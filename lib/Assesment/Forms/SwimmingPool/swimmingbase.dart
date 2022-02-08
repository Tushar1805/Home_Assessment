import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/Forms/LivingArrangements/livingArrangementUI.dart';

import 'package:provider/provider.dart';
import 'package:tryapp/Assesment/Forms/SwimmingPool/swimmingUI.dart';
import 'package:tryapp/Assesment/Forms/SwimmingPool/swimmingpro.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentpro.dart';

class SwimmingPool extends StatelessWidget {
  String roomname, docID;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  SwimmingPool(this.roomname, this.wholelist, this.accessname, this.docID);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<NewAssesmentProvider>(
          create: (_) => NewAssesmentProvider("")),
      ChangeNotifierProvider<SwimmingPoolProvider>(
          create: (_) => SwimmingPoolProvider(roomname, wholelist, accessname))
    ], child: SwimmingPoolUI(roomname, wholelist, accessname, docID));

    // return Scaffold(
    //     body: Center(
    //   child: ChangeNotifierProvider<NewAssesmentProvider>(
    //       create: (_) => NewAssesmentProvider(""),
    //       child: LivingArrangementsUI(roomname, wholelist, accessname)),
    // ));
  }
}
