// 유저 프로필 페이지
// 연결되는 서브 페이지 : my review, dog profile, regist dog
import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_doguber_frontend/providers.dart';
import 'package:image_picker/image_picker.dart';

import '../api.dart';
import '../constants.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  //내프로필에 넣을거
  //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필 페이지')),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(children: [
          Expanded(
            flex: 1,
            child: CircleAvatar(
                radius: double.infinity,
                backgroundImage: buildProfileImage(context)),
          ),
          Expanded(
            flex: 1,
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    context.read<UserInfo>().name,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 10),
                      Text(
                        context.read<UserInfo>().gender == "male" ? "남성" : "여성",
                        style: const TextStyle(fontSize: 20),
                      ),
                      const Spacer(flex: 1),
                      Text(
                        '${context.read<UserInfo>().age}세',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const Spacer(flex: 10),
                    ],
                  ),
                  Expanded(
                    flex: 1,
                    child: Card(
                      elevation: 1,
                      child: Text(
                          context.read<UserInfo>().description ?? "안녕하세요~^^"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                context.read<UserInfo>().ownDogList.isEmpty
                    ? Center(child: Text('no dogs'))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: context.read<UserInfo>().ownDogList.length,
                          itemBuilder: (context, index) {
                            var dogs = context.read<UserInfo>().ownDogList;
                            return ListTile(
                              leading: dogs[index]['dogImage'] == null
                                  ? Image.asset(
                                      'assets/images/profile_test.png',
                                    )
                                  : Image.memory(
                                      dogs[index]['dogImage'],
                                    ),
                              title: Text(dogs[index]["name"]),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  context.go(
                                      '${RouterPath.myDogProfile}?dogId=${dogs[index]["id"]}');
                                },
                                child: const Text('detail'),
                              ),
                            );
                          },
                        ),
                      ),
                Column(
                  children: [
                    ElevatedButton(
                        onPressed: () =>
                            context.go(RouterPath.myDogRegistraion),
                        child: Text("regist dog")),
                    ElevatedButton(
                      onPressed: () => context.go(RouterPath.myReview),
                      child: Text("view my reivew"),
                    ),
                    ElevatedButton(
                      onPressed: () => context.go(RouterPath.profileModify),
                      child: Text("modify my info"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  ImageProvider<Object>? buildProfileImage(BuildContext context) {
    if (context.read<UserInfo>().image == null) {
      return const AssetImage('assets/images/profile_test.png');
    }
    return MemoryImage(context.read<UserInfo>().image!);
  }
}

class ProfileModifyPage extends StatelessWidget {
  ProfileModifyPage({super.key});

  final TextEditingController _descriptionCtrl = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? pickedFile;

  @override
  Widget build(BuildContext context) {
    void goBack() => context.go(RouterPath.myProfile);

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            ElevatedButton(
                onPressed: () async {
                  bool result = await ProfileApi.modifyMyDescriptionAtServer(
                      description: _descriptionCtrl.text);
                  if (result == true) {
                    debugPrint('[log] modify success');
                  } else {
                    debugPrint('[log] modify fail');
                  }
                },
                child: const Text('수정')),
            ElevatedButton(
              onPressed: () async {
                try {
                  pickedFile =
                      await _imagePicker.pickImage(source: ImageSource.gallery);
                  if (pickedFile == null) {
                    return;
                  }
                } catch (e) {
                  debugPrint("[log] Error picking image: $e");
                  return;
                }
              },
              child: const Text('select image'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (pickedFile == null) {
                  debugPrint("[log] select image");
                  return;
                }
                bool result =
                    await ProfileApi.modifyMyImageAtServer(image: pickedFile!);
                if (result == false) {
                  debugPrint("[log] modify fail");
                  return;
                }
                goBack();
              },
              child: const Text('modify'),
            )
          ],
        ),
      ),
    );
  }
}

class MyReviewPage extends StatelessWidget {
  const MyReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("my review")),
      body: const Center(child: Text("reviews")),
    );
  }
}

class DogProfilePage extends StatelessWidget {
  final int dogId;
  const DogProfilePage({required this.dogId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("dog id : $dogId")),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                  future: DogProfileApi.getDogProfile(id: dogId),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // 로딩 중일 때
                    } else if (snapshot.data == null) {
                      return Text('data is null ${snapshot.error}');
                    } else if (snapshot.hasError) {
                      return Text(
                          'snapshot has Error: ${snapshot.error}'); // 에러 발생 시
                    }
                    return Column(
                      children: [
                        Text(snapshot.data.dogName),
                        // 나머지 DogInfo 필드에 대한 UI 추가
                      ],
                    );
                  }),
            ),
            ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("remove dog profile"),
                          content: const Text("are you sure?"),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  //TODO: 기능추가
                                  context.go(RouterPath.myProfile);
                                },
                                child: const Text('yes'))
                          ],
                        );
                      });
                },
                child: const Text('remove')),
          ],
        ),
      ),
    );
  }
}

class DogRegistrationPage extends StatefulWidget {
  const DogRegistrationPage({super.key});

  @override
  State<DogRegistrationPage> createState() => _DogRegistrationPageState();
}

class _DogRegistrationPageState extends State<DogRegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController neuteredController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  late DogInfo _dogInfo;
  XFile? _dogImage;
  bool? _selectedRadio;

  @override
  Widget build(BuildContext context) {
    void goBack() => context.go(RouterPath.myProfile);

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 등록'),
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    try {
                      XFile? pickedFile = await _imagePicker.pickImage(
                          source: ImageSource.gallery);
                      if (pickedFile == null) {
                        return;
                      }
                      _dogImage = pickedFile;
                    } catch (e) {
                      // 에러 발생 시 처리
                      print("Error picking image: $e");
                      return;
                    }
                  },
                  child: const Text('select image')),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '이름'),
              ),
              TextField(
                controller: genderController,
                decoration: const InputDecoration(labelText: '성별'),
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: '나이'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: breedController,
                decoration: const InputDecoration(labelText: '종'),
              ),
              Row(
                children: [
                  const Expanded(child: Text('중성화 여부')),
                  Expanded(
                    flex: 2,
                    child: ListTile(
                      title: const Text('완료'),
                      leading: Radio<bool>(
                        value: true,
                        groupValue: _selectedRadio,
                        onChanged: (bool? value) {
                          setState(() => _selectedRadio = value!);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ListTile(
                      title: const Text('안함'),
                      leading: Radio<bool>(
                        value: false,
                        groupValue: _selectedRadio,
                        onChanged: (bool? value) {
                          setState(() => _selectedRadio = value!);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: sizeController,
                decoration: const InputDecoration(labelText: '크기'),
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: '무게'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: '설명'),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  Uint8List? imagedata;
                  if (_dogImage != null) {
                    imagedata = await _dogImage!.readAsBytes();
                  }
                  _dogInfo = DogInfo(
                    null,
                    nameController.text,
                    genderController.text,
                    imagedata,
                    null,
                    _selectedRadio!, //불리안 선택
                    int.parse(ageController.text), //숫자만  가능한 필드로
                    1.1, //더블만 가능한 필드로
                    1.1, //더블만 가능한 필드로
                    breedController.text,
                    descriptionController.text,
                  );
                  bool result =
                      await DogProfileApi.registDogProfile(doginfo: _dogInfo);
                  if (result == false) {
                    debugPrint('[log] regist dog profile failed');
                    return;
                  }
                  goBack();
                },
                child: const Text('등록하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
