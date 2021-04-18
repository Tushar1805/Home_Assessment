import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/Forms/Laundry/laundryUI.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentpro.dart';

import 'package:provider/provider.dart';

import 'laundrypro.dart';

class Laundry extends StatelessWidget {
  String roomname;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  Laundry(this.roomname, this.wholelist, this.accessname);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<NewAssesmentProvider>(
          create: (_) => NewAssesmentProvider("")),
      ChangeNotifierProvider<LaundryPro>(
          create: (_) => LaundryPro(roomname, wholelist, accessname))
    ], child: LaundryUI(roomname, wholelist, accessname));

    // return Scaffold(
    //     body: Center(
    //   child: ChangeNotifierProvider<NewAssesmentProvider>(
    //       create: (_) => NewAssesmentProvider(""),
    //       child: LaundryUI(roomname, wholelist, accessname)),
    // ));
  }
}
