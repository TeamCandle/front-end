import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../api.dart';
import '../customwidgets.dart';
import '../datamodels.dart';
import '../mymap.dart';
import '../router.dart';

class CurrentMatchPage extends StatefulWidget {
  final int matchId;
  const CurrentMatchPage({super.key, required this.matchId});

  @override
  State<CurrentMatchPage> createState() => _CurrentMatchPageState();
}

class _CurrentMatchPageState extends State<CurrentMatchPage> {
  final MyMap _mapController = MyMap();
  late DetailInfo? _matchingDetail;

  Future<bool> initDetailPage() async {
    //이 페이지에서 쓸 맵 컨트롤러를 초기화한다.
    bool result = await _mapController.initMapOnRequestDetail();
    if (result == false) return false;

    //요청 세부사항을 가져온다.
    _matchingDetail = await MatchingLogApi.getMatchingLogDetail(widget.matchId);
    if (_matchingDetail == null) return false;

    //요청자의 좌표를 표시한다.
    _mapController.marking(
      _matchingDetail!.careLoaction.latitude,
      _matchingDetail!.careLoaction.longitude,
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("current matching page")),
      body: FutureBuilder(
        future: initDetailPage(),
        builder: buildDetail,
      ),
    );
  }

  Widget buildDetail(BuildContext context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError || snapshot.data == false) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }

    //TODO:리스트에서 이미지오류날때 이거쓰삼
    dynamic image = _matchingDetail!.dogImage == null
        ? const AssetImage('assets/images/profile_test.png')
        : MemoryImage(_matchingDetail!.dogImage!);
    String careType = _matchingDetail!.careType;
    String description = _matchingDetail!.description;
    int userId = _matchingDetail!.userId;
    int dogId = _matchingDetail!.dogId;
    String reward = _matchingDetail!.reward.toString();
    String status = _matchingDetail!.status;
    bool isRequester = _matchingDetail!.requester!;
    debugPrint('!!! current userId : $userId');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 2,
          child: GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController.setMapController(ctrl: controller);
            },
            initialCameraPosition: CameraPosition(
              target: _matchingDetail!.careLoaction,
              zoom: 15,
            ),
            markers: _mapController.markers,
          ),
        ),
        Expanded(
          flex: 1,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double height = constraints.maxHeight;
              double width = constraints.maxWidth;

              return cunstomContainer(
                child: Column(children: [
                  Expanded(
                    child: Row(children: [
                      Expanded(
                        child: Center(
                          child: CircleAvatar(
                            maxRadius: (height / 4),
                            backgroundImage: image,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(children: [
                          Text('종류 : $careType'),
                          Text('보상 : $reward'),
                          Text('현재 $status'),
                        ]),
                      ),
                      buildInfoButton(context, userId, dogId, isRequester),
                    ]),
                  ),
                  Expanded(
                    child: Center(
                      child: customCard(
                        width: width,
                        height: (height / 2.5),
                        child: Text(description),
                      ),
                    ),
                  ),
                ]),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: ElevatedButton(
            onPressed: () {
              context.go('${RouterPath.chatPage}?matchId=${widget.matchId}');
            },
            child: const Text('chatting'),
          ),
        ),
      ],
    );
  }

  Expanded buildInfoButton(
    BuildContext context,
    int userId,
    int dogId,
    bool isRequester,
  ) {
    debugPrint('!!! requester bool : $isRequester');
    if (isRequester == true) {
      return Expanded(
        child: Column(children: [
          Expanded(
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                ),
                onPressed: () {
                  context.go(
                      '${RouterPath.userProfileFromCurrentMatch}?userId=$userId&detailId=${widget.matchId}');
                },
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: Text('신청자'),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                ),
                onPressed: () {
                  context
                      .go('${RouterPath.chatPage}?matchId=${widget.matchId}');
                },
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: Text('채팅F'),
                ),
              ),
            ),
          ),
        ]),
      );
    } else {
      return Expanded(
        child: Column(children: [
          Expanded(
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                ),
                onPressed: () {
                  context.go(
                      '${RouterPath.userProfileFromRequirement}?userId=$userId&detailId=${widget.matchId}');
                },
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: Text('보호자'),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                ),
                onPressed: () {
                  context.go(
                      '${RouterPath.dogProfileFromRequirement}?dogId=$dogId&detailId=${widget.matchId}');
                },
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: Text('강아지'),
                ),
              ),
            ),
          ),
        ]),
      );
    }
  }
}

class ChattingPage extends StatefulWidget {
  final int matchId;
  const ChattingPage({super.key, required this.matchId});

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  late StompClient stompClient;
  ScrollController _scrollController = ScrollController();
  TextEditingController _textController = TextEditingController();

  void callback(StompFrame frame) {
    //List<dynamic>? result = json.decode(frame.body!);
    Map<String, dynamic> obj = json.decode(frame.body!);
    Map<String, dynamic> message = {
      'message': obj['message'],
      'sender': obj['sender'],
    };

    setState(() {
      context.read<ChatData>().add(message);
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   ChattingApi.connect(matchId: widget.matchId, callback: callback);
  // }

  @override
  void dispose() {
    super.dispose();
    ChattingApi.disconnect();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> initChatting() async {
      bool result = await ChattingApi.connect(
        matchId: widget.matchId,
        callback: callback,
      );
      if (result == false) return false;
      return await context.read<ChatData>().initChatting(widget.matchId);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('widget.title')),
      body: FutureBuilder(
          future: initChatting(),
          builder: (context, snapshot) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: context.watch<ChatData>().messages.length,
                    itemBuilder: (context, index) {
                      if (context.read<ChatData>().messages[index]['sender'] ==
                          context.read<UserInfo>().name) {
                        return Row(children: [
                          const Spacer(),
                          Text(context.watch<ChatData>().messages[index]
                              ['message']),
                        ]);
                      } else {
                        return Row(children: [
                          Text(context.watch<ChatData>().messages[index]
                              ['message']),
                          const Spacer(),
                        ]);
                      }
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your message',
                        ),
                      ),
                    ),
                    // 전송 버튼
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        ChattingApi.send(_textController.text, widget.matchId);
                        context.read<ChatData>().update(
                              _textController.text,
                              context.read<UserInfo>().name,
                            );
                        _textController.clear();
                      },
                    ),
                  ],
                ),
              ],
            );
          }),
    );
  }
}
