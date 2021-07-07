import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentpro.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentui.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/reportui.dart';

class ReportBase extends StatelessWidget {
  final String assesmentdoc;
  ReportBase({this.assesmentdoc});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ChangeNotifierProvider<NewAssesmentProvider>(
                create: (_) => NewAssesmentProvider(assesmentdoc),
                child: ReportUI())));
  }
}
