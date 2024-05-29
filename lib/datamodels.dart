//dependencies
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
//files
import 'constants.dart';
import 'api.dart';

//provider class
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

class InfinitList extends ChangeNotifier {
  int _allRequestOffset = 1;
  List<dynamic> _allRequestList = [];

  int _myRequestOffset = 1;
  List<dynamic> _myRequestList = [];

  List<dynamic> get allRequestList => _allRequestList;
  List<dynamic> get myRequestList => _myRequestList;

  Future<void> updateAllRequestList() async {
    List<dynamic>? data =
        await RequirementApi.getAllRequirementList(offset: _allRequestOffset);
    if (data == null) {
      debugPrint('[log] null from updateAllRequestList');
      return;
    } else if (data.isEmpty) {
      debugPrint('[log] empty from updateAllRequestList');
      return;
    } else {
      _allRequestList.addAll(data);
      ++_allRequestOffset;
      notifyListeners();
      return;
    }
  }

  Future<void> updateMyRequestList() async {
    List<dynamic>? data =
        await RequirementApi.getMyRequirementList(offset: _myRequestOffset);
    if (data == null) {
      debugPrint('[log] null from updateMyRequestList');
      return;
    } else if (data.isEmpty) {
      debugPrint('[log] empty from updateMyRequestList');
      return;
    } else {
      _myRequestList.addAll(data);
      ++_myRequestOffset;
      notifyListeners();
      return;
    }
  }

  void releaseList() {
    _allRequestOffset = 1;
    _allRequestList = [];
    _myRequestOffset = 1;
    _myRequestList = [];
    notifyListeners();
    return;
  }
}

//data model
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

class RequirementDetail {
  int requirementId;
  Uint8List? dogImage;
  String careType;
  String startTime;
  String endTime;
  LatLng careLoaction;
  String description;
  int userId;
  int dogId;
  int reward;
  String status;

  RequirementDetail(
    this.requirementId,
    this.dogImage,
    this.careType,
    this.startTime,
    this.endTime,
    this.careLoaction,
    this.description,
    this.userId,
    this.dogId,
    this.reward,
    this.status,
  );
}
