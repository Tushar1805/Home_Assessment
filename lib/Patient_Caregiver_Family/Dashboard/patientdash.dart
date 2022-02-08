import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../patientdashUI.dart';
import './patientdashprov.dart';

class Patient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ChangeNotifierProvider<PatientProvider>(
                create: (_) => PatientProvider("patient"),
                child: PatientUI())));
  }
}
