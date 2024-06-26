//constant

class ApiKeys {
  static const String kakaoNativeAppKey = '8826eec5f744658162616455cf5361ad';
  static const String kakaoJavaScriptAppKey =
      '529540eb153fa80c33ac0fea3a763257';
  static const String googleApiKey = 'AIzaSyBTk9blgdCa4T8fARQha7o-AuF8WkK3byI';
}

class DogSize {
  static const String small = "SMALL";
  static const String medium = "MEDIUM";
  static const String large = "LARGE";
}

class CareType {
  static const String walking = "WALKING";
  static const String boarding = "BOARDING";
  static const String grooming = "GROOMING";
  static const String playtime = "PLAYTIME";
  static const String etc = "ETC";
}

class Status {
  static const String waiting = '결제 대기중';
  static const String notCompleted = '미완료';
  static const String completed = '완료';
  static const String canceled = '취소됨';
  static const String matched = '매칭 완료';
  static const String notMatched = '매칭 실패';
}

class ServerUrl {
  static const String serverUrl = 'http://13.209.220.187';

  //log in/out
  static const String loginUrl = '$serverUrl/user/login/kakao'; //get
  static const String logoutUrl = '$serverUrl/user/logout'; //DELETE

  //reissue
  static const String accessTokenUrl = '$serverUrl/user/accessToken'; //post

  //profile
  static const String myProfileUrl = '$serverUrl/profile/user/me';
  static const String userProfileUrl = '$serverUrl/profile/user'; //get

  static const String dogProfileUrl =
      '$serverUrl/profile/dog'; //get, ?id=${애견 id}
  static const String dogRegistrationUrl = '$serverUrl/profile/dog'; //post

  static const String requirementUrl = '$serverUrl/requirement'; //+me
  static const String requirementListUrl = '$serverUrl/requirement/list'; //+me
  static const String requirementCancelUrl = '$serverUrl/requirement/cancel';

  //application url
  static const String applicationUrl = '$serverUrl/application'; //+me

  static const String matchUrl = '$serverUrl/match';

  static const String paymentUrl = '$serverUrl/payment';

  static const String reviewUrl = '$serverUrl/review';
}
