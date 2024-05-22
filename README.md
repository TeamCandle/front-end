# flutter_doguber_v1

### 할거
결제플로우
예외플로우


### 참고 링크
- 플러터 참고 자료 모음
https://velog.io/@jaybon/%ED%94%8C%EB%9F%AC%ED%84%B0-%EA%B4%80%EB%A0%A8-%EC%82%AC%EC%9D%B4%ED%8A%B8-%EC%B6%94%EC%B2%9C  

https://velog.io/@ximya_hf/howtowirtutilclasslikepro  

https://medium.com/@gunseliunsal/stateless-vs-stateful-widgets-in-flutter-852741b6046e  

- ui 템플릿들
https://flutterawesome.com/tag/ui/  

https://iqonic.design/product-category/mobile/page/3/

ThemeData 클래스의 공식 문서 -> 디자인

### 사용 패키지 및 API
화면 이동 : go_router  
상태 관리 :provider. 안드로이드의 viewmodel이라고 생각하면 됨.  
백그라운드 서비스 : flutter_background_service 패키지  
지도 : google API. tracking기능은 직접 만들어야 할듯?  
로컬 스토리지 : localstorage
스케줄링 : Timer
푸쉬 알림 : FCM, local_notification
채팅 : stomp


### 파일 구성
- api.dart : 통신 모듈
- constants.dart : 상수 파일. 링크, 텍스트스타일 등의 const변수 저장  
- providers.dart : 데이터 파일. viewmodel역할
- router.dart : 화면 이동 경로 지정

### provider 사용법
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

### localstorage package
main -> await initLocalStorage()
localStorage.getItem('key')
localStorage.setItem('key', 'value')
key - value 형태로 간단한 정보만 저장

### 기타 정보
- 스프링부트 파일 구조  
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

### 변수 선언 종류
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


### android 오류
- net::ERR_CLEARTEXT_NOT_PERMITTED
https://peterica.tistory.com/560  
androidmanifest.xml파일에 추가하여 해결  

### 플러터 오류
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