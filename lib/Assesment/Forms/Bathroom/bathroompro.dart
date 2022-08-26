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
      controllers["field${i + 1}"].text = capitalize(
          wholelist[5][accessname]['question']["${i + 1}"]['Recommendation']);
      controllerstreco["field${i + 1}"].text =
          '${capitalize(wholelist[5][accessname]['question']["${i + 1}"]['Recommendationthera'])}';
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
    getRole();
    setinitials();
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
      if (wholelist[5][accessname]['question']["5"]['Answer'].length == 0) {
        setdata(5, 'Yes', 'Able to Operate Switches?');
      }
      notifyListeners();
    } else {
      wholelist[5][accessname]['question']["5"]['toggle'] = <bool>[true, false];
      if (wholelist[5][accessname]['question']["5"]['Answer'].length == 0) {
        setdata(5, 'Yes', 'Able to Operate Switches?');
      }
      notifyListeners();
    }

    if (wholelist[5][accessname]['question']["7"].containsKey('doorwidth')) {
    } else {
      print('getting created');
      wholelist[5][accessname]['question']["7"]['doorwidth'] = 0;
    }

    if (wholelist[5][accessname]['question']["8"].containsKey('toggle')) {
      if (wholelist[5][accessname]['question']["8"]['Answer'].length == 0) {
        setdata(8, 'Yes', 'Obstacle/Clutter Present?');
      }
      notifyListeners();
    } else {
      wholelist[5][accessname]['question']["8"]['toggle'] = <bool>[true, false];
      if (wholelist[5][accessname]['question']["8"]['Answer'].length == 0) {
        setdata(8, 'Yes', 'Obstacle/Clutter Present?');
      }
      notifyListeners();
    }

    if (wholelist[5][accessname]['question']["9"].containsKey('toggle')) {
      if (wholelist[5][accessname]['question']["9"]['Answer'].length == 0) {
        setdata(9, "Yes", 'Able to Access Telephone?');
      }
      notifyListeners();
    } else {
      wholelist[5][accessname]['question']["9"]['toggle'] = <bool>[true, false];
      if (wholelist[5][accessname]['question']["9"]['Answer'].length == 0) {
        setdata(9, "Yes", 'Able to Access Telephone?');
      }
      notifyListeners();
    }

    if (wholelist[5][accessname]['question']["9"]
        .containsKey('telephoneType')) {
    } else {
      wholelist[5][accessname]['question']["9"]['telephoneType'] = "";
    }

    if (wholelist[5][accessname]['question']["10"].containsKey('toggle')) {
      if (wholelist[5][accessname]['question']["10"]['Answer'].length == 0) {
        setdata(10, "Yes", 'Smoke Detector Present?');
      }
      notifyListeners();
    } else {
      wholelist[5][accessname]['question']["10"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[5][accessname]['question']["10"]['Answer'].length == 0) {
        setdata(10, "Yes", 'Smoke Detector Present?');
      }
      notifyListeners();
    }

    if (wholelist[5][accessname]['question']["12"].containsKey('toggle')) {
      if (wholelist[5][accessname]['question']["12"]['Answer'].length == 0) {
        setdata(12, "Yes", 'Has access to medicine cabinet?');
      }
      notifyListeners();
    } else {
      wholelist[5][accessname]['question']["12"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[5][accessname]['question']["12"]['Answer'].length == 0) {
        setdata(12, "Yes", 'Has access to medicine cabinet?');
      }
      notifyListeners();
    }

    if (wholelist[5][accessname]['question']["13"].containsKey('toggle')) {
      if (wholelist[5][accessname]['question']["13"]['Answer'].length == 0) {
        setdata(13, "Yes", 'Has access to cabinet under sink?');
      }
      notifyListeners();
    } else {
      wholelist[5][accessname]['question']["13"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[5][accessname]['question']["13"]['Answer'].length == 0) {
        setdata(13, "Yes", 'Has access to cabinet under sink?');
      }
      notifyListeners();
    }

    if (wholelist[5][accessname]['question']["14"].containsKey('toggle')) {
      if (wholelist[5][accessname]['question']["14"]['Answer'].length == 0) {
        setdata(14, "Yes", 'Shower: Present?');
      }
      notifyListeners();
    } else {
      wholelist[5][accessname]['question']["14"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[5][accessname]['question']["14"]['Answer'].length == 0) {
        setdata(14, "Yes", 'Shower: Present?');
      }
      notifyListeners();
    }

    if (wholelist[5][accessname]['question']["15"].containsKey('toggle')) {
      if (wholelist[5][accessname]['question']["15"]['Answer'].length == 0) {
        setdata(15, "Yes", 'Able to manage in & out of the shower?');
      }
      notifyListeners();
    } else {
      wholelist[5][accessname]['question']["15"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[5][accessname]['question']["15"]['Answer'].length == 0) {
        setdata(15, "Yes", 'Able to manage in & out of the shower?');
      }
      notifyListeners();
    }

    if (wholelist[5][accessname]['question']["15"].containsKey('ManageInOut')) {
    } else {
      wholelist[5][accessname]['question']["15"]['ManageInOut'] = '';
    }

    if (wholelist[5][accessname]['question']["16"].containsKey('toggle')) {
      if (wholelist[5][accessname]['question']["16"]['Answer'].length == 0) {
        setdata(16, "Yes", 'Grab Bars Present?');
      }
      notifyListeners();
    } else {
      wholelist[5][accessname]['question']["16"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[5][accessname]['question']["16"]['Answer'].length == 0) {
        setdata(16, "Yes", 'Grab Bars Present?');
      }
      notifyListeners();
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
      notifyListeners();
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
      if (wholelist[5][accessname]['question']["18"]['Answer'].length == 0) {
        setdata(18, "Yes", "Hand-Held Shower Present?");
      }
      notifyListeners();
    } else {
      wholelist[5][accessname]['question']["18"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[5][accessname]['question']["18"]['Answer'].length == 0) {
        setdata(18, "Yes", "Hand-Held Shower Present?");
      }
      notifyListeners();
    }

    if (wholelist[5][accessname]['question']["20"].containsKey('toggle')) {
      if (wholelist[5][accessname]['question']["20"]['Answer'].length == 0) {
        setdata(20, "Yes", 'Tub Present?');
      }
      notifyListeners();
    } else {
      wholelist[5][accessname]['question']["20"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[5][accessname]['question']["20"]['Answer'].length == 0) {
        setdata(20, "Yes", 'Tub Present?');
      }
      notifyListeners();
    }

    if (wholelist[5][accessname]['question']["20"].containsKey('toggle2')) {
    } else {
      wholelist[5][accessname]['question']["20"]
          ['toggle2'] = <bool>[true, false];
      wholelist[5][accessname]['question']["20"]['toggle2'][0]
          ? wholelist[5][accessname]['question']["20"]['ManageInOut'] = 'Yes'
          : wholelist[5][accessname]['question']["20"]['ManageInOut'] = 'No';
      notifyListeners();
    }

    if (wholelist[5][accessname]['question']["21"].containsKey('toggle')) {
      if (wholelist[5][accessname]['question']["21"]['Answer'].length == 0) {
        setdata(21, "Yes", 'Able to access faucets Independently?');
      }
      notifyListeners();
    } else {
      wholelist[5][accessname]['question']["21"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[5][accessname]['question']["21"]['Answer'].length == 0) {
        setdata(21, "Yes", 'Able to access faucets Independently?');
      }
      notifyListeners();
    }

    if (wholelist[5][accessname]['question']["23"].containsKey('toggle')) {
      if (wholelist[5][accessname]['question']["23"]['Answer'].length == 0) {
        setdata(23, "Yes", 'Can get on/off commode independently?');
      }
      notifyListeners();
    } else {
      wholelist[5][accessname]['question']["23"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[5][accessname]['question']["23"]['Answer'].length == 0) {
        setdata(23, "Yes", 'Can get on/off commode independently?');
      }
      notifyListeners();
    }

    if (wholelist[5][accessname]['question']["24"].containsKey('toggle')) {
      if (wholelist[5][accessname]['question']["24"]['Answer'].length == 0) {
        setdata(24, "Yes", 'Able to flush commode independently?');
      }
      notifyListeners();
    } else {
      wholelist[5][accessname]['question']["24"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[5][accessname]['question']["24"]['Answer'].length == 0) {
        setdata(24, "Yes", 'Able to flush commode independently?');
      }
      notifyListeners();
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
                    if (index == 10) {
                      controllerstreco['field10'].text =
                          'Please install a well functioning Smoke detector Immediately. Most states have free Smoke Detectors available for FREE. Please contact your local Fire Department.';
                      assesmentprovider.setrecothera(10,
                          'Please install a well functioning Smoke detector Immediately. Most states have free Smoke Detectors available for FREE. Please contact your local Fire Department.');
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
                    if (index == 10) {
                      controllerstreco['field10'].text = '';
                      assesmentprovider.setrecothera(10, '');
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
                    if (index == 10) {
                      controllerstreco['field10'].text = '';
                      assesmentprovider.setrecothera(10, '');
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
    setdatalistenthera(index);
    notifyListeners();
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
    setdatalisten(index);
    notifyListeners();
  }

  setdatalisten(index) {
    wholelist[5][accessname]['question']["$index"]['Recommendation'] =
        controllers["field$index"].text;
    cur = !cur;
    if (index == 25) {
      if (controllers["field$index"].text.length == 0) {
        if (wholelist[5][accessname]['question']["$index"]['Answer'].length ==
            0) {
        } else {
          wholelist[5][accessname]['complete'] -= 1;
          wholelist[5][accessname]['question']["$index"]['Answer'] =
              controllers["field$index"].text;
        }
      } else {
        if (wholelist[5][accessname]['question']["$index"]['Answer'].length ==
            0) {
          wholelist[5][accessname]['complete'] += 1;
        }

        wholelist[5][accessname]['question']["$index"]['Answer'] =
            controllers["field$index"].text;
      }
    }
    notifyListeners();
  }
}
