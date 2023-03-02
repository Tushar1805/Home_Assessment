import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Formsrepo.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:google_speech/google_speech.dart';
import 'package:rxdart/rxdart.dart';

class PatioProvider extends ChangeNotifier {
  final FormsRepository formsRepository = FormsRepository();
  String videoName = '';
  String videoDownloadUrl;
  String selectedRequestId;
  String videoUrl;
  File video;
  bool isVideoSelected = false;
  final firestoreInstance = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  stt.SpeechToText speech;
  bool _isListening = false, saveToForm = false;
  double confidence = 1.0;
  bool available = false, isColor = false;
  Map<String, Color> colorsset = {};
  Map<String, TextEditingController> controllers = {};
  Map<String, TextEditingController> controllerstreco = {};
  Map<String, bool> isListening = {};
  bool cur = true;
  String role, curUid, assessor, therapist;
  int stepcount = 0;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  var test = TextEditingController();
  bool uploading = false;
  var falseIndex = -1, trueIndex = -1;
  String roomname;
  var accessname;
  List<Map<String, dynamic>> wholelist;

  // MIC Stram
  final RecorderStream _recorder = RecorderStream();

  // bool recognizing = false;
  Map<String, bool> isRecognizing = {};
  Map<String, bool> isRecognizingThera = {};
  // bool recognizeFinished = false;
  Map<String, bool> isRecognizeFinished = {};
  String text = '';
  StreamSubscription<List<int>> _audioStreamSubscription;
  BehaviorSubject<List<int>> _audioStream;

  PatioProvider(this.roomname, this.wholelist, this.accessname) {
    speech = stt.SpeechToText();

    for (int i = 0; i < wholelist[8][accessname]['question'].length; i++) {
      controllers["field${i + 1}"] = TextEditingController();
      controllerstreco["field${i + 1}"] = TextEditingController();
      isListening["field${i + 1}"] = false;
      controllers["field${i + 1}"].text =
          wholelist[8][accessname]['question']["${i + 1}"]['Recommendation'];
      controllerstreco["field${i + 1}"].text = wholelist[8][accessname]
          ['question']["${i + 1}"]['Recommendationthera'];
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
    getRole();
    setinitials();
  }

  Future<String> getRole() async {
    var runtimeType;
    final User useruid = await _auth.currentUser;
    firestoreInstance.collection("users").doc(useruid.uid).get().then(
      (value) {
        runtimeType = value.data()['role'].runtimeType.toString();
        // print("runtime Type: $runtimeType");
        if (runtimeType == "List<dynamic>") {
          for (int i = 0; i < value.data()["role"].length; i++) {
            if (value.data()["role"][i].toString() == "therapist") {
              role = "therapist";
            }
          }
        } else {
          role = value.data()["role"];
        }
      },
    );
  }

  Future<void> setinitials() async {
    if (wholelist[8][accessname].containsKey('isSave')) {
    } else {
      wholelist[8][accessname]["isSave"] = true;
    }
    if (wholelist[8][accessname].containsKey('isSaveThera')) {
    } else {
      wholelist[8][accessname]["isSaveThera"] = false;
    }
    if (wholelist[8][accessname].containsKey('videos')) {
      if (wholelist[8][accessname]['videos'].containsKey('name')) {
      } else {
        wholelist[8][accessname]['videos']['name'] = "";
      }
      if (wholelist[8][accessname]['videos'].containsKey('url')) {
      } else {
        wholelist[8][accessname]['videos']['url'] = "";
      }
    } else {
      // print('Yes,it is');

      wholelist[8][accessname]["videos"] = {'name': '', 'url': ''};
    }

    if (wholelist[8][accessname]['question']["5"].containsKey('toggle')) {
      if (wholelist[8][accessname]['question']["5"]['Answer'].length == 0) {
        // setdata(5, 'Yes', 'Able to Operate Switches?');
        wholelist[8][accessname]['question']["5"]['Question'] =
            'Able to Operate Switches?';
        wholelist[8][accessname]['question']["5"]['Answer'] = 'Yes';
        wholelist[8][accessname]['question']["5"]['toggled'] = false;
      }
      notifyListeners();
    } else {
      wholelist[8][accessname]['question']["5"]['toggle'] = <bool>[true, false];
      if (wholelist[8][accessname]['question']["5"]['Answer'].length == 0) {
        // setdata(5, 'Yes', 'Able to Operate Switches?');
        wholelist[8][accessname]['question']["5"]['Question'] =
            'Able to Operate Switches?';
        wholelist[8][accessname]['question']["5"]['Answer'] = 'Yes';
        wholelist[8][accessname]['question']["5"]['toggled'] = false;
      }
      notifyListeners();
    }

    if (wholelist[8][accessname]['question']["8"].containsKey('toggle')) {
      if (wholelist[8][accessname]['question']["8"]['Answer'].length == 0) {
        // setdata(8, 'Yes', 'Obstacle/Clutter Present?');
        wholelist[8][accessname]['question']["8"]['Question'] =
            'Obstacle/Clutter Present?';
        wholelist[8][accessname]['question']["8"]['Answer'] = 'Yes';
        wholelist[8][accessname]['question']["8"]['toggled'] = false;
      }
      notifyListeners();
    } else {
      wholelist[8][accessname]['question']["8"]['toggle'] = <bool>[true, false];
      if (wholelist[8][accessname]['question']["8"]['Answer'].length == 0) {
        // setdata(8, 'Yes', 'Obstacle/Clutter Present?');
        wholelist[8][accessname]['question']["8"]['Question'] =
            'Obstacle/Clutter Present?';
        wholelist[8][accessname]['question']["8"]['Answer'] = 'Yes';
        wholelist[8][accessname]['question']["8"]['toggled'] = false;
      }
      notifyListeners();
    }

    if (wholelist[8][accessname]['question']["11"].containsKey('toggle')) {
      if (wholelist[8][accessname]['question']["11"]['Answer'].length == 0) {
        // setdata(11, 'Yes', 'Smoke Detector Present?');
        wholelist[8][accessname]['question']["11"]['Question'] =
            'Smoke Detector Present?';
        wholelist[8][accessname]['question']["11"]['Answer'] = 'Yes';
        wholelist[8][accessname]['question']["11"]['toggled'] = false;
      }
      notifyListeners();
    } else {
      wholelist[8][accessname]['question']["11"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[8][accessname]['question']["11"]['Answer'].length == 0) {
        // setdata(11, 'Yes', 'Smoke Detector Present?');
        wholelist[8][accessname]['question']["11"]['Question'] =
            'Smoke Detector Present?';
        wholelist[8][accessname]['question']["11"]['Answer'] = 'Yes';
        wholelist[8][accessname]['question']["11"]['toggled'] = false;
      }
      notifyListeners();
    }

    if (wholelist[8][accessname]['question']["7"].containsKey('doorwidth')) {
    } else {
      print('getting created');
      wholelist[8][accessname]['question']["7"]['doorwidth'] = 0;
    }

    if (wholelist[8][accessname]['question']["9"]
        .containsKey('MultipleStair')) {
      if (wholelist[8][accessname]['question']["9"]['MultipleStair']
          .containsKey('count')) {
        stepcount =
            wholelist[8][accessname]['question']["9"]['MultipleStair']['count'];
      }
    } else {
      wholelist[8][accessname]['question']["9"]['MultipleStair'] = {};
    }

    if (wholelist[8][accessname]['question']["10"].containsKey('Railling')) {
    } else {
      wholelist[8][accessname]['question']["10"]['Railling'] = {
        'OneSided': {},
      };
    }
  }

  setdataToggle(index, String value, que) {
    wholelist[8][accessname]['question']["$index"]['Question'] = que;
    if (value.length == 0) {
      if (wholelist[8][accessname]['question']["$index"]['toggled']) {
      } else {
        wholelist[8][accessname]['complete'] -= 1;
        wholelist[8][accessname]['question']["$index"]['Answer'] = value;
        notifyListeners();
      }
    } else {
      if (wholelist[8][accessname]['question']["$index"]['toggled'] == false) {
        wholelist[8][accessname]['complete'] += 1;
        wholelist[8][accessname]['question']["$index"]['toggled'] = true;
        notifyListeners();
      }

      wholelist[8][accessname]['question']["$index"]['Answer'] = value;
      notifyListeners();
    }
  }

  setdata(index, value, que) {
    wholelist[8][accessname]['question']["$index"]['Question'] = que;
    if (value.length == 0) {
      if (wholelist[8][accessname]['question']["$index"]['Answer'].length ==
          0) {
      } else {
        wholelist[8][accessname]['complete'] -= 1;
        wholelist[8][accessname]['question']["$index"]['Answer'] = value;
      }
    } else {
      if (wholelist[8][accessname]['question']["$index"]['Answer'].length ==
          0) {
        wholelist[8][accessname]['complete'] += 1;
      }
      wholelist[8][accessname]['question']["$index"]['Answer'] = value;
    }
    notifyListeners();
  }

  setreco(index, value) {
    wholelist[8][accessname]['question']["$index"]['Recommendation'] = value;
    notifyListeners();
  }

  getvalue(index) {
    return wholelist[8][accessname]['question']["$index"]['Answer'];
  }

  getreco(index) {
    return wholelist[8][accessname]['question']["$index"]['Recommendation'];
  }

  setrecothera(index, value) {
    wholelist[8][accessname]['question']["$index"]['Recommendationthera'] =
        value;
    notifyListeners();
  }

  setprio(index, value) {
    wholelist[8][accessname]['question']["$index"]['Priority'] = value;
    notifyListeners();
  }

  getprio(index) {
    return wholelist[8][accessname]['question']["$index"]['Priority'];
  }

  getrecothera(index) {
    return wholelist[8][accessname]['question']["$index"]
        ['Recommendationthera'];
  }

  setdatalistenthera(index) {
    wholelist[8][accessname]['question']["$index"]['Recommendationthera'] =
        controllerstreco["field$index"].text;
    cur = !cur;
    notifyListeners();
  }

  setdatalisten(index) {
    wholelist[8][accessname]['question']["$index"]['Recommendation'] =
        controllers["field$index"].text;
    cur = !cur;
    notifyListeners();
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> addVideo(String path) {
    video = File(path);
    videoName = basename(video.path);
    isVideoSelected = true;
    notifyListeners();
  }
}
