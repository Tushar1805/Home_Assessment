import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Formsrepo.dart';

import 'package:path/path.dart';

import '../../../constants.dart';

class LivingProvider extends ChangeNotifier {
  String roomname;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  final firestoreInstance = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool obstacle = false;
  bool grabbarneeded = false, saveToForm = false;
  stt.SpeechToText _speech;
  bool _isListening = false;
  double _confidence = 1.0;
  int doorwidth = 0;
  bool available = false;
  Map<String, Color> colorsset = {};
  Map<String, TextEditingController> controllers = {};
  Map<String, TextEditingController> controllerstreco = {};
  Map<String, bool> isListening = {};
  bool cur = true;
  bool isColor = false;
  String type, therapist, curUid, assessor;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  var test = TextEditingController();
  final FormsRepository formsRepository = FormsRepository();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String videoName = '';
  String videoDownloadUrl;
  String selectedRequestId;
  String videoUrl;
  File video;
  bool isVideoSelected = false;

  LivingProvider(this.roomname, this.wholelist, this.accessname) {
    _speech = stt.SpeechToText();
    for (int i = 0; i < wholelist[2][accessname]['question'].length; i++) {
      controllers["field${i + 1}"] = TextEditingController();
      controllerstreco["field${i + 1}"] = TextEditingController();
      isListening["field${i + 1}"] = false;
      controllers["field${i + 1}"].text =
          wholelist[2][accessname]['question']["${i + 1}"]['Recommendation'];
      controllerstreco["field${i + 1}"].text =
          '${wholelist[2][accessname]['question']["${i + 1}"]['Recommendationthera']}';
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
    setinitials();
    getRole();
    notifyListeners();
  }

  Future<void> setinitials() async {
    if (wholelist[2][accessname].containsKey('isSave')) {
    } else {
      wholelist[2][accessname]["isSave"] = true;
    }
    if (wholelist[2][accessname].containsKey('videos')) {
      if (wholelist[2][accessname]['videos'].containsKey('name')) {
      } else {
        wholelist[2][accessname]['videos']['name'] = "";
      }
      if (wholelist[2][accessname]['videos'].containsKey('url')) {
      } else {
        wholelist[2][accessname]['videos']['url'] = "";
      }
    } else {
      // print('Yes,it is');

      wholelist[2][accessname]["videos"] = {'name': '', 'url': ''};
    }

    if (wholelist[2][accessname]['question']["5"].containsKey('toggle')) {
      if (wholelist[2][accessname]['question']["5"]['Answer'].length == 0) {
        setdata(5, 'Yes', 'Able to Operate Switches?');
      }
      notifyListeners();
    } else {
      wholelist[2][accessname]['question']["5"]['toggle'] = <bool>[true, false];
      if (wholelist[2][accessname]['question']["5"]['Answer'].length == 0) {
        setdata(5, 'Yes', 'Able to Operate Switches?');
      }
      notifyListeners();
    }

    if (wholelist[2][accessname]['question']["7"].containsKey('doorwidth')) {
    } else {
      wholelist[2][accessname]['question']["7"]['doorwidth'] = 0;
    }

    if (wholelist[2][accessname]['question']["8"].containsKey('toggle')) {
      if (wholelist[2][accessname]['question']["8"]['Answer'].length == 0) {
        setdata(8, 'Yes', 'Obstacle/Clutter Present?');
      }
      notifyListeners();
    } else {
      wholelist[2][accessname]['question']["8"]['toggle'] = <bool>[true, false];
      if (wholelist[2][accessname]['question']["8"]['Answer'].length == 0) {
        setdata(8, 'Yes', 'Obstacle/Clutter Present?');
      }
      notifyListeners();
    }

    if (wholelist[2][accessname]['question']["9"].containsKey('toggle')) {
      if (wholelist[2][accessname]['question']["9"]['Answer'].length == 0) {
        setdata(9, 'Yes', 'Able to Access Telephone?');
      }
      notifyListeners();
    } else {
      wholelist[2][accessname]['question']["9"]['toggle'] = <bool>[true, false];
      if (wholelist[2][accessname]['question']["9"]['Answer'].length == 0) {
        setdata(9, 'Yes', 'Able to Access Telephone?');
      }
      notifyListeners();
    }

    if (wholelist[2][accessname]['question']["10"].containsKey('toggle')) {
      if (wholelist[2][accessname]['question']["10"]['Answer'].length == 0) {
        setdata(10, 'Yes', 'Smoke Detector Present?');
      }
      notifyListeners();
    } else {
      wholelist[2][accessname]['question']["10"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[2][accessname]['question']["10"]['Answer'].length == 0) {
        setdata(10, 'Yes', 'Smoke Detector Present?');
      }
      notifyListeners();
    }
  }

  Future<String> getRole() async {
    var runtimeType;
    final User useruid = await _auth.currentUser;
    firestoreInstance.collection("users").doc(useruid.uid).get().then(
      (value) {
        runtimeType = value.data()['role'].runtimeType.toString();
        print("runtime Type: $runtimeType");
        if (runtimeType == "List<dynamic>") {
          for (int i = 0; i < value.data()["role"].length; i++) {
            if (value.data()["role"][i].toString() == "therapist") {
              type = "therapist";
            }
          }
        } else {
          type = value.data()["role"];
        }
      },
    );
  }

  setdata(index, value, que) {
    wholelist[2][accessname]['question']["$index"]['Question'] = que;
    if (value.length == 0) {
      if (wholelist[2][accessname]['question']["$index"]['Answer'].length ==
          0) {
      } else {
        wholelist[2][accessname]['complete'] -= 1;
        wholelist[2][accessname]['question']["$index"]['Answer'] = value;
        notifyListeners();
      }
    } else {
      if (wholelist[2][accessname]['question']["$index"]['Answer'].length ==
          0) {
        wholelist[2][accessname]['complete'] += 1;
        notifyListeners();
      }

      wholelist[2][accessname]['question']["$index"]['Answer'] = value;
      notifyListeners();
    }
  }

  setreco(index, value) {
    wholelist[2][accessname]['question']["$index"]['Recommendation'] = value;
    notifyListeners();
  }

  getvalue(index) {
    return wholelist[2][accessname]['question']["$index"]['Answer'];
  }

  getreco(index) {
    return wholelist[2][accessname]['question']["$index"]['Recommendation'];
  }

  setrecothera(index, value) {
    wholelist[2][accessname]['question']["$index"]['Recommendationthera'] =
        value;
    notifyListeners();
  }

  setprio(index, value) {
    wholelist[2][accessname]['question']["$index"]['Priority'] = value;
    notifyListeners();
  }

  getprio(index) {
    return wholelist[2][accessname]['question']["$index"]['Priority'];
  }

  getrecothera(index) {
    return wholelist[2][accessname]['question']["$index"]
        ['Recommendationthera'];
  }

  void showSnackBar(snackbar, BuildContext buildContext) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 3),
      content: Container(
        height: 30.0,
        child: Center(
          child: Text(
            '$snackbar',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
          ),
        ),
      ),
      backgroundColor: lightBlack(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
    );
    ScaffoldMessenger.of(buildContext)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  Future<void> addVideo(String path) {
    video = File(path);
    videoName = basename(video.path);
    isVideoSelected = true;
    notifyListeners();
  }

  void deleteVideo() {
    video = null;
    videoName = '';
    isVideoSelected = false;
    notifyListeners();
  }

  Future<void> uploadVideo() async {
    try {
      print("*************Uploading Video************");
      String name = 'applicationVideos/' + DateTime.now().toIso8601String();
      Reference ref = FirebaseStorage.instance.ref().child(name);

      UploadTask upload = ref.putFile(video);
      String url = "";
      await upload.whenComplete(() => {url = ref.getDownloadURL().toString()});
      videoDownloadUrl = url;
      print("************Url = $videoDownloadUrl**********");
    } catch (e) {
      print(e.toString());
    }
  }
}
