//dependency
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_doguber_frontend/mymap.dart';
import 'package:flutter_doguber_frontend/notification.dart';
import 'package:flutter_doguber_frontend/pages/matchpage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

//files
import 'constants.dart';
import 'datamodels.dart';

class AuthApi {
  String? _accessToken;
  String? _refreshToken;

  //make class to singleton
  AuthApi._privateConstructor();
  static final AuthApi _instance = AuthApi._privateConstructor();
  factory AuthApi() => _instance;

  //getter
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  //function
  Future<bool> registToken(JavaScriptMessage message) async {
    //userInfo로부터 webView로 반환받은 결과를 가져온다.
    Map<String, dynamic> tokens = jsonDecode(message.message);

    //token을 저장한다.
    _accessToken = tokens['accessToken'];
    _refreshToken = tokens['refreshToken'];
    localStorage.setItem('accessToken', _accessToken!);
    debugPrint('!!! access token : $_accessToken');
    debugPrint('!!! refresh token : $_refreshToken');

    //서버에 fcm token을 등록한다(설치 등으로 바뀌는 케이스 있으므로 매 로그인마다 실행)
    bool result = await _registFcmTokenToServer(tokens['accessToken']);
    return result;
  }

  void cleanUpToken() {
    _accessToken = null;
    _refreshToken = null;
    debugPrint('!!! logged out');
  }

  //setter
  void setAccessToken({required String accessToken}) {
    _accessToken = accessToken;
  }

  void setRefreshToken({required String refreshToken}) {
    _refreshToken = refreshToken;
  }

  Future<bool> _registFcmTokenToServer(String accessToken) async {
    var url = Uri.parse('${ServerUrl.serverUrl}/fcm/token');
    var header = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    var body = {"token": "${CombinedNotificationService.fcmToken}"};

    http.Response? response = await HttpMethod.tryPost(
      title: "regist fcm token",
      url: url,
      header: header,
      body: body,
    );

    if (response?.statusCode == 200) {
      return true;
    } else {
      debugPrint('!!! fcm token regist fail');
      return false;
    }
  }

  Future<dynamic> reissuAccessToken() async {
    var url = Uri.parse(ServerUrl.accessTokenUrl);
    var header = {'Authorization': 'Bearer $_accessToken'};
    var body = {'refreshToken: $_refreshToken'};

    try {
      var response = await http.post(url, headers: header, body: body);
      if (response.statusCode != 200) {
        debugPrint(
            "[!!!] reissue AccToken fail, code : ${response.statusCode}, ${response.body}");
        return null;
      }
      debugPrint("[!!!] reissue AccToken success");
      return response;
    } catch (e) {
      debugPrint('[!!!] reissue AccToken error : $e');
      return null;
    }
  }

  Future<bool> getDummy() async {
    var url = Uri.parse('${ServerUrl.serverUrl}/user/dummy?id=5'); //1~50

    try {
      http.Response? response = await http.get(url);
      if (response.statusCode != 200) {
        debugPrint("[!!!] dummy fail : ${response.body}");
        return false;
      }
      String token = response.body;
      _accessToken = token;
      await _registFcmTokenToServer(_accessToken!);
      return true;
    } catch (e) {
      debugPrint('[!!!] dummy error ');
      return false;
    }
  }
}

class HttpMethod {
  static Future<http.Response?> tryGet({
    required String title,
    required Uri url,
    required Map<String, String> header,
  }) async {
    debugPrint("[!!!] start $title");

    try {
      http.Response? response = await http.get(url, headers: header);
      if (response.statusCode != 200) {
        debugPrint("[!!!] fail ${response.statusCode}");
        debugPrint("[!!!] body ${response.body}");
        return null;
      }
      debugPrint("[!!!] success $title");
      return response;
    } catch (e) {
      debugPrint('[!!!] error $title: $e');
      return null;
    }
  }

  static Future<http.Response?> tryPost({
    required String title,
    required Uri url,
    required Map<String, String> header,
    required Map<String, dynamic> body,
  }) async {
    debugPrint("[!!!] start $title");

    try {
      var response =
          await http.post(url, headers: header, body: jsonEncode(body));
      if (response.statusCode != 200) {
        debugPrint("[!!!] fail code ${response.statusCode}");
        debugPrint("[!!!] fail body ${response.body}");
        return null;
      }
      debugPrint("[!!!] success $title");
      return response;
    } catch (e) {
      debugPrint('[!!!] error $title: $e');
      return null;
    }
  }

  static Future<http.Response?> tryPostWithoutBody({
    required String title,
    required Uri url,
    required Map<String, String> header,
  }) async {
    debugPrint("[!!!] start $title");

    try {
      var response = await http.post(url, headers: header);
      if (response.statusCode != 200) {
        debugPrint("[!!!] fail code ${response.statusCode}");
        debugPrint("[!!!] fail body ${response.body}");
        return null;
      }
      debugPrint("[!!!] success $title");
      return response;
    } catch (e) {
      debugPrint('[!!!] error $title: $e');
      return null;
    }
  }

  static Future<http.Response?> tryPatch({
    required String title,
    required Uri url,
    required Map<String, String> header,
    required Map<String, dynamic> body,
  }) async {
    debugPrint("[!!!] start $title");

    try {
      var response =
          await http.patch(url, headers: header, body: json.encode(body));
      if (response.statusCode != 200) {
        debugPrint("[!!!] fail ${response.statusCode}");
        debugPrint("[!!!] fail body ${response.body}");
        return null;
      }
      debugPrint("[!!!] success $title");
      return response;
    } catch (e) {
      debugPrint('[!!!] error $title: $e');
      return null;
    }
  }

  static Future<http.Response?> tryPatchWithoutBody({
    required String title,
    required Uri url,
    required Map<String, String> header,
  }) async {
    debugPrint("[!!!] start $title");

    try {
      var response = await http.patch(url, headers: header);
      if (response.statusCode != 200) {
        debugPrint("[!!!] fail ${response.statusCode}");
        debugPrint("[!!!] fail body ${response.body}");
        return null;
      }
      debugPrint("[!!!] success $title");
      return response;
    } catch (e) {
      debugPrint('[!!!] error $title: $e');
      return null;
    }
  }

  static Future<bool> tryDelete({
    required String title,
    required Uri url,
    required Map<String, String> header,
  }) async {
    debugPrint("[!!!] start $title");

    try {
      http.Response? response = await http.delete(url, headers: header);
      if (response.statusCode != 200) {
        debugPrint("[!!!] fail ${response.statusCode}");
        debugPrint("[!!!] body ${response.body}");
        return false;
      }
      debugPrint("[!!!] success $title");
      return true;
    } catch (e) {
      debugPrint('[!!!] error $title: $e');
      return false;
    }
  }

  static Future<http.Response?> tryPut({
    required String title,
    required Uri url,
    required Map<String, String> header,
  }) async {
    debugPrint("[!!!] start $title");

    try {
      http.Response? response = await http.put(url, headers: header);
      if (response.statusCode != 200) {
        debugPrint("[!!!] fail ${response.statusCode}");
        debugPrint("[!!!] body ${response.body}");
        return null;
      }
      debugPrint("[!!!] success $title");
      return response;
    } catch (e) {
      debugPrint('[!!!] error $title: $e');
      return null;
    }
  }

  static Future<bool> tryMultipartRequest({
    required String title,
    required http.MultipartRequest request,
  }) async {
    debugPrint("[!!!] start $title");

    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode != 200) {
        final responseBody = await response.stream.bytesToString();
        debugPrint('[!!!] fail ${response.statusCode}');
        debugPrint('[!!!] fail body: $responseBody');
        return false;
      }
      debugPrint("[!!!] success $title");
      return true;
    } catch (e) {
      debugPrint('[!!!] error $title, $e');
      return false;
    }
  }
}

class ProfileApi {
  static final AuthApi _auth = AuthApi();

  static Future<Map<String, dynamic>?> getMyProfileFromServer() async {
    var url = Uri.parse(ServerUrl.myProfileUrl);
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    http.Response? response = await HttpMethod.tryGet(
      title: "get my profile",
      url: url,
      header: header,
    );

    if (response == null) {
      debugPrint('[!!!] get my profile from server error!');
      return null;
    } else {
      return jsonDecode(response.body);
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile(
      {required int userId}) async {
    var url = Uri.parse('${ServerUrl.userProfileUrl}?id=$userId');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    http.Response? response = await HttpMethod.tryGet(
      title: "get user profile",
      url: url,
      header: header,
    );
    if (response == null) {
      debugPrint('!!! get user profile fail');
      return null;
    } else {
      return jsonDecode(response.body);
    }
  }

  static Future<bool> modifyMyDescriptionAtServer(
      {required String description}) async {
    var url = Uri.parse(ServerUrl.userProfileUrl);
    var header = {
      'Authorization': 'Bearer ${_auth.accessToken}',
      'Content-Type': 'application/json',
    };
    var body = {'description': description};

    http.Response? response = await HttpMethod.tryPatch(
      title: "modify my description",
      url: url,
      header: header,
      body: body,
    );

    if (response?.statusCode != 200) {
      return false;
    }
    return true;
  }

  static Future<bool> modifyMyImageAtServer({required XFile image}) async {
    //전송할 데이터 준비
    var url = Uri.parse(ServerUrl.userProfileUrl);
    var header = {
      'Authorization': 'Bearer ${_auth.accessToken}',
      'Content-Type': 'multipart/form-data'
    };
    Uint8List imageBytes = await image.readAsBytes();
    var multipartFile = http.MultipartFile.fromBytes(
      'image',
      imageBytes.toList(),
      filename: DateTime.now().toString(),
      contentType: MediaType('image', 'jpeg'),
    );

    //전송 준비
    var request = http.MultipartRequest('PATCH', url);
    request.headers.addAll(header);
    request.files.add(multipartFile);

    // Send the request
    return await HttpMethod.tryMultipartRequest(
      title: 'modify profile image',
      request: request,
    );
  }
}

class DogProfileApi {
  static final AuthApi _auth = AuthApi();

  //애견 프로필 조회
  static Future<DogInfo?> getDogProfile({required int id}) async {
    var url = Uri.parse('${ServerUrl.dogProfileUrl}?id=$id');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    http.Response? response = await HttpMethod.tryGet(
      title: "get dog profile",
      url: url,
      header: header,
    );

    if (response == null) {
      debugPrint('[!!!] get dog profile error');
      return null;
    }
    var data = jsonDecode(response.body);
    debugPrint('[!!!] json decode $data');
    DogInfo dogInfo;
    try {
      dogInfo = DogInfo(
        data['id'],
        data['name'],
        data['gender'],
        data['image'] == null ? null : base64Decode(data['image']),
        data['owner'],
        data['neutered'],
        data['age'],
        data['size'],
        data['breed'],
        data['description'],
      );
      return dogInfo;
    } catch (e) {
      debugPrint('[!!!] create doginfo fail');
      return null;
    }
  }

  //애견 프로필 리스트 조회 : 필요 시 제작

  //애견 프로필 등록
  static Future<bool> registDogProfile({required DogInfo doginfo}) async {
    var url = Uri.parse(ServerUrl.dogRegistrationUrl);
    var header = {
      'Authorization': 'Bearer ${_auth.accessToken}',
      'Content-Type': 'multipart/form-data'
    };

    //전송 데이터 준비
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll(header);
    request.fields['name'] = doginfo.dogName;
    request.fields['gender'] = doginfo.dogGender;
    request.fields['neutered'] = doginfo.neutered.toString();
    request.fields['age'] = doginfo.age.toString();
    request.fields['size'] = doginfo.size;
    request.fields['breed'] = doginfo.breed;
    request.fields['description'] = doginfo.description!;
    if (doginfo.dogImage != null) {
      var multipartFile = http.MultipartFile.fromBytes(
        'image',
        doginfo.dogImage!.toList(),
        filename: DateTime.now().toString(),
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
    } else {
      request.fields['image'] = "";
    }

    // Send the request
    return await HttpMethod.tryMultipartRequest(
      title: 'regist dog',
      request: request,
    );
  }

  //애견 프로필 변경
  static Future<bool> modifyDogProfile({required DogInfo doginfo}) async {
    var url = Uri.parse(ServerUrl.dogRegistrationUrl);
    var header = {
      'Authorization': 'Bearer ${_auth.accessToken}',
      'Content-Type': 'multipart/form-data'
    };

    //전송 데이터 준비
    var request = http.MultipartRequest('PATCH', url);
    request.headers.addAll(header);
    request.fields['id'] = doginfo.dogId.toString();
    request.fields['name'] = doginfo.dogName;
    request.fields['gender'] = doginfo.dogGender;
    request.fields['neutered'] = doginfo.neutered.toString();
    request.fields['age'] = doginfo.age.toString();
    request.fields['size'] = doginfo.size.toString();
    request.fields['breed'] = doginfo.breed;
    request.fields['description'] = doginfo.description!;
    if (doginfo.dogImage != null) {
      var multipartFile = http.MultipartFile.fromBytes(
        'image',
        doginfo.dogImage!.toList(),
        filename: DateTime.now().toString(),
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
    } else {
      request.fields['image'] = "";
    }

    // Send the request
    return await HttpMethod.tryMultipartRequest(
      title: 'modify dog profile',
      request: request,
    );
  }

  //애견 프로필 삭제
  static Future<bool> deleteDogProfile({required int id}) async {
    var url = Uri.parse('${ServerUrl.dogProfileUrl}?id=$id');
    debugPrint(url.toString());
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    return await HttpMethod.tryDelete(
      title: "delete dog profile",
      url: url,
      header: header,
    );
  }
}

class RequirementApi {
  static final AuthApi _auth = AuthApi();

  // 전체 요구 리스트 조회
  static Future<List<dynamic>?> getAllRequirementList(
      {required int offset}) async {
    //데이터 준비
    var url = Uri.parse('${ServerUrl.requirementListUrl}?offset=$offset');
    var header = {
      'Authorization': 'Bearer ${_auth.accessToken}',
      'Content-Type': 'application/json',
    };
    var body = {
      'location': {"x": 128.3936, "y": 36.1461}
    };

    //연결
    var response = await HttpMethod.tryPost(
      title: "all requirement list",
      url: url,
      header: header,
      body: body,
    );
    if (response == null) {
      debugPrint('response is null');
      return null;
    }

    debugPrint('start decode');
    Map<String, dynamic> tempMap = jsonDecode(response.body);
    debugPrint('end decode');
    debugPrint('start get list');
    List<dynamic> tempList = tempMap['requirements'];
    debugPrint('end get list');
    debugPrint('print all item');

    return tempList;
  }

  // 특정 요구 조회
  static Future<DetailInfo?> getRequirementDetail({required int id}) async {
    var url = Uri.parse('${ServerUrl.requirementUrl}?id=$id');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    http.Response? response = await HttpMethod.tryGet(
      title: "get request detail",
      url: url,
      header: header,
    );
    if (response == null) {
      debugPrint('[!!!] get request detail error');
      return null;
    }

    var data = jsonDecode(response.body);
    debugPrint('$data');
    DetailInfo requirementDetail;
    try {
      requirementDetail = DetailInfo(
        data['id'],
        data['image'] == null ? null : base64Decode(data['image']),
        data['careType'],
        data['startTime'].toString(),
        data['endTime'].toString(),
        LatLng(data['careLocation']['y'], data['careLocation']['x']),
        data['description'],
        data['userId'],
        data['dogId'],
        data['reward'],
        data['status'],
      );
      return requirementDetail;
    } catch (e) {
      debugPrint('[!!!] decode requirement fail');
      return null;
    }
  }

  // 내 요구 리스트 조회
  static Future<List<dynamic>?> getMyRequirementList(
      {required int offset}) async {
    var url = Uri.parse('${ServerUrl.requirementListUrl}/me?offset=$offset');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};
    http.Response? response = await HttpMethod.tryGet(
      title: "my requirement list",
      url: url,
      header: header,
    );
    if (response == null) {
      debugPrint('response is null');
      return null;
    }

    Map<String, dynamic> tempMap = jsonDecode(response.body);
    List<dynamic> tempList = tempMap['requirements'];
    return tempList;
  }

  // 내 요구 조회, 신청자 리스트가 동봉되어있으므로 detailInfo 사용 x
  static Future<http.Response?> getMyRequirementDetail(
      {required int requirementId}) async {
    var url = Uri.parse('${ServerUrl.requirementUrl}/me?id=$requirementId');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};
    http.Response? response = await HttpMethod.tryGet(
      title: "my requirement",
      url: url,
      header: header,
    );
    if (response == null) {
      debugPrint('[!!!] response is null');
      return null;
    }
    return response;
  }

  //요구 등록
  static Future<bool> registRequirement({
    required int dogId,
    required DateTime startTime,
    required DateTime endTime,
    required LatLng location,
    required String careType,
    required int reward,
    required String description,
  }) async {
    var url = Uri.parse(ServerUrl.requirementUrl);
    var header = {
      'Authorization': 'Bearer ${_auth.accessToken}',
      'Content-Type': 'application/json',
    };
    MyMap myMap = MyMap();
    await myMap.getMyLocation();
    var body = {
      "dogId": dogId,
      "careType": careType,
      "startTime": startTime.toIso8601String(),
      "endTime": endTime.toIso8601String(),
      "careLocation": {
        "x": location.longitude,
        "y": location.latitude,
      },
      "reward": reward,
      "description": description,
    };

    http.Response? response = await HttpMethod.tryPost(
      title: "regist requirement",
      url: url,
      header: header,
      body: body,
    );
    if (response == null || response.body.isEmpty) {
      debugPrint('[!!!] regist requirement fail');
      return false;
    }
    debugPrint('[!!!] request success, $body');
    return true;
  }

  // 요구 취소
  static Future<bool> cancelMyRequirement(int requirementId) async {
    var url = Uri.parse('${ServerUrl.requirementUrl}/cancel?id=$requirementId');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};
    http.Response? response = await HttpMethod.tryPatchWithoutBody(
      title: "my requirement",
      url: url,
      header: header,
    );
    if (response == null) {
      debugPrint('[!!!] response is null');
      return false;
    }
    return true;
  }
}

class ApplicationApi {
  static final AuthApi _auth = AuthApi();

  //내가 신청했던 리스트 조회
  static Future<List<dynamic>?> getMyApplicationList(
      {required int offset}) async {
    var url = Uri.parse('${ServerUrl.applicationUrl}/list?offset=$offset');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};
    http.Response? response = await HttpMethod.tryGet(
      title: "get my application list",
      url: url,
      header: header,
    );
    if (response == null) {
      debugPrint('response is null');
      return null;
    }

    Map<String, dynamic> tempMap = jsonDecode(response.body);
    List<dynamic> tempList = tempMap['applications'];
    return tempList;
  }

  //특정 신청 조회
  static Future<DetailInfo?> getApplicationDetail(int applicationId) async {
    var url = Uri.parse('${ServerUrl.applicationUrl}?id=$applicationId');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};
    http.Response? response = await HttpMethod.tryGet(
      title: "get application detail",
      url: url,
      header: header,
    );
    if (response == null) {
      debugPrint('[!!!] response is null');
      return null;
    }

    var data = jsonDecode(response.body);
    debugPrint('$data');
    DetailInfo applicationDetail;
    try {
      applicationDetail = DetailInfo(
        data['id'],
        data['image'] == null ? null : base64Decode(data['image']),
        data['careType'],
        data['startTime'].toString(),
        data['endTime'].toString(),
        LatLng(data['careLocation']['y'], data['careLocation']['x']),
        data['description'],
        data['userId'],
        data['dogId'],
        data['reward'],
        data['status'],
      );
      return applicationDetail;
    } catch (e) {
      debugPrint('[!!!] decode application fail');
      return null;
    }
  }

  //탐색한 요구사항에 대한 신청
  static Future<bool> apply(int requirementId) async {
    var url =
        Uri.parse('${ServerUrl.applicationUrl}?requirementId=$requirementId');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    http.Response? response = await HttpMethod.tryPostWithoutBody(
      title: "cancel my application",
      url: url,
      header: header,
    );

    if (response == null) {
      debugPrint('[!!!] response is null');
      return false;
    }
    return true;
  }

  //그에 대한 취소
  static Future<bool> cancel(int applicationId) async {
    var url = Uri.parse('${ServerUrl.applicationUrl}/cancel?id=$applicationId');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    http.Response? response = await HttpMethod.tryPut(
      title: "cancel my application",
      url: url,
      header: header,
    );

    if (response == null) {
      debugPrint('[!!!] response is null');
      return false;
    }
    return true;
  }

  //내가 등록한 요구사항에 들어온 신청 수락
  static Future<bool> accept(int requirementId, int applicationId) async {
    var url = Uri.parse(
        '${ServerUrl.serverUrl}/match?requirementId=$requirementId&applicationId=$applicationId');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    http.Response? response = await HttpMethod.tryPostWithoutBody(
      title: "cancel my application",
      url: url,
      header: header,
    );

    if (response == null) {
      debugPrint('[!!!] response is null');
      return false;
    }
    return true;
  }
}

class MatchingLogApi {
  static final AuthApi _auth = AuthApi();

  static Future<Map<String, dynamic>?> getUpcoming() async {
    var url = Uri.parse('${ServerUrl.matchUrl}/upcoming');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    http.Response? response = await HttpMethod.tryGet(
      title: "get match log list",
      url: url,
      header: header,
    );
    if (response == null) {
      debugPrint('response is null');
      return null;
    }

    Map<String, dynamic> tempMap = jsonDecode(response.body);

    return tempMap;
  }

  //매칭 로그 조회
  static Future<List<dynamic>?> getMatchingLogList(int offset) async {
    var url = Uri.parse('${ServerUrl.matchUrl}/list?offset=$offset');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    http.Response? response = await HttpMethod.tryGet(
      title: "get match log list",
      url: url,
      header: header,
    );
    if (response == null) {
      debugPrint('response is null');
      return null;
    }

    Map<String, dynamic> tempMap = jsonDecode(response.body);
    List<dynamic> tempList = tempMap['matches'];
    return tempList;
  }

  //특정 매칭 기록 조회
  static Future<DetailInfo?> getMatchingLogDetail(int matingId) async {
    //requester 여부는 upcoming에서확인하자
    var url = Uri.parse('${ServerUrl.matchUrl}?id=$matingId');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    http.Response? response = await HttpMethod.tryGet(
      title: "get matching log detail",
      url: url,
      header: header,
    );
    if (response == null) {
      debugPrint('[!!!] response is null');
      return null;
    }

    var data = jsonDecode(response.body);
    debugPrint('$data');
    DetailInfo matchingLogDetail;
    try {
      matchingLogDetail = DetailInfo(
        data['details']['id'],
        data['details']['image'] == null ? null : base64Decode(data['image']),
        data['details']['careType'],
        data['details']['startTime'].toString(),
        data['details']['endTime'].toString(),
        LatLng(
          data['details']['careLocation']['y'],
          data['details']['careLocation']['x'],
        ),
        data['details']['description'], //TODO: null 조심
        data['details']['userId'],
        data['details']['dogId'],
        data['details']['reward'],
        data['details']['status'],
      );
      matchingLogDetail.setRequester(data['requester']);
      debugPrint('requester in api ${data['requester']}');
      return matchingLogDetail;
    } catch (e) {
      debugPrint('[!!!] decode matching log fail');
      return null;
    }
  }

  //매칭 완료
  static Future<bool> complete(int matchingId) async {
    var url = Uri.parse('${ServerUrl.matchUrl}/complete?id=$matchingId');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    http.Response? response = await HttpMethod.tryPatchWithoutBody(
      title: "match completed",
      url: url,
      header: header,
    );
    if (response == null) {
      debugPrint('response is null');
      return false;
    }
    return true;
  }

  //매칭 취소 = 매칭이 WAITING_PAYMENT 상태일 때 취소 동작
  //테스트 완료
  static Future<bool> cancel(int matchingId) async {
    var url = Uri.parse('${ServerUrl.matchUrl}/cancel?id=$matchingId');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    http.Response? response = await HttpMethod.tryPatchWithoutBody(
      title: "cancel this matching",
      url: url,
      header: header,
    );
    if (response == null) {
      debugPrint('response is null');
      return false;
    }
    return true;
  }
}

//TODO: 맨위에 현재 매칭에서는 다음과 같이 할 것. 디테일 받아오고 상태 표시하고,
//TODO: 지금 생각으로는 매칭 로그에는 리뷰 버튼만 맹글고 결제같은 로직은 현재 매칭에서 구현하면 될듯?

class ChattingApi {
  static final AuthApi _auth = AuthApi();
  static const String _connectUrl = 'ws://13.209.220.187/ws';
  static StompClient? _stompClient;

  //채팅 연결
  static Future<bool> connect({
    required int matchId,
    required void Function(StompFrame) callback,
  }) async {
    //webSocketConnectHeaders: {'Authorization': 'Bearer yourToken'},
    var stompConnectHeaders = {'Authorization': 'Bearer ${_auth.accessToken}'};
    String destination = '/exchange/chat.exchange/*.room.$matchId';

    try {
      _stompClient = StompClient(
        config: StompConfig(
          url: _connectUrl,
          onConnect: (frame) {
            debugPrint('!!! successfully connected');
            _stompClient!.subscribe(
              destination: destination,
              callback: callback,
            );
            debugPrint('!!! subscribed to destination');
          },
          beforeConnect: () async {
            debugPrint('!!! beforeConnect: starting connection');
            debugPrint('!!! beforeConnect: headers: $stompConnectHeaders');
            debugPrint('!!! beforeConnect: URL: $_connectUrl');
            debugPrint('!!! beforeConnect: matchId: $matchId');
            await Future.delayed(const Duration(milliseconds: 100));
            debugPrint(
                '!!! beforeConnect: delay finished, attempting to connect...');
          },
          onWebSocketError: (error) {
            debugPrint('!!! connect error $error');
          },
          stompConnectHeaders: stompConnectHeaders,
        ),
      );

      _stompClient!.activate();
      debugPrint('!!! activated stomp client');
      return true;
    } catch (e) {
      debugPrint('!!! activated error on stomp client');
      return false;
    }
  }

  static void disconnect() {
    _stompClient!.deactivate();
    debugPrint('!!! deactivate stomp client');
  }

  //채팅 내역 가져오기 (다시 들어갔을 때)
  static Future<List<dynamic>?> getChattingLog(int matchId) async {
    var url = Uri.parse('${ServerUrl.serverUrl}/chat/history?roomId=$matchId');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    http.Response? response = await HttpMethod.tryGet(
      title: "get chat log",
      url: url,
      header: header,
    );
    if (response == null) {
      debugPrint('[!!!] response is null');
      return null;
    }

    var data = jsonDecode(response.body);
    List<dynamic> chatList = data['messages'];
    debugPrint('$chatList');
    return chatList;
  }

  //메시지 보내기
  static bool send(String message, int matchId) {
    if (message.isEmpty) return false;

    String destination = '/send/chat.talk.$matchId';
    _stompClient!.send(destination: destination, body: message);
    return true;
  }
}

class PaymentApi {
  static final AuthApi _auth = AuthApi();

  //결제 요청
  static Future<bool> pay(int matchId) async {
    var url = Uri.parse('${ServerUrl.paymentUrl}/ready?matchId=$matchId');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    debugPrint('!!! payment start');
    debugPrint('!!! url : $url');
    debugPrint('!!! header : $header');

    // 1. 결제 url 받아오기
    String? paymentUrl;
    try {
      http.Response? response = await http.get(url, headers: header);
      debugPrint('!!! response : ${response.statusCode}');
      debugPrint('!!! response : ${response.body}');
      paymentUrl = response.body;
    } catch (e) {
      debugPrint('!!! payment error : $e');
      return false;
    }

    //2. 해당 url로 redirect
    Uri redirectUrl = Uri.parse(paymentUrl);
    if (await canLaunchUrl(redirectUrl) == false) {
      debugPrint('!!! can not launch url');
      return false;
    }
    debugPrint('!!! url launched');
    return await launchUrl(redirectUrl);
  }

  //결제 승인
  static Future<bool> approve(int matchId) async {
    var url = Uri.parse(
        '${ServerUrl.paymentUrl}/approve/alternative?matchId=$matchId');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    http.Response? response = await HttpMethod.tryPatchWithoutBody(
      title: "approve payment",
      url: url,
      header: header,
    );
    if (response == null) {
      debugPrint('response is null');
      return false;
    }
    debugPrint('!!! payment approved');
    return true;
  }

  //결제 취소 = 매칭이 NOT_COMPLETED 상태일 때 취소 동작
}

class ReviewApi {
  static final AuthApi _auth = AuthApi();

  //리뷰 내역 출력
  static Future<List<dynamic>?> getReviewList({
    required int userId,
    required int offset,
  }) async {
    var url =
        Uri.parse('${ServerUrl.reviewUrl}/list?userId=$userId&offset=$offset');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    http.Response? response = await HttpMethod.tryGet(
      title: "get review list",
      url: url,
      header: header,
    );
    if (response == null) {
      debugPrint('response is null');
      return null;
    }

    Map<String, dynamic> tempMap = jsonDecode(response.body);
    List<dynamic> tempList = tempMap['reviews'];
    return tempList;
  }

  //특정 리뷰 조회 -> 필요 시 제작

  //리뷰 등록
  static Future<bool> regist({
    required int matchId,
    required double rating,
    required String text,
  }) async {
    var url = Uri.parse(ServerUrl.reviewUrl);
    var header = {
      'Authorization': 'Bearer ${_auth.accessToken}',
      'Content-Type': 'application/json',
    };
    var body = {'matchId': matchId, 'rating': rating, 'text': text};

    http.Response? response = await HttpMethod.tryPost(
      title: "regist review",
      url: url,
      header: header,
      body: body,
    );

    if (response == null) {
      debugPrint('[!!!] response is null');
      return false;
    }
    return true;
  }

  //리뷰 삭제
  static Future<bool> delete(int reviewId) async {
    var url = Uri.parse('${ServerUrl.reviewUrl}?id=$reviewId');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    bool result = await HttpMethod.tryDelete(
      title: "delete review",
      url: url,
      header: header,
    );

    return result;
  }
}
