//dependencies
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_doguber_frontend/firebase_options.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';
//files
import 'router.dart';
import 'datamodels.dart';
import 'notification.dart';

//exfAqq5NSyugB-Bst4UVix:APA91bFR7PCtRFwCBO5XjYLf2gOO3eUp93_urIPcC6XyDGZeXx1poNi4Zzgf-SwTOQ9PcCRkJF-93HUQGB-RyYfjikENlw7fE9Ji9Hc_wDGRH3ZWhdzvgGlApBq43kINn8c9gJzhyuN1
Future<void> main() async {
  //init flutter engine
  WidgetsFlutterBinding.ensureInitialized();

  //init fcm
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FcmNotification.initFcmNotification();

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

class DogUberApp extends StatefulWidget {
  const DogUberApp({super.key});

  @override
  State<DogUberApp> createState() => _DogUberAppState();
}

class _DogUberAppState extends State<DogUberApp> {
  @override
  void initState() {
    super.initState();
    //FcmNotification.setTapListener(context);
  }

  @override
  Widget build(BuildContext context) {
    //provider 등록
    //router.dart파일의 화면 트리로 이동.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserInfo>(create: (context) => UserInfo()),
        ChangeNotifierProvider<InfinitList>(create: (context) => InfinitList()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFF77D970),
            //unselectedItemColor: Colors.grey,
          ),
          buttonTheme: const ButtonThemeData(buttonColor: Color(0xFF77D970)),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF77D970)),
          dialogTheme: const DialogTheme(backgroundColor: Colors.white),
          cardTheme: const CardTheme(
            color: Colors.white,
            shadowColor: Colors.black,
            elevation: 10.0,
          ),
        ),
      ),
    );
  }
}
