//dependencies
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//files
import 'pages/homepage.dart';
import 'pages/matchpage.dart';
import 'pages/loginpage.dart';
import 'pages/profilepage.dart';

//화면이동 담당 파일.
//생략 항목(무시해도 됨) routes: <RouteBase>[...

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
                  return const ProfilePage();
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
                        var dogId = state.uri.queryParameters['dogId'];
                        int dogIdInt;
                        if (dogId == null) {
                          return ErrorPage();
                        }
                        try {
                          dogIdInt = int.parse(dogId);
                        } catch (e) {
                          return ErrorPage();
                        }
                        return DogProfilePage(dogId: dogIdInt);
                      }),
                  GoRoute(
                      path: 'dog_registration',
                      builder: (BuildContext context, GoRouterState state) {
                        return const DogRegistrationPage();
                      }),
                  GoRoute(
                      path: 'modify_myprofile',
                      builder: (BuildContext context, GoRouterState state) {
                        return ProfileModifyPage();
                      }),
                ],
              ),
              GoRoute(
                  path: 'matching',
                  builder: (BuildContext context, GoRouterState state) {
                    return const MatchingPage();
                  },
                  routes: [
                    GoRoute(
                      path: 'request_detail',
                      builder: (BuildContext context, GoRouterState state) {
                        return const RequestDetailPage();
                      },
                      routes: [
                        GoRoute(
                          path: 'apply_success',
                          builder: (BuildContext context, GoRouterState state) {
                            return const ApplySuccessPage();
                          },
                        ),
                      ],
                    ),
                    GoRoute(
                        path: 'my_request_list',
                        builder: (BuildContext context, GoRouterState state) {
                          return const MyRequestListPage();
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
                      path: 'my_application_list',
                      builder: (BuildContext context, GoRouterState state) {
                        return const MyApplicationListPage();
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
                    GoRoute(
                      path: 'request_search',
                      builder: (BuildContext context, GoRouterState state) {
                        return const RequestSearchPage();
                      },
                    ),
                  ])
            ]),
      ],
    ),
  ],
);

class ErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Error')),
      body: Center(child: Text('Dog ID is missing')),
    );
  }
}
