//dependencies
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_doguber_frontend/firebase_options.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';
import 'package:google_fonts/google_fonts.dart';
//files
import 'mymap.dart';
import 'pages/profilepage.dart';
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

  //init firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //init my notification
  await CombinedNotificationService.initialize();

  //init kakao login sdk
  KakaoSdk.init(
    nativeAppKey: '8826eec5f744658162616455cf5361ad',
    javaScriptAppKey: '529540eb153fa80c33ac0fea3a763257',
  );

  //init local storage
  await initLocalStorage();

  await CombinedNotificationService.checkNotiLaunch();

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
  Widget build(BuildContext context) {
    //provider 등록
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserInfo>(
          create: (context) => UserInfo(),
        ),
        ChangeNotifierProvider<InfiniteList>(
          create: (context) => InfiniteList(),
        ),
        ChangeNotifierProvider<ChatData>(
          create: (context) => ChatData(),
        ),
        ChangeNotifierProvider<LocationInfo>(
          create: (context) => LocationInfo(),
        ),
      ],
      child: MaterialApp.router(
        //router.dart파일의 화면 트리로 이동.
        routerConfig: NewRoot,
        theme: ThemeData(
          //Color(0xFFa2e1a6)
          //Colors.black
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF005f4d),
            onPrimary: Colors.white,
            secondary: Color(0xFFa2e1a6),
            onSecondary: Colors.black,
            error: Color(0xFFF7F7F7),
            onError: Colors.black,
            surface: Color(0xFFF7F7F7),
            onSurface: Colors.black,
          ),
          dialogBackgroundColor: Color(0xFFF7F7F7),
          scaffoldBackgroundColor: const Color(0xFFF7F7F7),
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF7F7F7)),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFa2e1a6),
            foregroundColor: Colors.black,
          ),
          dialogTheme: DialogTheme(backgroundColor: Color(0xFFF7F7F7)),
          drawerTheme:
              const DrawerThemeData(backgroundColor: Color(0xFFF7F7F7)),
          cardTheme: const CardTheme(
            color: Colors.white,
            shadowColor: Colors.black,
            elevation: 10.0,
          ),
          textTheme: GoogleFonts.notoSansKrTextTheme(),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              elevation: WidgetStatePropertyAll<double?>(4),
              textStyle: WidgetStatePropertyAll<TextStyle>(
                GoogleFonts.notoSansKr(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
                EdgeInsets.all(8),
              ),
              foregroundColor:
                  const WidgetStatePropertyAll<Color>(Color(0xFF333333)),
              backgroundColor:
                  const WidgetStatePropertyAll<Color>(Color(0xFFa2e1a6)),
            ),
          ),
          timePickerTheme: const TimePickerThemeData(
            //backgroundColor: Color(0xFFF7F7F7),
            dialBackgroundColor: Color(0xFFF0F0F0),
            //dialHandColor: Color(0xFF005f4d),
            //dayPeriodColor: Color(0xFFa2e1a6),
            hourMinuteColor: Color(0xFFF0F0F0),
            dayPeriodTextColor: Colors.black,
            hourMinuteTextColor: Colors.black,
          ),
        ),
      ),
    );
  }
}
