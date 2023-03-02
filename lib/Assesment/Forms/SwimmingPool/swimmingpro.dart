import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:path/path.dart';

import '../../../constants.dart';

class SwimmingPoolProvider extends ChangeNotifier {
  stt.SpeechToText _speech;
  bool _isListening = false;
  Map<String, Color> colorsset = {};
  final firestoreInstance = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, TextEditingController> _controllers = {};
  Map<String, TextEditingController> _controllerstreco = {};
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  String type;
  String roomname;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  Map<String, bool> isListening = {};
  String imageName = '';
  String imageDownloadUrl;
  String imageUrl;
  File image;
  bool isImageSelected = false;
  List<String> mediaList = [];
  String videoName = '';
  String videoDownloadUrl;
  String selectedRequestId;
  String videoUrl;
  File video;
  bool isVideoSelected = false;
  bool isColor = false;
  var falseIndex = -1, trueIndex = -1;
  bool saveToForm = false;
  double _confidence = 1.0;
  bool available = false;
  Map<String, TextEditingController> controllers = {};
  Map<String, TextEditingController> controllerstreco = {};
  bool cur = true;
  String therapist, curUid, assessor;
  var test = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  SwimmingPoolProvider(this.roomname, this.wholelist, this.accessname) {
    _speech = stt.SpeechToText();
    for (int i = 0; i < wholelist[11][accessname]['question'].length; i++) {
      _controllers["field${i + 1}"] = TextEditingController();
      _controllerstreco["field${i + 1}"] = TextEditingController();
      isListening["field${i + 1}"] = false;
      _controllers["field${i + 1}"].text =
          wholelist[11][accessname]['question']["${i + 1}"]['Recommendation'];
      _controllerstreco["field${i + 1}"].text =
          '${wholelist[11][accessname]['question']["${i + 1}"]['Recommendationthera']}';
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
    getRole();
    setinitialsdata();
  }
  Future<void> getRole() async {
    var runtimeType;
    final User useruid = await _auth.currentUser;
    firestoreInstance.collection("users").doc(useruid.uid).get().then((value) {
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
    });

    notifyListeners();
  }

  Future<void> setinitialsdata() async {
    if (wholelist[11][accessname].containsKey('isSave')) {
    } else {
      wholelist[11][accessname]["isSave"] = true;
    }
    if (wholelist[11][accessname].containsKey('isSaveThera')) {
    } else {
      wholelist[11][accessname]["isSaveThera"] = false;
    }

    if (wholelist[11][accessname].containsKey('videos')) {
      if (wholelist[11][accessname]['videos'].containsKey('name')) {
      } else {
        wholelist[11][accessname]['videos']['name'] = "";
      }
      if (wholelist[11][accessname]['videos'].containsKey('url')) {
      } else {
        wholelist[11][accessname]['videos']['url'] = "";
      }
    } else {
      // print('Yes,it is');

      wholelist[11][accessname]["videos"] = {'name': '', 'url': ''};
    }

    if (wholelist[11][accessname]['question']["1"].containsKey('toggle1')) {
      if (wholelist[11][accessname]['question']["1"]['aboveGround']
                  ['adaptationAvailable']
              .length ==
          0) {
        wholelist[11][accessname]['question']["1"]['aboveGround']
            ['adaptationAvailable'] = 'Yes';
      }
      notifyListeners();
    } else {
      wholelist[11][accessname]['question']["1"]
          ['toggle1'] = <bool>[true, false];
      if (wholelist[11][accessname]['question']["1"]['aboveGround']
                  ['adaptationAvailable']
              .length ==
          0) {
        wholelist[11][accessname]['question']["1"]['aboveGround']
            ['adaptationAvailable'] = 'Yes';
      }
      notifyListeners();
    }
    if (wholelist[11][accessname]['question']["1"].containsKey('toggle2')) {
      if (wholelist[11][accessname]['question']["1"]['aboveGround']
                  ['isClientSafe']
              .length ==
          0) {
        wholelist[11][accessname]['question']["1"]['aboveGround']
            ['isClientSafe'] = 'Yes';
      }
      notifyListeners();
    } else {
      wholelist[11][accessname]['question']["1"]
          ['toggle2'] = <bool>[true, false];
      if (wholelist[11][accessname]['question']["1"]['aboveGround']
                  ['isClientSafe']
              .length ==
          0) {
        wholelist[11][accessname]['question']["1"]['aboveGround']
            ['isClientSafe'] = 'Yes';
      }
      notifyListeners();
    }

    if (wholelist[11][accessname]['question']["1"].containsKey('aboveGround')) {
    } else {
      wholelist[11][accessname]['question']["1"]['aboveGround'] = {
        'adaptationAvailable': "",
        'explain': "",
        'isClientSafe': ""
      };
      notifyListeners();
    }

    if (wholelist[11][accessname]['question']["1"].containsKey('inGround')) {
    } else {
      wholelist[11][accessname]['question']["1"]
          ['inGround'] = {'adaptationAvailable': "", 'isClientSafe': ""};
      notifyListeners();
    }

    if (wholelist[11][accessname]['question']["2"].containsKey('toggle')) {
      if (wholelist[11][accessname]['question']["2"]['Answer'].length == 0) {
        // setdata(2, 'Yes', 'Pool Accessible?');
        wholelist[11][accessname]['question']["2"]['Question'] =
            'Pool Accessible?';
        wholelist[11][accessname]['question']["2"]['Answer'] = 'Yes';
        wholelist[11][accessname]['question']["2"]['toggled'] = false;
      }
      notifyListeners();
    } else {
      wholelist[11][accessname]['question']["2"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[11][accessname]['question']["2"]['Answer'].length == 0) {
        // setdata(2, 'Yes', 'Pool Accessible?');
        wholelist[11][accessname]['question']["2"]['Question'] =
            'Pool Accessible?';
        wholelist[11][accessname]['question']["2"]['Answer'] = 'Yes';
        wholelist[11][accessname]['question']["2"]['toggled'] = false;
      }
      notifyListeners();
    }
    if (wholelist[11][accessname]['question']["4"].containsKey('toggle')) {
      if (wholelist[11][accessname]['question']["4"]['Answer'].length == 0) {
        // setdata(4, 'Yes', 'Pool Deck Clutter?');
        wholelist[11][accessname]['question']["4"]['Question'] =
            'Pool Deck Clutter?';
        wholelist[11][accessname]['question']["4"]['Answer'] = 'Yes';
        wholelist[11][accessname]['question']["4"]['toggled'] = false;
      }
      notifyListeners();
    } else {
      wholelist[11][accessname]['question']["4"]
          ['toggle'] = <bool>[true, false];
      if (wholelist[11][accessname]['question']["4"]['Answer'].length == 0) {
        // setdata(4, 'Yes', 'Pool Deck Clutter?');
        wholelist[11][accessname]['question']["4"]['Question'] =
            'Pool Deck Clutter?';
        wholelist[11][accessname]['question']["4"]['Answer'] = 'Yes';
        wholelist[11][accessname]['question']["4"]['toggled'] = false;
      }
      notifyListeners();
    }
  }

  Future<void> addVideo(String path) {
    video = File(path);
    videoName = basename(video.path);
    isVideoSelected = true;
    notifyListeners();
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

  Future<void> addImage(String path) {
    image = File(path);
    imageName = basename(image.path);
    isImageSelected = true;
    notifyListeners();
  }

  void deleteImage() {
    image = null;
    imageName = '';
    isImageSelected = false;
    notifyListeners();
  }

  void addMedia(String url) {
    if (mediaList.length < 3) {
      mediaList.add(url);
      notifyListeners();
    }
  }

  void deleteMedia(int index) {
    mediaList.removeAt(index);
    notifyListeners();
  }

  Future<String> uploadImage(image) async {
    try {
      String name = 'applicationImages/' + DateTime.now().toIso8601String();
      final ref = FirebaseStorage.instance.ref().child(name);
      ref.putFile(image);
      String url = (await ref.getDownloadURL()).toString();
      imageDownloadUrl = url;
      print(imageDownloadUrl);
      return imageDownloadUrl;
    } catch (e) {
      print(e.toString());
    }
  }

  Future uploadFile(List<File> image) async {
    try {
      for (var img in image) {
        print("***********this is the line of error************");
        String url = await uploadImage(img);
        mediaList.add(url);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future deleteFile(String imagePath, context) async {
    String imagePath1 = 'asssessmentImages/' + imagePath;
    try {
      // FirebaseStorage.instance
      //     .ref()
      //     .child(imagePath1)
      //     .delete()
      //     .then((_) => print('Successfully deleted $imagePath storage item'));
      Reference ref = await FirebaseStorage.instance.refFromURL(imagePath);
      ref.delete();

      // FirebaseStorage firebaseStorege = FirebaseStorage.instance;
      // StorageReference storageReference = firebaseStorege.getReferenceFromUrl(imagePath);

      print('deleteFile(): file deleted');
      // return url;
    } catch (e) {
      print('  deleteFile(): error: ${e.toString()}');
      throw (e.toString());
    }
  }

  setdataToggle(index, String value, que) {
    wholelist[11][accessname]['question']["$index"]['Question'] = que;
    if (value.length == 0) {
      if (wholelist[11][accessname]['question']["$index"]['toggled']) {
      } else {
        wholelist[11][accessname]['complete'] -= 1;
        wholelist[11][accessname]['question']["$index"]['Answer'] = value;
        notifyListeners();
      }
    } else {
      if (wholelist[11][accessname]['question']["$index"]['toggled'] == false) {
        wholelist[11][accessname]['complete'] += 1;
        wholelist[11][accessname]['question']["$index"]['toggled'] = true;
        notifyListeners();
      }

      wholelist[11][accessname]['question']["$index"]['Answer'] = value;
      notifyListeners();
    }
  }

  setdata(index, String value, que) {
    wholelist[11][accessname]['question']["$index"]['Question'] = que;
    if (value.length == 0) {
      if (wholelist[11][accessname]['question']["$index"]['Answer'].length ==
          0) {
      } else {
        wholelist[11][accessname]['complete'] -= 1;
        wholelist[11][accessname]['question']["$index"]['Answer'] = value;
        notifyListeners();
      }
    } else {
      if (wholelist[11][accessname]['question']["$index"]['Answer'].length ==
          0) {
        wholelist[11][accessname]['complete'] += 1;
        notifyListeners();
      }

      wholelist[11][accessname]['question']["$index"]['Answer'] = value;
      notifyListeners();
    }
  }

  setreco(index, value) {
    wholelist[11][accessname]['question']["$index"]['Recommendation'] = value;
    notifyListeners();
  }

  getvalue(index) {
    return wholelist[11][accessname]['question']["$index"]['Answer'];
  }

  getreco(index) {
    return wholelist[11][accessname]['question']["$index"]['Recommendation'];
  }

  setprio(index, value) {
    wholelist[11][accessname]['question']["$index"]['Priority'] = value;
    notifyListeners();
  }

  getprio(index) {
    return wholelist[11][accessname]['question']["$index"]['Priority'];
  }

  setrecothera(index, value) {
    wholelist[11][accessname]['question']["$index"]['Recommendationthera'] =
        value;
    notifyListeners();
  }

  getrecothera(index) {
    return wholelist[11][accessname]['question']["$index"]
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
        wholelist[3][accessname]["isSaveThera"] = saveToForm;
      } else {
        saveToForm = false;
        falseIndex = index;
        wholelist[3][accessname]["isSaveThera"] = saveToForm;
      }
    } else {
      if (index == falseIndex) {
        if (wholelist[3][accessname]["question"]["$index"]
                ["Recommendationthera"] !=
            "") {
          wholelist[3][accessname]["isSaveThera"] = true;
          falseIndex = -1;
        } else {
          wholelist[3][accessname]["isSaveThera"] = false;
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
  }

  setdatalisten(index) {
    wholelist[3][accessname]['question']["$index"]['Recommendation'] =
        controllers["field$index"].text;
    cur = !cur;
    notifyListeners();
  }
}
