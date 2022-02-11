import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentbase.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentrepo.dart';
import 'package:tryapp/CompleteAssessment/completeAssessmentBase.dart';
import 'package:tryapp/Nurse_Case_Manager/Dashboard/nursedashprov.dart';
import 'package:tryapp/Nurse_Case_Manager/Dashboard/nursedashrepo.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/reportbase.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/reportui.dart';
import 'package:tryapp/Therapist/Dashboard/homeAddresses.dart';
import 'package:tryapp/Therapist/Dashboard/patients.dart';
import 'package:tryapp/main.dart';
import 'package:tryapp/products.dart';
import 'package:tryapp/splash/assesment.dart';
import 'package:tryapp/constants.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../login/login.dart';
import '../../viewPhoto.dart';

class NurseUI extends StatefulWidget {
  @override
  _NurseUIState createState() => _NurseUIState();
}

class _NurseUIState extends State<NurseUI> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  // FirebaseAuth auth = FirebaseAuth.instance;
  final firestoreInstance = FirebaseFirestore.instance;
  User curuser;
  String name,
      curUid,
      userFirstName,
      userLastName,
      fname,
      lname,
      address,
      patientUid;
  String imgUrl = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setImage();
    getUserDetails();
    getPatientDetails();
    getCurrentUid();
  }

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
          // address = (value["houses"][0]["city"].toString());
        });
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
    final User useruid = await _auth.currentUser;
    setState(() {
      curUid = useruid.uid;
    });
  }

  Widget getButton(
      String status,
      String assessor,
      String patientUid,
      String therapistUid,
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

    if (status == "Assessment Scheduled" && assessor == curUid) {
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
                        NewAssesment(docID, "nurse/case manager", null)));
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
    } else if (status == "Assessment in Progress" && curUid == assessor) {
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
                    builder: (context) => CompleteAssessmentBase(
                        list, docID, "nurse/case manager")));
            // print(list);
            // print("nurse index : ${list.length}");
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
    } else if (status == "Report Generated") {
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
    } else if (status == "Assessment Finished" && assessor == curUid) {
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
            "Assessment Finished",
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

  Widget ongoingassess(NurseProvider assesspro, BuildContext bcontext) {
    // assesspro.getstatuspatient("nurse/case manager");
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
            : Container(
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

                        return listdata(assesspro.datasetmain["$index"],
                            assesspro.dataset.docs[index], assesspro, context);
                        // return listdata(assesspro.datasetmain[index],
                        //     assesspro.datasetmain[index], assesspro, context);
                      },
                    ),
                  ),
                ),
              ));
  }

  Widget listdata(snapshot, assessmentdata, NurseProvider assesspro,
      BuildContext buildContext) {
    patientUid = assessmentdata.data()["patient"];
    // print(patientUid);

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
          // width: double.infinity,
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

    // assesspro.getfielddata(snapshot["patient"]);

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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                child: Wrap(children: [
                                  Text(
                                    'Patient Name: ',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black45),
                                  ),
                                  Text(
                                    '${(snapshot["firstName"].toString() != "") ? snapshot["firstName"][0].toString().toUpperCase() : ""}${(snapshot["firstName"].toString() != "") ? snapshot["firstName"].toString().substring(1) : ""} '
                                    '${(snapshot["lastName"].toString() != "") ? snapshot["lastName"][0].toString().toUpperCase() : ""}${(snapshot["lastName"].toString() != "") ? snapshot["lastName"].toString().substring(1) : ""}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ]),
                              ),
                              SizedBox(height: 2.5),
                              Divider(),
                              getDate('Start Date: ',
                                  assessmentdata.data()["date"]),
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

                              // getDate("Latest Change: ",
                              //     snapshot["latestChangeDate"]),
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
                              Container(
                                width: double.infinity,
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
                          )),
                    ],
                  ),
                  getButton(
                      assessmentdata.data()["currentStatus"],
                      assessmentdata.data()["assessor"],
                      assessmentdata.data()["patient"],
                      assessmentdata.data()["therapist"],
                      list,
                      assessmentdata.data()["docID"],
                      buildContext),
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
        ));
  }

  @override
  Widget build(BuildContext context) {
    NurseProvider assesspro = Provider.of<NurseProvider>(context);

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
                                  padding: EdgeInsets.only(top: 60),
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
                                  child: (userFirstName != null &&
                                          userFirstName != '')
                                      ? Text(
                                          '${userFirstName[0].toUpperCase()}${userFirstName.substring(1)}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 37,
                                          ),
                                        )
                                      : Text("Nurse"),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 7),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ViewPhoto(
                                      imgUrl ?? "", "nurse/case manager")));
                            },
                            child: Container(
                              padding: EdgeInsets.only(top: 0),
                              // alignment: Alignment.centerRight,
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
                                      : Image.asset('assets/nurseavatar.png'),
                                ),
                              ),
                            ),
                          ),
                          // Container(
                          //   // height: 30,
                          //   alignment: Alignment.centerRight,
                          //   // width: double.infinity,
                          //   // color: Colors.red,
                          //   child: CircleAvatar(
                          //     radius: 47,
                          //     child: ClipOval(
                          //       child: Image.asset('assets/nurseavatar.png'),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      // child: Text("$name"),
                      //
                    ),
                  ),
                  // ListTile(
                  //   leading: Icon(Icons.favorite, color: Colors.green),
                  //   title: Text(
                  //     'Patients/Caregivers/Families',
                  //     style: TextStyle(fontSize: 18),
                  //   ),
                  //   onTap: () => {
                  //     Navigator.of(context).push(
                  //         MaterialPageRoute(builder: (context) => PatientsList()))
                  //   },
                  // ),
                  // ListTile(
                  //     leading: Icon(Icons.home, color: Colors.green),
                  //     title: Text(
                  //       'Home Addresses',
                  //       style: TextStyle(fontSize: 18),
                  //     ),
                  //     onTap: () => {
                  //           Navigator.of(context).push(MaterialPageRoute(
                  //               builder: (context) => HomeAddresses()))
                  //         }),
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
                                  AssesmentSplashScreen("nurse/case manager")))
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.assessment, color: Colors.green),
                    title: Text(
                      'Products',
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () => {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Products()))
                    },
                  ),
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
                highlightColor: Colors.transparent,
                icon: Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                onPressed: () async {
                  try {
                    await _auth.signOut();
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
          body: ongoingassess(assesspro, context),
          backgroundColor: Colors.grey[300],
        ));
  }
}
