//dependency
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_doguber_frontend/datamodels.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
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
  Future<bool> initialize() async {
    await context
        .read<LocationInfo>()
        .getMyLocation()
        .then((LatLng? myLocation) async {
      if (myLocation == null) return false;
      await context.read<InfiniteList>().updateAllRequestList();
      //TODO: 여기에 myLocation 넣어서 마무리
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("모든 요청사항"),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: ElevatedButton(
              onPressed: () => context.go(RouterPath.allRequirementFilter),
              child: const Icon(Icons.filter_list_rounded),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: FutureBuilder(
          future: initialize(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('error!'));
            }

            return buildAllRequirementList(context);
          },
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

  Widget buildAllRequirementList(BuildContext context) {
    var allRequestList = context.watch<InfiniteList>().allRequestList;

    return ListView.builder(
      itemCount: allRequestList.length,
      itemBuilder: (BuildContext context, int index) {
        // if (index == allRequestList.length - 3) {
        //   context.read<InfiniteList>().updateAllRequestList();
        // }

        dynamic image = allRequestList[index]['image'] == null
            ? const AssetImage('assets/images/empty_image.png')
            : MemoryImage(base64Decode(allRequestList[index]['image']));
        int id = allRequestList[index]['id'];
        String careType = allRequestList[index]['careType'];
        String time = allRequestList[index]['time'];
        String breed = allRequestList[index]['breed'];
        String status = allRequestList[index]['status'];

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

//filter page
class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late GoogleMapController _mapController;
  LatLng? _targetLocation;
  LatLng? _myLocation;
  int _sliderValue = 5;
  final List<bool> _sizeValues = [false, false, false];
  String _careValue = CareType.walking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('필터 설정')),
      body: FutureBuilder(
        future: context.read<LocationInfo>().getMyLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('err'));
          }

          _myLocation = snapshot.data!;
          context.read<LocationInfo>().clearMarkers;
          return Column(children: [
            Expanded(
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: _myLocation!,
                  zoom: 15,
                ),
                onTap: (argument) async {
                  _targetLocation = argument;
                  context
                      .read<LocationInfo>()
                      .setOnlySingleMarker(_targetLocation!);
                  await _mapController
                      .animateCamera(CameraUpdate.newLatLng(_targetLocation!));
                },
                markers: context.watch<LocationInfo>().markers,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: buildAddress(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: buildRangeSlider(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: buildSizeToggle(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: buildCareDropdown(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: ElevatedButton(
                        onPressed: () {
                          LatLng? location = _targetLocation ?? _myLocation;
                          String size;
                          if (_sizeValues[0] == true) {
                            size = DogSize.small;
                          } else if (_sizeValues[1] == true) {
                            size = DogSize.medium;
                          } else if (_sizeValues[2] == true) {
                            size = DogSize.large;
                          } else {
                            return;
                          }

                          context.go(
                            RouterPath.allRequirementFiltered,
                            extra: {
                              'targetLocation': location,
                              'radius': _sliderValue,
                              'size': size,
                              'careType': _careValue,
                            },
                          );
                        },
                        child: const Text('설정 완료'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  Widget buildAddress(BuildContext context) {
    if (_targetLocation == null) {
      return customContainer(child: Text(''));
    }
    return customContainer(
      child: FutureBuilder(
        future: context.read<LocationInfo>().getPlaceAddress(
              _targetLocation!.latitude,
              _targetLocation!.longitude,
            ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('');
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Text('something wrong..');
          }
          return Text(snapshot.data!);
        },
      ),
    );
  }

  Widget buildCareDropdown() {
    return customContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('유형'),
          DropdownButton<String>(
            value: _careValue,
            onChanged: (String? value) {
              setState(() => _careValue = value!);
            },
            items: const [
              DropdownMenuItem<String>(
                value: CareType.walking,
                child: Text('산책'),
              ),
              DropdownMenuItem<String>(
                value: CareType.boarding,
                child: Text('이동'),
              ),
              DropdownMenuItem<String>(
                value: CareType.grooming,
                child: Text('미용/단장'),
              ),
              DropdownMenuItem<String>(
                value: CareType.playtime,
                child: Text('훈련/놀아주기'),
              ),
              DropdownMenuItem<String>(
                value: CareType.etc,
                child: Text('기타'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSizeToggle(BuildContext context) {
    return customContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('크기'),
          ToggleButtons(
            isSelected: _sizeValues,
            constraints: BoxConstraints.expand(
                width: MediaQuery.of(context).size.width / 5),
            onPressed: (int index) {
              setState(() {
                for (int i = 0; i < _sizeValues.length; i++) {
                  if (i == index) {
                    _sizeValues[i] = true;
                  } else {
                    _sizeValues[i] = false;
                  }
                }
              });
            },
            children: const <Widget>[
              Text('소형'),
              Text('중형'),
              Text('대형'),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRangeSlider() {
    return customContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('범위   $_sliderValue'),
          Expanded(
            child: Slider(
              value: _sliderValue.toDouble(),
              min: 5,
              max: 10,
              divisions: 5,
              label: _sliderValue.toString(),
              onChanged: (double value) {
                setState(() => _sliderValue = value.round());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilteredListPage extends StatefulWidget {
  final LatLng targetLocation;
  final int radius;
  final String size;
  final String careType;

  const FilteredListPage({
    super.key,
    required this.targetLocation,
    required this.radius,
    required this.size,
    required this.careType,
  });

  @override
  State<FilteredListPage> createState() => _FilteredListPageState();
}

class _FilteredListPageState extends State<FilteredListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("필터링 결과")),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: FutureBuilder(
          future: context.read<InfiniteList>().updateFilteredList(
                widget.targetLocation,
                widget.radius,
                widget.size,
                widget.careType,
              ),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('error!'));
            }

            return buildList(context);
          },
        ),
      ),
    );
  }

  Widget buildList(BuildContext context) {
    var filteredList = context.watch<InfiniteList>().filteredList;

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (BuildContext context, int index) {
        if (index == filteredList.length - 3) {
          context.read<InfiniteList>().updateFilteredList(
                widget.targetLocation,
                widget.radius,
                widget.size,
                widget.careType,
              );
        }

        dynamic image = filteredList[index]['image'] == null
            ? const AssetImage('assets/images/empty_image.png')
            : MemoryImage(base64Decode(filteredList[index]['image']));
        int id = filteredList[index]['id'];
        String careType = filteredList[index]['careType'];
        String time = filteredList[index]['time'];
        String breed = filteredList[index]['breed'];
        String status = filteredList[index]['status'];

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
    context.read<InfiniteList>().clearAllList;
    return Scaffold(
      appBar: AppBar(title: const Text("내 신청 목록")),
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
