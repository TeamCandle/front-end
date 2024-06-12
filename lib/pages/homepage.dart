import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
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
import '../notification.dart';
import '../router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //terminated 상태에서 알람 클릭 시
      String? payload =
          CombinedNotificationService.details?.notificationResponse?.payload;
      int? id = CombinedNotificationService.details?.notificationResponse?.id;
      if (payload == null || id == null) return;
      int? detailId = int.tryParse(payload);
      if (detailId == null) return;
      switch (id) {
        case CombinedNotificationService.appliedNotiId:
          context.go(
            RouterPath.myRequirementDetail,
            extra: {'detailId': detailId},
          );
          break;
        case CombinedNotificationService.acceptedNotiId:
          context.go(
            RouterPath.matchLogDetail,
            extra: {'detailId': detailId},
          );
          break;
        case CombinedNotificationService.chatNotiId:
          context.push(
            RouterPath.chatting,
            extra: {'matchId': detailId},
          );
          break;
        default:
          return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    dynamic profileImageOnDrawer = context.watch<UserInfo>().image == null
        ? const AssetImage('assets/images/profile_test.png')
        : MemoryImage(context.watch<UserInfo>().image!);

    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/images/carrotBowOnlyLogo.png'),
        title: const Text('댕근 모멘트'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openEndDrawer(),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: profileImageOnDrawer,
                ),
              ),
            ),
          ),
          Container(width: 16),
        ],
      ),
      endDrawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: ListView(children: [
            Container(
              margin: const EdgeInsets.all(30),
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width / 5,
                backgroundImage: profileImageOnDrawer,
              ),
            ),
            customHomeMenu(
              onTap: () => context.go(RouterPath.myProfile),
              child: Text('내 프로필'),
            ),
            customHomeMenu(
              onTap: () {
                context.read<UserInfo>().logOut();
                context.go('/');
              },
              child: Text('로그아웃'),
            ),
            customHomeMenu(child: Text('설정')),
          ]),
        ),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        double width = constraints.maxWidth;
        double boxHeight = constraints.maxWidth / 2;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FutureBuilder(
                  future: MatchingLogApi.getUpcoming(),
                  builder: (context, snapshot) {
                    debugPrint(
                        '!!! get upcoming: ${context.read<UserInfo>().id}');

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return customHomeMenu(
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.data == null) {
                      return customHomeMenu(
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

                    return Padding(
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFa2e1a6).withOpacity(0.5),
                              offset: Offset(0, -5),
                              spreadRadius: 0,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: customHomeMenu(
                          child: Center(
                            child: Column(children: [
                              const Text(
                                '현재 진행 중인 매칭 정보입니다',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text('$breed\t$careType'),
                              Text('$time자 건'),
                              Text('$status입니다'),
                            ]),
                          ),
                          onTap: () {
                            context.go(
                              RouterPath.currentDetail,
                              extra: {'detailId': matchId},
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: GestureDetector(
                    onTap: () => context.go(RouterPath.allRequirement),
                    child: customImageHomeMenu(
                      assetImagePath: 'assets/images/dog and people.jpeg',
                      height: boxHeight,
                      width: width,
                      text: '탐색하기',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: GestureDetector(
                    onTap: () => context.go(RouterPath.myRequirement),
                    child: customImageHomeMenu(
                      assetImagePath: 'assets/images/dog in bush.jpeg',
                      height: boxHeight,
                      width: width,
                      text: '돌봄 요청하기',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: customImageHomeMenu(
                    assetImagePath: 'assets/images/dog with a person.jpeg',
                    height: boxHeight,
                    width: width,
                    text: '프리미엄 서비스 신청',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: customImageHomeMenu(
                    assetImagePath: 'assets/images/dog in forest.jpeg',
                    height: boxHeight,
                    width: width,
                    text: '커뮤니티에서 소통해보세요',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: GestureDetector(
                    onTap: () => context.go(RouterPath.matchLog),
                    child: customImageHomeMenu(
                      assetImagePath:
                          'assets/images/a person walking with dog.jpeg',
                      height: boxHeight,
                      width: width,
                      text: '매칭 기록 열람하기',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
