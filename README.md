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


	
<button type="button" 
onclick="location.href=&#39;intent://kakaopay/pg?url=https://online-pay.kakao.com/pay/mockup/6f9c6c35fd3116e55dbcb6ee6579eee4f423882726ef689b42ee86cf163e51fe#Intent;scheme=kakaotalk;package=com.kakao.talk;S.browser_fallback_url=https%3A%2F%2Fplay.google.com%2Fstore%2Fapps%2Fdetails%3Fid%3Dcom.kakao.talk;end&#39;" class="waiting-popup__notice-button">
<span class="text">카카오페이가 실행되지 않거나 창을 닫으셨나요?</span> 
<svg xmlns="http://www.w3.org/2000/svg" width="15"
height="20" viewBox="0 0 15 20" class="icon">
<path fill="none" fill-rule="evenodd" stroke="#0E1012" stroke-linecap="round" stroke-linejoin="round"
d="M0 0L5 5 0 10" transform="translate(8 5)"></path>
I/flutter ( 8053): 				</svg></button>
I/flutter ( 8053): 			</div>
I/flutter ( 8053): 		</div>
I/flutter ( 8053): 		<div class="center_layer" style="display: none">
I/flutter ( 8053): 			<div class="inner_layer">
I/flutter ( 8053): 				<span role="text">
I/flutter ( 8053): 					<p class="txt_pay"><span>카카오페이 결제를 위해</span><br><em class="emph_txt">다음</em> 버튼을 눌러주세요!</p>
I/flutter ( 8053): 				</span>
I/flutter ( 8053): 				<a href= "intent://kakaopay/pg?url=https://online-pay.kakao.com/pay/mockup/6f9c6c35fd3116e55dbcb6ee6579eee4f423882726ef689b42ee86cf163e51fe#Intent;scheme=kakaotalk;package=com.kakao.talk;S.browser_fallback_url=https%3A%2F%2Fplay.google.com%2Fstore%2Fapps%2Fdetails%3Fid%3Dcom.kakao.talk;end" class="btn_pay">다음</a>
I/flutter ( 8053): 			</div>
I/flutter ( 8053): 		</div>
I/flutter ( 8053): 		<form id="approvalPost" action="approval" method="post">
I/flutter ( 8053): 		</form>
I/flutter ( 8053): 	</div>
I/flutter ( 8053): </body>
I/flutter ( 8053): </html>
I/flutter ( 8053): 

talk.kakaopay.m.app
com.kakao.talk

## 기타
ThemeData 클래스의 공식 문서 -> 디자인