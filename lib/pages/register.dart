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
