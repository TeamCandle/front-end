// 유저 프로필 페이지
// 연결되는 서브 페이지 : my review, dog profile, regist dog

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_doguber_frontend/api.dart';
import 'package:flutter_doguber_frontend/constants.dart';
import 'package:flutter_doguber_frontend/router.dart';
import 'package:go_router/go_router.dart';

//other user pages
class UserProfilePage extends StatelessWidget {
  final int userId;
  final int detailId;
  final String type;
  const UserProfilePage({
    super.key,
    required this.userId,
    required this.detailId,
    required this.type,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            switch (type) {
              case DetailFrom.requirement:
                context.go(
                    '${RouterPath.requirementDetail}?requirementId=$detailId');
                break;
              case DetailFrom.application:
                context.go(
                    '${RouterPath.myApplicationDetail}?applicationId=$detailId');
                break;
              case DetailFrom.currentMatch:
                context.go('${RouterPath.currentMatch}?matchId=$detailId');
                break;
              case DetailFrom.matchLog:
                context.go('${RouterPath.matchLogDetail}?matchingId=$detailId');
                break;
            }
          },
        ),
        title: const Text('상대 정보'),
      ),
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
          String gender = snapshot.data['gender'];
          int age = snapshot.data['age'];
          // TODO: 실제 완료에선 지울 것
          // snapshot.data['description'];
          String description = "remove later";
          List<dynamic> dogs = snapshot.data['dogList'];

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double width = constraints.maxWidth;

              return Column(
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
                      );
                    }).toList(),
                  ),
                  const Divider(thickness: 2),
                ],
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
  final int requestId;
  const UserDogProfile({
    super.key,
    required this.dogId,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('dogID : $dogId \n requestID : $requestId'),
      ),
    );
  }
}
