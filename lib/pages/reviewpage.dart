import 'package:flutter/material.dart';
import 'package:flutter_doguber_frontend/api.dart';
import 'package:flutter_doguber_frontend/customwidgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../datamodels.dart';
import '../router.dart';

class ReviewListPage extends StatelessWidget {
  final int userId;
  const ReviewListPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("리뷰 목록")),
      body: FutureBuilder(
        future: context.read<InfiniteList>().updateReviewList(userId: userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('error!'));
          }

          if (context.watch<InfiniteList>().reviewList.isEmpty) {
            return const Center(child: Text('받은 리뷰가 없습니다.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: context.watch<InfiniteList>().reviewList.length,
              itemBuilder: (BuildContext context, int index) {
                if (index ==
                    context.watch<InfiniteList>().reviewList.length - 3) {
                  context.read<InfiniteList>().updateReviewList(userId: userId);
                }

                int reviewId =
                    context.watch<InfiniteList>().reviewList[index]['id'];
                double rating =
                    context.watch<InfiniteList>().reviewList[index]['rating'];
                var txtcon = TextEditingController();
                txtcon.text =
                    context.watch<InfiniteList>().reviewList[index]['text'];
                var timeData = DateTime.parse(context
                    .read<InfiniteList>()
                    .reviewList[index]['createdAt']);
                String time =
                    DateFormat('yyyy-MM-dd  HH:mm:ss').format(timeData);
                String breed =
                    context.watch<InfiniteList>().reviewList[index]['breed'];
                String careType =
                    context.watch<InfiniteList>().reviewList[index]['careType'];

                return customContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '$breed\t\t\t$careType',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                        child: Row(
                          children: [
                            RatingBarIndicator(
                              rating: rating,
                              itemBuilder: (context, index) {
                                return const Icon(Icons.star,
                                    color: Colors.amber);
                              },
                              itemCount: 5,
                              itemSize: 30.0,
                              direction: Axis.horizontal,
                            ),
                            const Spacer(),
                            Text(time),
                          ],
                        ),
                      ),
                      customTextField(
                        child: TextField(
                          controller: txtcon,
                          style: const TextStyle(color: Colors.black),
                          maxLines: 4,
                          minLines: 4,
                          enabled: false,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

//requester가 match log에서 리뷰 버튼 클릭 시
class ReviewForRequesterPage extends StatefulWidget {
  final int matchId;
  const ReviewForRequesterPage({super.key, required this.matchId});

  @override
  State<ReviewForRequesterPage> createState() => _ReviewForRequesterPageState();
}

class _ReviewForRequesterPageState extends State<ReviewForRequesterPage> {
  final TextEditingController _txtController = TextEditingController();
  double _rating = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('리뷰')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
            future: ReviewApi.getReviewDetail(widget.matchId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || snapshot.data == null) {
                return const Center(child: Text('error!'));
              }

              if (snapshot.data!['id'] != null) {
                double tempRating = double.parse(snapshot.data!['rating']);
                return customContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                        child: Row(
                          children: [
                            RatingBarIndicator(
                              rating: tempRating,
                              itemBuilder: (context, index) {
                                return const Icon(Icons.star,
                                    color: Colors.amber);
                              },
                              itemCount: 5,
                              itemSize: 30.0,
                              direction: Axis.horizontal,
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                int detailId = int.parse(snapshot.data!['id']);
                                _showDelete(context, detailId);
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                      customTextField(
                        child: TextField(
                          controller: TextEditingController(
                              text: snapshot.data!['text']),
                          style: const TextStyle(color: Colors.black),
                          maxLines: 4,
                          minLines: 4,
                          enabled: false,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: RatingBar.builder(
                        initialRating: _rating,
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 50,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) {
                          return const Icon(Icons.star, color: Colors.amber);
                        },
                        onRatingUpdate: (rating) {
                          setState(() => _rating = rating);
                        },
                      ),
                    ),
                  ),
                  customTextField(
                    child: TextField(
                      controller: _txtController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '리뷰를 작성해주세요',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await ReviewApi.regist(
                        matchId: widget.matchId,
                        rating: _rating,
                        text: _txtController.text,
                      ).then((bool result) {
                        if (result == true) {
                          _showResult(
                            context,
                            result,
                            '등록 성공',
                            '해당 유저에 대한 평가가 등록되었습니다',
                          );
                        } else {
                          _showResult(
                            context,
                            result,
                            'Err',
                            'Err',
                          );
                        }
                      });
                    },
                    child: const Text('완료'),
                  ),
                ],
              );
            }),
      ),
    );
  }

  Future<dynamic> _showDelete(BuildContext context, int reviewId) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('등록한 리뷰 삭제'),
            content: Text('정말 삭제하시겠습니까?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('아니요'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ReviewApi.delete(reviewId).then((_) {
                    context.pop();
                  });
                },
                child: const Text("네"),
              ),
            ],
          );
        });
  }

  Future<dynamic> _showResult(
      BuildContext context, bool result, String title, String content) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (result == true) {
                    context.read<InfiniteList>().clearAllList();
                    await context
                        .read<InfiniteList>()
                        .updateMatchingLogList()
                        .then((_) {
                      context.go(RouterPath.matchLog);
                    });
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("ok"),
              )
            ],
          );
        });
  }
}

//applicant가 match log에서 리뷰 버튼 클릭 시
class ReviewForApplicantPage extends StatelessWidget {
  final int matchId;
  const ReviewForApplicantPage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('받은 리뷰')),
      body: FutureBuilder(
        future: ReviewApi.getReviewDetail(matchId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('error!'));
          }

          if (snapshot.data!['id'] == null) {
            return const Center(child: Text('아직 받은 리뷰가 없습니다.'));
          }

          double rating = double.parse(snapshot.data!['rating']);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: customContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                    child: Row(
                      children: [
                        RatingBarIndicator(
                          rating: rating,
                          itemBuilder: (context, index) {
                            return const Icon(Icons.star, color: Colors.amber);
                          },
                          itemCount: 5,
                          itemSize: 30.0,
                          direction: Axis.horizontal,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  customTextField(
                    child: TextField(
                      controller:
                          TextEditingController(text: snapshot.data!['text']),
                      style: const TextStyle(color: Colors.black),
                      maxLines: 4,
                      minLines: 4,
                      enabled: false,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
