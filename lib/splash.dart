import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './main.dart';
import './login/loginpro.dart';
import './login/resetPassword.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var result = FirebaseAuth.instance.currentUser();
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 3),
        () => FirebaseAuth.instance.onAuthStateChanged.listen((firebaseuser) {
              if (firebaseuser == null) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                    (Route<dynamic> rr) => false);
              } else {
                getdata();
              }
            }));
  }

  getdata() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    var type = await Firestore.instance
        .collection('users')
        .document(uid)
        .get()
        .then((value) {
      return value.data['role'];

      // var page = await LoginProvider.getUserType(type);
    });
    var newuser = await Firestore.instance
        .collection('users')
        .document(uid)
        .get()
        .then((value) {
      return value.data['NewUser'];

      // var page = await LoginProvider.getUserType(type);
    });
    var name = await Firestore.instance
        .collection('users')
        .document(uid)
        .get()
        .then((value) {
      return value.data['name'];

      // var page = await LoginProvider.getUserType(type);
    });
    var page = await LoginProvider().getUserType(type);
    if (newuser ?? false) {
      // rolesave.setString('role', type);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ResetPass(page, result, name)));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => page));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Image.asset('assets/logo.png'),
        ),
      ),
    );
  }
}
