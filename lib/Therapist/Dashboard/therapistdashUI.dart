import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentbase.dart';
import 'package:tryapp/CompleteAssessment/completeAssessmentBase.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/reportbase.dart';
import 'package:tryapp/Therapist/Dashboard/therapistdashrepo.dart';
import 'package:tryapp/Therapist/Dashboard/therapistpro.dart';
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
  var name, patientName;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserName();
  }

  Future<String> getUserName() async {
    final FirebaseUser useruid = await _auth.currentUser();
    firestoreInstance.collection("users").document(useruid.uid).get().then(
      (value) {
        setState(() {
          name = (value["name"].toString()).split(" ")[0];
        });
      },
    );
  }

  String getPatientName(String uid) {
    firestoreInstance.collection("users").document(uid).get().then((value) {
      setState() {
        patientName = value.data["name"];
      }

      print('Value data = ${value.data["name"]}');
    });
    return patientName;
  }

  Widget getButton(String status, String uid, List<Map<String, dynamic>> list,
      String docID) {
    if (status == "Assessment Scheduled") {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(5),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          elevation: 0,
          color: Color.fromRGBO(10, 80, 106, 1),
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => FirstFloorNorth()),
            // );
          },
          child: Text(
            "Assessment is Yet to be Finished",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      );
    } else if (status == "Assessment in Progress") {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(5),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          elevation: 0,
          color: Color.fromRGBO(10, 80, 106, 1),
          onPressed: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => CompleteAssessmentBase(list, docID)));
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
            borderRadius: new BorderRadius.circular(5),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          elevation: 0,
          color: Color.fromRGBO(10, 80, 106, 1),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ReportBase()));
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
                  padding: EdgeInsets.only(top: 5, left: 5, right: 5),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: 1000,
                        minHeight: MediaQuery.of(context).size.height / 10),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: assesspro.datasetmain.length,
                      itemBuilder: (context, index) {
                        // print(assesspro.datasetmain.length);
                        // return;
                        return listdata(assesspro.datasetmain[index],
                            assesspro.datasetmain[index], assesspro);
                      },
                    ),
                  ),
                ),
              ));
  }

  Widget listdata(snapshot, assessmentdata, assesspro) {
    // var data = getfield(snapshot);
    // // print(snapshot);
    final TherapistRepository therapistRepository = TherapistRepository();
    var data;
    getData() async {
      data = await therapistRepository.getfielddata(snapshot);
      setState(() {});
      print(data);
    }
    var list = snapshot["form"];
    List<Map<String, dynamic>> listData = new List<Map<String, dynamic>>.from(list);
    
    print(snapshot["patient"]); 
        print(snapshot);
    return Container(
        decoration: new BoxDecoration(boxShadow: [
          new BoxShadow(
            color: Colors.grey[200],
            blurRadius: 15.0,
          ),
        ]),
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
                                  'Patient Name: "Patient"',
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
                                  'Completion Date: ${snapshot["assessmentCompletionDate"].toDate()}',
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
                                  'Latest Change : ${snapshot["latestChangeDate"].toDate()}',
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
                                  'Status : ${snapshot["currentStatus"]}',
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
                                  'Home Address : ${snapshot["home"]}',
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
                  // getButton(snapshot["currentStatus"], snapshot["therapist"],
                  //     list, snapshot["docID"]),
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
    TherapistProvider assesspro = Provider.of<TherapistProvider>(context);
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
                                  "$name",
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
                    onTap: () => {},
                  ),
                  ListTile(
                    leading: Icon(Icons.home, color: Colors.green),
                    title: Text(
                      'Home Addresses',
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () => {Navigator.of(context).pop()},
                  ),
                  ListTile(
                    leading: Icon(Icons.people, color: Colors.green),
                    title: Text(
                      'Nurses/Case Managers',
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () => {Navigator.of(context).pop()},
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
                              builder: (context) => AssesmentSplashScreen()))
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
                FlatButton.icon(
                  icon: Icon(Icons.logout),
                  onPressed: () async {
                    try {
                      await _auth.signOut();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => Login()));
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  label: Text('Logout'),
                )
              ],
            ),
            backgroundColor: Colors.grey[300],
            body: ongoingassess(assesspro)));
  }
}
