import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void nothing() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('home page')),
      body: Center(
        child: Column(children: [
          ElevatedButton(
            onPressed: () => context.go('/home/match'),
            child: const Text('match'),
          ),
          ElevatedButton(onPressed: nothing, child: const Text("community")),
          ElevatedButton(onPressed: nothing, child: const Text("premium")),
          ElevatedButton(
            onPressed: () => context.go("/home/user_profile"),
            child: const Text("profile"),
          ),
        ]),
      ),
    );
  }
}
