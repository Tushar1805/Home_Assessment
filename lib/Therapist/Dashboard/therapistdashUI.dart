import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tryapp/Assesment/newassesment/cardsUI.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentbase.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentui.dart';
import 'package:tryapp/CompleteAssessment/completeAssessmentBase.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/reportbase.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/reportui.dart';
import 'package:tryapp/Therapist/Dashboard/homeAddresses.dart';
import 'package:tryapp/Therapist/Dashboard/nurses.dart';
import 'package:tryapp/Therapist/Dashboard/patients.dart';
import 'package:tryapp/Therapist/Dashboard/therapistdashrepo.dart';
import 'package:tryapp/Therapist/Dashboard/therapistpro.dart';
import 'package:tryapp/constants.dart';
import 'package:tryapp/splash/assesment.dart';
import 'package:tryapp/splash/midassessment.dart';
import '../../login/login.dart';

class TherapistUI extends StatefulWidget {
  @override
  _TherapistUIState createState() => _TherapistUIState();
}

class _TherapistUIState extends State<TherapistUI> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  // FirebaseAuth auth = FirebaseAuth.instance;
  final firestoreInstance = Firestore.instance;
  FirebaseUser curuser;
  var fname, lname, address, userFirstName, userLastName, curUid, patientUid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();
    getCurrentUid();
    getCurrentUid();
  }

  Future<void> getUserDetails() async {
    final FirebaseUser useruid = await _auth.currentUser();
    firestoreInstance.collection("users").document(useruid.uid).get().then(
      (value) {
        setState(() {
          userFirstName = (value["firstName"].toString());
          userLastName = (value["lastName"].toString());
          // address = (value["houses"][0]["city"].toString());
        });
      },
    );
  }

  Future<void> getPatientDetails() async {
    final FirebaseUser useruid = await _auth.currentUser();
    if (patientUid != null) {
      firestoreInstance.collection("users").document(patientUid).get().then(
        (value) {
          setState(() {
            fname = (value["firstName"].toString());
            lname = (value["lastName"].toString());
            address = (value["houses"][0]["city"].toString());
          });
        },
      );
    }
  }

  Future<void> getCurrentUid() async {
    final FirebaseUser useruid = await _auth.currentUser();
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
                    builder: (context) => NewAssesment(docID, "therapist")));
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
            _showSnackBar("Wait For The Assessor To Finish The Assessment");
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
            _showSnackBar("Wait For The Assessor To Finish The Assessment");
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
                    builder: (context) => ReportUI(docID, patientUid, list)));
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

  Widget ongoingassess(TherapistProvider assesspro) {
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
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: assesspro.datasetmain.length,
                      itemBuilder: (context, index) {
                        // print(assesspro.datasetmain.length);
                        // return;
                        // return listdata(assesspro.datasetmain[index],
                        //     assesspro.datasetmain[index], assesspro);
                        return listdata(
                            assesspro.datasetmain["$index"],
                            assesspro.dataset.documents[index],
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
    patientUid = assessmentdata.data["patient"] ?? "";
    List<Map<String, dynamic>> list = [];

    if (assessmentdata.data["form"] != null) {
      list = List<Map<String, dynamic>>.generate(
          assessmentdata.data["form"].length,
          (int index) => Map<String, dynamic>.from(
              assessmentdata.data["form"].elementAt(index)));
    }
    // print(snapshot["patient"]);
    // print(snapshot);
    Widget getDate(String label, var date) {
      if (date != null) {
        return Container(
          width: double.infinity,
          child: Text(
            '$label ${DateFormat.yMd().format(date.toDate())} ',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        );
      } else {
        if (label == "Completion Date:") {
          return Text(
            "$label Yet to be Complete",
            style: TextStyle(
              fontSize: 16,
            ),
          );
        } else {
          return Text(
            "$label Yet to be Begin",
            style: TextStyle(
              fontSize: 16,
            ),
          );
        }
      }
    }

    Widget getAddress(var address) {
      if (address != null) {
        return Container(
          width: double.infinity,
          child: Text(
            'Home Address : ${assesspro.capitalize(snapshot["houses"][0]["address1"])}, ${assesspro.capitalize(snapshot["houses"][0]["address2"])}, ${assesspro.capitalize(snapshot["houses"][0]["city"])} ' ??
                "Home Address: Nagpur",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        );
      } else {
        return Container(
          child: Text(
            "Home Address: Home Address not Availabe",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
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
                              Container(
                                child: Row(
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        'Patient Name: fhueuigtila',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black45),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        '${assesspro.capitalize(snapshot["firstName"])}${assesspro.capitalize(snapshot["lastName"])}',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 2.5),
                              Divider(),
                              Container(
                                width: double.infinity,
                                child: Text(
                                  'Start Date: ${assessmentdata.data["date"]}' ??
                                      "1/1/2021",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.5),
                              Divider(),
                              getDate(
                                  "Completion Date:",
                                  assessmentdata
                                      .data["assessmentCompletionDate"]),
                              SizedBox(height: 2.5),
                              Divider(),
                              // getDate("Latest Change: ",
                              //     snapshot["latestChangeDate"]),
                              // SizedBox(height: 2.5),
                              // Divider(),
                              Container(
                                width: double.infinity,
                                child: Text(
                                  'Status : ${assessmentdata.data["currentStatus"]}',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.5),
                              Divider(),

                              getAddress(snapshot["houses"]),

                              // Container(child: Text('${dataset.data}')),
                            ],
                          ),
                        ),
                      ],
                    ),
                    getButton(
                        assessmentdata.data["currentStatus"],
                        assessmentdata.data["therapist"],
                        assessmentdata.data["assessor"],
                        assessmentdata.data["patient"],
                        list,
                        assessmentdata.data["docID"],
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
    Widget getName(String name) {
      if (name != null) {
        return Container(
          alignment: Alignment.bottomLeft,
          child: Text(
            "${assesspro.capitalize(name)}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 37,
            ),
          ),
        );
      } else {
        return Container(
          alignment: Alignment.bottomLeft,
          child: Text(
            "Therapist",
            style: TextStyle(
              color: Colors.white,
              fontSize: 37,
            ),
          ),
        );
      }
    }

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
                              getName(userFirstName),
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
                            backgroundColor: Colors.white,
                            radius: 47,
                            child: ClipOval(
                              child: Image.asset('assets/therapistavatar.png'),
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
                    onTap: () => {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PatientsList()))
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.home, color: Colors.green),
                    title: Text(
                      'Home Addresses',
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () => {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => HomeAddresses()))
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.people, color: Colors.green),
                    title: Text(
                      'Nurses/Case Managers',
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () => {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => NursesList()))
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
                                  AssesmentSplashScreen("therapist")))
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.pages, color: Colors.green),
                    title: Text(
                      'Report',
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () => {Navigator.of(context).pop()},
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(10, 80, 106, 1),
              title: Text('Dashboard'),
              elevation: 0.0,
              actions: [
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    try {
                      await _auth.signOut();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => Login()));
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  // label: Text(
                  //   'Logout',
                  //   style: TextStyle(color: Colors.white, fontSize: 16),
                  // ),
                )
              ],
            ),
            backgroundColor: Colors.grey[300],
            body: ongoingassess(assesspro)));
  }
}
