//dependencies
import 'package:flutter/material.dart';
import 'package:flutter_doguber_frontend/pages/currentmatch.dart';
import 'package:flutter_doguber_frontend/pages/otheruser.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
//files
import 'datamodels.dart';
import 'pages/homepage.dart';
import 'pages/matchpage.dart';
import 'pages/loginpage.dart';
import 'pages/profilepage.dart';
import 'pages/reviewpage.dart';
import 'pages/searchpage.dart';
import 'pages/registpage.dart';
import 'constants.dart';
//화면이동 담당 파일.
//생략 항목(무시해도 됨) routes: <RouteBase>[...

class RouterPath {
  static const String webView = '/web_view';

  //will pushed page
  static const String userProfile = '/user_profile';
  static const String reviewList = '/review_list';
  static const String dogProfile = '/dog_profile';
  static const String chatting = '/chat';

  //main tree
  static const String home = '/home';
  static const String currentDetail = '$home/current_detail';

  static const String allRequirement = '$home/all_requirement';
  static const String allRequirementDetail = '$allRequirement/detail';

  static const String myApplication = '$allRequirement/my_application';
  static const String myApplicationDetail = '$myApplication/detail';

  static const String myRequirement = '$home/my_requirement';
  static const String myRequirementDetail = '$myRequirement/detail';
  static const String myRequirementSelectDog = '$myRequirement/select_dog';
  static const String myRequirementSelectLocation =
      '$myRequirementSelectDog/select_location';
  static const String myRequirementRegistForm =
      '$myRequirementSelectLocation/form';

  static const String matchLog = '$home/match_log';
  static const String matchLogDetail = '$matchLog/detail';
  static const String matchLogRegistReview = '$matchLogDetail/regist_review';
  static const String matchLogReviewDetail = '$matchLogDetail/review_detail';
  static const String paymentProcess = '$matchLogDetail/payment_process';
  static const String paymentResult = '$paymentProcess/payment_result';

  static const String myProfile = '$home/my_profile';
  static const String myDogProfile = '$myProfile/dog_profile';
  static const String myDogModify = '$myDogProfile/modify';
  static const String myDogRegist = '$myProfile/regist_dog';
  static const String myProfileModify = '$myProfile/modify';
}

final GoRouter NewRoot = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => LogInPage(),
      routes: [
        GoRoute(
          path: 'web_view',
          builder: (context, state) => WebViewPage(),
        ),
        //must be pushed page
        GoRoute(
          path: 'user_profile',
          builder: (context, state) {
            final Map<String, dynamic>? data =
                state.extra as Map<String, dynamic>?;
            final int userId = data?['userId'];
            return UserProfilePage(userId: userId);
          },
        ),
        GoRoute(
          path: 'review_list',
          builder: (context, state) {
            final Map<String, dynamic>? data =
                state.extra as Map<String, dynamic>?;
            final int userId = data?['userId'];
            return ReviewListPage(userId: userId);
          },
        ),
        GoRoute(
          path: 'dog_profile',
          builder: (context, state) {
            final Map<String, dynamic>? data =
                state.extra as Map<String, dynamic>?;
            final int dogId = data?['dogId'];
            return UserDogProfile(dogId: dogId);
          },
        ),
        GoRoute(
          path: 'chat',
          builder: (context, state) {
            final Map<String, dynamic>? data =
                state.extra as Map<String, dynamic>?;
            final int matchId = data?['matchId'];
            return ChattingPage(matchId: matchId);
          },
        ),
        //main tree
        GoRoute(
          path: 'home',
          builder: (context, state) => HomePage(),
          routes: [
            ////////////////////////////////////////////////////////////////////
            GoRoute(
              path: 'current_detail',
              builder: (context, state) {
                final Map<String, dynamic>? data =
                    state.extra as Map<String, dynamic>?;
                final int detailId = data?['detailId'];
                return CurrentMatchPage(matchId: detailId);
              },
            ),
            ////////////////////////////////////////////////////////////////////
            GoRoute(
              path: 'all_requirement',
              builder: (context, state) => AllRequestPage(),
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) {
                    final Map<String, dynamic>? data =
                        state.extra as Map<String, dynamic>?;
                    final int detailId = data?['detailId'];
                    return RequirementDetailPage(requirementId: detailId);
                  },
                ),
                GoRoute(
                  path: 'my_application',
                  builder: (context, state) => MyApplicationListPage(),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      builder: (context, state) {
                        final Map<String, dynamic>? data =
                            state.extra as Map<String, dynamic>?;
                        final int detailId = data?['detailId'];
                        return MyApplicationDetailPage(applicationId: detailId);
                      },
                    ),
                  ],
                ),
              ],
            ),
            ////////////////////////////////////////////////////////////////////
            GoRoute(
              path: 'my_requirement',
              builder: (context, state) => MyRequirementListPage(),
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) {
                    final Map<String, dynamic>? data =
                        state.extra as Map<String, dynamic>?;
                    final int detailId = data?['detailId'];
                    return MyRequirementDetailPage(requirementId: detailId);
                  },
                ),
                GoRoute(
                  path: 'select_dog',
                  builder: (context, state) => SelectDogPage(),
                  routes: [
                    GoRoute(
                      path: 'select_location',
                      builder: (context, state) {
                        final Map<String, dynamic>? data =
                            state.extra as Map<String, dynamic>?;
                        final int dogId = data?['dogId'];
                        return SelectLocationPage(dogId: dogId);
                      },
                      routes: [
                        GoRoute(
                          path: 'form',
                          builder: (context, state) {
                            final Map<String, dynamic>? data =
                                state.extra as Map<String, dynamic>?;
                            final int dogId = data?['dogId'];
                            final LatLng location = data?['location'];
                            return RequestRegistrationFormPage(
                              dogId: dogId,
                              location: location,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            ////////////////////////////////////////////////////////////////////
            GoRoute(
              path: 'match_log',
              builder: (context, state) => MatchingLogPage(),
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) {
                    final Map<String, dynamic>? data =
                        state.extra as Map<String, dynamic>?;
                    final int detailId = data?['detailId'];
                    return MatchingLogDetailPage(matchingId: detailId);
                  },
                  routes: [
                    GoRoute(
                      path: 'regist_review',
                      builder: (context, state) {
                        final Map<String, dynamic>? data =
                            state.extra as Map<String, dynamic>?;
                        final int matchId = data?['matchId'];
                        return ReviewForRequesterPage(matchId: matchId);
                      },
                    ),
                    GoRoute(
                      path: 'review_detail',
                      builder: (context, state) {
                        final Map<String, dynamic>? data =
                            state.extra as Map<String, dynamic>?;
                        final int matchId = data?['matchId'];
                        return ReviewForApplicantPage(matchId: matchId);
                      },
                    ),
                    GoRoute(
                      path: 'payment_process',
                      builder: (context, state) {
                        final Map<String, dynamic>? data =
                            state.extra as Map<String, dynamic>?;
                        final int matchId = data?['matchId'];
                        return PaymentProcessPage(matchId: matchId);
                      },
                      routes: [
                        GoRoute(
                          path: 'payment_result',
                          builder: (context, state) {
                            final Map<String, dynamic>? data =
                                state.extra as Map<String, dynamic>?;
                            final int matchId = data?['matchId'];
                            return PaymentResultPage(matchId: matchId);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            ////////////////////////////////////////////////////////////////////
            GoRoute(
              path: 'my_profile',
              builder: (context, state) => MyProfilePage(),
              routes: [
                GoRoute(
                  path: 'dog_profile',
                  builder: (context, state) {
                    final Map<String, dynamic>? data =
                        state.extra as Map<String, dynamic>?;
                    final int dogId = data?['dogId'];
                    return MyDogProfilePage(dogId: dogId);
                  },
                  routes: [
                    GoRoute(
                      path: 'modify',
                      builder: (context, state) {
                        final Map<String, dynamic>? data =
                            state.extra as Map<String, dynamic>?;
                        final DogInfo dogInfo = data?['dogInfo'];
                        return DogModifyPage(dogInfo: dogInfo);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'regist_dog',
                  builder: (context, state) => DogRegistrationPage(),
                ),
                GoRoute(
                  path: 'modify',
                  builder: (context, state) => ProfileModifyPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

// final GoRouter router = GoRouter(
//   routes: [
//     GoRoute(
//       path: '/',
//       builder: (BuildContext context, GoRouterState state) {
//         return const LogInPage();
//       },
//       routes: [
//         GoRoute(
//           path: 'login_direct',
//           builder: (context, state) {
//             return const WebViewPage();
//           },
//         ),
//         GoRoute(
//           path: 'home',
//           builder: (BuildContext context, GoRouterState state) {
//             return const HomePage();
//           },
//           routes: [
//             GoRoute(
//               path: 'current_match',
//               builder: (context, state) {
//                 var id = state.uri.queryParameters['matchId'];
//                 if (id == null) {
//                   return const ErrorPage(err: 'get err');
//                 }

//                 int idInt;
//                 try {
//                   idInt = int.parse(id);
//                 } catch (e) {
//                   debugPrint('!!! parsing error');
//                   return ErrorPage(err: 'user_profile detail parse');
//                 }

//                 return CurrentMatchPage(matchId: idInt);
//               },
//               routes: [
//                 GoRoute(
//                   path: 'chat',
//                   builder: (context, state) {
//                     int? id = int.tryParse(
//                       state.uri.queryParameters['matchId']!,
//                     );
//                     if (id == null) {
//                       return const ErrorPage(err: 'parsing err');
//                     }
//                     return ChattingPage(matchId: id);
//                   },
//                 ),
//                 GoRoute(
//                   path: 'user_profile',
//                   builder: (BuildContext context, GoRouterState state) {
//                     var id = state.uri.queryParameters['userId'];
//                     var detailId = state.uri.queryParameters['detailId'];
//                     if (id == null || detailId == null) {
//                       debugPrint('!!! query null');
//                       return ErrorPage(err: 'user_profile detail query');
//                     }

//                     int idInt;
//                     int detailIdInt;
//                     try {
//                       idInt = int.parse(id);
//                       detailIdInt = int.parse(detailId);
//                     } catch (e) {
//                       debugPrint('!!! parsing error');
//                       return ErrorPage(err: 'user_profile detail parse');
//                     }
//                     return UserProfilePage(
//                       userId: idInt,
//                       detailId: detailIdInt,
//                       from: DetailFrom.currentMatch,
//                     );
//                   },
//                 ),
//                 GoRoute(
//                   path: 'dog_profile',
//                   builder: (BuildContext context, GoRouterState state) {
//                     var id = state.uri.queryParameters['dogId'];
//                     var detailId = state.uri.queryParameters['detailId'];
//                     if (id == null || detailId == null) {
//                       debugPrint('!!! query null');
//                       return ErrorPage(err: 'dog_profile detail query');
//                     }

//                     int idInt;
//                     int detailIdInt;
//                     try {
//                       idInt = int.parse(id);
//                       detailIdInt = int.parse(detailId);
//                     } catch (e) {
//                       return ErrorPage(err: 'dog_profile detail parse');
//                     }
//                     return UserDogProfile(
//                       dogId: idInt,
//                       requestId: detailIdInt,
//                     );
//                   },
//                 ),
//               ],
//             ),
//             GoRoute(
//               path: 'all_requirement_list',
//               builder: (BuildContext context, GoRouterState state) {
//                 return const AllRequestPage();
//               },
//               routes: [
//                 GoRoute(
//                   path: 'detail',
//                   builder: (BuildContext context, GoRouterState state) {
//                     var id = state.uri.queryParameters['requirementId'];
//                     if (id == null) {
//                       return ErrorPage(err: 'all_requirement detail query');
//                     }

//                     int idInt;
//                     try {
//                       idInt = int.parse(id);
//                     } catch (e) {
//                       return ErrorPage(err: 'all_requirement detail parsing');
//                     }
//                     return RequirementDetailPage(requirementId: idInt);
//                   },
//                   routes: [
//                     GoRoute(
//                       path: 'user_profile',
//                       builder: (BuildContext context, GoRouterState state) {
//                         var id = state.uri.queryParameters['userId'];
//                         var detailId = state.uri.queryParameters['detailId'];
//                         if (id == null || detailId == null) {
//                           debugPrint('!!! query null');
//                           return ErrorPage(err: 'user_profile detail query');
//                         }

//                         int idInt;
//                         int detailIdInt;
//                         try {
//                           idInt = int.parse(id);
//                           detailIdInt = int.parse(detailId);
//                         } catch (e) {
//                           debugPrint('!!! parsing error');
//                           return ErrorPage(err: 'user_profile detail parse');
//                         }
//                         return UserProfilePage(
//                           userId: idInt,
//                           detailId: detailIdInt,
//                           from: DetailFrom.requirement,
//                         );
//                       },
//                     ),
//                     GoRoute(
//                       path: 'dog_profile',
//                       builder: (BuildContext context, GoRouterState state) {
//                         var id = state.uri.queryParameters['dogId'];
//                         var detailId = state.uri.queryParameters['detailId'];
//                         if (id == null || detailId == null) {
//                           debugPrint('!!! query null');
//                           return ErrorPage(err: 'dog_profile detail query');
//                         }

//                         int idInt;
//                         int detailIdInt;
//                         try {
//                           idInt = int.parse(id);
//                           detailIdInt = int.parse(detailId);
//                         } catch (e) {
//                           return ErrorPage(err: 'dog_profile detail parse');
//                         }
//                         return UserDogProfile(
//                           dogId: idInt,
//                           requestId: detailIdInt,
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//                 GoRoute(
//                   path: 'my_application_list',
//                   builder: (context, state) {
//                     return const MyApplicationListPage();
//                   },
//                   routes: [
//                     GoRoute(
//                       path: 'detail',
//                       builder: (context, state) {
//                         var id = state.uri.queryParameters['applicationId'];
//                         if (id == null) {
//                           return ErrorPage(
//                               err: 'my_application_list detail query');
//                         }

//                         int idInt;
//                         try {
//                           idInt = int.parse(id);
//                         } catch (e) {
//                           return ErrorPage(
//                               err: 'my_application_list detail parse');
//                         }
//                         return MyApplicationDetailPage(applicationId: idInt);
//                       },
//                       routes: [
//                         GoRoute(
//                           path: 'user_profile',
//                           builder: (BuildContext context, GoRouterState state) {
//                             var id = state.uri.queryParameters['userId'];
//                             var detailId =
//                                 state.uri.queryParameters['detailId'];
//                             if (id == null || detailId == null) {
//                               debugPrint('!!! query null');
//                               return ErrorPage(
//                                   err: 'user_profile detail query');
//                             }

//                             int idInt;
//                             int detailIdInt;
//                             try {
//                               idInt = int.parse(id);
//                               detailIdInt = int.parse(detailId);
//                             } catch (e) {
//                               debugPrint('!!! parsing error');
//                               return ErrorPage(
//                                   err: 'user_profile detail parse');
//                             }
//                             return UserProfilePage(
//                               userId: idInt,
//                               detailId: detailIdInt,
//                               from: DetailFrom.application,
//                             );
//                           },
//                         ),
//                         GoRoute(
//                           path: 'dog_profile',
//                           builder: (BuildContext context, GoRouterState state) {
//                             var id = state.uri.queryParameters['dogId'];
//                             var detailId =
//                                 state.uri.queryParameters['detailId'];
//                             if (id == null || detailId == null) {
//                               debugPrint('!!! query null');
//                               return ErrorPage(err: 'dog_profile detail query');
//                             }

//                             int idInt;
//                             int detailIdInt;
//                             try {
//                               idInt = int.parse(id);
//                               detailIdInt = int.parse(detailId);
//                             } catch (e) {
//                               return ErrorPage(err: 'dog_profile detail parse');
//                             }
//                             return UserDogProfile(
//                               dogId: idInt,
//                               requestId: detailIdInt,
//                             );
//                           },
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ],
//             ),
//             GoRoute(
//               path: 'my_requirement_list',
//               builder: (BuildContext context, GoRouterState state) {
//                 return const MyRequirementListPage();
//               },
//               routes: [
//                 GoRoute(
//                   path: 'detail',
//                   builder: (context, state) {
//                     var requirementId =
//                         state.uri.queryParameters['requirementId'];
//                     if (requirementId == null) {
//                       return ErrorPage(err: 'my_requirement_list detail query');
//                     }

//                     int requirementIdInt;
//                     try {
//                       requirementIdInt = int.parse(requirementId);
//                     } catch (e) {
//                       return ErrorPage(err: 'my_requirement_list detail parse');
//                     }
//                     return MyRequirementDetailPage(
//                         requirementId: requirementIdInt);
//                   },
//                 ),
//                 GoRoute(
//                   path: 'select_dog',
//                   builder: (BuildContext context, GoRouterState state) {
//                     return const SelectDogInRequirementPage();
//                   },
//                   routes: [
//                     GoRoute(
//                       path: 'registform',
//                       builder: (BuildContext context, GoRouterState state) {
//                         var dogId = state.uri.queryParameters['dogId'];
//                         if (dogId == null) {
//                           return ErrorPage(err: 'registform query');
//                         }

//                         int dogIdInt;
//                         try {
//                           dogIdInt = int.parse(dogId);
//                         } catch (e) {
//                           return ErrorPage(err: 'registform parse');
//                         }
//                         return RequestRegistrationFormPage(dogId: dogIdInt);
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             GoRoute(
//               path: 'my_profile',
//               builder: (BuildContext context, GoRouterState state) {
//                 return const ProfilePage();
//               },
//               routes: [
//                 GoRoute(
//                     path: 'review',
//                     builder: (BuildContext context, GoRouterState state) {
//                       if (state.uri.queryParameters['userId'] == null) {
//                         return const ErrorPage(err: 'go router null');
//                       }
//                       String id = state.uri.queryParameters['userId']!;
//                       int idInt = int.parse(id);
//                       return ReviewListPage(userId: idInt);
//                     }),
//                 GoRoute(
//                     path: 'dog_profile',
//                     builder: (BuildContext context, GoRouterState state) {
//                       var id = state.uri.queryParameters['dogId'];
//                       if (id == null) {
//                         return ErrorPage(err: 'mydog_profile query');
//                       }
//                       int idInt;
//                       try {
//                         idInt = int.parse(id);
//                       } catch (e) {
//                         return ErrorPage(err: 'mydog_profile parse');
//                       }
//                       return DogProfilePage(dogId: idInt);
//                     }),
//                 GoRoute(
//                     path: 'dog_registration',
//                     builder: (BuildContext context, GoRouterState state) {
//                       return const DogRegistrationPage();
//                     }),
//                 GoRoute(
//                     path: 'modify_myprofile',
//                     builder: (BuildContext context, GoRouterState state) {
//                       return const ProfileModifyPage();
//                     }),
//               ],
//             ),
//             GoRoute(
//               path: 'matchingLog',
//               builder: (BuildContext context, GoRouterState state) {
//                 return const MatchingLogPage();
//               },
//               routes: [
//                 GoRoute(
//                   path: 'detail',
//                   builder: (BuildContext context, GoRouterState state) {
//                     int? id = int.tryParse(
//                       state.uri.queryParameters['matchingId']!,
//                     );
//                     if (id == null) {
//                       return const ErrorPage(err: 'parsing err');
//                     }
//                     return MatchingLogDetailPage(matchingId: id);
//                   },
//                   routes: [
//                     GoRoute(
//                       path: 'regist_review',
//                       builder: (BuildContext context, GoRouterState state) {
//                         if (state.uri.queryParameters['matchId'] == null) {
//                           return const ErrorPage(err: 'go router null');
//                         }
//                         String id = state.uri.queryParameters['matchId']!;
//                         int idInt = int.parse(id);
//                         return ReviewRegistFormPage(matchId: idInt);
//                       },
//                       routes: [],
//                     )
//                   ],
//                 )
//               ],
//             ),
//           ],
//         ),
//       ],
//     ),
//   ],
// );

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

// class RouterPath {
//   static const String home = '/home';
//   static const String loginDirect = '/login_direct';

//   //profile tree
//   static const String myProfile = '/home/my_profile';
//   static const String myReview = '$myProfile/review';
//   static const String myDogProfile = '$myProfile/dog_profile';
//   static const String myDogRegistraion = '$myProfile/dog_registration';
//   static const String myProfileModification = '$myProfile/modify_myprofile';

//   //search tree
//   static const String allRequirement = '/home/all_requirement_list';
//   static const String requirementDetail = '$allRequirement/detail';
//   static const String userProfileFromRequirement =
//       '$requirementDetail/user_profile';
//   static const String dogProfileFromRequirement =
//       '$requirementDetail/dog_profile';

//   //application tree in search page
//   static const String myApplicationList = '$allRequirement/my_application_list';
//   static const String myApplicationDetail = '$myApplicationList/detail';
//   static const String userProfileFromApplication =
//       '$myApplicationDetail/user_profile';
//   static const String dogProfileFromApplication =
//       '$myApplicationDetail/dog_profile';

//   //my requirement tree
//   static const String myRequirement = '/home/my_requirement_list';
//   static const String myRequirementDetail = '$myRequirement/detail';
//   static const String selectDog = '$myRequirement/select_dog';
//   static const String requirementRegistForm = '$selectDog/registform';

//   //match tree
//   static const String matchingLog = '$home/matchingLog';
//   static const String matchLogDetail = '$matchingLog/detail';
//   static const String currentMatch = '$home/current_match';
//   static const String chatPage = '$currentMatch/chat';
//   static const String userProfileFromCurrentMatch =
//       '$currentMatch/user_profile';
//   static const String ReviewRegist = '$matchLogDetail/regist_review';
// }
