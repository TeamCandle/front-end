//예상 ui
//환영합니다
//카카오톡으로 로그인 하기

//dependencies
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_doguber_frontend/api.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

//files
import '../datamodels.dart';
import '../constants.dart';
import '../router.dart';

class CheckLocalInfoPage extends StatelessWidget {
  const CheckLocalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 비동기 함수 호출하여 로컬 데이터 확인 후 리디렉션
    _checkLocalInfo(context);
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _checkLocalInfo(BuildContext context) async {
    // 로컬 저장소에서 데이터 가져오기
    await Future.delayed(Duration(seconds: 2)); // 비동기 작업 예제
    final isLoggedIn = context.read<UserInfo>().isLoggedIn;

    // 결과에 따라 리디렉션
    if (isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }
}

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

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
                  onTap: () => context.go(RouterPath.webView),
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
