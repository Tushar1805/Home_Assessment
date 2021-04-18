import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentpro.dart';
import './livingpro.dart';
import './livingui.dart';
import 'package:provider/provider.dart';

class LivingRoom extends StatelessWidget {
  String roomname;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  LivingRoom(this.roomname, this.wholelist, this.accessname);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NewAssesmentProvider>(
            create: (_) => NewAssesmentProvider("")),
        ChangeNotifierProvider<LivingProvider>(create: (_) => LivingProvider())
      ],
      child: LivingRoomUI(roomname, wholelist, accessname));
    );
    // return Scaffold(
    //     body: Center(
    //         child: ChangeNotifierProvider<LivingProvider>(
    //   create: (_) => LivingProvider(),
    //   child: LivingRoomUI(roomname, wholelist, accessname),
    // )));
  }
}
