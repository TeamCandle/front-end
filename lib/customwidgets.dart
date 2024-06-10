import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

Widget customListTile({
  double? height,
  double? width,
  Widget? leading,
  Widget? title,
  Widget? subtitle,
  Widget? trailing,
  void Function()? onTap,
}) {
  return Container(
    height: height,
    width: width,
    margin: const EdgeInsets.fromLTRB(3, 0, 3, 8),
    padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 1,
          offset: const Offset(1, 1),
        ),
      ],
    ),
    child: ListTile(
      leading: leading,
      title: title,
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: subtitle,
      ),
      trailing: trailing,
      onTap: onTap,
    ),
  );
}

Widget customMsgBox({
  double? height,
  required double maxWidth,
  required Widget child,
}) {
  return SizedBox(
    width: maxWidth,
    child: Container(
      margin: const EdgeInsets.fromLTRB(3, 0, 3, 8),
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: child,
    ),
  );
}

Widget customContainer({
  double? height,
  double? width,
  Widget? child,
}) {
  return Container(
    height: height,
    width: width,
    margin: const EdgeInsets.fromLTRB(3, 0, 3, 8),
    padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 1,
          offset: const Offset(1, 1),
        ),
      ],
    ),
    child: child,
  );
}

Widget customTextField({
  double? height,
  double? width,
  TextField? child,
}) {
  return Container(
    height: height,
    width: width,
    margin: const EdgeInsets.fromLTRB(3, 0, 3, 8),
    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 1,
          offset: const Offset(1, 1),
        ),
      ],
    ),
    child: child,
  );
}

Widget customHomeMenu({
  double? height,
  double? width,
  Widget? child,
  void Function()? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: height,
      width: width,
      margin: const EdgeInsets.fromLTRB(3, 0, 3, 8),
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: child,
    ),
  );
}

Widget customImageHomeMenu({
  required double width,
  required double height,
  required String text,
  required String assetImagePath,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 1,
          offset: const Offset(1, 1),
        ),
      ],
    ),
    child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            assetImagePath,
            width: width,
            height: height,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 0,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(1, 1),
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                width: width,
                height: 30,
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white),
                width: width,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(text),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget customCard({
  double? height,
  double? width,
  required Widget child,
}) {
  return Container(
    height: height,
    width: width,
    margin: const EdgeInsets.fromLTRB(1, 8, 1, 0),
    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(10),
    ),
    child: child,
  );
}

Widget customSearchField({required Widget child}) {
  return Container(
    height: 50,
    margin: const EdgeInsets.fromLTRB(3, 0, 3, 8),
    padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 1,
          offset: const Offset(1, 1),
        ),
      ],
    ),
    child: child,
  );
}
