import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/Forms/Bathroom/bathroompro.dart';
import './bathroomUI.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentpro.dart';
import 'package:provider/provider.dart';

class Bathroom extends StatelessWidget {
  String roomname;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  Bathroom(this.roomname, this.wholelist, this.accessname);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<NewAssesmentProvider>(
          create: (_) => NewAssesmentProvider("")),
      ChangeNotifierProvider<BathroomPro>(create: (_) => BathroomPro(roomname, wholelist, accessname))
    ], child: BathroomUI(roomname, wholelist, accessname));
    // return Scaffold(
    //     body: Center(
    //   child: ChangeNotifierProvider<NewAssesmentProvider>(
    //       create: (_) => NewAssesmentProvider(""),
    //       child: BathroomUI(roomname, wholelist, accessname)),
    // ));
  }
}
