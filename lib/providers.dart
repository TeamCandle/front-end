//dependencies
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
//files
import 'constants.dart';

class UserInfo extends ChangeNotifier {
  bool _isLogined = false;
  String? _accessToken;
  String? _refreshToken;

  String _name = '_name';
  String _gender = '_gender';
  String _age = '_age';
  String _description = '_description';
  dynamic _image = '_image';
  List<Map<String, dynamic>> ownDogList = [
    {'id': 'a', 'name': 'dog1', 'gender': 'boy', 'image': 'else'},
    {'id': 'b', 'name': 'dog2', 'gender': 'girl', 'image': 'else'},
    {'id': 'c', 'name': 'dog3', 'gender': 'boy', 'image': 'else'},
    {'id': 'c', 'name': 'dog3', 'gender': 'boy', 'image': 'else'},
    {'id': 'c', 'name': 'dog3', 'gender': 'boy', 'image': 'else'},
    {'id': 'c', 'name': 'dog3', 'gender': 'boy', 'image': 'else'},
    {'id': 'c', 'name': 'dog3', 'gender': 'boy', 'image': 'else'},
    {'id': 'c', 'name': 'dog3', 'gender': 'boy', 'image': 'else'},
    {'id': 'c', 'name': 'dog3', 'gender': 'boy', 'image': 'else'},
    {'id': 'c', 'name': 'dog3', 'gender': 'boy', 'image': 'else'},
    {'id': 'c', 'name': 'dog3', 'gender': 'boy', 'image': 'else'},
    {'id': 'c', 'name': 'dog3', 'gender': 'boy', 'image': 'else'},
    {'id': 'c', 'name': 'dog3', 'gender': 'boy', 'image': 'else'},
    {'id': 'c', 'name': 'dog3', 'gender': 'boy', 'image': 'else'},
    {'id': 'c', 'name': 'dog3', 'gender': 'boy', 'image': 'else'},
    {'id': 'c', 'name': 'dog3', 'gender': 'boy', 'image': 'else'},
    {'id': 'c', 'name': 'dog3', 'gender': 'boy', 'image': 'else'},
  ]; //표면정보만 가져와서 리스트뷰로 출력. 상세 정보는 클릭 시 출력

  //getter
  bool get isLogined => _isLogined;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get name => _name;
  String? get gender => _gender;
  String? get age => _age;
  String? get description => _description;

  //login functions
  void logIn({required String accessToken, required String refreshToken}) {
    _isLogined = true;
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    debugPrint("[log] accessToken : $_accessToken");
    debugPrint("[log] refreshToken : $_refreshToken");
    notifyListeners();
  }

  void logOut() {
    _isLogined = false;
    _accessToken = null;
    _refreshToken = null;
  }

  //profile functions
  Future<void> getUserInfo() async {
    var url = Uri.parse(ServerUrl.userProfileUrl);
    var header = {'Authorization': 'Bearer $_accessToken'};

    try {
      var response = await http.get(url, headers: header);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        _name = data['name'];
        _gender = data['gender'];
        _age = data['age'];
        _description = data['description'];
        _image = data['image'];
        ownDogList = jsonDecode(data['dogList']).cast<Map<String, dynamic>>();

        debugPrint("[log] get profile success");
      } else {
        debugPrint(
            "[log] get profile fail, code : ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      debugPrint('[log] get profile error : $e');
    }
  }

  Future<void> changeUserInfo() async {
    //유저 프로필 설명 변경 대신 아예 통째로 없애고 다시 갱신하는건 어떨까
    //유저 설명 말고도 다른 요소를 수정할 필요가 있을 수 있으니
    //이미지는 분리해도 상관없을것같긴하고
  }
}

class DogInfo extends ChangeNotifier {
  //생각해볼 필요가 있겠어
  //map(편의상 object) list냐 그때그때 서버에서 받아올거냐
  //
}
