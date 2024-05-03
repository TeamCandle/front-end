//dependency
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

//files
import 'constants.dart';

//모든 메소드는 response or null을 리턴하는 것으로 통일.
//json decode 등의 변환은 providers에서 수행하기
//나중에 토큰들도 이 클래스의 변수로 넣어도 될듯?

class TokenManager {
  String? _accessToken;
  String? _refreshToken;

  //make class to singleton
  TokenManager._privateConstructor();
  static final TokenManager _instance = TokenManager._privateConstructor();
  factory TokenManager() => _instance;

  //getter
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  //setter
  void setAccessToken({required String accessToken}) {
    _accessToken = accessToken;
  }

  void setRefreshToken({required String refreshToken}) {
    _refreshToken = refreshToken;
  }

  void cleanUp() {
    _accessToken = null;
    _refreshToken = null;
  }
}

class DogUberApi {
  static final TokenManager _tokenManager = TokenManager();

  //token function
  static void updateAccessToken({required accessToken}) {
    _tokenManager.setAccessToken(accessToken: accessToken);
  }

  static void updateRefreshToken({required refreshToken}) {
    _tokenManager.setRefreshToken(refreshToken: refreshToken);
  }

  static Future<dynamic> reissuAccessToken() async {
    var url = Uri.parse(ServerUrl.accessTokenUrl);
    var header = {'Authorization': 'Bearer ${_tokenManager.accessToken}'};
    var body = {'refreshToken: ${_tokenManager.refreshToken}'};

    try {
      var response = await http.post(url, headers: header, body: body);
      if (response.statusCode != 200) {
        debugPrint(
            "[log] reissue AccToken fail, code : ${response.statusCode}, ${response.body}");
        return null;
      }
      debugPrint("[log] reissue AccToken success");
      return response;
    } catch (e) {
      debugPrint('[log] reissue AccToken error : $e');
      return null;
    }
  }

  //http metod
  static Future<dynamic> _tryGet(
      {required String title,
      required Uri url,
      required Map<String, String> header}) async {
    debugPrint("[log] start $title");

    try {
      var response = await http.get(url, headers: header);
      if (response.statusCode != 200) {
        debugPrint("[log] $title fail!!");
        debugPrint("[log] fail code ${response.statusCode}");
        debugPrint("[log] fail body ${response.body}");
        return null;
      }
      debugPrint("[log] $title success!");
      return response;
    } catch (e) {
      debugPrint('[log] $title error? : $e');
      return null;
    }
  }

  static Future<dynamic> _tryPost(
      {required String title,
      required Uri url,
      required Map<String, String> header,
      required Map<String, dynamic> body}) async {
    debugPrint("[log] start $title");
    try {
      var response = await http.post(url, headers: header, body: body);
      if (response.statusCode != 200) {
        debugPrint("[log] $title fail!!");
        debugPrint("[log] fail code ${response.statusCode}");
        debugPrint("[log] fail body ${response.body}");
        return null;
      }
      debugPrint("[log] $title success!");
      return response;
    } catch (e) {
      debugPrint('[log] $title error? : $e');
      return null;
    }
  }

  // profile method
  static Future<dynamic> getMyProfileFromServer() async {
    var url = Uri.parse(ServerUrl.myProfileUrl);
    var header = {'Authorization': 'Bearer ${_tokenManager.accessToken}'};
    var result =
        await _tryGet(title: "get my profile", url: url, header: header);
    if (result == null) return null;
  }

  static Future<dynamic> getUserProfileFromServer(
      {required String userName}) async {
    var url = Uri.parse('${ServerUrl.userProfileUrl}?username=$userName');
    var header = {'Authorization': 'Bearer ${_tokenManager.accessToken}'};
    var result =
        await _tryGet(title: "get user profile", url: url, header: header);
    if (result == null) return null;
  }

  static Future<dynamic> modifyMyProfileAtServer(
      {required String description}) async {
    //내프로필 가져오기 : profile/user/me
    //내프로필 설명 변경 : profile/user
    //내프로필 이미지 변경 : profile/user
  }

  // 유저 프로필 이미지 변경 == 내 프로필?

  // 애견 프로필 조회 -> list에 한번에 담기
  // 애견 프로필 등록
  // 애견 프로필 변경
  // 애견 프로필 삭제

  //requirement function
  // 요구 등록
  Future<dynamic> registRequirement(
      {required Map<String, dynamic> requirement}) async {
    var url = Uri.parse(ServerUrl.requirementUrl);
    var header = {'Authorization': 'Bearer ${_tokenManager.accessToken}'};
    var result = await _tryPost(
        title: "regist requirement",
        url: url,
        header: header,
        body: requirement);
    if (result == null) return null;
  }

  // 내 요구 리스트 조회
  Future<dynamic> getmyRequirementList() async {
    var url = Uri.parse('${ServerUrl.requirementListUrl}/me');
    var header = {'Authorization': 'Bearer ${_tokenManager.accessToken}'};
    var result =
        await _tryGet(title: "my requirement list", url: url, header: header);
    if (result == null) return null;
  }

  // 내 요구 조회
  Future<dynamic> getMyRequirement({required String requirementId}) async {
    var url = Uri.parse('${ServerUrl.requirementUrl}/me?id=$requirementId');
    var header = {'Authorization': 'Bearer ${_tokenManager.accessToken}'};
    var result =
        await _tryGet(title: "my requirement", url: url, header: header);
    if (result == null) return null;
  }

  // 요구 리스트 조회
  // body 필요

  // 요구 조회

  // 요구 취소

  // 신청 리스트 조회

  // 내 신청 조회

  // 신청 거절

  // 신청 취소
  //
}
