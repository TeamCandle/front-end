import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MainApp());
}

GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Home(),
      routes: [
        GoRoute(
          path: 'A',
          builder: (context, state) => A(),
          routes: [
            GoRoute(
              path: 'AA',
              name: 'AA',
              builder: (context, state) => AA(),
            )
          ],
        ),
        GoRoute(
          path: 'B',
          name: 'B',
          builder: (context, state) => B(),
          routes: [
            GoRoute(
              path: 'BB',
              name: 'BB',
              builder: (context, state) => BB(),
            )
          ],
        ),
      ],
    ),
  ],
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      children: [
        Text('home'),
        ElevatedButton(
          onPressed: () => context.go('/A'),
          child: Text('A'),
        ),
        ElevatedButton(
          onPressed: () => context.go('/B'),
          child: Text('B'),
        ),
      ],
    )));
  }
}

class A extends StatelessWidget {
  const A({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      children: [
        Text('A'),
        ElevatedButton(
          onPressed: () => context.pop(),
          child: Text('back'),
        ),
        ElevatedButton(
          onPressed: () => context.goNamed('AA'),
          child: Text('AA'),
        ),
        ElevatedButton(
          onPressed: () => context.go('/B'),
          child: Text('B'),
        ),
      ],
    )));
  }
}

class B extends StatelessWidget {
  const B({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      children: [
        Text('B'),
        ElevatedButton(
          onPressed: () => context.pop(),
          child: Text('back'),
        ),
        ElevatedButton(
          onPressed: () => context.go('/A'),
          child: Text('A'),
        ),
        ElevatedButton(
          onPressed: () => context.go('/B/BB'),
          child: Text('BB'),
        ),
      ],
    )));
  }
}

class AA extends StatelessWidget {
  const AA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      children: [
        Text('AA'),
        ElevatedButton(
          onPressed: () => context.pop(),
          child: Text('back'),
        ),
        ElevatedButton(
          onPressed: () => context.go('/A'),
          child: Text('A'),
        ),
        ElevatedButton(
          onPressed: () => context.push('/B/BB'),
          child: Text('BB'),
        ),
      ],
    )));
  }
}

class BB extends StatelessWidget {
  const BB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      children: [
        Text('BB'),
        ElevatedButton(
          onPressed: () => context.pop(),
          child: Text('back'),
        ),
        ElevatedButton(
          onPressed: () => context.go('/A/AA'),
          child: Text('AA'),
        ),
        ElevatedButton(
          onPressed: () => context.go('/B'),
          child: Text('B'),
        ),
      ],
    )));
  }
}
