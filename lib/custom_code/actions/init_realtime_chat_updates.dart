// Automatic FlutterFlow imports
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future initRealtimeChatUpdates() async {
  final client = Supabase.instance.client;
  final currentUserId = client.auth.currentUser?.id;

  if (currentUserId == null) {
    print('❌ No authenticated user found');
    return;
  }

  print('🔧 Current user ID: $currentUserId');

  // Test messages table accessibility
  print('🧪 Testing messages table subscription...');
  final testChannel = client.channel('test_messages_channel');
  testChannel
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'messages',
        callback: (payload) {
          print('🧪 TEST: Messages table event detected!');
          print('🧪 TEST Event: ${payload.eventType}');
          print('🧪 TEST New: ${payload.newRecord}');
          print('🧪 TEST Old: ${payload.oldRecord}');
        },
      )
      .subscribe();

  // Helper function to safely convert values to int
  int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper function to check if a field is a count field
  bool isCountField(String key) {
    return key == 'unread_message_count' ||
        key == 'total_dm_chats' ||
        key == 'total_sale_chats' ||
        key == 'total_unread_message_count' ||
        key.endsWith('_count');
  }

  // Use separate channels for each table to avoid conflicts
  final chatChannel = client.channel('chat_table_realtime');
  final chatUsersChannel = client.channel('chat_users_table_realtime');
  final messagesChannel = client.channel('messages_table_realtime');

  // Subscribe to chat table changes
  chatChannel
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat',
        callback: (payload) {
          try {
            final eventType = payload.eventType;
            final newRow = payload.newRecord;
            final oldRow = payload.oldRecord;

            print('📡 Realtime Event Type: ${eventType} on table: chat');
            print('🆕 New record: $newRow');
            print('🗑️ Old record: $oldRow');

            // Check if newRow is valid for INSERT/UPDATE
            if (eventType != PostgresChangeEvent.delete &&
                (newRow == null || newRow['id'] == null)) {
              print('❌ Invalid payload: newRow or ID is null');
              return;
            }

            // Check if oldRow is valid for DELETE
            if (eventType == PostgresChangeEvent.delete &&
                (oldRow == null || oldRow['id'] == null)) {
              print('❌ Invalid DELETE payload: oldRow or ID is null');
              return;
            }

            final chatId = newRow?['id'] ?? oldRow?['id'];

            FFAppState().update(() {
              final chats =
                  List<Map<String, dynamic>>.from(FFAppState().matchedUsers);

              if (eventType == PostgresChangeEvent.insert ||
                  eventType == PostgresChangeEvent.update) {
                print(
                    '🔄 Processing ${eventType.name.toUpperCase()} for chat ID: $chatId');

                final existingIndex =
                    chats.indexWhere((c) => c['chat_id'] == chatId);

                if (existingIndex != -1) {
                  // Chat found in app state - perform smart merge
                  final existingChat =
                      Map<String, dynamic>.from(chats[existingIndex]);

                  // Update chat fields
                  for (final key in newRow.keys) {
                    final newValue = newRow[key];

                    // Skip null values to preserve existing enriched data
                    if (newValue == null) {
                      print('⏭️ Skipping null value for key: $key');
                      continue;
                    }

                    // Special handling for count fields
                    if (isCountField(key)) {
                      final existingCount = toInt(existingChat[key]);
                      final newCount = toInt(newValue);

                      // Don't overwrite positive counts with 0 (prevents race conditions)
                      if (newCount == 0 && existingCount > 0) {
                        print(
                            '⏭️ Preserving existing count for $key: $existingCount (new was 0)');
                        continue;
                      }
                    }

                    // Map database fields to app state fields
                    switch (key) {
                      case 'id':
                        existingChat['chat_id'] = newValue;
                        break;
                      case 'created_at':
                        existingChat['chat_created_at'] = newValue;
                        break;
                      case 'last_message':
                      case 'last_message_date':
                      case 'first_message_date':
                      case 'last_message_user':
                      case 'is_blocked':
                      case 'blocked_by_user':
                      case 'chat_type':
                        existingChat[key] = newValue;
                        break;
                    }
                  }

                  chats[existingIndex] = existingChat;
                  print('✅ Merged data for existing chat: $chatId');
                } else {
                  // Chat not found in app state - ignore the update
                  print(
                      '⏭️ Chat $chatId not found in app state, ignoring ${eventType.name.toUpperCase()}');
                }
              } else if (eventType == PostgresChangeEvent.delete) {
                // Delete the entire chat
                print('🗑️ Deleting chat with ID: $chatId');

                final existingIndex =
                    chats.indexWhere((c) => c['chat_id'] == chatId);

                if (existingIndex != -1) {
                  chats.removeAt(existingIndex);
                  print('✅ Deleted chat: $chatId');
                } else {
                  print('⚠️ Chat $chatId not found for deletion');
                }
              }

              FFAppState().matchedUsers = chats;
              print('✅ Updated matchedUsers with ${chats.length} chats');
            });
          } catch (e) {
            print('❌ Error in chat table callback: $e');
          }
        },
      )
      .subscribe();

  // Subscribe to chat_users table changes
  chatUsersChannel
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_users',
        callback: (payload) {
          try {
            final eventType = payload.eventType;
            final newRow = payload.newRecord;
            final oldRow = payload.oldRecord;

            print('📡 Realtime Event Type: ${eventType} on table: chat_users');

            // Only process if this affects the current user
            final affectedUserId = newRow?['user_id'] ?? oldRow?['user_id'];
            final chatId = newRow?['chat_id'] ?? oldRow?['chat_id'];

            if (chatId == null) {
              print('❌ No chat_id found in payload');
              return;
            }

            print(
                '🔄 Processing chat_users change for chat: $chatId, user: $affectedUserId');

            FFAppState().update(() {
              final chats =
                  List<Map<String, dynamic>>.from(FFAppState().matchedUsers);

              if (eventType == PostgresChangeEvent.delete) {
                // If current user is deleted from chat, remove chat from app state
                if (affectedUserId == currentUserId) {
                  final existingIndex =
                      chats.indexWhere((c) => c['chat_id'] == chatId);
                  if (existingIndex != -1) {
                    chats.removeAt(existingIndex);
                    print('✅ Removed chat from app state: $chatId');
                  }
                }
              } else if (eventType == PostgresChangeEvent.update) {
                // Handle is_deleted flag changes
                final isDeleted = newRow?['is_deleted'] ?? false;
                if (isDeleted && affectedUserId == currentUserId) {
                  final existingIndex =
                      chats.indexWhere((c) => c['chat_id'] == chatId);
                  if (existingIndex != -1) {
                    chats.removeAt(existingIndex);
                    print(
                        '✅ Chat marked as deleted, removed from app state: $chatId');
                  }
                }
              }

              FFAppState().matchedUsers = chats;
            });
          } catch (e) {
            print('❌ Error in chat_users callback: $e');
          }
        },
      )
      .subscribe();

  // Subscribe to messages table changes (for unread count updates)
  messagesChannel
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'messages',
        callback: (payload) {
          try {
            final eventType = payload.eventType;
            final newRow = payload.newRecord;
            final oldRow = payload.oldRecord;

            print('📡 Realtime Event Type: ${eventType} on table: messages');
            print('🆕 Message New record: $newRow');
            print('🗑️ Message Old record: $oldRow');

            final chatId = newRow?['chat_id'] ?? oldRow?['chat_id'];
            if (chatId == null) {
              print('❌ No chat_id found in message payload');
              return;
            }

            print('🔄 Processing message event for chat: $chatId');

            // Only process if this affects a chat the user is part of
            FFAppState().update(() {
              final chats =
                  List<Map<String, dynamic>>.from(FFAppState().matchedUsers);
              final existingIndex =
                  chats.indexWhere((c) => c['chat_id'] == chatId);

              if (existingIndex != -1) {
                final existingChat =
                    Map<String, dynamic>.from(chats[existingIndex]);
                print('📍 Found chat in app state: ${existingChat['chat_id']}');

                if (eventType == PostgresChangeEvent.insert) {
                  // New message - update last message info and potentially unread count
                  if (newRow != null) {
                    final senderId = newRow['sender_id'];
                    final messageText = newRow['message'];
                    final createdAt = newRow['created_at'];
                    final isRead = newRow['is_read'] ?? false;

                    print(
                        '📨 New message from $senderId, isRead: $isRead, currentUser: $currentUserId');

                    // Update last message info (this might be redundant with chat table updates, but ensures consistency)
                    existingChat['last_message'] = messageText;
                    existingChat['last_message_date'] = createdAt;
                    existingChat['last_message_user'] = senderId;

                    // Update unread count if message is from other user and not read
                    // Based on your RPC: messages from other user that are unread by current user
                    if (senderId != currentUserId && !isRead) {
                      final currentUnread =
                          toInt(existingChat['unread_message_count']);
                      final newUnreadCount = currentUnread + 1;
                      existingChat['unread_message_count'] = newUnreadCount;

                      print(
                          '📈 Unread count increased from $currentUnread to $newUnreadCount for chat $chatId');

                      // Update total unread count across all chats
                      final currentTotalUnread =
                          toInt(existingChat['total_unread_message_count']);
                      final newTotalUnread = currentTotalUnread + 1;

                      // Update total unread for ALL chats in the list
                      for (int i = 0; i < chats.length; i++) {
                        final otherChat = Map<String, dynamic>.from(chats[i]);
                        otherChat['total_unread_message_count'] =
                            newTotalUnread;
                        chats[i] = otherChat;
                      }

                      print(
                          '📊 Total unread count updated from $currentTotalUnread to $newTotalUnread');
                    } else {
                      print(
                          '📝 Message is read or from current user, no unread count change');
                    }

                    print(
                        '✅ Updated chat with new message: $chatId, unread: ${existingChat['unread_message_count']}');
                  }
                } else if (eventType == PostgresChangeEvent.update) {
                  // Message updated (e.g., marked as read)
                  if (newRow != null && oldRow != null) {
                    final senderId = newRow['sender_id'];
                    final oldIsRead = oldRow['is_read'] ?? false;
                    final newIsRead = newRow['is_read'] ?? false;

                    print(
                        '📖 Message read status change: $oldIsRead -> $newIsRead, sender: $senderId');

                    // If message was marked as read and it's from other user to current user
                    if (!oldIsRead && newIsRead && senderId != currentUserId) {
                      final currentUnread =
                          toInt(existingChat['unread_message_count']);
                      if (currentUnread > 0) {
                        final newUnreadCount = currentUnread - 1;
                        existingChat['unread_message_count'] = newUnreadCount;

                        print(
                            '📉 Unread count decreased from $currentUnread to $newUnreadCount for chat $chatId');

                        // Update total unread count across all chats
                        final currentTotalUnread =
                            toInt(existingChat['total_unread_message_count']);
                        if (currentTotalUnread > 0) {
                          final newTotalUnread = currentTotalUnread - 1;

                          // Update total unread for ALL chats in the list
                          for (int i = 0; i < chats.length; i++) {
                            final otherChat =
                                Map<String, dynamic>.from(chats[i]);
                            otherChat['total_unread_message_count'] =
                                newTotalUnread;
                            chats[i] = otherChat;
                          }

                          print(
                              '📊 Total unread count updated from $currentTotalUnread to $newTotalUnread');
                        }
                      }
                    } else {
                      print(
                          '📝 No unread count change needed for this read status update');
                    }

                    print(
                        '✅ Updated message read status for chat: $chatId, unread: ${existingChat['unread_message_count']}');
                  }
                } else if (eventType == PostgresChangeEvent.delete) {
                  // Message deleted - might need to recalculate unread count
                  if (oldRow != null) {
                    final senderId = oldRow['sender_id'];
                    final wasRead = oldRow['is_read'] ?? false;

                    print(
                        '🗑️ Message deleted, was read: $wasRead, sender: $senderId');

                    // If deleted message was unread and from other user to current user
                    if (!wasRead && senderId != currentUserId) {
                      final currentUnread =
                          toInt(existingChat['unread_message_count']);
                      if (currentUnread > 0) {
                        final newUnreadCount = currentUnread - 1;
                        existingChat['unread_message_count'] = newUnreadCount;

                        print(
                            '📉 Unread count decreased from $currentUnread to $newUnreadCount after deletion');

                        // Update total unread count across all chats
                        final currentTotalUnread =
                            toInt(existingChat['total_unread_message_count']);
                        if (currentTotalUnread > 0) {
                          final newTotalUnread = currentTotalUnread - 1;

                          // Update total unread for ALL chats in the list
                          for (int i = 0; i < chats.length; i++) {
                            final otherChat =
                                Map<String, dynamic>.from(chats[i]);
                            otherChat['total_unread_message_count'] =
                                newTotalUnread;
                            chats[i] = otherChat;
                          }

                          print(
                              '📊 Total unread count updated from $currentTotalUnread to $newTotalUnread');
                        }
                      }
                    } else {
                      print(
                          '📝 Deleted message was read or from current user, no count change');
                    }

                    print(
                        '✅ Updated counts after message deletion: $chatId, unread: ${existingChat['unread_message_count']}');
                  }
                }

                chats[existingIndex] = existingChat;
              } else {
                print(
                    '⚠️ Chat $chatId not found in app state for message update');
              }

              FFAppState().matchedUsers = chats;
              print('✅ Updated matchedUsers after message event');
            });
          } catch (e) {
            print('❌ Error in messages callback: $e');
          }
        },
      )
      .subscribe();

  print('🎧 Realtime subscriptions initialized for chat tables:');
  print('   - Chat table: chat_table_realtime');
  print('   - Chat users table: chat_users_table_realtime');
  print('   - Messages table: messages_table_realtime');
}
