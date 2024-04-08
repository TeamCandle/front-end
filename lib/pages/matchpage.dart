import 'package:flutter/material.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('match page')),
      body: Center(
          child: Column(
        children: [
          ElevatedButton(onPressed: () {}, child: const Text("regist")),
          ElevatedButton(onPressed: () {}, child: const Text("search")),
          ElevatedButton(onPressed: () {}, child: const Text("match log")),
          ElevatedButton(onPressed: () {}, child: const Text("chat")),
        ],
      )),
    );
  }
}
