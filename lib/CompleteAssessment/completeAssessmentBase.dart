import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentpro.dart';
import 'package:tryapp/Assesment/oldassessments/oldassessmentspro.dart';
import 'package:tryapp/CompleteAssessment/completeAssessments.dart';

class CompleteAssessmentBase extends StatelessWidget {
  List<Map<String, dynamic>> list = [];
  String docID;
  CompleteAssessmentBase(this.list, this.docID);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<NewAssesmentProvider>(
          create: (_) => NewAssesmentProvider("")),
      ChangeNotifierProvider<OldAssessmentsProvider>(
        create: (_) => OldAssessmentsProvider(),
      )
    ], child: CompleteAssessmentUI(this.list, docID));
  }
}
