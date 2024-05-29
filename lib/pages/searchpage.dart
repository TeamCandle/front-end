//dependency
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
          ],
        ),
      ),
    );
  }
}

// single request detail
class RequestDetailPage extends StatefulWidget {
  final int requestId;
  const RequestDetailPage({super.key, required this.requestId});

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  //리퀘디테일
  //맵컨트롤러

  final MyMap _mapController = MyMap();
  late RequirementDetail? _requirementDetail;

  Future<bool> initRequestDetailPage() async {
    bool result = await _mapController.initMapOnRequestDetail();
    if (result == false) return false;
    _requirementDetail =
        await RequirementApi.getRequirementDetail(id: widget.requestId);
    if (_requirementDetail == null) return false;
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

            return Stack(children: [
              GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController.setMapController(ctrl: controller);
                },
                initialCameraPosition: CameraPosition(
                  target: _requirementDetail!.careLoaction,
                  zoom: 30,
                ),
                markers: _mapController.markers,
              ),
              Center(
                  child: Column(
                children: [
                  const Spacer(),
                  Card.outlined(
                    child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('check'),
                                  content: const Text('are you sure?'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        context.go(RouterPath.applySuccess);
                                      },
                                      child: const Text("ok"),
                                    )
                                  ],
                                );
                              });
                        },
                        child: const Text('apply')),
                  ),
                ],
              )),
            ]);
          }),
    );
  }
}

//apply
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

class MyApplicationListPage extends StatelessWidget {
  const MyApplicationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("my application")),
      body: const Center(
        child: Text("my application list"),
      ),
    );
  }
}
