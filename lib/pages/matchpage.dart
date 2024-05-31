//dependency
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
//files
import '../constants.dart';
import '../datamodels.dart';
import '../testdata.dart';
import '../mymap.dart';
import '../router.dart';

class MatchingLogPage extends StatefulWidget {
  const MatchingLogPage({super.key});

  @override
  State<MatchingLogPage> createState() => _MatchingLogPageState();
}

class _MatchingLogPageState extends State<MatchingLogPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("매칭 기록")),
      body: FutureBuilder(
        future: context.read<InfinitList>().updateMatchingLogList(),
        builder: buildMatchingLogList,
      ),
    );
  }

  Widget buildMatchingLogList(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return const Center(child: Text('error!'));
    }

    return ListView.builder(
        itemCount: context.watch<InfinitList>().matchingLogList.length,
        itemBuilder: (BuildContext context, int index) {
          if (index ==
              context.watch<InfinitList>().matchingLogList.length - 3) {
            context.read<InfinitList>().updateMyApplicationList();
          }

          var image = context.watch<InfinitList>().matchingLogList[index]
                      ['image'] ==
                  null
              ? Image.asset('assets/images/empty_image.png')
              : Image.memory(
                  base64Decode(
                    context.read<InfinitList>().matchingLogList[index]['image'],
                  ),
                );
          int id = context.watch<InfinitList>().matchingLogList[index]['id'];
          String careType =
              context.watch<InfinitList>().matchingLogList[index]['careType'];
          String time =
              context.watch<InfinitList>().matchingLogList[index]['time'];
          String breed =
              context.watch<InfinitList>().matchingLogList[index]['breed'];
          String status =
              context.watch<InfinitList>().matchingLogList[index]['status'];

          return ListTile(
            leading: image,
            title: Text('$breed\t$careType'),
            subtitle: Text(time),
            trailing: Text(status),
            onTap: () => context
                .go('${RouterPath.myApplicationDetail}?applicationId=$id'),
          );
        });
  }
}
