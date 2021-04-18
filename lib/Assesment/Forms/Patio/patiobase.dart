import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/Forms/Patio/patioUI.dart';
import '../../newassesment/newassesmentpro.dart';
import './patioUI.dart';
import 'package:provider/provider.dart';

class Patio extends StatelessWidget {
  String roomname;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  Patio(this.roomname, this.wholelist, this.accessname);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: ChangeNotifierProvider<NewAssesmentProvider>(
          create: (_) => NewAssesmentProvider(""),
          child: PatioUI(roomname, wholelist, accessname)),
    ));
  }
}
