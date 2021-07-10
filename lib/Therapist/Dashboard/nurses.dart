import 'package:flutter/material.dart';
import 'package:tryapp/Therapist/Dashboard/therapistdash.dart';

class NursesList extends StatefulWidget {
  @override
  _NursesListState createState() => _NursesListState();
}

class _NursesListState extends State<NursesList> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Therapist()));
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(10, 80, 106, 1),
          title: Text('Nurses/Case Managers'),
          elevation: 0.0,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Text("Yet To Be Implemented"),
          ),
        ),
      ),
    );
  }
}
