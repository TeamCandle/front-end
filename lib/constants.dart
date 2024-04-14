//상수 관리 페이지

abstract class ServerUrl {
  ServerUrl._();
  static String serverUrl = 'http://13.209.220.187';

  //log in/out
  static String loginUrl = '$serverUrl/user/login/kakao'; //get
  static String logoutUrl = '$serverUrl/user/logout'; //DELETE

  //reissue
  static String accessTokenReissuanceUrl = '$serverUrl/user/accessToken'; //post

  //profile
  static String myProfileUrl = '$serverUrl/profile/user/me';
  static String userProfileUrl = '$serverUrl/profile/user'; //get

  static String dogProfileUrl = '$serverUrl/profile/dog'; //get, ?id=${애견 id}
  static String dogRegistrationUrl = '$serverUrl/profile/dog'; //post
}
