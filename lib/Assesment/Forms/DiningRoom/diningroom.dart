import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/Forms/DiningRoom/diningroomUi.dart';
import 'package:tryapp/Assesment/Forms/DiningRoom/diningroompro.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentpro.dart';

import 'package:provider/provider.dart';

class DiningRoom extends StatelessWidget {
  String roomname, docID;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  DiningRoom(this.roomname, this.wholelist, this.accessname, this.docID);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<NewAssesmentProvider>(
          create: (_) => NewAssesmentProvider("")),
      ChangeNotifierProvider<DiningPro>(
          create: (_) => DiningPro(roomname, wholelist, accessname))
    ], child: DiningRoomUI(roomname, wholelist, accessname, docID));
    // return Scaffold(
    //     body: Center(
    //   child: ChangeNotifierProvider<NewAssesmentProvider>(
    //       create: (_) => NewAssesmentProvider(""),
    //       child: DiningRoomUI(roomname, wholelist, accessname)),
    // ));
  }
}
