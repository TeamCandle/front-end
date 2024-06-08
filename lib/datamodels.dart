//dependencies
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
//files
import 'constants.dart';
import 'api.dart';

//data model with provider
class UserInfo extends ChangeNotifier {
  final AuthApi _auth = AuthApi();
  bool _isLoggedIn = false;
  int? _id;
  String? _name;
  String? _gender;
  int? _age;
  double? _rating;
  String? _description;
  Uint8List? _image;
  List<Map<String, dynamic>> ownDogList = [];

  //getter
  bool get isLoggedIn => _isLoggedIn;
  int get id => _id!;
  String get name => _name!;
  String get gender => _gender!;
  int get age => _age!;
  double get rating => _rating!;
  String? get description => _description;
  Uint8List? get image => _image;

  Future<bool> logIn(JavaScriptMessage message) async {
    await _auth.registToken(message).then((result) {
      if (result == false) return false;
    });
    _isLoggedIn = await updateMyProfile();
    debugPrint('!!! is logged in : $_isLoggedIn');
    return _isLoggedIn;
  }

  void logOut() {
    _isLoggedIn = false;
    _auth.cleanUpToken();
    _id = null;
    _name = null;
    _gender = null;
    _age = null;
    _description = null;
    _image = null;
    ownDogList = [];
    debugPrint('!!! cleaned up info');
  }

  Future<bool> updateMyProfile() async {
    //get data
    Map<String, dynamic>? data = await ProfileApi.getMyProfileFromServer();
    if (data == null || data.isEmpty) {
      debugPrint('!!! get profile error!');
      return false;
    }

    //set info
    _id = data['id'];
    _name = data['name'];
    _gender = data['gender'];
    _age = data['age'];
    _description = data['description'];
    _rating = data['rating'];
    if (_rating == -1) {
      _rating = 0;
    }
    if (data['image'] != null) {
      List<int> bytes = base64Decode(data['image']);
      _image = Uint8List.fromList(bytes);
    }
    ownDogList = data['dogList'].cast<Map<String, dynamic>>();
    notifyListeners();
    return true;
  }
}

class InfiniteList extends ChangeNotifier {
  int _allRequestOffset = 1;
  List<dynamic> allRequestList = [];

  int _myRequestOffset = 1;
  List<dynamic> myRequestList = [];

  int _myApplicationOffset = 1;
  List<dynamic> myApplicationList = [];

  int _matchingLogOffset = 1;
  List<dynamic> matchingLogList = [];

  int _reviewOffset = 1;
  List<dynamic> reviewList = [];

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
      allRequestList.addAll(data);
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
      myRequestList.addAll(data);
      ++_myRequestOffset;
      notifyListeners();
      return;
    }
  }

  Future<void> updateMyApplicationList() async {
    List<dynamic>? data =
        await ApplicationApi.getMyApplicationList(offset: _myApplicationOffset);
    if (data == null) {
      debugPrint('[log] null from updateMyApplicationList');
      return;
    } else if (data.isEmpty) {
      debugPrint('[log] empty from updateMyApplicationList');
      return;
    } else {
      myApplicationList.addAll(data);
      ++_myApplicationOffset;
      notifyListeners();
      return;
    }
  }

  Future<void> updateMatchingLogList() async {
    List<dynamic>? data =
        await MatchingLogApi.getMatchingLogList(_matchingLogOffset);
    if (data == null) {
      debugPrint('[log] null from updateMatchingLogList');
      return;
    } else if (data.isEmpty) {
      debugPrint('[log] empty from updateMatchingLogList');
      return;
    } else {
      matchingLogList.addAll(data);
      ++_matchingLogOffset;
      notifyListeners();
      return;
    }
  }

  Future<void> updateReviewList({required int userId}) async {
    List<dynamic>? data = await ReviewApi.getReviewList(
      userId: userId,
      offset: _reviewOffset,
    );
    if (data == null) {
      debugPrint('[log] null from updateReviewList');
      return;
    } else if (data.isEmpty) {
      debugPrint('[log] empty from updateReviewList');
      return;
    } else {
      reviewList.addAll(data);
      ++_reviewOffset;
      notifyListeners();
      return;
    }
  }

  void releaseList() {
    _allRequestOffset = 1;
    allRequestList = [];
    _myRequestOffset = 1;
    myRequestList = [];
    _myApplicationOffset = 1;
    myApplicationList = [];
    _matchingLogOffset = 1;
    matchingLogList = [];
    _reviewOffset = 1;
    reviewList = [];
    notifyListeners();
    return;
  }

  void clearMyApplicationOnly() {
    //왜? 내 신청 페이지의 root가 allrequest라서
    _myApplicationOffset = 1;
    myApplicationList = [];
    notifyListeners();
  }
}

class ChatData extends ChangeNotifier {
  List<dynamic> messages = [];

  Future<bool> initChatting(int matchId) async {
    List<dynamic>? data = await ChattingApi.getChattingLog(matchId);
    if (data == null) {
      debugPrint('!!! get chatting fail');
      return false;
    }

    messages = data;
    notifyListeners();
    return true;
  }

  void add(Map<String, dynamic> message) {
    messages.add(message);
    notifyListeners();
  }

  void update(String text, String sender) {
    messages.add({'message': text, 'sender': sender});
    notifyListeners();
  }
}

class SettingData extends ChangeNotifier {
  /// 로그인 정보 저장 설정
  static bool isSaveLoggedIn = true;

  /// 알람 권한 설정
  /// 지도 권한 설정
  /// 로그아웃
  ///
}

//data model
class DogInfo {
  int? dogId; //최초 등록 시에만 null
  String dogName;
  int? ownerId; //최초 등록 시에만 null
  String dogGender;
  bool neutered;
  int age;
  String size;
  String breed;
  String? description;
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
    this.breed,
    this.description,
  );
}

class DetailInfo {
  int detailId;
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
  bool? requester;

  DetailInfo(
    this.detailId,
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

  void setRequester(bool isRequester) => requester = isRequester;
}
