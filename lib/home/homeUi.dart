import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tryapp/login/login.dart';

class DashPage extends StatefulWidget {
  @override
  _DashPageState createState() => _DashPageState();
}

class _DashPageState extends State<DashPage> {
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  FirebaseAuth _auth = FirebaseAuth.instance;

  void getUserData() async {
    User firebaseUser = await FirebaseAuth.instance.currentUser;
    firestoreInstance
        .collection("users")
        .doc(firebaseUser.uid)
        .get()
        .then((value) {
      print('karUn');
      print(value.data);
    });
  }

  DocumentReference a = FirebaseFirestore.instance.collection('users').doc();

  @override
  Widget build(BuildContext context) {
    // final user = Provider.of<FirebaseUser>(context);
    getUserData();
    return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          elevation: 0.0,
          actions: [
            FlatButton.icon(
              icon: Icon(Icons.person),
              onPressed: () async {
                try {
                  await _auth.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Login()));
                } catch (e) {
                  print(e.toString());
                }
              },
              label: Text('logout'),
            )
          ],
        ),
        body: Text('karan'));
  }
}
