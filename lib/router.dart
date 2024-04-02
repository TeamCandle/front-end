//dependencies
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//files
import 'pages/homepage.dart';
import 'pages/matchpage.dart';
import 'pages/loginpage.dart';

//화면이동 담당 파일.
//생략 항목(무시해도 됨)
//routes: <RouteBase>[...

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const LogInPage();
      },
      routes: [
        GoRoute(
          path: 'match',
          builder: (BuildContext context, GoRouterState state) {
            return const MatchPage();
          },
        ),
      ],
    ),
  ],
);
