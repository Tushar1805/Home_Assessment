import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_speech/google_speech.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentbase.dart';
import 'package:tryapp/CompleteAssessment/completeAssessmentBase.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/reportui.dart';
import 'package:tryapp/Therapist/Dashboard/therapistpro.dart';
import 'package:tryapp/constants.dart';
import 'package:flutter/services.dart';
import 'package:google_speech/google_speech.dart';
import 'package:rxdart/rxdart.dart';

class DetailedScreen extends StatefulWidget {
  String title, status;
  DetailedScreen(this.title, this.status);
  @override
  State<DetailedScreen> createState() => _DetailedScreenState();
}

class _DetailedScreenState extends State<DetailedScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  // FirebaseAuth auth = FirebaseAuth.instance;
  final firestoreInstance = FirebaseFirestore.instance;
  User curuser;
  var fname, lname, address, userFirstName, userLastName, curUid, patientUid;
  String imgUrl = "";
  List<Map<String, dynamic>> list = [];
  int sum = 0;
  double rating = 0.0;
  bool admin = false;
  bool beginAssessmentStatus = false;
  bool recommendationStatus = false;
  String dialogMessage;

  // bool recognizing = false;
  // bool recognizeFinished = false;
  // String text = '';

  // MIC Stram
  final RecorderStream _recorder = RecorderStream();

  bool recognizing = false;
  bool recognizeFinished = false;
  String text = '';
  StreamSubscription<List<int>> _audioStreamSubscription;
  BehaviorSubject<List<int>> _audioStream;

  @override
  void initState() {
    super.initState();
    _recorder.initialize();
    setImage();
    getUserDetails();
    getCurrentUid();
  }

  void streamingRecognize() async {
    _audioStream = BehaviorSubject<List<int>>();
    _audioStreamSubscription = _recorder.audioStream.listen((event) {
      _audioStream.add(event);
    });

    await _recorder.start();

    setState(() {
      recognizing = true;
    });
    final serviceAccount = ServiceAccount.fromString(
        (await rootBundle.loadString('assets/test_service_account.json')));
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
    final config = _getConfig();

    final responseStream = speechToText.streamingRecognize(
        StreamingRecognitionConfig(config: config, interimResults: true),
        _audioStream);

    var responseText = '';

    responseStream.listen((data) {
      final currentText =
          data.results.map((e) => e.alternatives.first.transcript).join('\n');

      if (data.results.first.isFinal) {
        responseText += '\n' + currentText;
        setState(() {
          text = responseText;
          recognizeFinished = true;
        });
      } else {
        setState(() {
          text = responseText + '\n' + currentText;
          recognizeFinished = true;
        });
      }
    }, onDone: () {
      setState(() {
        recognizing = false;
      });
    });
  }

  void stopRecording() async {
    await _recorder.stop();
    await _audioStreamSubscription?.cancel();
    await _audioStream?.close();
    setState(() {
      recognizing = false;
    });
  }

  RecognitionConfig _getConfig() => RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 16000,
      languageCode: 'en-US');

  // void recognize() async {
  //   setState(() {
  //     recognizing = true;
  //   });
  //   final serviceAccount = ServiceAccount.fromString(
  //       '${(await rootBundle.loadString('assets/service-account-file.json'))}');
  //   final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
  //   final config = _getConfig();
  //   final audio = await _getAudioContent('test.mp3');

  //   await speechToText.recognize(config, audio).then((value) {
  //     setState(() {
  //       text = value.results
  //           .map((e) => e.alternatives.first.transcript)
  //           .join('\n');
  //     });
  //   }).whenComplete(() => setState(() {
  //         recognizeFinished = true;
  //         recognizing = false;
  //       }));
  // }

  // void streamingRecognize() async {
  //   setState(() {
  //     recognizing = true;
  //   });
  //   final serviceAccount = ServiceAccount.fromString(
  //       '${(await rootBundle.loadString('assets/service-account-file.json'))}');
  //   final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
  //   final config = _getConfig();

  //   final responseStream = speechToText.streamingRecognize(
  //       StreamingRecognitionConfig(config: config, interimResults: true),
  //       await _getAudioStream('test.mp3'));

  //   responseStream.listen((data) {
  //     setState(() {
  //       text =
  //           data.results.map((e) => e.alternatives.first.transcript).join('\n');
  //       recognizeFinished = true;
  //     });
  //   }, onDone: () {
  //     setState(() {
  //       recognizing = false;
  //     });
  //   });
  // }

  // RecognitionConfig _getConfig() => RecognitionConfig(
  //     encoding: AudioEncoding.LINEAR16,
  //     model: RecognitionModel.basic,
  //     enableAutomaticPunctuation: true,
  //     sampleRateHertz: 16000,
  //     languageCode: 'en-US');

  // Future<void> _copyFileFromAssets(String name) async {
  //   var data = await rootBundle.load('assets/$name');
  //   final directory = await getApplicationDocumentsDirectory();
  //   final path = directory.path + '/$name';
  //   await File(path).writeAsBytes(
  //       data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  // }

  // Future<List<int>> _getAudioContent(String name) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final path = directory.path + '/$name';
  //   if (!File(path).existsSync()) {
  //     await _copyFileFromAssets(name);
  //   }
  //   return File(path).readAsBytesSync().toList();
  // }

  // Future<Stream<List<int>>> _getAudioStream(String name) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final path = directory.path + '/$name';
  //   if (!File(path).existsSync()) {
  //     await _copyFileFromAssets(name);
  //   }
  //   return File(path).openRead();
  // }

  Future<void> setImage() async {
    final User useruid = _auth.currentUser;
    await firestoreInstance
        .collection("users")
        .doc(useruid.uid)
        .get()
        .then((value) {
      setState(() {
        if (value.data()["url"] != null) {
          imgUrl = (value.data()["url"].toString()) ?? "";
        } else {
          firestoreInstance
              .collection("users")
              .doc(useruid.uid)
              .set({'url': ''}, SetOptions(merge: true));
          imgUrl = "";
        }
        print(imgUrl);
        // address = (value["houses"][0]["city"].toString());
      });
    });
  }

  Future<void> getUserDetails() async {
    final User useruid = _auth.currentUser;
    await firestoreInstance.collection("users").doc(useruid.uid).get().then(
      (value) {
        setState(() {
          userFirstName = (value.data()["firstName"].toString());
          userLastName = (value.data()["lastName"].toString());
          // imgUrl = (value['url'].toString()) ?? "";
          // print("**********imgUrl = $imgUrl");
          // address = (value["houses"][0]["city"].toString());
        });
        if (value.data().containsKey("admin")) {
          setState(() {
            admin = value.data()["admin"];
          });
        }
      },
    );
  }

  Future<void> getPatientDetails() async {
    final User useruid = _auth.currentUser;
    if (patientUid != null) {
      await firestoreInstance.collection("users").doc(patientUid).get().then(
        (value) {
          setState(() {
            fname = (value.data()["firstName"].toString());
            lname = (value.data()["lastName"].toString());
            address = (value.data()["houses"][0]["city"].toString());
          });
        },
      );
    }
  }

  Future<void> getCurrentUid() async {
    final User useruid = _auth.currentUser;
    setState(() {
      curUid = useruid.uid;
    });
  }

  Widget getButton(
      String status,
      String therapistUid,
      String assessorUid,
      String patientUid,
      List<Map<String, dynamic>> list,
      String docID,
      BuildContext buildContext) {
    void _showSnackBar(snackbar) {
      final snackBar = SnackBar(
        duration: const Duration(seconds: 3),
        content: Container(
          height: 25.0,
          child: Center(
            child: Text(
              '$snackbar',
              style: TextStyle(fontSize: 14.0, color: Colors.white),
            ),
          ),
        ),
        backgroundColor: lightBlack(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      );
      ScaffoldMessenger.of(buildContext)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }

    if (status == "Assessment Scheduled" && assessorUid == curUid) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.4,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          elevation: 3,
          color: Color.fromRGBO(10, 80, 106, 1),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        NewAssesment(docID, "therapist", null)));
          },
          child: Text(
            "Begin Assessment",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      );
    } else if (status == "Assessment Scheduled" && assessorUid != curUid) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.5,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          elevation: 3,
          color: Color.fromRGBO(10, 80, 106, 1),
          onPressed: () {
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => NewAssesment(docID)));
            _showSnackBar("Wait for the assessor to finish the assessment");
          },
          child: Text(
            "Assessment Scheduled",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      );
    } else if (status == "Assessment in Progress" && assessorUid == curUid) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.5,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          elevation: 3,
          color: Color.fromRGBO(10, 80, 106, 1),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CompleteAssessmentBase(list, docID, "therapist")));
          },
          child: Text(
            "Provide Recommendations",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      );
    } else if (status == "Assessment in Progress" && assessorUid != curUid) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.5,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          elevation: 3,
          color: Color.fromRGBO(10, 80, 106, 1),
          onPressed: () {
            _showSnackBar("Wait for the assessor to finish the assessment");
          },
          child: Text(
            "Assessment in Progress",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      );
    } else if (status == "Report Generated") {
      return Container(
        width: MediaQuery.of(context).size.width * 0.4,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 20,
          ),
          elevation: 3,
          color: Color.fromRGBO(10, 80, 106, 1),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ReportUI(docID, patientUid, therapistUid, list)));
          },
          child: Text(
            "View Report",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      );
    } else if (status == "Assessment Finished" && curUid != assessorUid) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.5,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          elevation: 3,
          color: Color.fromRGBO(10, 80, 106, 1),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CompleteAssessmentBase(list, docID, "therapist")));
          },
          child: Text(
            "Provide Recommendations",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        // Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("My title"),
      content: Text("This is my message."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // Widget ongoingassess(TherapistProvider assesspro, BuildContext context) {
  //   return (assesspro.loading)
  //       ? Center(child: CircularProgressIndicator())
  //       : (assesspro.datasetmain.length == 0)
  //           ? Container(
  //               width: double.infinity,
  //               height: MediaQuery.of(context).size.height * 0.7,
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   Container(
  //                     height: MediaQuery.of(context).size.height * .2,
  //                     child: Image.asset('assets/nodata.png'),
  //                   ),
  //                   Container(
  //                     child: Container(
  //                       child: Text(
  //                         'NO ASSIGNMENTS ASSIGNED',
  //                         style: TextStyle(
  //                           fontSize: 20,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.grey[600],
  //                         ),
  //                         textAlign: TextAlign.center,
  //                       ),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             )
  //           : Container(
  //               child: Container(
  //               child: Padding(
  //                 padding: EdgeInsets.all(8),
  //                 child: ConstrainedBox(
  //                   constraints: BoxConstraints(
  //                       maxHeight: 1000,
  //                       minHeight: MediaQuery.of(context).size.height / 10),
  //                   child: ListView.builder(
  //                     physics: BouncingScrollPhysics(),
  //                     shrinkWrap: true,
  //                     itemCount: assesspro.datasetmain?.length ?? 0,
  //                     itemBuilder: (context, index) {
  //                       // print(assesspro.datasetmain.length);
  //                       // return;
  //                       // return listdata(assesspro.datasetmain[index],
  //                       //     assesspro.datasetmain[index], assesspro);
  //                       return listdata(assesspro.datasetmain["$index"],
  //                           assesspro.dataset.docs[index], assesspro, context);
  //                     },
  //                   ),
  //                 ),
  //               ),
  //             ));
  // }

  Widget onGoingScheduledAssess(
      TherapistProvider assesspro, BuildContext context) {
    return (assesspro.scheduledLoading)
        ? Center(child: CircularProgressIndicator())
        : (assesspro.scheduledDataset.length == 0)
            ? Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * .2,
                      child: Image.asset('assets/nodata.png'),
                    ),
                    Container(
                      child: Container(
                        child: Text(
                          'NO ASSIGNMENTS ASSIGNED',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                ),
              )
            : Container(
                child: Container(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: 1000,
                        minHeight: MediaQuery.of(context).size.height / 10),
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: assesspro.scheduledDataset?.length ?? 0,
                      itemBuilder: (context, index) {
                        // print(assesspro.datasetmain.length);
                        // return;
                        // return listdata(assesspro.datasetmain[index],
                        //     assesspro.datasetmain[index], assesspro);
                        return listdata(
                            assesspro.scheduledDataset["$index"],
                            assesspro.scheduledAssessments.docs[index],
                            assesspro,
                            context);
                      },
                    ),
                  ),
                ),
              ));
  }

  Widget onGoingPendingAssess(
      TherapistProvider assesspro, BuildContext context) {
    return (assesspro.pendingLoading)
        ? Center(child: CircularProgressIndicator())
        : (assesspro.pendingDataset.length == 0)
            ? Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * .2,
                      child: Image.asset('assets/nodata.png'),
                    ),
                    Container(
                      child: Container(
                        child: Text(
                          'NO ASSIGNMENTS ASSIGNED',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                ),
              )
            : Container(
                child: Container(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: 1000,
                        minHeight: MediaQuery.of(context).size.height / 10),
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: assesspro.pendingDataset?.length ?? 0,
                      itemBuilder: (context, index) {
                        // print(assesspro.datasetmain.length);
                        // return;
                        // return listdata(assesspro.datasetmain[index],
                        //     assesspro.datasetmain[index], assesspro);
                        return listdata(
                            assesspro.pendingDataset["$index"],
                            assesspro.pendingAssessments.docs[index],
                            assesspro,
                            context);
                      },
                    ),
                  ),
                ),
              ));
  }

  Widget onGoingClosedAssess(
      TherapistProvider assesspro, BuildContext context) {
    return (assesspro.closedLoading)
        ? Center(child: CircularProgressIndicator())
        : (assesspro.closedDataset.length == 0)
            ? Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * .2,
                      child: Image.asset('assets/nodata.png'),
                    ),
                    Container(
                      child: Container(
                        child: Text(
                          'NO ASSIGNMENTS ASSIGNED',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                ),
              )
            : Container(
                child: Container(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: 1000,
                        minHeight: MediaQuery.of(context).size.height / 10),
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: assesspro.closedDataset?.length ?? 0,
                      itemBuilder: (context, index) {
                        // print(assesspro.datasetmain.length);
                        // return;
                        // return listdata(assesspro.datasetmain[index],
                        //     assesspro.datasetmain[index], assesspro);
                        return listdata(
                            assesspro.closedDataset["$index"],
                            assesspro.closedAssessments.docs[index],
                            assesspro,
                            context);
                      },
                    ),
                  ),
                ),
              ));
  }

  Widget listdata(snapshot, assessmentdata, TherapistProvider assesspro,
      BuildContext buildContext) {
    patientUid = assessmentdata["patient"] ?? "";
    List<Map<String, dynamic>> list = [];

    if (assessmentdata.data()["form"] != null) {
      list = List<Map<String, dynamic>>.generate(
          assessmentdata.data()["form"].length,
          (int index) => Map<String, dynamic>.from(
              assessmentdata.data()["form"].elementAt(index)));
    }

    // print(snapshot["patient"]);
    // print(snapshot);
    Widget getDate(String label, var date) {
      if (date != null) {
        return Container(
          width: double.infinity,
          child: Wrap(children: [
            Text(
              '$label ',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black45,
              ),
            ),
            Text(
              '${DateFormat.yMd().format(date.toDate())}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ]),
        );
      } else {
        if (label == "Completion Date:") {
          return Wrap(children: [
            Text(
              "$label ",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black45,
              ),
            ),
            Text(
              "Yet to be Complete",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ]);
        } else {
          return Wrap(children: [
            Text(
              "$label ",
              style: TextStyle(fontSize: 16, color: Colors.black45),
            ),
            Text(
              "Yet to be Begin",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ]);
        }
      }
    }

    Widget getAddress(var address) {
      if (address != null) {
        return Container(
          width: double.infinity,
          child: Wrap(children: [
            Text(
              'Home Address: ',
              style: TextStyle(fontSize: 16, color: Colors.black45),
            ),
            Text(
              '${(snapshot["houses"][0]["address1"] != "") ? snapshot["houses"][0]["address1"][0].toString().toUpperCase() : ""}${(snapshot["houses"][0]["address1"] != "") ? snapshot["houses"][0]["address1"].toString().substring(1) : ""},'
                      '${(snapshot["houses"][0]["address2"] != "") ? snapshot["houses"][0]["address2"][0].toString().toUpperCase() : ""}${(snapshot["houses"][0]["address2"] != "") ? snapshot["houses"][0]["address2"].toString().substring(1) : ""},'
                      '${(snapshot["houses"][0]["city"] != "") ? snapshot["houses"][0]["city"][0].toString().toUpperCase() : ""}${(snapshot["houses"][0]["city"] != "") ? snapshot["houses"][0]["city"].toString().substring(1) : ""} ' ??
                  "Home Address: Nagpur",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ]),
        );
      } else {
        return Container(
          child: Wrap(children: [
            Text(
              "Home Address: ",
              style: TextStyle(fontSize: 16, color: Colors.black45),
            ),
            Text(
              "Home Address not Availabe",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ]),
        );
      }
    }

    // assesspro.getfielddata(snapshot["patient"]);

    return Container(
      // decoration: new BoxDecoration(boxShadow: [
      //   new BoxShadow(
      //     color: Colors.grey[100],
      //     blurRadius: 15.0,
      //   ),
      // ]
      // ),
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
      // height: MediaQuery.of(context).size.height * 0.3,
      child: GestureDetector(
        child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: Colors.white,
            child: Container(
                padding: EdgeInsets.only(bottom: 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.30,
                          // color: Colors.red,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 47,
                            // backgroundImage: (imgUrl != "" && imgUrl != null)
                            //       ? new NetworkImage(imgUrl)
                            //       : Image.asset('assets/therapistavatar.png'),
                            child: ClipOval(
                              child: Image.asset('assets/therapistavatar.png'),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: VerticalDivider(
                            width: 2,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.55,
                          // color: Colors.red,
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      'Patient Name: ',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black45),
                                    ),
                                  ),
                                  Container(
                                    width: 87,
                                    child: Text(
                                      '${(snapshot["firstName"] != "") ? snapshot["firstName"][0].toString().toUpperCase() : ""}${(snapshot["firstName"] != "") ? snapshot["firstName"].toString().substring(1) : ""} '
                                              '${(snapshot["lastName"] != "") ? snapshot["lastName"][0].toString().toUpperCase() : ""}${(snapshot["lastName"] != "") ? snapshot["lastName"].toString().substring(1) : ""} ' ??
                                          "Prachi Rathi",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 2.5),
                              Divider(),
                              Container(
                                width: double.infinity,
                                child: Wrap(children: [
                                  Text(
                                    'Start Date: ',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black45),
                                  ),
                                  Text(
                                    '${DateFormat.yMd().format(assessmentdata['date'].toDate())}' ??
                                        "1/1/2021",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ]),
                              ),
                              SizedBox(height: 2.5),
                              Divider(),
                              (assessmentdata.data()[
                                              "assessmentCompletionDate"] !=
                                          "" &&
                                      assessmentdata.data()[
                                              "assessmentCompletionDate"] !=
                                          null)
                                  ? getDate(
                                      "Completion Date:",
                                      assessmentdata
                                          .data()["assessmentCompletionDate"])
                                  : SizedBox(),
                              (assessmentdata.data()[
                                              "assessmentCompletionDate"] !=
                                          "" &&
                                      assessmentdata.data()[
                                              "assessmentCompletionDate"] !=
                                          null)
                                  ? SizedBox(height: 2.5)
                                  : SizedBox(),
                              (assessmentdata.data()[
                                              "assessmentCompletionDate"] !=
                                          "" &&
                                      assessmentdata.data()[
                                              "assessmentCompletionDate"] !=
                                          null)
                                  ? Divider()
                                  : SizedBox(),
                              // getDate("Latest Change: ",
                              //     snapshot["latestChangeDate"]),
                              // SizedBox(height: 2.5),
                              // Divider(),
                              // Container(
                              //   width: double.infinity,
                              //   child: Wrap(children: [
                              //     Text(
                              //       'Status: ',
                              //       style: TextStyle(
                              //           fontSize: 16, color: Colors.black45),
                              //     ),
                              //     Text(
                              //       '${assessmentdata.data()["currentStatus"]}',
                              //       style: TextStyle(
                              //         fontSize: 16,
                              //       ),
                              //     ),
                              //   ]),
                              // ),
                              // SizedBox(height: 2.5),
                              // Divider(),

                              // getAddress(snapshot["houses"]),
                              Container(
                                child: Wrap(children: [
                                  Text(
                                    'Home Address: ',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black45),
                                  ),
                                  Text(
                                    '${assessmentdata.data()["home"]}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ]),
                              ),

                              // Container(child: Text('${dataset.data}')),
                            ],
                          ),
                        ),
                      ],
                    ),
                    getButton(
                        assessmentdata.data()["currentStatus"],
                        assessmentdata.data()["therapist"],
                        assessmentdata.data()["assessor"],
                        assessmentdata.data()["patient"],
                        list,
                        assessmentdata.data()["docID"],
                        context),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ))),
        onTap: () async {
          //   print("Hello");
          //   await assesspro.getdocref(assessmentdata);
          //   // print(assesspro.curretnassessmentdocref);
          //   // print(assessmentdata.data);

          //   if (assessmentdata.data['Status'] == "new") {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) =>
          //                 NewAssesment(assesspro.curretnassessmentdocref)));
          //   } else {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) =>
          //                 NewAssesment(assesspro.curretnassessmentdocref)));
          //   }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TherapistProvider assesspro = Provider.of<TherapistProvider>(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(10, 80, 106, 1),
          title: Text(widget.title),
          elevation: 0.0,
        ),
        backgroundColor: Colors.grey[300],
        body: (widget.status == "Pending")
            ? onGoingPendingAssess(assesspro, context)
            : (widget.status == "Scheduled")
                ? onGoingScheduledAssess(assesspro, context)
                : onGoingClosedAssess(assesspro, context)
        //     Center(
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
        //     children: <Widget>[
        //       if (recognizeFinished)
        //         _RecognizeContent(
        //           text: text,
        //         ),
        //       ElevatedButton(
        //         onPressed: recognizing ? stopRecording : streamingRecognize,
        //         child: recognizing
        //             ? const Text('Stop recording')
        //             : const Text('Start Streaming from mic'),
        //       ),
        //     ],
        //   ),
        // ),
        );
  }
}

class _RecognizeContent extends StatelessWidget {
  final String text;

  const _RecognizeContent({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          const Text(
            'The text recognized by the Google Speech Api:',
          ),
          const SizedBox(
            height: 16.0,
          ),
          Text(
            text ?? '---',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}
