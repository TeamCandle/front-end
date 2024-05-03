//상수 관리 페이지

class CareType {
  static String walking = "WALKING";
  static String boarding = "BOARDING";
  static String grooming = "GROOMING";
  static String playtime = "PLAYTIME";
  static String etc = "ETC";
}
// 케어타입
// "WALKING"-산책
// "BOARDING"-돌봄
// "GROOMING"-외견 케어
// "PLAYTIME"-놀아주기
// "ETC"-기타

class RequirementStatus {
  static String matched = 'MATCHED';
  static String recruiting = 'RECRUITING';
  static String cancelled = 'CANCELLED';
  static String expired = 'EXPIRED';
}

class ApplicationStatus {
  static String matched = 'MATCHED';
  static String waiting = 'WAITING';
  static String rejected = 'REJECTED';
  static String cancelled = 'CANCELLED';
}

class MatchingStatus {
  static String completed = 'COMPLETED';
  static String inProgress = 'IN_PROGRESS';
  static String cancelled = 'CANCELLED';
}

class ServerUrl {
  static String serverUrl = 'http://13.209.220.187';

  //log in/out
  static String loginUrl = '$serverUrl/user/login/kakao'; //get
  static String logoutUrl = '$serverUrl/user/logout'; //DELETE

  //reissue
  static String accessTokenUrl = '$serverUrl/user/accessToken'; //post

  //profile
  static String myProfileUrl = '$serverUrl/profile/user/me';
  static String userProfileUrl = '$serverUrl/profile/user'; //get

  static String dogProfileUrl = '$serverUrl/profile/dog'; //get, ?id=${애견 id}
  static String dogRegistrationUrl = '$serverUrl/profile/dog'; //post

  static String requirementUrl = '$serverUrl/requirement'; //+me
  static String requirementListUrl = '$serverUrl/requirement/list'; //+me
  static String requirementCancelUrl = '$serverUrl/requirement/cancel';
}
