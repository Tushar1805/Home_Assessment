import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentui.dart';

import './newassesmentpro.dart';
import '../oldassessments/oldassessmentspro.dart';

class NewAssesment extends StatelessWidget {
  final String docID, role;
  NewAssesment(this.docID, this.role);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<NewAssesmentProvider>(
          create: (_) => NewAssesmentProvider(docID)),
      ChangeNotifierProvider<OldAssessmentsProvider>(
          create: (_) => OldAssessmentsProvider(role))
    ], child: NewAssesmentUI(docID));

    // Scaffold(
    //     body: Center(
    //         child: ChangeNotifierProvider<NewAssesmentProvider>(
    //             create: (_) => NewAssesmentProvider(),
    //             child: NewAssesmentUI())));
  }
}
