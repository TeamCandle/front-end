import 'package:flutter/material.dart';

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

Widget cunstomHomeMenu({
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
