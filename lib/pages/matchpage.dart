import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  void nothing() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('match page')),
      body: Center(
          child: Column(
        children: [
          ElevatedButton(onPressed: nothing, child: const Text("regist")),
          ElevatedButton(onPressed: nothing, child: const Text("search")),
          ElevatedButton(onPressed: nothing, child: const Text("match log")),
          ElevatedButton(onPressed: nothing, child: const Text("chat")),
        ],
      )),
    );
  }
}
