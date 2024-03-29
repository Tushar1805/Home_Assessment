import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/oldassessments/oldassessmentsbase.dart';
import '../Assesment/newassesment/newassesmentbase.dart';
import 'dart:async';

class AssesmentSplashScreen extends StatefulWidget {
  String role;
  AssesmentSplashScreen(this.role);
  @override
  _AssesmentSplashScreenState createState() => _AssesmentSplashScreenState();
}

class _AssesmentSplashScreenState extends State<AssesmentSplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 2),
        () => FirebaseAuth.instance.authStateChanges().listen((firebaseuser) {
              if (firebaseuser == null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OldAssessments(widget.role)),
                );
              } else {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OldAssessments(widget.role)));
              }
            }));
  }

  getdata() async {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => OldAssessments(widget.role)));
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
