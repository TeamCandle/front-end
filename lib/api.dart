//dependency
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';

//files
import 'constants.dart';

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
  void logIn({required JavaScriptMessage message}) {
    Map<String, dynamic> tokens = jsonDecode(message.message);
    _accessToken = tokens['accessToken'];
    _refreshToken = tokens['refreshToken'];
    _isLogined = true;
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
    debugPrint("[log] $title start");

    try {
      http.Response? response = await http.get(url, headers: header);
      if (response.statusCode != 200) {
        debugPrint("[log] fail code ${response.statusCode}");
        debugPrint("[log] fail body ${response.body}");
        return null;
      }
      debugPrint("[log] success code ${response.statusCode}");
      Map<String, dynamic> decodedData = jsonDecode(response.body);
      debugPrint('[log] body : $decodedData');

      return response;
    } catch (e) {
      debugPrint('[log] $title error : $e');
      return null;
    }
  }

  static Future<dynamic> tryPost({
    required String title,
    required Uri url,
    required Map<String, String> header,
    required Map<String, dynamic> body,
  }) async {
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

  static Future<dynamic> tryPatch({
    required String title,
    required Uri url,
    required Map<String, String> header,
    required Map<String, dynamic> body,
  }) async {
    debugPrint("[log] start $title");

    try {
      var response = await http.patch(
        url,
        headers: header,
        body: json.encode(body),
      );
      if (response.statusCode != 200) {
        debugPrint("[log] fail code ${response.statusCode}");
        debugPrint("[log] fail body ${response.body}");
        return null;
      }
      debugPrint("[log] success code : ${response.statusCode}");
      return response;
    } catch (e) {
      debugPrint('[log] $title error!! : $e');
      return null;
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

  static Future<dynamic> modifyMyImageAtServer({required XFile image}) async {
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
    try {
      http.StreamedResponse response = await request.send();
      debugPrint('[log] success, ${response.statusCode}');
      final responseBody = await response.stream.bytesToString();
      debugPrint('[log] response body: $responseBody');
    } catch (e) {
      debugPrint('[log] error, $e');
    }
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

class RequirementApi {
  // 내 요구 조회
  // Future<dynamic> getMyRequirement({required String requirementId}) async {
  //   var url = Uri.parse('${ServerUrl.requirementUrl}/me?id=$requirementId');
  //   var header = {'Authorization': 'Bearer ${_tokenManager.accessToken}'};
  //   var result =
  //       await _tryGet(title: "my requirement", url: url, header: header);
  //   if (result == null) return null;
  // }

  //requirement function
  // // 요구 등록
  // Future<dynamic> registRequirement(
  //     {required Map<String, dynamic> requirement}) async {
  //   var url = Uri.parse(ServerUrl.requirementUrl);
  //   var header = {'Authorization': 'Bearer ${_tokenManager.accessToken}'};
  //   var result = await _tryPost(
  //       title: "regist requirement",
  //       url: url,
  //       header: header,
  //       body: requirement);
  //   if (result == null) return null;
  // }

  // // 내 요구 리스트 조회
  // Future<dynamic> getmyRequirementList() async {
  //   var url = Uri.parse('${ServerUrl.requirementListUrl}/me');
  //   var header = {'Authorization': 'Bearer ${_tokenManager.accessToken}'};
  //   var result =
  //       await _tryGet(title: "my requirement list", url: url, header: header);
  //   if (result == null) return null;
  // }
}

class DogProfileApi {}

class ApplicationApi {}

class MatchingLogApi {}

class PaymentApi {}

class ChattingApi {}

class ReviewApi {}
