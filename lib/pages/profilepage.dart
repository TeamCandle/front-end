// 유저 프로필 페이지
// 연결되는 서브 페이지 : my review, dog profile, regist dog
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_doguber_frontend/providers.dart';

import '../constants.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필 페이지')),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(children: [
          Row(children: [
            const CircleAvatar(
              radius: 50,
              foregroundImage: AssetImage('assets/images/profile_test.png'),
            ),
            Expanded(
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '${context.read<UserInfo>().name}',
                      style: const TextStyle(fontSize: 30),
                    ),
                    Text('${context.read<UserInfo>().gender}'),
                    Text('${context.read<UserInfo>().age}'),
                  ],
                ),
              ]),
            ),
          ]),
          Row(
            children: [
              const Spacer(),
              SizedBox(
                  height: 60,
                  child: Image.asset('assets/images/rank_test.png')),
              const Spacer(),
              const Text("normal rank"),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go(RouterPath.myReview),
                child: const Text("view my reivew"),
              ),
              const Spacer(),
            ],
          ),
          const Text("description"),
          Expanded(
            flex: 100,
            child: ListView.builder(
              itemCount: context.read<UserInfo>().ownDogList.length,
              itemBuilder: (context, index) {
                var dogs = context.read<UserInfo>().ownDogList;
                return ListTile(
                  title: Text(dogs[index]["name"]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        // 등록된 프로필 확인
                        onPressed: () {
                          context.go(RouterPath.myDogProfile);
                        },
                        child: const Text('상세 정보'),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton(
                        // 등록된 프로필 삭제
                        onPressed: () {},
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          ElevatedButton(
              onPressed: () {
                context.go(RouterPath.myDogRegistraion);
              },
              child: const Text("regist dog")),
        ]),
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
