import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tryapp/Assesment/Forms/LivingArrangements/livingArrangementbase.dart';
import 'package:tryapp/Assesment/Forms/LivingArrangements/livingArrangementpro.dart';
import 'package:tryapp/Assesment/Forms/viewVideo.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentrepo.dart';
import 'package:tryapp/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:path/path.dart';
import 'package:tryapp/productDetails.dart';

final _colorgreen = Color.fromRGBO(10, 80, 106, 1);

class LivingArrangementsUI extends StatefulWidget {
  String roomname, docID;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  LivingArrangementsUI(
      this.roomname, this.wholelist, this.accessname, this.docID);
  @override
  _LivingArrangementsUIState createState() => _LivingArrangementsUIState();
}

class _LivingArrangementsUIState extends State<LivingArrangementsUI> {
  stt.SpeechToText _speech;
  bool _isListening = false;
  TimeOfDay time1;
  TimeOfDay time2;
  TimeOfDay picked1;
  TimeOfDay picked2;

  bool available = false;
  Map<String, Color> colorsset = {};
  final firestoreInstance = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, TextEditingController> _controllers = {};
  Map<String, TextEditingController> _controllerstreco = {};
  Map<String, bool> isListening = {};
  bool cur = true;
  int roomatecount = 0;
  int flightcount = 0;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  String role, assessor, curUid, therapist;
  bool isColor = false, saveToForm = false;
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
  List<Map<String, dynamic>> assistiveDevice = [
    {"name": "SC/Quad", "description": "", "url": ""},
    {"name": "Cane/Std", "description": "", "url": ""},
    {
      "name": "Walker",
      "description":
          "A walker is a type of mobility aid used to help people who are still able to walk (e.g., don't require a wheelchair) yet need assistance.\n\nIt is a four-legged frame that allows a person to lean on it for balance, support, and rest. \n\nWalkers are usually made out of aluminum so they are light enough to be picked up and moved easily. \n\nThey often have comfort grips made of foam, gel, or rubber to enhance the user's comfort. The tips of the legs are typically covered with rubber caps that are designed to prevent slipping and improve stability.",
      "url": "https://www.aafp.org/afp/2011/0815/hi-res/afp20110815p405-f6.jpg"
    },
    {
      "name": "Front Wheel Walker",
      "description":
          "The greatest benefit to using a front wheel walker is increased mobility.\n\nWith wheels on the front end, you don’t have to lift the walker every time you take a step. If you don’t have the upper body strength or endurance to use a basic walker comfortably, a wheeled option can still provide balance but makes movement easier.\n\nYou can move faster with a front wheel walker, but it’s still grounded by the two back legs. Many products offer slip-resistant caps or glide caps for the rear legs.\n\nSlip-resistant caps are made of a material like rubber, which prevents the walker from slipping on smooth surfaces. Glide caps, or glides, help a walker move more smoothly and quickly across a surface.",
      "url":
          "https://5.imimg.com/data5/WJ/YH/BR/SELLER-66068728/front-wheel-walker-500x500.jpg"
    },
    {"name": "4 Whl. Walker", "description": "", "url": ""},
    {"name": "Manual Whl Chair", "description": "", "url": ""},
    {"name": "Power W/c", "description": "", "url": ""},
    {"name": "Crutches", "description": "", "url": ""},
    {"name": "Scooter", "description": "", "url": ""}
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    time1 = TimeOfDay.now();
    time2 = TimeOfDay.now();
    _speech = stt.SpeechToText();
    for (int i = 0;
        i < widget.wholelist[1][widget.accessname]['question'].length;
        i++) {
      _controllers["field${i + 1}"] = TextEditingController();
      _controllerstreco["field${i + 1}"] = TextEditingController();
      isListening["field${i + 1}"] = false;
      _controllers["field${i + 1}"].text = widget.wholelist[1]
          [widget.accessname]['question']["${i + 1}"]['Recommendation'];
      _controllerstreco["field${i + 1}"].text =
          '${widget.wholelist[1][widget.accessname]['question']["${i + 1}"]['Recommendationthera']}';
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
    getRole();
    getAssessData();
    setinitialsdata();
    print("RoomName: ${widget.roomname}");
  }

  Future<Null> selectTime1(BuildContext context) async {
    if (assessor == curUid) {
      picked1 = await showTimePicker(context: context, initialTime: time1);
      if (picked1 != null) {
        setState(() {
          time1 = picked1;
          widget.wholelist[1][widget.accessname]['question']["4"]['Alone']
              ['From'] = '${time1.hour % 12}:${time1.minute % 60}';
          // widget.wholelist[1][widget.accessname]['question']["4"]['Alone']
          //     ['From'] = time1;
        });
      }
    } else if (role != "therapist") {
      picked1 = await showTimePicker(context: context, initialTime: time1);
      if (picked1 != null) {
        setState(() {
          time1 = picked1;
          widget.wholelist[1][widget.accessname]['question']["4"]['Alone']
              ['From'] = '${time1.hour % 12}:${time1.minute % 60}';
          // widget.wholelist[1][widget.accessname]['question']["4"]['Alone']
          //     ['From'] = time1;
        });
      }
    } else {
      _showSnackBar("You can't change the other fields", context);
    }
  }

  Future<Null> selectTime2(BuildContext context) async {
    if (assessor == curUid) {
      picked2 = await showTimePicker(context: context, initialTime: time2);
      if (picked2 != null) {
        setState(() {
          time2 = picked2;
          widget.wholelist[1][widget.accessname]['question']["4"]['Alone']
              ['Till'] = "${time2.hour % 12}:${time2.minute % 60}";
          // widget.wholelist[1][widget.accessname]['question']["4"]['Alone']
          //     ['Till'] = time2;
        });
      }
    } else if (role != "therapist") {
      picked2 = await showTimePicker(context: context, initialTime: time2);
      if (picked2 != null) {
        setState(() {
          time2 = picked2;
          widget.wholelist[1][widget.accessname]['question']["4"]['Alone']
              ['Till'] = "${time2.hour % 12}:${time2.minute % 60}";
          // widget.wholelist[1][widget.accessname]['question']["4"]['Alone']
          //     ['Till'] = time2;
        });
      }
    } else {
      _showSnackBar("You can't change the other fields", context);
    }
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
              videoUrl = widget.wholelist[1][widget.accessname]["videos"]["url"]
                      .toString() ??
                  "";
              videoName = widget.wholelist[1][widget.accessname]["videos"]
                          ["name"]
                      .toString() ??
                  "";
            }));
  }

  Future<void> setinitialsdata() async {
    if (widget.wholelist[1][widget.accessname].containsKey('isSave')) {
    } else {
      widget.wholelist[1][widget.accessname]["isSave"] = true;
    }
    if (widget.wholelist[1][widget.accessname].containsKey('videos')) {
      if (widget.wholelist[1][widget.accessname]['videos']
          .containsKey('name')) {
      } else {
        widget.wholelist[1][widget.accessname]['videos']['name'] = "";
      }
      if (widget.wholelist[1][widget.accessname]['videos'].containsKey('url')) {
      } else {
        widget.wholelist[1][widget.accessname]['videos']['url'] = "";
      }
    } else {
      // print('Yes,it is');

      widget.wholelist[1][widget.accessname]
          ["videos"] = {'name': '', 'url': ''};
    }

    if (widget.wholelist[1][widget.accessname]['question']["2"]
        .containsKey('Modetrnas')) {
    } else {
      setState(() {
        widget.wholelist[1][widget.accessname]['question']["2"]['Modetrnas'] =
            '';
        widget.wholelist[1][widget.accessname]['question']["2"]
            ['Modetrnasother'] = '';
      });
    }
    if (widget.wholelist[1][widget.accessname].containsKey('videos')) {
    } else {
      setState(() {
        widget.wholelist[1][widget.accessname]['videos'] = [];
      });
    }

    if (widget.wholelist[1][widget.accessname]['question']["4"]
        .containsKey('Alone')) {
      setState(() {
        if (widget.wholelist[1][widget.accessname]['question']["4"]['Alone']
            .containsKey('From')) {
          // time1 = int.parse(wholelist[1][widget.accessname]['question']["4"]
          //     ['Alone']['From']);
          if (widget.wholelist[1][widget.accessname]['question']["4"]['Alone']
                  ['From'] !=
              "") {
            time1 = TimeOfDay(
                hour: int.parse(widget.wholelist[1][widget.accessname]
                        ['question']["4"]['Alone']['From']
                    .split(":")[0]),
                minute: int.parse(widget.wholelist[1][widget.accessname]
                        ['question']["4"]['Alone']['From']
                    .split(":")[1]));
          }
        }
        if (widget.wholelist[1][widget.accessname]['question']["4"]['Alone']
            .containsKey('Till')) {
          if (widget.wholelist[1][widget.accessname]['question']["4"]['Alone']
                  ['Till'] !=
              "") {
            time2 = TimeOfDay(
                hour: int.parse(widget.wholelist[1][widget.accessname]
                        ['question']["4"]['Alone']['Till']
                    .split(":")[0]),
                minute: int.parse(widget.wholelist[1][widget.accessname]
                        ['question']["4"]['Alone']['Till']
                    .split(":")[1]));
          }
        }
      });
    } else {
      setState(() {
        widget.wholelist[1][widget.accessname]['question']["4"]['Alone'] = {};
      });
    }

    if (widget.wholelist[1][widget.accessname]['question']['5']
        .containsKey('toggle')) {
    } else {
      widget.wholelist[1][widget.accessname]['question']['5']
          ['toggle'] = <bool>[true, false];
    }

    if (widget.wholelist[1][widget.accessname]['question']["5"]
        .containsKey('Roomate')) {
      if (widget.wholelist[1][widget.accessname]['question']["5"]['Roomate']
          .containsKey('count')) {
        setState(() {
          roomatecount = widget.wholelist[1][widget.accessname]['question']["5"]
              ['Roomate']['count'];
        });
      }
    } else {
      // print('Yes,it is');
      setState(() {
        widget.wholelist[1][widget.accessname]['question']["5"]['Roomate'] = {};
      });
    }

    if (widget.wholelist[1][widget.accessname]['question']['7']
        .containsKey('toggle')) {
    } else {
      widget.wholelist[1][widget.accessname]['question']['7']
          ['toggle'] = <bool>[true, false];
    }

    if (widget.wholelist[1][widget.accessname]['question']["11"]
        .containsKey('Flights')) {
      if (widget.wholelist[1][widget.accessname]['question']["11"]['Flights']
          .containsKey('count')) {
        setState(() {
          flightcount = widget.wholelist[1][widget.accessname]['question']["11"]
              ['Flights']["count"];
        });
      }
    } else {
      // print('hello');
      setState(() {
        widget.wholelist[1][widget.accessname]['question']["11"]
            ['Flights'] = {};
        widget.wholelist[1][widget.accessname]['question']["11"]['Answer'] = 0;
      });
    }

    if (widget.wholelist[1][widget.accessname]['question']['12']
        .containsKey('toggle')) {
    } else {
      widget.wholelist[1][widget.accessname]['question']['12']
          ['toggle'] = <bool>[true, false];
    }
  }

  getRole() async {
    User user = await _auth.currentUser;
    var runtimeType;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get()
        .then((value) => setState(() {
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
            }));
  }

  setdata(index, value, que) {
    widget.wholelist[1][widget.accessname]['question']["$index"]['Question'] =
        que;
  }

  setreco(index, value) {
    setState(() {
      widget.wholelist[1][widget.accessname]['question']["$index"]
          ['Recommendation'] = value;
    });
  }

  getvalue(index) {
    return widget.wholelist[1][widget.accessname]['question']["$index"]
        ['Answer'];
  }

  getreco(index) {
    return widget.wholelist[1][widget.accessname]['question']["$index"]
        ['Recommendation'];
  }

  setprio(index, value) {
    setState(() {
      widget.wholelist[1][widget.accessname]['question']["$index"]['Priority'] =
          value;
    });
  }

  getprio(index) {
    return widget.wholelist[1][widget.accessname]['question']["$index"]
        ['Priority'];
  }

  setrecothera(index, value) {
    // final isValid = _formKey.currentState.validate();
    // if (!isValid) {
    //   return;
    // } else {
    setState(() {
      widget.wholelist[1][widget.accessname]['question']["$index"]
          ['Recommendationthera'] = value;
    });
    // }
  }

  getrecothera(index) {
    return widget.wholelist[1][widget.accessname]['question']["$index"]
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

  @override
  Widget build(BuildContext context) {
    LivingArrangementsProvider assesspro =
        Provider.of<LivingArrangementsProvider>(context);

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
          widget.wholelist[1][widget.accessname]["videos"]["url"] = videoUrl;
          widget.wholelist[1][widget.accessname]["videos"]["name"] = videoName;
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
            assesspro.addVideo(pickedVideo.path);
            // FocusScope.of(context).requestFocus(new FocusNode());
            setState(() {
              upload(File(pickedVideo?.path));
            });
          } else {
            Navigator.pop(context);
            setState(() {});
            final snackBar = SnackBar(content: Text('Video Not Selected!'));
            assesspro.notifyListeners();
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          final pickedVideo =
              await ImagePicker().pickVideo(source: ImageSource.gallery);
          if (pickedVideo != null) {
            Navigator.pop(context);
            assesspro.addVideo(pickedVideo.path);
            setState(() {
              upload(File(pickedVideo?.path));
            });
          } else {
            Navigator.pop(context);
            setState(() {});
            final snackBar = SnackBar(content: Text('Video Not Selected!'));
            assesspro.notifyListeners();
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

      assesspro.notifyListeners();
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

    void _listen(index) async {
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
          setState(() {
            _isListening = true;
            // colorsset["field$index"] = Colors.red;
            isListening['field$index'] = true;
          });
          _speech.listen(
            onResult: (val) => setState(() {
              _controllers["field$index"].text = widget.wholelist[1]
                          [widget.accessname]['question']["$index"]
                      ['Recommendation'] +
                  " " +
                  val.recognizedWords;
            }),
          );
        }
      } else {
        setState(() {
          _isListening = false;
          isListening['field$index'] = false;
          colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
        });
        _speech.stop();
      }
      print(isListening);
    }

    setdatalisten(index) {
      setState(() {
        widget.wholelist[1][widget.accessname]['question']["$index"]
            ['Recommendation'] = _controllers["field$index"].text;
        cur = !cur;
      });
    }

    void _listenthera(index) async {
      if (!_isListening) {
        bool available = await _speech.initialize(
          onStatus: (val) {
            print('onStatus: $val');
            setState(() {
              // _isListening = false;
              //
            });
          },
          onError: (val) => print('onError: $val'),
        );
        if (available) {
          setState(() {
            _isListening = true;
            // colorsset["field$index"] = Colors.red;
            isListening['field$index'] = true;
          });
          _speech.listen(
            onResult: (val) => setState(() {
              _controllerstreco["field$index"].text = widget.wholelist[1]
                          [widget.accessname]['question']["$index"]
                      ['Recommendationthera'] +
                  " " +
                  val.recognizedWords;
            }),
          );
        }
      } else {
        setState(() {
          _isListening = false;
          isListening['field$index'] = false;
          colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
        });
        _speech.stop();
      }
    }

    setdatalistenthera(index) {
      setState(() {
        widget.wholelist[1][widget.accessname]['question']["$index"]
            ['Recommendationthera'] = _controllerstreco["field$index"].text;
        cur = !cur;
      });
    }

    Widget getrecowid(index, BuildContext context) {
      if (widget.wholelist[1][widget.accessname]["question"]["$index"]
              ["Recommendationthera"] !=
          "") {
        setState(() {
          isColor = true;
          // saveToForm = true;
          // widget.wholelist[1][widget.accessname]["isSave"] = saveToForm;
        });
      } else {
        setState(() {
          isColor = false;
          // saveToForm = false;
          // widget.wholelist[1][widget.accessname]["isSave"] = saveToForm;
        });
      }
      if (falseIndex == -1) {
        if (widget.wholelist[1][widget.accessname]["question"]["$index"]
                ["Recommendationthera"] !=
            "") {
          setState(() {
            saveToForm = true;
            trueIndex = index;
            widget.wholelist[1][widget.accessname]["isSave"] = true;
          });
        } else {
          setState(() {
            saveToForm = false;
            falseIndex = index;
            widget.wholelist[1][widget.accessname]["isSave"] = false;
          });
        }
      } else {
        if (index == falseIndex) {
          if (widget.wholelist[1][widget.accessname]["question"]["$index"]
                  ["Recommendationthera"] !=
              "") {
            setState(() {
              widget.wholelist[1][widget.accessname]["isSave"] = true;
              falseIndex = -1;
            });
          } else {
            setState(() {
              widget.wholelist[1][widget.accessname]["isSave"] = false;
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
              setrecothera(index, value);
              // setState(() {
              //   // print("Color Changed");
              //   if (value.length != 0) {
              //     isColor = true;
              //   } else {
              //     isColor = false;
              //   }
              // });
            },
            controller: _controllerstreco["field$index"],
            cursorColor: (isColor) ? Colors.green : Colors.red,
            decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: (isColor) ? Colors.green : Colors.red, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: (isColor) ? Colors.green : Colors.red, width: 1),
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
                        heroTag: null,
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
                    },
                    groupValue: getprio(index),
                  ),
                  Text('1'),
                  Radio(
                    value: '2',
                    onChanged: (value) {
                      setState(() {
                        setprio(index, value);
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

    Widget getrecomain(int index, bool isthera, BuildContext context) {
      return SingleChildScrollView(
        // reverse: true,
        child: Container(
          // color: Colors.red,
          child: Column(
            children: [
              Container(
                child: TextFormField(
                  maxLines: null,
                  showCursor: cur,
                  controller: _controllers["field$index"],
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: colorsset["field$index"], width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 1, color: colorsset["field$index"]),
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
                                    _listen(index);
                                    setdatalisten(index);
                                  } else if (role != "therapist") {
                                    _listen(index);
                                    setdatalisten(index);
                                  } else {
                                    _showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                              ),
                            ),
                          ),
                        ]),
                      ),
                      labelText: 'Comments'),
                  onChanged: (value) {
                    // print(widget.accessname);
                    if (assessor == therapist && role == "therapist") {
                      setreco(index, value);
                      FocusScope.of(context).requestFocus();
                      new TextEditingController().clear();
                    } else if (role != "therapist") {
                      setreco(index, value);
                      FocusScope.of(context).requestFocus();
                      new TextEditingController().clear();
                    } else {
                      _showSnackBar(
                          "You can't change the other fields", context);
                    }
                  },
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

    Widget flightcountwidget(index, BuildContext context) {
      return Container(
        child: Column(
          children: [
            Container(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: TextFormField(
                  initialValue: widget.wholelist[1][widget.accessname]
                      ['question']["11"]['Flights']["flight$index"]["flight"],
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: colorsset["field${7}"], width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 1, color: colorsset["field${7}"]),
                      ),
                      labelText: 'Number of steps in flight$index:'),
                  onChanged: (value) {
                    FocusScope.of(context).requestFocus();
                    new TextEditingController().clear();
                    if (assessor == therapist && role == "therapist") {
                      setState(() {
                        widget.wholelist[1][widget.accessname]['question']["11"]
                            ['Flights']['flight$index']["flight"] = value;
                      });
                    } else if (role != "therapist") {
                      setState(() {
                        widget.wholelist[1][widget.accessname]['question']["11"]
                            ['Flights']['flight$index']["flight"] = value;
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
            ),
            SizedBox(height: 7)
          ],
        ),
      );
    }

    Widget roomatecountwidget(index, BuildContext context) {
      return Container(
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * .3,
                    child: Text('Relationship',
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
                          child: Text('Spouse'),
                          value: 'Spouse',
                        ),
                        DropdownMenuItem(
                          child: Text('Son'),
                          value: 'Son',
                        ),
                        DropdownMenuItem(
                          child: Text('Daughter'),
                          value: 'Daughter',
                        ),
                        DropdownMenuItem(
                          child: Text('Grand-Son'),
                          value: 'Grand-Son',
                        ),
                        DropdownMenuItem(
                          child: Text('Daughter-In-Law'),
                          value: 'Daughter-In-Law',
                        ),
                        DropdownMenuItem(
                          child: Text('Grand-Daughter'),
                          value: 'Grand-Daughter',
                        ),
                        DropdownMenuItem(
                          child: Text('Son-In-Law'),
                          value: 'Son-In-Law',
                        ),
                        DropdownMenuItem(
                          child: Text('Niece'),
                          value: 'Niece',
                        ),
                        DropdownMenuItem(
                          child: Text('Family-other'),
                          value: 'Family-other',
                        ),
                        DropdownMenuItem(
                          child: Text('Acquaintance'),
                          value: 'Acquaintance',
                        ),
                        DropdownMenuItem(
                          child: Text('Caregiver'),
                          value: 'Caregiver',
                        ),
                        DropdownMenuItem(
                          child: Text('Professional'),
                          value: 'Professional',
                        ),
                        DropdownMenuItem(
                          child: Text('Friend'),
                          value: 'Friend',
                        ),
                        DropdownMenuItem(
                          child: Text('Nephew'),
                          value: 'Nephew',
                        ),
                      ],
                      onChanged: (value) {
                        FocusScope.of(context).requestFocus();
                        new TextEditingController().clear();
                        // print(widget.accessname);
                        if (assessor == therapist && role == "therapist") {
                          setState(() {
                            widget.wholelist[1][widget.accessname]['question']
                                    ["5"]['Roomate']['roomate$index']
                                ['Relationship'] = value;
                          });
                        } else if (role != "therapist") {
                          setState(() {
                            widget.wholelist[1][widget.accessname]['question']
                                    ["5"]['Roomate']['roomate$index']
                                ['Relationship'] = value;
                          });
                        } else {
                          _showSnackBar(
                              "You can't change the other fields", context);
                        }
                      },
                      value: widget.wholelist[1][widget.accessname]['question']
                          ["5"]['Roomate']['roomate$index']['Relationship'])
                ],
              ),
            ),
            Container(
              child: SingleChildScrollView(
                // reverse: true,
                child: Container(
                  // color: Colors.yellow,
                  child: Column(
                    children: [
                      Container(
                        child: TextFormField(
                          showCursor: cur,
                          initialValue: widget.wholelist[1][widget.accessname]
                                  ['question']["5"]['Roomate']['roomate$index']
                              ['FirstName'],
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: colorsset["field$index"], width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: colorsset["field$index"]),
                              ),
                              labelText: 'First Name'),
                          onChanged: (value) {
                            FocusScope.of(context).requestFocus();
                            new TextEditingController().clear();
                            // print(widget.accessname);
                            if (assessor == therapist && role == "therapist") {
                              widget.wholelist[1][widget.accessname]['question']
                                      ["5"]['Roomate']['roomate$index']
                                  ['FirstName'] = value;
                            } else if (role != "therapist") {
                              widget.wholelist[1][widget.accessname]['question']
                                      ["5"]['Roomate']['roomate$index']
                                  ['FirstName'] = value;
                            } else {
                              _showSnackBar(
                                  "You can't change the other fields", context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: SingleChildScrollView(
                // reverse: true,
                child: Container(
                  // color: Colors.yellow,
                  child: Column(
                    children: [
                      Container(
                        child: TextFormField(
                          showCursor: cur,
                          initialValue: widget.wholelist[1][widget.accessname]
                                  ['question']["5"]['Roomate']['roomate$index']
                              ['LastName'],
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: colorsset["field$index"], width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: colorsset["field$index"]),
                              ),
                              labelText: 'Last Name'),
                          onChanged: (value) {
                            FocusScope.of(context).requestFocus();
                            new TextEditingController().clear();
                            // print(widget.accessname);
                            if (assessor == therapist && role == "therapist") {
                              widget.wholelist[1][widget.accessname]['question']
                                      ["5"]['Roomate']['roomate$index']
                                  ['LastName'] = value;
                            } else if (role != "therapist") {
                              widget.wholelist[1][widget.accessname]['question']
                                      ["5"]['Roomate']['roomate$index']
                                  ['LastName'] = value;
                            } else {
                              _showSnackBar(
                                  "You can't change the other fields", context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
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
              : Text('Living Arrangements'),
          automaticallyImplyLeading: false,
          backgroundColor: _colorgreen,
          actions: [
            IconButton(
              icon: Icon(Icons.done_all, color: Colors.white),
              onPressed: () async {
                try {
                  var test = widget.wholelist[1][widget.accessname]["complete"];
                  for (int i = 0;
                      i <
                          widget.wholelist[1][widget.accessname]['question']
                              .length;
                      i++) {
                    setdatalisten(i + 1);
                    setdatalistenthera(i + 1);
                  }
                  if (role == "therapist") {
                    NewAssesmentRepository().setLatestChangeDate(widget.docID);
                    NewAssesmentRepository()
                        .setForm(widget.wholelist, widget.docID);
                    Navigator.pop(
                        context, widget.wholelist[1][widget.accessname]);
                  } else {
                    NewAssesmentRepository().setLatestChangeDate(widget.docID);
                    NewAssesmentRepository()
                        .setForm(widget.wholelist, widget.docID);
                    Navigator.pop(
                        context, widget.wholelist[1][widget.accessname]);
                  }
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
                  //       // width: MediaQuery.of(context).size.width / 10,
                  //       padding: EdgeInsets.all(25),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Container(
                  //             width: MediaQuery.of(context).size.width / 1.6,
                  //             child: Text(
                  //               '${widget.roomname} Details',
                  //               style: TextStyle(
                  //                 fontSize: 25,
                  //                 fontWeight: FontWeight.bold,
                  //                 color: Color.fromRGBO(10, 80, 106, 1),
                  //               ),
                  //             ),
                  //           ),
                  //           Container(
                  //             alignment: Alignment.topRight,
                  //             width: 45,
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
                  // SizedBox(height: 10),
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
                                                  widget.wholelist[1]
                                                          [widget.accessname]
                                                      ["videos"]["name"] = "";
                                                  widget.wholelist[1]
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
                                                  widget.wholelist[1]
                                                          [widget.accessname]
                                                      ["videos"]["name"] = "";
                                                  widget.wholelist[1]
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
                                    SizedBox(
                                      width: 10.0,
                                    )
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(),
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Column(children: [
                      // SizedBox(
                      //   height: 15,
                      // ),
                      // Divider(
                      //   height: dividerheight,
                      //   color: Color.fromRGBO(10, 80, 106, 1),
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * .5,
                            child: Text('House Type',
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
                                  child: Text('Apartment'),
                                  value: 'Apartment',
                                ),
                                DropdownMenuItem(
                                  child: Text('House'),
                                  value: 'House',
                                ),
                                DropdownMenuItem(
                                  child: Text('Condominium'),
                                  value: 'Condominium',
                                ),
                                DropdownMenuItem(
                                  child: Text('Other'),
                                  value: 'Other',
                                ),
                              ],
                              onChanged: (value) {
                                FocusScope.of(context).requestFocus();
                                new TextEditingController().clear();
                                if (assessor == therapist &&
                                    role == "therapist") {
                                  assesspro.setdata(1, value, 'House Type');
                                } else if (role != "therapist" &&
                                    (role == "patient" ||
                                        role == "nurse/case manager")) {
                                  assesspro.setdata(1, value, 'House Type');
                                } else {
                                  _showSnackBar(
                                      "You can't change the other fields",
                                      context);
                                }
                              },
                              value: getvalue(1),
                            ),
                          )
                        ],
                      ),
                      (getvalue(1) == "Other")
                          ? getrecomain(1, false, context)
                          : SizedBox(),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * .5,
                            child: Text('Number of Levels',
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
                                  child: Text('1'),
                                  value: '1',
                                ),
                                DropdownMenuItem(
                                  child: Text('2'),
                                  value: '2',
                                ),
                                DropdownMenuItem(
                                  child: Text('3'),
                                  value: '3',
                                ),
                                DropdownMenuItem(
                                  child: Text('4'),
                                  value: '4',
                                ),
                                DropdownMenuItem(
                                  child: Text('5'),
                                  value: '5',
                                ),
                                DropdownMenuItem(
                                  child: Text('Other'),
                                  value: 'Other',
                                ),
                              ],
                              onChanged: (value) {
                                FocusScope.of(context).requestFocus();
                                new TextEditingController().clear();
                                // print(widget.accessname);
                                if (assessor == therapist &&
                                    role == "therapist") {
                                  assesspro.setdata(
                                      2, value, 'Number of Levels');
                                } else if (role != "therapist") {
                                  assesspro.setdata(
                                      2, value, 'Number of Levels');
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
                      // (getvalue(2) == "Other")
                      //     ? getrecomain(2, false)
                      //     : SizedBox(),
                      (getvalue(2) != '' &&
                              getvalue(2) != '0' &&
                              getvalue(2) != '1')
                          ? Container(
                              padding: EdgeInsets.only(top: 15),
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
                                              .65,
                                          child: Text('Mode Of Transportation',
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
                                              child: Text('Stairs'),
                                              value: 'Stairs',
                                            ),
                                            DropdownMenuItem(
                                              child: Text('Elevator'),
                                              value: 'Elevator',
                                            ),
                                            DropdownMenuItem(
                                              child: Text('Ramp'),
                                              value: 'Ramp',
                                            ),
                                            DropdownMenuItem(
                                              child: Text('Tramp'),
                                              value: 'Tramp',
                                            ),
                                            DropdownMenuItem(
                                              child: Text('Other'),
                                              value: 'Other',
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              if (assessor == therapist &&
                                                  role == "therapist") {
                                                widget.wholelist[1]
                                                            [widget.accessname]
                                                        ['question']["2"]
                                                    ['Modetrnas'] = value;
                                              } else if (role != "therapist") {
                                                widget.wholelist[1]
                                                            [widget.accessname]
                                                        ['question']["2"]
                                                    ['Modetrnas'] = value;
                                              } else {
                                                _showSnackBar(
                                                    "You can't change the other fields",
                                                    context);
                                              }
                                            });
                                            // setdata(
                                            //   2,
                                            //   value,
                                            //   'Mode Of Transportation'
                                            // );
                                          },
                                          value: widget.wholelist[1]
                                                  [widget.accessname]
                                              ['question']["2"]['Modetrnas'],
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  (widget.wholelist[1][widget.accessname]
                                                      ['question']["2"]
                                                  ['Modetrnas'] ==
                                              'Other' ||
                                          getvalue(2) == "Other")
                                      ? getrecomain(2, false, context)
                                      : SizedBox(),
                                ],
                              ),
                            )
                          : SizedBox(),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * .5,
                            child: Text('Living on Level',
                                style: TextStyle(
                                  color: Color.fromRGBO(10, 80, 106, 1),
                                  fontSize: 20,
                                )),
                          ),
                          Container(
                            child: DropdownButton(
                              items: [
                                DropdownMenuItem(child: Text('--'), value: ''),
                                DropdownMenuItem(
                                  child: Text('1'),
                                  value: '1',
                                ),
                                DropdownMenuItem(
                                  child: Text('2'),
                                  value: '2',
                                ),
                                DropdownMenuItem(
                                  child: Text('3'),
                                  value: '3',
                                ),
                                DropdownMenuItem(
                                  child: Text('4'),
                                  value: '4',
                                ),
                                DropdownMenuItem(
                                  child: Text('5'),
                                  value: '5',
                                ),
                                DropdownMenuItem(
                                  child: Text('6'),
                                  value: '6',
                                ),
                                DropdownMenuItem(
                                  child: Text('7'),
                                  value: '7',
                                ),
                                DropdownMenuItem(
                                  child: Text('Other'),
                                  value: 'Other',
                                ),
                              ],
                              onChanged: (value) {
                                FocusScope.of(context).requestFocus();
                                new TextEditingController().clear();
                                // print(widget.accessname);
                                if (assessor == therapist &&
                                    role == "therapist") {
                                  assesspro.setdata(
                                      3, value, 'Living on Level');
                                } else if (role != "therapist") {
                                  assesspro.setdata(
                                      3, value, 'Living on Level');
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
                      // SizedBox(height: 5),
                      (getvalue(3) == 'Other')
                          ? getrecomain(3, false, context)
                          : SizedBox(),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * .5,
                            child: Text('Living Arrangements',
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
                                  child: Text('Alone'),
                                  value: 'Alone',
                                ),
                                DropdownMenuItem(
                                  child: Text('Alone Sometimes'),
                                  value: 'Alone Sometimes',
                                ),
                                DropdownMenuItem(
                                  child: Text('Never Alone'),
                                  value: 'Never Alone',
                                ),
                              ],
                              onChanged: (value) {
                                FocusScope.of(context).requestFocus();
                                new TextEditingController().clear();
                                // print(widget.accessname);
                                if (assessor == therapist &&
                                    role == "therapist") {
                                  assesspro.setdata(
                                      4, value, 'Living Arrangements');
                                } else if (role != "therapist") {
                                  assesspro.setdata(
                                      4, value, 'Living Arrangements');
                                } else {
                                  _showSnackBar(
                                      "You can't change the other fields",
                                      context);
                                }
                              },
                              value: getvalue(4),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 5),
                      (getvalue(4) != 'Never Alone' && getvalue(4) != '')
                          ? (getvalue(4) == 'Alone')
                              ? getrecomain(4, true, context)
                              : Container(
                                  padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 7,
                                      ),
                                      Container(
                                        child: Row(
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .41,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'From:',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.fromLTRB(
                                                        3, 0, 0, 0),
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    4)),
                                                        shape:
                                                            BoxShape.rectangle,
                                                        border: Border.all(
                                                          color: _colorgreen,
                                                          width: 1,
                                                        )),
                                                    child: Row(children: [
                                                      Container(
                                                        // color: Colors.red,
                                                        width: 35,
                                                        child: IconButton(
                                                          icon:
                                                              Icon(Icons.alarm),
                                                          onPressed: () {
                                                            selectTime1(
                                                                context);
                                                          },
                                                        ),
                                                      ),
                                                      Text(
                                                        '${time1.hour}:${time1.minute}',
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                    ]),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .39,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Till:',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.fromLTRB(
                                                        3, 0, 0, 0),
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    4)),
                                                        shape:
                                                            BoxShape.rectangle,
                                                        border: Border.all(
                                                          color: _colorgreen,
                                                          width: 1,
                                                        )),
                                                    child: Row(children: [
                                                      Container(
                                                          // color: Colors.red,
                                                          width: 35,
                                                          child: IconButton(
                                                            icon: Icon(
                                                                Icons.alarm),
                                                            onPressed: () {
                                                              selectTime2(
                                                                  context);
                                                              // print(time2);
                                                            },
                                                          )),
                                                      Text(
                                                        '${time2.hour}:${time2.minute}',
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                    ]),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                          : SizedBox(),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * .5,
                            child: Text('Has Room-mate?',
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
                                child: Text('Yes'),
                                value: 'Yes',
                              ),
                              DropdownMenuItem(
                                child: Text('No'),
                                value: 'No',
                              ),
                            ],
                            onChanged: (value) {
                              FocusScope.of(context).requestFocus();
                              new TextEditingController().clear();
                              // print(widget.accessname);
                              if (assessor == therapist &&
                                  role == "therapist") {
                                assesspro.setdata(5, value, 'Has Room-mate?');
                              } else if (role != "therapist") {
                                assesspro.setdata(5, value, 'Has Room-mate?');
                              } else {
                                _showSnackBar(
                                    "You can't change the other fields",
                                    context);
                              }
                            },
                            value: getvalue(5),
                          )
                        ],
                      ),
                      SizedBox(height: 15),
                      (getvalue(5) == 'Yes')
                          ? SingleChildScrollView(
                              // reverse: true,
                              child: Container(
                                // color: Colors.yellow,
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
                                            child: Text('Number of Room-mates',
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
                                                  .35,
                                              child: NumericStepButton(
                                                counterval: roomatecount,
                                                onChanged: (value) {
                                                  if (assessor == therapist &&
                                                      role == "therapist") {
                                                    setState(() {
                                                      widget.wholelist[1][widget
                                                                      .accessname]
                                                                  ['question']
                                                              ["5"]['Roomate']
                                                          ['count'] = value;
                                                      roomatecount = widget
                                                                      .wholelist[1]
                                                                  [
                                                                  widget
                                                                      .accessname]
                                                              ['question']["5"]
                                                          ['Roomate']['count'];
                                                      if (value > 0) {
                                                        widget.wholelist[1][widget
                                                                        .accessname]
                                                                    ['question']
                                                                ["5"]['Roomate']
                                                            [
                                                            'roomate$value'] = {
                                                          'Relationship': '',
                                                          'FirstName': '',
                                                          'LastName': '',
                                                        };

                                                        if (widget.wholelist[1][
                                                                widget
                                                                    .accessname]
                                                                ['question']
                                                                ["5"]['Roomate']
                                                            .containsKey(
                                                                'roomate${value + 1}')) {
                                                          widget.wholelist[1][
                                                                  widget
                                                                      .accessname]
                                                                  ['question']
                                                                  ["5"]
                                                                  ['Roomate']
                                                              .remove(
                                                                  'roomate${value + 1}');
                                                        }
                                                      } else if (value == 0) {
                                                        if (widget.wholelist[1][
                                                                widget
                                                                    .accessname]
                                                                ['question']
                                                                ["5"]['Roomate']
                                                            .containsKey(
                                                                'roomate${value + 1}')) {
                                                          widget.wholelist[1][
                                                                  widget
                                                                      .accessname]
                                                                  ['question']
                                                                  ["5"]
                                                                  ['Roomate']
                                                              .remove(
                                                                  'roomate${value + 1}');
                                                        }
                                                      }
                                                    });
                                                  } else if (role !=
                                                      "therapist") {
                                                    setState(() {
                                                      widget.wholelist[1][widget
                                                                      .accessname]
                                                                  ['question']
                                                              ["5"]['Roomate']
                                                          ['count'] = value;
                                                      roomatecount = widget
                                                                      .wholelist[1]
                                                                  [
                                                                  widget
                                                                      .accessname]
                                                              ['question']["5"]
                                                          ['Roomate']['count'];
                                                      if (value > 0) {
                                                        widget.wholelist[1][widget
                                                                        .accessname]
                                                                    ['question']
                                                                ["5"]['Roomate']
                                                            [
                                                            'roomate$value'] = {
                                                          'Relationship': '',
                                                          'FirstName': '',
                                                          'LastName': '',
                                                        };

                                                        if (widget.wholelist[1][
                                                                widget
                                                                    .accessname]
                                                                ['question']
                                                                ["5"]['Roomate']
                                                            .containsKey(
                                                                'roomate${value + 1}')) {
                                                          widget.wholelist[1][
                                                                  widget
                                                                      .accessname]
                                                                  ['question']
                                                                  ["5"]
                                                                  ['Roomate']
                                                              .remove(
                                                                  'roomate${value + 1}');
                                                        }
                                                      } else if (value == 0) {
                                                        if (widget.wholelist[1][
                                                                widget
                                                                    .accessname]
                                                                ['question']
                                                                ["5"]['Roomate']
                                                            .containsKey(
                                                                'roomate${value + 1}')) {
                                                          widget.wholelist[1][
                                                                  widget
                                                                      .accessname]
                                                                  ['question']
                                                                  ["5"]
                                                                  ['Roomate']
                                                              .remove(
                                                                  'roomate${value + 1}');
                                                        }
                                                      }
                                                    });
                                                  } else {
                                                    _showSnackBar(
                                                        "You can't change the other fields",
                                                        context);
                                                  }

                                                  // print(widget.wholelist[1][
                                                  //             widget.accessname]
                                                  //         ['question']["5"]
                                                  //     ['Roomate']);
                                                },
                                              )),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    (roomatecount > 0)
                                        ? Container(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 10, 0, 10),
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxHeight: 1000,
                                                    minHeight:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            10),
                                                child: ListView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: roomatecount,
                                                  itemBuilder:
                                                      (context, index1) {
                                                    return roomatecountwidget(
                                                        index1 + 1, context);
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
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * .5,
                            child:
                                Text('Able to get in & out of doors & steps?',
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
                              DropdownMenuItem(
                                child: Text('Min(A)'),
                                value: 'Min(A)',
                              ),
                              DropdownMenuItem(
                                child: Text('Mod(A)'),
                                value: 'Mod(A)',
                              ),
                              DropdownMenuItem(
                                child: Text('Max(A)'),
                                value: 'Max(A)',
                              ),
                              DropdownMenuItem(
                                child: Text('Max(A) x2'),
                                value: 'Max(A) x2',
                              )
                            ],
                            onChanged: (value) {
                              FocusScope.of(context).requestFocus();
                              new TextEditingController().clear();
                              // print(widget.accessname);
                              if (assessor == therapist &&
                                  role == "therapist") {
                                assesspro.setdata(6, value,
                                    'Able to get in & out of doors & steps?');
                              } else if (role != "therapist") {
                                assesspro.setdata(6, value,
                                    'Able to get in & out of doors & steps?');
                              } else {
                                _showSnackBar(
                                    "You can't change the other fields",
                                    context);
                              }
                            },
                            value: getvalue(6),
                          )
                        ],
                      ),
                      (getvalue(6) != 'Fairly Well' && getvalue(6) != '')
                          ? getrecomain(6, true, context)
                          : SizedBox(),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * .5,
                            child: Text('Using assistive device?',
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
                                child: Text('Yes'),
                                value: 'Yes',
                              ),
                              DropdownMenuItem(
                                child: Text('No'),
                                value: 'No',
                              ),
                            ],
                            onChanged: (value) {
                              FocusScope.of(context).requestFocus();
                              new TextEditingController().clear();
                              // print(widget.accessname);
                              if (assessor == therapist &&
                                  role == "therapist") {
                                assesspro.setdata(
                                    7, value, 'Using assistive device?');
                              } else if (role != "therapist") {
                                assesspro.setdata(
                                    7, value, 'Using assistive device?');
                              } else {
                                _showSnackBar(
                                    "You can't change the other fields",
                                    context);
                              }
                            },
                            value: getvalue(7),
                          )
                        ],
                      ),
                      (getvalue(7) == 'Yes')
                          ? Container(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * .3,
                                    child: Text('Assistive Device?',
                                        style: TextStyle(
                                          color: Color.fromRGBO(10, 80, 106, 1),
                                          fontSize: 20,
                                        )),
                                  ),
                                  Container(
                                      child: IconButton(
                                          onPressed: () {
                                            for (int i = 0;
                                                i < assistiveDevice.length;
                                                i++) {
                                              if (assistiveDevice[i]['name'] ==
                                                  widget.wholelist[1][widget
                                                                  .accessname]
                                                              ['question']["7"]
                                                          ['additional']
                                                      ["assistiveDevice"]) {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProductDetails(
                                                                assistiveDevice[
                                                                    i]['name'],
                                                                assistiveDevice[
                                                                        i][
                                                                    'description'],
                                                                assistiveDevice[
                                                                        i]
                                                                    ['url'])));
                                              }
                                            }
                                          },
                                          icon: Icon(Icons.info))),
                                  DropdownButton(
                                    items: [
                                      DropdownMenuItem(
                                        child: Text('--'),
                                        value: '',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('SC/Quad'),
                                        value: 'SC/Quad',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('Cane/Std'),
                                        value: 'Cane/Std',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('Walker'),
                                        value: 'Walker',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('Front Wheel Walker'),
                                        value: 'Front Wheel Walker',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('4 Whl. Walker'),
                                        value: '4 Whl. Whalker',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('Manual Whl Chair'),
                                        value: 'Manual Whl Chair',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('Power W/c'),
                                        value: 'Power W/c',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('Crutches'),
                                        value: 'Crutches',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('Scooter'),
                                        value: 'Scooter',
                                      ),
                                    ],
                                    onChanged: (value) {
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                      if (assessor == therapist &&
                                          role == "therapist") {
                                        widget.wholelist[1][widget.accessname]
                                                ['question']["7"]['additional']
                                            ["assistiveDevice"] = value;
                                      } else if (role != "therapist") {
                                        widget.wholelist[1][widget.accessname]
                                                ['question']["7"]['additional']
                                            ["assistiveDevice"] = value;
                                      } else {
                                        _showSnackBar(
                                            "You can't change the other fields",
                                            context);
                                      }

                                      // setrecothera(7, value);
                                    },
                                    value: widget.wholelist[1]
                                            [widget.accessname]['question']["7"]
                                        ['additional']["assistiveDevice"],
                                  )
                                ],
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * .4,
                            child: Text('Gait pattern noted',
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
                                  child: Text('Normal'),
                                  value: 'Normal',
                                ),
                                DropdownMenuItem(
                                  child: Text('Slight Shuffling'),
                                  value: 'Slight Shuffling',
                                ),
                                DropdownMenuItem(
                                  child: Text('Limping'),
                                  value: 'Limping',
                                ),
                                DropdownMenuItem(
                                  child: Text('Significant Shuffling'),
                                  value: 'Significant Shuffling',
                                ),
                                DropdownMenuItem(
                                  child: Text('Other'),
                                  value: 'Other',
                                ),
                              ],
                              onChanged: (value) {
                                FocusScope.of(context).requestFocus();
                                new TextEditingController().clear();
                                // print(widget.accessname);
                                if (assessor == therapist &&
                                    role == "therapist") {
                                  assesspro.setdata(
                                      8, value, 'Gait pattern noted');
                                } else if (role != "therapist") {
                                  assesspro.setdata(
                                      8, value, 'Gait pattern noted');
                                } else {
                                  _showSnackBar(
                                      "You can't change the other fields",
                                      context);
                                }
                              },
                              value: getvalue(8),
                            ),
                          ),
                        ],
                      ),
                      (getvalue(8) == 'Slight Shuffling' ||
                              getvalue(8) == 'Limping' ||
                              getvalue(8) == 'Significant Shuffling' ||
                              getvalue(8) == 'Other')
                          ? getrecomain(8, true, context)
                          : SizedBox(),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * .5,
                            child: Text('Access to Curbside',
                                style: TextStyle(
                                  color: Color.fromRGBO(10, 80, 106, 1),
                                  fontSize: 20,
                                )),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * .35,
                            child: DropdownButton(
                              isExpanded: true,
                              items: [
                                DropdownMenuItem(
                                  child: Text('--'),
                                  value: '',
                                ),
                                DropdownMenuItem(
                                  child: Text('Never goes to the curbside'),
                                  value: 'Never goes to the curbside',
                                ),
                                DropdownMenuItem(
                                  child: Text('Sometimes goes to the curbside'),
                                  value: 'Sometimes goes to the curbside',
                                ),
                                DropdownMenuItem(
                                  child: Text('Often goes to the curbside'),
                                  value: 'Often goes to the curbside',
                                ),
                                DropdownMenuItem(
                                  child: Text('Other'),
                                  value: 'Other',
                                ),
                              ],
                              onChanged: (value) {
                                FocusScope.of(context).requestFocus();
                                new TextEditingController().clear();
                                // print(widget.accessname);
                                if (assessor == therapist &&
                                    role == "therapist") {
                                  assesspro.setdata(
                                      9, value, 'Access to Curbside');
                                } else if (role != "therapist") {
                                  assesspro.setdata(
                                      9, value, 'Access to Curbside');
                                } else {
                                  _showSnackBar(
                                      "You can't change the other fields",
                                      context);
                                }
                              },
                              value: getvalue(9),
                            ),
                          )
                        ],
                      ),
                      (getvalue(9) != 'Never goes to the curbside' &&
                              // getvalue(9) != 'Other' &&
                              getvalue(9) != '')
                          ? getrecomain(9, true, context)
                          : SizedBox(),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * .6,
                            child: Text('Access to curbside specify',
                                style: TextStyle(
                                  color: Color.fromRGBO(10, 80, 106, 1),
                                  fontSize: 20,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          // height: 10000,
                          child: TextFormField(
                        maxLines: null,
                        controller: _controllers["field${10}"],
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: colorsset["field${10}"], width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1, color: colorsset["field${10}"]),
                          ),
                          suffix: Container(
                            padding: EdgeInsets.all(0),
                            child: Column(children: [
                              Container(
                                alignment: Alignment.topRight,
                                width: 58,
                                height: 30,
                                margin: EdgeInsets.all(0),
                                child: AvatarGlow(
                                  animate: isListening['field${10}'],
                                  glowColor: Theme.of(context).primaryColor,
                                  endRadius: 300.0,
                                  duration: const Duration(milliseconds: 2000),
                                  repeatPauseDuration:
                                      const Duration(milliseconds: 100),
                                  repeat: true,
                                  child: FlatButton(
                                    child: Icon(isListening['field${10}']
                                        ? Icons.cancel
                                        : Icons.mic),
                                    onPressed: () {
                                      if (assessor == therapist &&
                                          role == "therapist") {
                                        _listen(10);
                                        setdatalisten(10);
                                      } else if (role != "therapist") {
                                        _listen(10);
                                        setdatalisten(10);
                                      } else {
                                        _showSnackBar(
                                            "You can't change the other fields",
                                            context);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                        onChanged: (value) {
                          FocusScope.of(context).requestFocus();
                          new TextEditingController().clear();
                          // print(widget.accessname);
                          if (assessor == therapist && role == "therapist") {
                            assesspro.setdata(
                                10, value, 'Access to curbside specify');
                          } else if (role != "therapist") {
                            assesspro.setdata(
                                10, value, 'Access to curbside specify');
                          } else {
                            _showSnackBar(
                                "You can't change the other fields", context);
                          }
                        },
                      )),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .50,
                                child: Text('Number of Flight of Stairs',
                                    style: TextStyle(
                                      color: Color.fromRGBO(10, 80, 106, 1),
                                      fontSize: 20,
                                    )),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .35,
                                child: NumericStepButton(
                                  counterval: flightcount,
                                  onChanged: (value) {
                                    if (assessor == therapist &&
                                        role == "therapist") {
                                      assesspro.setFlightData(11, value,
                                          'Number of flight of stairs');
                                      setState(() {
                                        // widget.wholelist[1][widget.accessname]
                                        //             ['question']["11"]
                                        //         ['Question'] =
                                        //     'Number of Flight of Stairs';
                                        widget.wholelist[1][widget.accessname]
                                                ['question']["11"]['Flights']
                                            ["count"] = value;
                                        // widget.wholelist[1][widget.accessname]
                                        //         ['question']["11"]['Answer'] =
                                        //     value;
                                        flightcount = widget.wholelist[1]
                                                [widget.accessname]['question']
                                            ["11"]['Flights']["count"];
                                        print(widget.wholelist[1]
                                                [widget.accessname]['question']
                                            ["11"]['Flights']["count"]);
                                        // if (value == 0) {
                                        //   if (widget.wholelist[1][widget
                                        //                       .accessname]
                                        //                   ['question']["11"]
                                        //               ["Answer"] ==
                                        //           0 ||
                                        //       widget.wholelist[1][widget
                                        //                       .accessname]
                                        //                   ['question']["11"]
                                        //               ["Answer"] ==
                                        //           "") {
                                        //   } else {
                                        //     widget.wholelist[1]
                                        //             [widget.accessname]
                                        //         ['complete'] -= 1;
                                        //     widget.wholelist[1]
                                        //                 [widget.accessname]
                                        //             ['question']["11"]
                                        //         ["Answer"] = value;
                                        //   }
                                        // } else {
                                        //   if (widget.wholelist[1]
                                        //                   [widget.accessname]
                                        //               ['question']["11"]
                                        //           ["Answer"] ==
                                        //       value) {
                                        //   } else {
                                        //     widget.wholelist[1]
                                        //             [widget.accessname]
                                        //         ['complete'] += 1;
                                        //   }
                                        //   widget.wholelist[1]
                                        //               [widget.accessname]
                                        //           ['question']["11"]
                                        //       ["Answer"] = value;
                                        // }
                                        if (value > 0) {
                                          widget.wholelist[1][widget.accessname]
                                                  ['question']["11"]['Flights']
                                              ['flight$value'] = {"flight": ''};

                                          if (widget.wholelist[1]
                                                  [widget.accessname]
                                                  ['question']["11"]['Flights']
                                              .containsKey(
                                                  'flight${value + 1}')) {
                                            widget.wholelist[1]
                                                    [widget.accessname]
                                                    ['question']["11"]
                                                    ['Flights']
                                                .remove('flight${value + 1}');
                                          }
                                        } else if (value == 0) {
                                          if (widget.wholelist[1]
                                                  [widget.accessname]
                                                  ['question']["11"]['Flights']
                                              .containsKey(
                                                  'flight${value + 1}')) {
                                            widget.wholelist[1]
                                                    [widget.accessname]
                                                    ['question']["11"]
                                                    ['Flights']
                                                .remove('flight${value + 1}');
                                          }
                                        }
                                      });
                                    } else if (role != "therapist") {
                                      assesspro.setFlightData(11, value,
                                          'Number of flight of stairs');
                                      setState(() {
                                        // widget.wholelist[1][widget.accessname]
                                        //             ['question']["11"]
                                        //         ['Question'] =
                                        //     'Number of Flight of Stairs';
                                        widget.wholelist[1][widget.accessname]
                                                ['question']["11"]['Flights']
                                            ["count"] = value;
                                        // widget.wholelist[1][widget.accessname]
                                        //         ['question']["11"]['Answer'] =
                                        //     value;
                                        flightcount = widget.wholelist[1]
                                                [widget.accessname]['question']
                                            ["11"]['Flights']["count"];
                                        print(widget.wholelist[1]
                                                [widget.accessname]['question']
                                            ["11"]['Flights']["count"]);
                                        // if (value == 0) {
                                        //   if (widget.wholelist[1]
                                        //                   [widget.accessname]
                                        //               ['question']["11"]
                                        //           ["Answer"] ==
                                        //       0) {
                                        //   } else {
                                        //     widget.wholelist[1]
                                        //             [widget.accessname]
                                        //         ['complete'] -= 1;
                                        //     widget.wholelist[1]
                                        //                 [widget.accessname]
                                        //             ['question']["11"]
                                        //         ["Answer"] = value;
                                        //   }
                                        // } else {
                                        //   if (widget.wholelist[1]
                                        //                   [widget.accessname]
                                        //               ['question']["11"]
                                        //           ["Answer"] !=
                                        //       0) {
                                        //   } else {
                                        //     widget.wholelist[1]
                                        //             [widget.accessname]
                                        //         ['complete'] += 1;
                                        //   }
                                        //   widget.wholelist[1]
                                        //               [widget.accessname]
                                        //           ['question']["11"]
                                        //       ["Answer"] = value;
                                        // }
                                        if (value > 0) {
                                          widget.wholelist[1][widget.accessname]
                                                  ['question']["11"]['Flights']
                                              ['flight$value'] = {"flight": ''};

                                          if (widget.wholelist[1]
                                                  [widget.accessname]
                                                  ['question']["11"]['Flights']
                                              .containsKey(
                                                  'flight${value + 1}')) {
                                            widget.wholelist[1]
                                                    [widget.accessname]
                                                    ['question']["11"]
                                                    ['Flights']
                                                .remove('flight${value + 1}');
                                          }
                                          if (widget.wholelist[1]
                                                          [widget.accessname]
                                                      ['question']["11"]
                                                  ["Answer"] ==
                                              0) {
                                            widget.wholelist[1]
                                                    [widget.accessname]
                                                ['complete'] += 1;
                                            widget.wholelist[1]
                                                        [widget.accessname]
                                                    ['question']["11"]
                                                ["Answer"] = value;
                                          }
                                        } else if (value == 0) {
                                          if (widget.wholelist[1]
                                                  [widget.accessname]
                                                  ['question']["11"]['Flights']
                                              .containsKey(
                                                  'flight${value + 1}')) {
                                            widget.wholelist[1]
                                                    [widget.accessname]
                                                    ['question']["11"]
                                                    ['Flights']
                                                .remove('flight${value + 1}');
                                          }
                                          if (widget.wholelist[1]
                                                          [widget.accessname]
                                                      ['question']["11"]
                                                  ["Answer"] !=
                                              0) {
                                            widget.wholelist[1]
                                                    [widget.accessname]
                                                ['complete'] -= 1;
                                            widget.wholelist[1]
                                                        [widget.accessname]
                                                    ['question']["11"]
                                                ["Answer"] = value;
                                          }
                                        }
                                      });
                                    } else {
                                      _showSnackBar(
                                          "You can't change the other fields",
                                          context);
                                    }

                                    // print(widget.wholelist[1]
                                    //         [widget.accessname]['question']
                                    //     ["11"]['Flights']);
                                  },
                                ),
                              ),
                            ]),
                      ),
                      // SizedBox(height: 10),
                      (flightcount > 0)
                          ? Container(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxHeight: 1000,
                                      minHeight:
                                          MediaQuery.of(context).size.height /
                                              10),
                                  child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: flightcount,
                                    itemBuilder: (context, index1) {
                                      return flightcountwidget(
                                          index1 + 1, context);
                                    },
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 15,
                            ),

                      // SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * .6,
                            child: Text(
                                'Smoke detector batteries checked annually/replaced?',
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
                                child: Text('Yes'),
                                value: 'Yes',
                              ),
                              DropdownMenuItem(
                                child: Text('No'),
                                value: 'No',
                              ),
                            ],
                            onChanged: (value) {
                              FocusScope.of(context).requestFocus();
                              new TextEditingController().clear();
                              // print(widget.accessname);
                              if (assessor == therapist &&
                                  role == "therapist") {
                                assesspro.setdata(12, value,
                                    'Smoke detector batteries checked annually/replaced?');
                              } else if (role != "therapist") {
                                assesspro.setdata(12, value,
                                    'Smoke detector batteries checked annually/replaced?');
                              } else {
                                _showSnackBar(
                                    "You can't change the other fields",
                                    context);
                              }
                            },
                            value: getvalue(12),
                          )
                        ],
                      ),
                      (getvalue(12) == 'No')
                          ? getrecomain(12, true, context)
                          : SizedBox(height: 5),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Text(
                                'Person responsible to change smoke detector batteries',
                                style: TextStyle(
                                  color: Color.fromRGBO(10, 80, 106, 1),
                                  fontSize: 20,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          // height: 10000,
                          child: TextFormField(
                        initialValue: getvalue(13),
                        maxLines: 1,
                        decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(10, 80, 106, 1),
                                  width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1),
                            ),
                            // isDense: true,
                            labelText: 'Specify Name'),
                        onChanged: (value) {
                          FocusScope.of(context).requestFocus();
                          new TextEditingController().clear();
                          // print(widget.accessname);
                          if (assessor == therapist && role == "therapist") {
                            assesspro.setdata(13, value,
                                'Person responsible to change smoke detector batteries');
                          } else if (role != "therapist") {
                            assesspro.setdata(13, value,
                                'Person responsible to change smoke detector batteries');
                          } else {
                            _showSnackBar(
                                "You can't change the other fields", context);
                          }
                        },
                      )),
                      SizedBox(
                        height: 20,
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
                      SizedBox(
                        height: 10,
                      ),
                      // Container(
                      //     // height: 10000,
                      //     child: TextFormField(
                      //   initialValue: getvalue(14),
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
                      //   ),
                      //   onChanged: (value) {
                      //     FocusScope.of(context).requestFocus();
                      //     new TextEditingController().clear();
                      //     // print(widget.accessname);
                      //     if (assessor == therapist && role == "therapist") {
                      //       assesspro.setdata(14, value, 'Observations');
                      //     } else if (role != "therapist") {
                      //       assesspro.setdata(14, value, 'Observations');
                      //     } else {
                      //       _showSnackBar(
                      //           "You can't change the other fields", context);
                      //     }
                      //   },
                      // )),
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
                                controller: _controllers["field14"],
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),

                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    setreco(14, value);
                                    setdata(14, value, 'Oberservations');
                                  } else if (role != "therapist") {
                                    setreco(14, value);
                                    setdata(14, value, 'Oberservations');
                                  } else {
                                    _showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                              ),
                            ),
                            AvatarGlow(
                              animate: isListening["field14"],
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
                                  heroTag: "btn14",
                                  child: Icon(
                                    Icons.mic,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    if (assessor == therapist &&
                                        role == "therapist") {
                                      _listen(14);
                                      setdatalisten(14);
                                    } else if (role != "therapist") {
                                      _listen(14);
                                      setdatalisten(14);
                                    } else {
                                      _showSnackBar(
                                          "You can't change the other fields",
                                          context);
                                    }
                                    // print("1: ${isListening['field12']}");
                                    // ticklisten(12);
                                    // print("2: ${isListening['field12']}");
                                    print(isListening);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorsset["field${11}"],
                            width: 1,
                          ), //Border.all
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ]),
                  ),
                  Container(
                      child: RaisedButton(
                          color: colorb,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Submit',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          onPressed: () {
                            // uploadFile(_image);
                            // // _mediaList.add(assesspro.uploadImage().toString());
                            // widget.wholelist[1][widget.accessname]["images"] =
                            //     _mediaList;
                            // bool isValid = _formKey.currentState.validate();
                            var test = widget.wholelist[1][widget.accessname]
                                ["complete"];
                            for (int i = 0;
                                i <
                                    widget
                                        .wholelist[1][widget.accessname]
                                            ['question']
                                        .length;
                                i++) {
                              setdatalisten(i + 1);
                              setdatalistenthera(i + 1);
                            }
                            // if (!isValid) {
                            // _showSnackBar("Recommendation Required", context);
                            // } else {
                            // if (test == 0) {
                            //   _showSnackBar(
                            //       "You Must Have to Fill the Form First",
                            //       context);
                            // } else {
                            if (role == "therapist") {
                              // if (saveToForm) {
                              NewAssesmentRepository()
                                  .setLatestChangeDate(widget.docID);
                              NewAssesmentRepository()
                                  .setForm(widget.wholelist, widget.docID);
                              // Navigator.pop(context,
                              //     widget.wholelist[1][widget.accessname]);
                              Navigator.pop(context,
                                  widget.wholelist[1][widget.accessname]);
                              // } else {
                              //   _showSnackBar(
                              //       "Provide all recommendations", context);
                              // }
                            } else {
                              NewAssesmentRepository()
                                  .setLatestChangeDate(widget.docID);
                              NewAssesmentRepository()
                                  .setForm(widget.wholelist, widget.docID);
                              // Navigator.pop(context,
                              //     widget.wholelist[1][widget.accessname]);
                              Navigator.pop(context,
                                  widget.wholelist[1][widget.accessname]);
                            }
                          }
                          // }
                          // },
                          ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
