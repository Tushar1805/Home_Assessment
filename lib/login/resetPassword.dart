import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import './loading.dart';

class ResetPass extends StatefulWidget {
  var page;
  var result;
  var name;
  ResetPass(this.page, this.result, this.name);
  @override
  _ResetPassState createState() => _ResetPassState();
}

class _ResetPassState extends State<ResetPass> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firestoreInstance = Firestore.instance;
  // var name = "";
  FocusNode myFocusNode = new FocusNode();
  final password1 = TextEditingController();
  final password2 = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getUserName();
  }

  // Future<String> getUserName() async {
  //   final FirebaseUser useruid = await _auth.currentUser();
  //   firestoreInstance.collection("users").document(useruid.uid).get().then(
  //     (value) {
  //       setState(() {
  //         name = (value["name"].toString()).split(" ")[0];
  //       });
  //     },
  //   );
  // }

  Future<void> changePassword() async {
    final FirebaseUser user = await _auth.currentUser();
    if (password1.text == "" || password1.text != password2.text) {
      print('Wande hai bhai');
    } else {
      user.updatePassword(password1.text).then((value) async {
        print('Succesfullt Changed Password!');
        await Firestore.instance
            .collection('users')
            .document(widget.result)
            .updateData({'NewUser': false});
        setState(() {
          loading = false;
        });
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => widget.page));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? SplashScreen1Sub()
        : WillPopScope(
            onWillPop: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
                (Route<dynamic> route) => false,
              );
              return;
            },
            child: Scaffold(
              // appBar: AppBar(
              //   // title: Text('Assessment'),
              //   backgroundColor: Color.fromRGBO(10, 80, 106, 1),
              // ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 1,
                      width: double.infinity,
                      color: Color.fromRGBO(10, 80, 106, 1),
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.07,
                          ),
                          Container(
                            // height: 30,
                            alignment: Alignment.centerRight,
                            // width: double.infinity,
                            padding: EdgeInsets.fromLTRB(0, 0, 25, 0),
                            // color: Colors.red,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 47,
                              child: ClipOval(
                                child:
                                    Image.asset('assets/therapistavatar.png'),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.65,
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(15, 15, 0, 0),
                            alignment: Alignment.topLeft,
                            child: Text(
                              'WELCOME,',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.99,
                            padding: EdgeInsets.fromLTRB(15, 0, 0, 10),
                            alignment: Alignment.topLeft,
                            child: Text(
                              '${widget.name}.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 65,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            child: Column(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                                  child: Text(
                                    'New Password:',
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: TextFormField(
                                      style: TextStyle(color: Colors.white),
                                      validator: (input) {
                                        if (input.length < 6) {
                                          print(
                                              'Password should be more than 6 words');
                                        }
                                        return '';
                                      },
                                      controller: password1,
                                      cursorColor: Colors.green,
                                      decoration: new InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 2.0),
                                            borderRadius:
                                                new BorderRadius.circular(25.0),
                                          ),
                                          focusedBorder: new OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 3.5),
                                            borderRadius:
                                                new BorderRadius.circular(25.0),
                                          ),
                                          labelText: 'New Password',
                                          labelStyle: TextStyle(
                                              color: myFocusNode.hasFocus
                                                  ? Colors.white
                                                  : Colors.white),
                                          prefixIcon: const Icon(
                                            Icons.lock_rounded,
                                            color: Colors.white,
                                          ),
                                          prefixText: ' ',
                                          suffixStyle: const TextStyle(
                                              color: Colors.green)),
                                      obscureText: true,
                                    ))
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                                  child: Text(
                                    'Confirm Password:',
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: TextFormField(
                                    style: TextStyle(color: Colors.white),
                                    validator: (input) {
                                      if (input.length < 6) {
                                        print(
                                            'Password should be more than 6 words');
                                      }
                                      return '';
                                    },
                                    controller: password2,
                                    cursorColor: Colors.green,
                                    decoration: new InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 2.0),
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                        ),
                                        focusedBorder: new OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 3.5),
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                        ),
                                        labelText: 'Confirm Password',
                                        labelStyle: TextStyle(
                                            color: myFocusNode.hasFocus
                                                ? Colors.white
                                                : Colors.white),
                                        prefixIcon: const Icon(
                                          Icons.lock_rounded,
                                          color: Colors.white,
                                        ),
                                        prefixText: ' ',
                                        suffixStyle: const TextStyle(
                                            color: Colors.green)),
                                    obscureText: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.all(15),
                      alignment: Alignment.bottomRight,
                      child: ButtonTheme(
                          height: 50,
                          child: RaisedButton(
                            textColor: Colors.white,
                            color: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            child: Text(
                              'Update Password',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              setState(() {
                                loading = true;
                              });
                              changePassword();
                            },
                          ))),
                ],
              ),
            ),
          );
  }
}
