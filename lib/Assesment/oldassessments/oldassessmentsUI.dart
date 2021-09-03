import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentbase.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentrepo.dart';
import 'package:tryapp/CompleteAssessment/completeAssessmentBase.dart';
import 'package:tryapp/Nurse_Case_Manager/Dashboard/nursedash.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/patientdash.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/reportbase.dart';
import 'package:tryapp/Therapist/Dashboard/therapistdash.dart';
import 'package:tryapp/constants.dart';
import './oldassessmentspro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './oldassessmentsrepo.dart';
import 'package:provider/provider.dart';

class OldAssessmentsUI extends StatefulWidget {
  @override
  _OldAssessmentsUIState createState() => _OldAssessmentsUIState();
}

class _OldAssessmentsUIState extends State<OldAssessmentsUI> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String role;

  @override
  void initState() {
    super.initState();
    getRole();
  }

  getRole() async {
    User user = await FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((value) {
      setState(() {
        role = value['role'];
      });
    });
  }

  void _showSnackBar(snackbar, BuildContext buildContext) {
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    );
    ScaffoldMessenger.of(buildContext)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final assesspro = Provider.of<OldAssessmentsProvider>(context);
    // assesspro.getoldassess();
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        if (role == "therapist") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Therapist()));
        } else if (role == "patient") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Patient()));
        } else if (role == "nurse/case manager") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Nurse()));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: assesspro.colorgreen,
          title: Text('Assessments'),
        ),
        backgroundColor: Colors.grey[200],
        body: SingleChildScrollView(
          child: Container(
              child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                height: MediaQuery.of(context).size.height * 0.09,
                width: MediaQuery.of(context).size.height * 0.6,
                // child: Card(
                //   shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(10)),
                //   color: Colors.grey[200],
                child: Row(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.09,
                      width: MediaQuery.of(context).size.width * 0.41,
                      padding: EdgeInsets.all(7),
                      // color: Colors.red,
                      child: RaisedButton(
                        color: (!assesspro.assessdisplay)
                            ? Colors.green[600]
                            : Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                          // side: BorderSide(color: Colors.grey[200])
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Old",
                            style: TextStyle(
                                fontSize: 14.0,
                                color: (!assesspro.assessdisplay)
                                    ? Colors.white
                                    : Colors.grey[700]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onPressed: () {
                          assesspro.getstatuspatient('old', role);
                        },
                      ),
                    ),
                    // SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.09,
                      width: MediaQuery.of(context).size.width * 0.42,
                      // color: Colors.yellow,
                      padding: EdgeInsets.all(7),
                      child: RaisedButton(
                        color: (assesspro.assessdisplay)
                            ? Colors.green
                            : Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                          // side: BorderSide(color: Colors.grey[200])
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Newly Assigned",
                            style: TextStyle(
                                fontSize: 14.0,
                                color: (assesspro.assessdisplay)
                                    ? Colors.white
                                    : Colors.grey[700]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onPressed: () {
                          assesspro.getstatuspatient('new', role);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // ),
              Container(
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.fromLTRB(27, 0, 0, 0),
                  // color: Colors.red,box
                  height: MediaQuery.of(context).size.height * 0.08,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .2,
                              child: Text('Sort By',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            Container(
                              // color: Colors.pink,
                              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              height: MediaQuery.of(context).size.height,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      width: 1, style: BorderStyle.solid),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  items: [
                                    DropdownMenuItem(
                                      child: Text('Latest'),
                                      value: '',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('Location'),
                                      value: 'Address',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('Name'),
                                      value: 'name',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('Age'),
                                      value: 'Age',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('Recent'),
                                      value: 'Recent',
                                    ),
                                  ],
                                  onChanged: (value) {
                                    assesspro.getsorteddata(value, 'old');
                                  },
                                  value: assesspro.sortdata,
                                ),
                              ),
                            )
                          ],
                        ),
                      ))),
              (assesspro.assessdisplay)
                  ? newassessments(assesspro)
                  : ongoingassess(assesspro),
            ],
          )),
        ),
        // bottomNavigationBar: Padding(
        //   padding: EdgeInsets.all(8.0),
        //   child: RaisedButton(
        //     onPressed: () {
        //       String uid;
        //       NewAssesmentRepository()
        //           .setAssessmentData()
        //           .then((value) => setState(() {
        //                 if (value is String) {
        //                   uid = value.toString();
        //                 }
        //               }));
        //       Navigator.push(context,
        //           MaterialPageRoute(builder: (context) => NewAssesment(uid)));
        //     },
        //     color: Colors.green,
        //     textColor: Colors.white,
        //     child: Text('Perform Assessment'),
        //   ),
        // ),
      ),
    );
  }

  Widget ongoingassess(OldAssessmentsProvider assesspro) {
    return (assesspro.loading)
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(child: CircularProgressIndicator()))
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
                    // child: ConstrainedBox(
                    //   constraints: BoxConstraints(
                    //       maxHeight: 1000,
                    //       minHeight: MediaQuery.of(context).size.height / 10),
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: assesspro.datasetmain.length,
                      itemBuilder: (context, index1) {
                        // print(assesspro.datasetmain.length);
                        // return;
                        return listdata(assesspro.datasetmain["$index1"],
                            assesspro.dataset.docs[index1], assesspro, context);
                      },
                    ),
                  ),
                ),
              );
  }

  Widget newassessments(OldAssessmentsProvider assesspro) {
    return (assesspro.loading)
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(child: CircularProgressIndicator()))
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
                    // child: ConstrainedBox(
                    // constraints: BoxConstraints(
                    //     maxHeight: MediaQuery.of(context).size.height,
                    //     minHeight: MediaQuery.of(context).size.height / 10),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: assesspro.datasetmain.length,
                      itemBuilder: (context, index1) {
                        // print(assesspro.getdocref());
                        return listdata(assesspro.datasetmain["$index1"],
                            assesspro.dataset.docs[index1], assesspro, context);
                      },
                    ),
                  ),
                ),
              );

    // child: RaisedButton(onPressed: () {
    //   print(assesspro.datasetmain['0'].data['name']);
    // }),
  }

  Widget listdata(snapshot, assessmentdata, OldAssessmentsProvider assesspro,
      BuildContext buildContext) {
    // var data = getfield(snapshot);
    // print(snapshot);

    Widget getAddress(var address) {
      if (address != null) {
        return Container(
          width: double.infinity,
          child: Text(
            'Patient Address: ${assesspro.capitalize(address[0]["address1"])}, ${assesspro.capitalize(address[0]["address2"])}',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        );
      } else {
        return Container(
          width: double.infinity,
          child: Text(
            'Patient Address: Nagpur',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        );
      }
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

    return Container(
        // decoration: new BoxDecoration(boxShadow: [
        //   new BoxShadow(
        //     color: Colors.grey[100],
        //     blurRadius: 15.0,
        //   ),
        // ]),
        padding: EdgeInsets.all(7),
        // height: MediaQuery.of(context).size.height * 0.17,
        child: GestureDetector(
          child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.white,
              child: Container(
                  child: Row(
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
                              'Patient Name: ${assesspro.capitalize(snapshot['firstName'])}${assesspro.capitalize(snapshot["lastName"])}',
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
                              'Patient Age: ${snapshot['age'] ?? '18'}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.5),
                          Divider(),
                          getAddress(snapshot["houses"]),
                          SizedBox(height: 2.5),
                          Divider(),
                          Container(
                            width: double.infinity,
                            child: Text(
                              'Patient Contact No: ${snapshot['mobileNo']}',
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
                                  .data()['assessmentCompletionDate']),
                          SizedBox(height: 2.5),
                          Divider(),
                          Container(
                            width: double.infinity,
                            child: Text(
                              'Assessment Status: ${assessmentdata.data()['currentStatus']}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // Container(child: Text('${dataset.data}')),
                        ],
                      )),
                ],
              ))),
          onTap: () async {
            print("Hello");
            await assesspro.getdocref(assessmentdata.data());
            // print(assesspro.curretnassessmentdocref);
            // print(assessmentdata.data);
            List<Map<String, dynamic>> list = [];

            if (assessmentdata.data()["form"] != null) {
              list = List<Map<String, dynamic>>.generate(
                  assessmentdata.data()["form"].length,
                  (int index) => Map<String, dynamic>.from(
                      assessmentdata.data()["form"].elementAt(index)));
            }
            User user = await FirebaseAuth.instance.currentUser;
            if (assessmentdata.data()['currentStatus'] ==
                    "Assessment in Progress" &&
                assessmentdata.data()["assessor"] == user.uid) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CompleteAssessmentBase(
                          list, assesspro.curretnassessmentdocref, role)));
            } else if (assessmentdata.data()['currentStatus'] ==
                    "Assessment Scheduled" &&
                assessmentdata.data()["assessor"] == user.uid) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewAssesment(
                          assesspro.curretnassessmentdocref, role)));
            } else if (assessmentdata.data()['currentStatus'] ==
                "Report Generated") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReportBase(
                          assesspro.curretnassessmentdocref,
                          assessmentdata.data()["patient"],
                          list)));
            } else if (assessmentdata.data()['currentStatus'] ==
                    "Assessment Finished" &&
                assessmentdata["therapist"] == user.uid) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CompleteAssessmentBase(
                          list, assesspro.curretnassessmentdocref, role)));
              // _showSnackBar("Wait For The Therapist To Provide Recommendations",
              //     buildContext);
            } else if (assessmentdata.data()['currentStatus'] ==
                    "Assessment Finished" &&
                assessmentdata["therapist"] != user.uid) {
              _showSnackBar("Wait For The Therapist To Provide Recommendations",
                  buildContext);
            } else {
              _showSnackBar("Assessment is Yet to be Finished", buildContext);
            }
          },
        ));
  }
}
