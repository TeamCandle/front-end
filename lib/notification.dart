import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_doguber_frontend/pages/profilepage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'firebase_options.dart';
import 'router.dart';

///1. 모바일에서 알람이 수신되는지 본다
///1-1. 백그라운드 및 종료 상태에서 수신이 되는가 : O
///1-2. 포그라운드 상태에서 수신이 되는가 : x

///2. 백그라운드 메시지 동작 확인
///2-1. 백그라운드 및 종료 상태에서 팝업된 메시지 탭 시
///-> 어플 오픈되기만 함.
///2-2. 백그라운드 및 종료 상태에서 알람 표시줄에 표시된 메시지 탭 시
///-> 어플 오픈되기만 함.

/// 3. 백그라운드 메시지 핸들링
/// 3-1. FCM 핸들러와 go router로 처리(setFcmHandlerInBackAndTerminated)
///  -> X
/// 3-2. FCM 핸들러와 순정 Navigator로 처리
/// -> X
/// 3-3. Notification 핸들러 추가

// 기능 명세
// 1. 요구 등록자가 신청을 받았을 때 메시지
// title : 케어타입
// body : ~월 ~일자 건에 대한 신청이 도착했습니다
// targetId : Requirement iD
// 2. 등록자가 신청 수락 시 신청자에게 전송되는 메시지
// title : 케어타입
// body : ~월 ~일자 건에 대한 신청이 수락되었습니다
// targetId : Match Id
// 3. 채팅
// title : sender 이름
// body : 메시지 내용
// targetId : Match Id

@pragma('vm:entry-point')
Future<void> handleFcmInBackAndTerminated(RemoteMessage message) async {
  //app이 background & terminated된 상태에서 fcm메시지 처리
  debugPrint("[log] got a fcm msg in background");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CombinedNotificationService.initialize();
  await CombinedNotificationService.showNotification(message);
}

class CombinedNotificationService {
  ///1. main에서 initialize 호출
  ///2. MaterialApp 내부의 stateful 위젯의 initState에 handler 2개 세팅
  static late FlutterLocalNotificationsPlugin notiController;
  static late StreamController<String?> notiTapStream;
  static late AndroidNotificationChannel notiChannel;

  static const int appliedNotiId = 1;
  static const int acceptedNotiId = 2;
  static const int chatNotiId = 3;
  static const String channelId = 'channelId'; //알림 채널 ID
  static const String streamId = 'streamId'; //알림스트림(리스너) ID
  static NotificationAppLaunchDetails? details;
  static Future<void> checkNotiLaunch() async {
    details = await notiController.getNotificationAppLaunchDetails();
  }

  static String? _fcmToken;

  static String? get fcmToken => _fcmToken;

  //initialize
  static Future<bool> _initFcmToken() async {
    _fcmToken = await FirebaseMessaging.instance.getToken();
    if (_fcmToken == null) {
      debugPrint('get fcmToken failed');
      return false;
    }
    debugPrint('[log] fcm token : $_fcmToken');

    //fcmToken 변경 시 핸들러 등록
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      debugPrint('[log] fcm token updated!!');
    }).onError((err) {
      debugPrint('[log] fcm token update error!!');
      return false;
    });
    return true;
  }

  static Future<bool> _initNotification() async {
    //init controllers
    notiTapStream = StreamController<String?>.broadcast(); //listener
    notiChannel = const AndroidNotificationChannel(
      channelId, // id
      channelId, // name
      description: 'chatting channel',
      importance: Importance.low,
    );
    notiController = FlutterLocalNotificationsPlugin(); //controller

    await notiController.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('app_icon'),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        //리스너 대기열(스트림)에 추가
        notiTapStream.add(response.payload);
        debugPrint('[log] notification tapped');
      },
      //onDidReceiveBackgroundNotificationResponse: interactNotiWithoutTap,
      //flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails()
    );
    return true;
  }

  static void _getPermissionOfNotification() {
    FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
    debugPrint('[log] User granted notification permission');
  }

  static Future<void> _getPermissionOfFcm() async {
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

  static Future<bool> initialize() async {
    //get fcm token
    await _initFcmToken().then((result) {
      if (result == false) return false;
    });

    //init local notification
    await _initNotification().then((result) {
      if (result == false) return false;
    });

    //get permission
    _getPermissionOfNotification();
    _getPermissionOfFcm();

    FirebaseMessaging.onBackgroundMessage(handleFcmInBackAndTerminated);

    return true;
  }

  ///////////////////////////////fcm function///////////////////////////////////
  static Future<void> setFcmhandlerInForeground() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('[log] Got a message in the foreground');
      await CombinedNotificationService.showNotification(message);
    });
  }

  // 보류. 동작 안함.
  // static Future<void> setHandlerOfOpenByFcm(
  //   void Function(RemoteMessage message) navigatorFunction,
  // ) async {
  //   //종료 상태에서 FCM을 받아 앱을 열 때
  //   // 동작 안함.
  //   await FirebaseMessaging.instance.getInitialMessage().then((initialMessage) {
  //     if (initialMessage != null) {
  //       debugPrint('[log] Got a message in the terminated');
  //       navigatorFunction(initialMessage);
  //     }
  //   });

  //   //background 상태에서 FCM을 받아 앱을 열 때
  //   //동작 안함
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
  //     debugPrint('[log] Got a message in the background');
  //     navigatorFunction(remoteMessage);
  //   });
  // }

  ////////////////////////////////Notification//////////////////////////////////
  //notification show function
  static Future<void> showNotification(RemoteMessage message) async {
    int id;
    switch (message.data['type']) {
      case 'applied':
        id = appliedNotiId;
        break;
      case 'accepted':
        id = acceptedNotiId;
        break;
      case 'chat':
        id = chatNotiId;
        break;
      default:
        id = 4;
        break;
    }
    var notiDetailForAnd = const AndroidNotificationDetails(
      channelId,
      channelId,
      channelDescription: 'android channel',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    var notiDetail = NotificationDetails(android: notiDetailForAnd);

    await notiController.show(
      id,
      message.data['title'],
      message.data['body'],
      notiDetail,
      payload: message.data['targetId'],
    );
  }

  static void setNotificationHandler(BuildContext context) {
    CombinedNotificationService.notiTapStream.stream
        .listen((String? payload) async {
      debugPrint('!!! setNotiListener launched');
      context.go(RouterPath.myProfile);
    });
  }
}
