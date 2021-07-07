import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentpro.dart';
import './kitchenpro.dart';
import './kitchenUI.dart';
import 'package:provider/provider.dart';

class Kitchen extends StatelessWidget {
  String roomname, docID;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  Kitchen(this.roomname, this.wholelist, this.accessname, this.docID);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<NewAssesmentProvider>(
          create: (_) => NewAssesmentProvider("")),
      ChangeNotifierProvider<KitchenPro>(
          create: (_) => KitchenPro(roomname, wholelist, accessname))
    ], child: KitchenUI(roomname, wholelist, accessname, docID));
  }
}
