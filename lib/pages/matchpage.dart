//dependency
import 'dart:convert';

import 'package:flutter/material.dart';
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

    return ListView.builder(
        itemCount: context.watch<InfiniteList>().matchingLogList.length,
        itemBuilder: (BuildContext context, int index) {
          if (index ==
              context.watch<InfiniteList>().matchingLogList.length - 3) {
            context.read<InfiniteList>().updateMyApplicationList();
          }

          var image = context.watch<InfiniteList>().matchingLogList[index]
                      ['image'] ==
                  null
              ? Image.asset('assets/images/empty_image.png')
              : Image.memory(
                  base64Decode(
                    context.read<InfiniteList>().matchingLogList[index]
                        ['image'],
                  ),
                );
          int id = context.watch<InfiniteList>().matchingLogList[index]['id'];
          String careType =
              context.watch<InfiniteList>().matchingLogList[index]['careType'];
          String time =
              context.watch<InfiniteList>().matchingLogList[index]['time'];
          String breed =
              context.watch<InfiniteList>().matchingLogList[index]['breed'];
          String status =
              context.watch<InfiniteList>().matchingLogList[index]['status'];

          return ListTile(
            leading: image,
            title: Text('$breed\t$careType'),
            subtitle: Text(time),
            trailing: Text(status),
            onTap: () =>
                context.go('${RouterPath.matchLogDetail}?matchingId=$id'),
          );
        });
  }
}

class MatchingLogDetailPage extends StatefulWidget {
  final int matchingId;
  const MatchingLogDetailPage({super.key, required this.matchingId});

  @override
  State<MatchingLogDetailPage> createState() => _MatchingLogDetailPageState();
}

class _MatchingLogDetailPageState extends State<MatchingLogDetailPage> {
  final MyMap _mapController = MyMap();
  late DetailInfo? _matchingDetail;

  Future<bool> initDetailPage() async {
    //이 페이지에서 쓸 맵 컨트롤러를 초기화한다.
    bool result = await _mapController.initMapOnRequestDetail();
    if (result == false) return false;

    //요청 세부사항을 가져온다.
    _matchingDetail =
        await MatchingLogApi.getMatchingLogDetail(widget.matchingId);
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
      appBar: AppBar(title: const Text("matching log detail page")),
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
          child: buildMatchingLogButton(isRequester, status),
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
    if (isRequester == true) {
      return Expanded(
        child: Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
            ),
            onPressed: () {
              context.go(
                  '${RouterPath.userProfileFromRequirement}?userId=$userId&detailId=${widget.matchingId}');
            },
            child: const Padding(
              padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: Text('신청자'),
            ),
          ),
        ),
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
                      '${RouterPath.userProfileFromRequirement}?userId=$userId&detailId=${widget.matchingId}');
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
                      '${RouterPath.dogProfileFromRequirement}?dogId=$dogId&detailId=${widget.matchingId}');
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

  Widget? buildMatchingLogButton(bool isRequester, String status) {
    debugPrint('!!! status : $status');
    if (isRequester == true) {
      switch (status) {
        case Status.waiting:
          return Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: ElevatedButton(
                    onPressed: () async {},
                    child: const Text('결제하기'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: ElevatedButton(
                    onPressed: () async {},
                    child: const Text('매칭 취소'),
                  ),
                ),
              ),
            ],
          );
        case Status.notCompleted:
          return ElevatedButton(
            onPressed: () async {},
            child: const Text('완료하기'),
          );
        case Status.completed:
          return ElevatedButton(
            onPressed: () async {},
            child: const Text('리뷰'),
          );
        default:
          return ElevatedButton(
            onPressed: () async {},
            child: Text('$status...'),
          );
      }
    } else {
      switch (status) {
        case Status.completed:
          return ElevatedButton(
            onPressed: () async {},
            child: const Text('리뷰'),
          );
        default:
          return ElevatedButton(
            onPressed: () async {},
            child: Text(status),
          );
      }
    }
  }

  Future<dynamic> _showResult(BuildContext context, bool result) {
    String title;
    String content;
    if (result == true) {
      title = '신청 성공!';
      content = '수락이 되면 알려드릴게요!';
    } else {
      title = '신청 실패!';
      content = '이미 신청하진 않으셨나요?';
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
                    context.read<InfiniteList>().clearMyApplicationOnly();
                    await context
                        .read<InfiniteList>()
                        .updateMyApplicationList()
                        .then((_) {
                      context.go(RouterPath.allRequirement);
                    });
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Text("ok"),
              )
            ],
          );
        });
  }
}
