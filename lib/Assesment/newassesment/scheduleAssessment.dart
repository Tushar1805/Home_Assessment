import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tryapp/Nurse_Case_Manager/Dashboard/nurseDetails.dart';
import 'package:tryapp/Patient_Caregiver_Family/patientDetails.dart';
import 'package:tryapp/Therapist/Dashboard/TherapistDetails.dart';
import 'package:tryapp/login/login.dart';
import 'package:tryapp/main.dart';

import '../../constants.dart';

class ScheduleAssessment extends StatefulWidget {
  final TherapistClass therapist;
  final PatientClass patient;
  const ScheduleAssessment(this.therapist, this.patient, {Key key})
      : super(key: key);

  @override
  _ScheduleAssessmentState createState() => _ScheduleAssessmentState();
}

class _ScheduleAssessmentState extends State<ScheduleAssessment> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String fname, lname, email, address, phone, age, gender, uid, role;
  bool loadingPage = false;
  int _groupValue = -1;
  int assessor;
  var loading = false;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void initState() {
    super.initState();
    // getUserInfo();
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

  scheduleAssessment(String therapistUid, String patientUid, int assessor) {
    var doc = firestore.collection("assessments").doc().id;

    firestore.collection("assessments").doc(doc).set({
      "therapist": therapistUid,
      "patient": patientUid,
      "assessor": (assessor == 0) ? therapistUid : patientUid,
      'docID': doc,
      'date': Timestamp.now(),
      'status': 'new',
      'home': widget.patient.address,
      'currentStatus': "Assessment Scheduled",
    }).then((value) => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyHomePage())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        backwardsCompatibility: false,
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
                Text('Schedule Assessment', style: titleBarWhiteTextStyle()),
              ],
            ),
          ),
          decoration: new BoxDecoration(color: Color.fromRGBO(10, 80, 106, 1)),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Container(
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Stack(children: [
              SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.all(20),
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Select Assessor for the Assessment",
                            style: TextStyle(fontSize: 18),
                          )),

                      RadioListTile(
                        value: 0,
                        groupValue: _groupValue,
                        title: Text("Therapist"),
                        onChanged: (newValue) => setState(() {
                          assessor = newValue;
                          _groupValue = 0;
                        }),
                        activeColor: Colors.blue,
                      ),
                      RadioListTile(
                        value: 1,
                        groupValue: _groupValue,
                        title: Text("Patient"),
                        onChanged: (newValue) => setState(() {
                          assessor = newValue;
                          _groupValue = 1;
                        }),
                        activeColor: Colors.blue,
                      ),
                      RadioListTile(
                        value: 2,
                        groupValue: _groupValue,
                        title: Text("Case Manager"),
                        onChanged: (newValue) => setState(() {
                          assessor = newValue;
                          _groupValue = 2;
                        }),
                        activeColor: Colors.blue,
                      ),

                      // _buildfName(),
                      // SizedBox(
                      //   height: 15,
                      // ),
                      // _buildlName(),
                      // SizedBox(
                      //   height: 15,
                      // ),
                      // _buildEmail(),
                      // SizedBox(
                      //   height: 15,
                      // ),
                      // // _buildPhone(),
                      // // SizedBox(
                      // //   height: 15,
                      // // ),
                      // _buildAddress(),
                      // SizedBox(
                      //   height: 15,
                      // ),
                      // _buildPhone(),
                      // SizedBox(
                      //   height: 15,
                      // ),
                      // _buildAge(),
                      SizedBox(
                        height: 15,
                      ),
                      // _buildGender(),
                      // SizedBox(
                      //   height: 50,
                      // ),
                    ]),
              ),
              Container(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () async {
                        if (!_formKey.currentState.validate()) {
                          return;
                        }
                        _formKey.currentState.save();

                        // PatientClass patient = patientDetails();
                        // bool check = await checkIfEmailInUse(patient.email);

                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PatientDetails(
                                widget.therapist, widget.patient)));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.38,
                        height: 40.0,
                        decoration: new BoxDecoration(
                          color: Color.fromRGBO(10, 80, 106, 1),
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Previous',
                            style: whiteTextStyle().copyWith(
                                fontSize: 15.0, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    (_groupValue == 2)
                        ? TextButton(
                            onPressed: () async {
                              // if (!_formKey.currentState.validate()) {
                              //   return;
                              // }
                              // _formKey.currentState.save();

                              // PatientClass patient = patientDetails();
                              // bool check = await checkIfEmailInUse(patient.email);

                              // check
                              //     ? showSnackBar(context,
                              //         "Email already exists use a different email address")
                              //     : Navigator.of(context).pushReplacement(
                              //         MaterialPageRoute(
                              //             builder: (context) => ScheduleAssessment(
                              //                 widget.therapist, patient)));
                              if (_groupValue != -1) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => NurseDetails(
                                        widget.therapist, widget.patient)));
                              } else {
                                showSnackBar(context, "Choose Assessor first");
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.38,
                              height: 40.0,
                              decoration: new BoxDecoration(
                                color: Color.fromRGBO(10, 80, 106, 1),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Next',
                                  style: whiteTextStyle().copyWith(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          )
                        : TextButton(
                            onPressed: () async {
                              if (_groupValue != -1) {
                                setState(() {
                                  loading = true;
                                });
                                User therapist, patient;
                                await auth
                                    .createUserWithEmailAndPassword(
                                        email: widget.therapist.email,
                                        password: "123456")
                                    .then((value) => therapist = value.user);
                                await auth
                                    .createUserWithEmailAndPassword(
                                        email: widget.patient.email,
                                        password: "123456")
                                    .then((value) => patient = value.user);
                                firestore
                                    .collection("users")
                                    .doc(therapist.uid)
                                    .set(widget.therapist.toJson(),
                                        SetOptions(merge: true));
                                firestore
                                    .collection("users")
                                    .doc(patient.uid)
                                    .set(widget.patient.toJson(),
                                        SetOptions(merge: true));

                                scheduleAssessment(
                                    therapist.uid, patient.uid, _groupValue);
                              } else {
                                showSnackBar(context, "Choose Assessor first");
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.38,
                              height: 40.0,
                              decoration: new BoxDecoration(
                                color: Color.fromRGBO(10, 80, 106, 1),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                              ),
                              child: Center(
                                child: (!loading)
                                    ? Text(
                                        'Submit',
                                        style: whiteTextStyle().copyWith(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w600),
                                      )
                                    : Container(
                                        padding: EdgeInsets.all(10),
                                        child: CircularProgressIndicator()),
                              ),
                            ),
                          )
                  ],
                ),
              ),
            ]),
          )),
    );
  }
}
