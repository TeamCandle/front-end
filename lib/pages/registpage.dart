//dependency
import 'package:flutter/material.dart';
import 'package:flutter_doguber_frontend/api.dart';
import 'package:flutter_doguber_frontend/datamodels.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
//files
import '../constants.dart';
import '../testdata.dart';
import '../mymap.dart';
import '../router.dart';

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
              return ListTile(
                title: Text(
                  context
                      .watch<InfinitList>()
                      .myRequestList[index]['id']
                      .toString(),
                ),
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
  final TextEditingController rewardController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

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

  // final DateTime dateTime = DateTime(
  //     _selectedDate.year,
  //     _selectedDate.month,
  //     _selectedDate.day,
  //     _selectedTime.hour,
  //     _selectedTime.minute,
  //   );

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '[log] get dog id from select for requirement : ${widget.dogId}');
    return Scaffold(
      appBar: AppBar(title: const Text("request registration form page")),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('select dog'),
              ),
              ElevatedButton(
                onPressed: () async => await _selectDate(),
                child: const Text('when start?'),
              ),
              ElevatedButton(
                onPressed: () async => await _selectTime(),
                child: const Text('how long?'),
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
            ],
          ),
        ),
      ),
    );
  }
}
