import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/Forms/Garage/garageUI.dart';
// import 'package:tryapp/Assesment/Forms/Laundry/laundryUI.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentpro.dart';

import 'package:provider/provider.dart';

class Garage extends StatelessWidget {
  String roomname;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  Garage(this.roomname, this.wholelist, this.accessname);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: ChangeNotifierProvider<NewAssesmentProvider>(
          create: (_) => NewAssesmentProvider(""),
          child: GarageUI(roomname, wholelist, accessname)),
    ));
  }
}
