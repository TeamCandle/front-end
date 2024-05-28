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

//search request from all request list
//apply specific request

class AllRequestPage extends StatefulWidget {
  const AllRequestPage({super.key});

  @override
  State<AllRequestPage> createState() => _AllRequestPageState();
}

class _AllRequestPageState extends State<AllRequestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("all request")),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(children: [
              Text('search bar'),
              Spacer(),
              Text('fiter button with drawer'),
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
                      return Card(
                          child: Text(
                              '$index : ${context.watch<InfinitList>().allRequestList[index]['careType']}'));
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
  const RequestDetailPage({super.key});

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  final MyMap _myMap = MyMap();
  late LatLng initLocation = LatLng(10.00, 10.00);

  @override
  void initState() {
    super.initState();
    _myMap.setUpMapOnRequestDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("request detail page")),
      body: Stack(children: [
        FutureBuilder(
            future: _myMap.setUpMapOnRequestDetail(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              return GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _myMap.setMapController(ctrl: controller);
                },
                initialCameraPosition: CameraPosition(
                  target: _myMap.myLocation!,
                  zoom: 12,
                ),
                markers: _myMap.markers,
              );
            }),
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
      ]),
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
