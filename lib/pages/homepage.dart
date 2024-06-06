import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_doguber_frontend/api.dart';
import 'package:go_router/go_router.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../constants.dart';
import '../customwidgets.dart';
import '../datamodels.dart';
import '../mymap.dart';
import '../router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

//TODO: 디자인
class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    dynamic settingImage = context.watch<UserInfo>().image == null
        ? const AssetImage('assets/images/profile_test.png')
        : MemoryImage(context.watch<UserInfo>().image!);
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/images/carrotBowLogo.png'),
        title: const Text('댕근 모멘트'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openEndDrawer(),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: settingImage,
                ),
              ),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(children: [
          ListTile(title: Text('1')),
          ListTile(title: Text('2')),
          ListTile(title: Text('3')),
          ListTile(title: Text('4')),
        ]),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder(
                future: MatchingLogApi.getUpcoming(),
                builder: (context, snapshot) {
                  debugPrint(
                      '!!! get upcoming of ${context.read<UserInfo>().name}, id : ${context.read<UserInfo>().id}');

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return cunstomHomeMenu(
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.data == null) {
                    return cunstomHomeMenu(
                      child: const Center(
                        child: Text('매칭정보 없음'),
                      ),
                    );
                  }

                  int? matchId = snapshot.data!['id'];
                  var image = snapshot.data!['image'] == null
                      ? Image.asset('assets/images/empty_image.png')
                      : Image.memory(base64Decode(snapshot.data!['image']));
                  String breed = snapshot.data!['breed'];
                  String careType = snapshot.data!['careType'];
                  String time = snapshot.data!['time'];
                  String status = snapshot.data!['status'];

                  return cunstomHomeMenu(
                    child: Center(
                      child: Column(children: [
                        const Text('현재 매칭 중인 정보가 있음'),
                        Text('id : $matchId'),
                        Text('breed : $breed'),
                        Text('careType : $careType'),
                        Text('time : $time'),
                        Text('status : $status'),
                      ]),
                    ),
                    onTap: () {
                      context.go(
                        RouterPath.currentDetail,
                        extra: {'detailId': matchId},
                      );
                    },
                  );
                }),
            cunstomHomeMenu(
              onTap: () => context.go(RouterPath.allRequirement),
              child: const Center(child: Text('탐색하기')),
            ),
            cunstomHomeMenu(
              onTap: () => context.go(RouterPath.myRequirement),
              child: const Center(child: Text("regist my request")),
            ),
            cunstomHomeMenu(child: const Center(child: Text("premium"))),
            cunstomHomeMenu(child: const Center(child: Text("community"))),
            cunstomHomeMenu(
              onTap: () => context.go(RouterPath.matchLog),
              child: const Center(child: Text("나의 매칭 기록")),
            ),
            cunstomHomeMenu(
              onTap: () => context.go(RouterPath.myProfile),
              child: const Center(child: Text("profile")),
            ),
            ElevatedButton(
                onPressed: () {
                  context.read<UserInfo>().logOut();
                  context.go('/');
                },
                child: Text('log out')),
          ],
        ),
      ),
    );
  }
}
