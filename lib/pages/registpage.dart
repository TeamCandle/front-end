//dependency
import 'package:flutter/material.dart';
import 'package:flutter_doguber_frontend/api.dart';
import 'package:flutter_doguber_frontend/datamodels.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
//files
import '../constants.dart';
import '../testdata.dart';
import '../mymap.dart';
import '../router.dart';

class MyRequestListPage extends StatelessWidget {
  const MyRequestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("my request list")),
      body: FutureBuilder(
        future: context.read<InfinitList>().updateMyRequestList(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Center(child: Text('error!'));
          }

          return ListView.builder(
            itemCount: context.watch<InfinitList>().myRequestList.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(
                  context
                      .watch<InfinitList>()
                      .myRequestList[index]['id']
                      .toString(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(RouterPath.requestRegistrationForm);
        },
        child: const Text("+"),
      ),
    );
  }
}

class RequestRegistrationFormPage extends StatelessWidget {
  const RequestRegistrationFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("request registration form page")),
      body: const Center(child: Text("request registration form")),
    );
  }
}
