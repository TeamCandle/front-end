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
              )),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list_rounded),
              ),
            ]),
            Expanded(
              child: FutureBuilder(
                future: context.read<InfinitList>().updateAllRequestList(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('error!'));
                  }

                  return ListView.builder(
                    itemCount:
                        context.watch<InfinitList>().allRequestList.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (index ==
                          context.watch<InfinitList>().allRequestList.length -
                              3) {
                        context.read<InfinitList>().updateAllRequestList();
                      }

                      return ListTile(
                        leading: Image.asset('assets/images/empty_image.png'),
                        title: Text(context
                            .watch<InfinitList>()
                            .allRequestList[index]['careType']),
                        subtitle: Text(
                            '${context.watch<InfinitList>().allRequestList[index]['time']} / ${context.watch<InfinitList>().allRequestList[index]['breed']}'),
                        trailing: Text(context
                            .watch<InfinitList>()
                            .allRequestList[index]['status']),
                        onTap: () => context.go(
                            '${RouterPath.requestDetail}?requestId=${context.read<InfinitList>().allRequestList[index]['id']}'),
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => context.go(RouterPath.myApplicationList),
              child: const Text('my applications'),
            ),
          ],
        ),
      ),
    );
  }
}

// request detail -> success page
class RequestDetailPage extends StatefulWidget {
  final int requestId;
  const RequestDetailPage({super.key, required this.requestId});

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  final MyMap _mapController = MyMap();
  late RequirementDetail? _requirementDetail;

  Future<bool> initRequestDetailPage() async {
    //init map at this moment
    bool result = await _mapController.initMapOnRequestDetail();
    if (result == false) return false;

    //get request detail
    _requirementDetail =
        await RequirementApi.getRequirementDetail(id: widget.requestId);
    if (_requirementDetail == null) return false;

    //mark target location
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
        future: initRequestDetailPage(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == false) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

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
                    zoom: 30,
                  ),
                  markers: _mapController.markers,
                ),
              ),
              Expanded(
                flex: 1,
                child: Card.outlined(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: _requirementDetail!.dogImage == null
                                  ? Image.asset(
                                      'assets/images/profile_test.png')
                                  : Image.memory(_requirementDetail!.dogImage!),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(children: [
                                Text(_requirementDetail!.careType),
                                Text(
                                    '${_requirementDetail!.reward.toString()} 원'),
                                Text(_requirementDetail!.status),
                              ]),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(child: const Text('description')),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('check'),
                            content: const Text('are you sure?'),
                            actions: [
                              ElevatedButton(
                                onPressed: () async {
                                  await ApplicationApi.apply(widget.requestId)
                                      .then((bool result) {
                                    if (result == true) {
                                      context.go(RouterPath.allRequest);
                                    }
                                  });
                                },
                                child: const Text("ok"),
                              )
                            ],
                          );
                        });
                  },
                  child: const Text('apply')),
            ],
          );
        },
      ),
    );
  }
}

class ApplySuccessPage extends StatelessWidget {
  const ApplySuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("success page")),
      body: Center(
          child: ElevatedButton(
        onPressed: () {
          context.go(RouterPath.matching);
        },
        child: const Text('success'),
      )),
    );
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
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('something wrong..');
          }

          return ListView.builder(
              itemCount: context.watch<InfinitList>().myApplicationList.length,
              itemBuilder: (BuildContext context, int index) {
                if (index ==
                    context.watch<InfinitList>().myApplicationList.length - 3) {
                  context.read<InfinitList>().updateMyApplicationList();
                }

                return ListTile(
                  leading: Image.asset('assets/images/empty_image.png'),
                  title: Text(context
                      .watch<InfinitList>()
                      .myApplicationList[index]['careType']),
                  subtitle: Text(
                      '${context.watch<InfinitList>().myApplicationList[index]['time']} / ${context.watch<InfinitList>().myApplicationList[index]['breed']}'),
                  trailing: Text(context
                      .watch<InfinitList>()
                      .myApplicationList[index]['status']),
                  onTap: () {
                    context.go(
                        '${RouterPath.myApplicationDetail}?applicationId=${context.read<InfinitList>().myApplicationList[index]['id']}');
                  },
                );
              });
        },
      ),
    );
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
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.data == null || snapshot.hasError) {
            return const Text('data err');
          }
          var data = jsonDecode(snapshot.data!.body);
          return Text('$data');
        },
      ),
    );
  }
}
