//dependency
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
//files
import '../api.dart';
import '../constants.dart';
import '../customwidgets.dart';
import '../datamodels.dart';
import '../testdata.dart';
import '../mymap.dart';
import '../router.dart';

class MatchingLogPage extends StatefulWidget {
  const MatchingLogPage({super.key});

  @override
  State<MatchingLogPage> createState() => _MatchingLogPageState();
}

class _MatchingLogPageState extends State<MatchingLogPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("매칭 기록")),
      body: FutureBuilder(
        future: context.read<InfiniteList>().updateMatchingLogList(),
        builder: buildMatchingLogList,
      ),
    );
  }

  Widget buildMatchingLogList(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return const Center(child: Text('error!'));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ListView.builder(
          itemCount: context.watch<InfiniteList>().matchingLogList.length,
          itemBuilder: (BuildContext context, int index) {
            if (index ==
                context.watch<InfiniteList>().matchingLogList.length - 3) {
              context.read<InfiniteList>().updateMyApplicationList();
            }

            dynamic image = context.watch<InfiniteList>().matchingLogList[index]
                        ['image'] ==
                    null
                ? const AssetImage('assets/images/empty_image.png')
                : MemoryImage(
                    base64Decode(
                      context.read<InfiniteList>().matchingLogList[index]
                          ['image'],
                    ),
                  );
            int id = context.watch<InfiniteList>().matchingLogList[index]['id'];
            String careType = context
                .watch<InfiniteList>()
                .matchingLogList[index]['careType'];
            String time =
                context.watch<InfiniteList>().matchingLogList[index]['time'];
            String breed =
                context.watch<InfiniteList>().matchingLogList[index]['breed'];
            String status =
                context.watch<InfiniteList>().matchingLogList[index]['status'];

            return customListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: image,
              ),
              title: Text('$breed\t$careType'),
              subtitle: Text(time),
              trailing: Text(status),
              onTap: () {
                context.go(
                  RouterPath.matchLogDetail,
                  extra: {'detailId': id},
                );
              },
            );
          }),
    );
  }
}

class MatchingLogDetailPage extends StatefulWidget {
  final int matchId;
  const MatchingLogDetailPage({super.key, required this.matchId});

  @override
  State<MatchingLogDetailPage> createState() => _MatchingLogDetailPageState();
}

class _MatchingLogDetailPageState extends State<MatchingLogDetailPage> {
  late DetailInfo? _matchingDetail;
  late final GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("매칭 세부 정보")),
      body: FutureBuilder(
        future: MatchingLogApi.getMatchingLogDetail(widget.matchId),
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
                      Container(
                        width: width,
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: SizedBox(
                          width: width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: (width / 10),
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
                              buildInfoButton(
                                  context, userId, dogId, isRequester),
                            ],
                          ),
                        ),
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
                          child: const Text('chatting'),
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
    context.read<LocationInfo>().clearMarkers();
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
            onPressed: () async {
              await PaymentApi.refund(widget.matchId).then((bool result) {
                if (result == true) {
                  _showResult(
                    context,
                    result,
                    '환불 완료',
                    '환불되었습니다',
                  );
                } else {
                  _showResult(context, result, 'fail', 'err');
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

class PaymentProcessPage extends StatelessWidget {
  final int matchId;
  const PaymentProcessPage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: PaymentApi.pay(matchId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == false) {
            return const Center(child: Text('error!'));
          }
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('결제 진행 중...', style: TextStyle(fontSize: 30)),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.push(
                      RouterPath.paymentResult,
                      extra: {'matchId': matchId},
                    );
                  },
                  child: const Text('결제 완료 후 버튼을 눌러주세요'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PaymentResultPage extends StatelessWidget {
  final int matchId;
  const PaymentResultPage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: PaymentApi.approve(matchId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == false) {
            return const Center(child: Text('something wrong'));
          }

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('임금 지불 완료!', style: TextStyle(fontSize: 30)),
                Text(
                  '해당 유저에게 솔직한 리뷰를 써 주세요!',
                  style: TextStyle(fontSize: 20),
                ),
                ElevatedButton(
                  onPressed: () => context.go(RouterPath.home),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: Text('홈으로'),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
