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
import 'constants.dart';

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
          path: 'login_direct',
          builder: (context, state) {
            return const WebViewPage();
          },
        ),
        GoRoute(
          path: 'home',
          builder: (BuildContext context, GoRouterState state) {
            return const HomePage();
          },
          routes: [
            GoRoute(
              path: 'all_requirement_list',
              builder: (BuildContext context, GoRouterState state) {
                return const AllRequestPage();
              },
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (BuildContext context, GoRouterState state) {
                    var id = state.uri.queryParameters['requirementId'];
                    if (id == null) {
                      return ErrorPage(err: 'all_requirement detail query');
                    }

                    int idInt;
                    try {
                      idInt = int.parse(id);
                    } catch (e) {
                      return ErrorPage(err: 'all_requirement detail parsing');
                    }
                    return RequirementDetailPage(requirementId: idInt);
                  },
                  routes: [
                    GoRoute(
                      path: 'user_profile',
                      builder: (BuildContext context, GoRouterState state) {
                        var id = state.uri.queryParameters['userId'];
                        var detailId = state.uri.queryParameters['detailId'];
                        if (id == null || detailId == null) {
                          debugPrint('!!! query null');
                          return ErrorPage(err: 'user_profile detail query');
                        }

                        int idInt;
                        int detailIdInt;
                        try {
                          idInt = int.parse(id);
                          detailIdInt = int.parse(detailId);
                        } catch (e) {
                          debugPrint('!!! parsing error');
                          return ErrorPage(err: 'user_profile detail parse');
                        }
                        return UserProfilePage(
                          userId: idInt,
                          detailId: detailIdInt,
                          type: DetailFrom.requirement,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'dog_profile',
                      builder: (BuildContext context, GoRouterState state) {
                        var id = state.uri.queryParameters['dogId'];
                        var detailId = state.uri.queryParameters['detailId'];
                        if (id == null || detailId == null) {
                          debugPrint('!!! query null');
                          return ErrorPage(err: 'dog_profile detail query');
                        }

                        int idInt;
                        int detailIdInt;
                        try {
                          idInt = int.parse(id);
                          detailIdInt = int.parse(detailId);
                        } catch (e) {
                          return ErrorPage(err: 'dog_profile detail parse');
                        }
                        return UserDogProfile(
                          dogId: idInt,
                          requestId: detailIdInt,
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'my_application_list',
                  builder: (context, state) {
                    return const MyApplicationListPage();
                  },
                  routes: [
                    GoRoute(
                      path: 'detail',
                      builder: (context, state) {
                        var id = state.uri.queryParameters['applicationId'];
                        if (id == null) {
                          return ErrorPage(
                              err: 'my_application_list detail query');
                        }

                        int idInt;
                        try {
                          idInt = int.parse(id);
                        } catch (e) {
                          return ErrorPage(
                              err: 'my_application_list detail parse');
                        }
                        return MyApplicationDetailPage(applicationId: idInt);
                      },
                      routes: [
                        GoRoute(
                          path: 'user_profile',
                          builder: (BuildContext context, GoRouterState state) {
                            var id = state.uri.queryParameters['userId'];
                            var detailId =
                                state.uri.queryParameters['detailId'];
                            if (id == null || detailId == null) {
                              debugPrint('!!! query null');
                              return ErrorPage(
                                  err: 'user_profile detail query');
                            }

                            int idInt;
                            int detailIdInt;
                            try {
                              idInt = int.parse(id);
                              detailIdInt = int.parse(detailId);
                            } catch (e) {
                              debugPrint('!!! parsing error');
                              return ErrorPage(
                                  err: 'user_profile detail parse');
                            }
                            return UserProfilePage(
                              userId: idInt,
                              detailId: detailIdInt,
                              type: DetailFrom.application,
                            );
                          },
                        ),
                        GoRoute(
                          path: 'dog_profile',
                          builder: (BuildContext context, GoRouterState state) {
                            var id = state.uri.queryParameters['dogId'];
                            var detailId =
                                state.uri.queryParameters['detailId'];
                            if (id == null || detailId == null) {
                              debugPrint('!!! query null');
                              return ErrorPage(err: 'dog_profile detail query');
                            }

                            int idInt;
                            int detailIdInt;
                            try {
                              idInt = int.parse(id);
                              detailIdInt = int.parse(detailId);
                            } catch (e) {
                              return ErrorPage(err: 'dog_profile detail parse');
                            }
                            return UserDogProfile(
                              dogId: idInt,
                              requestId: detailIdInt,
                            );
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
            GoRoute(
              path: 'my_requirement_list',
              builder: (BuildContext context, GoRouterState state) {
                return const MyRequestListPage();
              },
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) {
                    var requirementId =
                        state.uri.queryParameters['requirementId'];
                    if (requirementId == null) {
                      return ErrorPage(err: 'my_requirement_list detail query');
                    }

                    int requirementIdInt;
                    try {
                      requirementIdInt = int.parse(requirementId);
                    } catch (e) {
                      return ErrorPage(err: 'my_requirement_list detail parse');
                    }
                    return MyRequirementDetailPage(
                        requirementId: requirementIdInt);
                  },
                ),
                GoRoute(
                  path: 'select_dog',
                  builder: (BuildContext context, GoRouterState state) {
                    return const SelectDogInRequirementPage();
                  },
                  routes: [
                    GoRoute(
                      path: 'registform',
                      builder: (BuildContext context, GoRouterState state) {
                        var dogId = state.uri.queryParameters['dogId'];
                        if (dogId == null) {
                          return ErrorPage(err: 'registform query');
                        }

                        int dogIdInt;
                        try {
                          dogIdInt = int.parse(dogId);
                        } catch (e) {
                          return ErrorPage(err: 'registform parse');
                        }
                        return RequestRegistrationFormPage(dogId: dogIdInt);
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: 'my_profile',
              builder: (BuildContext context, GoRouterState state) {
                return const ProfilePage();
              },
              routes: [
                GoRoute(
                    path: 'review',
                    builder: (BuildContext context, GoRouterState state) {
                      return const MyReviewPage();
                    }),
                GoRoute(
                    path: 'dog_profile',
                    builder: (BuildContext context, GoRouterState state) {
                      var id = state.uri.queryParameters['dogId'];
                      if (id == null) {
                        return ErrorPage(err: 'mydog_profile query');
                      }
                      int idInt;
                      try {
                        idInt = int.parse(id);
                      } catch (e) {
                        return ErrorPage(err: 'mydog_profile parse');
                      }
                      return DogProfilePage(dogId: idInt);
                    }),
                GoRoute(
                    path: 'dog_registration',
                    builder: (BuildContext context, GoRouterState state) {
                      return const DogRegistrationPage();
                    }),
                GoRoute(
                    path: 'modify_myprofile',
                    builder: (BuildContext context, GoRouterState state) {
                      return const ProfileModifyPage();
                    }),
              ],
            ),
            GoRoute(
              path: 'matchingLog',
              builder: (BuildContext context, GoRouterState state) {
                return const MatchingLogPage();
              },
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (BuildContext context, GoRouterState state) {
                    int? id = int.tryParse(
                      state.uri.queryParameters['matchingId']!,
                    );
                    if (id == null) {
                      return const ErrorPage(err: 'parsing err');
                    }
                    return MatchingLogDetailPage(matchingId: id);
                  },
                )
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class ErrorPage extends StatelessWidget {
  final String err;
  const ErrorPage({super.key, required this.err});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text(err)),
    );
  }
}

class RouterPath {
  static const String home = '/home';
  static const String loginDirect = '/login_direct';

  //profile tree
  static const String myProfile = '/home/my_profile';
  static const String myReview = '$myProfile/review';
  static const String myDogProfile = '$myProfile/dog_profile';
  static const String myDogRegistraion = '$myProfile/dog_registration';
  static const String myProfileModification = '$myProfile/modify_myprofile';

  //search tree
  static const String allRequirement = '/home/all_requirement_list';
  static const String requirementDetail = '$allRequirement/detail';
  static const String userProfileFromRequirement =
      '$requirementDetail/user_profile';
  static const String dogProfileFromRequirement =
      '$requirementDetail/dog_profile';

  static const String myApplicationList = '$allRequirement/my_application_list';
  static const String myApplicationDetail = '$myApplicationList/detail';
  static const String userProfileFromApplication =
      '$myApplicationDetail/user_profile';
  static const String dogProfileFromApplication =
      '$myApplicationDetail/dog_profile';

  //my requirement tree
  static const String myRequirement = '/home/my_requirement_list';
  static const String myRequirementDetail = '$myRequirement/detail';
  static const String selectDog = '$myRequirement/select_dog';
  static const String requirementRegistForm = '$selectDog/registform';

  //match tree
  static const String matchingLog = '/home/matchingLog';
  static const String matchLogDetail = '$matchingLog/detail';
}
