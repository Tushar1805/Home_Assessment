import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentpro.dart';
import './kitchenpro.dart';
import './kitchenUI.dart';
import 'package:provider/provider.dart';

class Kitchen extends StatelessWidget {
  String roomname;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  Kitchen(this.roomname, this.wholelist, this.accessname);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: ChangeNotifierProvider<NewAssesmentProvider>(
          create: (_) => NewAssesmentProvider(""),
          child: KitchenUI(roomname, wholelist, accessname)),
    ));
  }
}
