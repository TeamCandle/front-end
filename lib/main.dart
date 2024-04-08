//dependencies
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
//files
import 'router.dart';
import 'providers.dart';

void main() {
  // 웹 환경에서 카카오 로그인을 정상적으로 완료하려면 runApp() 호출 전 아래 메서드 호출 필요
  WidgetsFlutterBinding.ensureInitialized();

  // runApp() 호출 전 Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '8826eec5f744658162616455cf5361ad',
    javaScriptAppKey: '529540eb153fa80c33ac0fea3a763257',
  );
  runApp(const DogUberApp());
}

class DogUberApp extends StatelessWidget {
  const DogUberApp({super.key});

  @override
  Widget build(BuildContext context) {
    //provider 등록
    //router.dart파일의 화면 트리로 이동.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserInfo>(create: (_) => UserInfo()),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }
}
