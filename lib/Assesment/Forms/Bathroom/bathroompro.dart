import 'dart:io';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Formsrepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avatar_glow/avatar_glow.dart';

import '../../../constants.dart';
import 'package:path/path.dart';

class BathroomPro extends ChangeNotifier {
  String roomname, docID;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  final firestoreInstance = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool obstacle = false;
  bool grabbarneeded = false;
  stt.SpeechToText _speech;
  bool _isListening = false, isColor = false;
  double _confidence = 1.0;
  int doorwidth = 0;
  bool available = false;
  Map<String, Color> colorsset = {};
  Map<String, TextEditingController> controllers = {};
  Map<String, TextEditingController> controllerstreco = {};
  Map<String, bool> isListening = {};
  bool cur = true;
  String type;
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

  BathroomPro(this.roomname, this.wholelist, this.accessname, this.docID) {
    _speech = stt.SpeechToText();
    for (int i = 0; i < wholelist[5][accessname]['question'].length; i++) {
      controllers["field${i + 1}"] = TextEditingController();
      controllerstreco["field${i + 1}"] = TextEditingController();
      isListening["field${i + 1}"] = false;
      controllers["field${i + 1}"].text =
          wholelist[5][accessname]['question']["${i + 1}"]['Recommendation'];
      controllerstreco["field${i + 1}"].text =
          '${wholelist[5][accessname]['question']["${i + 1}"]['Recommendationthera']}';
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
    getRole();
    setinitials();
  }
  void _showSnackBar(snackbar, BuildContext buildContext) {
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

  Future<void> setinitials() async {
    if (wholelist[5][accessname].containsKey('videos')) {
      if (wholelist[5][accessname]['videos'].containsKey('name')) {
      } else {
        wholelist[5][accessname]['videos']['name'] = "";
      }
      if (wholelist[5][accessname]['videos'].containsKey('url')) {
      } else {
        wholelist[5][accessname]['videos']['url'] = "";
      }
    } else {
      // print('Yes,it is');

      wholelist[5][accessname]["videos"] = {'name': '', 'url': ''};
    }
    if (wholelist[5][accessname]['question']["7"].containsKey('doorwidth')) {
    } else {
      print('getting created');
      wholelist[5][accessname]['question']["7"]['doorwidth'] = 0;
    }
    if (wholelist[5][accessname]['question']["9"]
        .containsKey('telephoneType')) {
    } else {
      wholelist[5][accessname]['question']["9"]['telephoneType'] = "";
    }

    if (wholelist[5][accessname]['question']["15"].containsKey('ManageInOut')) {
    } else {
      wholelist[5][accessname]['question']["15"]['ManageInOut'] = '';
    }

    if (wholelist[5][accessname]['question']["16"].containsKey('Grabbar')) {
    } else {
      wholelist[5][accessname]['question']["16"]['Grabbar'] = {};
    }

    if (wholelist[5][accessname]['question']["17"]
        .containsKey('sidefentrance')) {
    } else {
      wholelist[5][accessname]['question']["17"]['sidefentrance'] = '';
    }
  }

  Future<void> addVideo(String path) {
    video = File(path);
    videoName = basename(video.path);
    isVideoSelected = true;
    notifyListeners();
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

  setdata(index, value, que) {
    wholelist[5][accessname]['question']["$index"]['Question'] = que;
    if (value.length == 0) {
      if (wholelist[5][accessname]['question']["$index"]['Answer'].length ==
          0) {
      } else {
        wholelist[5][accessname]['complete'] -= 1;
        wholelist[5][accessname]['question']["$index"]['Answer'] = value;

        notifyListeners();
      }
    } else {
      if (wholelist[5][accessname]['question']["$index"]['Answer'].length ==
          0) {
        wholelist[5][accessname]['complete'] += 1;
        notifyListeners();
      }
      wholelist[5][accessname]['question']["$index"]['Answer'] = value;
      notifyListeners();
    }
  }

  setreco(index, value) {
    wholelist[5][accessname]['question']["$index"]['Recommendation'] = value;
    notifyListeners();
  }

  getvalue(index) {
    return wholelist[5][accessname]['question']["$index"]['Answer'];
  }

  getreco(index) {
    return wholelist[5][accessname]['question']["$index"]['Recommendation'];
  }

  setrecothera(index, value) {
    wholelist[5][accessname]['question']["$index"]['Recommendationthera'] =
        value;
    notifyListeners();
  }

  setprio(index, value) {
    wholelist[5][accessname]['question']["$index"]['Priority'] = value;
    notifyListeners();
  }

  getprio(index) {
    return wholelist[5][accessname]['question']["$index"]['Priority'];
  }

  getrecothera(index) {
    return wholelist[5][accessname]['question']["$index"]
        ['Recommendationthera'];
  }

  Widget getrecomain(
      assesmentprovider,
      int index,
      bool isthera,
      String fieldlabel,
      String assessor,
      String therapist,
      String role,
      BuildContext bcontext) {
    return SingleChildScrollView(
      // reverse: true,
      child: Container(
        // color: Colors.yellow,
        child: Column(
          children: [
            SizedBox(height: 5),
            Container(
              child: TextFormField(
                maxLines: null,
                showCursor: assesmentprovider.cur,
                controller: assesmentprovider.controllers["field$index"],
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: assesmentprovider.colorsset["field$index"],
                          width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1,
                          color: assesmentprovider.colorsset["field$index"]),
                    ),
                    suffix: Container(
                      // color: Colors.red,
                      width: 40,
                      height: 30,
                      padding: EdgeInsets.all(0),
                      child: Row(children: [
                        Container(
                          // color: Colors.green,
                          alignment: Alignment.center,
                          width: 40,
                          height: 60,
                          margin: EdgeInsets.all(0),
                          child: AvatarGlow(
                            animate:
                                assesmentprovider.isListening['field$index'],
                            // glowColor: Theme.of().primaryColor,
                            endRadius: 500.0,
                            duration: const Duration(milliseconds: 2000),
                            repeatPauseDuration:
                                const Duration(milliseconds: 100),
                            repeat: true,
                            child: FloatingActionButton(
                              heroTag: "btn$index",
                              child: Icon(
                                Icons.mic,
                                size: 20,
                              ),
                              onPressed: () {
                                if (assessor == therapist &&
                                    role == "therapist") {
                                  listen(index);
                                  setdatalisten(index);
                                } else if (role != "therapist") {
                                  listen(index);
                                  setdatalisten(index);
                                } else {
                                  _showSnackBar(
                                      "You can't change the other fields",
                                      bcontext);
                                }
                              },
                            ),
                          ),
                        ),
                      ]),
                    ),
                    labelText: fieldlabel),
                onChanged: (value) {
                  if (assessor == therapist && role == "therapist") {
                    assesmentprovider.setreco(index, value);
                  } else if (role != "therapist") {
                    assesmentprovider.setreco(index, value);
                  } else {
                    _showSnackBar(
                        "You can't change the other fields", bcontext);
                  }
                  // print(accessname);
                },
              ),
            ),
            (role == 'therapist' && isthera)
                ? getrecowid(assesmentprovider, index)
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget getrecowid(assesmentprovider, index) {
    if (wholelist[5][accessname]["question"]["$index"]["Recommendationthera"] !=
        "") {
      isColor = true;
    } else {
      isColor = false;
    }
    return Column(
      children: [
        SizedBox(height: 8),
        TextFormField(
          controller: controllerstreco["field$index"],
          decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: (isColor) ? Colors.green : Colors.red, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: 1, color: (isColor) ? Colors.green : Colors.red),
              ),
              suffix: Container(
                // color: Colors.red,
                width: 40,
                height: 30,
                padding: EdgeInsets.all(0),
                child: Row(children: [
                  Container(
                    // color: Colors.green,
                    alignment: Alignment.center,
                    width: 40,
                    height: 60,
                    margin: EdgeInsets.all(0),
                    child: FloatingActionButton(
                      heroTag: "btn${index + 1}",
                      child: Icon(
                        Icons.mic,
                        size: 20,
                      ),
                      onPressed: () {
                        _listenthera(index);
                        setdatalistenthera(index);
                      },
                    ),
                  ),
                ]),
              ),
              labelStyle:
                  TextStyle(color: (isColor) ? Colors.green : Colors.red),
              labelText: 'Recomendation'),
          onChanged: (value) {
            // print(accessname);
            assesmentprovider.setrecothera(index, value);
            print('hejdfdf');
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Priority'),
            Row(
              children: [
                Radio(
                  value: '1',
                  onChanged: (value) {
                    assesmentprovider.setprio(index, value);
                  },
                  groupValue: assesmentprovider.getprio(index),
                ),
                Text('1'),
                Radio(
                  value: '2',
                  onChanged: (value) {
                    assesmentprovider.setprio(index, value);
                    notifyListeners();
                  },
                  groupValue: assesmentprovider.getprio(index),
                ),
                Text('2'),
                Radio(
                  value: '3',
                  onChanged: (value) {
                    assesmentprovider.setprio(index, value);
                    notifyListeners();
                  },
                  groupValue: assesmentprovider.getprio(index),
                ),
                Text('3'),
              ],
            )
          ],
        )
      ],
    );
  }

  void _listenthera(index) async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          // setState(() {
          //   // _isListening = false;
          //   //
          // });
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        _isListening = true;
        // colorsset["field$index"] = Colors.red;
        isListening['field$index'] = true;
        notifyListeners();
        _speech.listen(
          onResult: (val) {
            controllerstreco["field$index"].text = wholelist[5][accessname]
                    ['question']["$index"]['Recommendationthera'] +
                " " +
                val.recognizedWords;
            notifyListeners();
          },
        );
      }
    } else {
      _isListening = false;
      isListening['field$index'] = false;
      colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
      notifyListeners();
      _speech.stop();
    }
  }

  setdatalistenthera(index) {
    wholelist[5][accessname]['question']["$index"]['Recommendationthera'] =
        controllerstreco["field$index"].text;
    cur = !cur;
    notifyListeners();
  }

  void listen(index) async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          // setState(() {
          //   // _isListening = false;
          //   //
          // });
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        _isListening = true;
        // colorsset["field$index"] = Colors.red;
        isListening['field$index'] = true;
        notifyListeners();
        _speech.listen(onResult: (val) {
          controllers["field$index"].text = wholelist[5][accessname]['question']
                  ["$index"]['Recommendation'] +
              " " +
              val.recognizedWords;
          if (val.hasConfidenceRating && val.confidence > 0) {
            _confidence = val.confidence;
          }
          notifyListeners();
        });
      }
    } else {
      _isListening = false;
      isListening['field$index'] = false;
      colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
      notifyListeners();
      _speech.stop();
    }
  }

  setdatalisten(index) {
    wholelist[5][accessname]['question']["$index"]['Recommendation'] =
        controllers["field$index"].text;
    cur = !cur;
    notifyListeners();
  }
}
