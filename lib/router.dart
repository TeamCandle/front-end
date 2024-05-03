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

class RouterPath {
  static String home = '/home';

  //profile tree
  static String myProfile = '/home/my_profile';
  static String myReview = '/home/my_profile/my_review';
  static String myDogProfile = '/home/my_profile/dog_profile';
  static String myDogRegistraion = '/home/my_profile/dog_registration';

  //match tree
  static String match = '/home/match';
  static String requestRegistration = '/home/match/request_registration';
  static String requestRegistrationForm =
      '/home/match/request_registration/form';
  static String requestSearch = '/home/match/request_search';
  static String matchLog = '/home/match/match_log';
  static String chatting = '/home/match/chatting';
}

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const LogInPage();
      },
      routes: [
        GoRoute(
            path: 'home',
            builder: (BuildContext context, GoRouterState state) {
              return const HomePage();
            },
            routes: [
              GoRoute(
                path: 'my_profile',
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
                  routes: [
                    GoRoute(
                        path: 'request_registration',
                        builder: (BuildContext context, GoRouterState state) {
                          return const RequestRegistrationPage();
                        },
                        routes: [
                          GoRoute(
                            path: 'form',
                            builder:
                                (BuildContext context, GoRouterState state) {
                              return const RequestRegistrationFormPage();
                            },
                          ),
                        ]),
                    GoRoute(
                      path: 'request_search',
                      builder: (BuildContext context, GoRouterState state) {
                        return const RequestSearchPage();
                      },
                    ),
                    GoRoute(
                      path: 'match_log',
                      builder: (BuildContext context, GoRouterState state) {
                        return const MatchLogPage();
                      },
                    ),
                    GoRoute(
                      path: 'chatting',
                      builder: (BuildContext context, GoRouterState state) {
                        return const ChattingPage();
                      },
                    ),
                  ])
            ]),
      ],
    ),
  ],
);
