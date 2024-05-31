//dependency
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_doguber_frontend/datamodels.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
//files
import '../constants.dart';
import '../mymap.dart';
import '../api.dart';
import '../router.dart';

//search request from all request list
//apply specific request

class AllRequestPage extends StatefulWidget {
  const AllRequestPage({super.key});

  @override
  State<AllRequestPage> createState() => _AllRequestPageState();
}

class _AllRequestPageState extends State<AllRequestPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    context.read<InfinitList>().releaseList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("all request")),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Text',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list_rounded),
              ),
            ]),
            Expanded(
              child: FutureBuilder(
                future: context.read<InfinitList>().updateAllRequestList(),
                builder: buildAllRequirementList,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.go(RouterPath.myApplicationList);
              },
              child: const Text('my applications'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAllRequirementList(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return const Center(child: Text('error!'));
    }

    return ListView.builder(
      itemCount: context.watch<InfinitList>().allRequestList.length,
      itemBuilder: (BuildContext context, int index) {
        if (index == context.watch<InfinitList>().allRequestList.length - 3) {
          context.read<InfinitList>().updateAllRequestList();
        }

        var image = context.watch<InfinitList>().allRequestList[index]
                    ['image'] ==
                null
            ? Image.asset('assets/images/empty_image.png')
            : Image.memory(base64Decode(
                context.read<InfinitList>().allRequestList[index]['image']));
        int id = context.read<InfinitList>().allRequestList[index]['id'];
        String careType =
            context.watch<InfinitList>().allRequestList[index]['careType'];
        String time =
            context.watch<InfinitList>().allRequestList[index]['time'];
        String breed =
            context.watch<InfinitList>().allRequestList[index]['breed'];
        String status =
            context.watch<InfinitList>().allRequestList[index]['status'];

        return ListTile(
          leading: image,
          title: Text('$breed\t$careType'),
          subtitle: Text(time),
          trailing: Text(status),
          onTap: () =>
              context.go('${RouterPath.requirementDetail}?requestId=$id'),
        );
      },
    );
  }
}

// request detail -> success page
class RequirementDetailPage extends StatefulWidget {
  final int requirementId;
  const RequirementDetailPage({super.key, required this.requirementId});

  @override
  State<RequirementDetailPage> createState() => _RequirementDetailPageState();
}

class _RequirementDetailPageState extends State<RequirementDetailPage> {
  final MyMap _mapController = MyMap();
  late DetailInfo? _requirementDetail;

  Future<bool> initRequirementDetailPage() async {
    //이 페이지에서 쓸 맵 컨트롤러를 초기화한다.
    bool result = await _mapController.initMapOnRequestDetail();
    if (result == false) return false;

    //요청 세부사항을 가져온다.
    _requirementDetail =
        await RequirementApi.getRequirementDetail(id: widget.requirementId);
    if (_requirementDetail == null) return false;

    //요청자의 좌표를 표시한다.
    _mapController.marking(
      _requirementDetail!.careLoaction.latitude,
      _requirementDetail!.careLoaction.longitude,
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("request detail page")),
      body: FutureBuilder(
        future: initRequirementDetailPage(),
        builder: buildRequirementDetail,
      ),
    );
  }

  Widget buildRequirementDetail(BuildContext context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError || snapshot.data == false) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }

    //TODO:리스트에서 이미지오류날때 이거쓰삼
    dynamic image = _requirementDetail!.dogImage == null
        ? const AssetImage('assets/images/profile_test.png')
        : MemoryImage(_requirementDetail!.dogImage!);
    String careType = _requirementDetail!.careType;
    String description = _requirementDetail!.description;
    int userId = _requirementDetail!.userId;
    int dogId = _requirementDetail!.dogId;
    String reward = _requirementDetail!.reward.toString();
    String status = _requirementDetail!.status;

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
              target: _requirementDetail!.careLoaction,
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

              return Card(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: height / 2,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: CircleAvatar(
                                maxRadius: (height / 4),
                                backgroundImage: image,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(children: [
                            Text('종류 : $careType'),
                            Text('보상 : $reward'),
                            Text('현재 $status'),
                          ]),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(children: [
                            ElevatedButton(
                              onPressed: () {
                                context.go(
                                    '${RouterPath.userProfile}?userId=$userId&requirementId=${widget.requirementId}');
                              },
                              child: const Text('owner'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.go(
                                    '${RouterPath.dogProfile}?dogId=$dogId&requirementId=${widget.requirementId}');
                              },
                              child: const Text('dog'),
                            ),
                          ]),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: width,
                      height: (height / 2.5),
                      child: Card.outlined(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(description),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        ElevatedButton(
            onPressed: () async {
              await ApplicationApi.apply(widget.requirementId)
                  .then((bool result) {
                _showResult(context, result);
              });
            },
            child: const Text('apply')),
      ],
    );
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
                    context.read<InfinitList>().clearMyApplicationOnly();
                    await context
                        .read<InfinitList>()
                        .updateMyApplicationList()
                        .then((_) {
                      context.go(RouterPath.allRequirement);
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

// my application page
class MyApplicationListPage extends StatelessWidget {
  const MyApplicationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("my application")),
      body: FutureBuilder(
        future: context.read<InfinitList>().updateMyApplicationList(),
        builder: buildMyApplicationList,
      ),
    );
  }

  Widget buildMyApplicationList(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return const Center(child: Text('error!'));
    }

    return ListView.builder(
        itemCount: context.watch<InfinitList>().myApplicationList.length,
        itemBuilder: (BuildContext context, int index) {
          if (index ==
              context.watch<InfinitList>().myApplicationList.length - 3) {
            context.read<InfinitList>().updateMyApplicationList();
          }

          var image = context.watch<InfinitList>().myApplicationList[index]
                      ['image'] ==
                  null
              ? Image.asset('assets/images/empty_image.png')
              : Image.memory(base64Decode(context
                  .read<InfinitList>()
                  .myApplicationList[index]['image']));
          int id = context.watch<InfinitList>().myApplicationList[index]['id'];
          String careType =
              context.watch<InfinitList>().myApplicationList[index]['careType'];
          String time =
              context.watch<InfinitList>().myApplicationList[index]['time'];
          String breed =
              context.watch<InfinitList>().myApplicationList[index]['breed'];
          String status =
              context.watch<InfinitList>().myApplicationList[index]['status'];

          return ListTile(
            leading: image,
            title: Text('$breed\t$careType'),
            subtitle: Text(time),
            trailing: Text(status),
            onTap: () => context
                .go('${RouterPath.requirementDetail}?applicatgionId=$id'),
          );
        });
  }
}

class MyApplicationDetailPage extends StatelessWidget {
  final int applicationId;
  const MyApplicationDetailPage({super.key, required this.applicationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my application detail'),
      ),
      body: FutureBuilder(
        future: ApplicationApi.getApplicationDetail(applicationId),
        builder: (BuildContext context, AsyncSnapshot<DetailInfo?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.data == null || snapshot.hasError) {
            return const Text('data err');
          }
          return Text('${snapshot.data}');
        },
      ),
    );
  }
}
