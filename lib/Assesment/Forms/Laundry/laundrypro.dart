import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Formsrepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avatar_glow/avatar_glow.dart';

///Frame of this page:
///       contructor function:
///         1) this function helps to generate fields which are not needed previously
///            but will be needed to fill future fields
///
///       function which help to set and get data from the field and maps.
///             a)the set function requires value and index to work
///             b)the get fucntion requires only index of the question to get the
///               data.
///
///       fucntion which helps to control speech to text.
class LaundryPro extends ChangeNotifier {
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
  Map<String, TextEditingController> controllers = {};
  Map<String, TextEditingController> controllerstreco = {};
  Map<String, bool> isListening = {};
  bool cur = true;
  String type;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  var test = TextEditingController();
  final FormsRepository formsRepository = FormsRepository();
  final FirebaseAuth auth = FirebaseAuth.instance;

  LaundryPro(this.roomname, this.wholelist, this.accessname) {
    _speech = stt.SpeechToText();
    for (int i = 0; i < wholelist[7][accessname]['question'].length; i++) {
      controllers["field${i + 1}"] = TextEditingController();
      controllerstreco["field${i + 1}"] = TextEditingController();
      isListening["field${i + 1}"] = false;
      controllers["field${i + 1}"].text =
          wholelist[7][accessname]['question']["${i + 1}"]['Recommendation'];
      controllerstreco["field${i + 1}"].text =
          '${wholelist[7][accessname]['question']["${i + 1}"]['Recommendationthera']}';
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
    getRole();
    setinitials();
    doorwidth = int.tryParse('$getvalue(7)');
  }

  /// This fucntion helps us to create such fields which will be needed to fill extra
  /// data sunch as fields generated dynamically.
  Future<void> setinitials() async {
    if (wholelist[7][accessname]['question']["7"].containsKey('doorwidth')) {
    } else {
      print('getting created');
      wholelist[7][accessname]['question']["7"]['doorwidth'] = 0;
    }

    if (wholelist[7][accessname]['question']["15"].containsKey('ManageInOut')) {
    } else {
      wholelist[7][accessname]['question']["15"]['ManageInOut'] = '';
    }

    if (wholelist[7][accessname]['question']["16"].containsKey('Grabbar')) {
    } else {
      wholelist[7][accessname]['question']["16"]['Grabbar'] = {};
    }

    if (wholelist[7][accessname]['question']["17"]
        .containsKey('sidefentrance')) {
    } else {
      wholelist[7][accessname]['question']["17"]['sidefentrance'] = '';
    }
  }

  /// This fucntion will help us to get role of the logged in user

  Future<String> getRole() async {
    final FirebaseUser useruid = await _auth.currentUser();
    firestoreInstance.collection("users").document(useruid.uid).get().then(
      (value) {
        type = (value["role"].toString()).split(" ")[0];
        notifyListeners();
      },
    );
  }

  ///This function is used to set data i.e to take data from thr field and feed it in
// map.
  setdata(index, value, que) {
    if (value.length == 0) {
      if (wholelist[7][accessname]['question']["$index"]['Answer'].length ==
          0) {
      } else {
        wholelist[7][accessname]['complete'] -= 1;
        wholelist[7][accessname]['question']["$index"]['Answer'] = value;
        wholelist[7][accessname]['question']["$index"]['Question'] = que;
        notifyListeners();
      }
    } else {
      if (wholelist[7][accessname]['question']["$index"]['Answer'].length ==
          0) {
        wholelist[7][accessname]['complete'] += 1;
        notifyListeners();
      }
      wholelist[7][accessname]['question']["$index"]['Answer'] = value;
      notifyListeners();
    }
  }

  /// This function helps us to set the recommendation
  setreco(index, value) {
    wholelist[7][accessname]['question']["$index"]['Recommendation'] = value;
    notifyListeners();
  }

  /// This function helps us to get value form the map
  getvalue(index) {
    return wholelist[7][accessname]['question']["$index"]['Answer'];
  }

  /// This function helps us to get recommendation value form the map

  getreco(index) {
    return wholelist[7][accessname]['question']["$index"]['Recommendation'];
  }

  setrecothera(index, value) {
    wholelist[7][accessname]['question']["$index"]['Recommendationthera'] =
        value;
    notifyListeners();
  }
// This fucntion helps us to set the priority of the fields.

  setprio(index, value) {
    wholelist[7][accessname]['question']["$index"]['Priority'] = value;
    notifyListeners();
  }

// This fucntion helps us to get the priority of the fields.
  getprio(index) {
    return wholelist[7][accessname]['question']["$index"]['Priority'];
  }

  getrecothera(index) {
    return wholelist[7][accessname]['question']["$index"]
        ['Recommendationthera'];
  }

  // This fucntion helps us to set the recommendation from the therapist.
  Widget getrecomain(
      assesmentprovider, int index, bool isthera, String fieldlabel) {
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
                                listen(index);
                                setdatalisten(index);
                              },
                            ),
                          ),
                        ),
                      ]),
                    ),
                    labelText: fieldlabel),
                onChanged: (value) {
                  // print(accessname);
                  assesmentprovider.setreco(index, value);
                },
              ),
            ),
            (assesmentprovider.type == 'therapist' && isthera)
                ? getrecowid(assesmentprovider, index)
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget getrecowid(assesmentprovider, index) {
    return Column(
      children: [
        SizedBox(height: 8),
        TextFormField(
          controller: controllerstreco["field$index"],
          decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromRGBO(10, 80, 106, 1), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1),
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
            controllerstreco["field$index"].text = wholelist[7][accessname]
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
    wholelist[7][accessname]['question']["$index"]['Recommendationthera'] =
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
          controllers["field$index"].text = wholelist[7][accessname]['question']
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
    wholelist[7][accessname]['question']["$index"]['Recommendation'] =
        controllers["field$index"].text;
    cur = !cur;
    notifyListeners();
  }
}
