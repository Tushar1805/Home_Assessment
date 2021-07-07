import 'package:flutter/material.dart';
import '../Nurse_Case_Manager/Dashboard/nursedash.dart';
import '../Therapist/Dashboard/therapistdash.dart';
import '../Patient_Caregiver_Family/Dashboard/patientdash.dart';
import './loginrepo.dart';

class LoginProvider extends ChangeNotifier {
  final UserRepository userRepository = UserRepository();
  bool loading = false;
  bool userExists = false;

  Future loginProvider(String email, String password) async {
    userExists = await userRepository.login(email, password);
    // return userExists;
  }

  Future<Widget> getUserType(type) async {
    switch (type) {
      case 'nurse/casemanager':
        return Nurse();
      case 'therapist':
        return Therapist();
      case 'patient':
        return Patient();
      default:
        return Nurse();
    }
  }
}
