import 'package:flutter/material.dart';

Color lightBlack() {
  return Color(0XFF555555);
}

Color lightGray() {
  return Color(0XFFd9d9d9);
}

InputDecoration formInputDecoration(hint) {
  return InputDecoration(
    hintText: hint,
    contentPadding: EdgeInsets.only(left: 20.0, right: 20.0),
    focusColor: lightBlack(),
    counterText: "",
    filled: true,
    fillColor: Colors.white54,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(3.0)),
      borderSide: BorderSide(color: lightGray(), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(3.0)),
      borderSide: BorderSide(
        color: lightGray(),
        width: 1,
      ),
    ),
  );
}

ScaffoldMessengerState _showSnackBar(context, value) {
  final snackBar = SnackBar(
    duration: const Duration(seconds: 3),
    content: Container(
      height: 30.0,
      child: Center(
        child: Text(
          '$value',
          style: TextStyle(fontSize: 14.0, color: Colors.white),
        ),
      ),
    ),
    backgroundColor: lightBlack(),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
  );
  return ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}

// ignore: unused_element
// void _showSnackBar(snackbar, BuildContext buildContext) {
//       final snackBar = SnackBar(
//         duration: const Duration(seconds: 3),
//         content: Container(
//           height: 30.0,
//           child: Center(
//             child: Text(
//               '$snackbar',
//               style: TextStyle(fontSize: 14.0, color: Colors.white),
//             ),
//           ),
//         ),
//         backgroundColor: lightBlack(),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
//       );
//       ScaffoldMessenger.of(buildContext)
//         ..hideCurrentSnackBar()
//         ..showSnackBar(snackBar);
//     }
