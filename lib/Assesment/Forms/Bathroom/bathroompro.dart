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
  final firestoreInstance = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool obstacle = false;
  bool grabbarneeded = false;
  stt.SpeechToText _speech;
  bool _isListening = false, isColor = false;
  double _confidence = 1.0;
  int doorwidth = 0;
  bool available = false, saveToForm = false;
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
  var falseIndex = -1, trueIndex = -1;

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

    if (wholelist[5][accessname]['question']["5"].containsKey('toggle')) {
    } else {
      wholelist[5][accessname]['question']["5"]['toggle'] = <bool>[true, false];
      wholelist[5][accessname]['question']["5"]['toggle'][0]
          ? wholelist[5][accessname]['question']["5"]['Answer'] = 'Yes'
          : wholelist[5][accessname]['question']["5"]['Answer'] = 'No';
    }

    if (wholelist[5][accessname]['question']["7"].containsKey('doorwidth')) {
    } else {
      print('getting created');
      wholelist[5][accessname]['question']["7"]['doorwidth'] = 0;
    }

    if (wholelist[5][accessname]['question']["8"].containsKey('toggle')) {
    } else {
      wholelist[5][accessname]['question']["8"]['toggle'] = <bool>[true, false];
      wholelist[5][accessname]['question']["8"]['toggle'][0]
          ? wholelist[5][accessname]['question']["8"]['Answer'] = 'Yes'
          : wholelist[5][accessname]['question']["8"]['Answer'] = 'No';
    }

    if (wholelist[5][accessname]['question']["9"].containsKey('toggle')) {
    } else {
      wholelist[5][accessname]['question']["9"]['toggle'] = <bool>[true, false];
      wholelist[5][accessname]['question']["9"]['toggle'][0]
          ? wholelist[5][accessname]['question']["9"]['Answer'] = 'Yes'
          : wholelist[5][accessname]['question']["9"]['Answer'] = 'No';
    }

    if (wholelist[5][accessname]['question']["9"]
        .containsKey('telephoneType')) {
    } else {
      wholelist[5][accessname]['question']["9"]['telephoneType'] = "";
    }

    if (wholelist[5][accessname]['question']["10"].containsKey('toggle')) {
    } else {
      wholelist[5][accessname]['question']["10"]
          ['toggle'] = <bool>[true, false];
      wholelist[5][accessname]['question']["10"]['toggle'][0]
          ? wholelist[5][accessname]['question']["10"]['Answer'] = 'Yes'
          : wholelist[5][accessname]['question']["10"]['Answer'] = 'No';
    }

    if (wholelist[5][accessname]['question']["12"].containsKey('toggle')) {
    } else {
      wholelist[5][accessname]['question']["12"]
          ['toggle'] = <bool>[true, false];
      wholelist[5][accessname]['question']["12"]['toggle'][0]
          ? wholelist[5][accessname]['question']["12"]['Answer'] = 'Yes'
          : wholelist[5][accessname]['question']["12"]['Answer'] = 'No';
    }

    if (wholelist[5][accessname]['question']["13"].containsKey('toggle')) {
    } else {
      wholelist[5][accessname]['question']["13"]
          ['toggle'] = <bool>[true, false];
      wholelist[5][accessname]['question']["13"]['toggle'][0]
          ? wholelist[5][accessname]['question']["13"]['Answer'] = 'Yes'
          : wholelist[5][accessname]['question']["13"]['Answer'] = 'No';
    }

    if (wholelist[5][accessname]['question']["14"].containsKey('toggle')) {
    } else {
      wholelist[5][accessname]['question']["14"]
          ['toggle'] = <bool>[true, false];
      wholelist[5][accessname]['question']["14"]['toggle'][0]
          ? wholelist[5][accessname]['question']["14"]['Answer'] = 'Yes'
          : wholelist[5][accessname]['question']["14"]['Answer'] = 'No';
    }

    if (wholelist[5][accessname]['question']["15"].containsKey('toggle')) {
    } else {
      wholelist[5][accessname]['question']["15"]
          ['toggle'] = <bool>[true, false];
      wholelist[5][accessname]['question']["15"]['toggle'][0]
          ? wholelist[5][accessname]['question']["15"]['Answer'] = 'Yes'
          : wholelist[5][accessname]['question']["15"]['Answer'] = 'No';
    }

    if (wholelist[5][accessname]['question']["15"].containsKey('ManageInOut')) {
    } else {
      wholelist[5][accessname]['question']["15"]['ManageInOut'] = '';
    }

    if (wholelist[5][accessname]['question']["16"].containsKey('toggle')) {
    } else {
      wholelist[5][accessname]['question']["16"]
          ['toggle'] = <bool>[true, false];
      wholelist[5][accessname]['question']["16"]['toggle'][0]
          ? wholelist[5][accessname]['question']["16"]['Answer'] = 'Yes'
          : wholelist[5][accessname]['question']["16"]['Answer'] = 'No';
    }

    if (wholelist[5][accessname]['question']["16"].containsKey('Grabbar')) {
    } else {
      wholelist[5][accessname]['question']["16"]['Grabbar'] = {};
    }

    if (wholelist[5][accessname]['question']["16"]["Grabbar"]
        .containsKey('toggle')) {
    } else {
      wholelist[5][accessname]['question']["16"]['Grabbar']
          ['toggle'] = <bool>[true, false];
      wholelist[5][accessname]['question']["16"]['Grabbar']['toggle'][0]
          ? wholelist[5][accessname]['question']["16"]['Grabbar']
              ['Grabneeded'] = 'Yes'
          : wholelist[5][accessname]['question']["16"]['Grabbar']
              ['Grabneeded'] = 'No';
    }

    if (wholelist[5][accessname]['question']["16"]['Grabbar']
        .containsKey('Grabplacement')) {
    } else {
      wholelist[5][accessname]['question']["16"]['Grabbar']["Grabplacement"] =
          '';
    }

    if (wholelist[5][accessname]['question']["16"]['Grabbar']
        .containsKey('sidefentrance')) {
    } else {
      wholelist[5][accessname]['question']["16"]['Grabbar']['sidefentrance'] =
          '';
    }

    if (wholelist[5][accessname]['question']["16"]['Grabbar']
        .containsKey('distanceFromFloor')) {
    } else {
      wholelist[5][accessname]['question']["16"]['Grabbar']
          ['distanceFromFloor'] = '';
    }
    if (wholelist[5][accessname]['question']["16"]['Grabbar']
        .containsKey('grabBarLength')) {
    } else {
      wholelist[5][accessname]['question']["16"]['Grabbar']['grabBarLength'] =
          '';
    }

    if (wholelist[5][accessname]['question']["18"].containsKey('toggle')) {
    } else {
      wholelist[5][accessname]['question']["18"]
          ['toggle'] = <bool>[true, false];
      wholelist[5][accessname]['question']["18"]['toggle'][0]
          ? wholelist[5][accessname]['question']["18"]['Answer'] = 'Yes'
          : wholelist[5][accessname]['question']["18"]['Answer'] = 'No';
    }

    if (wholelist[5][accessname]['question']["20"].containsKey('toggle')) {
    } else {
      wholelist[5][accessname]['question']["20"]
          ['toggle'] = <bool>[true, false];
      wholelist[5][accessname]['question']["20"]['toggle'][0]
          ? wholelist[5][accessname]['question']["20"]['Answer'] = 'Yes'
          : wholelist[5][accessname]['question']["20"]['Answer'] = 'No';
    }

    if (wholelist[5][accessname]['question']["20"].containsKey('toggle2')) {
    } else {
      wholelist[5][accessname]['question']["20"]
          ['toggle2'] = <bool>[true, false];
      wholelist[5][accessname]['question']["20"]['toggle2'][0]
          ? wholelist[5][accessname]['question']["20"]['ManageInOut'] = 'Yes'
          : wholelist[5][accessname]['question']["20"]['ManageInOut'] = 'No';
    }

    if (wholelist[5][accessname]['question']["21"].containsKey('toggle')) {
    } else {
      wholelist[5][accessname]['question']["21"]
          ['toggle'] = <bool>[true, false];
      wholelist[5][accessname]['question']["21"]['toggle'][0]
          ? wholelist[5][accessname]['question']["21"]['Answer'] = 'Yes'
          : wholelist[5][accessname]['question']["21"]['Answer'] = 'No';
    }

    if (wholelist[5][accessname]['question']["23"].containsKey('toggle')) {
    } else {
      wholelist[5][accessname]['question']["23"]
          ['toggle'] = <bool>[true, false];
      wholelist[5][accessname]['question']["23"]['toggle'][0]
          ? wholelist[5][accessname]['question']["23"]['Answer'] = 'Yes'
          : wholelist[5][accessname]['question']["23"]['Answer'] = 'No';
    }

    if (wholelist[5][accessname]['question']["24"].containsKey('toggle')) {
    } else {
      wholelist[5][accessname]['question']["24"]
          ['toggle'] = <bool>[true, false];
      wholelist[5][accessname]['question']["24"]['toggle'][0]
          ? wholelist[5][accessname]['question']["24"]['Answer'] = 'Yes'
          : wholelist[5][accessname]['question']["24"]['Answer'] = 'No';
    }

    if (wholelist[5][accessname]['question']["20"].containsKey('ManageInOut')) {
    } else {
      wholelist[5][accessname]['question']["20"]['ManageInOut'] = '';
    }

    // if (wholelist[5][accessname]['question']["17"]
    //     .containsKey('sidefentrance')) {
    // } else {
    //   wholelist[5][accessname]['question']["17"]['sidefentrance'] = '';
    // }
  }

  Future<void> addVideo(String path) {
    video = File(path);
    videoName = basename(video.path);
    isVideoSelected = true;
    notifyListeners();
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
        notifyListeners();
      },
    );
  }

  setdata(index, value, que) {
    if (wholelist[5][accessname].containsKey('isSave')) {
    } else {
      wholelist[5][accessname]["isSave"] = true;
    }
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
      // saveToForm = true;
      // wholelist[5][accessname]["isSave"] = saveToForm;
    } else {
      isColor = false;
      // saveToForm = false;
      // wholelist[5][accessname]["isSave"] = saveToForm;
    }
    if (falseIndex == -1) {
      if (wholelist[5][accessname]["question"]["$index"]
              ["Recommendationthera"] !=
          "") {
        saveToForm = true;
        trueIndex = index;
        wholelist[5][accessname]["isSave"] = saveToForm;
      } else {
        saveToForm = false;
        falseIndex = index;
        wholelist[5][accessname]["isSave"] = saveToForm;
      }
    } else {
      if (index == falseIndex) {
        if (wholelist[5][accessname]["question"]["$index"]
                ["Recommendationthera"] !=
            "") {
          wholelist[5][accessname]["isSave"] = true;
          falseIndex = -1;
        } else {
          wholelist[5][accessname]["isSave"] = false;
        }
      }
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
                      heroTag: "btn${index + 100}",
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
              labelText: 'Recommendation'),
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
