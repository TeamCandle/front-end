//상수 관리 페이지

abstract class ServerUrl {
  ServerUrl._();

  static String serverUrl = 'http://13.209.220.187';
  static String loginUrl = 'http://13.209.220.187:80/user/login/kakao'; //get
  static String logoutUrl = 'http://13.209.220.187/user/logout'; //DELETE

  static String accessReissueUrl = 'http://13.209.220.187'; //post

  static String userProfileUrl = 'http://13.209.220.187/profile/user'; //get
  static String userDescriptUrl = 'http://13.209.220.187/profile/user'; //patch
  static String userImageUrl = 'http://13.209.220.187/profile/user'; //patch

  static String dogProfileUrl =
      'http://13.209.220.187/profile/dog'; //get, ?id=${애견 id}
  static String dogRegistrationUrl = 'http://13.209.220.187/profile/dog'; //post
}
