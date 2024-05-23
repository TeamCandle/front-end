//dependency
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//files
import '../constants.dart';
import '../testdata.dart';
import '../mymap.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('match page'),
        actions: [
          ElevatedButton(
              onPressed: () => context.go(RouterPath.requestSearch),
              child: const Icon(Icons.search)),
          ElevatedButton(onPressed: () {}, child: const Icon(Icons.filter_list))
        ],
      ),
      body: ListView.builder(
        itemCount: testAllRequireList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(testAllRequireList[index]["careType"]),
            onTap: () {
              context.go(RouterPath.requestDetail);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.abc), label: 'match log'),
          BottomNavigationBarItem(icon: Icon(Icons.abc), label: 'my apply'),
          BottomNavigationBarItem(icon: Icon(Icons.abc), label: 'my request'),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
              context.go(RouterPath.matchLog);
              break;
            case 1:
              context.go(RouterPath.myApplicationList);
              break;
            case 2:
              context.go(RouterPath.myRequestList);
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(RouterPath.chatting);
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}

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

class MyRequestListPage extends StatelessWidget {
  const MyRequestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("my request list")),
      body: const Center(child: Text("my request list")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(RouterPath.requestRegistrationForm);
        },
        child: const Text("+"),
      ),
    );
  }
}

class RequestRegistrationFormPage extends StatelessWidget {
  const RequestRegistrationFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("request registration form page")),
      body: const Center(child: Text("request registration form")),
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

class MatchLogPage extends StatelessWidget {
  const MatchLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("match log page")),
      body: const Center(child: Text("match log")),
    );
  }
}

class ChattingPage extends StatelessWidget {
  const ChattingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("chatting page")),
      body: const Center(child: Text("chatting")),
    );
  }
}

class RequestSearchPage extends StatelessWidget {
  const RequestSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("request search page")),
      body: const Center(child: Text("request list")),
    );
  }
}
