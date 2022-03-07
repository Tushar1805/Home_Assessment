import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/Forms/Kitchen/kitchenpro.dart';
import 'package:tryapp/Assesment/Forms/Patio/patioUI.dart';
import 'package:tryapp/Assesment/Forms/Patio/patiopro.dart';
import '../../newassesment/newassesmentpro.dart';
import './patioUI.dart';
import 'package:provider/provider.dart';

class Patio extends StatelessWidget {
  String roomname, docID;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  Patio(this.roomname, this.wholelist, this.accessname, this.docID);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: MultiProvider(providers: [
        ChangeNotifierProvider<NewAssesmentProvider>(
            create: (_) => NewAssesmentProvider("")),
        ChangeNotifierProvider<PatioProvider>(
            create: (_) => PatioProvider(roomname, wholelist, accessname))
      ], child: PatioUI(roomname, wholelist, accessname, docID)),
    ));
  }
}
