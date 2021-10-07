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
  var result = FirebaseAuth.instance.currentUser;
  StreamSubscription<User> _listener;

  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 3),
        () => _listener =
                FirebaseAuth.instance.authStateChanges().listen((firebaseuser) {
              if (firebaseuser == null) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              } else {
                getdata();
              }
            }));
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  getdata() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser;
    final uid = user.uid;
    var type, newUser, name, imgUrl, runtimeType;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((value) {
      runtimeType = value.data()['role'].runtimeType.toString();
      print("runtime Type: $runtimeType");
      if (runtimeType == "List<dynamic>") {
        for (int i = 0; i < value.data()["role"].length; i++) {
          if (value.data()["role"][i].toString() == "Therapist") {
            setState(() {
              type = "therapist";
            });
          }
        }
      } else {
        setState(() {
          type = value.data()['role'];
        });
      }
      setState(() {
        newUser = value.data()['newUser'].toString() ?? "false";
        name = value.data()['name'] ?? " ";
        imgUrl = value.data()["url"] ?? "";
      });
    });
    // var newuser = await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(uid)
    //     .get()
    //     .then((value) {
    //   return value.data()['NewUser'];

    //   // var page = await LoginProvider.getUserType(type);
    // });
    // var name = await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(uid)
    //     .get()
    //     .then((value) {
    //   return value['name'];

    //   // var page = await LoginProvider.getUserType(type);
    // });
    var page = await LoginProvider().getUserType(type);
    if (newUser == "true") {
      // rolesave.setString('role', type);
      // dispose();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ResetPass(page, result, name, imgUrl)));
    } else {
      // dispose();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Image.asset('assets/logo.png'),
        ),
      ),
    );
  }
}
