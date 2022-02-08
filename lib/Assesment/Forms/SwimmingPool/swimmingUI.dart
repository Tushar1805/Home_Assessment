import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:tryapp/Assesment/Forms/SwimmingPool/swimmingpro.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentrepo.dart';
import 'package:path/path.dart';

import '../../../constants.dart';
import '../viewVideo.dart';

final _colorgreen = Color.fromRGBO(10, 80, 106, 1);

class SwimmingPoolUI extends StatefulWidget {
  String roomname, docID;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  SwimmingPoolUI(this.roomname, this.wholelist, this.accessname, this.docID,
      {Key key})
      : super(key: key);

  @override
  _SwimmingPoolUIState createState() => _SwimmingPoolUIState();
}

class _SwimmingPoolUIState extends State<SwimmingPoolUI> {
  stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isListeningExplain = false;
  bool available = false;
  Map<String, Color> colorsset = {};
  FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, TextEditingController> _controllers = {};
  Map<String, TextEditingController> _controllerstreco = {};
  TextEditingController _explain;
  Map<String, bool> isListening = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final firestoreInstance = FirebaseFirestore.instance;
  bool cur = true;
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

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    for (int i = 0;
        i < widget.wholelist[11][widget.accessname]['question'].length;
        i++) {
      _controllers["field${i + 1}"] = TextEditingController();
      _controllerstreco["field${i + 1}"] = TextEditingController();
      isListening["field${i + 1}"] = false;
      _controllers["field${i + 1}"].text = widget.wholelist[11]
          [widget.accessname]['question']["${i + 1}"]['Recommendation'];
      _controllerstreco["field${i + 1}"].text =
          '${widget.wholelist[11][widget.accessname]['question']["${i + 1}"]['Recommendationthera']}';
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
    getRole();
    getAssessData();
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
            role = "therapist";
          }
        }
      } else {
        role = value.data()["role"];
      }
    });
  }

  Future<void> getAssessData() async {
    final User user = await _auth.currentUser;
    print(widget.docID);
    firestoreInstance
        .collection("assessments")
        .doc(widget.docID)
        .get()
        .then((value) => setState(() {
              curUid = user.uid;
              assessor = value["assessor"];
              therapist = value["therapist"];
              videoUrl = widget.wholelist[11][widget.accessname]["videos"]
                          ["url"]
                      .toString() ??
                  "";
              videoName = widget.wholelist[11][widget.accessname]["videos"]
                          ["name"]
                      .toString() ??
                  "";
            }));
  }

  Future<void> setinitialsdata() async {
    if (widget.wholelist[11][widget.accessname].containsKey('isSave')) {
    } else {
      widget.wholelist[11][widget.accessname]["isSave"] = true;
    }

    if (widget.wholelist[11][widget.accessname].containsKey('videos')) {
      if (widget.wholelist[11][widget.accessname]['videos']
          .containsKey('name')) {
      } else {
        widget.wholelist[11][widget.accessname]['videos']['name'] = "";
      }
      if (widget.wholelist[11][widget.accessname]['videos']
          .containsKey('url')) {
      } else {
        widget.wholelist[11][widget.accessname]['videos']['url'] = "";
      }
    } else {
      // print('Yes,it is');

      widget.wholelist[11][widget.accessname]
          ["videos"] = {'name': '', 'url': ''};
    }

    if (widget.wholelist[11][widget.accessname]['question']["1"]
        .containsKey('aboveGround')) {
    } else {
      widget.wholelist[11][widget.accessname]['question']["1"]['aboveGround'] =
          {'adaptationAvailable': "", 'explain': "", 'isClientSafe': ""};
    }

    if (widget.wholelist[11][widget.accessname]['question']["1"]
        .containsKey('inGround')) {
    } else {
      widget.wholelist[11][widget.accessname]['question']["1"]
          ['inGround'] = {'adaptationAvailable': "", 'isClientSafe': ""};
    }
  }

  setdata(index, value, que) {
    widget.wholelist[11][widget.accessname]['question']["$index"]['Question'] =
        que;
  }

  setreco(index, value) {
    setState(() {
      widget.wholelist[11][widget.accessname]['question']["$index"]
          ['Recommendation'] = value;
    });
  }

  getvalue(index) {
    return widget.wholelist[11][widget.accessname]['question']["$index"]
        ['Answer'];
  }

  getreco(index) {
    return widget.wholelist[11][widget.accessname]['question']["$index"]
        ['Recommendation'];
  }

  setprio(index, value) {
    setState(() {
      widget.wholelist[11][widget.accessname]['question']["$index"]
          ['Priority'] = value;
    });
  }

  getprio(index) {
    return widget.wholelist[11][widget.accessname]['question']["$index"]
        ['Priority'];
  }

  setrecothera(index, value) {
    // final isValid = _formKey.currentState.validate();
    // if (!isValid) {
    //   return;
    // } else {
    setState(() {
      widget.wholelist[11][widget.accessname]['question']["$index"]
          ['Recommendationthera'] = value;
    });
    // }
  }

  getrecothera(index) {
    return widget.wholelist[11][widget.accessname]['question']["$index"]
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
    final assesspro = Provider.of<SwimmingPoolProvider>(context);

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
          widget.wholelist[11][widget.accessname]["videos"]["url"] = videoUrl;
          widget.wholelist[11][widget.accessname]["videos"]["name"] = videoName;
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
                  var test =
                      widget.wholelist[11][widget.accessname]["complete"];
                  for (int i = 0;
                      i <
                          widget.wholelist[11][widget.accessname]['question']
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
                        context, widget.wholelist[11][widget.accessname]);
                    // }
                  } else {
                    NewAssesmentRepository().setLatestChangeDate(widget.docID);
                    NewAssesmentRepository()
                        .setForm(widget.wholelist, widget.docID);
                    Navigator.pop(
                        context, widget.wholelist[11][widget.accessname]);
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
                  Container(
                    width: double.infinity,
                    child: Card(
                      elevation: 8,
                      child: Container(
                        // width: MediaQuery.of(context).size.width / 10,
                        padding: EdgeInsets.all(25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width / 1.6,
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
                              width: 45,
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
                                      _showSnackBar(
                                          "You are not allowed to upload video",
                                          context);
                                    }
                                  } else {
                                    _showSnackBar(
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
                                                  widget.wholelist[11]
                                                          [widget.accessname]
                                                      ["videos"]["name"] = "";
                                                  widget.wholelist[11]
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
                                                  widget.wholelist[11]
                                                          [widget.accessname]
                                                      ["videos"]["name"] = "";
                                                  widget.wholelist[11]
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
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Type of pool',
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
                                    child: Text('Above-Ground'),
                                    value: 'Above-Ground',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('In-Ground'),
                                    value: 'In-Ground',
                                  ),
                                ],
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    assesspro.setdata(1, value, 'Type of pool');
                                  } else if (role != "therapist" &&
                                      (role == "patient" ||
                                          role == "nurse/case manager")) {
                                    assesspro.setdata(1, value, 'Type of pool');
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
                        (getvalue(1) != '')
                            ? (getvalue(1) == 'Above-Ground')
                                ? Container(
                                    // padding: EdgeInsets.all(15),
                                    child: Column(children: [
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .5,
                                          child: Text('Adaptations Available',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    10, 80, 106, 1),
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
                                              FocusScope.of(context)
                                                  .requestFocus();
                                              new TextEditingController()
                                                  .clear();
                                              if (assessor == therapist &&
                                                  role == "therapist") {
                                                widget.wholelist[11][widget
                                                                    .accessname]
                                                                ['question']["1"]
                                                            ['aboveGround'][
                                                        'adaptationAvailable'] =
                                                    value;
                                              } else if (role != "therapist" &&
                                                  (role == "patient" ||
                                                      role ==
                                                          "nurse/case manager")) {
                                                widget.wholelist[11][widget
                                                                    .accessname]
                                                                ['question']["1"]
                                                            ['aboveGround'][
                                                        'adaptationAvailable'] =
                                                    value;
                                              } else {
                                                _showSnackBar(
                                                    "You can't change the other fields",
                                                    context);
                                              }
                                            },
                                            value: widget.wholelist[11]
                                                            [widget.accessname]
                                                        ['question']["1"]
                                                    ['aboveGround']
                                                ['adaptationAvailable'],
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    (widget.wholelist[11][widget.accessname]
                                                        ['question']["1"]
                                                    ['aboveGround']
                                                ['adaptationAvailable'] ==
                                            'Yes')
                                        ? Container(
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .6,
                                                      child: Text(
                                                          'Explain what adaptation',
                                                          style: TextStyle(
                                                            color:
                                                                Color.fromRGBO(
                                                                    10,
                                                                    80,
                                                                    106,
                                                                    1),
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
                                                  initialValue: widget
                                                                  .wholelist[11]
                                                              [
                                                              widget.accessname]
                                                          ['question']["1"][
                                                      'aboveGround']['explain'],
                                                  maxLines: 1,
                                                  controller: _explain,
                                                  decoration: InputDecoration(
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: colorsset[
                                                              "field${1}"],
                                                          width: 1),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          width: 1,
                                                          color: colorsset[
                                                              "field${1}"]),
                                                    ),
                                                    suffix: Container(
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      child: Column(children: [
                                                        Container(
                                                          alignment: Alignment
                                                              .topRight,
                                                          width: 58,
                                                          height: 30,
                                                          margin:
                                                              EdgeInsets.all(0),
                                                          child: AvatarGlow(
                                                            animate:
                                                                _isListeningExplain,
                                                            glowColor: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            endRadius: 300.0,
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        2000),
                                                            repeatPauseDuration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        100),
                                                            repeat: true,
                                                            child: FlatButton(
                                                              child: Icon(
                                                                  _isListeningExplain
                                                                      ? Icons
                                                                          .cancel
                                                                      : Icons
                                                                          .mic),
                                                              onPressed:
                                                                  () async {
                                                                if (assessor ==
                                                                        therapist &&
                                                                    role ==
                                                                        "therapist") {
                                                                  if (!_isListeningExplain) {
                                                                    bool
                                                                        available =
                                                                        await _speech
                                                                            .initialize(
                                                                      onStatus:
                                                                          (val) {
                                                                        print(
                                                                            'onStatus: $val');
                                                                        setState(
                                                                            () {
                                                                          // _isListening = false;
                                                                          //
                                                                        });
                                                                      },
                                                                      onError: (val) =>
                                                                          print(
                                                                              'onError: $val'),
                                                                    );
                                                                    if (available) {
                                                                      setState(
                                                                          () {
                                                                        _isListeningExplain =
                                                                            true;
                                                                        //colorsset["field$index"] = Colors.red;
                                                                      });
                                                                      _speech
                                                                          .listen(
                                                                        onResult:
                                                                            (val) =>
                                                                                setState(() {
                                                                          _explain.text = widget.wholelist[11][widget.accessname]['question']["1"]['aboveGround']['explain'] +
                                                                              " " +
                                                                              val.recognizedWords;
                                                                        }),
                                                                      );
                                                                    }
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      _isListeningExplain =
                                                                          false;
                                                                      colorsset[
                                                                              "1"] =
                                                                          Color.fromRGBO(
                                                                              10,
                                                                              80,
                                                                              106,
                                                                              1);
                                                                    });
                                                                    _speech
                                                                        .stop();
                                                                  }
                                                                  setState(() {
                                                                    widget.wholelist[
                                                                            11][
                                                                        widget
                                                                            .accessname]['question']["1"]['aboveGround']['explain'] = _explain
                                                                        .text;
                                                                  });
                                                                } else if (role !=
                                                                    "therapist") {
                                                                  if (!_isListeningExplain) {
                                                                    bool
                                                                        available =
                                                                        await _speech
                                                                            .initialize(
                                                                      onStatus:
                                                                          (val) {
                                                                        print(
                                                                            'onStatus: $val');
                                                                        setState(
                                                                            () {
                                                                          // _isListening = false;
                                                                          //
                                                                        });
                                                                      },
                                                                      onError: (val) =>
                                                                          print(
                                                                              'onError: $val'),
                                                                    );
                                                                    if (available) {
                                                                      setState(
                                                                          () {
                                                                        _isListeningExplain =
                                                                            true;
                                                                        //colorsset["field$index"] = Colors.red;
                                                                      });
                                                                      _speech
                                                                          .listen(
                                                                        onResult:
                                                                            (val) =>
                                                                                setState(() {
                                                                          _explain.text = widget.wholelist[11][widget.accessname]['question']["1"]['aboveGround']['explain'] +
                                                                              " " +
                                                                              val.recognizedWords;
                                                                        }),
                                                                      );
                                                                    }
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      _isListeningExplain =
                                                                          false;
                                                                      colorsset[
                                                                              "1"] =
                                                                          Color.fromRGBO(
                                                                              10,
                                                                              80,
                                                                              106,
                                                                              1);
                                                                    });
                                                                    _speech
                                                                        .stop();
                                                                  }
                                                                  setState(() {
                                                                    widget.wholelist[
                                                                            11][
                                                                        widget
                                                                            .accessname]['question']["1"]['aboveGround']['explain'] = _explain
                                                                        .text;
                                                                  });
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
                                                    FocusScope.of(context)
                                                        .requestFocus();
                                                    new TextEditingController()
                                                        .clear();
                                                    // print(widget.accessname);
                                                    if (assessor == therapist &&
                                                        role == "therapist") {
                                                      setState(() {
                                                        widget.wholelist[11][widget
                                                                        .accessname]
                                                                    ['question']
                                                                [
                                                                "1"]['aboveGround']
                                                            ['explain'] = value;
                                                        _explain
                                                            .text = widget.wholelist[
                                                                        11][
                                                                    widget
                                                                        .accessname]
                                                                [
                                                                'question']["1"]
                                                            [
                                                            'aboveGround']['explain'];
                                                      });
                                                    } else if (role !=
                                                        "therapist") {
                                                      setState(() {
                                                        widget.wholelist[11][widget
                                                                        .accessname]
                                                                    ['question']
                                                                [
                                                                "1"]['aboveGround']
                                                            ['explain'] = value;
                                                        _explain
                                                            .text = widget.wholelist[
                                                                        11][
                                                                    widget
                                                                        .accessname]
                                                                [
                                                                'question']["1"]
                                                            [
                                                            'aboveGround']['explain'];
                                                      });
                                                    } else {
                                                      _showSnackBar(
                                                          "You can't change the other fields",
                                                          context);
                                                    }
                                                  },
                                                )),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .5,
                                                      child: Text(
                                                          'Can the Client Safely use the adaptations?',
                                                          style: TextStyle(
                                                            color:
                                                                Color.fromRGBO(
                                                                    10,
                                                                    80,
                                                                    106,
                                                                    1),
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
                                                          FocusScope.of(context)
                                                              .requestFocus();
                                                          new TextEditingController()
                                                              .clear();
                                                          if (assessor ==
                                                                  therapist &&
                                                              role ==
                                                                  "therapist") {
                                                            widget.wholelist[11]
                                                                            [
                                                                            widget
                                                                                .accessname]
                                                                        [
                                                                        'question']["1"]
                                                                    [
                                                                    'aboveGround']
                                                                [
                                                                'isClientSafe'] = value;
                                                          } else if (role !=
                                                                  "therapist" &&
                                                              (role ==
                                                                      "patient" ||
                                                                  role ==
                                                                      "nurse/case manager")) {
                                                            widget.wholelist[11]
                                                                            [
                                                                            widget
                                                                                .accessname]
                                                                        [
                                                                        'question']["1"]
                                                                    [
                                                                    'aboveGround']
                                                                [
                                                                'isClientSafe'] = value;
                                                          } else {
                                                            _showSnackBar(
                                                                "You can't change the other fields",
                                                                context);
                                                          }
                                                        },
                                                        value: widget.wholelist[
                                                                            11][
                                                                        widget
                                                                            .accessname]
                                                                    ['question']
                                                                [
                                                                "1"]['aboveGround']
                                                            ['isClientSafe'],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                (widget.wholelist[11][widget
                                                                        .accessname]
                                                                    ['question']
                                                                [
                                                                "1"]['aboveGround']
                                                            ['isClientSafe'] ==
                                                        'No')
                                                    ? getrecomain(
                                                        1, true, context)
                                                    : SizedBox(),
                                              ],
                                            ),
                                          )
                                        : SizedBox(),
                                  ]))
                                : Container(
                                    // padding: EdgeInsets.all(15),
                                    child: Column(children: [
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .5,
                                          child: Text('Adaptations Available',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    10, 80, 106, 1),
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
                                              FocusScope.of(context)
                                                  .requestFocus();
                                              new TextEditingController()
                                                  .clear();
                                              if (assessor == therapist &&
                                                  role == "therapist") {
                                                widget.wholelist[11][widget
                                                                    .accessname]
                                                                ['question']["1"]
                                                            ['inGround'][
                                                        'adaptationAvailable'] =
                                                    value;
                                              } else if (role != "therapist" &&
                                                  (role == "patient" ||
                                                      role ==
                                                          "nurse/case manager")) {
                                                widget.wholelist[11][widget
                                                                    .accessname]
                                                                ['question']["1"]
                                                            ['inGround'][
                                                        'adaptationAvailable'] =
                                                    value;
                                              } else {
                                                _showSnackBar(
                                                    "You can't change the other fields",
                                                    context);
                                              }
                                            },
                                            value: widget.wholelist[11]
                                                            [widget.accessname]
                                                        ['question']["1"]
                                                    ['inGround']
                                                ['adaptationAvailable'],
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    (widget.wholelist[11][widget.accessname]
                                                        ['question']["1"]
                                                    ['aboveGround']
                                                ['adaptationAvailable'] ==
                                            'Yes')
                                        ? Container(
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .5,
                                                      child: Text(
                                                          'Can the Client Safely use the adaptations?',
                                                          style: TextStyle(
                                                            color:
                                                                Color.fromRGBO(
                                                                    10,
                                                                    80,
                                                                    106,
                                                                    1),
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
                                                          FocusScope.of(context)
                                                              .requestFocus();
                                                          new TextEditingController()
                                                              .clear();
                                                          if (assessor ==
                                                                  therapist &&
                                                              role ==
                                                                  "therapist") {
                                                            widget.wholelist[11]
                                                                            [
                                                                            widget
                                                                                .accessname]
                                                                        [
                                                                        'question']
                                                                    [
                                                                    "1"]['inGround']
                                                                [
                                                                'isClientSafe'] = value;
                                                          } else if (role !=
                                                                  "therapist" &&
                                                              (role ==
                                                                      "patient" ||
                                                                  role ==
                                                                      "nurse/case manager")) {
                                                            widget.wholelist[11]
                                                                            [
                                                                            widget
                                                                                .accessname]
                                                                        [
                                                                        'question']
                                                                    [
                                                                    "1"]['inGround']
                                                                [
                                                                'isClientSafe'] = value;
                                                          } else {
                                                            _showSnackBar(
                                                                "You can't change the other fields",
                                                                context);
                                                          }
                                                        },
                                                        value: widget.wholelist[
                                                                            11][
                                                                        widget
                                                                            .accessname]
                                                                    ['question']
                                                                [
                                                                "1"]['inGround']
                                                            ['isClientSafe'],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                (widget.wholelist[11][widget
                                                                        .accessname]
                                                                    ['question']
                                                                [
                                                                "1"]['inGround']
                                                            ['isClientSafe'] ==
                                                        'No')
                                                    ? getrecomain(
                                                        1, true, context)
                                                    : SizedBox(),
                                              ],
                                            ),
                                          )
                                        : SizedBox(),
                                  ]))
                            : SizedBox(),

                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Pool Accessible',
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
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    assesspro.setdata(
                                        2, value, 'Pool Accessible');
                                  } else if (role != "therapist") {
                                    assesspro.setdata(
                                        2, value, 'Pool Accessible');
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
                        (getvalue(2) != '')
                            ? (getvalue(2) == 'No')
                                ? getrecomain(2, true, context)
                                : SizedBox()
                            : SizedBox(),

                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Pool Deck Flooring',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            Container(
                              child: DropdownButton(
                                items: [
                                  DropdownMenuItem(
                                      child: Text('--'), value: ''),
                                  DropdownMenuItem(
                                    child: Text('Non-slip surface'),
                                    value: 'Non-slip surface',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Slippery surface'),
                                    value: 'Slippery surface',
                                  ),
                                ],
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    assesspro.setdata(
                                        3, value, 'Pool Deck Flooring');
                                  } else if (role != "therapist") {
                                    assesspro.setdata(
                                        3, value, 'Pool Deck Flooring');
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
                        (getvalue(3) != '')
                            ? (getvalue(3) == 'Slippery surface')
                                ? getrecomain(3, true, context)
                                : SizedBox()
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Pool Deck Clutter?',
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
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    assesspro.setdata(
                                        4, value, 'Pool Deck Clutter?');
                                  } else if (role != "therapist") {
                                    assesspro.setdata(
                                        4, value, 'Pool Deck Clutter?');
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
                        (getvalue(4) != '')
                            ? (getvalue(4) == 'Yes')
                                ? getrecomain(4, true, context)
                                : SizedBox()
                            : SizedBox(),

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
                        Container(
                            // height: 10000,
                            child: TextFormField(
                          initialValue: getvalue(5),
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
                            FocusScope.of(context).requestFocus();
                            new TextEditingController().clear();
                            // print(widget.accessname);
                            if (assessor == therapist && role == "therapist") {
                              assesspro.setdata(5, value, 'Observations');
                            } else if (role != "therapist") {
                              assesspro.setdata(5, value, 'Observations');
                            } else {
                              _showSnackBar(
                                  "You can't change the other fields", context);
                            }
                          },
                        )),
                      ],
                    ),
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
                            var test = widget.wholelist[11][widget.accessname]
                                ["complete"];
                            for (int i = 0;
                                i <
                                    widget
                                        .wholelist[11][widget.accessname]
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
                              //     widget.wholelist[11][widget.accessname]);
                              Navigator.pop(context,
                                  widget.wholelist[11][widget.accessname]);
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
                              //     widget.wholelist[11][widget.accessname]);
                              Navigator.pop(context,
                                  widget.wholelist[11][widget.accessname]);
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
                    _showSnackBar("You can't change the other fields", context);
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

  Widget getrecowid(index, BuildContext context) {
    if (widget.wholelist[11][widget.accessname]["question"]["$index"]
            ["Recommendationthera"] !=
        "") {
      setState(() {
        isColor = true;
        // saveToForm = true;
        // widget.wholelist[11][widget.accessname]["isSave"] = saveToForm;
      });
    } else {
      setState(() {
        isColor = false;
        // saveToForm = false;
        // widget.wholelist[11][widget.accessname]["isSave"] = saveToForm;
      });
    }
    if (falseIndex == -1) {
      if (widget.wholelist[11][widget.accessname]["question"]["$index"]
              ["Recommendationthera"] !=
          "") {
        setState(() {
          saveToForm = true;
          trueIndex = index;
          widget.wholelist[11][widget.accessname]["isSave"] = true;
        });
      } else {
        setState(() {
          saveToForm = false;
          falseIndex = index;
          widget.wholelist[11][widget.accessname]["isSave"] = false;
        });
      }
    } else {
      if (index == falseIndex) {
        if (widget.wholelist[11][widget.accessname]["question"]["$index"]
                ["Recommendationthera"] !=
            "") {
          setState(() {
            widget.wholelist[11][widget.accessname]["isSave"] = true;
            falseIndex = -1;
          });
        } else {
          setState(() {
            widget.wholelist[11][widget.accessname]["isSave"] = false;
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
          //colorsset["field$index"] = Colors.red;
          isListening['field$index'] = true;
        });
        _speech.listen(
          onResult: (val) => setState(() {
            _controllers["field$index"].text = widget.wholelist[11]
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
  }

  setdatalisten(index) {
    setState(() {
      widget.wholelist[11][widget.accessname]['question']["$index"]
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
            _controllerstreco["field$index"].text = widget.wholelist[11]
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
      widget.wholelist[11][widget.accessname]['question']["$index"]
          ['Recommendationthera'] = _controllerstreco["field$index"].text;
      cur = !cur;
    });
  }
}
