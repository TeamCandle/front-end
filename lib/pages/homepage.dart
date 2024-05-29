import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';
import '../router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('home page')),
      body: Center(
        child: Column(children: [
          ElevatedButton(
            onPressed: () {},
            child: const Text("current process & chatting"),
          ),
          ElevatedButton(
            onPressed: () => context.go(RouterPath.allRequest),
            child: const Text('goto search page and apply'),
            //all request list, my apply list
          ),
          ElevatedButton(
            onPressed: () {
              context.go(RouterPath.myRequirement);
            },
            child: const Text("regist my request"),
            //my registration list, regist my request
          ),
          ElevatedButton(onPressed: () {}, child: const Text("premium")),
          ElevatedButton(onPressed: () {}, child: const Text("community")),
          ElevatedButton(
            onPressed: () {},
            child: const Text("look my matching log"),
            //match log list
          ),
          ElevatedButton(
            onPressed: () => context.go(RouterPath.myProfile),
            child: const Text("profile"),
          ),
        ]),
      ),
    );
  }
}
