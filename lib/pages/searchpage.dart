//dependency
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_doguber_frontend/datamodels.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
//files
import '../constants.dart';
import '../customwidgets.dart';
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
    context.read<InfiniteList>().releaseList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("모든 요청사항")),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(
                child: customSearchField(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Text',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Color(0xFFa2e1a6)),
                ),
                icon: const Icon(Icons.filter_list_rounded),
              ),
            ]),
            Expanded(
              child: FutureBuilder(
                future: context.read<InfiniteList>().updateAllRequestList(),
                builder: buildAllRequirementList,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
        child: ElevatedButton(
          onPressed: () => context.go(RouterPath.myApplication),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(48, 0, 48, 0),
            child: Text('내 신청 현황'),
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
    );
  }

  Widget buildAllRequirementList(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return const Center(child: Text('error!'));
    }

    return ListView.builder(
      itemCount: context.watch<InfiniteList>().allRequestList.length,
      itemBuilder: (BuildContext context, int index) {
        if (index == context.watch<InfiniteList>().allRequestList.length - 3) {
          context.read<InfiniteList>().updateAllRequestList();
        }

        dynamic image = context.watch<InfiniteList>().allRequestList[index]
                    ['image'] ==
                null
            ? const AssetImage('assets/images/empty_image.png')
            : MemoryImage(base64Decode(
                context.read<InfiniteList>().allRequestList[index]['image']));
        int id = context.read<InfiniteList>().allRequestList[index]['id'];
        String careType =
            context.watch<InfiniteList>().allRequestList[index]['careType'];
        String time =
            context.watch<InfiniteList>().allRequestList[index]['time'];
        String breed =
            context.watch<InfiniteList>().allRequestList[index]['breed'];
        String status =
            context.watch<InfiniteList>().allRequestList[index]['status'];

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
              RouterPath.allRequirementDetail,
              extra: {'detailId': id},
            );
          },
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

              return customContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: width,
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: (width / 10),
                            backgroundImage: image,
                          ),
                          Column(
                            children: [
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
                            ],
                          ),
                          Column(children: [
                            Center(
                              child: ElevatedButton(
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
                            ),
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(0),
                                ),
                                onPressed: () {
                                  context.push(
                                    RouterPath.dogProfile,
                                    extra: {'dogId': dogId},
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                                  child: Text('강아지'),
                                ),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    Center(
                      child: customCard(
                        width: width,
                        height: (height / 2.5),
                        child: Text(description),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: ElevatedButton(
            onPressed: () async {
              await ApplicationApi.apply(widget.requirementId)
                  .then((bool result) {
                _showResult(context, result);
              });
            },
            child: const Text('신청하기'),
          ),
        ),
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

// my application page
class MyApplicationListPage extends StatelessWidget {
  const MyApplicationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("my application")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder(
          future: context.read<InfiniteList>().updateMyApplicationList(),
          builder: buildMyApplicationList,
        ),
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
        itemCount: context.watch<InfiniteList>().myApplicationList.length,
        itemBuilder: (BuildContext context, int index) {
          if (index ==
              context.watch<InfiniteList>().myApplicationList.length - 3) {
            context.read<InfiniteList>().updateMyApplicationList();
          }

          var imageData =
              context.watch<InfiniteList>().myApplicationList[index]['image'];
          dynamic image = imageData == null
              ? const AssetImage('assets/images/empty_image.png')
              : MemoryImage(base64Decode(imageData));
          int id = context.watch<InfiniteList>().myApplicationList[index]['id'];
          String careType = context
              .watch<InfiniteList>()
              .myApplicationList[index]['careType'];
          String time =
              context.watch<InfiniteList>().myApplicationList[index]['time'];
          String breed =
              context.watch<InfiniteList>().myApplicationList[index]['breed'];
          String status =
              context.watch<InfiniteList>().myApplicationList[index]['status'];

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
                RouterPath.myApplicationDetail,
                extra: {'detailId': id},
              );
            },
          );
        });
  }
}

class MyApplicationDetailPage extends StatefulWidget {
  final int applicationId;
  const MyApplicationDetailPage({super.key, required this.applicationId});

  @override
  State<MyApplicationDetailPage> createState() =>
      _MyApplicationDetailPageState();
}

class _MyApplicationDetailPageState extends State<MyApplicationDetailPage> {
  final MyMap _mapController = MyMap();
  late DetailInfo? _applicationDetail;

  Future<bool> initRequirementDetailPage() async {
    //이 페이지에서 쓸 맵 컨트롤러를 초기화한다.
    bool result = await _mapController.initMapOnRequestDetail();
    if (result == false) return false;

    //요청 세부사항을 가져온다.
    _applicationDetail =
        await ApplicationApi.getApplicationDetail(widget.applicationId);
    if (_applicationDetail == null) return false;

    //요청자의 좌표를 표시한다.
    _mapController.marking(
      _applicationDetail!.careLoaction.latitude,
      _applicationDetail!.careLoaction.longitude,
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('상세 정보')),
      body: FutureBuilder(
        future: initRequirementDetailPage(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == false) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          //TODO:리스트에서 이미지오류날때 이거쓰삼
          int applicationId = _applicationDetail!.detailId;
          dynamic image = _applicationDetail!.dogImage == null
              ? const AssetImage('assets/images/profile_test.png')
              : MemoryImage(_applicationDetail!.dogImage!);
          String careType = _applicationDetail!.careType;
          String description = _applicationDetail!.description;
          int userId = _applicationDetail!.userId;
          int dogId = _applicationDetail!.dogId;
          String reward = _applicationDetail!.reward.toString();
          String status = _applicationDetail!.status;

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
                    target: _applicationDetail!.careLoaction,
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

                    return customContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: width,
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: (width / 10),
                                  backgroundImage: image,
                                ),
                                Column(
                                  children: [
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
                                  ],
                                ),
                                Column(children: [
                                  Center(
                                    child: ElevatedButton(
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
                                        padding:
                                            EdgeInsets.fromLTRB(25, 0, 25, 0),
                                        child: Text('보호자'),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(0),
                                      ),
                                      onPressed: () {
                                        context.push(
                                          RouterPath.dogProfile,
                                          extra: {'dogId': dogId},
                                        );
                                      },
                                      child: const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(25, 0, 25, 0),
                                        child: Text('강아지'),
                                      ),
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                          Center(
                            child: customCard(
                              width: width,
                              height: (height / 2.5),
                              child: Text(description),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: ElevatedButton(
                    onPressed: () async {
                      await ApplicationApi.cancel(applicationId)
                          .then((bool result) => _showResult(context, result));
                    },
                    child: const Text('신청 취소')),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<dynamic> _showResult(BuildContext context, bool result) {
    String title;
    String content;
    if (result == true) {
      title = '신청 취소됨';
      content = '해당 건에 대한 신청이 취소되었습니다';
    } else {
      title = '취소 완료';
      content = '이미 해당 건에 대한 신청이 취소되었습니다';
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
                      context.go(RouterPath.myApplication);
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
