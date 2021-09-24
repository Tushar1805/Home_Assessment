import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tryapp/Therapist/Dashboard/therapistpro.dart';
import 'package:tryapp/Therapist/Dashboard/viewFeedback.dart';

class ViewFeedbackBase extends StatelessWidget {
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ChangeNotifierProvider<TherapistProvider>(
                create: (_) => TherapistProvider("therapist"),
                child: ViewFeedback())));
  }
}
