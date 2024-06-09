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
  final MyMap _mapController = MyMap();
  late DetailInfo? _matchingDetail;

  Future<bool> initDetailPage() async {
    //이 페이지에서 쓸 맵 컨트롤러를 초기화한다.
    bool result = await _mapController.initialize();
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
      appBar: AppBar(title: const Text("현재 진행 중인 매칭")),
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
    int reward = _matchingDetail!.reward;
    String status = _matchingDetail!.status;
    bool isRequester = _matchingDetail!.requester!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: buildGoogleMap(),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double height = constraints.maxHeight;
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
                            Text('현재 $status'),
                          ]),
                          buildInfoButton(context, userId, dogId, isRequester),
                        ],
                      ),
                      customCard(
                        width: width,
                        height: (height / 3),
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
                          child: const Text('chatting'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                        child: isRequester
                            ? requesterButtonSet(status, reward)
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

  GoogleMap buildGoogleMap() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController.setMapController(ctrl: controller);
      },
      initialCameraPosition: CameraPosition(
        target: _matchingDetail!.careLoaction,
        zoom: 15,
      ),
      markers: _mapController.markers,
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
          onPressed: () async {},
          child: const Text('리뷰'),
        );
      default:
        return ElevatedButton(
          onPressed: null,
          child: Text('현재 $status'),
        );
    }
  }

  Widget requesterButtonSet(String status, int reward) {
    if (status == Status.waiting && reward == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ElevatedButton(
              onPressed: () async {
                await MatchingLogApi.complete(widget.matchId)
                    .then((bool result) {
                  if (result == true) {
                    _showResult(
                      context,
                      result,
                      '매칭 완료',
                      '매칭을 완료하였습니다. 리뷰를 작성하실 수 있어요',
                    );
                  } else {
                    _showResult(context, result, 'fail', 'err');
                  }
                });
              },
              child: const Text('완료하기'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await MatchingLogApi.cancel(widget.matchId).then((bool result) {
                if (result == true) {
                  _showResult(
                    context,
                    result,
                    '매칭 취소',
                    '매칭이 취소되었습니다.',
                  );
                } else {
                  _showResult(context, result, 'fail', 'err');
                }
              });
            },
            child: const Text('매칭 취소'),
          ),
        ],
      );
    } else if (status == Status.waiting && reward != 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ElevatedButton(
              onPressed: () async {
                await PaymentApi.pay(widget.matchId);
              },
              child: const Text('결제하기'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await MatchingLogApi.cancel(widget.matchId).then((bool result) {
                if (result == true) {
                  _showResult(
                    context,
                    result,
                    '매칭 취소',
                    '매칭이 취소되었습니다.',
                  );
                } else {
                  _showResult(context, result, 'fail', 'err');
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
                      _showResult(
                        context,
                        result,
                        '매칭 완료',
                        '매칭을 완료하였습니다. 리뷰를 작성하실 수 있어요',
                      );
                    } else {
                      _showResult(context, result, 'fail', 'err');
                    }
                  },
                );
              },
              child: const Text('완료하기'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {},
            child: const Text('결제 취소'),
          ),
        ],
      );
    } else if (status == Status.completed) {
      return ElevatedButton(
        onPressed: () async {},
        child: const Text('리뷰'),
      );
    } else {
      return ElevatedButton(
        onPressed: null,
        child: Text('현재 $status...'),
      );
    }
  }

  Future<dynamic> _showResult(
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
                onPressed: () async {
                  if (result == true) {
                    context.read<InfiniteList>().releaseList();
                    await context
                        .read<InfiniteList>()
                        .updateMatchingLogList()
                        .then((_) {
                      context.go(RouterPath.matchLog);
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
