import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './nursedashUI.dart';
import './nursedashprov.dart';
import './nursedashrepo.dart';

class Nurse extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ChangeNotifierProvider<NurseProvider>(
                create: (_) => NurseProvider("nurse/case manager"),
                child: NurseUI())));
  }
}
