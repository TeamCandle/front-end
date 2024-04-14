import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
//files
import 'constants.dart';

//모든 메소드는 response or null을 리턴하는 것으로 통일.
//json decode 등의 변환은 providers에서 수행하기
//나중에 토큰들도 이 클래스의 변수로 넣어도 될듯?

// 케어타입
// "WALKING"-산책
// "BOARDING"-돌봄
// "GROOMING"-외견 케어
// "PLAYTIME"-놀아주기
// "ETC"-기타

class DogUberApi {
  // 로그인

  // 로그아웃

  // accessToken 재발급
  static Future<dynamic> reissuAccessToken(
      {required String accessToken, required String refreshToken}) async {
    var url = Uri.parse(ServerUrl.accessTokenReissuanceUrl);
    var header = {'Authorization': 'Bearer $accessToken'};
    var body = {'refreshToken: $refreshToken'};

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

  // profile method
  static Future<dynamic> getMyProfileFromServer(
      {required String accessToken}) async {
    var url = Uri.parse(ServerUrl.myProfileUrl);
    var header = {'Authorization': 'Bearer $accessToken'};

    try {
      var response = await http.get(url, headers: header);
      if (response.statusCode != 200) {
        debugPrint(
            "[log] get my profile fail, code : ${response.statusCode}, ${response.body}");
        return null;
      }
      debugPrint("[log] get my profile success");
      return response;
    } catch (e) {
      debugPrint('[log] get my profile error : $e');
      return null;
    }
  }

  static Future<dynamic> getUserProfileFromServer(
      {required String accessToken, required String userName}) async {
    var url = Uri.parse('${ServerUrl.userProfileUrl}?username=$userName');
    var header = {'Authorization': 'Bearer $accessToken'};

    try {
      var response = await http.get(url, headers: header);
      if (response.statusCode != 200) {
        debugPrint(
            "[log] get user profile fail, code : ${response.statusCode}, ${response.body}");
        return null;
      }
      debugPrint("[log] get user profile success");
      return response;
    } catch (e) {
      debugPrint('[log] get user profile error : $e');
      return null;
    }
  }

  // 유저 프로필 설명 변경 == 내 프로필?

  // 유저 프로필 이미지 변경 == 내 프로필?

  // 애견 프로필 조회

  // 애견 프로필 등록

  // 애견 프로필 변경

  // 애견 프로필 삭제

  // 요구 등록

  // 내 요구 리스트 조회

  // 내 요구 조회

  // 요구 리스트 조회

  // 요구 조회

  // 요구 취소

  // 신청 리스트 조회

  // 내 신청 조회

  // 신청 거절

  // 신청 취소
  //
}
