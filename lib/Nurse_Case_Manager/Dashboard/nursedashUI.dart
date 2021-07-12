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
import 'package:tryapp/Therapist/Dashboard/homeAddresses.dart';
import 'package:tryapp/Therapist/Dashboard/patients.dart';
import 'package:tryapp/splash/assesment.dart';
import 'package:tryapp/constants.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../login/login.dart';

class NurseUI extends StatefulWidget {
  @override
  _NurseUIState createState() => _NurseUIState();
}

class _NurseUIState extends State<NurseUI> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  // FirebaseAuth auth = FirebaseAuth.instance;
  final firestoreInstance = Firestore.instance;
  FirebaseUser curuser;
  String name,
      curUid,
      userFirstName,
      userLastName,
      fname,
      lname,
      address,
      patientUid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();
    getPatientDetails();
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
      String assessor,
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

    if (status == "Assessment Scheduled" && assessor == curUid) {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
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
                        NewAssesment(docID, "nurse/case manager")));
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
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
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
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
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
                    builder: (context) => ReportBase(docID, patientUid)));
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
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
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
            _showSnackBar("Wait For Therapist To Provide Recommendations");
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

                        return listdata(
                            assesspro.datasetmain["$index"],
                            assesspro.dataset.documents[index],
                            assesspro,
                            context);
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
    patientUid = assessmentdata.data["patient"];
    // print(patientUid);

    List<Map<String, dynamic>> list = [];

    if (assessmentdata.data["form"] != null) {
      list = List<Map<String, dynamic>>.generate(
          assessmentdata.data["form"].length,
          (int index) => Map<String, dynamic>.from(
              assessmentdata.data["form"].elementAt(index)));
    }

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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: double.infinity,
                                child: Text(
                                  'Patient Name: ${assesspro.capitalize(snapshot["firstName"])}${assesspro.capitalize(snapshot["lastName"])}',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.5),
                              Divider(),
                              Container(
                                width: double.infinity,
                                child: Text(
                                  'Start Date: ${assessmentdata.data["date"]}' ??
                                      "11/7/2021",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.5),
                              Divider(),
                              getDate(
                                  "Completion Date: ",
                                  assessmentdata
                                      .data["assessmentCompletionDate"]),

                              // getDate("Latest Change: ",
                              //     snapshot["latestChangeDate"]),
                              SizedBox(height: 2.5),
                              Divider(),
                              Container(
                                width: double.infinity,
                                child: Text(
                                  'Status: ${assessmentdata.data["currentStatus"]}',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.5),
                              Divider(),
                              Container(
                                width: double.infinity,
                                child: Text(
                                  'Home Address: ${assesspro.capitalize(snapshot["houses"][0]["address1"])}, ${assesspro.capitalize(snapshot["houses"][0]["address2"])}, ${assesspro.capitalize(snapshot["houses"][0]["city"])} ' ??
                                      "Home Address: Nagpur",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              // Container(child: Text('${dataset.data}')),
                            ],
                          )),
                    ],
                  ),
                  getButton(
                      assessmentdata.data["currentStatus"],
                      assessmentdata.data["assessor"],
                      assessmentdata.data["patient"],
                      list,
                      assessmentdata.data["docID"],
                      buildContext),
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
                            Container(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "${assesspro.capitalize(userFirstName)}",
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
                      Container(
                        // height: 30,
                        alignment: Alignment.centerRight,
                        // width: double.infinity,
                        // color: Colors.red,
                        child: CircleAvatar(
                          radius: 47,
                          child: ClipOval(
                            child: Image.asset('assets/nurseavatar.png'),
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
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => PatientsList()))
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
                        }),
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
              ],
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
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Login()));
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
          backgroundColor: Colors.grey[200],
        ));
  }
}
