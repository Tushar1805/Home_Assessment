import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color.fromRGBO(10, 80, 106, 1),
        child: Center(
          child: SpinKitFoldingCube(color: Colors.white, size: 50.0),
        ));
  }
}
