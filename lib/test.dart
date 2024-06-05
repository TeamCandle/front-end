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

class TestWeb extends StatefulWidget {
  final dynamic url;
  final dynamic header;
  const TestWeb({
    super.key,
    required this.url,
    required this.header,
  });

  @override
  State<TestWeb> createState() => _TestWebState();
}

class _TestWebState extends State<TestWeb> {
  late final WebViewController _webViewController;
  final AuthApi _authApi = AuthApi();

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
    _webViewController.loadRequest(
      widget.url,
      headers: widget.header,
    );
    _webViewController.addJavaScriptChannel(
      'tokenHandler',
      onMessageReceived: (JavaScriptMessage message) async {},
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
