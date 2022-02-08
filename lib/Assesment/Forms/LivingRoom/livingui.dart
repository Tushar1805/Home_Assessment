import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:tryapp/Assesment/Forms/LivingRoom/livingpro.dart';
import 'package:tryapp/Assesment/Forms/viewVideo.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentrepo.dart';
import 'package:tryapp/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

final _colorgreen = Color.fromRGBO(10, 80, 106, 1);

class LivingRoomUI extends StatefulWidget {
  String roomname, docID;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  LivingRoomUI(this.roomname, this.wholelist, this.accessname, this.docID);
  @override
  _LivingRoomUIState createState() => _LivingRoomUIState();
}

class _LivingRoomUIState extends State<LivingRoomUI> {
  stt.SpeechToText _speech;
  bool _isListening = false;
  double _confidence = 1.0;
  bool available = false, isColor = false;
  Map<String, Color> colorsset = {};
  Map<String, TextEditingController> _controllers = {};
  Map<String, TextEditingController> _controllerstreco = {};
  Map<String, bool> isListening = {};
  bool cur = true, saveToForm = false;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String assessor,
      curUid,
      therapist,
      role,
      videoDownloadUrl,
      videoUrl,
      videoName;
  File video;
  bool uploading = false;
  var falseIndex = -1, trueIndex = -1;
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    for (int i = 0;
        i < widget.wholelist[2][widget.accessname]['question'].length;
        i++) {
      _controllers["field${i + 1}"] = TextEditingController();
      _controllerstreco["field${i + 1}"] = TextEditingController();
      isListening["field${i + 1}"] = false;
      _controllers["field${i + 1}"].text = widget.wholelist[2]
          [widget.accessname]['question']["${i + 1}"]['Recommendation'];
      _controllerstreco["field${i + 1}"].text =
          '${widget.wholelist[2][widget.accessname]['question']["${i + 1}"]['Recommendationthera']}';
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
    // setinitials();
    getAssessData();
    getRole();
  }

  // Future<void> setinitials() async {
  //   if (widget.wholelist[2][widget.accessname].containsKey('isSave')) {
  //   } else {
  //     widget.wholelist[2][widget.accessname]["isSave"] = true;
  //   }
  //   if (widget.wholelist[2][widget.accessname].containsKey('videos')) {
  //     if (widget.wholelist[2][widget.accessname]['videos']
  //         .containsKey('name')) {
  //     } else {
  //       widget.wholelist[2][widget.accessname]['videos']['name'] = "";
  //     }
  //     if (widget.wholelist[2][widget.accessname]['videos'].containsKey('url')) {
  //     } else {
  //       widget.wholelist[2][widget.accessname]['videos']['url'] = "";
  //     }
  //   } else {
  //     // print('Yes,it is');

  //     widget.wholelist[2][widget.accessname]
  //         ["videos"] = {'name': '', 'url': ''};
  //   }

  //   if (widget.wholelist[2][widget.accessname]['question']["7"]
  //       .containsKey('doorwidth')) {
  //   } else {
  //     widget.wholelist[2][widget.accessname]['question']["7"]['doorwidth'] = 0;
  //   }
  // }

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
              videoUrl = widget.wholelist[2][widget.accessname]["videos"]["url"]
                      .toString() ??
                  "";
              videoName = widget.wholelist[2][widget.accessname]["videos"]
                          ["name"]
                      .toString() ??
                  "";
            }));
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

  // setdata(index, value, que) {
  //   widget.wholelist[2][widget.accessname]['question']["$index"]['Question'] =
  //       que;
  //   if (value.length == 0) {
  //     if (widget.wholelist[2][widget.accessname]['question']["$index"]['Answer']
  //             .length ==
  //         0) {
  //     } else {
  //       setState(() {
  //         widget.wholelist[2][widget.accessname]['complete'] -= 1;
  //         widget.wholelist[2][widget.accessname]['question']["$index"]
  //             ['Answer'] = value;
  //       });
  //     }
  //   } else {
  //     if (widget.wholelist[2][widget.accessname]['question']["$index"]['Answer']
  //             .length ==
  //         0) {
  //       setState(() {
  //         widget.wholelist[2][widget.accessname]['complete'] += 1;
  //       });
  //     }
  //     setState(() {
  //       widget.wholelist[2][widget.accessname]['question']["$index"]['Answer'] =
  //           value;
  //     });
  //   }
  // }

  // setreco(index, value) {
  //   setState(() {
  //     widget.wholelist[2][widget.accessname]['question']["$index"]
  //         ['Recommendation'] = value;
  //   });
  // }

  // getvalue(index) {
  //   return widget.wholelist[2][widget.accessname]['question']["$index"]
  //       ['Answer'];
  // }

  // getreco(index) {
  //   return widget.wholelist[2][widget.accessname]['question']["$index"]
  //       ['Recommendation'];
  // }

  // setrecothera(index, value) {
  //   setState(() {
  //     widget.wholelist[2][widget.accessname]['question']["$index"]
  //         ['Recommendationthera'] = value;
  //   });
  // }

  // setprio(index, value) {
  //   setState(() {
  //     widget.wholelist[2][widget.accessname]['question']["$index"]['Priority'] =
  //         value;
  //   });
  // }

  // getprio(index) {
  //   return widget.wholelist[2][widget.accessname]['question']["$index"]
  //       ['Priority'];
  // }

  // getrecothera(index) {
  //   return widget.wholelist[2][widget.accessname]['question']["$index"]
  //       ['Recommendationthera'];
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

  @override
  Widget build(BuildContext context) {
    LivingProvider provider = Provider.of<LivingProvider>(context);

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
          videoName = basename(videos.path);
          print("************Url = $videoName**********");
          widget.wholelist[2][widget.accessname]["videos"]["url"] = videoUrl;
          widget.wholelist[2][widget.accessname]["videos"]["name"] = videoName;
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
            provider.addVideo(pickedVideo.path);
            setState(() {
              upload(File(pickedVideo?.path));
            });
          } else {
            Navigator.pop(context);
            setState(() {});
            final snackBar = SnackBar(content: Text('Video Not Selected!'));
            provider.notifyListeners();
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          final pickedVideo =
              await ImagePicker().pickVideo(source: ImageSource.gallery);
          if (pickedVideo != null) {
            Navigator.pop(context);
            provider.addVideo(pickedVideo.path);
            setState(() {
              upload(File(pickedVideo?.path));
            });
          } else {
            Navigator.pop(context);
            setState(() {});
            final snackBar = SnackBar(content: Text('Video Not Selected!'));
            provider.notifyListeners();
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
      provider.notifyListeners();
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

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Assessment'),
          automaticallyImplyLeading: false,
          backgroundColor: _colorgreen,
          actions: [
            IconButton(
              icon: Icon(Icons.done_all, color: Colors.white),
              onPressed: () async {
                try {
                  var test = widget.wholelist[2][widget.accessname]["complete"];
                  for (int i = 0;
                      i <
                          widget.wholelist[2][widget.accessname]['question']
                              .length;
                      i++) {
                    // print(colorsset["field${i + 1}"]);
                    // if (colorsset["field${i + 1}"] == Colors.red) {
                    //   showDialog(
                    //       context: context,
                    //       builder: (context) => CustomDialog(
                    //           title: "Not Saved",
                    //           description:
                    //               "Please click cancel button to save the field"));
                    //   test = 1;
                    // }
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
                        context, widget.wholelist[0][widget.accessname]);
                    // } else {
                    //   _showSnackBar("Provide all recommendations", context);
                    // }
                  } else {
                    NewAssesmentRepository().setLatestChangeDate(widget.docID);
                    NewAssesmentRepository()
                        .setForm(widget.wholelist, widget.docID);
                    Navigator.pop(
                        context, widget.wholelist[0][widget.accessname]);
                  }
                  // }
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
                  Container(
                    width: double.infinity,
                    child: Card(
                      elevation: 8,
                      child: Container(
                        padding: EdgeInsets.all(25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .65,
                              child: Text(
                                '${widget.roomname} Details',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(10, 80, 106, 1),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.topRight,
                              width: 47,
                              decoration: BoxDecoration(
                                  color: _colorgreen,
                                  // border: Border.all(
                                  //   color: Colors.red[500],
                                  // ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              // color: Colors.red,
                              child: RawMaterialButton(
                                onPressed: () {
                                  if (videoUrl == "" && videoName == "") {
                                    if (curUid == assessor) {
                                      uploadVideo(context);
                                    } else {
                                      provider.showSnackBar(
                                          "You are not allowed to upload video",
                                          context);
                                    }
                                  } else {
                                    provider.showSnackBar(
                                        "You can add only one video", context);
                                  }
                                },
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
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
                                                  widget.wholelist[2]
                                                          [widget.accessname]
                                                      ["videos"]["name"] = "";
                                                  widget.wholelist[2]
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
                                                  widget.wholelist[2]
                                                          [widget.accessname]
                                                      ["videos"]["name"] = "";
                                                  widget.wholelist[2]
                                                          [widget.accessname]
                                                      ["videos"]["url"] = "";
                                                  deleteFile(videoUrl);
                                                  deleteVideo();
                                                  NewAssesmentRepository()
                                                      .setForm(widget.wholelist,
                                                          widget.docID);
                                                });
                                              } else {
                                                provider.showSnackBar(
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
                        SizedBox(height: 15),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .6,
                                child: Text('Threshold to Living Room',
                                    style: TextStyle(
                                      color: Color.fromRGBO(10, 80, 106, 1),
                                      fontSize: 20,
                                    )),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .25,
                                child: TextFormField(
                                    initialValue: widget.wholelist[2]
                                            [widget.accessname]['question']["1"]
                                        ['Answer'],
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
                                        provider.setdata(1, value,
                                            'Threshold to Living Room');
                                        FocusScope.of(context).requestFocus();
                                        new TextEditingController().clear();
                                        // print(widget.accessname);

                                      } else if (role != "therapist") {
                                        provider.setdata(1, value,
                                            'Threshold to Living Room');
                                        FocusScope.of(context).requestFocus();
                                        new TextEditingController().clear();
                                        // print(widget.accessname);

                                      } else {
                                        provider.showSnackBar(
                                            "You can't change the other fields",
                                            context);
                                      }
                                    }),
                              ),
                            ]),
                        SizedBox(height: 10),
                        (provider.getvalue(1) != "")
                            ? (double.parse(provider.getvalue(1)) > 5)
                                ? getrecomain(1, true, "Comments (if any)",
                                    context, provider)
                                : SizedBox()
                            : SizedBox(),
                        SizedBox(
                          height: 10,
                        ),
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
                                      provider.setdata(
                                          2, value, 'Flooring Type');
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);

                                    } else if (role != "therapist") {
                                      provider.setdata(
                                          2, value, 'Flooring Type');
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                    } else {
                                      provider.showSnackBar(
                                          "You can't change the other fields",
                                          context);
                                    }
                                  },
                                  value: provider.getvalue(2)),
                            )
                          ],
                        ),
                        (provider.getvalue(2) == 'Wood - Smooth Finish' ||
                                provider.getvalue(2) == 'Tile - Smooth Finish')
                            ? getrecomain(
                                2, true, "Comments (if any)", context, provider)
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
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
                                    provider.setdata(
                                        3, value, 'Floor Coverage');
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);

                                  } else if (role != "therapist") {
                                    provider.setdata(
                                        3, value, 'Floor Coverage');
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                  } else {
                                    provider.showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                                value: provider.getvalue(3),
                              ),
                            )
                          ],
                        ),
                        (provider.getvalue(3) != 'No covering' &&
                                provider.getvalue(3) != '')
                            ? getrecomain(
                                3, true, 'Comments (if any)', context, provider)
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
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
                                      provider.setdata(
                                          4, value, 'Lighting Type');
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);

                                    } else if (role != "therapist") {
                                      provider.setdata(
                                          4, value, 'Lighting Type');
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                    } else {
                                      provider.showSnackBar(
                                          "You can't change the other fields",
                                          context);
                                    }
                                  },
                                  value: provider.getvalue(4)),
                            )
                          ],
                        ),
                        (provider.getvalue(4) == 'Inadequate')
                            ? getrecomain(
                                4, true, 'Specify Type', context, provider)
                            : SizedBox(),
                        SizedBox(height: 15),
                        // Divider(
                        //   height: dividerheight,
                        //   color: Color.fromRGBO(10, 20, 102, 1),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .6,
                              child: Text('Able to Operate Switches?',
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
                                      child: Text('Yes'),
                                      value: 'Yes',
                                    ),
                                    DropdownMenuItem(
                                      child: Text('No'),
                                      value: 'No',
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (assessor == therapist &&
                                        role == "therapist") {
                                      provider.setdata(5, value,
                                          'Able to Operate Switches?');
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);

                                    } else if (role != "therapist") {
                                      provider.setdata(5, value,
                                          'Able to Operate Switches?');
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                    } else {
                                      provider.showSnackBar(
                                          "You can't change the other fields",
                                          context);
                                    }
                                  },
                                  value: provider.getvalue(5)),
                            ),
                          ],
                        ),
                        (provider.getvalue(5) == 'No' &&
                                provider.getvalue(5) != '')
                            ? getrecomain(
                                5, true, 'Comments(if any)', context, provider)
                            : SizedBox(),

                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Switch Type',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            Container(
                              child: DropdownButton(
                                  // items: [
                                  //   DropdownMenuItem(
                                  //     child: Text('--'),
                                  //     value: '',
                                  //   ),
                                  //   DropdownMenuItem(
                                  //     child: Text('Push Button'),
                                  //     value: 'pushbutton',
                                  //   ),
                                  //   DropdownMenuItem(
                                  //     child: Text('Rotary'),
                                  //     value: 'rotary',
                                  //   ),
                                  //   DropdownMenuItem(
                                  //     child: Text('Toggle'),
                                  //     value: 'toggle',
                                  //   ),
                                  //   DropdownMenuItem(
                                  //     child: Text('Slide'),
                                  //     value: 'slide',
                                  //   ),
                                  // ],
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
                                      provider.setdata(6, value, 'Switch Type');
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);

                                    } else if (role != "therapist") {
                                      provider.setdata(6, value, 'Switch Type');
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                    } else {
                                      provider.showSnackBar(
                                          "You can't change the other fields",
                                          context);
                                    }
                                  },
                                  value: provider.getvalue(6)),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
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
                                  initialValue: provider.getvalue(7),
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
                                  onChanged: (value) {
                                    if (assessor == therapist &&
                                        role == "therapist") {
                                      provider.setdata(7, value, 'Door Width');
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);

                                      setState(() {
                                        widget.wholelist[2][widget.accessname]
                                            ['question']["7"]['doorwidth'] = 0;

                                        widget.wholelist[2][widget.accessname]
                                                ['question']["7"]['doorwidth'] =
                                            double.parse(value);
                                      });
                                    } else if (role != "therapist") {
                                      provider.setdata(7, value, 'Door Width');
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);

                                      widget.wholelist[2][widget.accessname]
                                          ['question']["7"]['doorwidth'] = 0;

                                      widget.wholelist[2][widget.accessname]
                                              ['question']["7"]['doorwidth'] =
                                          double.parse(value);
                                    } else {
                                      provider.showSnackBar(
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
                        (widget.wholelist[2][widget.accessname]['question']["7"]
                                        ['doorwidth'] <
                                    30 &&
                                widget.wholelist[2][widget.accessname]
                                        ['question']["7"]['doorwidth'] >
                                    0 &&
                                widget.wholelist[2][widget.accessname]
                                        ['question']["7"]['doorwidth'] !=
                                    '')
                            ? getrecomain(
                                7, true, 'Comments (if any)', context, provider)
                            : SizedBox(),
                        SizedBox(
                          height: 15,
                        ),
                        // Divider(
                        //   height: dividerheight,
                        //   color: Color.fromRGBO(10, 70, 102, 1),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .6,
                              child: Text('Obstacle/Clutter Present?',
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
                                )
                              ],
                              onChanged: (value) {
                                if (assessor == therapist &&
                                    role == "therapist") {
                                  provider.setdata(
                                      8, value, 'Obstacle/Clutter Present?');
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);

                                } else if (role != "therapist") {
                                  provider.setdata(
                                      8, value, 'Obstacle/Clutter Present?');
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                } else {
                                  provider.showSnackBar(
                                      "You can't change the other fields",
                                      context);
                                }
                              },
                              value: provider.getvalue(8),
                            )
                          ],
                        ),
                        (provider.getvalue(8) == 'Yes')
                            ? getrecomain(
                                8, true, 'Specify Clutter', context, provider)
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .6,
                              child: Text('Able to Access Telephone?',
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
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    provider.setdata(
                                        9, value, 'Able to Access Telephone?');
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);

                                  } else if (role != "therapist") {
                                    provider.setdata(
                                        9, value, 'Able to Access Telephone?');
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                  } else {
                                    provider.showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                                value: provider.getvalue(9))
                          ],
                        ),
                        (provider.getvalue(9) != 'Yes' &&
                                provider.getvalue(9) != '')
                            ? getrecomain(
                                9, true, 'Comments (if any)', context, provider)
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .5,
                                        child: Text('Telephone Type?',
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
                                            child: Text('Wired'),
                                            value: 'Wired',
                                          ),
                                          DropdownMenuItem(
                                            child: Text('Cordless'),
                                            value: 'Cordless',
                                          ),
                                          DropdownMenuItem(
                                            child: Text('Cellphone'),
                                            value: 'Cellphone',
                                          ),
                                          DropdownMenuItem(
                                            child: Text('Intercom'),
                                            value: 'Intercom',
                                          ),
                                        ],
                                        onChanged: (value) {
                                          if (assessor == therapist &&
                                              role == "therapist") {
                                            FocusScope.of(context)
                                                .requestFocus();
                                            new TextEditingController().clear();
                                            // print(widget.accessname);
                                            widget.wholelist[2]
                                                        [widget.accessname]
                                                    ['question']["9"]
                                                ['telephoneType'] = value;
                                          } else if (role != "therapist") {
                                            FocusScope.of(context)
                                                .requestFocus();
                                            new TextEditingController().clear();
                                            // print(widget.accessname);
                                            widget.wholelist[2]
                                                        [widget.accessname]
                                                    ['question']["9"]
                                                ['telephoneType'] = value;
                                          } else {
                                            provider.showSnackBar(
                                                "You can't change the other fields",
                                                context);
                                          }
                                        },
                                        value: widget.wholelist[2]
                                                [widget.accessname]['question']
                                            ["9"]['telephoneType'],
                                      ),
                                    ]),
                              ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .6,
                              child: Text('Smoke Detector Present?',
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
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    provider.setdata(
                                        10, value, 'Smoke Detector Present?');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    provider.setdata(
                                        10, value, 'Smoke Detector Present?');
                                  } else {
                                    provider.showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                                value: provider.getvalue(10))
                          ],
                        ),
                        (provider.getvalue(10) == 'No')
                            ? getrecomain(10, true, 'Comments (if any)',
                                context, provider)
                            : SizedBox(),
                        SizedBox(height: 15),
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
                          height: 5,
                        ),
                        Container(
                            // height: 10000,
                            child: TextFormField(
                          initialValue: widget.wholelist[2][widget.accessname]
                              ['question']['11']['Answer'],
                          maxLines: 6,
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
                          ),
                          onChanged: (value) {
                            if (assessor == therapist && role == "therapist") {
                              FocusScope.of(context).requestFocus();
                              new TextEditingController().clear();
                              provider.setdata(11, value, "Observations");
                            } else if (role != "therapist") {
                              FocusScope.of(context).requestFocus();
                              new TextEditingController().clear();
                              provider.setdata(11, value, "Observations");
                            } else {
                              provider.showSnackBar(
                                  "You can't change the other fields", context);
                            }
                            //   FocusScope.of(context).requestFocus();
                            //   new TextEditingController().clear();
                            //   // print(widget.accessname);
                            //   widget.wholelist[2][widget.accessname]['question']
                            //       ["11"]['Question'] = 'Observations';

                            //   if (value.length == 0) {
                            //     if (widget
                            //             .wholelist[2][widget.accessname]
                            //                 ['question']['11']['Answer']
                            //             .length ==
                            //         0) {
                            //     } else {
                            //       setState(() {
                            //         widget.wholelist[2][widget.accessname]
                            //             ['complete'] -= 1;
                            //         widget.wholelist[2][widget.accessname]
                            //             ['question']["11"]['Answer'] = value;
                            //       });
                            //     }
                            //   } else {
                            //     if (widget
                            //             .wholelist[2][widget.accessname]
                            //                 ['question']["11"]['Answer']
                            //             .length ==
                            //         0) {
                            //       setState(() {
                            //         widget.wholelist[2][widget.accessname]
                            //             ['complete'] += 1;
                            //       });
                            //     }
                            //     setState(() {
                            //       widget.wholelist[2][widget.accessname]
                            //           ['question']["11"]['Answer'] = value;
                            //     });
                            //   }
                          },
                        ))
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
                          widget.wholelist[2][widget.accessname]["complete"];
                      for (int i = 0;
                          i <
                              widget.wholelist[2][widget.accessname]['question']
                                  .length;
                          i++) {
                        // print(colorsset["field${i + 1}"]);
                        // if (colorsset["field${i + 1}"] == Colors.red) {
                        //   showDialog(
                        //       context: context,
                        //       builder: (context) => CustomDialog(
                        //           title: "Not Saved",
                        //           description:
                        //               "Please click cancel button to save the field"));
                        //   test = 1;
                        // }
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
                            context, widget.wholelist[0][widget.accessname]);
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
                            context, widget.wholelist[0][widget.accessname]);
                      }
                      // }
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

  Widget getrecomain(int index, bool isthera, String fieldlabel,
      BuildContext context, LivingProvider provider) {
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
                      ]),
                    ),
                    labelText: fieldlabel),
                onChanged: (value) {
                  if (assessor == therapist && role == "therapist") {
                    FocusScope.of(context).requestFocus();
                    new TextEditingController().clear();
                    // print(widget.accessname);
                    provider.setreco(index, value);
                  } else if (role != "therapist") {
                    FocusScope.of(context).requestFocus();
                    new TextEditingController().clear();
                    // print(widget.accessname);
                    provider.setreco(index, value);
                  } else {
                    _showSnackBar("You can't change the other fields", context);
                  }
                },
              ),
            ),
            (role == 'therapist' && isthera)
                ? getrecowid(index, context, provider)
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget getrecowid(index, BuildContext context, LivingProvider provider) {
    if (widget.wholelist[2][widget.accessname]["question"]["$index"]
            ["Recommendationthera"] !=
        "") {
      isColor = true;
      // saveToForm = true;
      // widget.wholelist[2][widget.accessname]["isSave"] = saveToForm;
    } else {
      isColor = false;
      // saveToForm = false;
      // widget.wholelist[2][widget.accessname]["isSave"] = saveToForm;
    }
    if (falseIndex == -1) {
      if (widget.wholelist[2][widget.accessname]["question"]["$index"]
              ["Recommendationthera"] !=
          "") {
        setState(() {
          saveToForm = true;
          trueIndex = index;
          widget.wholelist[2][widget.accessname]["isSave"] = saveToForm;
        });
      } else {
        setState(() {
          saveToForm = false;
          falseIndex = index;
          widget.wholelist[2][widget.accessname]["isSave"] = saveToForm;
        });
      }
    } else {
      if (index == falseIndex) {
        if (widget.wholelist[2][widget.accessname]["question"]["$index"]
                ["Recommendationthera"] !=
            "") {
          setState(() {
            widget.wholelist[2][widget.accessname]["isSave"] = true;
            falseIndex = -1;
          });
        } else {
          setState(() {
            widget.wholelist[2][widget.accessname]["isSave"] = false;
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
            FocusScope.of(context).requestFocus();
            new TextEditingController().clear();
            // print(widget.accessname);
            provider.setrecothera(index, value);
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
                    provider.setprio(index, value);
                  },
                  groupValue: provider.getprio(index),
                ),
                Text('1'),
                Radio(
                  value: '2',
                  onChanged: (value) {
                    setState(() {
                      provider.setprio(index, value);
                    });
                  },
                  groupValue: provider.getprio(index),
                ),
                Text('2'),
                Radio(
                  value: '3',
                  onChanged: (value) {
                    setState(() {
                      provider.setprio(index, value);
                    });
                  },
                  groupValue: provider.getprio(index),
                ),
                Text('3'),
              ],
            )
          ],
        )
      ],
    );
  }

  void _listen(index) async {
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
          colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
          isListening['field$index'] = true;
        });
        _speech.listen(
          onResult: (val) => setState(() {
            _controllers["field$index"].text = widget.wholelist[2]
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
        isListening['field$index'] = false;
        colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
      });
      _speech.stop();
    }
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
  }

  setdatalistenthera(index) {
    setState(() {
      widget.wholelist[8][widget.accessname]['question']["$index"]
          ['Recommendationthera'] = _controllerstreco["field$index"].text;
      cur = !cur;
    });
  }

  setdatalisten(index) {
    setState(() {
      widget.wholelist[2][widget.accessname]['question']["$index"]
          ['Recommendation'] = _controllers["field$index"].text;
      cur = !cur;
    });
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
