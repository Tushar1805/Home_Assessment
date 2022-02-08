import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Color lightBlack() {
  return Color(0XFF555555);
}

Color lightGray() {
  return Color(0XFFd9d9d9);
}

Color darkBlack() {
  return Color(0XFF000000);
}

Color gray() {
  return Color(0XFF999999);
}

TextStyle lightBlackTextStyle() {
  return TextStyle(
      fontFamily: 'Source Sans Pro',
      fontSize: 14,
      color: lightBlack(),
      decoration: TextDecoration.none,
      fontWeight: FontWeight.w600);
}

TextStyle whiteTextStyle() {
  return TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.0);
}

Color orangeColor() {
  return Color(0XFFf59629);
}

Color redOrangeColor() {
  return Color(0XFFe76a4b);
}

TextStyle darkBlackTextStyle() {
  return TextStyle(
      fontFamily: 'Source Sans Pro',
      fontSize: 15,
      color: darkBlack(),
      decoration: TextDecoration.none,
      fontWeight: FontWeight.w900);
}

TextStyle normalTextStyle() {
  return TextStyle(
      fontFamily: 'Source Sans Pro',
      fontSize: 15,
      color: lightBlack(),
      fontWeight: FontWeight.w300);
}

TextStyle titleBarWhiteTextStyle() {
  return TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.0);
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

void _showSnackBar(snackbar, BuildContext buildContext) {
  final snackBar = SnackBar(
    duration: const Duration(seconds: 3),
    content: Container(
      height: 30.0,
      child: Center(
        child: Text(
          '$snackbar',
          style: TextStyle(fontSize: 14.0, color: Colors.white),
        ),
      ),
    ),
    backgroundColor: lightBlack(),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
  );
  ScaffoldMessenger.of(buildContext)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}

Widget loading() {
  return Container(
    color: Colors.white,
    child: Center(
      child: SpinKitThreeBounce(
        color: Color.fromRGBO(10, 80, 106, 1),
        size: 40.0,
      ),
    ),
  );
}


// ScaffoldMessengerState _showSnackBar(context, value) {
//   final snackBar = SnackBar(
//     duration: const Duration(seconds: 3),
//     content: Container(
//       height: 30.0,
//       child: Center(
//         child: Text(
//           '$value',
//           style: TextStyle(fontSize: 14.0, color: Colors.white),
//         ),
//       ),
//     ),
//     backgroundColor: lightBlack(),
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
//   );
//   return ScaffoldMessenger.of(context)
//     ..hideCurrentSnackBar()
//     ..showSnackBar(snackBar);
// }

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
