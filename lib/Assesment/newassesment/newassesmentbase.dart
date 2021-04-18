import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentui.dart';

import './newassesmentpro.dart';
import '../oldassessments/oldassessmentspro.dart';

class NewAssesment extends StatelessWidget {
  final String assessmentdoc;
  NewAssesment(this.assessmentdoc);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<NewAssesmentProvider>(
          create: (_) => NewAssesmentProvider(assessmentdoc)),
      ChangeNotifierProvider<OldAssessmentsProvider>(
          create: (_) => OldAssessmentsProvider())
    ], child: NewAssesmentUI());

    // Scaffold(
    //     body: Center(
    //         child: ChangeNotifierProvider<NewAssesmentProvider>(
    //             create: (_) => NewAssesmentProvider(),
    //             child: NewAssesmentUI())));
  }
}
