import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/Forms/DiningRoom/diningroomUi.dart';
import 'package:tryapp/Assesment/Forms/DiningRoom/diningroompro.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentpro.dart';

import 'package:provider/provider.dart';

class DiningRoom extends StatelessWidget {
  String roomname;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  DiningRoom(this.roomname, this.wholelist, this.accessname);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<NewAssesmentProvider>(
          create: (_) => NewAssesmentProvider("")),
      ChangeNotifierProvider<DiningPro>(
          create: (_) => DiningPro(roomname, wholelist, accessname))
    ], child: DiningRoomUI(roomname, wholelist, accessname));
    // return Scaffold(
    //     body: Center(
    //   child: ChangeNotifierProvider<NewAssesmentProvider>(
    //       create: (_) => NewAssesmentProvider(""),
    //       child: DiningRoomUI(roomname, wholelist, accessname)),
    // ));
  }
}
