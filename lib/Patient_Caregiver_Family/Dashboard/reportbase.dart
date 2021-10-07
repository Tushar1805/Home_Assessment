import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentpro.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentui.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/reportui.dart';

class ReportBase extends StatelessWidget {
  List<Map<String, dynamic>> list;
  final String docID, patientUid, therapistUid;
  ReportBase(this.docID, this.patientUid, this.therapistUid, this.list);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ChangeNotifierProvider<NewAssesmentProvider>(
                create: (_) => NewAssesmentProvider(""),
                child: ReportUI(docID, patientUid, therapistUid, list))));
  }
}
