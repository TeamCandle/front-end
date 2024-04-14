//예상 ui
//환영합니다
//카카오톡으로 로그인 하기

//dependencies
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

//files
import '../providers.dart';
import '../constants.dart';

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("login test")),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const WebViewPage()));
              },
              child: const Text("log in"),
            ),
            ElevatedButton(
              onPressed: () => {context.go('/home')},
              child: const Text('home'),
            ),
          ],
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
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _webViewController = WebViewController.fromPlatformCreationParams(params);
    _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    _webViewController.loadRequest(Uri.parse(ServerUrl.loginUrl));
    _webViewController.addJavaScriptChannel(
      'tokenHandler',
      onMessageReceived: logInMethod,
    );
    AndroidWebViewController.enableDebugging(true);
    (_webViewController.platform as AndroidWebViewController)
        .setMediaPlaybackRequiresUserGesture(false);
    super.initState();
  }

  void logInMethod(JavaScriptMessage message) async {
    var token = jsonDecode(message.message);
    context.read<UserInfo>().logIn(
        accessToken: token['accessToken'], refreshToken: token['refreshToken']);
    await context.read<UserInfo>().getMyProfile().then((_) {
      context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebViewWidget(controller: _webViewController),
    );
  }
}
