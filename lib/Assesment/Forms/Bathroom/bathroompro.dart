import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Formsrepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BathroomPro extends ChangeNotifier {
  String roomname;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  final firestoreInstance = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool obstacle = false;
  bool grabbarneeded = false;
  stt.SpeechToText _speech;
  bool _isListening = false;
  double _confidence = 1.0;
  int doorwidth = 0;
  bool available = false;
  Map<String, Color> colorsset = {};
  Map<String, TextEditingController> _controllers = {};
  Map<String, TextEditingController> _controllerstreco = {};
  Map<String, bool> isListening = {};
  bool cur = true;
  String type;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  var test = TextEditingController();
  final FormsRepository formsRepository = FormsRepository();
  final FirebaseAuth auth = FirebaseAuth.instance;

  BathroomPro(this.roomname, this.wholelist, this.accessname) {
    _speech = stt.SpeechToText();
    for (int i = 0; i < wholelist[5][accessname]['question'].length; i++) {
      _controllers["field${i + 1}"] = TextEditingController();
      _controllerstreco["field${i + 1}"] = TextEditingController();
      isListening["field${i + 1}"] = false;
      _controllers["field${i + 1}"].text =
          wholelist[5][accessname]['question'][i + 1]['Recommendation'];
      _controllerstreco["field${i + 1}"].text =
          '${wholelist[5][accessname]['question'][i + 1]['Recommendationthera']}';
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
    getRole();
    setinitials();
  }

  Future<void> setinitials() async {
    if (wholelist[5][accessname]['question'][7].containsKey('doorwidth')) {
    } else {
      print('getting created');
      wholelist[5][accessname]['question'][7]['doorwidth'] = 0;
    }

    if (wholelist[5][accessname]['question'][15].containsKey('ManageInOut')) {
    } else {
      wholelist[5][accessname]['question'][15]['ManageInOut'] = '';
    }

    if (wholelist[5][accessname]['question'][16].containsKey('Grabbar')) {
    } else {
      wholelist[5][accessname]['question'][16]['Grabbar'] = {};
    }

    if (wholelist[5][accessname]['question'][17].containsKey('sidefentrance')) {
    } else {
      wholelist[5][accessname]['question'][17]['sidefentrance'] = '';
    }
  }

  Future<String> getRole() async {
    final FirebaseUser useruid = await _auth.currentUser();
    firestoreInstance.collection("users").document(useruid.uid).get().then(
      (value) {
        type = (value["role"].toString()).split(" ")[0];
        notifyListeners();
      },
    );
  }

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

  setreco(index, value) {
    wholelist[5][accessname]['question'][index]['Recommendation'] = value;
    notifyListeners();
  }

  getvalue(index) {
    return wholelist[5][accessname]['question'][index]['Answer'];
  }

  getreco(index) {
    return wholelist[5][accessname]['question'][index]['Recommendation'];
  }

  setrecothera(index, value) {
    wholelist[5][accessname]['question'][index]['Recommendationthera'] = value;
    notifyListeners();
  }

  setprio(index, value) {
    wholelist[5][accessname]['question'][index]['Priority'] = value;
    notifyListeners();
  }

  getprio(index) {
    return wholelist[5][accessname]['question'][index]['Priority'];
  }

  getrecothera(index) {
    return wholelist[5][accessname]['question'][index]['Recommendationthera'];
  }
}
