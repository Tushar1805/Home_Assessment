import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _email = TextEditingController();
  FocusNode myFocusNode = new FocusNode();
  final _password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  Future resetPassword(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _email.text.trim());

      _showSnackBar("Password Reset Email Sent", context);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      print("Error: $e");
      _showSnackBar(e.message, context);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(10, 80, 106, 1),
      body: SingleChildScrollView(
        child: Center(
            child: Container(
          child: Column(
            children: [
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
                height: MediaQuery.of(context).size.height * .45,
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          "Receive an email to\nreset your password",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          focusNode: myFocusNode,
                          validator: (input) {
                            if (input.isEmpty) {
                              _showSnackBar('Please type a email', context);
                              return 'Please type a email';
                            }
                            return '';
                          },
                          cursorColor: Colors.black,
                          controller: _email,
                          decoration: new InputDecoration(
                              // filled: true,
                              // fillColor: Colors.white,
                              focusedBorder: new OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 3.5),
                                borderRadius: new BorderRadius.circular(25.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 2.0),
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
                              suffixStyle: const TextStyle(color: Colors.pink)),
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 30,
                        ),
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
                              if (_email.text != null && _email.text != "") {
                                resetPassword(context);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    // return object of type Dialog
                                    return AlertDialog(
                                      title: new Text("oops!"),
                                      content:
                                          new Text("Email cannot be empty"),
                                      actions: <Widget>[
                                        // usually buttons at the bottom of the dialog
                                        new FlatButton(
                                          child: new Text("Close"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: Text(
                              'Reset Password',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )),
              )
            ],
          ),
        )),
      ),
    );
  }
}
