// 유저 프로필 페이지
// 연결되는 서브 페이지 : my review, dog profile, regist dog
import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_doguber_frontend/customwidgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_doguber_frontend/datamodels.dart';
import 'package:image_picker/image_picker.dart';

import '../api.dart';
import '../constants.dart';
import '../router.dart';

// profile pages
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 정보')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          //variable space
          double width = constraints.maxWidth;
          int id = context.watch<UserInfo>().id;
          dynamic image = context.watch<UserInfo>().image == null
              ? const AssetImage('assets/images/profile_test.png')
              : MemoryImage(context.watch<UserInfo>().image!);
          String name = context.watch<UserInfo>().name;
          String gender =
              context.watch<UserInfo>().gender == "male" ? "남성" : "여성";
          String age = context.watch<UserInfo>().age.toString();
          var txtcon = TextEditingController();
          txtcon.text = context.watch<UserInfo>().description == null
              ? "자기소개를 입력해주세요"
              : context.watch<UserInfo>().description!;
          List<Map<String, dynamic>> dogs =
              context.watch<UserInfo>().ownDogList;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: width / 4,
                  backgroundImage: image,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: Text(name, style: const TextStyle(fontSize: 50)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Center(
                    child: Text(
                      '$gender\t\t\t$age세',
                      style: const TextStyle(fontSize: 25),
                    ),
                  ),
                ),
                customTextField(
                  child: TextField(
                    controller: txtcon,
                    style: const TextStyle(color: Colors.black),
                    maxLines: 4,
                    minLines: 4,
                    enabled: false,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                const Divider(thickness: 2),
                Column(
                  children: dogs.map((dog) {
                    dynamic image = dog['image'] == null
                        ? const AssetImage('assets/images/profile_test.png')
                        : MemoryImage(base64Decode(dog['image']));

                    return customListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: image,
                      ),
                      title: Text(dog["name"]),
                      subtitle: Text('breed'), //TODO: 견종 요청
                      trailing: ElevatedButton(
                        onPressed: () {
                          context.go(
                            RouterPath.myDogProfile,
                            extra: {'dogId': dog['id']},
                          );
                        },
                        child: const Icon(Icons.login_rounded),
                      ),
                    );
                  }).toList(),
                ),
                const Divider(thickness: 2),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: ElevatedButton(
                    onPressed: () => context.go(RouterPath.myDogRegist),
                    child: const Text("반려견 등록하기"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: ElevatedButton(
                    onPressed: () {
                      context.push(
                        RouterPath.reviewList,
                        extra: {'userId': id},
                      );
                    },
                    child: const Text("내 리뷰 보기"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: ElevatedButton(
                    onPressed: () => context.go(RouterPath.myProfileModify),
                    child: const Text("내 정보 수정"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('설정'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileModifyPage extends StatefulWidget {
  const ProfileModifyPage({super.key});

  @override
  State<ProfileModifyPage> createState() => _ProfileModifyPageState();
}

class _ProfileModifyPageState extends State<ProfileModifyPage> {
  final TextEditingController _descriptionCtrl = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? pickedFile;

  @override
  Widget build(BuildContext context) {
    //define function
    void goBack() async {
      await context.read<UserInfo>().updateMyProfile().then((_) {
        context.go(RouterPath.myProfile);
      });
    }

    Future<bool> modifyMyImage() async {
      if (pickedFile == null) {
        debugPrint("[!!!] image empty");
        return true;
      }
      return await ProfileApi.modifyMyImageAtServer(image: pickedFile!);
    }

    void pickImageFromGallery() async {
      try {
        pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
        if (pickedFile == null) {
          return;
        }
      } catch (e) {
        debugPrint("[!!!] Error picking image: $e");
        return;
      }
      //setState(() {});
    }

    Future<bool> modifyMyDescription() async {
      if (_descriptionCtrl.text == "") {
        debugPrint('[!!!] text empty');
        return true;
      }
      return await ProfileApi.modifyMyDescriptionAtServer(
          description: _descriptionCtrl.text);
    }

    //build UI
    return Scaffold(
      appBar: AppBar(title: const Text('내 정보 수정')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth;
          dynamic image = context.read<UserInfo>().image == null
              ? const AssetImage('assets/images/profile_test.png')
              : MemoryImage(context.read<UserInfo>().image!);
          String name = context.read<UserInfo>().name;
          String gender =
              context.read<UserInfo>().gender == "male" ? "남성" : "여성";
          String age = context.read<UserInfo>().age.toString();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: pickImageFromGallery,
                  child: CircleAvatar(
                    radius: width / 4,
                    backgroundImage: pickedFile == null
                        ? image
                        : FileImage(File(pickedFile!.path)),
                  ),
                ),
                Center(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '$gender\t\t\t$age세',
                    style: const TextStyle(fontSize: 20.0),
                  ),
                ),
                SizedBox(
                  height: width / 4,
                  child: TextField(
                    controller: _descriptionCtrl,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      height: 1.2,
                    ),
                    maxLines: 4,
                    minLines: 4,
                    decoration: const InputDecoration(
                      hintText: '자기소개를 입력해주세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    bool result = await modifyMyImage();
                    if (result == false) {
                      debugPrint('log modify image fail');
                      return;
                    }
                    result = await modifyMyDescription();
                    if (result == false) {
                      debugPrint('log modify description fail');
                      return;
                    }
                    goBack();
                  },
                  child: const Text('수정하기'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Dog pages
class DogProfilePage extends StatelessWidget {
  const DogProfilePage({required this.dogId, super.key});
  final int dogId;

  @override
  Widget build(BuildContext context) {
    void goBack() async {
      await context.read<UserInfo>().updateMyProfile().then((_) {
        context.go(RouterPath.myProfile);
      });
    }

    Future<dynamic> buildDeleteDialog(BuildContext context, int id) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("remove dog profile"),
            content: const Text("are you sure?"),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  await DogProfileApi.deleteDogProfile(id: id);
                  goBack();
                },
                child: const Text('yes'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Dog profile")),
      body: Center(
        child: FutureBuilder(
          future: DogProfileApi.getDogProfile(id: dogId),
          builder: (BuildContext context, AsyncSnapshot<DogInfo?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.data == null) {
              return const Text('snapshot has null');
            } else if (snapshot.hasError) {
              return Text('snapshot has Error: ${snapshot.error}');
            }

            int dogId = snapshot.data!.dogId!;
            dynamic image = snapshot.data!.dogImage == null
                ? const AssetImage('assets/images/profile_test.png')
                : MemoryImage(snapshot.data!.dogImage!);
            String dogName = snapshot.data!.dogName;
            String dogGender = snapshot.data!.dogGender == "male" ? "남성" : "여성";
            int age = snapshot.data!.age;
            String description = snapshot.data!.description == null
                ? ""
                : context.watch<UserInfo>().description!;
            bool neutered = snapshot.data!.neutered;
            String breed = snapshot.data!.breed;
            String size = snapshot.data!.size;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: Image(
                    image: image,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(children: [
                    Text('이름 : $dogName'),
                    Text('성별 : $dogGender'),
                    Text(neutered == true ? '중성화 완료' : '중성화 안함'),
                    Text('${age.toString()}살'),
                    Text('$size견'),
                    Text('품종 : $breed'),
                    Text(description),
                    ElevatedButton(
                      onPressed: () => buildDeleteDialog(context, dogId),
                      child: const Text('remove'),
                    ),
                  ]),
                ),
              ],
            );

            // return Column(
            //   children: [
            //     Text(dogInfo.dogId.toString()),
            //     Text(dogInfo.dogName),
            //     Text(dogInfo.dogGender),
            //     Text(dogInfo.ownerId.toString()),
            //     Text(dogInfo.neutered.toString()),
            //     Text(dogInfo.age.toString()),
            //     Text(dogInfo.size.toString()),
            //     Text(dogInfo.weight.toString()),
            //     Text(dogInfo.breed),
            //     Text(dogInfo.description),
            //     ElevatedButton(
            //       onPressed: () => buildDeleteDialog(context, dogInfo.dogId!),
            //       child: const Text('remove'),
            //     ),
            //   ],
            // );
          },
        ),
      ),
    );
  }
}

class DogModifyPage extends StatefulWidget {
  final DogInfo dogInfo;
  const DogModifyPage({super.key, required this.dogInfo});

  @override
  State<DogModifyPage> createState() => _DogModifyPageState();
}

class _DogModifyPageState extends State<DogModifyPage> {
  //TODO: UI랑 같이 만들기
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                widget.dogInfo.dogName = 'changed';
                final ImagePicker _imagePicker = ImagePicker();
                XFile? file =
                    await _imagePicker.pickImage(source: ImageSource.gallery);
                widget.dogInfo.dogImage = await file!.readAsBytes();
                await DogProfileApi.modifyDogProfile(doginfo: widget.dogInfo);
              },
              child: const Text('modify : name to changed'),
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
  final TextEditingController ageController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController neuteredController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  late DogInfo _dogInfo;
  XFile? _dogImage;
  bool? _isNeutered;
  String? _isGender;
  final List<bool> _isSizeSelected = [false, false, false];

  @override
  Widget build(BuildContext context) {
    void goBack() async {
      await context.read<UserInfo>().updateMyProfile().then((_) {
        context.go(RouterPath.myProfile);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('프로필 등록')),
      body: Container(
        margin: const EdgeInsets.all(10.0),
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
              Row(
                children: [
                  const Expanded(child: Text('성별')),
                  Expanded(
                    flex: 2,
                    child: ListTile(
                      title: const Text('남자'),
                      leading: Radio<String>(
                        value: 'male',
                        groupValue: _isGender,
                        onChanged: (String? value) {
                          setState(() => _isGender = value!);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ListTile(
                      title: const Text('여자'),
                      leading: Radio<String>(
                        value: 'female',
                        groupValue: _isGender,
                        onChanged: (String? value) {
                          setState(() => _isGender = value!);
                        },
                      ),
                    ),
                  ),
                ],
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
                        groupValue: _isNeutered,
                        onChanged: (bool? value) {
                          setState(() => _isNeutered = value!);
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
                        groupValue: _isNeutered,
                        onChanged: (bool? value) {
                          setState(() => _isNeutered = value!);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              LayoutBuilder(builder: (context, constraints) {
                return ToggleButtons(
                  isSelected: _isSizeSelected,
                  constraints: BoxConstraints.expand(
                      width: (constraints.maxWidth - 10) / 3),
                  onPressed: (int index) {
                    setState(() {
                      for (int i = 0; i < _isSizeSelected.length; i++) {
                        if (i == index) {
                          _isSizeSelected[i] = true;
                        } else {
                          _isSizeSelected[i] = false;
                        }
                      }
                    });
                  },
                  children: const <Widget>[
                    Text('소형'),
                    Text('중형'),
                    Text('대형'),
                  ],
                );
              }),
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
                  if (_isGender == null) {
                    return;
                  }
                  if (_isNeutered == null) {
                    return;
                  }
                  String size;
                  if (_isSizeSelected[0] == true) {
                    size = DogSize.small;
                  } else if (_isSizeSelected[1] == true) {
                    size = DogSize.medium;
                  } else if (_isSizeSelected[2] == true) {
                    size = DogSize.large;
                  } else {
                    return;
                  }
                  _dogInfo = DogInfo(
                    null,
                    nameController.text,
                    _isGender!,
                    imagedata,
                    null, //owner id. must be empty
                    _isNeutered!, //불리안 선택
                    int.parse(ageController.text), //숫자만  가능한 필드로
                    size,
                    1.1, //더블만 가능한 필드로
                    breedController.text,
                    descriptionController.text,
                  );
                  bool result =
                      await DogProfileApi.registDogProfile(doginfo: _dogInfo);
                  if (result == false) {
                    debugPrint('[!!!] regist dog profile failed');
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
