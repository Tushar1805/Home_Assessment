import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentbase.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentrepo.dart';
import 'package:tryapp/Nurse_Case_Manager/Dashboard/nursedash.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/patientdash.dart';
import 'package:tryapp/Therapist/Dashboard/therapistdash.dart';
import './oldassessmentspro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './oldassessmentsrepo.dart';
import 'package:provider/provider.dart';

class OldAssessmentsUI extends StatefulWidget {
  @override
  _OldAssessmentsUIState createState() => _OldAssessmentsUIState();
}

class _OldAssessmentsUIState extends State<OldAssessmentsUI> {
  final Firestore firestore = Firestore.instance;
  String role;

  @override
  void initState() {
    super.initState();
    getRole();
  }

  getRole() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    var type = await Firestore.instance
        .collection('users')
        .document(user.uid)
        .get()
        .then((value) {
      setState(() {
        role = value.data['role'];
      });
    });
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
        } else if (role == "nurse") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Nurse()));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: assesspro.colorgreen,
          title: Text('Assessments'),
        ),
        body: SingleChildScrollView(
          child: Container(
              child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(25, 5, 25, 5),
                height: MediaQuery.of(context).size.height * 0.09,
                width: MediaQuery.of(context).size.height * 0.6,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: Colors.grey[300],
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
                              : Colors.grey[200],
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
                            assesspro.getstatuspatient('old');
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
                              : Colors.grey[200],
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
                            assesspro.getstatuspatient('new');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
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
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(8.0),
          child: RaisedButton(
            onPressed: () {
              String uid;
              NewAssesmentRepository()
                  .setAssessmentData()
                  .then((value) => setState(() {
                        if (value is String) {
                          uid = value.toString();
                        }
                      }));
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NewAssesment(uid)));
            },
            color: Colors.green,
            textColor: Colors.white,
            child: Text('Perform Assessment'),
          ),
        ),
      ),
    );
  }

  Widget ongoingassess(assesspro) {
    return (assesspro.loading)
        ? CircularProgressIndicator()
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
                  padding: EdgeInsets.all(15),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: 1000,
                        minHeight: MediaQuery.of(context).size.height / 10),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: assesspro.datasetmain.length,
                      itemBuilder: (context, index1) {
                        // print(assesspro.datasetmain.length);
                        // return;
                        return listdata(assesspro.datasetmain["$index1"],
                            assesspro.dataset.documents[index1], assesspro);
                      },
                    ),
                  ),
                ),
              ));
  }

  Widget newassessments(assesspro) {
    return (assesspro.loading)
        ? CircularProgressIndicator()
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
                  padding: EdgeInsets.all(15),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: 1000,
                        minHeight: MediaQuery.of(context).size.height / 10),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: assesspro.datasetmain.length,
                      itemBuilder: (context, index1) {
                        // print(assesspro.getdocref());
                        return listdata(assesspro.datasetmain["$index1"],
                            assesspro.dataset.documents[index1], assesspro);
                      },
                    ),
                  ),
                ),
              )

                // child: RaisedButton(onPressed: () {
                //   print(assesspro.datasetmain['0'].data['name']);
                // }),
                );
  }

  Widget listdata(snapshot, assessmentdata, assesspro) {
    // var data = getfield(snapshot);
    // print(snapshot);
    return Container(
        decoration: new BoxDecoration(boxShadow: [
          new BoxShadow(
            color: Colors.grey[300],
            blurRadius: 15.0,
          ),
        ]),
        padding: EdgeInsets.all(7),
        height: MediaQuery.of(context).size.height * 0.17,
        child: GestureDetector(
          child: Card(
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
                              'Name: ${snapshot['name']}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.5),
                          Container(
                            width: double.infinity,
                            child: Text(
                              'Age:${snapshot['Age']}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.5),
                          Container(
                            width: double.infinity,
                            child: Text(
                              'Address:${snapshot['Address']}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.5),
                          Container(
                            width: double.infinity,
                            child: Text(
                              'Contact No:${snapshot['Details']['Contact Number']}',
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
            await assesspro.getdocref(assessmentdata);
            // print(assesspro.curretnassessmentdocref);
            // print(assessmentdata.data);

            if (assessmentdata.data['Status'] == "new") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NewAssesment(assesspro.curretnassessmentdocref)));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NewAssesment(assesspro.curretnassessmentdocref)));
            }
          },
        ));
  }
}
