import 'package:flutter/material.dart';
import 'package:flutter_doguber_frontend/api.dart';
import 'package:flutter_doguber_frontend/customwidgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

          return ListView.builder(
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
              String time =
                  context.watch<InfiniteList>().reviewList[index]['createdAt'];
              String breed =
                  context.watch<InfiniteList>().reviewList[index]['breed'];
              String careType =
                  context.watch<InfiniteList>().reviewList[index]['careType'];

              return customContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('$breed\t\t\t$careType'),
                    RatingBarIndicator(
                      rating: rating,
                      itemBuilder: (context, index) {
                        return const Icon(Icons.star, color: Colors.amber);
                      },
                      itemCount: 5,
                      itemSize: 30.0,
                      direction: Axis.horizontal,
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
                    Text(time),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ReviewDetailPage extends StatelessWidget {
  const ReviewDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class ReviewRegistFormPage extends StatefulWidget {
  final int matchId;
  const ReviewRegistFormPage({super.key, required this.matchId});

  @override
  State<ReviewRegistFormPage> createState() => _ReviewRegistFormPageState();
}

class _ReviewRegistFormPageState extends State<ReviewRegistFormPage> {
  final TextEditingController _txtController = TextEditingController();
  double _rating = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('리뷰 작성')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RatingBar.builder(
                initialRating: _rating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) {
                  return const Icon(Icons.star, color: Colors.amber);
                },
                onRatingUpdate: (rating) {
                  setState(() => _rating = rating);
                },
              ),
              customTextField(
                child: TextField(
                  controller: _txtController,
                  decoration: const InputDecoration(hintText: '리뷰를 작성해주세요'),
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
        },
      ),
    );
  }

  Future<dynamic> _showResult(
    BuildContext context,
    bool result,
    String title,
    String content,
  ) {
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
                    context.read<InfiniteList>().releaseList();
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
