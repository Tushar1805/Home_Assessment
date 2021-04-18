import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/oldassessments/oldassessmentsbase.dart';
import '../Assesment/newassesment/newassesmentbase.dart';
import 'dart:async';

class AssesmentSplashScreen extends StatefulWidget {
  @override
  _AssesmentSplashScreenState createState() => _AssesmentSplashScreenState();
}

class _AssesmentSplashScreenState extends State<AssesmentSplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 2),
        () => FirebaseAuth.instance.onAuthStateChanged.listen((firebaseuser) {
              if (firebaseuser == null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OldAssessments()),
                );
              } else {
                getdata();
              }
              ;
            }));
  }

  getdata() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => OldAssessments()));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromRGBO(10, 80, 106, 1),
        body: Center(
          child: Icon(
            Icons.assessment,
            color: Colors.white,
            size: 200,
          ),
        ),
      ),
    );
  }
}
