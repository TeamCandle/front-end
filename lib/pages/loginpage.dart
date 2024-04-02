//dependencies
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
//files
import '../provider_class.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  void nothing() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("login test")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const WebViewPage()));
          },
          child: const Text("log in"),
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
  late WebViewController _webViewController;
  var initialUrl = 'http://13.209.220.187:80/user/login/kakao';

  @override
  void initState() {
    _webViewController = WebViewController();
    _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    _webViewController.loadRequest(Uri.parse(initialUrl));
    _webViewController.addJavaScriptChannel(
      'tokenHandler',
      onMessageReceived: (JavaScriptMessage message) {
        String token = message.message;
        print('Token: $token');
        //Navigator.of(context).pop(message.message);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebViewWidget(controller: _webViewController),
    );
  }
}

// class _LogInPageState extends State<LogInPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("login test")),
//       body: Center(
//         child: Stack(
//           children: [
//             if (context.read<UserInfo>().isLogined)
//               Positioned(
//                 top: 10,
//                 right: 10,
//                 child: Row(
//                   children: [
//                     Image.network(
//                       context
//                               .read<UserInfo>()
//                               .user
//                               ?.kakaoAccount
//                               ?.profile
//                               ?.profileImageUrl ??
//                           '',
//                       width: 50,
//                       height: 50,
//                     ),
//                     SizedBox(width: 10),
//                   ],
//                 ),
//               ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 if (context.read<UserInfo>().isLogined)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(
//                           width: 150,
//                           height: 200,
//                           child: ElevatedButton(
//                             onPressed: () {},
//                             child: Text('매칭', overflow: TextOverflow.visible),
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(
//                                   vertical: 20, horizontal: 40),
//                               backgroundColor: Colors.blue,
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 16),
//                         SizedBox(
//                           width: 150,
//                           height: 200,
//                           child: ElevatedButton(
//                             onPressed: () {},
//                             child: Text('커뮤니티', overflow: TextOverflow.visible),
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(
//                                   vertical: 20, horizontal: 40),
//                               backgroundColor: Colors.green,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 if (context.read<UserInfo>().isLogined)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(
//                           width: 150,
//                           height: 100,
//                           child: ElevatedButton(
//                             onPressed: () {},
//                             child: Text('프리미엄', overflow: TextOverflow.visible),
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(
//                                   vertical: 20, horizontal: 40),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 16),
//                         SizedBox(
//                           width: 150,
//                           height: 100,
//                           child: ElevatedButton(
//                             onPressed: () {},
//                             child: Text('프로필', overflow: TextOverflow.visible),
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(
//                                   vertical: 20, horizontal: 40),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 if (!context.read<UserInfo>().isLogined)
//                   ElevatedButton(
//                     onPressed: () async {
//                       await context.read<UserInfo>().login();
//                       setState(() {});
//                     },
//                     child: const Text('로그인'),
//                   ),
//               ],
//             ),
//             if (context.read<UserInfo>().isLogined)
//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.1,
//                   child: FractionallySizedBox(
//                     widthFactor: 1.0,
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         await context.read<UserInfo>().logout();
//                         setState(() {});
//                       },
//                       child: const Text('로그아웃'),
//                       style: ElevatedButton.styleFrom(
//                         padding:
//                             EdgeInsets.symmetric(vertical: 16, horizontal: 32),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
