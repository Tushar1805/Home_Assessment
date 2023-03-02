import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tryapp/login/forgotPassword.dart';
import 'package:tryapp/login/resetPassword.dart';
// import 'package:tryapp/home/homeUi.dart';
// import 'package:tryapp/welcome.dart';
import '../constants.dart';
import './loginpro.dart';
import './loading.dart';
// import '../main.dart' as main;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import './loginrepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

SharedPreferences localStorage;

class LoginForm extends StatefulWidget {
  var pass;
  LoginForm(this.pass);
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _email = TextEditingController();
  FocusNode myFocusNode = new FocusNode();
  final _password = TextEditingController();
  UserRepository userrepo = UserRepository();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;
  String token;
  String type;

  void initState() {
    getToken();
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

  getToken() async {
    token = await FirebaseMessaging.instance.getToken();
    setState(() {
      token = token;
    });
    print(token);
  }

  Future login(String email, String password) async {
    try {
      // print(passwordsave);
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User useer = result.user;
      print("*************result : $result****************");

      await FirebaseFirestore.instance
          .collection("users")
          .doc(useer.uid)
          .set({"token": token}, SetOptions(merge: true));

      if (useer != null) {
        print("user uid = ${useer.uid} ");
        return useer.uid;
      } else {
        return null;
      }
    } catch (e) {}
  }

  String emailValidator(String value, context) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      _showSnackBar('Email format is invalid', context);
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);

    return loading
        ? SplashScreen1Sub()
        : Scaffold(
            backgroundColor: Color.fromRGBO(10, 80, 106, 1),
            body: SingleChildScrollView(
              child: Center(
                  child: Column(children: [
                Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * .5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      // color: Colors.lightGreen[600].withOpacity(0.7),
                      // image: DecorationImage(
                      //     image: AssetImage('assets/piclog.png'),
                      //     fit: BoxFit.cover),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20)),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Image.asset(
                          'assets/logo.png',
                          width: 174.0,
                          height: 174.0,
                        ),
                      ),
                    )),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * .5,
                  child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 30),
                          TextFormField(
                            focusNode: myFocusNode,
                            validator: (input) {
                              // emailValidator(input, context);
                              if (input.isEmpty) {
                                _showSnackBar('Please enter email', context);
                                return 'Please enter email';
                              } else {
                                return null;
                              }
                            },
                            cursorColor: Colors.black,
                            controller: _email,
                            // inputFormatters: [
                            //   FilteringTextInputFormatter.allow(new RegExp(
                            //       "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
                            //           "\\@" +
                            //           "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
                            //           "(" +
                            //           "\\." +
                            //           "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
                            //           ")+"))
                            // ],
                            decoration: new InputDecoration(
                                // filled: true,
                                // fillColor: Colors.white,
                                focusedBorder: new OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 3.5),
                                  borderRadius: new BorderRadius.circular(25.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 2.0),
                                  borderRadius: new BorderRadius.circular(25.0),
                                ),
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                    color: myFocusNode.hasFocus
                                        ? Colors.white
                                        : Colors.white),
                                prefixIcon: const Icon(
                                  Icons.email,
                                  color: Colors.white,
                                ),
                                prefixText: ' ',
                                suffixStyle:
                                    const TextStyle(color: Colors.pink)),
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            style: TextStyle(color: Colors.white),
                            initialValue: widget.pass,
                            validator: (input) {
                              if (input.length < 6) {
                                _showSnackBar(
                                    'Password should be more than 6 words',
                                    context);
                                print('Password should be more than 6 words');
                              }
                              return '';
                            },
                            onChanged: (input) {
                              // _password.clear();
                              widget.pass = input;
                              // _password.text = widget.pass;
                            },
                            // onChanged: (input) => _password = input,
                            // controller: _password,
                            cursorColor: Colors.green,
                            decoration: new InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 2.0),
                                  borderRadius: new BorderRadius.circular(25.0),
                                ),
                                focusedBorder: new OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 3.5),
                                  borderRadius: new BorderRadius.circular(25.0),
                                ),
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                    color: myFocusNode.hasFocus
                                        ? Colors.white
                                        : Colors.white),
                                prefixIcon: const Icon(
                                  Icons.lock_rounded,
                                  color: Colors.white,
                                ),
                                prefixText: ' ',
                                suffixStyle:
                                    const TextStyle(color: Colors.green)),
                            obscureText: true,
                          ),
                          SizedBox(height: 30),
                          Container(
                            width: MediaQuery.of(context).size.width * .5,
                            height: 50,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              padding: EdgeInsets.all(10),
                              color: Colors.lightGreen[800],
                              onPressed: () async {
                                String email = _email.text
                                    .toLowerCase()
                                    .replaceAll(RegExp(r"\s+"), "");
                                String password = widget.pass;
                                setState(() {
                                  loading = true;
                                });
                                // var result = await login(email, password);
                                var result = await login(email, password);
                                // await loggeedIn.setString('email', email);
                                var runtimeType;
                                if (result != null) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(result)
                                      .get()
                                      .then((value) {
                                    runtimeType = value
                                        .data()['role']
                                        .runtimeType
                                        .toString();
                                    print("runtime Type: $runtimeType");
                                    if (runtimeType == "List<dynamic>") {
                                      for (int i = 0;
                                          i < value.data()["role"].length;
                                          i++) {
                                        if (value
                                                .data()["role"][i]
                                                .toString() ==
                                            "therapist") {
                                          setState(() {
                                            type = "therapist";
                                          });
                                        }
                                      }
                                    } else {
                                      setState(() {
                                        type = value.data()["role"];
                                      });
                                    }
                                  });
                                  print("*************$type");
                                  var name = await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(result)
                                      .get()
                                      .then((value) {
                                    return value.data()['firstName'];
                                  });
                                  var newUser = await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(result)
                                      .get()
                                      .then((value) {
                                    return value.data()['newUser'];
                                  });
                                  var imgUrl = await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(result)
                                      .get()
                                      .then((value) {
                                    return value.data()['url'];
                                  });
                                  print(newUser);
                                  var page =
                                      await loginProvider.getUserType(type);
                                  if (newUser == "true" ?? false) {
                                    setState(() {
                                      loading = false;
                                    });

                                    // rolesave.setString('role', type);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ResetPass(
                                                page, result, name, imgUrl)));
                                  } else {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => page));
                                  }

                                  // rolesave.setString('role', type);
                                  // Navigator.pushReplacement(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => page));
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // return object of type Dialog
                                      return AlertDialog(
                                        title: new Text("oops!"),
                                        content: new Text("login failed"),
                                        actions: <Widget>[
                                          // usually buttons at the bottom of the dialog
                                          new FlatButton(
                                            child: new Text("Close"),
                                            onPressed: () {
                                              setState(() {
                                                loading = false;
                                              });
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: loginProvider.loading
                                  ? CircularProgressIndicator()
                                  : Text(
                                      'Log In',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ForgotPassword()));
                            },
                            child: Text(
                              "Forgot Password",
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.white,
                                  fontSize: 20),
                            ),
                          )
                          // Container(
                          //   width: MediaQuery.of(context).size.width * .5,
                          //   height: 50,
                          //   child: RaisedButton(
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(20.0),
                          //     ),
                          //     padding: EdgeInsets.all(10),
                          //     color: Colors.white,
                          //     onPressed: () async {
                          //       if (_email.text.toLowerCase() == "") {
                          //         showDialog(
                          //           context: context,
                          //           builder: (BuildContext context) {
                          //             // return object of type Dialog
                          //             return AlertDialog(
                          //               title: new Text("Oops!"),
                          //               content: new Text(
                          //                   "To reset password enter your correct email address first"),
                          //               actions: <Widget>[
                          //                 // usually buttons at the bottom of the dialog
                          //                 new FlatButton(
                          //                   child: new Text("Close"),
                          //                   onPressed: () {
                          //                     setState(() {
                          //                       loading = false;
                          //                     });
                          //                     Navigator.of(context).pop();
                          //                   },
                          //                 ),
                          //               ],
                          //             );
                          //           },
                          //         );
                          //       } else {
                          //         FirebaseAuth.instance
                          //             .sendPasswordResetEmail(
                          //                 email: _email.text.toString())
                          //             .then((_) {
                          //           showDialog(
                          //             context: context,
                          //             builder: (BuildContext context) {
                          //               // return object of type Dialog
                          //               return AlertDialog(
                          //                 title: new Text("Success"),
                          //                 content: new Text(
                          //                     "Link has been sent to your email for password reset"),
                          //                 actions: <Widget>[
                          //                   // usually buttons at the bottom of the dialog
                          //                   new FlatButton(
                          //                     child: new Text("Close"),
                          //                     onPressed: () {
                          //                       setState(() {
                          //                         loading = false;
                          //                       });
                          //                       Navigator.of(context).pop();
                          //                     },
                          //                   ),
                          //                 ],
                          //               );
                          //             },
                          //           );
                          //         }).catchError((error) {
                          //           showDialog(
                          //             context: context,
                          //             builder: (BuildContext context) {
                          //               // return object of type Dialog
                          //               return AlertDialog(
                          //                 title: new Text("oops!"),
                          //                 content: new Text(
                          //                     "Reseting Password failed"),
                          //                 actions: <Widget>[
                          //                   // usually buttons at the bottom of the dialog
                          //                   new FlatButton(
                          //                     child: new Text("Close"),
                          //                     onPressed: () {
                          //                       setState(() {
                          //                         loading = false;
                          //                       });
                          //                       Navigator.of(context).pop();
                          //                     },
                          //                   ),
                          //                 ],
                          //               );
                          //             },
                          //           );
                          //         });
                          //       }
                          //     },
                          //     child: loginProvider.loading
                          //         ? CircularProgressIndicator()
                          //         : Text(
                          //             'Forgot Password',
                          //             style: TextStyle(
                          //                 color: Colors.lightGreen[800]),
                          //           ),
                          //   ),
                          // )
                        ],
                      )),
                ),
              ])),
            ));
  }
}
