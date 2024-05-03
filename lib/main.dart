//dependencies
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';
//files
import 'router.dart';
import 'providers.dart';

Future<void> main() async {
  //init flutter engine
  WidgetsFlutterBinding.ensureInitialized();

  //init kakao login sdk
  KakaoSdk.init(
    nativeAppKey: '8826eec5f744658162616455cf5361ad',
    javaScriptAppKey: '529540eb153fa80c33ac0fea3a763257',
  );

  //init local storage
  await initLocalStorage();

  //run app
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
