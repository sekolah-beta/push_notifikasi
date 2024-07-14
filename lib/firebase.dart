// ignore_for_file: unused_import

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:push_notifikasi/firebase_options.dart';
import 'package:push_notifikasi/local_notification.dart';
import 'package:push_notifikasi/main.dart';

class FirebaseApp {
  static init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showLocalNotification(message);
    });

    await FirebaseMessaging.instance.subscribeToTopic("all");
  }

  static Future<void> setupInteractedMessage(context) async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      handleMessage(context);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMessage(context);
    });

    // Retrieve payload notification from local notification using RxDart
    onClickNotification.stream.listen((payload) {
      handleMessage(context);
    });
  }
}

void handleMessage(context) {
  print('new message');
  // Navigator.push(context, MaterialPageRoute(builder: (builder) {
  //   return const NotificationScreen();
  // }));
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void showLocalNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (kIsWeb || android == null || notification == null) return;

  String? payload = json.encode(message.data);

  localNotification.show(
      notification.hashCode, notification.title, notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel?.id ?? '',
          channel?.name ?? '',
          channelDescription: channel?.description ?? '',
          playSound: true,
          // color: Colors.white,
          icon: "@mipmap/ic_launcher",
        ),
      ),
      payload: payload);
}
