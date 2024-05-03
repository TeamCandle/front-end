//dependency
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//files
import '../router.dart';

class MatchPage extends StatelessWidget {
  const MatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('match page')),
      body: Center(
          child: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                context.go(RouterPath.requestRegistration);
              },
              child: const Text("regist")),
          ElevatedButton(
              onPressed: () {
                context.go(RouterPath.requestSearch);
              },
              child: const Text("search")),
          ElevatedButton(
              onPressed: () {
                context.go(RouterPath.matchLog);
              },
              child: const Text("match log")),
          ElevatedButton(
              onPressed: () {
                context.go(RouterPath.chatting);
              },
              child: const Text("chat")),
        ],
      )),
    );
  }
}

class RequestRegistrationPage extends StatelessWidget {
  const RequestRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("registraion page")),
      body: const Center(child: Text("request regist")),
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
      body: const Center(child: Text("equest registration form")),
    );
  }
}

class RequestSearchPage extends StatelessWidget {
  const RequestSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("request search page")),
      body: const Center(child: Text("request search")),
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
