import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tryapp/CompleteAssessment/completeAssessmentBase.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/feedback.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/homeAddress.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/patientdashprov.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/reportui.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/requestAssessment.dart';
import 'package:tryapp/constants.dart';
import 'package:tryapp/main.dart';
import '../../splash/assesment.dart';
import '../../Assesment/newassesment/newassesmentbase.dart';
import '../../login/login.dart';
import '../../viewPhoto.dart';

class PatientUI extends StatefulWidget {
  @override
  _PatientUIState createState() => _PatientUIState();
}

class _PatientUIState extends State<PatientUI> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final firestoreInstance = FirebaseFirestore.instance;
  User curuser;
  var fname, lname, curUid, address, therapistUid, theraFName, theraLName;
  String imgUrl = "";
  String requestedTherapistNames;
  String recommendationTherapistNames;
  String waitingTherapistNames;
  String assessingTherapist;
  String assessingCasemanager;

  @override
  void initState() {
    super.initState();
    setImage();
    getUserName();
    getCurrentUid();
    // print("First name: " + fname);
    Future.delayed(Duration(seconds: 10), () async {
      if (requestedTherapistNames != null) {
        await showDialog<String>(
          context: context,
          builder: (BuildContext context) => new AlertDialog(
            title: new Text("Wait!"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    '$requestedTherapistNames will soon begin your assessment. You will then be able to see your assessment report',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w300)),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      } else if (recommendationTherapistNames != null) {
        await showDialog<String>(
          context: context,
          builder: (BuildContext context) => new AlertDialog(
            title: new Text("Wait!"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    '$recommendationTherapistNames will soon give recommendation to your assessment. You will then be able to see your assessment report',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w300)),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      } else if (waitingTherapistNames != null) {
        await showDialog<String>(
          context: context,
          builder: (BuildContext context) => new AlertDialog(
            title: new Text("Wait!"),
            content: Container(
              // height: MediaQuery.of(context).size.height * 0.3,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                        '$waitingTherapistNames will soon complete your assessment. You will then be able to see your assessment report',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      } else if (assessingTherapist != null && assessingCasemanager != null) {
        await showDialog<String>(
          context: context,
          builder: (BuildContext context) => new AlertDialog(
            title: new Text("Wait!"),
            content: Container(
              // height: MediaQuery.of(context).size.height * 0.3,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                        "You will be able to view your assessment report once $assessingCasemanager conducts your assessment and $assessingTherapist provides recommendation on the same.",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    });
  }

  Future<void> setImage() async {
    final User useruid = await auth.currentUser;
    firestoreInstance.collection("users").doc(useruid.uid).get().then((value) {
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

  Future<String> getUserName() async {
    final User useruid = await auth.currentUser;
    firestoreInstance.collection("users").doc(useruid.uid).get().then(
      (value) {
        setState(() {
          fname = (value.data()["firstName"].toString());
          lname = (value.data()["lastName"].toString());
          address = (value.data()["houses"]);
          // imgUrl = (value["url"].toString()) ?? "";
          // print("**************imageUrl = $imgUrl");
        });
      },
    );
  }

  Future<void> getTherapistDetails() async {
    final User useruid = await auth.currentUser;
    if (therapistUid != null) {
      firestoreInstance.collection("users").doc(therapistUid).get().then(
        (value) {
          setState(() {
            theraFName = (value.data()["firstName"].toString());
            theraLName = (value.data()["lastName"].toString());
          });
        },
      );
    }
    // print(therapistUid);
  }

  Future<void> getCurrentUid() async {
    final User useruid = await auth.currentUser;
    setState(() {
      curUid = useruid.uid;
    });
  }

  Widget getButton(
      String status,
      String patientUid,
      String assessorUid,
      String therapistUid,
      List<Map<String, dynamic>> list,
      String docID,
      BuildContext buildContext,
      PatientProvider assesspro) {
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      );
      ScaffoldMessenger.of(buildContext)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }

    if (status == "Assessment Scheduled" && curUid == assessorUid) {
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
                        NewAssesment(docID, "patient", null)));
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
    }
    if (status == "Assessment Scheduled" && curUid != assessorUid) {
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
            _showSnackBar("Assessor will begin the assessment soon");
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
    } else if (status == "Assessment in Progress" && curUid == assessorUid) {
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
                        CompleteAssessmentBase(list, docID, "patient")));
          },
          child: Text(
            "Complete Assessment",
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10),
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
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10),
              ),
              // padding: EdgeInsets.symmetric(
              //   vertical: 10,
              //   horizontal: 10,
              // ),
              elevation: 3,
              color: Color.fromRGBO(10, 80, 106, 1),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => FeedbackDialogWidget(
                        therapistUid, patientUid, docID, assesspro),
                    barrierDismissible: true);
              },
              child: Text(
                "Feedback",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (status == "Assessment Finished" && curUid == assessorUid) {
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
            _showSnackBar("Wait for the therapist to provide recommendations");
          },
          child: Text(
            "Form Filled",
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
            _showSnackBar("Wait for the therapist to provide recommendations");
          },
          child: Text(
            "Form Filled",
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

  Widget ongoingassess(PatientProvider assesspro, BuildContext buildContext) {
    // print(assesspro.datasetmain.length);
    return (assesspro.loading)
        ? Center(child: CircularProgressIndicator())
        : (assesspro.datasetmain.length == 0)
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
            : Stack(children: [
                Container(
                    child: Container(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: 1000,
                          minHeight: MediaQuery.of(context).size.height / 10),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: assesspro.datasetmain.length,
                        itemBuilder: (context, index) {
                          // print(assesspro.datasetmain.length);
                          // return;
                          return listdata(
                              assesspro.datasetmain["$index"],
                              assesspro.dataset.docs[index],
                              assesspro,
                              context);
                        },
                      ),
                    ),
                  ),
                )),
              ]);
  }

  Widget listdata(snapshot, assessmentdata, PatientProvider assesspro,
      BuildContext buildContext) {
    therapistUid = assessmentdata.data()["therapist"] ?? "";

    List<Map<String, dynamic>> list = [];

    if (assessmentdata.data()["form"] != null) {
      list = List<Map<String, dynamic>>.generate(
          assessmentdata.data()["form"].length,
          (int index) => Map<String, dynamic>.from(
              assessmentdata.data()["form"].elementAt(index)));
    }

    Widget getDate(String label, var date) {
      if (date != null) {
        return Container(
          child: Wrap(children: [
            Text(
              '$label ',
              style: TextStyle(fontSize: 16, color: Colors.black45),
            ),
            Text(
              '${DateFormat.yMd().format(date.toDate())} ',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ]),
        );
      } else {
        if (label == "Completion Date: ") {
          return Container(
            child: Wrap(children: [
              Text(
                "$label ",
                style: TextStyle(fontSize: 16, color: Colors.black45),
              ),
              Text(
                "Yet to be Complete",
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
                "$label ",
                style: TextStyle(fontSize: 16, color: Colors.black45),
              ),
              Text(
                "Yet to be Begin",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ]),
          );
        }
      }
    }

    Widget getAddress(var address1) {
      if (address1 != null) {
        return Container(
          child: Wrap(children: [
            Text(
              'Patient Home Address: ',
              style: TextStyle(fontSize: 16, color: Colors.black45),
            ),
            Text(
              // ${name[0].toUpperCase()}${name.substring(1)}
              '${(address1[0]["address1"] != "") ? address1[0]["address1"][0].toString().toUpperCase() : ""}'
                      '${(address1[0]["address1"] != "") ? address1[0]["address1"].toString().substring(1) : ""},'
                      '${(address1[0]["address2"] != "") ? address1[0]["address2"][0].toString().toUpperCase() : ""}${(address1[0]["address2"] != "") ? address1[0]["address2"].toString().substring(1) : ""},'
                      '${(address1[0]["city"] != "") ? address1[0]["city"][0].toString().toUpperCase() : ""}${(address1[0]["city"] != "") ? address1[0]["city"].toString().substring(1) : ""} ' ??
                  "Patient Home Address: Nagpur",
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

    Widget getName(var snap) {
      if (snap != null) {
        return Container(
          width: double.infinity,
          child: Wrap(children: [
            Text(
              'Assessing Therapist: ',
              style: TextStyle(fontSize: 16, color: Colors.black45),
            ),
            Text(
              '${(snap["firstName"] != "") ? snap["firstName"][0].toString().toUpperCase() : ""}${(snap["firstName"] != "") ? snap["firstName"].toString().substring(1) : ""} '
              '${(snap["lastName"] != "") ? snap["lastName"][0].toString().toUpperCase() : ""}${(snap["lastName"] != "") ? snap["lastName"].toString().substring(1) : ""} ',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ]),
        );
      } else {
        return Container(
          width: double.infinity,
          child: Wrap(children: [
            Text(
              'Assessing Therapist: ',
              style: TextStyle(fontSize: 16, color: Colors.black45),
            ),
            Text(
              'Therapist',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ]),
        );
      }
    }

    // if (assesspro.data2 == null) {
    //   return Container(
    //     width: MediaQuery.of(context).size.width,
    //     height: MediaQuery.of(context).size.height,
    //     child: Padding(
    //       padding: EdgeInsets.only(top: 0),
    //       child:
    //           Stack(alignment: AlignmentDirectional.center, children: <Widget>[
    //         Positioned(
    //             width: MediaQuery.of(context).size.width * .5,
    //             height: MediaQuery.of(context).size.height * .5,
    //             child: Center(child: Text("Loading Data......"))),
    //       ]),
    //     ),
    //   );
    // } else {
    return Container(
        // decoration: new BoxDecoration(boxShadow: [
        //   new BoxShadow(
        //     color: Colors.grey[200],
        //     blurRadius: 15.0,
        //   ),
        // ]),
        padding: EdgeInsets.only(top: 5, left: 5, right: 5),
        // height: MediaQuery.of(context).size.height * 0.3,
        child: GestureDetector(
          child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.white,
              child: Container(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getName(snapshot),
                              SizedBox(height: 2.5),
                              Divider(),
                              // getAddress(address),
                              // SizedBox(height: 2.5),
                              // Divider(),
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
                              SizedBox(height: 2.5),
                              Divider(),
                              (assessmentdata.data()[
                                              "assessmentCompletionDate"] !=
                                          null &&
                                      assessmentdata.data()[
                                              "assessmentCompletionDate"] !=
                                          "")
                                  ? getDate(
                                      "Completion Date: ",
                                      assessmentdata
                                          .data()["assessmentCompletionDate"])
                                  : SizedBox(),
                              (assessmentdata.data()[
                                              "assessmentCompletionDate"] !=
                                          null &&
                                      assessmentdata.data()[
                                              "assessmentCompletionDate"] !=
                                          "")
                                  ? SizedBox(height: 2.5)
                                  : SizedBox(),
                              (assessmentdata.data()[
                                              "assessmentCompletionDate"] !=
                                          null &&
                                      assessmentdata.data()[
                                              "assessmentCompletionDate"] !=
                                          "")
                                  ? Divider()
                                  : SizedBox(),
                              Container(
                                child: Wrap(children: [
                                  Text(
                                    'Status: ',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black45),
                                  ),
                                  Text(
                                    '${assessmentdata.data()["currentStatus"] == "Assessment Finished" ? "Form Filled" : assessmentdata.data()["currentStatus"]}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ]),
                              ),
                              // SizedBox(height: 2.5),
                              // Divider(),
                              // Container(
                              //   width: double.infinity,
                              //   child: Text(
                              //     'Home Address : ${assesspro.data2["houses"][0]["address1"]}' ??
                              //         "Mangalwari Bazaar" +
                              //             "," +
                              //             ' ${assesspro.data2["houses"][0]["address2"]}' ??
                              //         "Sadar" +
                              //             "," +
                              //             ' ${assesspro.data2["houses"][0]["city"]}' ??
                              //         "Nagpur",
                              //     style: TextStyle(
                              //       fontSize: 16,
                              //     ),
                              //   ),
                              // ),
                              // Container(child: Text('${dataset.data}')),
                            ],
                          )),
                    ],
                  ),
                  getButton(
                      assessmentdata.data()["currentStatus"],
                      assessmentdata.data()["patient"],
                      assessmentdata.data()["assessor"],
                      assessmentdata.data()["therapist"],
                      list,
                      assessmentdata.data()["docID"],
                      buildContext,
                      assesspro),
                  SizedBox(height: 10),
                  assessmentdata.data()["currentStatus"] ==
                          "Assessment Finished"
                      ? Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text(
                              "Report will be generated once therapist provides the recommendations",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color.fromRGBO(10, 80, 106, 1),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        )
                      : SizedBox(),
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
        ));
  }

  @override
  Widget build(BuildContext context) {
    PatientProvider assesspro = Provider.of<PatientProvider>(context);
    if (!assesspro.loading) {
      setState(() {
        requestedTherapistNames = assesspro.requestedTherapistNames;
        recommendationTherapistNames = assesspro.recommendationTherapistNames;
        waitingTherapistNames = assesspro.waitingTherapistNames;
        assessingTherapist = assesspro.assessingTherapist;
        assessingCasemanager = assesspro.assessingCasemanager;
      });
    }
    print("Widget asessingTherapist: $assessingTherapist");
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          drawer: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: DrawerHeader(
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
                                  padding: EdgeInsets.only(top: 40),
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
                                    "${assesspro.capitalize(fname)}",
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
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      ViewPhoto(imgUrl ?? "", "patient")));
                            },
                            child: Container(
                              // height: 30,
                              padding: EdgeInsets.only(top: 30),
                              alignment: Alignment.topRight,
                              // width: double.infinity,
                              // color: Colors.red,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 47,
                                // backgroundImage: (imgUrl != "" && imgUrl != null)
                                //     ? NetworkImage(imgUrl)
                                //     : Image.asset('assets/therapistavatar.png'),
                                child: ClipOval(
                                  clipBehavior: Clip.hardEdge,
                                  child: (imgUrl != "" && imgUrl != null)
                                      ? CachedNetworkImage(
                                          imageUrl: imgUrl,
                                          fit: BoxFit.cover,
                                          width: 400,
                                          height: 400,
                                          placeholder: (context, url) =>
                                              new CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              new Icon(Icons.error),
                                        )
                                      : Image.asset(
                                          'assets/patientavatar.png',
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // child: Text("$name"),
                      //
                    ),
                  ),
                  // ListTile(
                  //   leading: Icon(Icons.favorite, color: Colors.green),
                  //   title: Text(
                  //     'Provide Medical History',
                  //     style: TextStyle(fontSize: 18),
                  //   ),
                  //   onTap: () => {
                  //     Navigator.of(context).push(MaterialPageRoute(
                  //         builder: (context) => ProvideMedicalHistory()))
                  //   },
                  // ),
                  ListTile(
                    leading: Icon(Icons.home, color: Colors.green),
                    title: Text(
                      'Home Addresses',
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeAddress()))
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.assessment, color: Colors.green),
                    title: Text(
                      'Request assesment',
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RequestAssessment()))
                    },
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
                              builder: (context) =>
                                  AssesmentSplashScreen("patient")))
                    },
                  ),
                  // ListTile(
                  //   leading: Icon(Icons.pages, color: Colors.green),
                  //   title: Text(
                  //     'View Report',
                  //     style: TextStyle(fontSize: 18),
                  //   ),
                  //   onTap: () => {
                  //     //   Navigator.push(context,
                  //     //       MaterialPageRoute(builder: (context) => ReportBase(list)))
                  //   },
                  // ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            title: Text('Dashboard'),
            // automaticallyImplyLeading: false,
            backgroundColor: Color.fromRGBO(10, 80, 106, 1),
            elevation: 0.0,

            actions: [
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                highlightColor: Colors.transparent,
                onPressed: () async {
                  try {
                    await auth.signOut();
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => MyHomePage()));
                  } catch (e) {
                    print(e.toString());
                  }
                },
                // label: Text(
                //   'logout',
                //   style: TextStyle(color: Colors.white, fontSize: 16),
                // ),
              )
            ],
          ),
          backgroundColor: Colors.grey[300],
          body: ongoingassess(assesspro, context),
        ));
  }
}
