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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
  late DetailInfo? _requirementDetail;
  late final GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("상세 정보")),
      body: FutureBuilder(
        future: RequirementApi.getRequirementDetail(widget.requirementId),
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

    _requirementDetail = snapshot.data;
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
    LatLng location = _requirementDetail!.careLoaction;
    context.read<LocationInfo>().setOnlySingleMarker(location);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: buildGoogleMap()),
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
                                Text(status),
                              ],
                            ),
                            buildInfoButton(context, userId, dogId),
                          ],
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
                        padding: const EdgeInsets.all(8),
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

  Column buildInfoButton(BuildContext context, int userId, int dogId) {
    return Column(children: [
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
    ]);
  }

  GoogleMap buildGoogleMap() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: _requirementDetail!.careLoaction,
        zoom: 15,
      ),
      markers: context.watch<LocationInfo>().markers,
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
      appBar: AppBar(title: Text("내 신청 목록")),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
  late DetailInfo? _applicationDetail;
  late final GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('상세 정보')),
      body: FutureBuilder(
        future: ApplicationApi.getApplicationDetail(widget.applicationId),
        builder: buildDetail,
      ),
    );
  }

  Widget buildDetail(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError || snapshot.data == null) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }

    _applicationDetail = snapshot.data!;
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
    LatLng location = _applicationDetail!.careLoaction;
    context.read<LocationInfo>().setOnlySingleMarker(location);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: buildGoogleMap()),
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
                                Text(status),
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
                              buildInfoButton(context, dogId),
                            ]),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: buildAddress(context, location),
                      ),
                      Center(
                        child: customCard(
                          width: width,
                          height: (width / 4),
                          child: Text(description),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await ApplicationApi.cancel(applicationId).then(
                                  (bool result) =>
                                      _showResult(context, result));
                            },
                            child: const Text('신청 취소')),
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

  Center buildInfoButton(BuildContext context, int dogId) {
    return Center(
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
    );
  }

  GoogleMap buildGoogleMap() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: _applicationDetail!.careLoaction,
        zoom: 15,
      ),
      markers: context.watch<LocationInfo>().markers,
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
