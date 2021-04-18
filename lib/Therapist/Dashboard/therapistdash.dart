import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './therapistdashUI.dart';
import './therapistpro.dart';
import '../../login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Therapist extends StatelessWidget {
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ChangeNotifierProvider<TherapistProvider>(
                create: (_) => TherapistProvider(), child: TherapistUI())));
  }
}
