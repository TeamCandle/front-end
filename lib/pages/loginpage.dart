//예상 ui
//환영합니다
//카카오톡으로 로그인 하기

//dependencies
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_doguber_frontend/api.dart';
import 'package:flutter_doguber_frontend/pages/profilepage.dart';
import 'package:go_router/go_router.dart';
import 'package:localstorage/localstorage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

//files
import '../datamodels.dart';
import '../constants.dart';
import '../notification.dart';
import '../router.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final AuthApi _auth = AuthApi();
  @override
  void initState() {
    super.initState();
    CombinedNotificationService.setFcmhandlerInForeground();
    CombinedNotificationService.setNotificationHandler(context);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkLocalInfo();
    });
  }

  Future<void> checkLocalInfo() async {
    String? tempToken = localStorage.getItem('accessToken');
    if (tempToken == null) return;
    _auth.setAccessToken(accessToken: tempToken);
    await context.read<UserInfo>().updateMyProfile().then((bool result) {
      if (result == false) return;
      String? payload =
          CombinedNotificationService.details?.notificationResponse?.payload;
      //메시지에 메시지 유형 타입을 추가해달라고 부탁해서, show 시 아이디를 다르게 하자
      //..response?.id로 notification id 받아올 수 있는듯
      //아이디에 따라 switch로 context go 다르게 해보자
      context.go(RouterPath.home);
    });
  }
  // RemoteMessage? initialMessage =
  //       await FirebaseMessaging.instance.getInitialMessage();
  //   if (initialMessage != null) {
  //     CombinedNotificationService.notiTapStream.add(
  //       initialMessage.data['targetId'],
  //     );
  //   }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF005f4d),
        body: Stack(children: [
          Center(
            child: Column(children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(20),
                width: double.infinity,
                child: InkWell(
                  onTap: () => context.push(RouterPath.webView),
                  child: Image.asset('assets/images/icon_kakao_login.png'),
                ),
              ),
            ]),
          ),
          LayoutBuilder(builder: (context, constraints) {
            double radius = constraints.maxWidth / 3;
            return Stack(
              children: [
                Center(
                    child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: radius,
                )),
                Center(
                  child: Image.asset(
                    'assets/images/carrotBowLogo.png',
                    width: radius,
                    height: radius,
                  ),
                ),
              ],
            );
          }),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            AuthApi api = AuthApi();
            bool result = await api.getDummy();
            if (result == false) return;
            await context.read<UserInfo>().updateMyProfile().then((_) {
              debugPrint('[log] login success!');
              context.go('/home');
            });
          },
          child: const Text('dummy'),
        ),
      ),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;

    //platform check
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    //setup webview controller
    _webViewController = WebViewController.fromPlatformCreationParams(params);
    _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    _webViewController.loadRequest(Uri.parse(ServerUrl.loginUrl));
    _webViewController.addJavaScriptChannel(
      'tokenHandler',
      onMessageReceived: (JavaScriptMessage message) async {
        await context.read<UserInfo>().logIn(message).then(
          (bool result) {
            if (result == true) {
              context.go(RouterPath.home);
            }
          },
        );
      },
    );

    //setup webview on android
    AndroidWebViewController.enableDebugging(true);
    (_webViewController.platform as AndroidWebViewController)
        .setMediaPlaybackRequiresUserGesture(false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(child: WebViewWidget(controller: _webViewController)),
    );
  }
}
