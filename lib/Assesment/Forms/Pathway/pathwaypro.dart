import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Formsrepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avatar_glow/avatar_glow.dart';

class PathwayPro extends ChangeNotifier {
  stt.SpeechToText _speech;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool available = false;
  int threeshold = 0;
  Map<String, Color> colorsset = {};
  Map<String, TextEditingController> _controllers = {};
  Map<String, TextEditingController> _controllerstreco = {};
  final firestoreInstance = Firestore.instance;
  Map<String, bool> isListening = {};
  bool cur = true;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  var _textfield = TextEditingController();
  String type;
  int sizes = 30;
  int stepsizes = 0;
  int stepcount = 0;
  var test = TextEditingController();
  final FormsRepository formsRepository = FormsRepository();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser curuser;
  String roomname;
  var accessname;
  List<Map<String, dynamic>> wholelist;

  PathwayPro(this.roomname, this.wholelist, this.accessname) {
    _speech = stt.SpeechToText();
    _textfield.text = wholelist[0][accessname]['question'][1]['Recommendation'];
    for (int i = 0; i < wholelist[0][accessname]['question'].length; i++) {
      _controllers["field${i + 1}"] = TextEditingController();
      _controllerstreco["field${i + 1}"] = TextEditingController();
      isListening["field${i + 1}"] = false;
      _controllers["field${i + 1}"].text =
          wholelist[0][accessname]['question'][i + 1]['Recommendation'];
      _controllerstreco["field${i + 1}"].text =
          '${wholelist[0][accessname]['question'][i + 1]['Recommendationthera']}';
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
    getRole();
    setinitials();
  }

  setinitials() {
    if (wholelist[0][accessname]['question'][8].containsKey('Railling')) {
    } else {
      wholelist[0][accessname]['question'][8]['Railling'] = {
        'OneSided': {},
      };
    }
    if (wholelist[0][accessname]['question'][7].containsKey('MultipleStair')) {
      if (wholelist[0][accessname]['question'][7]['MultipleStair']
          .containsKey('count')) {
        stepcount =
            wholelist[0][accessname]['question'][7]['MultipleStair']['count'];
        notifyListeners();
      }
    } else {
      wholelist[0][accessname]['question'][7]['MultipleStair'] = {};
    }
    print(wholelist[0][accessname]['question'][7]['MultipleStair']);
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
      if (wholelist[0][accessname]['question'][index]['Answer'].length == 0) {
      } else {
        wholelist[0][accessname]['complete'] -= 1;
        wholelist[0][accessname]['question'][index]['Answer'] = value;
        notifyListeners();
      }
    } else {
      if (wholelist[0][accessname]['question'][index]['Answer'].length == 0) {
        wholelist[0][accessname]['complete'] += 1;
        notifyListeners();
      }
      wholelist[0][accessname]['question'][index]['Answer'] = value;
      notifyListeners();
    }
  }

  setreco(index, value) {
    wholelist[0][accessname]['question'][index]['Recommendation'] = value;
    notifyListeners();
  }

  getvalue(index) {
    return wholelist[0][accessname]['question'][index]['Answer'];
  }

  getreco(index) {
    return wholelist[0][accessname]['question'][index]['Recommendation'];
  }

  setprio(index, value) {
    wholelist[0][accessname]['question'][index]['Priority'] = value;
    notifyListeners();
  }

  getprio(index) {
    return wholelist[0][accessname]['question'][index]['Priority'];
  }

  setrecothera(index, value) {
    wholelist[0][accessname]['question'][index]['Recommendationthera'] = value;
    notifyListeners();
  }

  Future getImage(bool isCamera) async {
    // File image;
    // if (isCamera) {
    //   // ignore: deprecated_member_use
    //   image = await ImagePicker.pickImage(source: ImageSource.camera);
    // } else {
    //   // ignore: deprecated_member_use
    //   image = await ImagePicker.pickImage(source: ImageSource.gallery);
    // }
    // setState(() {
    //   _image = image;
    // });
  }

  void listen(index) async {
    if (!isListening['field$index']) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          if (val == 'notListening') {
            isListening['field$index'] = false;
            notifyListeners();
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        // _isListening = true;
        colorsset["field$index"] = Colors.red;
        isListening['field$index'] = true;
        notifyListeners();
        _speech.listen(
          onResult: (val) {
            _controllers["field$index"].text = wholelist[0][accessname]
                    ['question'][index]['Recommendation'] +
                " " +
                val.recognizedWords;
            // if (val.hasConfidenceRating && val.confidence > 0) {
            //   _confidence = val.confidence;
            // }
            notifyListeners();
          },
        );
        print('karan');
      }
    } else {
      // _isListening = false;
      isListening['field$index'] = false;
      colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
      notifyListeners();
      _speech.stop();
    }
  }

  ticklisten(index) {
    print('clicked');
    // _isListening = false;
    // isListening['field$index'] = false;
    colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
    notifyListeners();
    _speech.stop();
  }

  setdatalisten(index) {
    wholelist[0][accessname]['question'][index]['Recommendation'] =
        _controllers["field$index"].text;
    cur = !cur;
    notifyListeners();
  }
}
