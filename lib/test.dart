import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

String googleApiKey = 'AIzaSyBTk9blgdCa4T8fARQha7o-AuF8WkK3byI';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DogOwnerProfilePage(),
    );
  }
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example data for the dogs
    final List<Map<String, String>> dogs = [
      {'name': 'Dog 1', 'breed': '푸들', 'careType': '산책', 'size': '소형'},
      {'name': 'Dog 2', 'breed': '말티즈', 'careType': '돌봄', 'size': '중형'},
      {'name': 'Dog 3', 'breed': '시츄', 'careType': '외견 케어', 'size': '소형'},
      {'name': 'Dog 4', 'breed': '리트리버', 'careType': '놀아주기', 'size': '대형'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text('위치'),
              ),
              const Spacer(),
              DropdownButton<String>(
                hint: Text('크기'),
                onChanged: (String? newValue) {},
                items: <String>['소형', '중형', '대형']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              Spacer(),
              DropdownButton<String>(
                hint: Text('케어 종류'),
                onChanged: (String? newValue) {},
                items: <String>['산책', '돌봄', '외견 케어', '놀아주기']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: dogs.length + 1, // Additional item for the button
        itemBuilder: (context, index) {
          if (index == dogs.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: () {},
                child: Text('신청 현황'),
              ),
            );
          }
          final dog = dogs[index];
          return ListTile(
            onTap: () {},
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/images/empty_image.png'),
            ),
            title: Text('${dog['name']}'),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('견종: ${dog['breed']}'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(' ${dog['careType']}'),
                    Text(' ${dog['size']}'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ApplicationStatusPage extends StatelessWidget {
  const ApplicationStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example data for the applications
    final List<Map<String, String>> applications = [
      {'name': 'Dog 1', 'breed': '푸들', 'careType': '산책', 'status': '매칭 완료'},
      {'name': 'Dog 2', 'breed': '말티즈', 'careType': '돌봄', 'status': '수락 대기'},
      {'name': 'Dog 3', 'breed': '시츄', 'careType': '외견 케어', 'status': '매칭 실패'},
      {'name': 'Dog 4', 'breed': '리트리버', 'careType': '놀아주기', 'status': '신청 취소'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('신청 현황'),
      ),
      body: ListView.builder(
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final application = applications[index];
          return ListTile(
            onTap: () {},
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/images/empty_image.png'),
            ),
            title: Text('${application['name']}'),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('견종: ${application['breed']}'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${application['careType']}'),
                    Text('${application['status']}'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class exploreDetailPage extends StatelessWidget {
  const exploreDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('탐색 상세 정보'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/map.png', height: 215),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Image.asset(
                  'assets/images/dog.png',
                  width: 170,
                  height: 200,
                ),
                Spacer(),
                Column(
                  children: [
                    Text('케어 타입/ 시간'),
                    SizedBox(height: 30),
                    Text('세부사항'),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('견주 프로필'),
                    ),
                  ],
                ),
                Spacer(),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('신청'),
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class ApplicationDetailPage extends StatelessWidget {
  // exploreDetailPage랑 분리 하긴했으나 마지막 버튼 부분만 바뀜
  const ApplicationDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('신청 상세 정보'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/map.png', height: 215),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Image.asset(
                  'assets/images/dog.png',
                  width: 170,
                  height: 200,
                ),
                Spacer(),
                Column(
                  children: [
                    Text('케어 타입/ 시간'),
                    SizedBox(height: 30),
                    Text('세부사항'),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('견주 프로필'),
                    ),
                  ],
                ),
                Spacer(),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('매칭완료'), // 매칭완료, 수락대기, 매칭 실패, 신청 취소 등 각 상태에 따라
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class DogOwnerProfilePage extends StatelessWidget {
  const DogOwnerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('견주 프로필')),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(children: [
          const Spacer(),
          const CircleAvatar(
            radius: 50,
            foregroundImage: AssetImage('assets/images/profile_test.png'),
          ),
          Row(children: [
            Expanded(
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('name'),
                    Text('gender'),
                    Text('age'),
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
                  width: 100,
                  child: Image.asset('assets/images/img_1.png')),
              const Spacer(),
              Text("3.5점"),
              const Spacer(),
            ],
          ),
          const Spacer(),
          const Text("description"),
          const Spacer(),
          ElevatedButton(onPressed: () {}, child: const Text("매칭 후기")),
        ]),
      ),
    );
  }
}
