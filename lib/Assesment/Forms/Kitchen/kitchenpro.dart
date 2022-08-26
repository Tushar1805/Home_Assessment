import 'dart:io';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Formsrepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avatar_glow/avatar_glow.dart';

import '../../../constants.dart';
import 'package:path/path.dart';

class KitchenPro extends ChangeNotifier {
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
  var falseIndex = -1, trueIndex = -1;

  KitchenPro(this.roomname, this.wholelist, this.accessname) {
    _speech = stt.SpeechToText();
    for (int i = 0; i < wholelist[3][accessname]['question'].length; i++) {
      controllers["field${i + 1}"] = TextEditingController();
      controllerstreco["field${i + 1}"] = TextEditingController();
      isListening["field${i + 1}"] = false;
      controllers["field${i + 1}"].text = capitalize(
          wholelist[3][accessname]['question']["${i + 1}"]['Recommendation']);
      controllerstreco["field${i + 1}"].text =
          '${capitalize(wholelist[3][accessname]['question']["${i + 1}"]['Recommendationthera'])}';
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
    getRole();
    setinitials();
    doorwidth = int.tryParse('$getvalue(7)');
  }

  String capitalize(String s) {
    // Each sentence becomes an array element
    var output = '';
    if (s != null && s != '') {
      var sentences = s.split('.');
      // Initialize string as empty string

      // Loop through each sentence
      for (var sen in sentences) {
        // Trim leading and trailing whitespace
        var trimmed = sen.trim();
        // Capitalize first letter of current sentence

        var capitalized = trimmed.isNotEmpty
            ? "${trimmed[0].toUpperCase() + trimmed.substring(1)}"
            : '';
        // Add current sentence to output with a period
        output += capitalized + ". ";
      }
    }
    return output;
  }

  Future<void> setinitials() async {
    if (wholelist[3][accessname].containsKey('isSave')) {
    } else {
      wholelist[3][accessname]["isSave"] = true;
    }
    if (wholelist[3][accessname].containsKey('videos')) {
      if (wholelist[3][accessname]['videos'].containsKey('name')) {
      } else {
        wholelist[3][accessname]['videos']['name'] = "";
      }
      if (wholelist[3][accessname]['videos'].containsKey('url')) {
      } else {
        wholelist[3][accessname]['videos']['url'] = "";
      }
    } else {
      // print('Yes,it is');

      wholelist[3][accessname]["videos"] = {'name': '', 'url': ''};
    }

    if (wholelist[3][accessname]['question']["5"].containsKey('toggle')) {
      if (wholelist[3][accessname]['question']["5"]['Answer'].length == 0) {
        setdata(5, 'Yes', 'Able to Operate Switches?');
      }
      notifyListeners();
    } else {
      wholelist[3][accessname]['question']["5"]['toggle'] = <bool>[true, false];
      if (wholelist[3][accessname]['question']["5"]['Answer'].length == 0) {
        setdata(5, 'Yes', 'Able to Operate Switches?');
      }
      notifyListeners();
    }

    if (wholelist[3][accessname]['question']["7"].containsKey('doorwidth')) {
    } else {
      print('getting created');
      wholelist[3][accessname]['question']["7"]['doorwidth'] = 0;
    }

    if (wholelist[3][accessname]['question']["8"].containsKey('toggle')) {
      if (wholelist[3][accessname]['question']["8"]['Answer'].length == 0) {
        setdata(8, 'Yes', 'Obstacle/Clutter Present?');
      }
      notifyListeners();
    } else {
      wholelist[3][accessname]['question']["8"]['toggle'] = <bool>[true, false];
      if (wholelist[3][accessname]['question']["8"]['Answer'].length == 0) {
        setdata(8, 'Yes', 'Obstacle/Clutter Present?');
      }
      notifyListeners();
    }

    if (wholelist[3][accessname]['question']["9"].containsKey('toggle')) {
      if (wholelist[3][accessname]['question']["9"]['Answer'].length == 0) {
        setdata(9, 'Yes', 'Able to Access Telephone?');
      }
      notifyListeners();
    } else {
      wholelist[3][accessname]['question']["9"]['toggle'] = <bool>[true, false];
      if (wholelist[3][accessname]['question']["9"]['Answer'].length == 0) {
        setdata(9, 'Yes', 'Able to Access Telephone?');
      }
      notifyListeners();
    }

    if (wholelist[3][accessname]['question']["10"].containsKey('toggle')) {
      if (wholelist[3][accessname]['question']["10"]['Answer'].length == 0) {
        setdata(10, 'Yes', 'Able to Access Stove?');
      }
      notifyListeners();
    } else {
      wholelist[3][accessname]['question']["10"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[3][accessname]['question']["10"]['Answer'].length == 0) {
        setdata(10, 'Yes', 'Able to Access Stove?');
      }
      notifyListeners();
    }

    if (wholelist[3][accessname]['question']["12"].containsKey('toggle')) {
      if (wholelist[3][accessname]['question']["12"]['Answer'].length == 0) {
        setdata(12, 'Yes', 'Able to Access Sink?');
      }
      notifyListeners();
    } else {
      wholelist[3][accessname]['question']["12"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[3][accessname]['question']["12"]['Answer'].length == 0) {
        setdata(12, 'Yes', 'Able to Access Sink?');
      }
      notifyListeners();
    }

    if (wholelist[3][accessname]['question']["13"].containsKey('toggle')) {
      if (wholelist[3][accessname]['question']["13"]['Answer'].length == 0) {
        setdata(13, 'Yes', 'Able to Access Dishwasher?');
      }
      notifyListeners();
    } else {
      wholelist[3][accessname]['question']["13"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[3][accessname]['question']["13"]['Answer'].length == 0) {
        setdata(13, 'Yes', 'Able to Access Dishwasher?');
      }
      notifyListeners();
    }

    if (wholelist[3][accessname]['question']["14"].containsKey('toggle')) {
      if (wholelist[3][accessname]['question']["14"]['Answer'].length == 0) {
        setdata(14, 'Yes', 'Able to Access Refrigerator?');
      }
      notifyListeners();
    } else {
      wholelist[3][accessname]['question']["14"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[3][accessname]['question']["14"]['Answer'].length == 0) {
        setdata(14, 'Yes', 'Able to Access Refrigerator?');
      }
      notifyListeners();
    }

    if (wholelist[3][accessname]['question']["15"].containsKey('toggle')) {
      if (wholelist[3][accessname]['question']["15"]['Answer'].length == 0) {
        setdata(15, 'Yes', 'Able to Access High Cabinets?');
      }
      notifyListeners();
    } else {
      wholelist[3][accessname]['question']["15"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[3][accessname]['question']["15"]['Answer'].length == 0) {
        setdata(15, 'Yes', 'Able to Access High Cabinets?');
      }
      notifyListeners();
    }

    if (wholelist[3][accessname]['question']["15"].containsKey('ManageInOut')) {
    } else {
      wholelist[3][accessname]['question']["15"]['ManageInOut'] = '';
    }

    if (wholelist[3][accessname]['question']["16"].containsKey('toggle')) {
      if (wholelist[3][accessname]['question']["16"]['Answer'].length == 0) {
        setdata(16, 'Yes', 'Able to Access Lower Cabinets?');
      }
      notifyListeners();
    } else {
      wholelist[3][accessname]['question']["16"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[3][accessname]['question']["16"]['Answer'].length == 0) {
        setdata(16, 'Yes', 'Able to Access Lower Cabinets?');
      }
      notifyListeners();
    }

    if (wholelist[3][accessname]['question']["17"].containsKey('toggle')) {
      if (wholelist[3][accessname]['question']["17"]['Answer'].length == 0) {
        setdata(17, 'Yes', 'Smoke Detector Present?');
      }
      notifyListeners();
    } else {
      wholelist[3][accessname]['question']["17"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[3][accessname]['question']["17"]['Answer'].length == 0) {
        setdata(17, 'Yes', 'Smoke Detector Present?');
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
        notifyListeners();
      },
    );
  }

  Future<void> addVideo(String path) {
    video = File(path);
    videoName = basename(video.path);
    isVideoSelected = true;
    notifyListeners();
  }

  setdata(index, value, que) {
    wholelist[3][accessname]['question']["$index"]['Question'] = que;
    if (value.length == 0) {
      if (wholelist[3][accessname]['question']["$index"]['Answer'].length ==
          0) {
      } else {
        wholelist[3][accessname]['complete'] -= 1;
        wholelist[3][accessname]['question']["$index"]['Answer'] = value;

        notifyListeners();
      }
    } else {
      if (wholelist[3][accessname]['question']["$index"]['Answer'].length ==
          0) {
        wholelist[3][accessname]['complete'] += 1;
        notifyListeners();
      }
      wholelist[3][accessname]['question']["$index"]['Answer'] = value;
      notifyListeners();
    }
  }

  setreco(index, value) {
    wholelist[3][accessname]['question']["$index"]['Recommendation'] = value;
    notifyListeners();
  }

  getvalue(index) {
    return wholelist[3][accessname]['question']["$index"]['Answer'];
  }

  getreco(index) {
    return wholelist[3][accessname]['question']["$index"]['Recommendation'];
  }

  setrecothera(index, value) {
    wholelist[3][accessname]['question']["$index"]['Recommendationthera'] =
        value;
    notifyListeners();
  }

  setprio(index, value) {
    wholelist[3][accessname]['question']["$index"]['Priority'] = value;
    notifyListeners();
  }

  getprio(index) {
    return wholelist[3][accessname]['question']["$index"]['Priority'];
  }

  getrecothera(index) {
    return wholelist[3][accessname]['question']["$index"]
        ['Recommendationthera'];
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
    if (wholelist[3][accessname]["question"]["$index"]["Recommendationthera"] !=
        "") {
      isColor = true;
      // saveToForm = true;
      // wholelist[3][accessname]["isSave"] = saveToForm;
    } else {
      isColor = false;
      // saveToForm = false;
      // wholelist[3][accessname]["isSave"] = saveToForm;
    }
    if (falseIndex == -1) {
      if (wholelist[3][accessname]["question"]["$index"]
              ["Recommendationthera"] !=
          "") {
        saveToForm = true;
        trueIndex = index;
        wholelist[3][accessname]["isSave"] = saveToForm;
      } else {
        saveToForm = false;
        falseIndex = index;
        wholelist[3][accessname]["isSave"] = saveToForm;
      }
    } else {
      if (index == falseIndex) {
        if (wholelist[3][accessname]["question"]["$index"]
                ["Recommendationthera"] !=
            "") {
          wholelist[3][accessname]["isSave"] = true;
          falseIndex = -1;
        } else {
          wholelist[3][accessname]["isSave"] = false;
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
                    color: controllerstreco["field$index"].text != ""
                        ? Colors.green
                        : Colors.red,
                    width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: 1,
                    color: controllerstreco["field$index"].text != ""
                        ? Colors.green
                        : Colors.red),
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
              labelStyle: TextStyle(
                  color: controllerstreco["field$index"].text != ""
                      ? Colors.green
                      : Colors.red),
              labelText: 'Recommendation'),
          onChanged: (value) {
            // print(accessname);
            assesmentprovider.setrecothera(index, value);
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
                    if (index == 17) {
                      controllerstreco['field17'].text =
                          'Please install a well functioning Smoke detector Immediately. Most states have free Smoke Detectors available for FREE. Please contact your local Fire Department';
                      assesmentprovider.setrecothera(17,
                          'Please install a well functioning Smoke detector Immediately. Most states have free Smoke Detectors available for FREE. Please contact your local Fire Department');
                    }
                    notifyListeners();
                  },
                  groupValue: assesmentprovider.getprio(index),
                ),
                Text('1'),
                Radio(
                  value: '2',
                  onChanged: (value) {
                    assesmentprovider.setprio(index, value);
                    if (index == 17) {
                      controllerstreco['field17'].text = '';
                      assesmentprovider.setrecothera(17, '');
                    }
                    notifyListeners();
                  },
                  groupValue: assesmentprovider.getprio(index),
                ),
                Text('2'),
                Radio(
                  value: '3',
                  onChanged: (value) {
                    assesmentprovider.setprio(index, value);
                    if (index == 17) {
                      controllerstreco['field17'].text = '';
                      assesmentprovider.setrecothera(17, '');
                    }
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
            controllerstreco["field$index"].text = wholelist[3][accessname]
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
    setdatalistenthera(index);
    notifyListeners();
  }

  setdatalistenthera(index) {
    wholelist[3][accessname]['question']["$index"]['Recommendationthera'] =
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
          controllers["field$index"].text = wholelist[3][accessname]['question']
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
    setdatalisten(index);
    notifyListeners();
  }

  setdatalisten(index) {
    wholelist[3][accessname]['question']["$index"]['Recommendation'] =
        controllers["field$index"].text;
    cur = !cur;
    if (index == 18) {
      if (controllers["field$index"].text.length == 0) {
        if (wholelist[3][accessname]['question']["$index"]['Answer'].length ==
            0) {
        } else {
          wholelist[3][accessname]['complete'] -= 1;
          wholelist[3][accessname]['question']["$index"]['Answer'] =
              controllers["field$index"].text;
        }
      } else {
        if (wholelist[3][accessname]['question']["$index"]['Answer'].length ==
            0) {
          wholelist[3][accessname]['complete'] += 1;
        }

        wholelist[3][accessname]['question']["$index"]['Answer'] =
            controllers["field$index"].text;
      }
    }
    notifyListeners();
  }
}
