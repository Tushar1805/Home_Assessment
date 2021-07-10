import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tryapp/Nurse_Case_Manager/Dashboard/nursedash.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/patientdash.dart';
import 'package:tryapp/Therapist/Dashboard/therapistdash.dart';

class PatientsList extends StatefulWidget {
  @override
  _PatientsListState createState() => _PatientsListState();
}

class _PatientsListState extends State<PatientsList> {
  String role;

  @override
  void initState() {
    super.initState();
    getRole();
  }

  getRole() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    await Firestore.instance
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
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        if (role == "therapist") {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Therapist()));
        } else if (role == "nurse/case manager") {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Nurse()));
        } else if (role == "patient") {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Patient()));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(10, 80, 106, 1),
          title: Text('Patients/Caregivers/Families'),
          elevation: 0.0,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Text("Yet To Be Implemented"),
          ),
        ),
      ),
    );
  }
}
