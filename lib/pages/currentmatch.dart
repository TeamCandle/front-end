import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_doguber_frontend/api.dart';
import 'package:flutter_doguber_frontend/constants.dart';
import 'package:flutter_doguber_frontend/customwidgets.dart';
import 'package:flutter_doguber_frontend/datamodels.dart';
import 'package:flutter_doguber_frontend/mymap.dart';
import 'package:flutter_doguber_frontend/router.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class CurrentMatchPage extends StatefulWidget {
  final int matchId;
  const CurrentMatchPage({super.key, required this.matchId});

  @override
  State<CurrentMatchPage> createState() => _CurrentMatchPageState();
}

class _CurrentMatchPageState extends State<CurrentMatchPage> {
  late DetailInfo? _matchingDetail;
  late final GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("현재 진행 중인 매칭")),
      body: FutureBuilder(
        future: MatchingLogApi.getMatchingLogDetail(widget.matchId),
        builder: buildDetail,
      ),
    );
  }

  Widget buildDetail(BuildContext context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError || snapshot.data == null) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }

    _matchingDetail = snapshot.data;
    //TODO:리스트에서 이미지오류날때 이거쓰삼
    dynamic image = _matchingDetail!.dogImage == null
        ? const AssetImage('assets/images/profile_test.png')
        : MemoryImage(_matchingDetail!.dogImage!);
    String careType = _matchingDetail!.careType;
    String description = _matchingDetail!.description;
    int userId = _matchingDetail!.userId;
    int dogId = _matchingDetail!.dogId;
    int reward = _matchingDetail!.reward;
    String status = _matchingDetail!.status;
    bool isRequester = _matchingDetail!.requester!;
    LatLng location = _matchingDetail!.careLoaction;
    context.read<LocationInfo>().setOnlySingleMarker(location);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: buildGoogleMap(),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double width = constraints.maxWidth;

              return SingleChildScrollView(
                child: customContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            maxRadius: (width / 10),
                            backgroundImage: image,
                          ),
                          Column(children: [
                            Text(careType),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
                              height: 1,
                              width: (width - 32) / 3,
                              color: Colors.grey[300],
                            ),
                            Text('$reward 원'),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
                              height: 1,
                              width: (width - 32) / 3,
                              color: Colors.grey[300],
                            ),
                            Text(status),
                          ]),
                          buildInfoButton(context, userId, dogId, isRequester),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: buildAddress(context, location),
                      ),
                      customCard(
                        width: width,
                        height: (width / 4),
                        child: Text(description),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: ElevatedButton(
                          onPressed: () {
                            context.push(
                              RouterPath.chatting,
                              extra: {'matchId': widget.matchId},
                            );
                          },
                          child: const Text('채팅'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                        child: isRequester
                            ? requesterButtonSet(status)
                            : applicantButtonSet(status),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  FutureBuilder<String?> buildAddress(BuildContext context, LatLng location) {
    return FutureBuilder(
      future: context
          .read<LocationInfo>()
          .getPlaceAddress(location.latitude, location.longitude),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        } else if (snapshot.hasError || snapshot.data == null) {
          return const Text('address null');
        }
        return Text(snapshot.data!);
      },
    );
  }

  GoogleMap buildGoogleMap() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: _matchingDetail!.careLoaction,
        zoom: 15,
      ),
      markers: context.watch<LocationInfo>().markers,
    );
  }

  Widget buildInfoButton(
    BuildContext context,
    int userId,
    int dogId,
    bool isRequester,
  ) {
    if (isRequester == true) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
        ),
        onPressed: () {
          context.push(
            RouterPath.userProfile,
            extra: {'userId': userId},
          );
        },
        child: const Padding(
          padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Text('신청자'),
        ),
      );
    } else {
      return Column(children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(0),
          ),
          onPressed: () {
            context.push(
              RouterPath.userProfile,
              extra: {'userId': userId},
            );
          },
          child: const Padding(
            padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Text('보호자'),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(0),
          ),
          onPressed: () {
            context.push(
                '${RouterPath.dogProfile}?dogId=$dogId&detailId=${widget.matchId}');
          },
          child: const Padding(
            padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Text('강아지'),
          ),
        ),
      ]);
    }
  }

  Widget applicantButtonSet(String status) {
    switch (status) {
      case Status.completed:
        return ElevatedButton(
          onPressed: () async {
            context.go(
              RouterPath.matchLogReviewDetail,
              extra: {'matchId': widget.matchId},
            );
          },
          child: const Text('받은 리뷰 보기'),
        );
      default:
        return ElevatedButton(
          onPressed: null,
          child: Text('현재 $status'),
        );
    }
  }

  Widget requesterButtonSet(String status) {
    if (status == Status.waiting) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ElevatedButton(
              onPressed: () {
                context.push(
                  RouterPath.paymentProcess,
                  extra: {'matchId': widget.matchId},
                );
              },
              child: const Text('결제하기'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await MatchingLogApi.cancel(widget.matchId).then((bool result) {
                if (result == true) {
                  showResultDialog(
                    context,
                    result,
                    '매칭 취소',
                    '매칭이 취소되었습니다.',
                  );
                } else {
                  showResultDialog(context, result, 'fail', 'err');
                }
              });
            },
            child: const Text('매칭 취소'),
          ),
        ],
      );
    } else if (status == Status.notCompleted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ElevatedButton(
              onPressed: () async {
                await MatchingLogApi.complete(widget.matchId).then(
                  (bool result) {
                    if (result == true) {
                      showResultDialog(
                        context,
                        result,
                        '매칭 완료',
                        '매칭을 완료하였습니다. 리뷰를 작성하실 수 있어요',
                      );
                    } else {
                      showResultDialog(context, result, 'fail', 'err');
                    }
                  },
                );
              },
              child: const Text('완료하기'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await PaymentApi.refund(widget.matchId).then((bool result) {
                if (result == true) {
                  showResultDialog(
                    context,
                    result,
                    '환불 완료',
                    '환불되었습니다',
                  );
                } else {
                  showResultDialog(context, result, 'fail', 'err');
                }
              });
            },
            child: const Text('결제 취소'),
          ),
        ],
      );
    } else if (status == Status.completed) {
      return ElevatedButton(
        onPressed: () async {
          context.push(
            RouterPath.matchLogRegistReview,
            extra: {'matchId': widget.matchId},
          );
        },
        child: const Text('리뷰'),
      );
    } else {
      return ElevatedButton(
        onPressed: null,
        child: Text('현재 $status...'),
      );
    }
  }

  Future<dynamic> showResultDialog(
    BuildContext context,
    bool result,
    String title,
    String content,
  ) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text("ok"),
              )
            ],
          );
        });
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
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _callbackReceivedStompMsg(StompFrame frame) {
    //List<dynamic>? result = json.decode(frame.body!);
    Map<String, dynamic> obj = json.decode(frame.body!);
    Map<String, dynamic> message = {
      'message': obj['message'],
      'sender': obj['sender'],
    };

    context.read<ChatData>().add(message);
    _scrollToBottom();
  }

  Future<bool> initChatting() async {
    bool result = await ChattingApi.connect(
      matchId: widget.matchId,
      callback: _callbackReceivedStompMsg,
    );
    if (result == false) return false;
    await context.read<ChatData>().initChatting(widget.matchId);
    _scrollToBottom();
    return true;
  }

  Future<void> sendMessage() async {
    ChattingApi.send(_textController.text, widget.matchId);
    context.read<ChatData>().update(
          _textController.text,
          context.read<UserInfo>().name,
        );
    _textController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _scrollController.dispose();
    ChattingApi.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('채팅')),
      body: FutureBuilder(
          future: initChatting(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: context.watch<ChatData>().messages.length,
                      itemBuilder: (context, index) {
                        if (context.read<ChatData>().messages[index]
                                ['sender'] ==
                            context.read<UserInfo>().name) {
                          return BubbleSpecialThree(
                            text: context.watch<ChatData>().messages[index]
                                ['message'],
                            color: Color(0xFFa2e1a6),
                          );
                        } else {
                          return BubbleSpecialThree(
                            text: context.watch<ChatData>().messages[index]
                                ['message'],
                            color: Colors.white,
                            isSender: false,
                          );
                        }
                      },
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: customSearchField(
                          child: TextField(
                            onTap: _scrollToBottom,
                            controller: _textController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your message',
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 전송 버튼
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: IconButton(
                        icon: const Icon(Icons.send),
                        style: const ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Color(0xFFa2e1a6)),
                        ),
                        onPressed: sendMessage,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
    );
  }
}
