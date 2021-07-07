import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/Forms/Pathway/pathwaypro.dart';
import '../../newassesment/newassesmentpro.dart';
import './pathwayUI.dart';
import 'package:provider/provider.dart';

class Pathway extends StatelessWidget {
  String roomname, docID;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  Pathway(this.roomname, this.wholelist, this.accessname, this.docID);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<NewAssesmentProvider>(
          create: (_) => NewAssesmentProvider(docID)),
      ChangeNotifierProvider<PathwayPro>(
          create: (_) => PathwayPro(roomname, wholelist, accessname))
    ], child: PathwayUI(roomname, wholelist, accessname, docID));
    // return Scaffold(
    //     body: Center(
    //   child: ChangeNotifierProvider<NewAssesmentProvider>(
    //       create: (_) => NewAssesmentProvider(),
    //       child: PathwayUI(roomname, wholelist, accessname)),
    // ));
  }
}
