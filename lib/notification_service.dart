import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:study_pulse_edu/resources/widgets/show_parent_verification_dialog.dart';
import 'package:study_pulse_edu/routes/route_const.dart';
import 'package:study_pulse_edu/viewmodels/mobile/count_notification_mobile_user_view_model.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Nhận thông báo (background): ${message.messageId}');
}

Future<void> setupFlutterNotifications(
    GlobalKey<NavigatorState> navigatorKey) async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (details) async {
      final payload = details.payload;
      if (payload != null) {
        final data = jsonDecode(payload);
        await _handleNotificationTap(navigatorKey, data);
      }
    },
  );
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null) {
    final payloadJson = jsonEncode(message.data);
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Thông báo chung',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
      payload: payloadJson,
    );
  }
}

Future<void> handleFCMEvents(GlobalKey<NavigatorState> navigatorKey) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showFlutterNotification(message);
    if(message.data['type'] == 'ATTENDANCE' || message.data['type'] == 'SCORE' || message.data['type'] == 'TUITION' || message.data['type'] == 'RESULT') {
      final context = navigatorKey.currentContext;
      final accountId = message.data['accountId'];
      if (context != null) {
        final container = ProviderScope.containerOf(context);
        container
            .read(countNotificationMobileUserViewModelProvider.notifier)
            .refreshUnreadCount(accountId);
      }
    }

  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    await _handleNotificationTap(navigatorKey, message.data);
  });

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    await _handleNotificationTap(navigatorKey, initialMessage.data);
  }
}

Future<void> _handleNotificationTap(
  GlobalKey<NavigatorState> navigatorKey,
  Map<String, dynamic> data,
) async {
  final context = navigatorKey.currentContext!;

  if(data['type'] == 'ATTENDANCE' || data['type'] == 'SCORE' || data['type'] == 'TUITION' || data['type'] == 'RESULT') {

    final matches =
      GoRouter.of(context).routerDelegate.currentConfiguration.matches;
    final isAtNotificationScreen = matches.any((match) {
    final route = match.route;
    return route is GoRoute &&
        route.name == RouteConstants.userNotificationRouteName;
  });
    final parentCode = data['parentCode'];
    if (isAtNotificationScreen) {
      return;
    }

    final enteredCode = await showParentVerificationDialog(context);
    if (enteredCode == parentCode) {
      context.pushNamed(RouteConstants.userNotificationRouteName, extra: {
        "accountId": data['accountId'],
        "onClose": () {
          final container = ProviderScope.containerOf(context);
          container
              .read(countNotificationMobileUserViewModelProvider.notifier)
              .refreshUnreadCount(data['accountId']);
        }
      });
    } else if (enteredCode != null) {
      showErrorToast("Mã xác nhận phụ huynh không chính xác");
    }
  }

  if (data['type'] == 'ASSIGNMENT') {
    final matches =
        GoRouter.of(context).routerDelegate.currentConfiguration.matches;
    final isAtNotificationScreen = matches.any((match) {
      final route = match.route;
      return route is GoRoute &&
          route.name == RouteConstants.userAssignmentRouteName;
    });
    if (isAtNotificationScreen) {
      return;
    }
      context.pushNamed(RouteConstants.userAssignmentRouteName, extra: {
        "studentId": data['studentId'],
        "studentName": data['studentName'],
        "studentCode": data['studentCode'],
      },);
  }
}
