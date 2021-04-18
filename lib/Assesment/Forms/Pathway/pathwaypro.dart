import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Formsrepo.dart';

class PathwayPro extends ChangeNotifier {
  final FormsRepository formsRepository = FormsRepository();
  FirebaseAuth auth = FirebaseAuth.instance;
  final firestoreInstance = Firestore.instance;
  FirebaseUser curuser;
  String type;

  Future<String> getRole() async {
    final FirebaseUser useruid = await auth.currentUser();
    firestoreInstance.collection("users").document(useruid.uid).get().then(
      (value) {
        type = (value["role"].toString());
      },
    );
    return type;
  }
}
