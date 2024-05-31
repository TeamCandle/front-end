//dependency
import 'dart:convert';
import 'dart:io';

import 'package:flutter_doguber_frontend/mymap.dart';
import 'package:flutter_doguber_frontend/notification.dart';
import 'package:flutter_doguber_frontend/pages/matchpage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';

//files
import 'constants.dart';
import 'datamodels.dart';

class AuthApi {
  String? _accessToken;
  String? _refreshToken;
  bool _isLogined = false;

  //make class to singleton
  AuthApi._privateConstructor();
  static final AuthApi _instance = AuthApi._privateConstructor();
  factory AuthApi() => _instance;

  //getter
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isLogined => _isLogined;

  //function
  Future<void> logIn({required JavaScriptMessage message}) async {
    //login page webview로부터 응답을 받는다.
    Map<String, dynamic> tokens = jsonDecode(message.message);

    //로그인 정보를 갱신한다.
    _accessToken = tokens['accessToken'];
    _refreshToken = tokens['refreshToken'];
    _isLogined = true;

    //서버에 fcm token을 등록한다(설치 등으로 바뀌는 케이스 있으므로 매 로그인마다 실행)
    await _registFcmTokenToServer(tokens['accessToken']);

    debugPrint('[log] got login');
    debugPrint('[log] access token : $_accessToken');
    debugPrint('[log] refresh token : $_refreshToken');
    return;
  }

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
    _isLogined = false;
  }

  Future<void> _registFcmTokenToServer(String accessToken) async {
    var url = Uri.parse('${ServerUrl.serverUrl}/fcm/token');
    var header = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    var body = {"token": "${FcmNotification.fcmToken}"};

    http.Response? response = await HttpMethod.tryPost(
      title: "regist fcm token",
      url: url,
      header: header,
      body: body,
    );

    if (response?.statusCode != 200) {
      debugPrint('[log] fcm token regist fail');
    }
    return;
  }

  Future<dynamic> reissuAccessToken() async {
    var url = Uri.parse(ServerUrl.accessTokenUrl);
    var header = {'Authorization': 'Bearer $_accessToken'};
    var body = {'refreshToken: $_refreshToken'};

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
}

class HttpMethod {
  static Future<http.Response?> tryGet({
    required String title,
    required Uri url,
    required Map<String, String> header,
  }) async {
    debugPrint("[log] start $title");

    try {
      http.Response? response = await http.get(url, headers: header);
      if (response.statusCode != 200) {
        debugPrint("[log] fail ${response.statusCode}");
        debugPrint("[log] body ${response.body}");
        return null;
      }
      debugPrint("[log] success $title");
      return response;
    } catch (e) {
      debugPrint('[log] error $title: $e');
      return null;
    }
  }

  static Future<http.Response?> tryPost({
    required String title,
    required Uri url,
    required Map<String, String> header,
    required Map<String, dynamic> body,
  }) async {
    debugPrint("[log] start $title");

    try {
      var response =
          await http.post(url, headers: header, body: jsonEncode(body));
      if (response.statusCode != 200) {
        debugPrint("[log] fail code ${response.statusCode}");
        debugPrint("[log] fail body ${response.body}");
        return null;
      }
      debugPrint("[log] success $title");
      return response;
    } catch (e) {
      debugPrint('[log] error $title: $e');
      return null;
    }
  }

  static Future<http.Response?> tryPatch({
    required String title,
    required Uri url,
    required Map<String, String> header,
    required Map<String, dynamic> body,
  }) async {
    debugPrint("[log] start $title");

    try {
      var response =
          await http.patch(url, headers: header, body: json.encode(body));
      if (response.statusCode != 200) {
        debugPrint("[log] fail ${response.statusCode}");
        debugPrint("[log] fail body ${response.body}");
        return null;
      }
      debugPrint("[log] success $title");
      return response;
    } catch (e) {
      debugPrint('[log] error $title: $e');
      return null;
    }
  }

  static Future<bool> tryDelete({
    required String title,
    required Uri url,
    required Map<String, String> header,
  }) async {
    debugPrint("[log] start $title");

    try {
      http.Response? response = await http.delete(url, headers: header);
      if (response.statusCode != 200) {
        debugPrint("[log] fail ${response.statusCode}");
        debugPrint("[log] body ${response.body}");
        return false;
      }
      debugPrint("[log] success $title");
      return true;
    } catch (e) {
      debugPrint('[log] error $title: $e');
      return false;
    }
  }

  static Future<http.Response?> tryPut({
    required String title,
    required Uri url,
    required Map<String, String> header,
  }) async {
    debugPrint("[log] start $title");

    try {
      http.Response? response = await http.put(url, headers: header);
      if (response.statusCode != 200) {
        debugPrint("[log] fail ${response.statusCode}");
        debugPrint("[log] body ${response.body}");
        return null;
      }
      debugPrint("[log] success $title");
      return response;
    } catch (e) {
      debugPrint('[log] error $title: $e');
      return null;
    }
  }

  static Future<bool> tryMultipartRequest({
    required String title,
    required http.MultipartRequest request,
  }) async {
    debugPrint("[log] start $title");

    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode != 200) {
        final responseBody = await response.stream.bytesToString();
        debugPrint('[log] fail ${response.statusCode}');
        debugPrint('[log] fail body: $responseBody');
        return false;
      }
      debugPrint("[log] success $title");
      return true;
    } catch (e) {
      debugPrint('[log] error $title, $e');
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
      debugPrint('[log] get my profile from server error!');
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

  // static Future<dynamic> getUserProfileFromServer(
  //     {required String userName}) async {
  //   var url = Uri.parse('${ServerUrl.userProfileUrl}?username=$userName');
  //   var header = {'Authorization': 'Bearer ${_tokenManager.accessToken}'};
  //   var result = await HttpMethod.tryGet(
  //       title: "get user profile", url: url, header: header);
  //   if (result == null) return null;
  // }
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
      debugPrint('[log] get dog profile error');
      return null;
    }
    var data = jsonDecode(response.body);
    debugPrint('[log] json decode $data');
    DogInfo dogInfo;
    try {
      dogInfo = DogInfo(
        data['id'],
        data['name'],
        data['gender'],
        data['image'] == null ? null : base64Decode(data['image']),
        data['owner'],
        true,
        data['age'],
        //TODO: 고치기
        data['size'],
        1.1,
        data['breed'],
        data['description'],
      );
      return dogInfo;
    } catch (e) {
      debugPrint('[log] create doginfo fail');
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
    request.fields['weight'] = doginfo.weight.toString();
    request.fields['breed'] = doginfo.breed;
    request.fields['description'] = doginfo.description;
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
    request.fields['weight'] = doginfo.weight.toString();
    request.fields['breed'] = doginfo.breed;
    request.fields['description'] = doginfo.description;
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
      debugPrint('[log] get request detail error');
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
      debugPrint('[log] decode requirement fail');
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
      debugPrint('[log] response is null');
      return null;
    }
    return response;
  }

  //요구 등록
  static Future<bool> registRequirement({
    required int dogId,
    required DateTime dateTime,
    required int duration,
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
      "startTime": dateTime.toIso8601String(),
      "endTime": dateTime.toIso8601String(),
      "careLocation": {
        "x": myMap.myLocation!.longitude,
        "y": myMap.myLocation!.latitude,
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
      debugPrint('[log] regist requirement fail');
      return false;
    }
    return true;
  }

  // 요구 취소
  static Future<bool> cancelMyRequirement(int requirementId) async {
    var url = Uri.parse('${ServerUrl.requirementUrl}/cancel?id=$requirementId');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};
    http.Response? response = await HttpMethod.tryPut(
      title: "my requirement",
      url: url,
      header: header,
    );
    if (response == null) {
      debugPrint('[log] response is null');
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
      debugPrint('[log] response is null');
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
      debugPrint('[log] decode application fail');
      return null;
    }
  }

  //탐색한 요구사항에 대한 신청
  static Future<bool> apply(int requirementId) async {
    var url =
        Uri.parse('${ServerUrl.applicationUrl}?requirementId=$requirementId');
    var header = {'Authorization': 'Bearer ${_auth.accessToken}'};

    try {
      var response = await http.post(url, headers: header);
      if (response.statusCode != 200) {
        debugPrint("[log] apply fail code ${response.statusCode}");
        debugPrint("[log] apply fail body ${response.body}");
        return false;
      }
      debugPrint("[log] success apply");
      return true;
    } catch (e) {
      debugPrint('[log] error apply $e');
      return false;
    }
  }
  //그에 대한 취소
  //내가 등록한 요구사항에 들어온 신청 수락
}

class MatchingLogApi {
  static final AuthApi _auth = AuthApi();

  //매칭 로그 조회
  //특정 매칭 기록 조회
  //매칭 완료
  //매칭 취소
  //
}

class PaymentApi {}

class ChattingApi {}

class ReviewApi {}
