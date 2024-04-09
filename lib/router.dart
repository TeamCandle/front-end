//dependencies
import 'package:flutter/material.dart';
import 'package:flutter_doguber_frontend/pages/profilepage.dart';
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
      builder: (BuildContext context, GoRouterState state) => const LogInPage(),
      routes: [
        GoRoute(
            path: 'home',
            builder: (BuildContext context, GoRouterState state) {
              return const HomePage();
            },
            routes: [
              GoRoute(
                path: 'user_profile',
                builder: (BuildContext context, GoRouterState state) {
                  return const UserProfilePage();
                },
                routes: [
                  GoRoute(
                      path: 'my_review',
                      builder: (BuildContext context, GoRouterState state) {
                        return const MyReviewPage();
                      }),
                  GoRoute(
                      path: 'dog_profile',
                      builder: (BuildContext context, GoRouterState state) {
                        return const DogProfilePage();
                      }),
                  GoRoute(
                      path: 'dog_registration',
                      builder: (BuildContext context, GoRouterState state) {
                        return const DogRegistrationPage();
                      }),
                ],
              ),
              GoRoute(
                path: 'match',
                builder: (BuildContext context, GoRouterState state) {
                  return const MatchPage();
                },
              )
            ]),
      ],
    ),
  ],
);
