import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:tryapp/Assesment/Forms/Pathway/pathwaypro.dart';
import 'package:provider/provider.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentrepo.dart';
import 'package:tryapp/constants.dart';
import 'package:path/path.dart';

import '../ViewVideo.dart';

///Frame of this page:
///       init function:
///         1) this function helps to generate fields which are not needed previously
///            but will be needed to fill future fields
///
///       function which help to set and get data from the field and maps.
///             a)the set function requires value and index to work
///             b)the get fucntion requires only index of the question to get the
///               data.
///       UI for the whole page.

final _colorgreen = Color.fromRGBO(10, 80, 106, 1);

class PathwayUI extends StatefulWidget {
  String roomname, docID;

  var accessname;
  List<Map<String, dynamic>> wholelist;
  PathwayUI(this.roomname, this.wholelist, this.accessname, this.docID);
  @override
  _PathwayUIState createState() => _PathwayUIState();
}

class _PathwayUIState extends State<PathwayUI> {
  stt.SpeechToText _speech;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool available = false, saveToForm = false;
  int threeshold = 0;
  Map<String, Color> colorsset = {};
  Map<String, TextEditingController> _controllers = {};
  Map<String, TextEditingController> _controllerstreco = {};
  final firestoreInstance = FirebaseFirestore.instance;
  Map<String, bool> isListening = {};
  bool cur = true;
  bool curThera = true;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  var _textfield = TextEditingController();
  String role, assessor, curUid, therapist;
  int sizes = 30;
  int stepsizes = 0;
  int stepcount = 0;
  bool isColor = false;
  var test = TextEditingController();
  String imageDownloadUrl;
  var _mediaList = <String>[];
  List<File> _image = [];
  CollectionReference imgRef;
  List<dynamic> mediaList = [];
  bool uploading = false;
  double value = 0;
  List<String> path = [];
  String videoDownloadUrl, videoUrl, videoName;
  File video;
  var falseIndex = -1, trueIndex = -1;
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;

  String transcription = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _textfield.text = widget.wholelist[0][widget.accessname]['question']["1"]
        ['Recommendation'];
    for (int i = 0;
        i < widget.wholelist[0][widget.accessname]['question'].length;
        i++) {
      _controllers["field${i + 1}"] = TextEditingController();
      _controllerstreco["field${i + 1}"] = TextEditingController(
          text: getprio(6) == '1'
              ? 'Please install a well functioning Smoke detector Immediately. Most states have free Smoke Detectors available for FREE. Please contact your local Fire Department'
              : 'Recommendation');
      isListening["field${i + 1}"] = false;
      _controllers["field${i + 1}"].text = widget.wholelist[0]
          [widget.accessname]['question']["${i + 1}"]['Recommendation'];
      _controllerstreco["field${i + 1}"].text =
          '${widget.wholelist[0][widget.accessname]['question']["${i + 1}"]['Recommendationthera']}';
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
    // setinitials();
    getRole();
    getAssessData();
    // activateSpeechRecognizer();
  }

  // void activateSpeechRecognizer() {
  //   print('_MyAppState.activateSpeechRecognizer... ');
  //   _speechRecognition = new SpeechRecognition();
  //   _speechRecognition.setAvailabilityHandler(onSpeechAvailability);
  //   // _speechRecognition.setCurrentLocaleHandler(onCurrentLocale);
  //   _speechRecognition.setRecognitionStartedHandler(onRecognitionStarted);
  //   _speechRecognition.setRecognitionResultHandler(onRecognitionResult);
  //   _speechRecognition.setRecognitionCompleteHandler(onRecognitionComplete);
  //   _speechRecognition
  //       .activate()
  //       .then((res) => setState(() => _speechRecognitionAvailable = res));
  // }

  // void start(index, isthera) {
  //   print("starterd");
  //   _speechRecognition
  //       .listen()
  //       .then((result) => print('_MyAppState.start => result $result'));
  // }

  // void cancel(index) => _speechRecognition
  //     .cancel()
  //     .then((result) => setState(() => _isListening = result));

  // void stop(index) => _speechRecognition
  //     .stop()
  //     .then((result) => setState(() => _isListening = result));

  // void onSpeechAvailability(bool result) =>
  //     setState(() => _speechRecognitionAvailable = result);

  // void onCurrentLocale(String locale) {
  //   print('_MyAppState.onCurrentLocale... $locale');
  //   setState(
  //       () => selectedLang = languages.firstWhere((l) => l.code == locale));
  // }

  void onRecognitionStarted() => setState(() => _isListening = true);

  void onRecognitionResult(text) => setState(() => transcription = text);

  void onRecognitionComplete() => setState(() => _isListening = false);

  /// This fucntion will help us to get role of the logged in user
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
              setState(() {
                role = "therapist";
              });
            }
          }
        } else {
          setState(() {
            role = value.data()["role"];
          });
        }
      },
    );
  }

  Future<void> getAssessData() async {
    final User user = await _auth.currentUser;
    firestoreInstance
        .collection("assessments")
        .doc(widget.docID)
        .get()
        .then((value) => setState(() {
              curUid = user.uid;
              assessor = value["assessor"];
              therapist = value["therapist"];
              videoUrl = widget.wholelist[0][widget.accessname]["videos"]["url"]
                      .toString() ??
                  "";
              videoName = widget.wholelist[0][widget.accessname]["videos"]
                          ["name"]
                      .toString() ??
                  "";
            }));
  }

// This function is used to set data i.e to take data from thr field and feed it in
// map.
  setdata(index, value, que) {
    widget.wholelist[0][widget.accessname]['question']["$index"]['Question'] =
        que;
    if (value.length == 0) {
      if (widget.wholelist[0][widget.accessname]['question']["$index"]['Answer']
              .length ==
          0) {
      } else {
        setState(() {
          widget.wholelist[0][widget.accessname]['complete'] -= 1;
          widget.wholelist[0][widget.accessname]['question']["$index"]
              ['Answer'] = value;
          widget.wholelist[0][widget.accessname]['question']["$index"]
              ['Question'] = que;
        });
      }
    } else {
      if (widget.wholelist[0][widget.accessname]['question']["$index"]['Answer']
              .length ==
          0) {
        setState(() {
          widget.wholelist[0][widget.accessname]['complete'] += 1;
        });
      }
      setState(() {
        widget.wholelist[0][widget.accessname]['question']["$index"]['Answer'] =
            value;
      });
    }
  }

  /// This function helps us to set the recommendation
  setreco(index, value) {
    setState(() {
      widget.wholelist[0][widget.accessname]['question']["$index"]
          ['Recommendation'] = value;
    });
  }

  /// This function helps us to get value form the map
  getvalue(index) {
    return widget.wholelist[0][widget.accessname]['question']["$index"]
        ['Answer'];
  }

  /// This function helps us to get recommendation value form the map
  getreco(index) {
    return widget.wholelist[0][widget.accessname]['question']["$index"]
        ['Recommendation'];
  }

// This fucntion helps us to set the priority of the fields.
  setprio(index, value) {
    setState(() {
      widget.wholelist[0][widget.accessname]['question']["$index"]['Priority'] =
          value;
    });
  }

// This fucntion helps us to get the priority of the fields.
  getprio(index) {
    return widget.wholelist[0][widget.accessname]['question']["$index"]
        ['Priority'];
  }

// This fucntion helps us to set the recommendation from the therapist.
  setrecothera(index, value) {
    setState(() {
      widget.wholelist[0][widget.accessname]['question']["$index"]
          ['Recommendationthera'] = value;
    });
  }

  // void initSpeechRecognizer(index) {
  //   _speechRecognition = SpeechRecognition();

  //   _speechRecognition.setAvailabilityHandler(
  //     (bool result) => setState(() => available = result),
  //   );

  //   _speechRecognition.setRecognitionStartedHandler(
  //     () => setState(() => isListening["field$index"] = true),
  //   );

  //   _speechRecognition.setRecognitionResultHandler(
  //     (String speech) => setState(() => widget.wholelist[0][widget.accessname]
  //         ['question']["$index"]['Recommendationthera'] = speech),
  //   );

  //   _speechRecognition.setRecognitionCompleteHandler(
  //     () => setState(() => isListening["field$index"] = false),
  //   );

  //   _speechRecognition.activate().then(
  //         (result) => setState(() => available = result),
  //       );
  // }

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

  Widget toggleButton(
      BuildContext context, PathwayPro pathwaypro, int queIndex, String que) {
    return Container(
      height: 35,
      child: ToggleButtons(
        borderColor: Colors.black,
        fillColor: Colors.green,
        borderWidth: 0,
        selectedBorderColor: Colors.black,
        selectedColor: Colors.white,
        borderRadius: BorderRadius.circular(20),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Yes',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'No',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
        onPressed: (int select) {
          if (assessor == therapist && role == "therapist") {
            setState(() {
              for (int i = 0;
                  i <
                      widget
                          .wholelist[0][widget.accessname]['question']
                              ['$queIndex']['toggle']
                          .length;
                  i++) {
                widget.wholelist[0][widget.accessname]['question']['$queIndex']
                    ['toggle'][i] = i == select;
              }
            });
            pathwaypro.setdata(
                queIndex,
                widget.wholelist[0][widget.accessname]['question']['$queIndex']
                        ['toggle'][0]
                    ? 'Yes'
                    : 'No',
                que);
          } else if (role != "therapist") {
            setState(() {
              for (int i = 0;
                  i <
                      widget
                          .wholelist[0][widget.accessname]['question']
                              ['$queIndex']['toggle']
                          .length;
                  i++) {
                widget.wholelist[0][widget.accessname]['question']['$queIndex']
                    ['toggle'][i] = i == select;
              }
            });
            pathwaypro.setdata(
                queIndex,
                widget.wholelist[0][widget.accessname]['question']['$queIndex']
                        ['toggle'][0]
                    ? 'Yes'
                    : 'No',
                que);
          } else {
            _showSnackBar("You can't change the other fields", context);
          }
        },
        isSelected: widget.wholelist[0][widget.accessname]['question']
                ['$queIndex']['toggle']
            .cast<bool>(),
      ),
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    final pathwaypro = Provider.of<PathwayPro>(context);

    Future<void> upload(File videos) async {
      setState(() {
        uploading = true;
      });
      try {
        print("*************Uploading Video************");
        String name = 'applicationVideos/' + DateTime.now().toIso8601String();
        Reference ref = FirebaseStorage.instance.ref().child(name);

        UploadTask upload = ref.putFile(videos);
        String url = (await (await upload).ref.getDownloadURL()).toString();
        setState(() {
          videoUrl = url;
          print("************Url = $videoUrl**********");
          var path = videos.path;
          var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
          var newPath = path.substring(0, lastSeparator + 1) + widget.roomname;
          videos = videos.renameSync(newPath);
          videoName = basename(videos.path);
          print("************Name = $videoName**********");
          widget.wholelist[0][widget.accessname]["videos"]["url"] = videoUrl;
          widget.wholelist[0][widget.accessname]["videos"]["name"] = videoName;
          NewAssesmentRepository().setForm(widget.wholelist, widget.docID);
          uploading = false;
        });
      } catch (e) {
        print(e.toString());
      }
    }

    Future<void> selectVideo(String source) async {
      if (video == null) {
        if (source == 'camera') {
          final pickedVideo =
              await ImagePicker().pickVideo(source: ImageSource.camera);

          if (pickedVideo != null) {
            Navigator.pop(context);
            pathwaypro.addVideo(pickedVideo.path);
            // FocusScope.of(context).requestFocus(new FocusNode());
            setState(() {
              upload(File(pickedVideo?.path));
            });
          } else {
            Navigator.pop(context);
            setState(() {});
            final snackBar = SnackBar(content: Text('Video Not Selected!'));
            pathwaypro.notifyListeners();
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          final pickedVideo =
              await ImagePicker().pickVideo(source: ImageSource.gallery);
          if (pickedVideo != null) {
            Navigator.pop(context);
            pathwaypro.addVideo(pickedVideo.path);
            setState(() {
              upload(File(pickedVideo?.path));
            });
          } else {
            Navigator.pop(context);
            setState(() {});
            final snackBar = SnackBar(content: Text('Video Not Selected!'));
            pathwaypro.notifyListeners();
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        }
      } else {
        final snackBar =
            SnackBar(content: Text('Only One Video Can be Uploaded!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    void uploadVideo(BuildContext context) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              // actionsPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              title: Center(
                  child: Text(
                'Select Video From',
                style: darkBlackTextStyle()
                    .copyWith(fontSize: 18.0, fontWeight: FontWeight.w600),
              )),
              actions: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      // mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 200,
                            height: 80.0,
                            color: Color(0xFFf0f0fa),
                            child: InkWell(
                              onTap: () async {
                                await selectVideo('camera');
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      color: Color.fromRGBO(10, 80, 106, 1),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text('Use Camera')
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 200,
                            height: 80.0,
                            color: Color(0xFFf0f0fa),
                            child: InkWell(
                              onTap: () async {
                                await selectVideo('gallery');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.photo_library_outlined,
                                      color: Color.fromRGBO(10, 80, 106, 1),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text('Upload from Gallery')
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(43, 10, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Note: ",
                              style: darkBlackTextStyle().copyWith(
                                  fontSize: 16.0, fontWeight: FontWeight.w600)),
                          Container(
                            width: MediaQuery.of(context).size.width * .4,
                            child: Text("Touch overlay background to exit."),
                          ),
                        ],
                      ),
                    ),

                    // SizedBox(height: 10),

                    Container(
                      padding: EdgeInsets.fromLTRB(28, 10, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Warning: ",
                              style: darkBlackTextStyle().copyWith(
                                  fontSize: 16.0, fontWeight: FontWeight.w600)),
                          Container(
                            width: MediaQuery.of(context).size.width * .4,
                            child: Text(
                                "You can select only one video so cover all parts of room in one video and make sure you are holding your device vertically."),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            );
          });
    }

    void deleteVideo() {
      setState(() {
        video = null;
        videoName = '';
        videoUrl = '';
      });

      pathwaypro.notifyListeners();
    }

    Future deleteFile(String imagePath) async {
      String imagePath1 = 'asssessmentVideos/' + imagePath;
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

    /// This function is a helper function of the listen fucntion.
    setdatalisten(index) {
      setState(() {
        widget.wholelist[0][widget.accessname]['question']["$index"]
            ['Recommendation'] = _controllers["field$index"].text;
        cur = !cur;
      });
    }

    /// this fucntion helps us to listent to hte done button at the bottom
    void listenbutton(BuildContext context) {
      var test = widget.wholelist[0][widget.accessname]["complete"];
      for (int i = 0;
          i < widget.wholelist[0][widget.accessname]['question'].length;
          i++) {
        // print(colorsset["field${i + 1}"]);
        // if (colorsset["field${i + 1}"] == Colors.red) {
        //   showDialog(
        //       context: context,
        //       builder: (context) => CustomDialog(
        //           title: "Not Saved",
        //           description: "Please click tick button to save the field"));
        //   test = 1;
        // }
        setdatalisten(i + 1);
      }
      // if (test == 0) {
      //   _showSnackBar("You must have to fill at least 1 field first", context);
      // } else {
      if (role == "therapist") {
        // if (saveToForm) {
        NewAssesmentRepository().setLatestChangeDate(widget.docID);
        NewAssesmentRepository().setForm(widget.wholelist, widget.docID);
        Navigator.pop(context, widget.wholelist[0][widget.accessname]);
        // } else {
        //   _showSnackBar("Provide all recommendations", context);
        // }
      } else {
        NewAssesmentRepository().setLatestChangeDate(widget.docID);
        NewAssesmentRepository().setForm(widget.wholelist, widget.docID);
        Navigator.pop(context, widget.wholelist[0][widget.accessname]);
        // Navigator.of(buildContext).pushReplacement(MaterialPageRoute(
        //     builder: (context) =>
        //         CompleteAssessmentBase(widget.wholelist, widget.docID, role)));
      }
      // }
    }

    /// This fucntion is to take care of speech to text mic button and place the text in
    /// the particular field.
    void _listen(index, bool isthera) async {
      if (!isListening['field$index']) {
        bool available = await _speech.initialize(
          onStatus: (val) {
            print('onStatus: $val');
            if (val == 'notListening') {
              setState(() {
                isListening['field$index'] = false;
              });
            }
          },
          onError: (val) => print('onError: $val'),
        );
        if (available) {
          var systemLocale = await _speech.systemLocale();
          setState(() {
            // _isListening = true;
            colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
            isListening['field$index'] = true;
          });
          if (isthera) {
            _speech.listen(
                onResult: (val) => setState(() {
                      _controllerstreco["field$index"].text =
                          widget.wholelist[0][widget.accessname]['question']
                                  ["$index"]['Recommendationthera'] +
                              " " +
                              val.recognizedWords;
                      // if (val.hasConfidenceRating && val.confidence > 0) {
                      //   _confidence = val.confidence;
                      // }
                    }),
                listenFor: Duration(minutes: 1),
                localeId: systemLocale.localeId,
                onSoundLevelChange: null,
                cancelOnError: true,
                partialResults: true);
          } else {
            _speech.listen(
                onResult: (val) => setState(() {
                      _controllers["field$index"].text = widget.wholelist[0]
                                  [widget.accessname]['question']["$index"]
                              ['Recommendation'] +
                          " " +
                          val.recognizedWords;
                      // if (val.hasConfidenceRating && val.confidence > 0) {
                      //   _confidence = val.confidence;
                      // }
                    }),
                listenFor: Duration(milliseconds: 5000),
                localeId: systemLocale.localeId,
                onSoundLevelChange: null,
                cancelOnError: true,
                partialResults: true);
          }
        }
      } else {
        setState(() {
          // _isListening = false;
          isListening['field$index'] = false;
          colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
        });
        _speech.stop();
      }
    }

    ticklisten(index) {
      print('clicked');
      setState(() {
        // _isListening = false;
        isListening['field$index'] = false;
        colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
      });
      _speech.stop();
    }

    setdatalistenThera(index) {
      setState(() {
        widget.wholelist[0][widget.accessname]['question']["$index"]
            ['Recommendationthera'] = _controllerstreco["field$index"].text;
        curThera = !curThera;
      });
    }

    Widget getrecowid(index, BuildContext context) {
      // if (index == 6) {
      //   getprio(index) == '1'
      //       ? widget.wholelist[0][widget.accessname]['question']["$index"]
      //               ['Recommendationthera'] =
      //           'Please install a well functioning Smoke detector Immediately. Most states have free Smoke Detectors available for FREE. Please contact your local Fire Department'
      //       : widget.wholelist[0][widget.accessname]['question']["$index"]
      //           ['Recommendationthera'] = '';
      // }
      if (widget.wholelist[0][widget.accessname]["question"]["$index"]
              ["Recommendationthera"] !=
          "") {
        setState(() {
          isColor = true;
          // saveToForm = true;
          // widget.wholelist[0][widget.accessname]["isSave"] = saveToForm;
        });
      } else {
        setState(() {
          isColor = false;
          // saveToForm = false;
          // widget.wholelist[0][widget.accessname]["isSave"] = saveToForm;
        });
      }
      if (falseIndex == -1) {
        if (widget.wholelist[0][widget.accessname]["question"]["$index"]
                ["Recommendationthera"] !=
            "") {
          setState(() {
            saveToForm = true;
            trueIndex = index;
            widget.wholelist[0][widget.accessname]["isSave"] = saveToForm;
          });
        } else {
          setState(() {
            saveToForm = false;
            falseIndex = index;
            widget.wholelist[0][widget.accessname]["isSave"] = saveToForm;
          });
        }
      } else {
        if (index == falseIndex) {
          if (widget.wholelist[0][widget.accessname]["question"]["$index"]
                  ["Recommendationthera"] !=
              "") {
            setState(() {
              widget.wholelist[0][widget.accessname]["isSave"] = true;
              falseIndex = -1;
            });
          } else {
            setState(() {
              widget.wholelist[0][widget.accessname]["isSave"] = false;
            });
          }
        }
      }

      return Column(
        children: [
          SizedBox(height: 8),
          TextFormField(
            onChanged: (value) {
              FocusScope.of(context).requestFocus();
              new TextEditingController().clear();
              // print(widget.accessname);
              setrecothera(index, value);
            },
            controller: _controllerstreco["field$index"],
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
                    child: AvatarGlow(
                      animate: isListening['field$index'],
                      glowColor: Theme.of(context).primaryColor,
                      endRadius: 500.0,
                      duration: const Duration(milliseconds: 2000),
                      repeatPauseDuration: const Duration(milliseconds: 100),
                      repeat: true,
                      child: FloatingActionButton(
                        heroTag: "btn${index + 100}",
                        child: Icon(
                          Icons.mic,
                          size: 20,
                        ),
                        onPressed: () {
                          _listen(index, true);
                          setdatalistenThera(index);
                        },
                      ),
                    ),
                  ),
                ]),
              ),
              labelStyle:
                  TextStyle(color: (isColor) ? Colors.green : Colors.red),
              labelText: 'Recommendation',
            ),
            // initialValue: (index == 6)
            // ? getprio(index) == '1'
            //     ? 'Please install a well functioning Smoke detector Immediately. Most states have free Smoke Detectors available for FREE. Please contact your local Fire Department'
            //     : ''
            // : ""
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
                      setprio(index, value);
                      if (index == 6) {
                        setState(() {
                          _controllerstreco['field6'].text =
                              'Please install a well functioning Smoke detector Immediately. Most states have free Smoke Detectors available for FREE. Please contact your local Fire Department';
                          setrecothera(6,
                              'Please install a well functioning Smoke detector Immediately. Most states have free Smoke Detectors available for FREE. Please contact your local Fire Department');
                        });
                      }
                    },
                    groupValue: getprio(index),
                  ),
                  Text('1'),
                  Radio(
                    value: '2',
                    onChanged: (value) {
                      setState(() {
                        setprio(index, value);
                        if (index == 6) {
                          _controllerstreco['field6'].text = '';
                          setrecothera(6, _controllerstreco['field6'].text);
                        }
                      });
                    },
                    groupValue: getprio(index),
                  ),
                  Text('2'),
                  Radio(
                    value: '3',
                    onChanged: (value) {
                      setState(() {
                        setprio(index, value);
                        if (index == 6) {
                          _controllerstreco['field6'].text = '';
                          setrecothera(6, _controllerstreco['field6'].text);
                        }
                      });
                    },
                    groupValue: getprio(index),
                  ),
                  Text('3'),
                ],
              )
            ],
          )
        ],
      );
    }

    /// This is a widget function which returns is the recommendation fields and the
    /// priority field.
    Widget getrecomain(int index, bool isthera, BuildContext context) {
      return SingleChildScrollView(
        // reverse: true,
        child: Container(
          // color: Colors.yellow,
          child: Column(
            children: [
              // Container(
              //   child: TextFormField(
              //     maxLines: 1,
              //     showCursor: cur,
              //     controller: _controllers["field$index"],
              //     decoration: InputDecoration(
              //         focusedBorder: OutlineInputBorder(
              //           borderSide: BorderSide(
              //               color: colorsset["field$index"], width: 1),
              //         ),
              //         enabledBorder: OutlineInputBorder(
              //           borderSide: BorderSide(
              //               width: 1, color: colorsset["field$index"]),
              //         ),
              //         suffix: Container(
              //           // color: Colors.red,
              //           width: 40,
              //           height: 30,
              //           padding: EdgeInsets.all(0),
              //           child: Row(children: [
              //             Container(
              //               // color: Colors.green,
              //               alignment: Alignment.center,
              //               width: 40,
              //               height: 60,
              //               margin: EdgeInsets.all(0),
              //               child: AvatarGlow(
              //                 animate: isListening['field$index'],
              //                 glowColor: Theme.of(context).primaryColor,
              //                 endRadius: 35.0,
              //                 duration: const Duration(milliseconds: 2000),
              //                 repeatPauseDuration:
              //                     const Duration(milliseconds: 100),
              //                 repeat: true,
              //                 child: FloatingActionButton(
              //                   heroTag: "btn${index + 100}",
              //                   child: Icon(
              //                     Icons.mic,
              //                     size: 20,
              //                   ),
              //                   onPressed: () {
              //                     if (assessor == therapist &&
              //                         role == "therapist") {
              //                       _listen(index, false);
              //                       setdatalisten(index);
              //                     } else if (role != "therapist") {
              //                       _listen(index, false);
              //                       setdatalisten(index);
              //                     } else {
              //                       _showSnackBar(
              //                           "You can't change the other fields",
              //                           context);
              //                     }
              //                   },
              //                 ),
              //               ),
              //             ),
              //           ]),
              //         ),
              //         labelText: 'Comments'
              //         ),
              //     onChanged: (value) {
              // if (assessor == therapist && role == "therapist") {
              //   FocusScope.of(context).requestFocus();
              //   new TextEditingController().clear();
              //   // print(widget.accessname);
              //   setreco(index, value);
              // } else if (role != "therapist") {
              //   FocusScope.of(context).requestFocus();
              //   new TextEditingController().clear();
              //   // print(widget.accessname);
              //   setreco(index, value);
              // } else {
              //   _showSnackBar(
              //       "You can't change the other fields", context);
              // }
              //     },
              //   ),
              // ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 8, 8, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        // initialValue: getvalue(14),
                        maxLines: 1,
                        showCursor: cur,
                        controller: _controllers["field$index"],
                        decoration: InputDecoration(
                            border: InputBorder.none, labelText: 'comment'),

                        onChanged: (value) {
                          if (assessor == therapist && role == "therapist") {
                            FocusScope.of(context).requestFocus();
                            new TextEditingController().clear();
                            // print(widget.accessname);
                            setreco(index, value);
                          } else if (role != "therapist") {
                            FocusScope.of(context).requestFocus();
                            new TextEditingController().clear();
                            // print(widget.accessname);
                            setreco(index, value);
                          } else {
                            _showSnackBar(
                                "You can't change the other fields", context);
                          }
                        },
                      ),
                    ),
                    AvatarGlow(
                      animate: isListening["field$index"],
                      glowColor: Theme.of(context).primaryColor,
                      endRadius: 35.0,
                      duration: const Duration(milliseconds: 2000),
                      repeatPauseDuration: const Duration(milliseconds: 100),
                      repeat: true,
                      child: Container(
                        width: 40,
                        height: 30,
                        padding: EdgeInsets.all(0),
                        alignment: Alignment.center,
                        margin: EdgeInsets.all(0),
                        child: FloatingActionButton(
                          heroTag: "btn${index + 100}",
                          child: Icon(
                            Icons.mic,
                            size: 20,
                          ),
                          onPressed: () {
                            if (assessor == therapist && role == "therapist") {
                              _listen(index, false);
                              setdatalisten(index);
                              Timer(Duration(seconds: 3), () {
                                ticklisten(index);
                              });
                            } else if (role != "therapist") {
                              _listen(index, false);
                              setdatalisten(index);
                              Timer(Duration(seconds: 3), () {
                                ticklisten(index);
                              });
                            } else {
                              _showSnackBar(
                                  "You can't change the other fields", context);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorsset["field$index"],
                    width: 1,
                  ), //Border.all
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              (role == 'therapist' && isthera)
                  ? getrecowid(index, context)
                  : SizedBox(),
            ],
          ),
        ),
      );
    }

    /// This function is specific for the pathwayui. this is used to generate the
    /// steps field based on dynamic and multiple stairs to store data of each stair
    Widget stepcountswid(index, BuildContext context) {
      return Container(
        child: Column(
          children: [
            Container(
              // padding: EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(child: Text('$index:')),
                  Container(
                    width: MediaQuery.of(context).size.width * .35,
                    child: TextFormField(
                      initialValue: widget.wholelist[0][widget.accessname]
                              ['question']["7"]['MultipleStair']['step$index']
                          ['stepwidth'],
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: colorsset["field${7}"], width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1, color: colorsset["field${7}"]),
                          ),
                          labelText: 'Step Width$index (Inches)'),
                      onChanged: (value) {
                        if (assessor == therapist && role == "therapist") {
                          setState(() {
                            widget.wholelist[0][widget.accessname]['question']
                                    ["7"]['MultipleStair']['step$index']
                                ['stepwidth'] = value;
                          });
                        } else if (role != "therapist") {
                          setState(() {
                            widget.wholelist[0][widget.accessname]['question']
                                    ["7"]['MultipleStair']['step$index']
                                ['stepwidth'] = value;
                          });
                        } else {
                          _showSnackBar(
                              "You can't change the other fields", context);
                        }

                        // print(widget.wholelist[0][widget.accessname]['question']
                        //     [7]);
                      },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .35,
                    child: TextFormField(
                      initialValue: widget.wholelist[0][widget.accessname]
                              ['question']["7"]['MultipleStair']['step$index']
                          ['stepheight'],
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: colorsset["field${7}"], width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1, color: colorsset["field${7}"]),
                          ),
                          labelText: 'Step Height$index (Inches)'),
                      onChanged: (value) {
                        if (assessor == therapist && role == "therapist") {
                          setState(() {
                            widget.wholelist[0][widget.accessname]['question']
                                    ["7"]['MultipleStair']['step$index']
                                ['stepheight'] = value;
                          });
                        } else if (role != "therapist") {
                          setState(() {
                            widget.wholelist[0][widget.accessname]['question']
                                    ["7"]['MultipleStair']['step$index']
                                ['stepheight'] = value;
                          });
                        } else {
                          _showSnackBar(
                              "You can't change the other fields", context);
                        }

                        // print(widget.wholelist[0][widget.accessname]['question']
                        //     [7]);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 7)
          ],
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: (widget.roomname != null)
              ? Text("${widget.roomname}")
              : Text('Pathway'),
          automaticallyImplyLeading: false,
          backgroundColor: _colorgreen,
          actions: [
            IconButton(
              icon: Icon(Icons.done_all, color: Colors.white),
              onPressed: () async {
                try {
                  listenbutton(context);
                } catch (e) {
                  print(e.toString());
                }
              },
            )
          ],
        ),
        body: Container(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Container(
                  //   width: double.infinity,
                  //   child: Card(
                  //     elevation: 8,
                  //     child: Container(
                  //       padding: EdgeInsets.all(25),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Container(
                  //               width: MediaQuery.of(context).size.width / 1.6,
                  //               child: Text(
                  //                 '${widget.roomname}Details',
                  //                 style: TextStyle(
                  //                   fontSize: 25,
                  //                   fontWeight: FontWeight.bold,
                  //                   color: Color.fromRGBO(10, 80, 106, 1),
                  //                 ),
                  //               )),
                  //           Container(
                  //             alignment: Alignment.topRight,
                  //             width: 50,
                  //             decoration: BoxDecoration(
                  //                 color: _colorgreen,
                  //                 // border: Border.all(
                  //                 //   color: Colors.red[500],
                  //                 // ),
                  //                 borderRadius:
                  //                     BorderRadius.all(Radius.circular(50))),
                  //             // color: Colors.red,
                  //             child: RawMaterialButton(
                  //               onPressed: () {
                  //                 if (videoUrl == "" && videoName == "") {
                  //                   if (curUid == assessor) {
                  //                     uploadVideo(context);
                  //                   } else {
                  //                     _showSnackBar(
                  //                         "You are not allowed to upload video",
                  //                         context);
                  //                   }
                  //                 } else {
                  //                   _showSnackBar(
                  //                       "You can add only one video", context);
                  //                 }
                  //               },
                  //               child: Icon(
                  //                 Icons.camera_alt,
                  //                 color: Colors.white,
                  //               ),
                  //             ),
                  //           )
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Container(
                    padding: EdgeInsets.fromLTRB(15, 10, 10, 0),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "If you want to upload a video",
                            style: TextStyle(fontSize: 18),
                          ),
                          FlatButton(
                            child: Text(
                              'Click Here',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  color: Color.fromRGBO(10, 80, 106, 1)),
                            ),
                            onPressed: () {
                              if (videoUrl == "" && videoName == "") {
                                if (curUid == assessor) {
                                  uploadVideo(context);
                                } else {
                                  _showSnackBar(
                                      "You are not allowed to upload video",
                                      context);
                                }
                              } else {
                                _showSnackBar(
                                    "You can add only one video", context);
                              }
                            },
                          ),
                        ]),
                  ),
                  SizedBox(height: 10),
                  (uploading)
                      ? Center(
                          child: Column(
                            children: [
                              Text("Uploading Video...."),
                              SizedBox(
                                height: 5,
                              ),
                              CircularProgressIndicator()
                            ],
                          ),
                        )
                      : (videoUrl != "" &&
                              videoUrl != null &&
                              videoName != "" &&
                              videoName != null)
                          ? InkWell(
                              // ignore: missing_return
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        ViewVideo(videoUrl, widget.roomname)));
                              },
                              child: Container(
                                decoration: new BoxDecoration(
                                  color: Color(0xFFeeeef5),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(40.0),
                                  ),
                                ),
                                width: (videoName == '' || videoName == null)
                                    ? 0.0
                                    : MediaQuery.of(context).size.width - 50,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: (videoName == '' ||
                                              videoName == null)
                                          ? 0.0
                                          : MediaQuery.of(context).size.width -
                                              150,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0, vertical: 15.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: (videoName == null ||
                                                      videoName == "")
                                                  ? SizedBox()
                                                  : Text(
                                                      "$videoName",
                                                      style: normalTextStyle()
                                                          .copyWith(
                                                              fontSize: 14.0),
                                                      overflow:
                                                          TextOverflow.fade,
                                                      maxLines: 1,
                                                      softWrap: false,
                                                    ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    (videoName == '')
                                        ? SizedBox()
                                        : IconButton(
                                            onPressed: () {
                                              if (therapist == assessor &&
                                                  role == "therapist") {
                                                setState(() {
                                                  widget.wholelist[0]
                                                          [widget.accessname]
                                                      ["videos"]["name"] = "";
                                                  widget.wholelist[0]
                                                          [widget.accessname]
                                                      ["videos"]["url"] = "";
                                                  deleteFile(videoUrl);
                                                  deleteVideo();
                                                  NewAssesmentRepository()
                                                      .setForm(widget.wholelist,
                                                          widget.docID);
                                                });
                                              } else if (role != "therapist") {
                                                setState(() {
                                                  widget.wholelist[0]
                                                          [widget.accessname]
                                                      ["videos"]["name"] = "";
                                                  widget.wholelist[0]
                                                          [widget.accessname]
                                                      ["videos"]["url"] = "";
                                                  deleteFile(videoUrl);
                                                  deleteVideo();
                                                  NewAssesmentRepository()
                                                      .setForm(widget.wholelist,
                                                          widget.docID);
                                                });
                                              } else {
                                                _showSnackBar(
                                                    "You can't change the other fields",
                                                    context);
                                              }
                                            },
                                            icon: Icon(
                                              Icons.delete_outline_rounded,
                                              color: Color.fromRGBO(
                                                  10, 80, 106, 1),
                                            ),
                                          ),
                                    // SizedBox(
                                    //   width: 15.0,
                                    // )
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(),
                  Container(
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                    child: Column(
                      children: [
                        // SizedBox(
                        //   height: 15,
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .58,
                              child: Text('Obstacle/Clutter Present?',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            // DropdownButton(
                            //   items: [
                            //     DropdownMenuItem(
                            //       child: Text('--'),
                            //       value: '',
                            //     ),
                            //     DropdownMenuItem(
                            //       child: Text('Yes'),
                            //       value: 'Yes',
                            //     ),
                            //     DropdownMenuItem(
                            //       child: Text('No'),
                            //       value: 'No',
                            //     )
                            //   ],
                            //   onChanged: (value) {
                            //     FocusScope.of(context).requestFocus();
                            //     new TextEditingController().clear();
                            //     // print(widget.accessname);
                            //     if (assessor == therapist &&
                            //         role == "therapist") {
                            //       setdata(
                            //           1, value, 'Obstacle/Clutter Present?');
                            //     } else if (role != "therapist") {
                            //       setdata(
                            //           1, value, 'Obstacle/Clutter Present?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: getvalue(1),
                            // )
                            toggleButton(context, pathwaypro, 1,
                                'Obstacle/Clutter Present?')
                          ],
                        ),
                        SizedBox(height: 15),
                        (getvalue(1) == 'Yes')
                            ? getrecomain(1, true, context)
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Typically Uses',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            Container(
                              child: DropdownButton(
                                items: [
                                  DropdownMenuItem(
                                    child: Text('--'),
                                    value: '',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Front Entrance'),
                                    value: 'Front Entrance',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Garage Entrance'),
                                    value: 'Garage Entrance',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Side Entrance'),
                                    value: 'Side Entrance',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Back Entrance'),
                                    value: 'Back Entrance',
                                  ),
                                ],
                                onChanged: (value) {
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    setdata(2, value, 'Typically Uses');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    setdata(2, value, 'Typically Uses');
                                  } else {
                                    _showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                                value: getvalue(2),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Occasionally Uses',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            Container(
                              child: DropdownButton(
                                items: [
                                  DropdownMenuItem(
                                    child: Text('--'),
                                    value: '',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Front Entrance'),
                                    value: 'Front Entrance',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Garage Entrance'),
                                    value: 'Garage Entrance',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Side Entrance'),
                                    value: 'Side Entrance',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Back Entrance'),
                                    value: 'Back Entrance',
                                  ),
                                ],
                                onChanged: (value) {
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    setdata(3, value, 'Occasionally Uses');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    setdata(3, value, 'Occasionally Uses');
                                  } else {
                                    _showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                                value: getvalue(3),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Entrance Has Lights?',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            // DropdownButton(
                            //   items: [
                            //     DropdownMenuItem(
                            //       child: Text('--'),
                            //       value: '',
                            //     ),
                            //     DropdownMenuItem(
                            //       child: Text('Yes'),
                            //       value: 'Yes',
                            //     ),
                            //     DropdownMenuItem(
                            //       child: Text('No'),
                            //       value: 'No',
                            //     )
                            //   ],
                            //   onChanged: (value) {
                            //     if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       setdata(4, value, 'Entrance Has Lights?');
                            //     } else if (assessor == therapist &&
                            //         role == "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       setdata(4, value, 'Entrance Has Lights?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: getvalue(4),
                            // )
                            toggleButton(
                                context, pathwaypro, 4, "Entrance Has Lights?"),
                          ],
                        ),
                        SizedBox(height: 15),
                        (getvalue(4) == 'No')
                            ? getrecomain(4, true, context)
                            : SizedBox(),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Door Width',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .3,
                              child: TextFormField(
                                  initialValue: getvalue(5),
                                  decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Color.fromRGBO(10, 80, 106, 1),
                                            width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(width: 1),
                                      ),
                                      labelText: '(Inches)'),
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d*')),
                                  ], //
                                  onChanged: (value) {
                                    if (assessor == therapist &&
                                        role == "therapist") {
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                      setdata(5, value, 'Door Width');
                                    } else if (role != "therapist") {
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                      setdata(5, value, 'Door Width');
                                    } else {
                                      _showSnackBar(
                                          "You can't change the other fields",
                                          context);
                                    }
                                  }),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        (getvalue(5) != "")
                            ? (double.parse(getvalue(5)) < 30 &&
                                    double.parse(getvalue(5)) > 0)
                                ? getrecomain(5, true, context)
                                : SizedBox()
                            : SizedBox(),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .58,
                              child: Text('Smoke Detector Present?',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            //Decoration for the dropdown button

                            // DecoratedBox(
                            //   decoration: ShapeDecoration(
                            //     shape: RoundedRectangleBorder(
                            //       side: BorderSide(
                            //           width: 1.0,
                            //           style: BorderStyle.solid,
                            //           color: Colors.black),
                            //       borderRadius:
                            //           BorderRadius.all(Radius.circular(5.0)),
                            //     ),
                            //   ),
                            //   child: Padding(
                            //     padding:
                            //         const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                            // child:
                            // DropdownButton(
                            //   items: [
                            //     DropdownMenuItem(
                            //       child: Text('--'),
                            //       value: '',
                            //     ),
                            //     DropdownMenuItem(
                            //       child: Text('Yes'),
                            //       value: 'Yes',
                            //     ),
                            //     DropdownMenuItem(
                            //       child: Text('No'),
                            //       value: 'No',
                            //     ),
                            //   ],
                            //   onChanged: (value) {
                            //     if (assessor == therapist &&
                            //         role == "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       setdata(6, value, 'Smoke Detector Present?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       setdata(6, value, 'Smoke Detector Present?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: getvalue(6),
                            // ),
                            //   ),
                            // )
                            toggleButton(context, pathwaypro, 6,
                                "Smoke Detector Present?"),
                          ],
                        ),
                        SizedBox(height: 15),
                        (getvalue(6) == 'No')
                            ? getrecomain(6, true, context)
                            : SizedBox(),

                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: Text('Type of Steps',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            Container(
                              // width: MediaQuery.of(context).size.width * .3,
                              child: DropdownButton(
                                items: [
                                  DropdownMenuItem(
                                    child: Text('--'),
                                    value: '',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Single Dimension'),
                                    value: 'Single Dimension',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Multiple Dimension'),
                                    value: 'Multiple Dimension',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('NA'),
                                    value: 'N/A',
                                  ),
                                ],
                                onChanged: (value) {
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    setdata(7, value, 'Type of Steps');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    setdata(7, value, 'Type of Steps');
                                  } else {
                                    _showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                                value: getvalue(7),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        (getvalue(7) != '' && getvalue(7) != 'N/A')
                            ? (getvalue(7) == 'Single Dimension')
                                ? SingleChildScrollView(
                                    // reverse: true,
                                    child: Container(
                                      // color: Colors.yellow,
                                      child: Column(
                                        children: [
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .5,
                                                  child: Text('Number of Steps',
                                                      style: TextStyle(
                                                        color: Color.fromRGBO(
                                                            10, 80, 106, 1),
                                                        fontSize: 20,
                                                      )),
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .3,
                                                  child: TextFormField(
                                                      initialValue: widget
                                                          .wholelist[0][widget
                                                                  .accessname][
                                                              'question']
                                                              [
                                                              "7"]
                                                              [
                                                              'stepCount'][
                                                              "count"]
                                                          .toString(),
                                                      decoration:
                                                          InputDecoration(
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            10,
                                                                            80,
                                                                            106,
                                                                            1),
                                                                    width: 1),
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1),
                                                              ),
                                                              labelText:
                                                                  'Count'),
                                                      keyboardType:
                                                          TextInputType.phone,
                                                      onChanged: (value) {
                                                        if (assessor ==
                                                                therapist &&
                                                            role ==
                                                                "therapist") {
                                                          setState(() {
                                                            widget.wholelist[0][
                                                                            widget.accessname]
                                                                        [
                                                                        'question']["7"]
                                                                    [
                                                                    'stepCount']
                                                                [
                                                                "count"] = value;
                                                          });
                                                        } else if (role !=
                                                            "therapist") {
                                                          setState(() {
                                                            widget.wholelist[0][
                                                                            widget.accessname]
                                                                        [
                                                                        'question']["7"]
                                                                    [
                                                                    'stepCount']
                                                                [
                                                                "count"] = value;
                                                          });
                                                        } else {
                                                          _showSnackBar(
                                                              "You can't change the other fields",
                                                              context);
                                                        }

                                                        // print(widget.wholelist[
                                                        //             0][
                                                        //         widget
                                                        //             .accessname]
                                                        //     ['question']);
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ),
                                          widget.wholelist[0][widget.accessname]
                                                                  ['question']
                                                              ["7"]['stepCount']
                                                          ["count"] !=
                                                      '0' &&
                                                  widget.wholelist[0][widget.accessname]
                                                                  ['question']
                                                              ["7"]['stepCount']
                                                          ["count"] !=
                                                      ""
                                              ? Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 10, 0, 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .4,
                                                        child: TextFormField(
                                                          initialValue: widget
                                                                          .wholelist[0]
                                                                      [
                                                                      widget
                                                                          .accessname]
                                                                  [
                                                                  'question']["7"]
                                                              [
                                                              'Single Step Width'],
                                                          keyboardType:
                                                              TextInputType
                                                                  .phone,
                                                          decoration:
                                                              InputDecoration(
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: colorsset[
                                                                            "field${7}"],
                                                                        width:
                                                                            1),
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: colorsset[
                                                                            "field${7}"]),
                                                                  ),
                                                                  labelText:
                                                                      'Step Width:'),
                                                          onChanged: (value) {
                                                            if (assessor ==
                                                                    therapist &&
                                                                role ==
                                                                    "therapist") {
                                                              setState(() {
                                                                widget.wholelist[0]
                                                                            [
                                                                            widget
                                                                                .accessname]
                                                                        [
                                                                        'question']["7"]
                                                                    [
                                                                    'Single Step Width'] = value;
                                                              });
                                                            } else if (role !=
                                                                "therapist") {
                                                              setState(() {
                                                                widget.wholelist[0]
                                                                            [
                                                                            widget
                                                                                .accessname]
                                                                        [
                                                                        'question']["7"]
                                                                    [
                                                                    'Single Step Width'] = value;
                                                              });
                                                            } else {
                                                              _showSnackBar(
                                                                  "You can't change the other fields",
                                                                  context);
                                                            }

                                                            // print(widget.wholelist[
                                                            //             0][
                                                            //         widget
                                                            //             .accessname]
                                                            //     ['question']["7"]);
                                                          },
                                                        ),
                                                      ),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .4,
                                                        child: TextFormField(
                                                          initialValue: widget
                                                                          .wholelist[0]
                                                                      [
                                                                      widget
                                                                          .accessname]
                                                                  [
                                                                  'question']["7"]
                                                              [
                                                              'Single Step Height'],
                                                          keyboardType:
                                                              TextInputType
                                                                  .phone,
                                                          decoration:
                                                              InputDecoration(
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: colorsset[
                                                                            "field${7}"],
                                                                        width:
                                                                            1),
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: colorsset[
                                                                            "field${7}"]),
                                                                  ),
                                                                  labelText:
                                                                      'Step Height:'),
                                                          onChanged: (value) {
                                                            if (assessor ==
                                                                    therapist &&
                                                                role ==
                                                                    "therapist") {
                                                              setState(() {
                                                                widget.wholelist[0]
                                                                            [
                                                                            widget
                                                                                .accessname]
                                                                        [
                                                                        'question']["7"]
                                                                    [
                                                                    'Single Step Height'] = value;
                                                              });
                                                            } else if (role !=
                                                                "therapist") {
                                                              setState(() {
                                                                widget.wholelist[0]
                                                                            [
                                                                            widget
                                                                                .accessname]
                                                                        [
                                                                        'question']["7"]
                                                                    [
                                                                    'Single Step Height'] = value;
                                                              });
                                                            } else {
                                                              _showSnackBar(
                                                                  "You can't change the other fields",
                                                                  context);
                                                            }

                                                            // print(widget.wholelist[
                                                            //             0][
                                                            //         widget
                                                            //             .accessname]
                                                            //     ['question']["7"]);
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ))
                                              : SizedBox(),
                                        ],
                                      ),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    // reverse: true,
                                    child: Container(
                                      // color: Colors.yellow,
                                      child: Column(
                                        children: [
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .5,
                                                  child: Text('Number of Steps',
                                                      style: TextStyle(
                                                        color: Color.fromRGBO(
                                                            10, 80, 106, 1),
                                                        fontSize: 20,
                                                      )),
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .3,
                                                  child: NumericStepButton(
                                                    counterval: stepcount,
                                                    onChanged: (value) {
                                                      if (assessor ==
                                                              therapist &&
                                                          role == "therapist") {
                                                        setState(() {
                                                          widget.wholelist[0][widget
                                                                          .accessname]
                                                                      [
                                                                      'question']["7"]
                                                                  [
                                                                  'MultipleStair']
                                                              ['count'] = value;
                                                          widget.wholelist[0][widget
                                                                      .accessname]
                                                                  [
                                                                  'question']["7"]
                                                              [
                                                              'Recommendation'] = value;

                                                          stepcount = widget
                                                                          .wholelist[0]
                                                                      [
                                                                      widget
                                                                          .accessname]
                                                                  [
                                                                  'question']["7"]
                                                              [
                                                              'Recommendation'];
                                                          if (value > 0) {
                                                            widget.wholelist[0][
                                                                            widget.accessname]
                                                                        [
                                                                        'question']["7"]
                                                                    [
                                                                    'MultipleStair']
                                                                [
                                                                'step$value'] = {
                                                              'stepwidth': '',
                                                              'stepheight': ''
                                                            };

                                                            if (widget
                                                                .wholelist[0][
                                                                    widget
                                                                        .accessname]
                                                                    ['question']
                                                                    ["7"][
                                                                    'MultipleStair']
                                                                .containsKey(
                                                                    'step${value + 1}')) {
                                                              widget
                                                                  .wholelist[0][
                                                                      widget
                                                                          .accessname]
                                                                      [
                                                                      'question']
                                                                      ["7"][
                                                                      'MultipleStair']
                                                                  .remove(
                                                                      'step${value + 1}');
                                                            }
                                                          } else if (value ==
                                                              0) {
                                                            if (widget
                                                                .wholelist[0][
                                                                    widget
                                                                        .accessname]
                                                                    ['question']
                                                                    ["7"][
                                                                    'MultipleStair']
                                                                .containsKey(
                                                                    'step${value + 1}')) {
                                                              widget
                                                                  .wholelist[0][
                                                                      widget
                                                                          .accessname]
                                                                      [
                                                                      'question']
                                                                      ["7"][
                                                                      'MultipleStair']
                                                                  .remove(
                                                                      'step${value + 1}');
                                                            }
                                                          }
                                                        });
                                                      } else if (role !=
                                                          "therapist") {
                                                        setState(() {
                                                          widget.wholelist[0][widget
                                                                          .accessname]
                                                                      [
                                                                      'question']["7"]
                                                                  [
                                                                  'MultipleStair']
                                                              ['count'] = value;
                                                          widget.wholelist[0][widget
                                                                      .accessname]
                                                                  [
                                                                  'question']["7"]
                                                              [
                                                              'Recommendation'] = value;

                                                          stepcount = widget
                                                                          .wholelist[0]
                                                                      [
                                                                      widget
                                                                          .accessname]
                                                                  [
                                                                  'question']["7"]
                                                              [
                                                              'Recommendation'];
                                                          if (value > 0) {
                                                            widget.wholelist[0][
                                                                            widget.accessname]
                                                                        [
                                                                        'question']["7"]
                                                                    [
                                                                    'MultipleStair']
                                                                [
                                                                'step$value'] = {
                                                              'stepwidth': '',
                                                              'stepheight': ''
                                                            };

                                                            if (widget
                                                                .wholelist[0][
                                                                    widget
                                                                        .accessname]
                                                                    ['question']
                                                                    ["7"][
                                                                    'MultipleStair']
                                                                .containsKey(
                                                                    'step${value + 1}')) {
                                                              widget
                                                                  .wholelist[0][
                                                                      widget
                                                                          .accessname]
                                                                      [
                                                                      'question']
                                                                      ["7"][
                                                                      'MultipleStair']
                                                                  .remove(
                                                                      'step${value + 1}');
                                                            }
                                                          } else if (value ==
                                                              0) {
                                                            if (widget
                                                                .wholelist[0][
                                                                    widget
                                                                        .accessname]
                                                                    ['question']
                                                                    ["7"][
                                                                    'MultipleStair']
                                                                .containsKey(
                                                                    'step${value + 1}')) {
                                                              widget
                                                                  .wholelist[0][
                                                                      widget
                                                                          .accessname]
                                                                      [
                                                                      'question']
                                                                      ["7"][
                                                                      'MultipleStair']
                                                                  .remove(
                                                                      'step${value + 1}');
                                                            }
                                                          }
                                                        });
                                                      } else {
                                                        _showSnackBar(
                                                            "You can't change the other fields",
                                                            context);
                                                      }

                                                      // print(widget.wholelist[0][
                                                      //             widget
                                                      //                 .accessname]
                                                      //         ['question']["7"]
                                                      //     ['MultipleStair']);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          (stepcount > 0)
                                              ? Container(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(10),
                                                    child: ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                          maxHeight: 1000,
                                                          minHeight:
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  10),
                                                      child: ListView.builder(
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount: stepcount,
                                                        itemBuilder:
                                                            (context, index1) {
                                                          return stepcountswid(
                                                              index1 + 1,
                                                              context);
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox()
                                        ],
                                      ),
                                    ),
                                  )
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Railing',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            DropdownButton(
                              items: [
                                DropdownMenuItem(
                                  child: Text('--'),
                                  value: '',
                                ),
                                DropdownMenuItem(
                                  child: Text('One Side'),
                                  value: 'One Side',
                                ),
                                DropdownMenuItem(
                                  child: Text('Both Side'),
                                  value: 'Both Side',
                                ),
                                DropdownMenuItem(
                                  child: Text('On Neither Side'),
                                  value: 'On Neither Side',
                                ),
                              ],
                              onChanged: (value) {
                                if (assessor == therapist &&
                                    role == "therapist") {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  setdata(8, value, 'Railling');
                                } else if (role != "therapist") {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  setdata(8, value, 'Railling');
                                } else {
                                  _showSnackBar(
                                      "You can't change the other fields",
                                      context);
                                }
                              },
                              value: getvalue(8),
                            )
                          ],
                        ),
                        (getvalue(8) == 'On Neither Side')
                            ? getrecomain(8, true, context)
                            : (getvalue(8) == 'One Side')
                                ? Container(
                                    child: Column(
                                    children: [
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .5,
                                              child: Text('Going Up',
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        10, 80, 106, 1),
                                                    fontSize: 20,
                                                  )),
                                            ),
                                            DropdownButton(
                                              items: [
                                                DropdownMenuItem(
                                                  child: Text('--'),
                                                  value: '',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text('Left'),
                                                  value: 'Left',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text('Right'),
                                                  value: 'Right',
                                                ),
                                              ],
                                              onChanged: (value) {
                                                if (assessor == therapist &&
                                                    role == "therapist") {
                                                  widget.wholelist[0][widget
                                                                  .accessname]
                                                              ['question']["8"][
                                                          'Railling']['OneSided']
                                                      ['GoingUp'] = value;
                                                } else if (role !=
                                                    "therapist") {
                                                  widget.wholelist[0][widget
                                                                  .accessname]
                                                              ['question']["8"][
                                                          'Railling']['OneSided']
                                                      ['GoingUp'] = value;
                                                } else {
                                                  _showSnackBar(
                                                      "You can't change the other fields",
                                                      context);
                                                }
                                              },
                                              value: widget.wholelist[0][
                                                              widget.accessname]
                                                          ['question']["8"]
                                                      ['Railling']['OneSided']
                                                  ['GoingUp'],
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .5,
                                              child: Text('Going Down',
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        10, 80, 106, 1),
                                                    fontSize: 20,
                                                  )),
                                            ),
                                            DropdownButton(
                                              items: [
                                                DropdownMenuItem(
                                                  child: Text('--'),
                                                  value: '',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text('Left'),
                                                  value: 'Left',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text('Right'),
                                                  value: 'Right',
                                                ),
                                              ],
                                              onChanged: (value) {
                                                if (assessor == therapist &&
                                                    role == "therapist") {
                                                  widget.wholelist[0][widget
                                                                  .accessname]
                                                              ['question']["8"][
                                                          'Railling']['OneSided']
                                                      ['GoingDown'] = value;
                                                } else if (role !=
                                                    "therapist") {
                                                  widget.wholelist[0][widget
                                                                  .accessname]
                                                              ['question']["8"][
                                                          'Railling']['OneSided']
                                                      ['GoingDown'] = value;
                                                } else {
                                                  _showSnackBar(
                                                      "You can't change the other fields",
                                                      context);
                                                }
                                              },
                                              value: widget.wholelist[0][
                                                              widget.accessname]
                                                          ['question']["8"]
                                                      ['Railling']['OneSided']
                                                  ['GoingDown'],
                                            )
                                          ],
                                        ),
                                      ),
                                      (role == 'therapist')
                                          ? getrecomain(8, true, context)
                                          : SizedBox()
                                    ],
                                  ))
                                : SizedBox(),

                        SizedBox(
                          height: 15,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .5,
                                child: Text('Threshold to Front Door',
                                    style: TextStyle(
                                      color: Color.fromRGBO(10, 80, 106, 1),
                                      fontSize: 20,
                                    )),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .3,
                                child: TextFormField(
                                    initialValue: getvalue(9),
                                    decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color.fromRGBO(
                                                  10, 80, 106, 1),
                                              width: 1),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(width: 1),
                                        ),
                                        labelText: '(Inches)'),
                                    keyboardType: TextInputType.phone,
                                    onChanged: (value) {
                                      if (assessor == therapist &&
                                          role == "therapist") {
                                        FocusScope.of(context).requestFocus();
                                        new TextEditingController().clear();
                                        // print(widget.accessname);

                                        setdata(9, value,
                                            'Threshold to Front Door');
                                      } else if (role != "therapist") {
                                        FocusScope.of(context).requestFocus();
                                        new TextEditingController().clear();
                                        // print(widget.accessname);

                                        setdata(9, value,
                                            'Threshold to Front Door');
                                      } else {
                                        _showSnackBar(
                                            "You can't change the other fields",
                                            context);
                                      }
                                    }),
                              ),
                            ]),
                        (getvalue(9) != "")
                            ? (double.parse(getvalue(9)) > 5)
                                ? (role == 'therapist')
                                    ? getrecomain(9, true, context)
                                    : SizedBox()
                                : SizedBox()
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .35,
                              child: Text(
                                  'Able to Manage Through Doors/Thresholds/ Door Sills?',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            DropdownButton(
                              items: [
                                DropdownMenuItem(
                                  child: Text('--'),
                                  value: '',
                                ),
                                DropdownMenuItem(
                                  child: Text('Fairly Well'),
                                  value: 'Fairly Well',
                                ),
                                DropdownMenuItem(
                                  child: Text('With Difficulty'),
                                  value: 'With Difficulty',
                                ),
                                (role == "therapist")
                                    ? DropdownMenuItem(
                                        child: Text('Min(A)'),
                                        value: 'Min(A)',
                                      )
                                    : DropdownMenuItem(
                                        child: Text('25% Assistance'),
                                        value: 'Min(A)',
                                      ),
                                (role == "therapist")
                                    ? DropdownMenuItem(
                                        child: Text('Mod(A)'),
                                        value: 'Mod(A)',
                                      )
                                    : DropdownMenuItem(
                                        child: Text('50% Assistance'),
                                        value: 'Mod(A)',
                                      ),
                                (role == "therapist")
                                    ? DropdownMenuItem(
                                        child: Text('Max(A)'),
                                        value: 'Max(A)',
                                      )
                                    : DropdownMenuItem(
                                        child: Text('75% Assistance'),
                                        value: 'Max(A)',
                                      ),
                                (role == "therapist")
                                    ? DropdownMenuItem(
                                        child: Text('Max(A) x2'),
                                        value: 'Max(A) x2',
                                      )
                                    : DropdownMenuItem(
                                        child:
                                            Text('75% Assistance (2 People)'),
                                        value: 'Max(A) x2',
                                      ),
                              ],
                              onChanged: (value) {
                                if (assessor == therapist &&
                                    role == "therapist") {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  setdata(10, value,
                                      'Able to Manage Through Doors/Thresholds/ Door Sills?');
                                } else if (role != "therapist") {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  setdata(10, value,
                                      'Able to Manage Through Doors/Thresholds/ Door Sills?');
                                } else {
                                  _showSnackBar(
                                      "You can't change the other fields",
                                      context);
                                }
                              },
                              value: getvalue(10),
                            )
                          ],
                        ),
                        (getvalue(10) != 'Fairly Well' && getvalue(10) != '')
                            ? getrecomain(10, true, context)
                            : SizedBox(),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .35,
                              child: Text('Able to Lock/Unlock Doors?',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            DropdownButton(
                              items: [
                                DropdownMenuItem(
                                  child: Text('--'),
                                  value: '',
                                ),
                                DropdownMenuItem(
                                  child: Text('Fairly Well'),
                                  value: 'Fairly Well',
                                ),
                                DropdownMenuItem(
                                  child: Text('With Difficulty'),
                                  value: 'With Difficulty',
                                ),
                                (role == "therapist")
                                    ? DropdownMenuItem(
                                        child: Text('Min(A)'),
                                        value: 'Min(A)',
                                      )
                                    : DropdownMenuItem(
                                        child: Text('25% Assistance'),
                                        value: 'Min(A)',
                                      ),
                                (role == "therapist")
                                    ? DropdownMenuItem(
                                        child: Text('Mod(A)'),
                                        value: 'Mod(A)',
                                      )
                                    : DropdownMenuItem(
                                        child: Text('50% Assistance'),
                                        value: 'Mod(A)',
                                      ),
                                (role == "therapist")
                                    ? DropdownMenuItem(
                                        child: Text('Max(A)'),
                                        value: 'Max(A)',
                                      )
                                    : DropdownMenuItem(
                                        child: Text('75% Assistance'),
                                        value: 'Max(A)',
                                      ),
                                (role == "therapist")
                                    ? DropdownMenuItem(
                                        child: Text('Max(A) x2'),
                                        value: 'Max(A) x2',
                                      )
                                    : DropdownMenuItem(
                                        child:
                                            Text('75% Assistance (2 People)'),
                                        value: 'Max(A) x2',
                                      ),
                              ],
                              onChanged: (value) {
                                if (assessor == therapist &&
                                    role == "therapist") {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  setdata(
                                      11, value, 'Able to Lock/Unlock Doors?');
                                } else if (role != "therapist") {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  setdata(
                                      11, value, 'Able to Lock/Unlock Doors?');
                                } else {
                                  _showSnackBar(
                                      "You can't change the other fields",
                                      context);
                                }
                              },
                              value: getvalue(11),
                            )
                          ],
                        ),
                        (getvalue(11) != 'Fairly Well' && getvalue(11) != '')
                            ? getrecomain(11, true, context)
                            : SizedBox(),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Observations',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                          ],
                        ),

                        // Divider(
                        //   height: dividerheight,
                        //   color: Color.fromRGBO(10, 80, 106, 1),
                        // ),
                        SizedBox(height: 15),
                        // Container(
                        //     // height: 10000,
                        //     child: TextFormField(
                        //   initialValue: widget.wholelist[0][widget.accessname]
                        //       ["question"]["12"]["Answer"],
                        //   maxLines: 6,
                        //   decoration: InputDecoration(
                        //     focusedBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(
                        //           color: Color.fromRGBO(10, 80, 106, 1),
                        //           width: 1),
                        //     ),
                        //     enabledBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(width: 1),
                        //     ),
                        //     // isDense: true,
                        //     // suffix: Icon(Icons.mic),
                        //   ),
                        //   onChanged: (value) {
                        //     if (assessor == therapist && role == "therapist") {
                        //       FocusScope.of(context).requestFocus();
                        //       new TextEditingController().clear();
                        //       // print(widget.accessname);
                        //       setreco(12, value);
                        //       setdata(12, value, 'Oberservations');
                        //     } else if (role != "therapist") {
                        //       FocusScope.of(context).requestFocus();
                        //       new TextEditingController().clear();
                        //       // print(widget.accessname);
                        //       setreco(12, value);
                        //       setdata(12, value, 'Oberservations');
                        //     } else {
                        //       _showSnackBar(
                        //           "You can't change the other fields", context);
                        //     }
                        //   },
                        // )
                        // )
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 8, 8, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  // initialValue: getvalue(14),
                                  maxLines: 6,
                                  showCursor: cur,
                                  controller: _controllers["field12"],
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),

                                  onChanged: (value) {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    if (assessor == therapist &&
                                        role == "therapist") {
                                      setreco(12, value);
                                      setdata(12, value, 'Oberservations');
                                    } else if (role != "therapist") {
                                      setreco(12, value);
                                      setdata(12, value, 'Oberservations');
                                    } else {
                                      _showSnackBar(
                                          "You can't change the other fields",
                                          context);
                                    }
                                  },
                                ),
                              ),
                              AvatarGlow(
                                animate: isListening["field12"],
                                glowColor: Colors.blue,
                                endRadius: 35.0,
                                duration: const Duration(milliseconds: 2000),
                                repeatPauseDuration:
                                    const Duration(milliseconds: 300),
                                repeat: true,
                                child: Container(
                                  width: 40,
                                  height: 30,
                                  padding: EdgeInsets.all(0),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.all(0),
                                  child: FloatingActionButton(
                                    heroTag: "btn12",
                                    child: Icon(
                                      Icons.mic,
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      // Map<Permission, PermissionStatus>
                                      //     permissions = await [
                                      //   Permission.microphone
                                      // ].request();

                                      if (assessor == therapist &&
                                          role == "therapist") {
                                        _listen(12, false);
                                        setdatalisten(12);
                                      } else if (role != "therapist") {
                                        _listen(12, false);
                                        setdatalisten(12);
                                      } else {
                                        _showSnackBar(
                                            "You can't change the other fields",
                                            context);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colorsset["field${12}"],
                              width: 1,
                            ), //Border.all
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20),
                    ),
                    color: colorb,
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onPressed: () async {
                      listenbutton(context);

                      // _showSnackBar(
                      //     "You Must Have to Fill the Details First", context);
                    },
                  ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // /// this fucntion helps us to listent to hte done button at the bottom
  // void listenbutton(BuildContext context) {
  //   var test = widget.wholelist[0][widget.accessname]["complete"];
  //   for (int i = 0;
  //       i < widget.wholelist[0][widget.accessname]['question'].length;
  //       i++) {
  //     // print(colorsset["field${i + 1}"]);
  //     // if (colorsset["field${i + 1}"] == Colors.red) {
  //     //   showDialog(
  //     //       context: context,
  //     //       builder: (context) => CustomDialog(
  //     //           title: "Not Saved",
  //     //           description: "Please click tick button to save the field"));
  //     //   test = 1;
  //     // }
  //     setdatalisten(i + 1);
  //   }
  //   // if (test == 0) {
  //   //   _showSnackBar("You must have to fill at least 1 field first", context);
  //   // } else {
  //   if (role == "therapist") {
  //     // if (saveToForm) {
  //     NewAssesmentRepository().setLatestChangeDate(widget.docID);
  //     NewAssesmentRepository().setForm(widget.wholelist, widget.docID);
  //     Navigator.pop(context, widget.wholelist[0][widget.accessname]);
  //     // } else {
  //     //   _showSnackBar("Provide all recommendations", context);
  //     // }
  //   } else {
  //     NewAssesmentRepository().setLatestChangeDate(widget.docID);
  //     NewAssesmentRepository().setForm(widget.wholelist, widget.docID);
  //     Navigator.pop(context, widget.wholelist[0][widget.accessname]);
  //     // Navigator.of(buildContext).pushReplacement(MaterialPageRoute(
  //     //     builder: (context) =>
  //     //         CompleteAssessmentBase(widget.wholelist, widget.docID, role)));
  //   }
  //   // }
  // }

  /// This fucntion is to take care of speeck to text mic button and place the text in
  /// the particular field.
  // void _listen(index, bool isthera) async {
  //   if (!isListening['field$index']) {
  //     bool available = await _speech.initialize(
  //       onStatus: (val) {
  //         print('onStatus: $val');
  //         if (val == 'notListening') {
  //           setState(() {
  //             isListening['field$index'] = false;
  //           });
  //         }
  //       },
  //       onError: (val) => print('onError: $val'),
  //     );
  //     if (available) {
  //       setState(() {
  //         // _isListening = true;
  //         colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
  //         isListening['field$index'] = true;
  //       });
  //       if (isthera) {
  //         _speech.listen(
  //           onResult: (val) => setState(() {
  //             _controllerstreco["field$index"].text = widget.wholelist[0]
  //                         [widget.accessname]['question']["$index"]
  //                     ['Recommendationthera'] +
  //                 " " +
  //                 val.recognizedWords;
  //             // if (val.hasConfidenceRating && val.confidence > 0) {
  //             //   _confidence = val.confidence;
  //             // }
  //           }),
  //         );
  //       } else {
  //         _speech.listen(
  //           onResult: (val) => setState(() {
  //             _controllers["field$index"].text = widget.wholelist[0]
  //                         [widget.accessname]['question']["$index"]
  //                     ['Recommendation'] +
  //                 " " +
  //                 val.recognizedWords;
  //             // if (val.hasConfidenceRating && val.confidence > 0) {
  //             //   _confidence = val.confidence;
  //             // }
  //           }),
  //         );
  //       }
  //     }
  //   } else {
  //     setState(() {
  //       // _isListening = false;
  //       isListening['field$index'] = false;
  //       colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
  //     });
  //     _speech.stop();
  //   }
  // }

  // ticklisten(index) {
  //   print('clicked');
  //   setState(() {
  //     // _isListening = false;
  //     // isListening['field$index'] = false;
  //     colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
  //   });
  //   _speech.stop();
  // }

  // /// This function is a helper function of the listen fucntion.
  // setdatalisten(index) {
  //   setState(() {
  //     widget.wholelist[0][widget.accessname]['question']["$index"]
  //         ['Recommendation'] = _controllers["field$index"].text;
  //     cur = !cur;
  //   });
  // }

  // setdatalistenThera(index) {
  //   setState(() {
  //     widget.wholelist[0][widget.accessname]['question']["$index"]
  //         ['Recommendationthera'] = _controllerstreco["field$index"].text;
  //     curThera = !curThera;
  //   });
  // }

  // /// This is a widget function which returns is the recommendation fields and the
  // /// priority field.
  // Widget getrecomain(int index, bool isthera, BuildContext context) {
  //   return SingleChildScrollView(
  //     // reverse: true,
  //     child: Container(
  //       // color: Colors.yellow,
  //       child: Column(
  //         children: [
  //           Container(
  //             child: TextFormField(
  //               maxLines: null,
  //               showCursor: cur,
  //               controller: _controllers["field$index"],
  //               decoration: InputDecoration(
  //                   focusedBorder: OutlineInputBorder(
  //                     borderSide:
  //                         BorderSide(color: colorsset["field$index"], width: 1),
  //                   ),
  //                   enabledBorder: OutlineInputBorder(
  //                     borderSide:
  //                         BorderSide(width: 1, color: colorsset["field$index"]),
  //                   ),
  //                   suffix: Container(
  //                     // color: Colors.red,
  //                     width: 40,
  //                     height: 30,
  //                     padding: EdgeInsets.all(0),
  //                     child: Row(children: [
  //                       Container(
  //                         // color: Colors.green,
  //                         alignment: Alignment.center,
  //                         width: 40,
  //                         height: 60,
  //                         margin: EdgeInsets.all(0),
  //                         child: AvatarGlow(
  //                           animate: isListening['field$index'],
  //                           glowColor: Theme.of(context).primaryColor,
  //                           endRadius: 500.0,
  //                           duration: const Duration(milliseconds: 2000),
  //                           repeatPauseDuration:
  //                               const Duration(milliseconds: 100),
  //                           repeat: true,
  //                           child: FloatingActionButton(
  //                             heroTag: "btn${index + 100}",
  //                             child: Icon(
  //                               Icons.mic,
  //                               size: 20,
  //                             ),
  //                             onPressed: () {
  //                               if (assessor == therapist &&
  //                                   role == "therapist") {
  //                                 _listen(index, false);
  //                                 setdatalisten(index);
  //                               } else if (role != "therapist") {
  //                                 _listen(index, false);
  //                                 setdatalisten(index);
  //                               } else {
  //                                 _showSnackBar(
  //                                     "You can't change the other fields",
  //                                     context);
  //                               }
  //                             },
  //                           ),
  //                         ),
  //                       ),
  //                     ]),
  //                   ),
  //                   labelText: 'Comments'),
  //               onChanged: (value) {
  //                 if (assessor == therapist && role == "therapist") {
  //                   FocusScope.of(context).requestFocus();
  //                   new TextEditingController().clear();
  //                   // print(widget.accessname);
  //                   setreco(index, value);
  //                 } else if (role != "therapist") {
  //                   FocusScope.of(context).requestFocus();
  //                   new TextEditingController().clear();
  //                   // print(widget.accessname);
  //                   setreco(index, value);
  //                 } else {
  //                   _showSnackBar("You can't change the other fields", context);
  //                 }
  //               },
  //             ),
  //           ),
  //           (role == 'therapist' && isthera)
  //               ? getrecowid(index, context)
  //               : SizedBox(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget getrecowid(index, BuildContext context) {
  //   if (widget.wholelist[0][widget.accessname]["question"]["$index"]
  //           ["Recommendationthera"] !=
  //       "") {
  //     setState(() {
  //       isColor = true;
  //       // saveToForm = true;
  //       // widget.wholelist[0][widget.accessname]["isSave"] = saveToForm;
  //     });
  //   } else {
  //     setState(() {
  //       isColor = false;
  //       // saveToForm = false;
  //       // widget.wholelist[0][widget.accessname]["isSave"] = saveToForm;
  //     });
  //   }
  //   if (falseIndex == -1) {
  //     if (widget.wholelist[0][widget.accessname]["question"]["$index"]
  //             ["Recommendationthera"] !=
  //         "") {
  //       setState(() {
  //         saveToForm = true;
  //         trueIndex = index;
  //         widget.wholelist[0][widget.accessname]["isSave"] = saveToForm;
  //       });
  //     } else {
  //       setState(() {
  //         saveToForm = false;
  //         falseIndex = index;
  //         widget.wholelist[0][widget.accessname]["isSave"] = saveToForm;
  //       });
  //     }
  //   } else {
  //     if (index == falseIndex) {
  //       if (widget.wholelist[0][widget.accessname]["question"]["$index"]
  //               ["Recommendationthera"] !=
  //           "") {
  //         setState(() {
  //           widget.wholelist[0][widget.accessname]["isSave"] = true;
  //           falseIndex = -1;
  //         });
  //       } else {
  //         setState(() {
  //           widget.wholelist[0][widget.accessname]["isSave"] = false;
  //         });
  //       }
  //     }
  //   }
  //   return Column(
  //     children: [
  //       SizedBox(height: 8),
  //       TextFormField(
  //         onChanged: (value) {
  //           FocusScope.of(context).requestFocus();
  //           new TextEditingController().clear();
  //           // print(widget.accessname);
  //           setrecothera(index, value);
  //         },
  //         controller: _controllerstreco["field$index"],
  //         decoration: InputDecoration(
  //             focusedBorder: OutlineInputBorder(
  //               borderSide: BorderSide(
  //                   color: (isColor) ? Colors.green : Colors.red, width: 1),
  //             ),
  //             enabledBorder: OutlineInputBorder(
  //               borderSide: BorderSide(
  //                   width: 1, color: (isColor) ? Colors.green : Colors.red),
  //             ),
  //             suffix: Container(
  //               // color: Colors.red,
  //               width: 40,
  //               height: 30,
  //               padding: EdgeInsets.all(0),
  //               child: Row(children: [
  //                 Container(
  //                   // color: Colors.green,
  //                   alignment: Alignment.center,
  //                   width: 40,
  //                   height: 60,
  //                   margin: EdgeInsets.all(0),
  //                   child: AvatarGlow(
  //                     animate: isListening['field$index'],
  //                     glowColor: Theme.of(context).primaryColor,
  //                     endRadius: 500.0,
  //                     duration: const Duration(milliseconds: 2000),
  //                     repeatPauseDuration: const Duration(milliseconds: 100),
  //                     repeat: true,
  //                     child: FloatingActionButton(
  //                       heroTag: "btn$index",
  //                       child: Icon(
  //                         Icons.mic,
  //                         size: 20,
  //                       ),
  //                       onPressed: () {
  //                         _listen(index, true);
  //                         setdatalistenThera(index);
  //                       },
  //                     ),
  //                   ),
  //                 ),
  //               ]),
  //             ),
  //             labelStyle:
  //                 TextStyle(color: (isColor) ? Colors.green : Colors.red),
  //             labelText: 'Recommendation'),
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text('Priority'),
  //           Row(
  //             children: [
  //               Radio(
  //                 value: '1',
  //                 onChanged: (value) {
  //                   setprio(index, value);
  //                 },
  //                 groupValue: getprio(index),
  //               ),
  //               Text('1'),
  //               Radio(
  //                 value: '2',
  //                 onChanged: (value) {
  //                   setState(() {
  //                     setprio(index, value);
  //                   });
  //                 },
  //                 groupValue: getprio(index),
  //               ),
  //               Text('2'),
  //               Radio(
  //                 value: '3',
  //                 onChanged: (value) {
  //                   setState(() {
  //                     setprio(index, value);
  //                   });
  //                 },
  //                 groupValue: getprio(index),
  //               ),
  //               Text('3'),
  //             ],
  //           )
  //         ],
  //       )
  //     ],
  //   );
  // }

  // /// This function is specific for the pathwayui. this is used to generate the
  // /// steps field based on dynamic and multiple stairs to store data of each stair
  // Widget stepcountswid(index, BuildContext context) {
  //   return Container(
  //     child: Column(
  //       children: [
  //         Container(
  //           // padding: EdgeInsets.all(5),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Container(child: Text('$index:')),
  //               Container(
  //                 width: MediaQuery.of(context).size.width * .35,
  //                 child: TextFormField(
  //                   initialValue: widget.wholelist[0][widget.accessname]
  //                           ['question']["7"]['MultipleStair']['step$index']
  //                       ['stepwidth'],
  //                   keyboardType: TextInputType.phone,
  //                   decoration: InputDecoration(
  //                       focusedBorder: OutlineInputBorder(
  //                         borderSide: BorderSide(
  //                             color: colorsset["field${7}"], width: 1),
  //                       ),
  //                       enabledBorder: OutlineInputBorder(
  //                         borderSide: BorderSide(
  //                             width: 1, color: colorsset["field${7}"]),
  //                       ),
  //                       labelText: 'Step Width$index:'),
  //                   onChanged: (value) {
  //                     if (assessor == therapist && role == "therapist") {
  //                       setState(() {
  //                         widget.wholelist[0][widget.accessname]['question']
  //                                 ["7"]['MultipleStair']['step$index']
  //                             ['stepwidth'] = value;
  //                       });
  //                     } else if (role != "therapist") {
  //                       setState(() {
  //                         widget.wholelist[0][widget.accessname]['question']
  //                                 ["7"]['MultipleStair']['step$index']
  //                             ['stepwidth'] = value;
  //                       });
  //                     } else {
  //                       _showSnackBar(
  //                           "You can't change the other fields", context);
  //                     }

  //                     // print(widget.wholelist[0][widget.accessname]['question']
  //                     //     [7]);
  //                   },
  //                 ),
  //               ),
  //               Container(
  //                 width: MediaQuery.of(context).size.width * .35,
  //                 child: TextFormField(
  //                   initialValue: widget.wholelist[0][widget.accessname]
  //                           ['question']["7"]['MultipleStair']['step$index']
  //                       ['stepheight'],
  //                   keyboardType: TextInputType.phone,
  //                   decoration: InputDecoration(
  //                       focusedBorder: OutlineInputBorder(
  //                         borderSide: BorderSide(
  //                             color: colorsset["field${7}"], width: 1),
  //                       ),
  //                       enabledBorder: OutlineInputBorder(
  //                         borderSide: BorderSide(
  //                             width: 1, color: colorsset["field${7}"]),
  //                       ),
  //                       labelText: 'Step Height$index:'),
  //                   onChanged: (value) {
  //                     if (assessor == therapist && role == "therapist") {
  //                       setState(() {
  //                         widget.wholelist[0][widget.accessname]['question']
  //                                 ["7"]['MultipleStair']['step$index']
  //                             ['stepheight'] = value;
  //                       });
  //                     } else if (role != "therapist") {
  //                       setState(() {
  //                         widget.wholelist[0][widget.accessname]['question']
  //                                 ["7"]['MultipleStair']['step$index']
  //                             ['stepheight'] = value;
  //                       });
  //                     } else {
  //                       _showSnackBar(
  //                           "You can't change the other fields", context);
  //                     }

  //                     // print(widget.wholelist[0][widget.accessname]['question']
  //                     //     [7]);
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         SizedBox(height: 7)
  //       ],
  //     ),
  //   );
  // }

  // _listenn(int index, TextEditingController contrller, bool isListening) async {
  //   if (!isListening) {
  //     bool available = await _speech.initialize(
  //       onStatus: (val) {
  //         print('onStatus: $val');
  //         if (val == 'notListening') {
  //           setState(() {
  //             cur = true;
  //           });
  //         }
  //       },
  //       onError: (val) {
  //         print('onError: ${val.runtimeType}');
  //         if ('$val' ==
  //             "SpeechRecognitionError msg: error_no_match, permanent: true") {
  //           setState(() {
  //             isListening = false;
  //             // _textfield.selection = TextSelection.fromPosition(TextPosition(
  //             //     offset: widget
  //             //         .wholelist[0][widget.accessname]['question'][1]
  //             //             ['Recommendation']
  //             //         .length));
  //           });
  //         }
  //       },
  //     );
  //     print(available);
  //     if (available) {
  //       setState(() => isListening = true);

  //       _speech.listen(
  //         onResult: (val) {
  //           setState(() {
  //             print('listen');

  //             contrller.text = widget.wholelist[0][widget.accessname]
  //                     ['question'][index]['Recommendation'] +
  //                 " " +
  //                 val.recognizedWords;
  //           });
  //           // setState(() {
  //           //   _textfield.selection = TextSelection.fromPosition(TextPosition(
  //           //       offset: widget
  //           //               .wholelist[0][widget.accessname]['question'][1]
  //           //                   ['Recommendation']
  //           //               .length +
  //           //           _textfield.text.length));
  //           // });
  //         },
  //       );
  //       //
  //     }
  //   } else {
  //     print('stop');

  //     setState(() {
  //       isListening = false;
  //     });
  //     _speech.stop();
  //   }
  // }

}

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;
  final Image image;

  CustomDialog({this.title, this.description, this.buttonText, this.image});
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: dialogContent(context));
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 300,
          padding: EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              )
            ],
          ),
          child: Container(
            // margin:
            //     EdgeInsets.only(top: MediaQuery.of(context).size.height / 8),
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Container(
                    child: Image.asset(
                  "assets/gifmessage.gif",
                  // height: 125.0,
                  // width: 150.0,
                )),
                SizedBox(height: 15.2),
                Container(
                    // width: 200,
                    child: Image.asset(
                  "assets/download.png",
                  height: 70.0,
                  width: 70.0,
                )),
                SizedBox(height: 12.0),
                Text(description, style: TextStyle(fontSize: 16.0)),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FlatButton(
                    color: Color.fromRGBO(10, 80, 106, 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(
                          color: Color.fromRGBO(10, 80, 106, 1),
                        )),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child:
                        Text("Got it", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class NumericStepButton extends StatefulWidget {
  final int minValue;
  final int maxValue;
  int counterval;
  final ValueChanged<int> onChanged;

  NumericStepButton(
      {Key key,
      this.minValue = 0,
      this.maxValue = 10,
      this.onChanged,
      this.counterval})
      : super(key: key);

  @override
  State<NumericStepButton> createState() {
    return _NumericStepButtonState();
  }
}

class _NumericStepButtonState extends State<NumericStepButton> {
  int counter = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    counter = widget.counterval;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              Icons.remove,
              color: Colors.green,
            ),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 9.0),
            iconSize: 20.0,
            color: Colors.green,
            onPressed: () {
              setState(() {
                if (counter > widget.minValue) {
                  counter--;
                }
                widget.onChanged(counter);
              });
            },
          ),
          Container(
            // width: 20,
            decoration: BoxDecoration(
                border: Border(
              bottom:
                  BorderSide(width: 1.0, color: Color.fromRGBO(10, 80, 106, 1)),
            )),
            child: Text(
              '$counter',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.green,
            ),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 9.0),
            iconSize: 20.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {
                if (counter < widget.maxValue) {
                  counter++;
                }
                widget.onChanged(counter);
              });
            },
          ),
        ],
      ),
    );
  }
}
