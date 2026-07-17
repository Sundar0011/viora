import '../database.dart';

class ChatTable extends SupabaseTable<ChatRow> {
  @override
  String get tableName => 'chat';

  @override
  ChatRow createRow(Map<String, dynamic> data) => ChatRow(data);
}

class ChatRow extends SupabaseDataRow {
  ChatRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ChatTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String? get lastMessage => getField<String>('last_message');
  set lastMessage(String? value) => setField<String>('last_message', value);

  DateTime? get lastMessageDate => getField<DateTime>('last_message_date');
  set lastMessageDate(DateTime? value) =>
      setField<DateTime>('last_message_date', value);

  DateTime? get firstMessageDate => getField<DateTime>('first_message_date');
  set firstMessageDate(DateTime? value) =>
      setField<DateTime>('first_message_date', value);

  String? get lastMessageUser => getField<String>('last_message_user');
  set lastMessageUser(String? value) =>
      setField<String>('last_message_user', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  bool? get isBlocked => getField<bool>('is_blocked');
  set isBlocked(bool? value) => setField<bool>('is_blocked', value);

  String? get blockedByUser => getField<String>('blocked_by_user');
  set blockedByUser(String? value) =>
      setField<String>('blocked_by_user', value);

  String get createdBy => getField<String>('created_by')!;
  set createdBy(String value) => setField<String>('created_by', value);

  String get chatType => getField<String>('chat_type')!;
  set chatType(String value) => setField<String>('chat_type', value);
}
