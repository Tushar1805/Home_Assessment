import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Patio/patiobase.dart';
import 'package:tryapp/Assesment/Forms/Patio/patiopro.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentrepo.dart';
import 'package:tryapp/constants.dart';
import 'package:path/path.dart';
import 'package:google_speech/google_speech.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:rxdart/rxdart.dart';

import '../ViewVideo.dart';

final _colorgreen = Color.fromRGBO(10, 80, 106, 1);

class PatioUI extends StatefulWidget {
  String roomname, docID;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  PatioUI(this.roomname, this.wholelist, this.accessname, this.docID);
  @override
  _PatioUIState createState() => _PatioUIState();
}

class _PatioUIState extends State<PatioUI> {
  final firestoreInstance = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  stt.SpeechToText _speech;
  bool _isListening = false, saveToForm = false;
  double _confidence = 1.0;
  bool available = false, isColor = false;
  Map<String, Color> colorsset = {};
  Map<String, TextEditingController> _controllers = {};
  Map<String, TextEditingController> _controllerstreco = {};
  Map<String, bool> isListening = {};
  bool cur = true;
  String role, curUid, assessor, therapist;
  int stepcount = 0;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  var test = TextEditingController();
  String videoDownloadUrl, videoUrl, videoName;
  File video;
  bool uploading = false;
  var falseIndex = -1, trueIndex = -1;
  List<DropdownMenuItem<dynamic>> items = [];

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

  FocusNode focusNode = new FocusNode();
  FocusNode focusNode1 = new FocusNode();
  FocusNode focusNode2 = new FocusNode();
  FocusNode focusNode3 = new FocusNode();
  FocusNode focusNode4 = new FocusNode();
  FocusNode focusNode5 = new FocusNode();
  FocusNode focusNode6 = new FocusNode();
  FocusNode focusNode7 = new FocusNode();
  FocusNode focusNode8 = new FocusNode();
  FocusNode focusNode9 = new FocusNode();
  FocusNode focusNode10 = new FocusNode();

  void dispose() {
    focusNode.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();
    focusNode5.dispose();
    focusNode6.dispose();
    focusNode7.dispose();
    focusNode8.dispose();
    focusNode9.dispose();
    focusNode10.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _recorder.initialize();

    for (int i = 0;
        i < widget.wholelist[8][widget.accessname]['question'].length;
        i++) {
      _controllers["field${i + 1}"] = TextEditingController();
      _controllerstreco["field${i + 1}"] = TextEditingController();
      isListening["field${i + 1}"] = false;
      isRecognizing["field${i + 1}"] = false;
      isRecognizingThera["field${i + 1}"] = false;
      isRecognizeFinished["field${i + 1}"] = false;
      _controllers["field${i + 1}"].text = capitalize(widget.wholelist[8]
          [widget.accessname]['question']["${i + 1}"]['Recommendation']);
      _controllerstreco["field${i + 1}"].text = capitalize(widget.wholelist[8]
          [widget.accessname]['question']["${i + 1}"]['Recommendationthera']);
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
    getRole();
    fillDropItem();
    // setinitials();
    // getAssessData();
  }

  void streamingRecognize(index, TextEditingController text) async {
    _audioStream = BehaviorSubject<List<int>>();
    try {
      _audioStreamSubscription = _recorder.audioStream.listen((event) {
        _audioStream.add(event);
      });
    } catch (e) {
      print("AUDIO STREAM ERROR: $e");
    }

    await _recorder.start();

    setState(() {
      isRecognizing['field$index'] = true;
    });
    final serviceAccount = ServiceAccount.fromString(
        (await rootBundle.loadString('assets/test_service_account.json')));
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
    final config = _getConfig();

    final responseStream = speechToText.streamingRecognize(
        StreamingRecognitionConfig(config: config, interimResults: true),
        _audioStream);

    var responseText = '';

    try {
      responseStream.listen((data) {
        final currentText =
            data.results.map((e) => e.alternatives.first.transcript).join('\n');

        if (data.results.first.isFinal) {
          responseText += ' ' + currentText;
          setState(() {
            text.text = responseText;
            isRecognizeFinished['field$index'] = true;
          });
        } else {
          setState(() {
            text.text = responseText + ' ' + currentText;
            isRecognizeFinished['field$index'] = true;
          });
        }
      }, onDone: () {
        setState(() {
          isRecognizing['field$index'] = false;
        });
      });
    } catch (e) {
      print("RESPONSE STREAM ERROR: $e");
    }
  }

  void stopRecording(index) async {
    await _recorder.stop();
    await _audioStreamSubscription?.cancel();
    await _audioStream?.close();
    setState(() {
      isRecognizing['field$index'] = false;
    });
  }

  // For Therapist

  void streamingRecognizeThera(index, TextEditingController text) async {
    _audioStream = BehaviorSubject<List<int>>();
    _audioStreamSubscription = _recorder.audioStream.listen((event) {
      _audioStream.add(event);
    });

    await _recorder.start();

    setState(() {
      isRecognizingThera['field$index'] = true;
    });
    final serviceAccount = ServiceAccount.fromString(
        (await rootBundle.loadString('assets/test_service_account.json')));
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
    final config = _getConfig();

    final responseStream = speechToText.streamingRecognize(
        StreamingRecognitionConfig(config: config, interimResults: true),
        _audioStream);

    var responseText = '';

    try {
      responseStream.listen((data) {
        final currentText =
            data.results.map((e) => e.alternatives.first.transcript).join('\n');

        if (data.results.first.isFinal) {
          responseText += ' ' + currentText;
          setState(() {
            text.text = responseText;
            isRecognizeFinished['field$index'] = true;
          });
        } else {
          setState(() {
            text.text = responseText + ' ' + currentText;
            isRecognizeFinished['field$index'] = true;
          });
        }
      }, onDone: () {
        setState(() {
          isRecognizingThera['field$index'] = false;
        });
      });
    } catch (e) {
      print("THERA RESPONSE STREAM ERROR: $e");
    }
  }

  void stopRecordingThera(index) async {
    await _recorder.stop();
    await _audioStreamSubscription?.cancel();
    await _audioStream?.close();
    setState(() {
      isRecognizingThera['field$index'] = false;
    });
  }

  RecognitionConfig _getConfig() => RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 16000,
      languageCode: 'en-US');

  fillDropItem() {
    List<dynamic> itemList = [];
    setState(() {
      for (var i = 0; i < widget.wholelist[8]['count']; i++) {
        if (widget.wholelist[8]['room${i + 1}']['isUsed'][0]) {
          itemList.add("room${i + 1}".toString());
        }
      }

      itemList.forEach((element) {
        DropdownMenuItem<String> ddmi = DropdownMenuItem<String>(
          child: Text("${widget.wholelist[8][element.toString()]['name']}",
              style: TextStyle(fontSize: 18, color: Colors.white)),
          value: element.toString(),
        );
        items.add(ddmi);
      });
    });
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
    PatioProvider assesmentprovider = Provider.of<PatioProvider>(context);

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
          widget.wholelist[8][widget.accessname]["videos"]["url"] = videoUrl;
          widget.wholelist[8][widget.accessname]["videos"]["name"] = videoName;
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
            // assesmentprovider.addVideo(pickedVideo.path);
            // FocusScope.of(context).requestFocus(new FocusNode());
            setState(() {
              upload(File(pickedVideo?.path));
            });
          } else {
            Navigator.pop(context);
            setState(() {});
            final snackBar = SnackBar(content: Text('Video Not Selected!'));
            assesmentprovider.notifyListeners();
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          final pickedVideo =
              await ImagePicker().pickVideo(source: ImageSource.gallery);
          if (pickedVideo != null) {
            Navigator.pop(context);
            // assesmentprovider.addVideo(pickedVideo.path);
            setState(() {
              upload(File(pickedVideo?.path));
            });
          } else {
            Navigator.pop(context);
            setState(() {});
            final snackBar = SnackBar(content: Text('Video Not Selected!'));
            assesmentprovider.notifyListeners();
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

      assesmentprovider.notifyListeners();
    }

    Future deleteFile(String imagePath) async {
      String imagePath1 = 'asssessmentVideos/' + imagePath;
      try {
        Reference ref = await FirebaseStorage.instance.refFromURL(imagePath);

        print('deleteFile(): file deleted');
        // return url;
      } catch (e) {
        print('  deleteFile(): error: ${e.toString()}');
        throw (e.toString());
      }
    }

    Widget toggleButton(BuildContext context, PatioProvider assesmentprovider,
        int queIndex, String que) {
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
                            .wholelist[8][widget.accessname]['question']
                                ['$queIndex']['toggle']
                            .length;
                    i++) {
                  widget.wholelist[8][widget.accessname]['question']
                      ['$queIndex']['toggle'][i] = i == select;
                }
              });
              assesmentprovider.setdataToggle(
                  queIndex,
                  widget.wholelist[8][widget.accessname]['question']
                          ['$queIndex']['toggle'][0]
                      ? 'Yes'
                      : 'No',
                  que);
            } else if (role != "therapist") {
              setState(() {
                for (int i = 0;
                    i <
                        widget
                            .wholelist[8][widget.accessname]['question']
                                ['$queIndex']['toggle']
                            .length;
                    i++) {
                  widget.wholelist[8][widget.accessname]['question']
                      ['$queIndex']['toggle'][i] = i == select;
                }
              });
              assesmentprovider.setdataToggle(
                  queIndex,
                  widget.wholelist[8][widget.accessname]['question']
                          ['$queIndex']['toggle'][0]
                      ? 'Yes'
                      : 'No',
                  que);
            } else {
              _showSnackBar("You can't change the other fields", context);
            }
          },
          isSelected: widget.wholelist[8][widget.accessname]['question']
                  ['$queIndex']['toggle']
              .cast<bool>(),
        ),
      );
    }

    listenDropButton() {
      var test = widget.wholelist[8][widget.accessname]['complete'];
      for (int i = 0;
          i < widget.wholelist[8][widget.accessname]['question'].length;
          i++) {
        setdatalisten(i + 1);
        setdatalistenthera(i + 1);
      }
      // if (test == 0) {
      //   _showSnackBar(
      //       "You Must Have to Fill The Details First", context);
      // } else {
      if (role == "therapist") {
        // if (saveToForm) {
        NewAssesmentRepository().setLatestChangeDate(widget.docID);
        NewAssesmentRepository().setForm(widget.wholelist, widget.docID);
        // Navigator.pop(
        //     context, widget.wholelist[8][widget.accessname]);
        // } else {
        //   _showSnackBar(
        //       "Provide all recommendations", context);
        // }
      } else {
        NewAssesmentRepository().setLatestChangeDate(widget.docID);
        NewAssesmentRepository().setForm(widget.wholelist, widget.docID);
        // Navigator.pop(
        //     context, widget.wholelist[8][widget.accessname]);
      }
    }

    return WillPopScope(
      onWillPop: () async {
        listenDropButton();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: (widget.roomname != null)
              ? Container(
                  padding: EdgeInsets.all(8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      iconDisabledColor: Colors.white,
                      dropdownColor: Color.fromRGBO(10, 80, 106, 1),
                      icon: Icon(
                        // Add this
                        Icons.arrow_drop_down, // Add this
                        color: Colors.white, // Add this
                      ),
                      items: items,
                      onChanged: (value) {
                        setState(() {
                          widget.accessname = value;
                          widget.roomname =
                              widget.wholelist[8][widget.accessname]['name'];
                        });
                        print(widget.roomname);
                        listenDropButton();
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(
                                builder: (context) => Patio(
                                    widget.roomname,
                                    widget.wholelist,
                                    widget.accessname,
                                    widget.docID)))
                            .then((value) => setState(() {
                                  widget.wholelist[8][widget]['complete'] =
                                      value['complete'];
                                  // widget.wholelist[index]['']
                                }));
                      },
                      value: widget.accessname,
                    ),
                  ),
                )
              : Text('Patio'),
          // automaticallyImplyLeading: false,
          backgroundColor: _colorgreen,
          actions: [
            IconButton(
              icon: Icon(Icons.done_all, color: Colors.white),
              onPressed: () async {
                try {
                  var test = widget.wholelist[8][widget.accessname]['complete'];
                  for (int i = 0;
                      i <
                          widget.wholelist[8][widget.accessname]['question']
                              .length;
                      i++) {
                    setdatalisten(i + 1);
                    setdatalistenthera(i + 1);
                  }
                  // if (test == 0) {
                  //   _showSnackBar(
                  //       "You Must Have to Fill The Details First", context);
                  // } else {
                  if (role == "therapist") {
                    // if (saveToForm) {
                    NewAssesmentRepository().setLatestChangeDate(widget.docID);
                    NewAssesmentRepository()
                        .setForm(widget.wholelist, widget.docID);
                    Navigator.pop(
                        context, widget.wholelist[8][widget.accessname]);
                    // } else {
                    //   _showSnackBar("Provide all recommendations", context);
                    // }
                  } else {
                    NewAssesmentRepository().setLatestChangeDate(widget.docID);
                    NewAssesmentRepository()
                        .setForm(widget.wholelist, widget.docID);
                    Navigator.pop(
                        context, widget.wholelist[8][widget.accessname]);
                  }
                  // }
                } catch (e) {
                  print(e.toString());
                }
              },
              // label: Text(
              //   'Logout',
              //   style: TextStyle(color: Colors.white, fontSize: 16),
              // ),
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
                  //             width: MediaQuery.of(context).size.width / 1.6,
                  //             child: Text(
                  //               '${widget.roomname}Details',
                  //               style: TextStyle(
                  //                 fontSize: 25,
                  //                 fontWeight: FontWeight.bold,
                  //                 color: Color.fromRGBO(10, 80, 106, 1),
                  //               ),
                  //             ),
                  //           ),
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
                                                  widget.wholelist[8]
                                                          [widget.accessname]
                                                      ["videos"]["name"] = "";
                                                  widget.wholelist[8]
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
                                                  widget.wholelist[8]
                                                          [widget.accessname]
                                                      ["videos"]["name"] = "";
                                                  widget.wholelist[8]
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
                                      width: 15.0,
                                    )
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(),
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        // SizedBox(height: 15),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .4,
                                child: Text('Threshold to Patio',
                                    style: TextStyle(
                                      color: Color.fromRGBO(10, 80, 106, 1),
                                      fontSize: 20,
                                    )),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .3,
                                child: TextFormField(
                                  initialValue: widget.wholelist[8]
                                          [widget.accessname]['question']["1"]
                                      ['Answer'],
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
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    if (assessor == therapist &&
                                        role == "therapist") {
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                      assesmentprovider.setdata(
                                          1, value, 'Threshold to Patio');
                                    } else if (role != "therapist") {
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                      assesmentprovider.setdata(
                                          1, value, 'Threshold to Patio');
                                    } else {
                                      _showSnackBar(
                                          "You can't change the other fields",
                                          context);
                                    }
                                  },
                                ),
                              ),
                            ]),
                        (assesmentprovider.getvalue(1) != '')
                            ? (double.parse(assesmentprovider.getvalue(1)) >=
                                    2.5)
                                ? getrecomain(1, true, 'Comments (if any)',
                                    context, assesmentprovider, focusNode1)
                                : SizedBox()
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: Text('Flooring Type',
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
                                    child: Text('Wood - Smooth Finish'),
                                    value: 'Wood - Smooth Finish',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Wood - Friction Finish'),
                                    value: 'Wood - Friction Finish',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Carpet'),
                                    value: 'Carpet',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Concrete'),
                                    value: 'Concrete',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Tile - Smooth Finish'),
                                    value: 'Tile - Smooth Finish',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Tile - Friction Finish'),
                                    value: 'Tile - Friction Finish',
                                  ),
                                ],
                                onChanged: (value) {
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    FocusScope.of(context)
                                        .requestFocus(focusNode);
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        2, value, 'Flooring Type');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context)
                                        .requestFocus(focusNode);
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        2, value, 'Flooring Type');
                                  } else {
                                    _showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                                value: assesmentprovider.getvalue(2),
                              ),
                            )
                          ],
                        ),
                        (assesmentprovider.getvalue(2) ==
                                    'Wood - Smooth Finish' ||
                                assesmentprovider.getvalue(2) ==
                                    'Tile - Smooth Finish')
                            ? getrecomain(2, true, 'Comments (if any)', context,
                                assesmentprovider, focusNode2)
                            : SizedBox(),
                        SizedBox(height: 15),
                        // Divider(
                        //   height: dividerheight,
                        //   color: Color.fromRGBO(10, 80, 106, 1),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: Text('Floor Coverage',
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
                                    child: Text('Large Rug'),
                                    value: 'Large Rug',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Small Rug'),
                                    value: 'Small Rug',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('No covering'),
                                    value: 'No covering',
                                  ),
                                ],
                                onChanged: (value) {
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    FocusScope.of(context)
                                        .requestFocus(focusNode);
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        3, value, 'Floor Coverage');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context)
                                        .requestFocus(focusNode);
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        3, value, 'Floor Coverage');
                                  } else {
                                    _showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                                value: assesmentprovider.getvalue(3),
                              ),
                            )
                          ],
                        ),
                        (assesmentprovider.getvalue(3) != 'No covering' &&
                                assesmentprovider.getvalue(3) != '')
                            ? getrecomain(3, true, 'Comments (if any)', context,
                                assesmentprovider, focusNode3)
                            : SizedBox(),
                        SizedBox(height: 15),
                        // Divider(
                        //   height: dividerheight,
                        //   color: Color.fromRGBO(10, 80, 106, 1),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: Text('Lighting Type',
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
                                    child: Text('Adequate'),
                                    value: 'Adequate',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Inadequate'),
                                    value: 'Inadequate',
                                  ),
                                ],
                                onChanged: (value) {
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    FocusScope.of(context)
                                        .requestFocus(focusNode);
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        4, value, 'Lighting Type');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context)
                                        .requestFocus(focusNode);
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        4, value, 'Lighting Type');
                                  } else {
                                    _showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                                value: assesmentprovider.getvalue(4),
                              ),
                            )
                          ],
                        ),
                        (assesmentprovider.getvalue(4) == 'Inadequate')
                            ? getrecomain(4, true, 'Specify Type', context,
                                assesmentprovider, focusNode4)
                            : SizedBox(),
                        SizedBox(height: 15),
                        // Divider(
                        //   height: dividerheight,
                        //   color: Color.fromRGBO(10, 80, 106, 1),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .58,
                              child: Text('Able to Operate Switches?',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            // Container(
                            //   child: DropdownButton(
                            //     items: [
                            //       DropdownMenuItem(
                            //         child: Text('--'),
                            //         value: '',
                            //       ),
                            //       DropdownMenuItem(
                            //         child: Text('Yes'),
                            //         value: 'Yes',
                            //       ),
                            //       DropdownMenuItem(
                            //         child: Text('No'),
                            //         value: 'No',
                            //       ),
                            //     ],
                            //     onChanged: (value) {
                            //       if (assessor == therapist &&
                            //           role == "therapist") {
                            //         FocusScope.of(context).requestFocus(focusNode);
                            //         new TextEditingController().clear();
                            //         // print(widget.accessname);
                            //         setdata(
                            //             5, value, 'Able to Operate Switches?');
                            //       } else if (role != "therapist") {
                            //         FocusScope.of(context).requestFocus(focusNode);
                            //         new TextEditingController().clear();
                            //         // print(widget.accessname);
                            //         setdata(
                            //             5, value, 'Able to Operate Switches?');
                            //       } else {
                            //         _showSnackBar(
                            //             "You can't change the other fields",
                            //             context);
                            //       }
                            //     },
                            //     value: getvalue(5),
                            //   ),
                            // ),
                            toggleButton(context, assesmentprovider, 5,
                                'Able to Operate Switches?')
                          ],
                        ),
                        SizedBox(height: 15),
                        (assesmentprovider.getvalue(5) == 'No')
                            ? getrecomain(5, true, 'Comments(if any)', context,
                                assesmentprovider, focusNode5)
                            : SizedBox(),
                        SizedBox(height: 15),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: Text('Switch Type',
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
                                    child: Text('Single Pole'),
                                    value: 'Single Pole',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('3 Way'),
                                    value: '3 Way',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('4 Way'),
                                    value: '4 Way',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Multi Location'),
                                    value: 'Multi Location',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Double Switch'),
                                    value: 'Double Switch',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Dimmers'),
                                    value: 'Dimmers',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Remote Control'),
                                    value: 'Remote Control',
                                  ),
                                ],
                                onChanged: (value) {
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    FocusScope.of(context)
                                        .requestFocus(focusNode);
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        6, value, 'Switch Type');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context)
                                        .requestFocus(focusNode);
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        6, value, 'Switch Type');
                                  } else {
                                    _showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                                value: assesmentprovider.getvalue(6),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: Text('Door Width',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .25,
                              child: TextFormField(
                                initialValue: widget.wholelist[8]
                                        [widget.accessname]['question']["7"]
                                    ['Answer'],
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(10, 80, 106, 1),
                                          width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 1),
                                    ),
                                    labelText: '(Inches)'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        7, value, 'Door Width');
                                    setState(() {
                                      widget.wholelist[8][widget.accessname]
                                          ['question']["7"]['doorwidth'] = 0;

                                      widget.wholelist[8][widget.accessname]
                                              ['question']["7"]['doorwidth'] =
                                          double.parse(value);
                                    });
                                  } else if (role != "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        7, value, 'Door Width');
                                    setState(() {
                                      widget.wholelist[8][widget.accessname]
                                          ['question']["7"]['doorwidth'] = 0;

                                      widget.wholelist[8][widget.accessname]
                                              ['question']["7"]['doorwidth'] =
                                          double.parse(value);
                                    });
                                  } else {
                                    _showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        (widget.wholelist[8][widget.accessname]['question']["7"]
                                        ['doorwidth'] <
                                    30 &&
                                widget.wholelist[8][widget.accessname]
                                        ['question']["7"]['doorwidth'] >
                                    0 &&
                                widget.wholelist[8][widget.accessname]
                                        ['question']["7"]['doorwidth'] !=
                                    '')
                            ? getrecomain(7, true, 'Comments (if any)', context,
                                assesmentprovider, focusNode6)
                            : SizedBox(),
                        SizedBox(
                          height: 15,
                        ),
                        // Divider(
                        //   height: dividerheight,
                        //   color: Color.fromRGBO(10, 80, 106, 1),
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
                            //     if (assessor == therapist &&
                            //         role == "therapist") {
                            //       FocusScope.of(context).requestFocus(focusNode);
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       setdata(
                            //           8, value, 'Obstacle/Clutter Present?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus(focusNode);
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       setdata(
                            //           8, value, 'Obstacle/Clutter Present?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: getvalue(8),
                            // )
                            toggleButton(context, assesmentprovider, 8,
                                'Obstacle/Clutter Present?')
                          ],
                        ),
                        SizedBox(height: 15),
                        (assesmentprovider.getvalue(8) == 'Yes')
                            ? getrecomain(8, true, 'Specify Clutter', context,
                                assesmentprovider, focusNode7)
                            : SizedBox(),
                        SizedBox(height: 15),
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
                                    FocusScope.of(context)
                                        .requestFocus(focusNode);
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        9, value, 'Type of Steps');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context)
                                        .requestFocus(focusNode);
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        9, value, 'Type of Steps');
                                  } else {
                                    _showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                                value: assesmentprovider.getvalue(9),
                              ),
                            ),
                          ],
                        ),
                        (assesmentprovider.getvalue(9) != '' &&
                                assesmentprovider.getvalue(9) != 'N/A')
                            ? (assesmentprovider.getvalue(9) ==
                                    'Single Dimension')
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
                                                  child: Text('Number of steps',
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
                                                      initialValue: widget.wholelist[8]
                                                                      [widget.accessname]
                                                                  ['question']
                                                              ['9']['additional']
                                                          ["count"],
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
                                                                  '(Count)'),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      onChanged: (value) {
                                                        if (assessor ==
                                                                therapist &&
                                                            role ==
                                                                "therapist") {
                                                          setState(() {
                                                            widget.wholelist[8][
                                                                            widget.accessname]
                                                                        [
                                                                        'question']["9"]
                                                                    [
                                                                    'additional']
                                                                [
                                                                'count'] = value;
                                                          });
                                                        } else if (role !=
                                                            "therapist") {
                                                          setState(() {
                                                            widget.wholelist[8][
                                                                            widget.accessname]
                                                                        [
                                                                        'question']["9"]
                                                                    [
                                                                    'additional']
                                                                [
                                                                'count'] = value;
                                                          });
                                                        } else {
                                                          _showSnackBar(
                                                              "You can't change the other fields",
                                                              context);
                                                        }
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          widget.wholelist[8][widget.accessname]
                                                                  ['question']
                                                              ["9"]['additional']
                                                          ['count'] !=
                                                      '0' &&
                                                  widget.wholelist[8][widget
                                                                      .accessname]
                                                                  ['question']
                                                              ["9"]['additional']
                                                          ['count'] !=
                                                      ""
                                              ? Container(
                                                  padding: EdgeInsets.all(5),
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
                                                                          .wholelist[8]
                                                                      [
                                                                      widget
                                                                          .accessname]
                                                                  [
                                                                  'question']["9"]
                                                              [
                                                              'Single Step Width'],
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              InputDecoration(
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: colorsset[
                                                                            "field${8}"],
                                                                        width:
                                                                            1),
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: colorsset[
                                                                            "field${8}"]),
                                                                  ),
                                                                  labelText:
                                                                      'Step Width in inches:'),
                                                          onChanged: (value) {
                                                            if (assessor ==
                                                                    therapist &&
                                                                role ==
                                                                    "therapist") {
                                                              setState(() {
                                                                widget.wholelist[8]
                                                                            [
                                                                            widget
                                                                                .accessname]
                                                                        [
                                                                        'question']["9"]
                                                                    [
                                                                    'Single Step Width'] = value;
                                                              });
                                                            } else if (role !=
                                                                "therapist") {
                                                              setState(() {
                                                                widget.wholelist[8]
                                                                            [
                                                                            widget
                                                                                .accessname]
                                                                        [
                                                                        'question']["9"]
                                                                    [
                                                                    'Single Step Width'] = value;
                                                              });
                                                            } else {
                                                              _showSnackBar(
                                                                  "You can't change the other fields",
                                                                  context);
                                                            }
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
                                                                          .wholelist[8]
                                                                      [
                                                                      widget
                                                                          .accessname]
                                                                  [
                                                                  'question']["9"]
                                                              [
                                                              'Single Step Height'],
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              InputDecoration(
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: colorsset[
                                                                            "field${8}"],
                                                                        width:
                                                                            1),
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: colorsset[
                                                                            "field${8}"]),
                                                                  ),
                                                                  labelText:
                                                                      'Step Height in inches:'),
                                                          onChanged: (value) {
                                                            if (assessor ==
                                                                    therapist &&
                                                                role ==
                                                                    "therapist") {
                                                              setState(() {
                                                                widget.wholelist[8]
                                                                            [
                                                                            widget
                                                                                .accessname]
                                                                        [
                                                                        'question']["9"]
                                                                    [
                                                                    'Single Step Height'] = value;
                                                              });
                                                            } else if (role !=
                                                                "therapist") {
                                                              setState(() {
                                                                widget.wholelist[8]
                                                                            [
                                                                            widget
                                                                                .accessname]
                                                                        [
                                                                        'question']["9"]
                                                                    [
                                                                    'Single Step Height'] = value;
                                                              });
                                                            } else {
                                                              _showSnackBar(
                                                                  "You can't change the other fields",
                                                                  context);
                                                            }
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
                                                  child: Text('Number Of Steps',
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
                                                          widget.wholelist[8][widget
                                                                          .accessname]
                                                                      [
                                                                      'question']["9"]
                                                                  [
                                                                  'MultipleStair']
                                                              ['count'] = value;
                                                          stepcount = widget
                                                                          .wholelist[8]
                                                                      [
                                                                      widget
                                                                          .accessname]
                                                                  [
                                                                  'question']["9"]
                                                              [
                                                              'MultipleStair']['count'];
                                                          if (value > 0) {
                                                            widget.wholelist[8][
                                                                            widget.accessname]
                                                                        [
                                                                        'question']["9"]
                                                                    [
                                                                    'MultipleStair']
                                                                [
                                                                'step$value'] = {
                                                              'stepwidth': '',
                                                              'stepheight': ''
                                                            };

                                                            if (widget
                                                                .wholelist[8][
                                                                    widget
                                                                        .accessname]
                                                                    ['question']
                                                                    ["9"][
                                                                    'MultipleStair']
                                                                .containsKey(
                                                                    'step${value + 1}')) {
                                                              widget
                                                                  .wholelist[8][
                                                                      widget
                                                                          .accessname]
                                                                      [
                                                                      'question']
                                                                      ["9"][
                                                                      'MultipleStair']
                                                                  .remove(
                                                                      'step${value + 1}');
                                                            }
                                                          } else if (value ==
                                                              0) {
                                                            if (widget
                                                                .wholelist[8][
                                                                    widget
                                                                        .accessname]
                                                                    ['question']
                                                                    ["9"][
                                                                    'MultipleStair']
                                                                .containsKey(
                                                                    'step${value + 1}')) {
                                                              widget
                                                                  .wholelist[8][
                                                                      widget
                                                                          .accessname]
                                                                      [
                                                                      'question']
                                                                      ["9"][
                                                                      'MultipleStair']
                                                                  .remove(
                                                                      'step${value + 1}');
                                                            }
                                                          }
                                                        });
                                                      } else if (role !=
                                                          "therapist") {
                                                        setState(() {
                                                          widget.wholelist[8][widget
                                                                          .accessname]
                                                                      [
                                                                      'question']["9"]
                                                                  [
                                                                  'MultipleStair']
                                                              ['count'] = value;

                                                          stepcount = widget
                                                                          .wholelist[8]
                                                                      [
                                                                      widget
                                                                          .accessname]
                                                                  [
                                                                  'question']["9"]
                                                              [
                                                              'MultipleStair']['count'];
                                                          if (value > 0) {
                                                            widget.wholelist[8][
                                                                            widget.accessname]
                                                                        [
                                                                        'question']["9"]
                                                                    [
                                                                    'MultipleStair']
                                                                [
                                                                'step$value'] = {
                                                              'stepwidth': '',
                                                              'stepheight': ''
                                                            };

                                                            if (widget
                                                                .wholelist[8][
                                                                    widget
                                                                        .accessname]
                                                                    ['question']
                                                                    ["9"][
                                                                    'MultipleStair']
                                                                .containsKey(
                                                                    'step${value + 1}')) {
                                                              widget
                                                                  .wholelist[8][
                                                                      widget
                                                                          .accessname]
                                                                      [
                                                                      'question']
                                                                      ["9"][
                                                                      'MultipleStair']
                                                                  .remove(
                                                                      'step${value + 1}');
                                                            }
                                                          } else if (value ==
                                                              0) {
                                                            if (widget
                                                                .wholelist[8][
                                                                    widget
                                                                        .accessname]
                                                                    ['question']
                                                                    ["9"][
                                                                    'MultipleStair']
                                                                .containsKey(
                                                                    'step${value + 1}')) {
                                                              widget
                                                                  .wholelist[8][
                                                                      widget
                                                                          .accessname]
                                                                      [
                                                                      'question']
                                                                      ["9"][
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
                            : SizedBox(height: 15),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Railing is present on which side?',
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
                                  FocusScope.of(context)
                                      .requestFocus(focusNode);
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  assesmentprovider.setdata(10, value,
                                      'Railing is present on which side?');
                                } else if (role != "therapist") {
                                  FocusScope.of(context)
                                      .requestFocus(focusNode);
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  assesmentprovider.setdata(10, value,
                                      'Railing is present on which side?');
                                } else {
                                  _showSnackBar(
                                      "You can't change the other fields",
                                      context);
                                }
                              },
                              value: assesmentprovider.getvalue(10),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        (assesmentprovider.getvalue(10) == 'On Neither Side')
                            ? getrecomain(10, true, 'Comments (if any)',
                                context, assesmentprovider, focusNode8)
                            : (assesmentprovider.getvalue(10) == 'One Side')
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
                                              child: Text(
                                                  'Railing is present on which side while going up?',
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
                                                  value: '--',
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
                                                  widget.wholelist[8][widget
                                                                  .accessname]
                                                              ['question']["10"]
                                                          [
                                                          'Railling']['OneSided']
                                                      ['GoingUp'] = value;
                                                } else if (role !=
                                                    "therapist") {
                                                  widget.wholelist[8][widget
                                                                  .accessname]
                                                              ['question']["10"]
                                                          [
                                                          'Railling']['OneSided']
                                                      ['GoingUp'] = value;
                                                } else {
                                                  _showSnackBar(
                                                      "You can't change the other fields",
                                                      context);
                                                }
                                              },
                                              value: widget.wholelist[8][
                                                              widget.accessname]
                                                          ['question']["10"]
                                                      ['Railling']['OneSided']
                                                  ['GoingUp'],
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
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
                                              child: Text(
                                                  'Railing is present on which side while going down?',
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
                                                  widget.wholelist[8][widget
                                                                  .accessname]
                                                              ['question']["10"]
                                                          [
                                                          'Railling']['OneSided']
                                                      ['GoingDown'] = value;
                                                } else if (role !=
                                                    "therapist") {
                                                  widget.wholelist[8][widget
                                                                  .accessname]
                                                              ['question']["10"]
                                                          [
                                                          'Railling']['OneSided']
                                                      ['GoingDown'] = value;
                                                } else {
                                                  _showSnackBar(
                                                      "You can't change the other fields",
                                                      context);
                                                }
                                              },
                                              value: widget.wholelist[8][
                                                              widget.accessname]
                                                          ['question']["10"]
                                                      ['Railling']['OneSided']
                                                  ['GoingDown'],
                                            )
                                          ],
                                        ),
                                      ),
                                      (role == 'therapist')
                                          ? getrecowid(
                                              10, context, assesmentprovider)
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
                              width: MediaQuery.of(context).size.width * .58,
                              child: Text('Smoke Detector Present?',
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
                            //     ),
                            //   ],
                            //   onChanged: (value) {
                            //     if (assessor == therapist &&
                            //         role == "therapist") {
                            //       FocusScope.of(context).requestFocus(focusNode);
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       setdata(11, value, 'Smoke Detector Present?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus(focusNode);
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       setdata(11, value, 'Smoke Detector Present?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: getvalue(11),
                            // )
                            toggleButton(context, assesmentprovider, 11,
                                'Smoke Detector Present?')
                          ],
                        ),
                        SizedBox(height: 15),
                        (assesmentprovider.getvalue(11) == 'No')
                            ? getrecomain(11, true, 'Comments (if any)',
                                context, assesmentprovider, focusNode9)
                            : SizedBox(),

                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: Text('Observations',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        // Container(
                        //   // height: 10000,
                        //   child: TextFormField(
                        //     initialValue: widget.wholelist[8][widget.accessname]
                        //         ['question']["12"]['Answer'],
                        //     maxLines: 6,
                        //     decoration: InputDecoration(
                        //       focusedBorder: OutlineInputBorder(
                        //         borderSide: BorderSide(
                        //             color: Color.fromRGBO(10, 80, 106, 1),
                        //             width: 1),
                        //       ),
                        //       enabledBorder: OutlineInputBorder(
                        //         borderSide: BorderSide(width: 1),
                        //       ),
                        //       // isDense: true,
                        //       // suffix: Icon(Icons.mic),
                        //     ),
                        //     onChanged: (value) {
                        //       if (assessor == therapist &&
                        //           role == "therapist") {
                        //         FocusScope.of(context).requestFocus(focusNode);
                        //         new TextEditingController().clear();
                        //         // print(widget.accessname);
                        //         setdata(12, value, 'Observations');
                        //       } else if (role != "therapist") {
                        //         FocusScope.of(context).requestFocus(focusNode);
                        //         new TextEditingController().clear();
                        //         // print(widget.accessname);
                        //         setdata(12, value, 'Observations');
                        //       } else {
                        //         _showSnackBar(
                        //             "You can't change the other fields",
                        //             context);
                        //       }
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
                                      assesmentprovider.setreco(12, value);
                                      assesmentprovider.setdata(
                                          12, value, 'Oberservations');
                                    } else if (role != "therapist") {
                                      assesmentprovider.setreco(12, value);
                                      assesmentprovider.setdata(
                                          12, value, 'Oberservations');
                                    } else {
                                      _showSnackBar(
                                          "You can't change the other fields",
                                          context);
                                    }
                                  },
                                ),
                              ),
                              AvatarGlow(
                                animate: isRecognizing['field12'],
                                showTwoGlows: true,
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
                                      isRecognizing["field12"]
                                          ? Icons.stop_circle
                                          : Icons.mic,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      if (assessor == therapist &&
                                          role == "therapist") {
                                        // _listen(12);
                                        isRecognizing["field12"]
                                            ? stopRecording(12)
                                            : streamingRecognize(
                                                12, _controllers["field12"]);
                                        setdatalisten(12);
                                      } else if (role != "therapist") {
                                        // _listen(12);
                                        isRecognizing["field12"]
                                            ? stopRecording(12)
                                            : streamingRecognize(
                                                12, _controllers["field12"]);
                                        setdatalisten(12);
                                      } else {
                                        _showSnackBar(
                                            "You can't change the other fields",
                                            context);
                                      }
                                      setState(() {
                                        isListening["field12"] = false;
                                      });
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
                    onPressed: () {
                      var test =
                          widget.wholelist[8][widget.accessname]['complete'];
                      for (int i = 0;
                          i <
                              widget.wholelist[8][widget.accessname]['question']
                                  .length;
                          i++) {
                        setdatalisten(i + 1);
                        setdatalistenthera(i + 1);
                      }
                      // if (test == 0) {
                      //   _showSnackBar(
                      //       "You Must Have to Fill The Details First", context);
                      // } else {
                      if (role == "therapist") {
                        // if (saveToForm) {
                        NewAssesmentRepository()
                            .setLatestChangeDate(widget.docID);
                        NewAssesmentRepository()
                            .setForm(widget.wholelist, widget.docID);
                        Navigator.pop(
                            context, widget.wholelist[8][widget.accessname]);
                        // } else {
                        //   _showSnackBar(
                        //       "Provide all recommendations", context);
                        // }
                      } else {
                        NewAssesmentRepository()
                            .setLatestChangeDate(widget.docID);
                        NewAssesmentRepository()
                            .setForm(widget.wholelist, widget.docID);
                        Navigator.pop(
                            context, widget.wholelist[8][widget.accessname]);
                      }
                      // }
                    },
                  ))
                ],
              ),
            ),
          ),
        ),
        //////////////////////////////////////////////////
      ),
    );
  }

  Widget getrecomain(
      int index,
      bool isthera,
      String fieldlabel,
      BuildContext context,
      PatioProvider assesmentprovider,
      FocusNode focusNode) {
    return SingleChildScrollView(
      // reverse: true,
      child: Container(
        // color: Colors.yellow,
        child: Column(
          children: [
            SizedBox(height: 5),
            Container(
              child: TextFormField(
                focusNode: focusNode,
                maxLines: null,
                showCursor: cur,
                controller: _controllers["field$index"],
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: colorsset["field$index"], width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 1, color: colorsset["field$index"]),
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
                            animate: isRecognizing['field$index'],
                            glowColor: Colors.blue,
                            endRadius: 35.0,
                            duration: const Duration(milliseconds: 2000),
                            repeatPauseDuration:
                                const Duration(milliseconds: 100),
                            repeat: true,
                            child: FloatingActionButton(
                              heroTag: "btn$index",
                              child: Icon(
                                isRecognizing['field$index']
                                    ? Icons.stop_circle
                                    : Icons.mic,
                                size: 20,
                              ),
                              onPressed: () {
                                if (assessor == therapist &&
                                    role == "therapist") {
                                  // _listen(index);
                                  isRecognizing['field$index']
                                      ? stopRecording(index)
                                      : streamingRecognize(
                                          index, _controllers["field$index"]);
                                  setdatalisten(index);
                                } else if (role != "therapist") {
                                  isRecognizing['field$index']
                                      ? stopRecording(index)
                                      : streamingRecognize(
                                          index, _controllers["field$index"]);
                                  // _listen(index);
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
                    labelText: fieldlabel),
                onChanged: (value) {
                  if (assessor == therapist && role == "therapist") {
                    FocusScope.of(context).requestFocus(focusNode);
                    new TextEditingController().clear();
                    // print(widget.accessname);
                    assesmentprovider.setreco(index, value);
                  } else if (role != "therapist") {
                    FocusScope.of(context).requestFocus(focusNode);
                    new TextEditingController().clear();
                    // print(widget.accessname);
                    assesmentprovider.setreco(index, value);
                  } else {
                    _showSnackBar("You can't change the other fields", context);
                  }
                },
              ),
            ),
            (role == 'therapist' && isthera)
                ? getrecowid(index, context, assesmentprovider)
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget getrecowid(
      index, BuildContext context, PatioProvider assesmentprovider) {
    if (widget.wholelist[8][widget.accessname]["question"]["$index"]
            ["Recommendationthera"] !=
        "") {
      isColor = true;
      // saveToForm = true;
      // widget.wholelist[8][widget.accessname]["isSave"] = saveToForm;
    } else {
      isColor = false;
      // saveToForm = false;
      // widget.wholelist[8][widget.accessname]["isSave"] = saveToForm;
    }
    if (falseIndex == -1) {
      if (widget.wholelist[8][widget.accessname]["question"]["$index"]
              ["Recommendationthera"] !=
          "") {
        setState(() {
          saveToForm = true;
          trueIndex = index;
          widget.wholelist[8][widget.accessname]["isSaveThera"] = saveToForm;
        });
      } else {
        setState(() {
          saveToForm = false;
          falseIndex = index;
          widget.wholelist[8][widget.accessname]["isSaveThera"] = saveToForm;
        });
      }
    } else {
      if (index == falseIndex) {
        if (widget.wholelist[8][widget.accessname]["question"]["$index"]
                ["Recommendationthera"] !=
            "") {
          setState(() {
            widget.wholelist[8][widget.accessname]["isSaveThera"] = true;
            falseIndex = -1;
          });
        } else {
          setState(() {
            widget.wholelist[8][widget.accessname]["isSaveThera"] = false;
          });
        }
      }
    }
    return Column(
      children: [
        SizedBox(height: 8),
        TextFormField(
          controller: _controllerstreco["field$index"],
          decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: _controllerstreco["field$index"].text != ""
                        ? Colors.green
                        : Colors.red,
                    width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: 1,
                    color: _controllerstreco["field$index"].text != ""
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
                    child: AvatarGlow(
                      animate: isRecognizingThera['field$index'],
                      glowColor: Theme.of(context).primaryColor,
                      endRadius: 500.0,
                      duration: const Duration(milliseconds: 2000),
                      repeatPauseDuration: const Duration(milliseconds: 100),
                      repeat: true,
                      child: FloatingActionButton(
                        heroTag: "btn${index + 10}",
                        child: Icon(
                          isRecognizingThera['field$index']
                              ? Icons.stop_circle
                              : Icons.mic,
                          size: 20,
                        ),
                        onPressed: () {
                          // _listenthera(index);
                          isRecognizingThera['field$index']
                              ? stopRecordingThera(index)
                              : streamingRecognizeThera(
                                  index, _controllerstreco["field$index"]);
                          setdatalistenthera(index);
                        },
                      ),
                    ),
                  ),
                ]),
              ),
              labelStyle: TextStyle(
                  color: _controllerstreco["field$index"].text != ""
                      ? Colors.green
                      : Colors.red),
              labelText: 'Recommendation'),
          onChanged: (value) {
            // FocusScope.of(context).requestFocus(focusNode);
            // new TextEditingController().clear();
            // print(widget.accessname);
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
                    setState(() {
                      if (index == 11) {
                        _controllerstreco['field11'].text =
                            'Please install a well functioning Smoke detector Immediately. Most states have free Smoke Detectors available for FREE. Please contact your local Fire Department.';
                        assesmentprovider.setrecothera(11,
                            'Please install a well functioning Smoke detector Immediately. Most states have free Smoke Detectors available for FREE. Please contact your local Fire Department.');
                      }
                    });
                  },
                  groupValue: assesmentprovider.getprio(index),
                ),
                Text('1'),
                Radio(
                  value: '2',
                  onChanged: (value) {
                    setState(() {
                      assesmentprovider.setprio(index, value);
                      if (index == 11) {
                        _controllerstreco['field11'].text = '';
                        assesmentprovider.setrecothera(11, '');
                      }
                    });
                  },
                  groupValue: assesmentprovider.getprio(index),
                ),
                Text('2'),
                Radio(
                  value: '3',
                  onChanged: (value) {
                    setState(() {
                      assesmentprovider.setprio(index, value);
                      if (index == 11) {
                        _controllerstreco['field11'].text = '';
                        assesmentprovider.setrecothera(11, '');
                      }
                    });
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
                    initialValue: widget.wholelist[8][widget.accessname]
                            ['question']["9"]['MultipleStair']['step$index']
                        ['stepwidth'],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: colorsset["field${8}"], width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1, color: colorsset["field${8}"]),
                        ),
                        labelText: 'Step Width$index (Inches)'),
                    onChanged: (value) {
                      if (assessor == therapist && role == "therapist") {
                        setState(() {
                          widget.wholelist[8][widget.accessname]['question']
                                  ["9"]['MultipleStair']['step$index']
                              ['stepwidth'] = value;
                        });
                      } else if (role != "therapist") {
                        setState(() {
                          widget.wholelist[8][widget.accessname]['question']
                                  ["9"]['MultipleStair']['step$index']
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
                    initialValue: widget.wholelist[8][widget.accessname]
                            ['question']["9"]['MultipleStair']['step$index']
                        ['stepheight'],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: colorsset["field${8}"], width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1, color: colorsset["field${8}"]),
                        ),
                        labelText: 'Step Height$index (Inches)'),
                    onChanged: (value) {
                      if (assessor == therapist && role == "therapist") {
                        setState(() {
                          widget.wholelist[8][widget.accessname]['question']
                                  ["9"]['MultipleStair']['step$index']
                              ['stepheight'] = value;
                        });
                      } else if (role != "therapist") {
                        setState(() {
                          widget.wholelist[8][widget.accessname]['question']
                                  ["9"]['MultipleStair']['step$index']
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
            _controllerstreco["field$index"].text = widget.wholelist[8]
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
    setdatalistenthera(index);
  }

  setdatalistenthera(index) {
    setState(() {
      widget.wholelist[8][widget.accessname]['question']["$index"]
          ['Recommendationthera'] = _controllerstreco["field$index"].text;
      cur = !cur;
    });
  }

  void _listen(index) async {
    // print(!_isListening);
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          setState(() {
            if ('$val' == 'notListening') {
              _isListening = false;
              isListening['field$index'] = false;
              _speech.stop();
            } else {}
            print(isListening['field$index']);
          });
        },
        onError: (val) => print('onError: $val'),
      );

      if (available) {
        setState(() {
          _isListening = true;
          colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);

          isListening['field$index'] = true;
          print(isListening['field$index']);
        });
        // print("val " + '$available');
        _speech.listen(
          onResult: (val) => setState(() {
            _controllers["field$index"].text = widget.wholelist[8]
                        [widget.accessname]['question']["$index"]
                    ['Recommendation'] +
                " " +
                val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() {
        _isListening = false;
        // isListening['field$index'] = false;
        colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
      });
      _speech.stop();
    }
    setdatalisten(index);
  }

  setdatalisten(index) {
    setState(() {
      widget.wholelist[8][widget.accessname]['question']["$index"]
          ['Recommendation'] = _controllers["field$index"].text;
      cur = !cur;
    });
    if (index == 12) {
      if (_controllers["field$index"].text.length == 0) {
        if (widget
                .wholelist[8][widget.accessname]['question']["$index"]['Answer']
                .length ==
            0) {
        } else {
          widget.wholelist[8][widget.accessname]['complete'] -= 1;
          widget.wholelist[8][widget.accessname]['question']["$index"]
              ['Answer'] = _controllers["field$index"].text;
        }
      } else {
        if (widget
                .wholelist[8][widget.accessname]['question']["$index"]['Answer']
                .length ==
            0) {
          widget.wholelist[8][widget.accessname]['complete'] += 1;
        }

        widget.wholelist[8][widget.accessname]['question']["$index"]['Answer'] =
            _controllers["field$index"].text;
      }
    }
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
