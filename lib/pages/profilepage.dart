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
            flex: 1,
            child: Column(
              children: [
                context.read<UserInfo>().ownDogList.isEmpty
                    ? Center(child: Text('no dogs'))
                    : ListView.builder(
                        itemCount: context.read<UserInfo>().ownDogList.length,
                        itemBuilder: (context, index) {
                          var dogs = context.read<UserInfo>().ownDogList;
                          return ListTile(
                            title: Text(dogs[index]["name"]),
                            trailing: ElevatedButton(
                              onPressed: () =>
                                  context.go(RouterPath.myDogProfile),
                              child: const Text('detail'),
                            ),
                          );
                        },
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
    return context.read<UserInfo>().image!;
  }
}

class ProfileModifyPage extends StatelessWidget {
  ProfileModifyPage({super.key});

  final TextEditingController _descriptionCtrl = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
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
                //이미지 선택 함수
                try {
                  XFile? pickedFile =
                      await _imagePicker.pickImage(source: ImageSource.gallery);
                  if (pickedFile == null) {
                    return;
                  }
                  await ProfileApi.modifyMyImageAtServer(image: pickedFile);
                } catch (e) {
                  // 에러 발생 시 처리
                  print("Error picking image: $e");
                  return;
                }
              },
              child: const Text('select image'),
            ),
            ElevatedButton(
              onPressed: () {},
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
  const DogProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 프로필 확인 화면
    return Scaffold(
      appBar: AppBar(title: const Text("dog 1")),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Image.asset("assets/images/empty_image.png"),
            ),
            const Expanded(
              flex: 1,
              child: Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        Text(
                          "gender/neutering",
                          style: TextStyle(fontSize: 20),
                        ),
                        Spacer(),
                        Text(
                          "age/weight",
                          style: TextStyle(fontSize: 20),
                        ),
                        Spacer(),
                        Text(
                          "breed/size",
                          style: TextStyle(fontSize: 20),
                        ),
                        Spacer(),
                      ],
                    ),
                    Text(
                      "description",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    // 프로필 등록
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
              TextField(
                controller: neuteredController,
                decoration: const InputDecoration(labelText: '중성화 여부'),
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
                onPressed: () {
                  //프로필 확인용 으로 일단 입력 값 저장 했는데 서버로 저장으로 수정 필요
                  Map<String, dynamic> profile = {
                    "name": nameController.text,
                    "gender": genderController.text,
                    "age": ageController.text,
                    "breed": breedController.text,
                    "neutered": neuteredController.text,
                    "size": sizeController.text,
                    "weight": weightController.text,
                    "description": descriptionController.text,
                  };
                  Navigator.pop(context, profile);
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
