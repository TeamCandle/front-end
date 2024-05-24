//dependencies
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
//files
import 'constants.dart';
import 'api.dart';

class UserInfo extends ChangeNotifier {
  int _id = -1;
  String _name = '_name';
  String _gender = '_gender';
  int _age = -1;
  String? _description;
  MemoryImage? _image;
  List<Map<String, dynamic>> ownDogList = [];

  //getter
  String get name => _name;
  String get gender => _gender;
  int get age => _age;
  String? get description => _description;
  MemoryImage? get image => _image;

  Future<void> getMyProfile() async {
    Map<String, dynamic>? data = await ProfileApi.getMyProfileFromServer();
    if (data == null || data.isEmpty) {
      debugPrint('[log] get profile error!');
      return;
    }
    _id = data['id'];
    _name = data['name'];
    _gender = data['gender'];
    _age = data['age'];
    _description = data['description'];
    List<int> bytes = base64Decode(data['image']);
    _image = MemoryImage(Uint8List.fromList(bytes));
    ownDogList = data['dogList'].cast<Map<String, dynamic>>();
    debugPrint('[log] success get my profile');
    return;
  }

  void infoInit() {}
}

class DogInfo {
  final String dogId;
  final String dogName;
  final String dogGender;
  final dynamic dogImage;

  DogInfo(this.dogId, this.dogName, this.dogGender, this.dogImage);
}
