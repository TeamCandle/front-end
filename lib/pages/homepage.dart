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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
        title: const Text('home page'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(3, 0, 3, 8),
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
              decoration: BoxDecoration(
                color: Color(0xFF63A98E),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("current process & chatting"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF63A98E)),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(3, 0, 3, 8),
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
              decoration: BoxDecoration(
                color: Color(0xFF63A98E),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => context.go(RouterPath.allRequirement),
                child: const Text('goto search page and apply'),
                //all request list, my apply list
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF63A98E)),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(3, 0, 3, 8),
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
              decoration: BoxDecoration(
                color: Color(0xFF63A98E),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  context.go(RouterPath.myRequirement);
                },
                child: const Text("regist my request"),
                //my registration list, regist my request
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF63A98E)),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(3, 0, 3, 8),
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
              decoration: BoxDecoration(
                color: Color(0xFF63A98E),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("premium"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF63A98E)),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(3, 0, 3, 8),
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
              decoration: BoxDecoration(
                color: Color(0xFF63A98E),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("community"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF63A98E)),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(3, 0, 3, 8),
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
              decoration: BoxDecoration(
                color: Color(0xFF63A98E),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => context.go(RouterPath.matchLog),
                child: const Text("my match log"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF63A98E)),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(3, 0, 3, 8),
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
              decoration: BoxDecoration(
                color: Color(0xFF63A98E),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => context.go(RouterPath.myProfile),
                child: const Text("profile"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF63A98E)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
