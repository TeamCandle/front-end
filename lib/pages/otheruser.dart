// 유저 프로필 페이지
// 연결되는 서브 페이지 : my review, dog profile, regist dog

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_doguber_frontend/api.dart';
import 'package:flutter_doguber_frontend/constants.dart';
import 'package:flutter_doguber_frontend/customwidgets.dart';
import 'package:flutter_doguber_frontend/router.dart';
import 'package:flutter_doguber_frontend/test.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import '../datamodels.dart';

//other user pages
class UserProfilePage extends StatelessWidget {
  final int userId;
  const UserProfilePage({super.key, required this.userId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('상대 정보')),
      body: FutureBuilder(
        future: ProfileApi.getUserProfile(userId: userId),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Error'));
          }

          dynamic image = snapshot.data['image'] == null
              ? const AssetImage('assets/images/profile_test.png')
              : MemoryImage(base64Decode(snapshot.data['image']));
          String name = snapshot.data['name'];
          String gender = snapshot.data['gender'] == 'male' ? '남성' : '여성';
          int age = snapshot.data['age'];
          double rating = snapshot.data['rating'];
          if (rating == -1) {
            rating = 0;
          }
          // TODO: 실제 완료에선 지울 것
          // snapshot.data['description'];
          String description = "remove later";
          List<dynamic> dogs = snapshot.data['dogList'];

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double width = constraints.maxWidth;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CircleAvatar(radius: width / 4, backgroundImage: image),
                      Center(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '$gender\t\t\t$age세',
                          style: const TextStyle(fontSize: 20.0),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RatingBarIndicator(
                            rating: rating,
                            itemBuilder: (context, index) {
                              return const Icon(Icons.star,
                                  color: Colors.amber);
                            },
                            itemCount: 5,
                            itemSize: 30.0,
                            direction: Axis.horizontal,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: width / 4,
                        child: Card.outlined(
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(description),
                          ),
                        ),
                      ),
                      const Divider(thickness: 2),
                      Column(
                        children: dogs.map((dog) {
                          return ListTile(
                            leading: dog['dogImage'] == null
                                ? Image.asset('assets/images/profile_test.png')
                                : Image.memory(dog['dogImage']),
                            title: Text(dog["name"]),
                            subtitle: Text(dog['breed']),
                            trailing: ElevatedButton(
                              onPressed: () {
                                context.push(
                                  RouterPath.dogProfile,
                                  extra: {'dogId': dog['id']},
                                );
                              },
                              child: const Icon(Icons.login_rounded),
                            ),
                          );
                        }).toList(),
                      ),
                      const Divider(thickness: 2),
                      ElevatedButton(
                        onPressed: () {
                          context.push(
                            RouterPath.reviewList,
                            extra: {'userId': userId},
                          );
                        },
                        child: const Text('리뷰 보기'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UserDogProfile extends StatelessWidget {
  final int dogId;
  const UserDogProfile({super.key, required this.dogId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('강아지 정보')),
      body: FutureBuilder(
        future: DogProfileApi.getDogProfile(id: dogId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Error'));
          }

          DogInfo dogInfo = snapshot.data!;
          var image = dogInfo.dogImage == null
              ? Image.asset(
                  'assets/images/empty_image.png',
                  fit: BoxFit.cover,
                )
              : Image.memory(
                  dogInfo.dogImage!,
                  fit: BoxFit.cover,
                );

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: image,
                )),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        customContainer(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(dogInfo.dogName),
                                  Text('${dogInfo.age}살'),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(dogInfo.breed),
                                  Text('${dogInfo.size}견'),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    dogInfo.dogGender == 'male' ? '남아' : '여아',
                                  ),
                                  Text(
                                    dogInfo.neutered == true
                                        ? '중성화 완료됨'
                                        : '중성화 안함',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        customContainer(
                          height: MediaQuery.of(context).size.width / 3,
                          width: double.maxFinite,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: Text(dogInfo.description!),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
