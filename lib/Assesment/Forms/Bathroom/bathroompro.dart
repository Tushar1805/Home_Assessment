import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Formsrepo.dart';

class BathroomPro extends ChangeNotifier {
  String roomname;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  BathroomPro(this.roomname, this.wholelist, this.accessname);
  final FormsRepository formsRepository = FormsRepository();

  final FirebaseAuth auth = FirebaseAuth.instance;

  setdata(index, value) {
    if (value.length == 0) {
      if (wholelist[5][accessname]['question'][index]['Answer'].length == 0) {
      } else {
        wholelist[5][accessname]['complete'] -= 1;
        wholelist[5][accessname]['question'][index]['Answer'] = value;
        notifyListeners();
      }
    } else {
      if (wholelist[5][accessname]['question'][index]['Answer'].length == 0) {
        wholelist[5][accessname]['complete'] += 1;
        notifyListeners();
      }
      wholelist[5][accessname]['question'][index]['Answer'] = value;
      notifyListeners();
    }
  }
}
