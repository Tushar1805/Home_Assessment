import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Formsrepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avatar_glow/avatar_glow.dart';

class LivingArrangementsProvider extends ChangeNotifier {
  stt.SpeechToText _speech;
  bool _isListening = false;
  TimeOfDay time1;
  TimeOfDay time2;
  TimeOfDay picked1;
  TimeOfDay picked2;
  bool available = false;
  Map<String, Color> colorsset = {};
  final firestoreInstance = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, TextEditingController> _controllers = {};
  Map<String, TextEditingController> _controllerstreco = {};
  Map<String, bool> isListening = {};
  bool cur = true;
  int roomatecount = 0;
  int flightcount = 0;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  String type;
  String roomname;
  var accessname;
  List<Map<String, dynamic>> wholelist;

  LivingArrangementsProvider(this.roomname, this.wholelist, this.accessname) {
    print('helo');
    time1 = TimeOfDay.now();
    time2 = TimeOfDay.now();
    _speech = stt.SpeechToText();
    for (int i = 0; i < wholelist[1][accessname]['question'].length; i++) {
      _controllers["field${i + 1}"] = TextEditingController();
      _controllerstreco["field${i + 1}"] = TextEditingController();
      isListening["field${i + 1}"] = false;
      _controllers["field${i + 1}"].text =
          wholelist[1][accessname]['question']["${i + 1}"]['Recommendation'];
      _controllerstreco["field${i + 1}"].text =
          '${wholelist[1][accessname]['question']["${i + 1}"]['Recommendationthera']}';
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
    getRole();
    setinitialsdata();
  }

  Future<Null> selectTime1(BuildContext context) async {
    picked1 = await showTimePicker(context: context, initialTime: time1);

    if (picked1 != null) {
      time1 = picked1;
      wholelist[1][accessname]['question']["4"]['Alone']['From'] = time1;
      notifyListeners();
    }
  }

  Future<Null> selectTime2(BuildContext context) async {
    picked2 = await showTimePicker(context: context, initialTime: time2);

    if (picked2 != null) {
      time2 = picked2;
      wholelist[1][accessname]['question']["4"]['Alone']['Till'] = time2;
      notifyListeners();
    }
  }

  Future<void> setinitialsdata() async {
    if (wholelist[1][accessname]['question']["2"].containsKey('Modetrnas')) {
    } else {
      wholelist[1][accessname]['question']["2"]['Modetrnas'] = '';
      wholelist[1][accessname]['question']["2"]['Modetrnasother'] = '';
      notifyListeners();
    }

    if (wholelist[1][accessname]['question']["4"].containsKey('Alone')) {
      if (wholelist[1][accessname]['question']["4"]['Alone']
          .containsKey('From')) {
        time1 = wholelist[1][accessname]['question']['4']['Alone']['From'];
      }
      if (wholelist[1][accessname]['question']["4"]['Alone']
          .containsKey('Till')) {
        time2 = wholelist[1][accessname]['question']["4"]['Alone']['Till'];
      }
      notifyListeners();
    } else {
      wholelist[1][accessname]['question']["4"]['Alone'] = {};
      notifyListeners();
    }

    if (wholelist[1][accessname]['question']["5"].containsKey('Roomate')) {
      if (wholelist[1][accessname]['question']["5"]['Roomate']
          .containsKey('count')) {
        roomatecount =
            wholelist[1][accessname]['question']["5"]['Roomate']['count'];
        notifyListeners();
      }
    } else {
      print('Yes,it is');

      wholelist[1][accessname]['question']["5"]['Roomate'] = {};
      notifyListeners();
    }

    if (wholelist[1][accessname]['question']["11"].containsKey('Flights')) {
      flightcount =
          wholelist[1][accessname]['question']["11"]['Flights']['count'];
      notifyListeners();
    } else {
      print('hello');

      wholelist[1][accessname]['question']["11"]['Flights'] = {};
      notifyListeners();
    }
  }

  Future<void> getRole() async {
    final FirebaseUser useruid = await _auth.currentUser();
    firestoreInstance
        .collection("users")
        .document(useruid.uid)
        .get()
        .then((value) {
      type = (value["role"].toString()).split(" ")[0];
    });

    notifyListeners();
  }

  setdata(index, value) {
    if (value.length == 0) {
      if (wholelist[1][accessname]['question']["$index"]['Answer'].length ==
          0) {
      } else {
        wholelist[1][accessname]['complete'] -= 1;
        wholelist[1][accessname]['question']["$index"]['Answer'] = value;
        notifyListeners();
      }
    } else {
      if (wholelist[1][accessname]['question']["$index"]['Answer'].length ==
          0) {
        wholelist[1][accessname]['complete'] += 1;
        notifyListeners();
      }

      wholelist[1][accessname]['question']["$index"]['Answer'] = value;
      notifyListeners();
    }
  }

  setreco(index, value) {
    wholelist[1][accessname]['question']["$index"]['Recommendation'] = value;
    notifyListeners();
  }

  getvalue(index) {
    return wholelist[1][accessname]['question']["$index"]['Answer'];
  }

  getreco(index) {
    return wholelist[1][accessname]['question']["$index"]['Recommendation'];
  }

  setprio(index, value) {
    wholelist[1][accessname]['question']["$index"]['Priority'] = value;
    notifyListeners();
  }

  getprio(index) {
    return wholelist[1][accessname]['question']["$index"]['Priority'];
  }

  setrecothera(index, value) {
    wholelist[1][accessname]['question']["$index"]['Recommendationthera'] =
        value;
    notifyListeners();
  }

  getrecothera(index) {
    return wholelist[1][accessname]['question']["$index"]
        ['Recommendationthera'];
  }
}
