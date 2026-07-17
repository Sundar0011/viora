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

import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();

// Android notification channel
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'high_importance',
  'High Importance',
  description: 'Heads-up notifications',
  importance: Importance.high,
);

// iOS notification settings
const DarwinNotificationDetails _iosNotificationDetails =
    DarwinNotificationDetails(
  presentAlert: true,
  presentBadge: true,
  presentSound: true,
  interruptionLevel: InterruptionLevel.active,
);

bool _wired = false;
StreamSubscription<RemoteMessage>? _fgSub;
StreamSubscription<String>? _tokenSub;

// Background message handler - MUST be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 Background message received: ${message.data}');

  // Handle background notification tap with URL (app not open)
  if (message.data.containsKey('url') && message.data['url']!.isNotEmpty) {
    final url = message.data['url']!;
    print('🌐 Background: Should open URL (app not open): $url');
    // Note: Background handler can't launch URLs directly
    // This will be handled when app is opened
  }
}

Future<String> setupNotifications() async {
  print('🔔 setupNotifications() started');
  try {
    // 1) Firebase init
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
      print('✅ Firebase initialized');
    } else {
      print('ℹ️ Firebase already initialized');
    }

    // 2) Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3) Force FCM auto init (sometimes disabled)
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    print('✅ FCM autoInit enabled');

    // 4) Request permissions (especially important for iOS)
    await _requestNotificationPermissions();

    // 5) Local notifications init with platform-specific settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: const DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    // Set up notification tap handling
    await _fln.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print(
            '🔔 Local notification tapped (app is open): ${response.payload}');
        await _handleNotificationTap(response.payload, isAppOpen: true);
      },
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      final androidPlugin = _fln.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_channel);
      print('✅ Android notification channel created');
    }

    print('✅ Local notifications initialized');

    // 6) Log current token + listen for refresh
    final token = await FirebaseMessaging.instance.getToken();
    print('🎯 CURRENT TOKEN: $token');
    _tokenSub?.cancel();
    _tokenSub = FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      print('🔄 TOKEN REFRESHED: $t');
    });

    // 7) Foreground handler → local banner with URL support
    if (!_wired || _fgSub == null) {
      _wired = true;
      await _fgSub?.cancel();
      _fgSub = FirebaseMessaging.onMessage.listen((RemoteMessage m) async {
        print('📩 onMessage ARRIVED: '
            'title=${m.notification?.title} body=${m.notification?.body} data=${m.data}');

        final title = m.notification?.title ??
            m.data['title']?.toString() ??
            'Notification';
        final body = m.notification?.body ?? m.data['body']?.toString() ?? '';

        // Create payload with URL for tap handling
        String? payload;
        if (m.data.containsKey('url') && m.data['url']!.isNotEmpty) {
          payload = m.data['url'];
        }

        // Platform-specific notification details
        final NotificationDetails notificationDetails = NotificationDetails(
          android: const AndroidNotificationDetails(
            'high_importance',
            'High Importance',
            channelDescription: 'Heads-up notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: _iosNotificationDetails,
        );

        await _fln.show(
          DateTime.now().millisecondsSinceEpoch % 100000,
          title,
          body,
          notificationDetails,
          payload: payload,
        );
        print(
            '✅ Foreground local notification shown with URL payload: $payload');
      });
      print('✅ Foreground listener wired');

      // Background → foreground (app was in background, user tapped notification)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) async {
        print('🟢 onMessageOpenedApp (app was in background): ${m.data} '
            '(title=${m.notification?.title}, body=${m.notification?.body})');

        // Handle URL opening when notification is tapped from background
        if (m.data.containsKey('url') && m.data['url']!.isNotEmpty) {
          final url = m.data['url']!;
          await _handleNotificationTap(url, isAppOpen: false);
        }
      });

      // App terminated → opened by notification
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        print('🟢 App opened from terminated state: ${initialMessage.data}');

        // Handle URL opening when app is opened from terminated state
        if (initialMessage.data.containsKey('url') &&
            initialMessage.data['url']!.isNotEmpty) {
          final url = initialMessage.data['url']!;
          // Delay to ensure app is fully loaded
          Future.delayed(const Duration(milliseconds: 1000), () async {
            await _handleNotificationTap(url, isAppOpen: false);
          });
        }
      }
    }

    print('🔔 setupNotifications() completed successfully');
    return 'ok';
  } catch (e, st) {
    print('❌ setupNotifications() failed: $e\n$st');
    return 'error: $e';
  }
}

// Request notification permissions (especially important for iOS)
Future<void> _requestNotificationPermissions() async {
  try {
    print('🔐 Requesting notification permissions...');

    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('📱 Notification permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Notification permissions granted');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('⚠️ Provisional notification permissions granted');
    } else {
      print('❌ Notification permissions denied');
    }
  } catch (e) {
    print('❌ Error requesting permissions: $e');
  }
}

// Handle notification tap with app state awareness
Future<void> _handleNotificationTap(String? payload,
    {required bool isAppOpen}) async {
  if (payload != null && payload.isNotEmpty) {
    print('🔔 Handling notification tap - App Open: $isAppOpen, URL: $payload');
    await _handleUrl(payload, isAppOpen: isAppOpen);
  }
}

// Handle URL - modify based on app state and launch directly
Future<void> _handleUrl(String url, {required bool isAppOpen}) async {
  try {
    print('🌐 Processing URL - App Open: $isAppOpen, Original URL: $url');

    // Check if it's your app's deep link
    if (url.startsWith('squadd://')) {
      String finalUrl = url;

      if (isAppOpen && url.contains('/loadingPage?')) {
        // App is open, change loadingPage to loading
        finalUrl = url.replaceAll('/loadingPage?', '/loading?');
        print('🔄 Modified URL for open app: $finalUrl');
      } else {
        // App is not open, use original URL
        print('📱 Using original URL (app not open): $finalUrl');
      }

      // Launch the deep link URL with platform-specific handling
      await _launchDeepLink(finalUrl, isAppOpen: isAppOpen);
    } else {
      // External URL - open in browser
      await _openUrlInBrowser(url);
    }
  } catch (e) {
    print('❌ Error handling URL: $e');
  }
}

// Launch deep link URL with platform-specific handling
Future<void> _launchDeepLink(String url, {required bool isAppOpen}) async {
  try {
    print('🔗 Launching deep link: $url (App Open: $isAppOpen)');

    final uri = Uri.parse(url);

    // Check if URL can be launched
    final canLaunch = await canLaunchUrl(uri);
    print('🔍 Can launch URL: $canLaunch');

    if (!canLaunch) {
      print('❌ Cannot launch URL: $url');
      return;
    }

    // Platform-specific launch strategy
    if (Platform.isIOS) {
      print('🍎 iOS detected - using iOS-specific launch strategy');

      if (isAppOpen) {
        // For iOS when app is open, try platformDefault first
        try {
          await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
          print('✅ iOS deep link launched successfully (platformDefault)');
        } catch (e) {
          print(
              '⚠️ iOS platformDefault failed, trying externalApplication: $e');
          try {
            await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            print(
                '✅ iOS deep link launched successfully (externalApplication)');
          } catch (e2) {
            print('❌ iOS all launch modes failed: $e2');
          }
        }
      } else {
        // For iOS when app is not open
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        print('✅ iOS deep link launched successfully (app was closed)');
      }
    } else if (Platform.isAndroid) {
      print('🤖 Android detected - using Android-specific launch strategy');

      // For Android, use externalApplication mode
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      print('✅ Android deep link launched successfully');
    } else {
      // Fallback for other platforms
      print('🖥️ Other platform detected - using platformDefault');
      await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
      print('✅ Deep link launched successfully (other platform)');
    }
  } catch (e, stackTrace) {
    print('❌ Error launching deep link: $e');
    print('📍 Stack trace: $stackTrace');
  }
}

// Open URL in browser
Future<void> _openUrlInBrowser(String url) async {
  try {
    print('🌐 Opening URL in browser: $url');

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Force external browser
      );
      print('✅ URL opened in browser successfully');
    } else {
      print('❌ Cannot launch URL: $url');
    }
  } catch (e) {
    print('❌ Error opening URL: $e');
  }
}
