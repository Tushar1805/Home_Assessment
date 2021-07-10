import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './oldassessmentspro.dart';
import './oldassessmentsUI.dart';

class OldAssessments extends StatelessWidget {
  String role;
  OldAssessments(this.role);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ChangeNotifierProvider<OldAssessmentsProvider>(
      create: (_) => OldAssessmentsProvider(role),
      child: OldAssessmentsUI(),
    )));
  }
}
