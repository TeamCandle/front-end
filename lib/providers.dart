//dependencies
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
//files
import 'constants.dart';
import 'api.dart';

class DogInfo {
  final String dogId;
  final String dogName;
  final String dogGender;
  final dynamic dogImage;

  DogInfo(this.dogId, this.dogName, this.dogGender, this.dogImage);
}

class UserInfo extends ChangeNotifier {
  bool _isLogined = false;
  String _name = '_name';
  String _gender = '_gender';
  String _age = '_age';
  String _description = '_description';
  dynamic _image = '_image';
  List<Map<String, dynamic>> ownDogList = [
    {'id': 'a', 'name': 'dog1', 'gender': 'boy', 'image': 'else'},
    {'id': 'b', 'name': 'dog2', 'gender': 'girl', 'image': 'else'},
    {'id': 'c', 'name': 'dog3', 'gender': 'boy', 'image': 'else'},
  ];
  //표면정보만 가져와서 리스트뷰로 출력. 상세 정보는 클릭 시 출력

  //getter
  bool get isLogined => _isLogined;
  String? get name => _name;
  String? get gender => _gender;
  String? get age => _age;
  String? get description => _description;

  //login functions
  Future<void> logIn(Map<String, dynamic> token) async {
    _isLogined = true;
    DogUberApi.updateAccessToken(accessToken: token['accessToken']);
    DogUberApi.updateRefreshToken(refreshToken: token['refreshToken']);
    await getMyProfile();
  }

  //profile functions
  Future<void> getMyProfile() async {
    var response = await DogUberApi.getMyProfileFromServer();
    if (response == null) return;
    var data = jsonDecode(response.body);
    _name = data['name'];
    _gender = data['gender'];
    _age = data['age'];
    _description = data['description'];
    _image = data['image'];
    ownDogList = jsonDecode(data['dogList']).cast<Map<String, dynamic>>();
  }

  void infoInit() {}
}
