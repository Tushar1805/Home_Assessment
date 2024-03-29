import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/Forms/Bedroom/bedroomUI.dart';
import 'package:tryapp/Assesment/Forms/Bedroom/bedroompro.dart';
// import 'package:tryapp/Assesment/Forms/DiningRoom/diningroomUi.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentpro.dart';

import 'package:provider/provider.dart';

class Bedroom extends StatelessWidget {
  String roomname, docID;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  Bedroom(this.roomname, this.wholelist, this.accessname, this.docID);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<NewAssesmentProvider>(
          create: (_) => NewAssesmentProvider("")),
      ChangeNotifierProvider<BedroomPro>(
          create: (_) => BedroomPro(roomname, wholelist, accessname))
    ], child: BedroomUI(roomname, wholelist, accessname, docID));
    // return Scaffold(
    //     body: Center(
    //   child: ChangeNotifierProvider<NewAssesmentProvider>(
    //       create: (_) => NewAssesmentProvider(""),
    //       child: BedroomUI(roomname, wholelist, accessname)),
    // ));
  }
}
