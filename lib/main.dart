//dependencies
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_doguber_frontend/firebase_options.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';
import 'package:google_fonts/google_fonts.dart';
//files
import 'router.dart';
import 'datamodels.dart';
import 'notification.dart';
//TODO: floatingActionButtonLocation:
// FloatingActionButtonLocation.miniCenterDocked,

//CarouselSlider
//petItem으로 펫 슬라디잉
//전체적인 배경을 appBgColor(컬러그거에있음)으로 하고 요소들을 화이트로
//모든 텍스트박스를 custom textbox로
//0xFFC7F3D0

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
    FcmNotification.setFcmListenerInBackground(context);
    FcmNotification.setFcmListenerInForeground();
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
          scaffoldBackgroundColor: const Color(0xFFF7F7F7),
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF7F7F7)),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFFC7F3D0)),
          dialogTheme: const DialogTheme(backgroundColor: Color(0xFFF7F7F7)),
          cardTheme: const CardTheme(
            color: Colors.white,
            shadowColor: Colors.black,
            elevation: 10.0,
          ),
          textTheme: GoogleFonts.notoSansKrTextTheme(),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              textStyle: WidgetStatePropertyAll<TextStyle>(
                GoogleFonts.notoSansKr(
                  //fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
                EdgeInsets.all(8),
              ),
              foregroundColor:
                  const WidgetStatePropertyAll<Color>(Colors.black),
              backgroundColor:
                  const WidgetStatePropertyAll<Color>(Color(0xFFC7F3D0)),
            ),
          ),
        ),
      ),
    );
  }
}
