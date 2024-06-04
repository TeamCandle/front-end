# flutter_doguber_v1

## TODO
결제플로우
예외플로우

## 요청사항 or 질문사항
무조건 결제가 선행되어야 매칭을 완료할 수 있는가?


## 참고 링크
- 플러터 참고 자료 모음
https://velog.io/@jaybon/%ED%94%8C%EB%9F%AC%ED%84%B0-%EA%B4%80%EB%A0%A8-%EC%82%AC%EC%9D%B4%ED%8A%B8-%EC%B6%94%EC%B2%9C  
https://velog.io/@ximya_hf/howtowirtutilclasslikepro  
https://medium.com/@gunseliunsal/stateless-vs-stateful-widgets-in-flutter-852741b6046e  

- ui 템플릿들
https://flutterawesome.com/tag/ui/  
https://iqonic.design/product-category/mobile/page/3/

- 기능 샘플 코드
https://github.com/lkrcdd/flutter_google_map_demo.git
https://github.com/lkrcdd/flutter_push_back_v3.git

- ui
https://github.com/sangvaleap/app-flutter-pet-adoption?ref=flutterawesome.com

## 사용 패키지 및 API
화면 이동 : go_router  
상태 관리 : provider. 안드로이드의 viewmodel이라고 생각하면 됨.  
백그라운드 서비스 : flutter_background_service 패키지  
지도 : google API, geolocator, geocoding 
로컬 스토리지 : localstorage
스케줄링 : Timer
푸쉬 알림 : FCM, local_notification
채팅 : stomp

파일 구성
- api.dart : 통신 모듈
- constants.dart : 상수 파일. 링크, 텍스트스타일 등의 const변수 저장  
- providers.dart : 데이터 파일. viewmodel역할
- router.dart : 화면 이동 경로 지정



## setting
#### 1. google map api setting
1. api 키 발급 https://cloud.google.com/maps-platform/
  -> api 키 : AIzaSyBTk9blgdCa4T8fARQha7o-AuF8WkK3byI
2. API 및 서비스 항목으로 이동해서 sdk for android, ios enable
3. android/app/build.gradle 
  -> minSdk = flutter.minSdkVersion
4. android/app/src/main/AndroidManifest.xml 
  -> api key setup <activity ~ activity/> 
  !주의! 키 위치가 잘못 적히면 지도 안나옴. 만약 수정했다면 rebuild하지 말고 앱을 완전히 끄고 다시 빌드해야함
  -> <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>

#### 2. local_notification setting
1. android/app/build.gradle에 종속성 추가
android {
    ...
    compileSdk flutter.compileSdkVersion  //doctor로 확인해서 34이하면 34로 명시
    ...
    compileOptions {
        coreLibraryDesugaringEnabled true
        ...
    }
    defaultConfig {
        ...
        multiDexEnabled true
    }
    ...
}
dependencies {
    implementation 'androidx.window:window:1.0.0'
    implementation 'androidx.window:window-java:1.0.0'
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:1.2.2'
}

2. android/build.gradle에 종속성 추가
코드 최상단에 추가
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.1'
    }
}

3. android/app/src/main/AndroidManifest.xml 세팅
application 태그 내의 하단에 추가
<receiver 
  android:exported="false" 
  android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver" />

4. permission 받기
notiController
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
그럼 notify 시 권한이 있는지 확인하는 함수도 필요할듯.

#### 3. firebase setting
1. install firebase cli (if not installed)
2. firebase login
3. flutterfire configure
4. set android package name

#### 4. flutter_background_service setting 
1. android/build.gradle setting
buildscript {
    ext.kotlin_version = '1.8.10' <-
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.2' <-
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version" <-
    }
}

2. android/app/build.gradle setting
dependencies에 추가
implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8:$kotlin_version"

3. android/gradle/wrapper/gradle-wrapper.properties
-> distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip 로 변경

4. permission setting
android/app/src/main/AndroidManifest.xml에 permission 코드 추가
<manifest xmlns:android="http://schemas.android.com/apk/res/android" xmlns:tools="http://schemas.android.com/tools" package="com.example">
  ...
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
...



## information
#### provider 사용법
- 값을 읽는 가장 쉬운 방법은 BuildContext의 확장 메소드를 활용하는 것입니다.  
context.watch<T>() : 위젯이 T의 변화를 감지할 수 있도록 합니다.  
context.read<T>() : T를 변화 감지 없이 return 합니다.  
context.select<T, R>(R cb(T value)) : T의 일부 작은 영역에 대해서만 위젯이 변화를 감지할 수 있도록 합니다.  

- 멀티 프로바이더 선언 (메인 함수에)
MultiProvider(  
  providers: [  
    Provider<Something>(create: (_) => Something()),  
    Provider<SomethingElse>(create: (_) => SomethingElse()),  
    Provider<AnotherThing>(create: (_) => AnotherThing()),  
  ],  
  child: someWidget,  
)  

#### localstorage package
main -> await initLocalStorage()
localStorage.getItem('key')
localStorage.setItem('key', 'value')
key - value 형태로 간단한 정보만 저장

#### google map API
지도 사용 시 permission get -> handleLocationPermission() 함수로 얻음

구글 맵 컨트롤러 할당 LatLng 타입 변수로 좌표 지정 가능

마커 표시 
-> infowindow : 마커 클릭 시 표시되는 창 
-> snippet : subtitle

#### 변수 선언 종류
String, int ... : classic variable type

- type free variable
var : compile time variable -> must be init
dynamic : run time variable

- constants
const : compile time constants
final : run time constants(assign only one time)

- scope
static : global variable(class에 사용)

- init time
late : late init variable

#### 스프링부트 파일 구조  
my-spring-boot-project/  
├── src/  
│   ├── main/  
│   │   ├── java/                    # 자바 소스 코드 디렉터리  
│   │   │   └── com/  
│   │   │       └── example/  
│   │   │           └── myproject/  
│   │   │               ├── controller/    # 컨트롤러 클래스 디렉터리  
│   │   │               ├── model/         # 모델 클래스 디렉터리  
│   │   │               ├── repository/    # 리포지토리 클래스 디렉터리  
│   │   │               └── service/       # 서비스 클래스 디렉터리  
│   │   ├── resources/               # 리소스 디렉터리 (프로퍼티 파일, 정적 리소스 등)  
│   │   │   ├── static/              # 정적 리소스 (CSS, JavaScript, 이미지 등)  
│   │   │   ├── templates/           # 템플릿 파일 (Thymeleaf, Freemarker 등)  
│   │   │   ├── application.properties   # 애플리케이션 설정 파일  
│   │   │   └── ...                  # 기타 리소스 파일  
│   │   └── resources/  
│   │       └── application.properties   # 애플리케이션 설정 파일 (추가적으로 설정할   수 있음)  
│   └── test/                        # 테스트 소스 코드 디렉터리  
│       └── java/                    # 테스트 자바 소스 코드 디렉터리  
├── pom.xml (또는 build.gradle)       # Maven 또는 Gradle 빌드 파일  
└── ...                              # 기타 프로젝트 파일 및 리소스  

- (_)의 의미  
함수나 메서드의 매개변수로 _를 사용하면 해당 매개변수를 사용하지 않는다는 것을 나타냅니다  


## Error log
#### android 오류
- net::ERR_CLEARTEXT_NOT_PERMITTED
https://peterica.tistory.com/560  
androidmanifest.xml파일에 추가하여 해결  

#### 플러터 오류
- 이미지 추가
pubspec.yaml 추가 작성  
flutter:  
  assets:  
    - assets/images  

- The plugin kakao_flutter_sdk_common requires a higher Android SDK version.  
android/app/build.gradle에  
defaultConfig{minSdkVersion 21}  
을 적음으로서 해결  

- flutter buildcontext async  
https://medium.com/nerd-for-tech/do-not-use-buildcontext-in-async-gaps-why-and-how-to-handle-flutter-context-correctly-870b924eb42e
await ~ then ~  

- 채팅 연결 오류
1. dummy -> user 로그
I/flutter ( 5288): !!! beforeConnect: headers: {Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhY2Nlc3N0b2tlbiIsImV4cCI6MTcxNzUwODQ0NywidXNlcm5hbWUiOiJ1c2VyXzUifQ.sTVnQU7PFqpmocWUpFTFnnunwDjBIC_eyk7UoX4FeLXxBeJFmz98ArMqVXeP8bWhfJBnLYGHfb3DfByPqRb1gQ}
I/flutter ( 5288): !!! beforeConnect: URL: ws://13.209.220.187/ws
I/flutter ( 5288): !!! beforeConnect: matchId: 67
I/flutter ( 5288): !!! beforeConnect: starting connection
I/flutter ( 5288): !!! beforeConnect: headers: {Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhY2Nlc3N0b2tlbiIsImV4cCI6MTcxNzUwODQ0NywidXNlcm5hbWUiOiJ1c2VyXzUifQ.sTVnQU7PFqpmocWUpFTFnnunwDjBIC_eyk7UoX4FeLXxBeJFmz98ArMqVXeP8bWhfJBnLYGHfb3DfByPqRb1gQ}
I/flutter ( 5288): !!! beforeConnect: URL: ws://13.209.220.187/ws
I/flutter ( 5288): !!! beforeConnect: matchId: 67
I/flutter ( 5288): !!! activated stomp client
W/WindowOnBackDispatcher( 5288): sendCancelIfRunning: isInProgress=falsecallback=io.flutter.embedding.android.FlutterActivity$1@edda457
I/flutter ( 5288): [!!!] start get chat log
I/flutter ( 5288): !!! beforeConnect: delay finished, attempting to connect...
I/flutter ( 5288): [log] marking my location LatLng(36.1385317, 128.4108633)
I/flutter ( 5288): [!!!] start get matching log detail
I/flutter ( 5288): [!!!] success get chat log
I/flutter ( 5288): [{message: hi there, sender: user_5, createAt: 2024-06-04T12:30:59.176631}]
I/flutter ( 5288): [!!!] success get matching log detail
I/flutter ( 5288): {requester: true, details: {id: 67, dogImage: null, careType: 산책, startTime: 2024-06-13T11:15:55.985803, endTime: 2024-06-17T11:15:55.985803, careLocation: {x: 128.34, y: 36.14}, description: req_4, userId: 51, reward: 1004, dogId: 4, status: 결제 대기중}}
I/flutter ( 5288): requester in api true
I/flutter ( 5288): [log] marked at 36.14, 128.34
I/flutter ( 5288): !!! current userId : 51
I/flutter ( 5288): !!! requester bool : true
I/flutter ( 5288): !!! successfully connected
I/flutter ( 5288): !!! subscribed to destination

2. user -> dummy 로그
W/WindowOnBackDispatcher( 5288): sendCancelIfRunning: isInProgress=falsecallback=android.app.Dialog$$ExternalSyntheticLambda2@1368f5f
I/BpBinder( 5288): onLastStrongRef automatically unlinking death recipients:
Restarted application in 2,052ms.
I/FLTFireMsgService( 5288): FlutterFirebaseMessagingBackgroundService started!
I/flutter ( 5288): [log] fcm token : es5CWuipRjy7Y0yI3zHTJs:APA91bEKG3os02LWeVmsR19hZWmxw0_Vge5aO4Khi81dm2gPQMA3fqb0a7EFrlxl4fZzegVzFnSOZuU_F2fm6L9eIMbE9f-Cx_p6-WXWVjrY1qNR6KpZZqFG9MbU_IPcV75MeQYfFpSX
W/FLTFireMsgService( 5288): Attempted to start a duplicate background isolate. Returning...
I/flutter ( 5288): [log] User granted notification permission
I/flutter ( 5288): [log] User granted fcm permission
I/flutter ( 5288): [log] AuthorizationStatus.authorized
W/WindowOnBackDispatcher( 5288): sendCancelIfRunning: isInProgress=falsecallback=io.flutter.embedding.android.FlutterActivity$1@edda457
D/EGL_emulation( 5288): app_time_stats: avg=18257.15ms min=13.96ms max=255392.91ms count=14
D/EGL_emulation( 5288): app_time_stats: avg=1057.43ms min=99.65ms max=2015.20ms count=2
W/WindowOnBackDispatcher( 5288): sendCancelIfRunning: isInProgress=falsecallback=io.flutter.embedding.android.FlutterActivity$1@edda457
I/PlatformViewsController( 5288): Hosting view in view hierarchy for platform view: 0
I/PlatformViewsController( 5288): PlatformView is using SurfaceProducer backend
E/FrameEvents( 5288): updateAcquireFence: Did not find frame.
D/EGL_emulation( 5288): app_time_stats: avg=14132.60ms min=1.00ms max=268458.69ms count=19
E/FrameEvents( 5288): updateAcquireFence: Did not find frame.
I/flutter ( 5288): [!!!] start regist fcm token
I/flutter ( 5288): [!!!] success regist fcm token
I/flutter ( 5288): !!! got login
I/flutter ( 5288): !!! access token : eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhY2Nlc3N0b2tlbiIsImV4cCI6MTcxNzUwODcxNSwidXNlcm5hbWUiOiJrYWthb18zNDE5MDcxMzE5In0.fwb7FUZMkELWR5zvSp6zlNsjyxIXI7WEp0AJlxNrfYkMjCRUQ7B5tucIUghsPmTq14Kw5vABq4DC5XWa_T99Bw
I/flutter ( 5288): !!! refresh token : eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJyZWZyZXNodG9rZW4iLCJleHAiOjE3MTc1MTk1MTUsInVzZXJuYW1lIjoia2FrYW9fMzQxOTA3MTMxOSJ9.4aA5kbt8EerRsm5_Dd3-j4gp7_Q9QsrC0lAzJix85PMEbYDFcAXXWzrMP3qRRkCmEKbAKoQwfdyr5o16b8k4sw
I/flutter ( 5288): [!!!] start get my profile
I/flutter ( 5288): [!!!] success get my profile
I/flutter ( 5288): [log] success get my profile
I/flutter ( 5288): [log] login success!
I/flutter ( 5288): [!!!] start get match log list
I/flutter ( 5288): !!! get upcoming of 이재형, id : 51
D/EGL_emulation( 5288): app_time_stats: avg=62.34ms min=0.97ms max=708.06ms count=15
E/FrameEvents( 5288): updateAcquireFence: Did not find frame.
I/flutter ( 5288): [!!!] success get match log list
I/flutter ( 5288): !!! get upcoming of 이재형, id : 51
W/WindowOnBackDispatcher( 5288): sendCancelIfRunning: isInProgress=falsecallback=io.flutter.embedding.android.FlutterActivity$1@edda457
D/EGL_emulation( 5288): app_time_stats: avg=495.69ms min=18.98ms max=2300.09ms count=5
D/EGL_emulation( 5288): app_time_stats: avg=6.10ms min=1.62ms max=29.54ms count=59
D/EGL_emulation( 5288): app_time_stats: avg=3.52ms min=1.11ms max=6.67ms count=61
D/EGL_emulation( 5288): app_time_stats: avg=3.00ms min=1.29ms max=8.81ms count=60
D/EGL_emulation( 5288): app_time_stats: avg=3.19ms min=1.42ms max=6.97ms count=61
I/flutter ( 5288): [log] marking my location LatLng(36.1385317, 128.4108633)
I/flutter ( 5288): [!!!] start get matching log detail
I/flutter ( 5288): [!!!] success get matching log detail
I/flutter ( 5288): {requester: false, details: {id: 67, dogImage: null, careType: 산책, startTime: 2024-06-13T11:15:55.985803, endTime: 2024-06-17T11:15:55.985803, careLocation: {x: 128.34, y: 36.14}, description: req_4, userId: 5, reward: 1004, dogId: 4, status: 결제 대기중}}
I/flutter ( 5288): requester in api false
I/flutter ( 5288): [log] marked at 36.14, 128.34
I/flutter ( 5288): !!! current userId : 5
I/flutter ( 5288): !!! requester bool : false
D/MapsInitializer( 5288): preferredRenderer: null
D/zzcc    ( 5288): preferredRenderer: null
I/Google Maps Android API( 5288): Google Play services package version: 231818044
I/Google Maps Android API( 5288): Google Play services maps renderer version(legacy): 203115000
I/PlatformViewsController( 5288): Hosting view in a virtual display for platform view: 1
I/PlatformViewsController( 5288): PlatformView is using SurfaceProducer backend
D/TrafficStats( 5288): tagSocket(156) with statsTag=0x20001101, statsUid=-1
D/TrafficStats( 5288): tagSocket(129) with statsTag=0x20001101, statsUid=-1
I/GoogleMapController( 5288): No TextureView found. Likely using the LEGACY renderer.
E/OpenGLRenderer( 5288): Unable to match the desired swap behavior.
D/EGL_emulation( 5288): app_time_stats: avg=18.13ms min=2.93ms max=109.22ms count=50
I/flutter ( 5288): !!! beforeConnect: headers: {Authorization: eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhY2Nlc3N0b2tlbiIsImV4cCI6MTcxNzUwODcxNSwidXNlcm5hbWUiOiJrYWthb18zNDE5MDcxMzE5In0.fwb7FUZMkELWR5zvSp6zlNsjyxIXI7WEp0AJlxNrfYkMjCRUQ7B5tucIUghsPmTq14Kw5vABq4DC5XWa_T99Bw}
I/flutter ( 5288): !!! beforeConnect: URL: ws://13.209.220.187/ws
I/flutter ( 5288): !!! beforeConnect: matchId: 67
I/flutter ( 5288): !!! beforeConnect: starting connection
I/flutter ( 5288): !!! beforeConnect: headers: {Authorization: eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhY2Nlc3N0b2tlbiIsImV4cCI6MTcxNzUwODcxNSwidXNlcm5hbWUiOiJrYWthb18zNDE5MDcxMzE5In0.fwb7FUZMkELWR5zvSp6zlNsjyxIXI7WEp0AJlxNrfYkMjCRUQ7B5tucIUghsPmTq14Kw5vABq4DC5XWa_T99Bw}
I/flutter ( 5288): !!! beforeConnect: URL: ws://13.209.220.187/ws
I/flutter ( 5288): !!! beforeConnect: matchId: 67
I/flutter ( 5288): !!! activated stomp client
W/WindowOnBackDispatcher( 5288): sendCancelIfRunning: isInProgress=falsecallback=android.app.Dialog$$ExternalSyntheticLambda2@7d3b079
I/flutter ( 5288): [!!!] start get chat log
W/WindowOnBackDispatcher( 5288): sendCancelIfRunning: isInProgress=falsecallback=io.flutter.embedding.android.FlutterActivity$1@edda457
I/BpBinder( 5288): onLastStrongRef automatically unlinking death recipients:
I/flutter ( 5288): !!! beforeConnect: delay finished, attempting to connect...
I/flutter ( 5288): [log] marking my location LatLng(36.1385317, 128.4108633)
I/flutter ( 5288): [!!!] start get matching log detail
I/flutter ( 5288): [!!!] success get chat log
I/flutter ( 5288): [{message: hi there, sender: user_5, createAt: 2024-06-04T12:30:59.176631}]
I/flutter ( 5288): [!!!] success get matching log detail
I/flutter ( 5288): {requester: false, details: {id: 67, dogImage: null, careType: 산책, startTime: 2024-06-13T11:15:55.985803, endTime: 2024-06-17T11:15:55.985803, careLocation: {x: 128.34, y: 36.14}, description: req_4, userId: 5, reward: 1004, dogId: 4, status: 결제 대기중}}
I/flutter ( 5288): requester in api false
I/flutter ( 5288): [log] marked at 36.14, 128.34
I/flutter ( 5288): !!! current userId : 5
I/flutter ( 5288): !!! requester bool : false
D/MapsInitializer( 5288): preferredRenderer: null
D/zzcc    ( 5288): preferredRenderer: null
I/Google Maps Android API( 5288): Google Play services package version: 231818044
I/Google Maps Android API( 5288): Google Play services maps renderer version(legacy): 203115000
I/PlatformViewsController( 5288): Hosting view in a virtual display for platform view: 2
I/PlatformViewsController( 5288): PlatformView is using SurfaceProducer backend
I/GoogleMapController( 5288): No TextureView found. Likely using the LEGACY renderer.
E/OpenGLRenderer( 5288): Unable to match the desired swap behavior.
D/EGL_emulation( 5288): app_time_stats: avg=57.84ms min=6.02ms max=480.19ms count=17
I/flutter ( 5288): !!! beforeConnect: starting connection
I/flutter ( 5288): !!! beforeConnect: headers: {Authorization: eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhY2Nlc3N0b2tlbiIsImV4cCI6MTcxNzUwODcxNSwidXNlcm5hbWUiOiJrYWthb18zNDE5MDcxMzE5In0.fwb7FUZMkELWR5zvSp6zlNsjyxIXI7WEp0AJlxNrfYkMjCRUQ7B5tucIUghsPmTq14Kw5vABq4DC5XWa_T99Bw}
I/flutter ( 5288): !!! beforeConnect: URL: ws://13.209.220.187/ws
I/flutter ( 5288): !!! beforeConnect: matchId: 67
I/flutter ( 5288): !!! beforeConnect: delay finished, attempting to connect...
I/flutter ( 5288): !!! beforeConnect: starting connection
I/flutter ( 5288): !!! beforeConnect: headers: {Authorization: eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhY2Nlc3N0b2tlbiIsImV4cCI6MTcxNzUwODcxNSwidXNlcm5hbWUiOiJrYWthb18zNDE5MDcxMzE5In0.fwb7FUZMkELWR5zvSp6zlNsjyxIXI7WEp0AJlxNrfYkMjCRUQ7B5tucIUghsPmTq14Kw5vABq4DC5XWa_T99Bw}
I/flutter ( 5288): !!! beforeConnect: URL: ws://13.209.220.187/ws
I/flutter ( 5288): !!! beforeConnect: matchId: 67
I/flutter ( 5288): !!! beforeConnect: delay finished, attempting to connect...



## 기타
ThemeData 클래스의 공식 문서 -> 디자인