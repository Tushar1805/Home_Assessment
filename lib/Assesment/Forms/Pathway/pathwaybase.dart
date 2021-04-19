import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/Forms/Pathway/pathwaypro.dart';
import '../../newassesment/newassesmentpro.dart';
import './pathwayUI.dart';
import 'package:provider/provider.dart';

class Pathway extends StatelessWidget {
  String roomname;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  Pathway(this.roomname, this.wholelist, this.accessname);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<NewAssesmentProvider>(
          create: (_) => NewAssesmentProvider("")),
      ChangeNotifierProvider<PathwayPro>(
          create: (_) => PathwayPro(roomname, wholelist, accessname))
    ], child: PathwayUI(roomname, wholelist, accessname));
    // return Scaffold(
    //     body: Center(
    //   child: ChangeNotifierProvider<NewAssesmentProvider>(
    //       create: (_) => NewAssesmentProvider(),
    //       child: PathwayUI(roomname, wholelist, accessname)),
    // ));
  }
}
