import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
// import 'dart:js' as js;

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

  String template = "";
  // final JavascriptRuntime jsRuntime = getJavascriptRuntime();

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  getDetails() async {
    User user = auth.currentUser;
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

  // Future<String> sendEmailJs(JavascriptRuntime jsRuntime, mailText, toUser,
  //     androidGuide, iosGuide) async {
  //   try {
  //     String executeJs = await rootBundle.loadString("assets/app.js");
  //     final jsResult = jsRuntime.evaluate(executeJs +
  //         """mailer($mailText, $toUser, $androidGuide, $iosGuide)""");
  //     final jsStringResult = jsResult.stringResult;
  //     return jsStringResult;
  //   } catch (e) {
  //     print("JS Function ERROR: ${e.toString()}");
  //   }
  // }

  // Future<String> callJsMethod(JavascriptRuntime jsRuntime, a, b) async {
  //   try {
  //     String executeJs = await rootBundle.loadString("assets/app.js");
  //     final jsResult = jsRuntime.evaluate(executeJs + """add($a, $b)""");
  //     final jsStringResult = jsResult.stringResult;
  //     return jsStringResult;
  //   } catch (e) {
  //     print("JS Function ERROR: ${e.toString()}");
  //   }
  // }

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
            padding: const EdgeInsets.only(left: 10.0, top: 40, bottom: 10.0),
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
                    "Enter below the email address to which you wish to send trial  version of prism app or website",
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
                    if (recipientController.text.isNotEmpty) {
                      sendEmail();

                      User user = auth.currentUser;
                      FirebaseFirestore.instance
                          .collection("users")
                          .doc(user.uid)
                          .set({"sharedTo": recipients},
                              SetOptions(merge: true));
                      recipientController.clear();
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

  Future<File> copyAsset(var asset, var name) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File tempFile = File('$tempPath/$name.pdf');
    ByteData bd = await rootBundle.load(asset);
    await tempFile.writeAsBytes(bd.buffer.asUint8List(), flush: true);
    return tempFile;
  }

  Future<File> copyAssetForWeb(var asset, var name) async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    File tempFile = File('$tempPath/$name.pdf');
    ByteData bd = await rootBundle.load(asset);
    await tempFile.writeAsBytes(bd.buffer.asUint8List(), flush: true);
    return tempFile;
  }

  Future<void> sendEmail() async {
    // await GoogleAuthApi.signOut();
    setState(() {
      loading = true;
    });

    Reference ref = FirebaseStorage.instance.ref().child("/app-release.apk");
    String url = (await ref.getDownloadURL()).toString();

    print("URL: $url");

    setState(() {
      recipients.add(recipient);
      reverse(recipients);
      template = "<html>" +
          "<head>" +
          "<title>Email Template</title>" +
          "<body>" +
          "<style>" +
          ".color{" +
          "color: red;" +
          "font-size: 20px;" +
          "}" +
          ".inline{" +
          "display: inline-block;" +
          "}" +
          ".normal{" +
          "font-size: 20px;" +
          "}" +
          ".blueColor{" +
          "color: slateblue;" +
          "font-size: 20px;" +
          "}" +
          ".imgSize{" +
          "width: 70px;" +
          "height: 70px;" +
          "margin-right: 16px;" +
          "}" +
          "</style>" +
          "<span class = 'normal'>Thank you for accepting to do Beta testing of our new</span>" +
          "<span class = 'color'> Be Home Be Safe App </span>" +
          "<span class = 'normal'>!</span>" +
          "<br></br>" +
          "<br></br>" +
          "<span class = 'normal'>Please find below the links for the trial version (One time use only) of the Prism Health Services’</span>" +
          "&nbsp;" +
          "<span class = 'color'> BHBS App.</span>" +
          "<br></br>" +
          "<br></br>" +
          "<span class = 'normal'>To get started:</span>" +
          "<br></br>" +
          "<br></br>" +
          "<span class = 'normal'>Please click on the link below based on your phone type.</span>" +
          "<br></br>" +
          "<br></br>" +
          "&nbsp;&nbsp;<span class = 'normal'>&bull;</span>&nbsp;" +
          "<a href = 'https://prachitest-96f1d.web.app/'>iphone</a>" +
          "<h3 class = 'normal'>OR</h3>" +
          "&nbsp;&nbsp;<span class = 'normal'>&bull;</span>&nbsp;" +
          "<a href = '$url'>android</a>" +
          "<br></br>" +
          "<br></br>" +
          "<span class = 'normal'>While we have made the App super easy to use, we are going the extra step by attaching a instructional guide for additional information if you have any questions.</span> " +
          "<br></br>" +
          "<br></br>" +
          "<span class = 'normal'>Please contact us if you have any questions our Email: info@behomebesafe.com</span>" +
          "<br></br>" +
          "<br></br>" +
          "<span class = 'normal'>We look forward to your valuable feedback in making this user-friendly and serve the community so everyone can</span><span class = 'color'> BE HOME </span><span class = 'normal'> & </span><span class = 'color'> BE SAFE</span><span class = 'normal'> !</span>" +
          "<br></br>" +
          "<br></br>" +
          "<span class = 'normal'>Thanks once again for your time.</span>" +
          "<br></br>" +
          "<br></br>" +
          "<img src='image001.jpg' alt=' ', style = 'height: 40px'>" +
          "<h3 class = 'blueColor'>Thanks and kind regards.</h3>" +
          "<h3 class = 'blueColor'><i>Prachi Rathi </i>OTR/L, LMT, MHA, CAPS</h3>" +
          "<h3 class = 'blueColor'><i>Consultants</i></h3>" +
          "<img src='image002.jpg' alt=' '></img>" +
          "<br></br>" +
          "<span class = 'color'>PEACE-OF-MIND SOLUTIONS FOR SAFE, HAPPY & INDEPENDENT LIVING!</span>" +
          "<br></br>" +
          "<h3 class = 'blueColor'><b>Showroom & Corporate Address:</b></h3>" +
          "<h3 class = 'blueColor'>6971 Business Park Blvd. N</h3>" +
          "<h3 class = 'blueColor'>Jacksonville, FL 32256</h3>" +
          "<h3 class = 'blueColor'>Ph: 904-880-9900  X112   </h3>" +
          "<h3 class = 'blueColor'>Fax: 904-880-3241</h3>" +
          "<h3 class = 'blueColor'>Cell: 904-716-9772</h3>" +
          "<img src='image003.png' alt=' ', class ='imgSize'><img src='image004.png' alt=' ', class ='imgSize'>" +
          "<br></br>" +
          "<br></br>" +
          "</body>" +
          "</head>" +
          "</html>";

      // template = "<html>" +
      //     "<head>" +
      //     "<title>Email Template</title>" +
      //     "<body>" +
      //     "<h3 class = 'normal'><span>Thank you for accepting to do Beta testing of our new</span>" +
      //     "<span class = 'color'> Be Home Be Safe App </span>" +
      //     "<span>!</span></h3>" +
      //     "<br>" +
      //     "<h3 class = 'normal'><span>Please find below the links for the trial version (One time use only) of the Prism Health Services’ </span>" +
      //     "<span class = 'color'>BHBS App.</span></h3>" +
      //     "<br>" +
      //     "<h3 class = 'normal'>To get started: </h3>" +
      //     "<br>" +
      //     "<h3 class = 'normal'>Please click on the link below based on your phone type.</h3>" +
      //     "<br>" +
      //     "&nbsp;&nbsp;<span class = 'normal'>&bull;</span>&nbsp;" +
      //     "<a href = 'https://prachitest-96f1d.web.app/'>iphone</a>" +
      //     "<h3 class = 'normal'>OR</h3>" +
      //     "&nbsp;&nbsp;<span class = 'normal'>&bull;</span>&nbsp;" +
      //     "<a href = 'https://drive.google.com/file/d/1_N1mmHvtLW2sn6LG0GY-HdD4PyNlCKp8/view?usp=drivesdk'>android</a>" +
      //     "<br>" +
      //     "<h3 class = 'normal'>While we have made the App super easy to use, we are going the extra step by attaching a instructional guide for additional information if you have any questions.</h3> " +
      //     "<br>" +
      //     "<h3 class = 'normal'>Please contact us if you have any questions our Email: info@behomebesafe.com</h3>" +
      //     "<br>" +
      //     "<h3 class = 'normal'><span>We look forward to your valuable feedback in making this user-friendly and serve the community so everyone can</span><span class = 'color'> BE HOME </span><span class = 'normal'> & </span><span class = 'color'> BE SAFE</span><span class = 'normal'> !</span></h3>" +
      //     "<br>" +
      //     "<h3 class = 'normal'>Thanks once again for your time.</h3>" +
      //     "<br>" +
      //     "<img src='image001.jpg' alt='', style = 'height: 40px'></img>" +
      //     "<h3 class = 'blueColor'>Thanks and kind regards.</h3>" +
      //     "<h3 class = 'blueColor'>Prachi Rathi OTR/L, LMT, MHA, CAPS</h3>" +
      //     "<h3 class = 'blueColor'>Consultants</h3>" +
      //     "<img src='image002.jpg' alt=''></img>" +
      //     "<br>" +
      //     "<h3 class = 'color'>PEACE-OF-MIND SOLUTIONS FOR SAFE, HAPPY & INDEPENDENT LIVING!</h3>" +
      //     "<br>" +
      //     "<h3 class = 'blueColor'>Showroom & Corporate Address:</h3> " +
      //     "<h3 class = 'blueColor'>6971 Business Park Blvd. N</h3>" +
      //     "<h3 class = 'blueColor'>Jacksonville, FL 32256</h3>" +
      //     "<h3 class = 'blueColor'>Ph: 904-880-9900  X112   </h3>" +
      //     "<h3 class = 'blueColor'>Fax: 904-880-3241</h3>" +
      //     "<h3 class = 'blueColor'>Cell: 904-716-9772</h3>" +
      //     "<img src='image003.png' alt='' class ='imgSize'><img src='image004.png' alt='' class ='imgSize'>" +
      //     "<br>" +
      //     // "<p><i>The information in this email/ faxed document(s) is confidential and may be legally privileged. It is intended solely for the addressee. Access to this email/ faxed document(s) by anyone else is unauthorized. If you are not the intended recipient, any disclosure, copying, distribution or any action taken or omitted to be taken in reliance on it, is prohibited and may be unlawful. If you believe that you have received this email / faxed document(s) in error, please contact the sender immediately and destroy all the copies of documents received erroneously.</i></p>" +
      //     "<style>" +
      //     "h3{font-size: 28px!important;}" +
      //     ".color{color: red;font-size:28px;}" +
      //     ".inline{display: inline-block;}" +
      //     ".blueColor{color:slateblue;font-size:28px;}" +
      //     ".imgSize{width: 70px;height: 70px;margin-right: 16px;}" +
      //     ".normal{color:black;font-size:28px;}" +
      //     "</style>" +
      //     "</body>" +
      //     "</head>" +
      //     "</html>";

      // template = "<html>" +
      //     "<head>" +
      //     "<title>Email Template</title>" +
      //     "<body>" +
      //     "<h1>Thank you for accepting to do Beta testing of our new</h1>" +
      //     "<h1 class = 'color'> Be Home Be Safe App!</h1>" +
      //     "<h2>Please find below the links for the trial version (One time use only) of the Prism Health Services’<h1 class = 'color', class = 'inline'> BHBS App. " +
      //     "<h2>To get started: </h2>" +
      //     "<h2>Please click on the link below based on your phone type.</h2>" +
      //     "<ul style: 'list-style-type: disc'><h2><li>iPhone: </li></h2></ul>" +
      //     "<a href = 'https://prachitest-96f1d.web.app/'>Click for website link</a>" +
      //     "<h2>OR</h2>" +
      //     "<ul style: 'list-style-type: disc'><h2><li>Android: </li></h2></ul>" +
      //     "<a href = 'https://drive.google.com/file/d/1_N1mmHvtLW2sn6LG0GY-HdD4PyNlCKp8/view?usp=drivesdk'>Click for App link</a>" +
      //     "<h2>While we have made the App super easy to use, we are going the extra step by attaching a instructional guide for additional information if you have any questions.</h2> " +
      //     "<h2>Please contact us if you have any questions our Email: info@behomebesafe.com</h2>" +
      //     "<h2 class = 'inline'>We look forward to your valuable feedback in making this user-friendly and serve the community so everyone can<h2 class = 'color', class = 'inline'> BE HOME <h2 class = 'inline'> & <h2 class = 'color'> BE SAFE<h2 class = 'inline'> !" +
      //     "<h2>Thanks once again for your time.</h2>" +
      //     "<img src='image001.jpg' alt='Be Home Be Safe', style = 'height: 40px'>" +
      //     "<h2 class =  'blueColor'>Thanks and kind regards.</h2>" +
      //     "<h2 class =  'blueColor'><i>Prachi Rathi </i>OTR/L, LMT, MHA, CAPS</h2>" +
      //     "<h2 class =  'blueColor'><i>Consultants</i></h2>" +
      //     "<img src='image002.jpg' alt='Be Home Be Safe'></img>" +
      //     "<h4 class = 'color'>PEACE-OF-MIND SOLUTIONS FOR SAFE, HAPPY & INDEPENDENT LIVING!</h4>" +
      //     "<h3 class =  'blueColor'>Showroom & Corporate Address:</h3>" +
      //     "<h3 class =  'blueColor'>6971 Business Park Blvd. N</h3>" +
      //     "<h3 class =  'blueColor'>Jacksonville, FL 32256</h3>" +
      //     "<h3 class =  'blueColor'>Ph: 904-880-9900  X112   </h3>" +
      //     "<h3 class =  'blueColor'>Fax: 904-880-3241</h3>" +
      //     "<h3 class =  'blueColor'>Cell: 904-716-9772</h3>" +
      //     "<img src='image003.png' alt='Be Home Be Safe', class ='imgSize'><img src='image004.png' alt='Be Home Be Safe', class ='imgSize'>" +
      //     "<style> " +
      //     " .color{" +
      //     " color: red; " +
      //     "}" +
      //     ".inline{" +
      //     "display: inline-block;" +
      //     "}" +
      //     ".blueColor{" +
      //     "color:slateblue;" +
      //     "}" +
      //     ".imgSize{" +
      //     "width: 70px;" +
      //     "  height: 70px;" +
      //     "margin-right: 16px;" +
      //     "}" +
      //     "</style>" +
      //     "</body>" +
      //     "</html>";

      // template = "";
    });

    // final user = await GoogleAuthApi.signIn();

    // if (user == null) return;

    // final email = user.email;
    // final auth = await user.authentication;
    // final token = auth.accessToken;

    // print("Authentication: $email");
    // print("recipient: $recipient");

    // Directory tempDir = await getTemporaryDirectory();
    // String tempPath = tempDir.path;

    // // AndroidGuide File
    if (kIsWeb) {
      File android =
          await copyAssetForWeb("assets/androidGuide.pdf", "androidGuide");
    } else {
      File android = await copyAsset("assets/androidGuide.pdf", "androidGuide");
    }

    //  AppleGuide File
    if (kIsWeb) {
      File apple = await copyAssetForWeb("assets/appleGuide.pdf", "appleGuide");
    } else {
      File apple = await copyAsset("assets/appleGuide.pdf", "appleGuide");
    }

    // final smtpServer = gmailSaslXoauth2(email, token);
    // final message = Message()
    //   ..from = Address(email, 'Be Home Be Safe')
    //   ..recipients.add(recipient)
    //   ..subject = "Prism Application (Trial)"
    //   ..html = template
    //   ..attachments = [
    //     FileAttachment(File(apple.path)),
    //     FileAttachment(File(android.path))
    //   ];

    // ..attachments.add(FileAttachment(File("assets/androidGuide")))
    // ..attachments.add(FileAttachment(File("assets/appleGuide")))

    // "<h1>Thank you for accepting to do Beta testing of our new</h1><h1 class = 'color'> Be Home Be Safe App!</h1>\n\n" +
    //     "<h1>Please find below the links for the trial version (One time use only) of the Prism Health Services’  BHBS App. </h1>" +
    //     "<h2>To get started: </h2>\n<p>Please click on the link below based on your phone type.</p> " +
    //     "<ul>iPhone: </ul><a href = 'https://prachitest-96f1d.web.app/'>Click for website link</a>\n<h1>OR</h1>\n" +
    //     "<ul>Android: </ul><a href = 'https://drive.google.com/file/d/1_N1mmHvtLW2sn6LG0GY-HdD4PyNlCKp8/view?usp=drivesdk'>Click for App link</a>" +
    //     "\n\n<h1>While we have made the App super easy to use, we are going the extra step by attaching a instructional guide for additional information if you have any questions.</h1> \n\n " +
    //     "<h1>Please contact us if you have any questions our Email: info@behomebesafe.com</h1>\n\n" +
    //     "<h1>We look forward to your valuable feedback in making this user-friendly and serve the community so everyone can BE HOME & BE SAFE!</h1>\n\n" +
    //     "<h1>Thanks once again for your time.</h1>";
    // ..text = "Please find below the links for the trial version of the Prism Application. \n\n" +
    //     "Following the links, you will also find attached documentation that will guide you to use the same." +
    //     "If you are using an android mobile device, click on the link below to download and install the trial version of the Prism Application :" +
    //     "\n\n $url \n\nDownload will start after clicking the above link. It is 42.74 MB file so wait untill it gets download." +
    //     "\n\nIf you are using an apple mobile device, open the following link in your device's web browser to run the trial version of the Prism Application :\n\n" +
    //     "\n\n Note: On clicking the link, it shows a small alert dialog box that tells us 'This kind of file may harm your device'" +
    //     " but don't worry about that we have taken care of it.";

    try {
      // await send(message, smtpServer);
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('sendMail');
      // final resp = await callable.call();
      final resp = await callable.call(<String, dynamic>{
        'toUser': recipient,
        'mailText': template,
        // 'androidGuide': android.path.toString(),
        // 'iosGuide': apple.path.toString(),
      });
      // setState(() {
      //   loading = false;
      // });
      // print(template);

      // await send(message, smtpServer);
      // setState(() {
      //   loading = false;
      // });

      // Using flutter email sender here

      /*
      // final Email email = Email(
      //   isHTML: true,
      //   subject: "Prism Application (Trial)",
      //   body: template,
      //   recipients: [recipient],
      //   attachmentPaths: [apple.path, android.path],
      // );
      // await FlutterEmailSender.send(email);
      */

      // js.context.callMethod('mailer', [template, recipient, android, apple]);

      // final result =
      //     await sendEmailJs(jsRuntime, template, recipient, android, apple);
      // final result = callJsMethod(jsRuntime, 15, 5);

      // print("Result : $result");
      print("RESPONSE: $resp");

      showSnackBar(context, "Email sent successfully");
    } catch (e) {
      print("ERROR: ${e.toString()}");
      print('Message not sent.');
      setState(() {
        loading = false;
      });
    }
    setState(() {
      loading = false;
    });
  }
}

// class GoogleAuthApi {
//   static final _googleSignIn =
//       GoogleSignIn(scopes: ['https://mail.google.com/']);

//   static Future<GoogleSignInAccount> signIn() async {
//     if (await _googleSignIn.isSignedIn()) {
//       return _googleSignIn.currentUser;
//     } else {
//       return await _googleSignIn.signIn();
//     }
//   }

//   static Future signOut() => _googleSignIn.signOut();
// }
