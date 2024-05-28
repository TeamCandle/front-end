//dependencies
import 'dart:io';

import 'package:flutter/foundation.dart';
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
  Uint8List? _image;
  List<Map<String, dynamic>> ownDogList = [];

  //getter
  int get id => _id;
  String get name => _name;
  String get gender => _gender;
  int get age => _age;
  String? get description => _description;
  Uint8List? get image => _image;

  Future<void> updateMyProfile() async {
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
    if (data['image'] != null) {
      List<int> bytes = base64Decode(data['image']);
      _image = Uint8List.fromList(bytes);
    }
    ownDogList = data['dogList'].cast<Map<String, dynamic>>();
    debugPrint('[log] success get my profile');
    notifyListeners();
    return;
  }
}

class DogInfo {
  int? dogId; //최초 등록 시에만 null
  String dogName;
  int? ownerId; //최초 등록 시에만 null
  String dogGender;
  bool neutered;
  int age;
  double size;
  double weight;
  String breed;
  String description;
  Uint8List? dogImage;

  DogInfo(
    this.dogId,
    this.dogName,
    this.dogGender,
    this.dogImage,
    this.ownerId,
    this.neutered,
    this.age,
    this.size,
    this.weight,
    this.breed,
    this.description,
  );
}
