//dependency
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_doguber_frontend/api.dart';
import 'package:flutter_doguber_frontend/datamodels.dart';
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

class MyRequestListPage extends StatelessWidget {
  const MyRequestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("my request list")),
      body: FutureBuilder(
        future: context.read<InfinitList>().updateMyRequestList(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Center(child: Text('error!'));
          }

          return ListView.builder(
            itemCount: context.watch<InfinitList>().myRequestList.length,
            itemBuilder: (BuildContext context, int index) {
              //이미지, 견종, 날짜, 케어타입, 등록상태
              return ListTile(
                leading: CircleAvatar(
                  radius: 30.0,
                  child: context.watch<InfinitList>().myRequestList[index]
                              ['image'] ==
                          null
                      ? Image.asset('assets/images/profile_test.png')
                      : Image.memory(base64Decode(context
                          .watch<InfinitList>()
                          .myRequestList[index]['image'])),
                ),
                title: Row(
                  children: [
                    Text(
                      context.watch<InfinitList>().myRequestList[index]
                          ['breed'],
                    ),
                    const Spacer(),
                    Text(
                      context.watch<InfinitList>().myRequestList[index]
                          ['careType'],
                    ),
                  ],
                ),
                subtitle: Text(
                  context.watch<InfinitList>().myRequestList[index]['time'],
                ),
                trailing: Text(
                  context.watch<InfinitList>().myRequestList[index]['status'],
                ),
                onTap: () {
                  if (context.read<InfinitList>().myRequestList[index]
                          ['status'] ==
                      '취소됨') {
                    return;
                  } else {
                    context.go(
                        '${RouterPath.myRequirementDetail}?requirementId=${context.read<InfinitList>().myRequestList[index]['id']}');
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(RouterPath.selectDog);
        },
        child: const Text("+"),
      ),
    );
  }
}

//see my requirement detail
class MyRequirementDetailPage extends StatelessWidget {
  final int requirementId;
  const MyRequirementDetailPage({super.key, required this.requirementId});

  @override
  Widget build(BuildContext context) {
    Future<void> goBack() async {
      context.read<InfinitList>().releaseList();
      await context.read<InfinitList>().updateMyRequestList().then((_) {
        context.go(RouterPath.myRequirement);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('my requirement')),
      body: FutureBuilder(
        future:
            RequirementApi.getMyRequirementDetail(requirementId: requirementId),
        builder:
            (BuildContext context, AsyncSnapshot<http.Response?> snapshot) {
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
          return Column(
            children: [
              CircleAvatar(
                radius: 30.0,
                child: detail['dogImage'] == null
                    ? Image.asset('assets/images/profile_test.png')
                    : Image.memory(base64Decode(detail['dogImage'])),
              ),
              Text('${detail['careType']}'),
              Text('${detail['description']}'),
              Text('${detail['status']}'),
              Text(detail['reward'].toString()),
              Expanded(
                child: ListView.builder(
                    itemCount: applicants.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: Expanded(
                          child: applicants[index]['image'] == null
                              ? Image.asset('assets/images/profile_test.png')
                              : Image.memory(Uint8List.fromList(
                                  utf8.encode(applicants[index]['image']))),
                        ),
                        title: Text(applicants[index]['name']),
                        subtitle: Text(applicants[index]['gender']),
                        trailing: Text('${applicants[index]['rating']}'),
                      );
                    }),
              ),
              ElevatedButton(
                onPressed: () async {
                  bool result =
                      await RequirementApi.cancelMyRequirement(requirementId);
                  if (result == false) return;
                  await goBack();
                },
                child: const Text('cancel'),
              ),
            ],
          );
        },
      ),
    );
  }
}

//requirement regist sequence
class SelectDogInRequirementPage extends StatelessWidget {
  const SelectDogInRequirementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('select dog'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
                child: Text(
              '어느 아이를 부탁하시겠어요?',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            )),
            context.watch<UserInfo>().ownDogList.isEmpty
                ? const Center(
                    child:
                        Text('        키우는 반려견이 없으신가요?\n가족같은 나의 반려견을 등록해보세요 ^^'),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: context.watch<UserInfo>().ownDogList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: context.watch<UserInfo>().ownDogList[index]
                                      ['dogImage'] ==
                                  null
                              ? Image.asset('assets/images/profile_test.png')
                              : Image.memory(context
                                  .watch<UserInfo>()
                                  .ownDogList[index]['dogImage']),
                          title: Text(context
                              .watch<UserInfo>()
                              .ownDogList[index]["name"]),
                          trailing: ElevatedButton(
                            onPressed: () {
                              context.go(
                                '${RouterPath.requirementRegistForm}?dogId=${context.read<UserInfo>().ownDogList[index]["id"]}',
                              );
                            },
                            child: const Text('select'),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class RequestRegistrationFormPage extends StatefulWidget {
  final int dogId;
  const RequestRegistrationFormPage({super.key, required this.dogId});

  @override
  State<RequestRegistrationFormPage> createState() =>
      _RequestRegistrationFormPageState();
}

class _RequestRegistrationFormPageState
    extends State<RequestRegistrationFormPage> {
  final TextEditingController timeController = TextEditingController();
  final TextEditingController rewardController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  MyMap _mymap = MyMap();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedCare = CareType.boarding;

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
    Future<void> goBack() async {
      context.read<InfinitList>().releaseList();
      await context.read<InfinitList>().updateMyRequestList().then((_) {
        context.go(RouterPath.myRequirement);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("request registration form page")),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () async => await _selectDate(),
                child: const Text('select date'),
              ),
              ElevatedButton(
                onPressed: () async => await _selectTime(),
                child: const Text('select start time'),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'how long?'),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  const Spacer(),
                  const Text('요청사항'),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _selectedCare,
                    onChanged: (String? value) {
                      setState(() => _selectedCare = value!);
                    },
                    items: const [
                      DropdownMenuItem<String>(
                        value: CareType.boarding,
                        child: Text(CareType.boarding),
                      ),
                      DropdownMenuItem<String>(
                        value: CareType.etc,
                        child: Text(CareType.etc),
                      ),
                      DropdownMenuItem<String>(
                        value: CareType.grooming,
                        child: Text(CareType.grooming),
                      ),
                      DropdownMenuItem<String>(
                        value: CareType.playtime,
                        child: Text(CareType.playtime),
                      ),
                      DropdownMenuItem<String>(
                        value: CareType.walking,
                        child: Text(CareType.walking),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
              TextField(
                controller: rewardController,
                decoration: const InputDecoration(labelText: '보상'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: '설명'),
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (_selectedDate == null || _selectedTime == null) return;
                    final DateTime dateTime = DateTime(
                      _selectedDate!.year,
                      _selectedDate!.month,
                      _selectedDate!.day,
                      _selectedTime!.hour,
                      _selectedTime!.minute,
                    );
                    await RequirementApi.registRequirement(
                      dogId: widget.dogId,
                      dateTime: dateTime,
                      duration: int.parse(timeController.text),
                      careType: _selectedCare,
                      reward: int.parse(rewardController.text),
                      description: descriptionController.text,
                    ).then((bool result) {
                      _showResult(context, result);
                    });
                  },
                  child: const Text('request')),
            ],
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
                    context.read<InfinitList>().releaseList();
                    await context
                        .read<InfinitList>()
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
