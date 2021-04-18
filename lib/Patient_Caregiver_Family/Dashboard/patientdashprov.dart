import 'package:flutter/material.dart';
import './patientdashrepo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientProvider extends ChangeNotifier {
  final PatientRepository patientRepository = PatientRepository();

  final FirebaseAuth auth = FirebaseAuth.instance;

  inputData() async {
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    return uid;
    // here you write the codes to input the data into firestore
  }
}
