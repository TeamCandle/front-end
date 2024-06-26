// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBWbp-uEJEITyghvwexKRJLTr1YFLix5TI',
    appId: '1:1006717290462:web:cd3231850e217d79843f4f',
    messagingSenderId: '1006717290462',
    projectId: 'carrotbow-fcc75',
    authDomain: 'carrotbow-fcc75.firebaseapp.com',
    storageBucket: 'carrotbow-fcc75.appspot.com',
    measurementId: 'G-1SPVXKCVZS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAS6TsM59WaQiqyFL-IAzlwwN7ebK4ts8U',
    appId: '1:1006717290462:android:0ba0b1be555a4ddd843f4f',
    messagingSenderId: '1006717290462',
    projectId: 'carrotbow-fcc75',
    storageBucket: 'carrotbow-fcc75.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDgvemRwzx0fIdeh2yrZc-qiMaWTNmR1sk',
    appId: '1:1006717290462:ios:e1fea0d613caf53e843f4f',
    messagingSenderId: '1006717290462',
    projectId: 'carrotbow-fcc75',
    storageBucket: 'carrotbow-fcc75.appspot.com',
    iosBundleId: 'com.example.flutterDoguberFrontend',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDgvemRwzx0fIdeh2yrZc-qiMaWTNmR1sk',
    appId: '1:1006717290462:ios:e1fea0d613caf53e843f4f',
    messagingSenderId: '1006717290462',
    projectId: 'carrotbow-fcc75',
    storageBucket: 'carrotbow-fcc75.appspot.com',
    iosBundleId: 'com.example.flutterDoguberFrontend',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBWbp-uEJEITyghvwexKRJLTr1YFLix5TI',
    appId: '1:1006717290462:web:ceab2132ad527772843f4f',
    messagingSenderId: '1006717290462',
    projectId: 'carrotbow-fcc75',
    authDomain: 'carrotbow-fcc75.firebaseapp.com',
    storageBucket: 'carrotbow-fcc75.appspot.com',
    measurementId: 'G-1CTDHPCWGQ',
  );
}
