import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import '../main.dart';
import './loading.dart';

class ResetPass extends StatefulWidget {
  Widget page;
  var result;
  var name;
  var imgUrl;
  ResetPass(this.page, this.result, this.name, this.imgUrl);
  @override
  _ResetPassState createState() => _ResetPassState();
}

class _ResetPassState extends State<ResetPass> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firestoreInstance = FirebaseFirestore.instance;
  // var name = "";
  FocusNode myFocusNode = new FocusNode();
  final password1 = TextEditingController();
  final password2 = TextEditingController();
  bool loading = false;
  String name = "";

  @override
  void initState() {
    super.initState();
    getUserName();
  }

  Future<String> getUserName() async {
    final User useruid = _auth.currentUser;
    firestoreInstance.collection("users").doc(useruid.uid).get().then(
      (value) {
        setState(() {
          name = (value.data()["firstName"].toString());
        });
      },
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

  updateStatus() async {
    final User user = _auth.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'newUser': "false"});
  }

  Future<void> changePassword() async {
    final User user = _auth.currentUser;
    if (password1.text == "" || password1.text != password2.text) {
      print('Wande hai bhai');
      _showSnackBar("Incorrect Password", context);
      setState(() {
        loading = false;
      });
    } else {
      user.updatePassword(password1.text);
      print('Succesfully Changed Password!');
      _showSnackBar('Succesfully changed the password!', context);
      updateStatus();
      setState(() {
        loading = false;
      });
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyHomePage()));
      }
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
                      height: MediaQuery.of(context).size.height,
                      width: double.infinity,
                      color: Color.fromRGBO(10, 80, 106, 1),
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.06,
                          ),
                          Container(
                              // height: 30,
                              alignment: Alignment.topCenter,
                              // width: double.infinity,
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              // color: Colors.red,
                              child:
                                  (widget.imgUrl != "" && widget.imgUrl != null)
                                      ? CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 47,
                                          // backgroundImage: (imgUrl != "" && imgUrl != null)
                                          //     ? NetworkImage(imgUrl)
                                          //     : Image.asset('assets/therapistavatar.png'),
                                          child: ClipOval(
                                              clipBehavior: Clip.hardEdge,
                                              child: CachedNetworkImage(
                                                imageUrl: widget.imgUrl,
                                                fit: BoxFit.cover,
                                                width: 400,
                                                height: 400,
                                                placeholder: (context, url) =>
                                                    new CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        new Icon(Icons.error),
                                              )),
                                        )
                                      : CircleAvatar(
                                          radius: 47,
                                          backgroundColor: Colors.white,
                                          child: ClipOval(
                                            child: Image.asset(
                                              'assets/therapistavatar.png',
                                            ),
                                          ),
                                        )),
                          SizedBox(
                            height: 30,
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
                              '$name',
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
                                          _showSnackBar(
                                              'Password should be more than 6 words',
                                              context);
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
                                        _showSnackBar(
                                            'Password should be more than 6 words',
                                            context);
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
