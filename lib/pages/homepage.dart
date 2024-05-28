import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';

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
            onPressed: () => context.go(RouterPath.matching),
            child: const Text('match'),
          ),
          ElevatedButton(onPressed: () {}, child: const Text("community")),
          ElevatedButton(onPressed: () {}, child: const Text("premium")),
          ElevatedButton(
            onPressed: () => context.go(RouterPath.myProfile),
            child: const Text("profile"),
          ),
        ]),
      ),
    );
  }
}
