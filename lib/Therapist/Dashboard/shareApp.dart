import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';

class ShareApp extends StatefulWidget {
  const ShareApp({Key key}) : super(key: key);

  @override
  _ShareAppState createState() => _ShareAppState();
}

class _ShareAppState extends State<ShareApp> {
  TextEditingController recipientController = new TextEditingController();
  var recipient, name;
  List<dynamic> recipients = [];
  List<dynamic> revRecipients = [];
  FirebaseAuth auth = FirebaseAuth.instance;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  getDetails() async {
    User user = await auth.currentUser;
    print(user.uid);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((value) {
      setState(() {
        recipients = List.from(value.data()["sharedTo"]);
        name = value.data()["firstName"];
      });
    });
    setState(() {
      revRecipients = recipients.reversed.toList();
    });
    // print("revRecipients: $revRecipients");
  }

  void reverse(var recipient) {
    setState(() {
      revRecipients = recipient.reversed.toList();
    });
  }

  void showSnackBar(context, value) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 3),
      content: Container(
        height: 20.0,
        child: Center(
          child: Text(
            '$value',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
          ),
        ),
      ),
      backgroundColor: lightBlack(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color.fromRGBO(10, 80, 106, 1), // status bar color
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light, //status bar brigtness
        ),
        flexibleSpace: Container(
          width: MediaQuery.of(context).size.width,
          child: new Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 10, bottom: 10.0),
            child: Row(
              children: [
                IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                SizedBox(
                  width: 10.0,
                ),
                Text('Share App', style: titleBarWhiteTextStyle()),
              ],
            ),
          ),
          decoration: new BoxDecoration(color: Color.fromRGBO(10, 80, 106, 1)),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Enter below the email address to which you wish to send trial version of prism app or website",
                    style: TextStyle(
                        color: Color.fromRGBO(10, 80, 106, 1), fontSize: 20),
                  )),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                    decoration: formInputDecoration("Enter Email Address"),
                    controller: recipientController,
                    validator: (String value) {
                      if (recipientController.value.text.isEmpty) {
                        return 'Email is Required';
                      }
                      if (!RegExp(
                              r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                          .hasMatch(value)) {
                        return 'Please Enter a valid Email Address';
                      }
                      return null;
                    },
                    onChanged: (String value) {
                      recipient = value;
                      // recipients.add(recipient);
                      // reverse(recipients);
                    }),
              ),
              SizedBox(height: 10),
              (revRecipients != null && revRecipients.length != 0)
                  ? Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Recently Shared With",
                        style: TextStyle(
                            color: Color.fromRGBO(10, 80, 106, 1),
                            fontSize: 20),
                      ))
                  : SizedBox(),
              (revRecipients != null && revRecipients.length != 0)
                  ? Expanded(
                      child: ListView.builder(
                          itemCount: revRecipients.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: Card(
                                  color: Colors.white,
                                  child: Container(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 5, 10, 5),
                                      child: Text(
                                        revRecipients[index],
                                        style: TextStyle(fontSize: 16),
                                      ))),
                            );
                          }))
                  : SizedBox(),
              SizedBox(height: 10),
              Container(
                // height: MediaQuery.of(context).size.height * 0.6,
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    print("0000000");
                    String subject = "Prism Application (Trial)";
                    String url =
                        "https://firebasestorage.googleapis.com/v0/b/prachitest-96f1d.appspot.com/o/app-release.apk?alt=media&token=c0eba96a-2f44-46e2-984c-cc41e2db131e";

                    String message = "Please find below the links for the trial version of the Prism Application. \n\n" +
                        "Following the links, you will also find attached documentation that will guide you to use the same." +
                        "If you are using an android mobile device, click on the link below to download and install the trial version of the Prism Application :" +
                        "\n\n $url \n\nDownload will start after clicking the above link. It is 42.74 MB file so wait untill it gets download." +
                        "\n\nIf you are using an apple mobile device, open the following link in your device's web browser to run the trial version of the Prism Application : \n\n" +
                        "https://prachitest-96f1d.web.app \n\nYou can fill details of patient and caregiver as you wish there password will also be 123456." +
                        "\n\n Note: On clicking the link, it shows a small alert dialog box that tells us 'This kind of file may harm your device'" +
                        " but don't worry about that we have taken care of it.";

                    if (recipientController.text.isNotEmpty) {
                      print("#######");
                      sendEmailJs(recipient, subject, message);
                      recipients.add(recipient);
                      User user = auth.currentUser;
                      FirebaseFirestore.instance
                          .collection("users")
                          .doc(user.uid)
                          .set({"sharedTo": recipients},
                              SetOptions(merge: true));
                    } else {
                      showSnackBar(context, "Receiver mail can't be empty");
                      setState(() {
                        loading = false;
                      });
                    }
                  },
                  child: (loading == true)
                      ? Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: MediaQuery.of(context).size.height * 0.04,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3.0,
                            ),
                          ),
                        )
                      : Text("Send Email"),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(20),
                      textStyle: TextStyle(fontSize: 20)),
                ),
              )
            ],
          )),
    );
  }

  Future<void> sendEmailJs(String email, String subject, String message) async {
    setState(() {
      loading = true;
    });
    final serviceId = 'service_qlkrgo9';
    final templateId = 'template_hvch117';
    final userId = 'user_1jFTI749lDVF2WSiMRYu7';

    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
    final response = await http
        .post(
          url,
          headers: {
            "origin": 'http://localhost',
            "Content-Type": 'application/json',
          },
          body: json.encode({
            "service_id": serviceId,
            "template_id": templateId,
            "user_id": userId,
            'template_params': {
              'user_email': email,
              'user_subject': subject,
              'user_message': message
            }
          }),
        )
        .then((value) => showSnackBar(context, "Email sent successfully"));
    setState(() {
      loading = false;
    });
  }

  Future<void> sendEmail() async {
    print("****");
    setState(() {
      loading = true;
    });
    final user = await GoogleAuthApi.signIn();

    if (user == null) return;

    final email = user.email;
    print("$email");
    final auth = await user.authentication;
    final token = auth.accessToken;

    print("Authentication: $email");
    print("recipient: $recipient");

    // Reference ref = FirebaseStorage.instance.ref().child("/app-release.apk");
    // String url = (await ref.getDownloadURL()).toString();
    String url =
        "https://firebasestorage.googleapis.com/v0/b/prachitest-96f1d.appspot.com/o/app-release.apk?alt=media&token=c0eba96a-2f44-46e2-984c-cc41e2db131e";

    final smtpServer = gmailSaslXoauth2(email, token);
    final message = Message()
      ..from = Address(email, 'Be Home Be Safe')
      ..recipients.add(recipient)
      ..subject = "Prism Application (Trial)"
      ..text = "Please find below the links for the trial version of the Prism Application. \n\n" +
          "Following the links, you will also find attached documentation that will guide you to use the same." +
          "If you are using an android mobile device, click on the link below to download and install the trial version of the Prism Application :" +
          "\n\n $url \n\nDownload will start after clicking the above link. It is 42.74 MB file so wait untill it gets download." +
          "\n\nIf you are using an apple mobile device, open the following link in your device's web browser to run the trial version of the Prism Application :\n\n" +
          "Click on start trial first fill your details and use this email as your username and your password will be 123456." +
          " You can fill details of patient and caregiver as you wish there password will also be 123456." +
          "\n\n Note: On clicking the link, it shows a small alert dialog box that tells us 'This kind of file may harm your device'" +
          " but don't worry about that we have taken care of it.";

    try {
      await send(message, smtpServer);

      setState(() {
        loading = false;
      });
      showSnackBar(context, "Email sent successfully");
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      setState(() {
        loading = false;
      });
    }
  }
}

class GoogleAuthApi {
  static final _clientIDWeb =
      "360379890308-crcb8shgjqg6dlr4pjuv4llkj487njpf.apps.googleusercontent.com";
  static final _googleSignIn = GoogleSignIn(
      scopes: ['https://mail.google.com/'], clientId: _clientIDWeb);

  static Future<GoogleSignInAccount> signIn() async {
    if (await _googleSignIn.isSignedIn()) {
      return _googleSignIn.currentUser;
    } else {
      return await _googleSignIn.signIn();
    }
  }

  static Future signOut() => _googleSignIn.signOut();
}
