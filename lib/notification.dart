import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'firebase_options.dart';
import 'router.dart';

//exfAqq5NSyugB-Bst4UVix:APA91bFR7PCtRFwCBO5XjYLf2gOO3eUp93_urIPcC6XyDGZeXx1poNi4Zzgf-SwTOQ9PcCRkJF-93HUQGB-RyYfjikENlw7fE9Ji9Hc_wDGRH3ZWhdzvgGlApBq43kINn8c9gJzhyuN

@pragma('vm:entry-point')
Future<void> listenFcmInBackground(RemoteMessage message) async {
  //app이 background & terminated된 상태에서 fcm메시지 처리
  debugPrint("[log] got a fcm msg in background");

  final backNotiController = FlutterLocalNotificationsPlugin();
  debugPrint('[log] Got a notification in message');
  var notiDetailForAnd = const AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    channelDescription: 'your channel description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  var notiDetail = NotificationDetails(android: notiDetailForAnd);

  await backNotiController.show(
    1,
    message.data['title'],
    message.data['body'],
    notiDetail,
    payload: 'item x',
  );
}

class FcmNotification {
  static late FlutterLocalNotificationsPlugin notiController;
  static late StreamController<String?> notiTapStream;
  static late AndroidNotificationChannel notiChannel;

  static int notiId = 1; //개별 푸쉬알림 ID
  static String notiChId = 'ntCh'; //알림 채널 ID
  static String notiStreamId = 'ntStream'; //알림스트림(리스너) ID

  static String? _fcmToken;

  String? get fcmToken => _fcmToken;

  static Future<bool> initFcmNotification() async {
    //get fcm token
    _fcmToken = await FirebaseMessaging.instance.getToken();
    if (_fcmToken == null) {
      debugPrint('get fcmToken failed');
      return false;
    }
    debugPrint('[log] fcm token : $_fcmToken');

    //fcmToken 변경 시 핸들링
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      debugPrint('[log] fcm token updated!!');
    }).onError((err) {
      debugPrint('[log] fcm token update error!!');
      return false;
    });

    //fcm message를 백그라운드 및 종료 상태에서도 감지하도록 설정
    FirebaseMessaging.onBackgroundMessage(listenFcmInBackground);

    //init local notification
    notiTapStream = StreamController<String?>.broadcast(); //listener
    notiChannel = AndroidNotificationChannel(
      notiChId, // id
      'MY FOREGROUND SERVICE', // title
      description: 'notification ch',
      importance: Importance.low,
    );
    notiController = FlutterLocalNotificationsPlugin(); //controller
    await notiController.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('app_icon'),
      ),
      onDidReceiveNotificationResponse: onNotiTapped,
      //onDidReceiveBackgroundNotificationResponse: interactNotiWithoutTap,
    );

    //get permission
    getNotiPermission();
    getFcmPermission();

    return true;
  }

  static void getNotiPermission() {
    FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
    debugPrint('[log] User granted notification permission');
  }

  static Future<void> getFcmPermission() async {
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
    debugPrint('[log] User granted fcm permission');
    debugPrint('[log] ${settings.authorizationStatus}');
  }

  static void onNotiTapped(NotificationResponse notificationResponse) {
    debugPrint('[log] notification tapped');
    //리스너 대기열(스트림)에 추가
    notiTapStream.add(notificationResponse.payload);
  }

  //얘는 일단 보류해두고.
  static Future<void> setTapListener(BuildContext context) async {
    //when app terminated
    await FirebaseMessaging.instance.getInitialMessage().then((initialMessage) {
      if (initialMessage != null) {
        _gotoHomePage(initialMessage, context);
      }
    });

    //when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      _gotoHomePage(remoteMessage, context);
    });
  }

  static void _gotoHomePage(RemoteMessage message, BuildContext context) =>
      context.go(RouterPath.home);
}
