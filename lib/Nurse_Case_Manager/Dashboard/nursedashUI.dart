import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tryapp/splash/assesment.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../login/login.dart';

class NurseUI extends StatefulWidget {
  @override
  _NurseUIState createState() => _NurseUIState();
}

class _NurseUIState extends State<NurseUI> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  // FirebaseAuth auth = FirebaseAuth.instance;
  final firestoreInstance = Firestore.instance;
  FirebaseUser curuser;
  var name;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserName();
  }

  Future<String> getUserName() async {
    final FirebaseUser useruid = await _auth.currentUser();
    firestoreInstance.collection("users").document(useruid.uid).get().then(
      (value) {
        setState(() {
          name = (value["name"].toString()).split(" ")[0];
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(10, 80, 106, 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          // color: Colors.pink,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.only(top: 55),
                                alignment: Alignment.bottomLeft,
                                // color: Colors.red,
                                child: Text(
                                  "Hello,",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  "$name",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 37,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 7),
                        Container(
                          // height: 30,
                          alignment: Alignment.centerRight,
                          // width: double.infinity,
                          // color: Colors.red,
                          child: CircleAvatar(
                            radius: 47,
                            child: ClipOval(
                              child: Image.asset('assets/nurseavatar.png'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // child: Text("$name"),
                    //
                  ),
                  ListTile(
                    leading: Icon(Icons.favorite, color: Colors.green),
                    title: Text(
                      'Patients/Caregivers/Families',
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () => {},
                  ),
                  ListTile(
                    leading: Icon(Icons.home, color: Colors.green),
                    title: Text(
                      'Home Addresses',
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () => {Navigator.of(context).pop()},
                  ),
                  ListTile(
                    leading: Icon(Icons.assessment, color: Colors.green),
                    title: Text(
                      'Assessments',
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AssesmentSplashScreen()))
                    },
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              title: Text('Dashboard'),
              // automaticallyImplyLeading: false,
              backgroundColor: Color.fromRGBO(10, 80, 106, 1),
              elevation: 0.0,
              actions: [
                FlatButton.icon(
                  icon: Icon(Icons.logout),
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
            body: Container(
              height: double.infinity,
              width: double.infinity,
              child: Text(
                'Nurse\'s Dashboard!!!',
                style: TextStyle(
                  fontSize: 30,
                ),
                textAlign: TextAlign.center,
              ),
            )));
  }
}
