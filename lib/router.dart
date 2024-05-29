//dependencies
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//files
import 'pages/homepage.dart';
import 'pages/matchpage.dart';
import 'pages/loginpage.dart';
import 'pages/profilepage.dart';
import 'pages/searchpage.dart';
import 'pages/registpage.dart';

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
              path: 'all_request',
              builder: (BuildContext context, GoRouterState state) {
                return const AllRequestPage();
              },
              routes: [
                GoRoute(
                  path: 'request_detail',
                  builder: (BuildContext context, GoRouterState state) {
                    var requestId = state.uri.queryParameters['requestId'];
                    if (requestId == null) {
                      return ErrorPage();
                    }

                    int requestIdInt;
                    try {
                      requestIdInt = int.parse(requestId);
                    } catch (e) {
                      return ErrorPage();
                    }
                    return RequestDetailPage(requestId: requestIdInt);
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'my_requirement_list',
              builder: (BuildContext context, GoRouterState state) {
                return const MyRequestListPage();
              },
              routes: [],
            ),
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
            ),
          ],
        ),
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

class RouterPath {
  static const String home = '/home';

  //profile tree
  static const String myProfile = '/home/my_profile';
  static const String myReview = '/home/my_profile/my_review';
  static const String myDogProfile = '/home/my_profile/dog_profile';
  static const String myDogRegistraion = '/home/my_profile/dog_registration';
  static const String profileModify = '/home/my_profile/modify_myprofile';

  //search tree
  static const String allRequest = '/home/all_request';
  static const String requestDetail = '/home/all_request/request_detail';

  //my requirement tree
  static const String myRequirement = '/home/my_requirement_list';

  //match tree
  static const String matching = '/home/matching';

  static const String applySuccess =
      '/home/matching/request_detail/apply_success';
  static const String myRequestList = '/home/matching/my_request_list';
  static const String requestRegistrationForm =
      '/home/matching/my_request_list/form';
  static const String myApplicationList = "/home/matching/my_application_list";
  static const String matchLog = '/home/matching/match_log';
  static const String chatting = '/home/matching/chatting';
  static const String requestSearch = '/home/matching/request_search';
}
