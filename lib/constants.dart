//constant

class ApiKeys {
  static const String kakaoNativeAppKey = '8826eec5f744658162616455cf5361ad';
  static const String kakaoJavaScriptAppKey =
      '529540eb153fa80c33ac0fea3a763257';
  static const String googleApiKey = 'AIzaSyBTk9blgdCa4T8fARQha7o-AuF8WkK3byI';
}

class RouterPath {
  static const String home = '/home';

  //profile tree
  static const String myProfile = '/home/my_profile';
  static const String myReview = '/home/my_profile/my_review';
  static const String myDogProfile = '/home/my_profile/dog_profile';
  static const String myDogRegistraion = '/home/my_profile/dog_registration';
  static const String profileModify = '/home/my_profile/modify_myprofile';

  //match tree
  static const String matching = '/home/matching';
  static const String requestDetail = '/home/matching/request_detail';
  static const String applySuccess =
      '/home/matching/request_detail/apply_success';
  static const String myRequestList = '/home/matching/my_request_list';
  static const String requestRegistrationForm =
      '/home/matching/my_request_list/form';
  static const String myApplicationList = "/home/matching/my_application_list";
  static const String matchLog = '/home/matching/match_log';
  static const String chatting = '/home/matching/chatting';
  static const String requestSearch = '/home/matching/request_search';
}

class CareType {
  static const String walking = "WALKING";
  static const String boarding = "BOARDING";
  static const String grooming = "GROOMING";
  static const String playtime = "PLAYTIME";
  static const String etc = "ETC";
}

class RequirementStatus {
  static const String matched = 'MATCHED';
  static const String recruiting = 'RECRUITING';
  static const String cancelled = 'CANCELLED';
  static const String expired = 'EXPIRED';
}

class ApplicationStatus {
  static const String matched = 'MATCHED';
  static const String waiting = 'WAITING';
  static const String rejected = 'REJECTED';
  static const String cancelled = 'CANCELLED';
}

class MatchingStatus {
  static const String completed = 'COMPLETED';
  static const String inProgress = 'IN_PROGRESS';
  static const String cancelled = 'CANCELLED';
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
}
