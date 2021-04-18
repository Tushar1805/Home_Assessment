import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './oldassessmentspro.dart';
import './oldassessmentsUI.dart';

class OldAssessments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ChangeNotifierProvider<OldAssessmentsProvider>(
      create: (_) => OldAssessmentsProvider(),
      child: OldAssessmentsUI(),
    )));
  }
}
