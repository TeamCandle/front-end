<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class RegistrationPage extends StatelessWidget {
  final List<Map<String, dynamic>> ProfileList;

  const RegistrationPage({super.key, required this.ProfileList});

  // Dog profiles to be selected
  static const List<Map<String, dynamic>> dogProfiles = [
    {"name": "dog1", "breed": "푸들", "careType": "산책", "status": "매칭 완료", "image": "assets/images/empty_image.png"},
    {"name": "dog2", "breed": "말티즈", "careType": "돌봄", "status": "모집 중", "image": "assets/images/empty_image.png"},
    {"name": "dog3", "breed": "시츄", "careType": "외견 케어", "status": "등록 취소", "image": "assets/images/empty_image.png"},
    {"name": "dog4", "breed": "리트리버", "careType": "놀아주기", "status": "매칭 실패", "image": "assets/images/empty_image.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('등록 화면'),
      ),
      body: ListView.builder(
        itemCount: dogProfiles.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(dogProfiles[index]["image"]),
            ),
            title: Text(dogProfiles[index]["name"]),
            subtitle: Text("견종: ${dogProfiles[index]["breed"]}"),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dogProfiles[index]["careType"]),
                Text(dogProfiles[index]["status"]),
              ],
            ),
            onTap: () {
              context.go("/home/match/resister/resisterDetail");
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go("/home/match/resister/resisterform");
        },
        child: Text('등록하기'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class ApplicantProfilePage extends StatelessWidget {
  const ApplicantProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('신청자 프로필')),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(children: [
          const Spacer(),
          const CircleAvatar(
            radius: 50,
            foregroundImage: AssetImage('assets/images/profile_test.png'),
          ),
          const Spacer(),
          Row(children: [
            Expanded(
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('name'), Text('gender'), Text('age'),],),]),),]),
          Row(
            children: [
              const Spacer(),
              SizedBox(
                  height: 60, width: 100,
                  child: Image.asset('assets/images/img_1.png')),
              const Spacer(),
              Text("3.5점"),
              const Spacer(),
            ],),
          const Spacer(),
          const Text("description"),
          const Spacer(),
          ElevatedButton(
              onPressed: () {
              },
              child: const Text("매칭 후기")),
        ]),),);}}

class RegistrationDetailPage extends StatefulWidget {
  final List<Map<String, dynamic>> ProfileList;

  const RegistrationDetailPage({required this.ProfileList});

  @override
  _RegistrationDetailPageState createState() => _RegistrationDetailPageState();
}

class _RegistrationDetailPageState extends State<RegistrationDetailPage> {
  String _selectedCareType = '산책';
  DateTime _selectedDateTime = DateTime.now(); // 현재 시간을 기본값으로 선택
  TextEditingController _detailController = TextEditingController();
  bool _isSelected = false;

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute,
          );
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final applicants = [
      {'name': '신청자1', 'image': 'assets/images/user1.png'},
      {'name': '신청자2', 'image': 'assets/images/user2.png'},
      {'name': '신청자3', 'image': 'assets/images/user3.png'},
      {'name': '신청자4', 'image': 'assets/images/user4.png'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('등록 상세 정보'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Spacer(),
                Image.asset(
                  'assets/images/empty_image.png',
                  width: 100,
                  height: 100,
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('케어 종류 : 산책', style: TextStyle(fontSize: 16.0)),
                    SizedBox(height: 20),
                    Text('날짜 시간: ', style: TextStyle(fontSize: 16.0)),
                    SizedBox(height: 20),
                    Text('위치:'),
                    SizedBox(height: 20),
                    Text('상세정보:'),
                  ],
                ),
                const Spacer(),
              ],
            ),
            SizedBox(height: 70),
            Text('신청 선택:', style: TextStyle(fontSize: 16.0)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: applicants.length,
              itemBuilder: (context, index) {
                final applicant = applicants[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(applicant['image']!),
                  ),
                  title: Text(applicant['name']!),
                  trailing: ElevatedButton(
                    onPressed: () {
                    },
                    child: Text("수락"),
                  ),
                  onTap: () {
                    context.go("/home/match/resister/resisterDetail/ApplicantProfile");
                  },
                );
              },
            ),
            SizedBox(height: 50),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 등록 취소
                },
                child: Text("등록 취소", style: TextStyle(fontSize: 16.0)), // 모집중에서만 등록 취소 활성화 되고 매칭 완료, 등록 취소, 매칭 실패 상태 나타낸다
                // 모집 완료시 신청자 리스트 제거
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class RegistrationFormPage extends StatefulWidget {
  final List<Map<String, dynamic>> ProfileList;

  const RegistrationFormPage({required this.ProfileList});

  @override
  _RegistrationFormPageState createState() => _RegistrationFormPageState();
}

class _RegistrationFormPageState extends State<RegistrationFormPage> {
  String _selectedCareType = '산책';
  DateTime _selectedDateTime = DateTime.now();

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('등록 정보 입력'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            Row(
              children: <Widget>[
                SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () {
                    context.go("/home/match/resister/resisterform/selectprofile");
                  },
                  child: Text('애견프로필 선택'),
                ),
                const Spacer(),
                Column(
                  children: <Widget>[
                    Text('케어 종류 선택:'),
                    DropdownButton<String>(
                      value: _selectedCareType,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCareType = newValue!;
                        });
                      },
                      items: <String>['산책', '돌봄', '외견 케어', '놀아주기', '기타']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    Text('날짜 시간:'),
                    ElevatedButton(
                      onPressed: () => _selectDateTime(context),
                      child: Text(
                        '${_selectedDateTime.year}-${_selectedDateTime.month}-${_selectedDateTime.day} ${_selectedDateTime.hour}:${_selectedDateTime.minute}',
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: null,
                        child: Text('위치')
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
            const Spacer(),
            TextField(
              decoration: InputDecoration(
                labelText: '세부 사항 입력',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, 'Care Type: $_selectedCareType, Time: ${_selectedDateTime.toString()}');
              },
              child: Text('등록'),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class ProfileSelectionPage extends StatelessWidget {
  final List<Map<String, dynamic>> ProfileList;

  const ProfileSelectionPage({required this.ProfileList});

  static const List<Map<String, dynamic>> dogProfiles = [
    {"name": "dog1", "image": "assets/images/empty_image.png"},
    {"name": "dog2", "image": "assets/images/empty_image.png"},
    {"name": "dog3", "image": "assets/images/empty_image.png"},
    {"name": "dog4", "image": "assets/images/empty_image.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('애견 프로필 선택'),
      ),
      body: ListView.builder(
        itemCount: dogProfiles.length,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(dogProfiles[index]["image"]),
                ),
                title: Text(dogProfiles[index]["name"]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                      },
                      child: Text("선택"),
                    ),
                  ],
                ),
              ),
              Divider(),
            ],
          );
        },
      ),
    );
  }
}
=======
//dependency
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_doguber_frontend/api.dart';
import 'package:flutter_doguber_frontend/customwidgets.dart';
import 'package:flutter_doguber_frontend/datamodels.dart';
import 'package:flutter_doguber_frontend/test.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
//files
import '../constants.dart';
import '../testdata.dart';
import '../mymap.dart';
import '../router.dart';

//print my requirement list
//regist my request

class MyRequirementListPage extends StatelessWidget {
  const MyRequirementListPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<InfiniteList>().clearAllList;
    return Scaffold(
      appBar: AppBar(title: const Text("내 요청 목록")),
      body: FutureBuilder(
        future: context.read<InfiniteList>().updateMyRequestList(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Center(child: Text('error!'));
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ListView.builder(
              itemCount: context.watch<InfiniteList>().myRequestList.length,
              itemBuilder: (BuildContext context, int index) {
                var imageSource =
                    context.watch<InfiniteList>().myRequestList[index]['image'];
                dynamic image = imageSource == null
                    ? const AssetImage('assets/images/empty_image.png')
                    : MemoryImage(base64Decode(imageSource));
                int detailId =
                    context.read<InfiniteList>().myRequestList[index]['id'];
                String breed =
                    context.watch<InfiniteList>().myRequestList[index]['breed'];
                String careType = context
                    .watch<InfiniteList>()
                    .myRequestList[index]['careType'];
                String time =
                    context.watch<InfiniteList>().myRequestList[index]['time'];
                String status = context
                    .watch<InfiniteList>()
                    .myRequestList[index]['status'];

                return customListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: image,
                  ),
                  title: Text('$breed\t$careType'),
                  subtitle: Text(time),
                  trailing: Text(status),
                  onTap: () {
                    if (status == '모집중') {
                      context.go(
                        RouterPath.myRequirementDetail,
                        extra: {'detailId': detailId},
                      );
                    } else {
                      return;
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(RouterPath.myRequirementSelectDog);
        },
        child: const Text(
          '+',
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}

//see my requirement detail
class MyRequirementDetailPage extends StatelessWidget {
  final int requirementId;
  const MyRequirementDetailPage({super.key, required this.requirementId});

  Future<void> goBack(BuildContext context) async {
    context.read<InfiniteList>().clearAllList();
    await context
        .read<InfiniteList>()
        .updateMyRequestList()
        .then((_) => context.go(RouterPath.myRequirement));
  }

  Future<dynamic> checkCancel(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('등록 취소'),
            content: const Text('등록된 요구를 취소하시겠습니까?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('아니오'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await RequirementApi.cancelMyRequirement(requirementId)
                      .then((bool result) {
                    if (result == true) {
                      return goBack(context);
                    }
                  });
                },
                child: const Text("네"),
              )
            ],
          );
        });
  }

  Future<dynamic> checkAccept(BuildContext context, int userId) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('신청자 선택'),
            content: const Text('이 신청자를 선택하시겠습니까?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('아니오'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ApplicationApi.accept(requirementId, userId)
                      .then((bool result) {
                    if (result == true) {
                      return goBack(context);
                    }
                  });
                },
                child: const Text("네"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('신청자 확인')),
      body: FutureBuilder(
        future: RequirementApi.getMyRequirementDetail(
          requirementId: requirementId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          }

          var data = jsonDecode(snapshot.data!.body);
          Map<String, dynamic> detail = data['details'];
          List<dynamic> applicants = data['applications'];
          dynamic image = detail['dogImage'] == null
              ? const AssetImage('assets/images/profile_test.png')
              : MemoryImage(base64Decode(detail['dogImage']));

          return LayoutBuilder(builder: (context, constraints) {
            double width = constraints.maxWidth;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  customListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: image,
                    ),
                    title: Text('${detail['careType']}'),
                    subtitle: Text('${detail['reward']} 원'),
                    trailing: Text(
                      '${detail['status']}',
                      style: const TextStyle(fontSize: 15),
                    ),
                    onTap: null,
                  ),
                  customContainer(
                    height: width / 4,
                    child: Text('${detail['description']}'),
                  ),
                  const Divider(color: Colors.grey),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '신청자 목록',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Expanded(
                    child: applicants.isEmpty
                        ? const Center(child: Text('현재 신청자가 없습니다'))
                        : buildApplicantsList(applicants),
                  ),
                  ElevatedButton(
                    onPressed: () => checkCancel(context),
                    child: const Text('요청 등록 취소'),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  ListView buildApplicantsList(List<dynamic> applicants) {
    return ListView.builder(
        itemCount: applicants.length,
        itemBuilder: (BuildContext context, int index) {
          dynamic image = applicants[index]['image'] == null
              ? const AssetImage('assets/images/profile_test.png')
              : MemoryImage(
                  Uint8List.fromList(
                    utf8.encode(applicants[index]['image']),
                  ),
                );

          return customListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: image,
            ),
            title: Text(applicants[index]['name']),
            subtitle: Text(applicants[index]['gender']),
            trailing: RatingBarIndicator(
              rating: applicants[index]['rating'],
              itemBuilder: (context, index) {
                return const Icon(Icons.star, color: Colors.amber);
              },
              itemCount: 5,
              itemSize: 20,
              direction: Axis.horizontal,
            ),
            onTap: () async => checkAccept(context, applicants[index]['id']),
          );
        });
  }
}

//requirement regist sequence
class SelectDogPage extends StatelessWidget {
  const SelectDogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('선택 화면')),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  '어느 아이를 부탁하시겠어요?',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  itemCount: context.watch<UserInfo>().ownDogList.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (context.watch<UserInfo>().ownDogList.isEmpty) {
                      return const Center(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('반려동물이 없으신가요?'),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('가족같은 나의 반려견을 등록해보세요'),
                            ),
                          ],
                        ),
                      );
                    }

                    dynamic image = context.watch<UserInfo>().ownDogList[index]
                                ['dogImage'] ==
                            null
                        ? const AssetImage('assets/images/profile_test.png')
                        : MemoryImage(context
                            .watch<UserInfo>()
                            .ownDogList[index]['dogImage']);
                    String name =
                        context.watch<UserInfo>().ownDogList[index]["name"];
                    String breed =
                        context.watch<UserInfo>().ownDogList[index]["breed"];
                    int dogId =
                        context.read<UserInfo>().ownDogList[index]["id"];

                    return customListTile(
                      leading: CircleAvatar(radius: 30, backgroundImage: image),
                      title: Text(name),
                      subtitle: Text(breed),
                      trailing: ElevatedButton(
                        onPressed: () {
                          context.go(
                            RouterPath.myRequirementSelectLocation,
                            extra: {'dogId': dogId},
                          );
                        },
                        child: const Icon(Icons.arrow_forward),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectLocationPage extends StatefulWidget {
  final int dogId;
  const SelectLocationPage({super.key, required this.dogId});

  @override
  State<SelectLocationPage> createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  late final GoogleMapController _mapController;
  late LatLng myLocation;
  LatLng? targetLocation;

  Future<void> initialize() async {
    await context.read<LocationInfo>().getMyLocation().then((LatLng? location) {
      if (location == null) return;
      myLocation = location;
      context.read<LocationInfo>().setOnlySingleMarker(myLocation);
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('수행 위치를 선택해주세요')),
      body: FutureBuilder(
        future: initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Err'));
          }

          return GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: myLocation,
              zoom: 15,
            ),
            markers: context.watch<LocationInfo>().markers,
            onTap: (LatLng argument) async {
              targetLocation = argument;
              context.read<LocationInfo>().setOnlySingleMarker(targetLocation!);
              debugPrint(
                '[log] marking on tap $targetLocation',
              );
              await _mapController
                  .animateCamera(CameraUpdate.newLatLng(targetLocation!));
            },
          );
        },
      ),
      bottomNavigationBar: Row(children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () async {
                context.go(
                  RouterPath.myRequirementRegistForm,
                  extra: {
                    'location': myLocation,
                    'dogId': widget.dogId,
                  },
                );
              },
              child: const Text('내 위치'),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                if (targetLocation == null) return;
                context.go(
                  RouterPath.myRequirementRegistForm,
                  extra: {
                    'location': targetLocation,
                    'dogId': widget.dogId,
                  },
                );
              },
              child: const Text('선택한 위치'),
            ),
          ),
        ),
      ]),
    );
  }
}

class RequestRegistrationFormPage extends StatefulWidget {
  final int dogId;
  final LatLng location;
  const RequestRegistrationFormPage({
    super.key,
    required this.dogId,
    required this.location,
  });

  @override
  State<RequestRegistrationFormPage> createState() =>
      _RequestRegistrationFormPageState();
}

class _RequestRegistrationFormPageState
    extends State<RequestRegistrationFormPage> {
  final TextEditingController timeController = TextEditingController();
  final TextEditingController rewardController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedCare = CareType.walking;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('!!! received location : ${widget.location}');
    Future<void> goBack() async {
      context.read<InfiniteList>().clearAllList();
      await context.read<InfiniteList>().updateMyRequestList().then((_) {
        context.go(RouterPath.myRequirement);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("등록 양식")),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FutureBuilder(
                      future: context.read<LocationInfo>().getPlaceAddress(
                            widget.location.latitude,
                            widget.location.longitude,
                          ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return LinearProgressIndicator();
                        } else if (snapshot.hasError || snapshot.data == null) {
                          return Text('data null');
                        }
                        return TextField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: snapshot.data!,
                          ),
                        );
                      }),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () async => await _selectDate(),
                        child: const Text('날짜 선택'),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _selectedDate == null
                                ? ''
                                : _selectedDate!.toString().split(' ').first,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () async => await _selectTime(),
                          child: const Text('시작 시간'),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: TextField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: _selectedTime == null
                                  ? ''
                                  : _selectedTime!.format(context),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(labelText: '얼마동안 돌봐드릴까요?'),
                  keyboardType: TextInputType.number,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                  child: Row(
                    children: [
                      const Text(
                        '요청사항',
                        style: TextStyle(fontSize: 20),
                      ),
                      const Spacer(),
                      DropdownButton<String>(
                        padding: const EdgeInsets.only(top: 8),
                        value: _selectedCare,
                        onChanged: (String? value) {
                          setState(() => _selectedCare = value!);
                        },
                        items: const [
                          DropdownMenuItem<String>(
                            value: CareType.walking,
                            child: Text('산책'),
                          ),
                          DropdownMenuItem<String>(
                            value: CareType.boarding,
                            child: Text('이동'),
                          ),
                          DropdownMenuItem<String>(
                            value: CareType.grooming,
                            child: Text('미용/단장'),
                          ),
                          DropdownMenuItem<String>(
                            value: CareType.playtime,
                            child: Text('훈련/놀아주기'),
                          ),
                          DropdownMenuItem<String>(
                            value: CareType.etc,
                            child: Text('기타'),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: rewardController,
                    decoration: const InputDecoration(labelText: '보상'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: customTextField(
                    child: TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: '설명',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (_selectedDate == null || _selectedTime == null)
                        return;
                      int? hour = int.tryParse(timeController.text);
                      if (hour == null) return;
                      final DateTime startTime = DateTime(
                        _selectedDate!.year,
                        _selectedDate!.month,
                        _selectedDate!.day,
                        _selectedTime!.hour,
                        _selectedTime!.minute,
                      );
                      final DateTime endTime = DateTime(
                        _selectedDate!.year,
                        _selectedDate!.month,
                        _selectedDate!.day,
                        _selectedTime!.hour + hour,
                        _selectedTime!.minute,
                      );
                      await RequirementApi.registRequirement(
                        dogId: widget.dogId,
                        startTime: startTime,
                        endTime: endTime,
                        location: widget.location,
                        careType: _selectedCare,
                        reward: int.parse(rewardController.text),
                        description: descriptionController.text,
                      ).then((bool result) {
                        _showResult(context, result);
                      });
                    },
                    child: const Text('요청 등록하기')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> _showResult(BuildContext context, bool result) {
    String title;
    String content;
    if (result == true) {
      title = '등록 성공!';
      content = '신청자를 모집하고 있습니다!';
    } else {
      title = '등록 실패';
      content = '에러 발생!!';
    }
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (result == true) {
                    context.read<InfiniteList>().clearAllList();
                    await context
                        .read<InfiniteList>()
                        .updateMyRequestList()
                        .then((_) {
                      context.go(RouterPath.myRequirement);
                    });
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("ok"),
              )
            ],
          );
        });
  }
}
>>>>>>> ljh_0606
