import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Garage/garagebase.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentrepo.dart';
import 'package:tryapp/constants.dart';
import '../ViewVideo.dart';
import './garagepro.dart';
import 'package:path/path.dart';

final _colorgreen = Color.fromRGBO(10, 80, 106, 1);

class GarageUI extends StatefulWidget {
  String roomname, docID;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  GarageUI(this.roomname, this.wholelist, this.accessname, this.docID);
  @override
  _GarageUIState createState() => _GarageUIState();
}

class _GarageUIState extends State<GarageUI> {
  final firestoreInstance = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  stt.SpeechToText _speech;
  bool _isListening = false;
  double _confidence = 1.0;
  bool available = false;
  Map<String, Color> colorsset = {};
  Map<String, TextEditingController> _controllers = {};
  Map<String, TextEditingController> _controllerstreco = {};
  Map<String, bool> isListening = {};
  String role, assessor, therapist, curUid;
  bool cur = true;
  int stepsizes = 0;
  int stepcount = 0;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  String videoDownloadUrl, videoUrl, videoName;
  File video;
  bool uploading = false;
  List<DropdownMenuItem<dynamic>> items = [];
  var test = TextEditingController();
  @override
  void initState() {
    super.initState();
    getAssessData();
    getRole();
    fillDropItem();
    // setinitialsdata();
  }

  fillDropItem() {
    List<dynamic> itemList = [];
    setState(() {
      for (var i = 0; i < widget.wholelist[9]['count']; i++) {
        if (widget.wholelist[9]['room${i + 1}']['isUsed'][0]) {
          itemList.add("room${i + 1}".toString());
        }
      }

      itemList.forEach((element) {
        DropdownMenuItem<String> ddmi = DropdownMenuItem<String>(
          child: Text("${widget.wholelist[9][element.toString()]['name']}",
              style: TextStyle(fontSize: 18, color: Colors.white)),
          value: element.toString(),
        );
        items.add(ddmi);
      });
    });
  }

  Future<void> setinitialsdata() async {
    if (widget.wholelist[9][widget.accessname].containsKey('isSave')) {
    } else {
      widget.wholelist[9][widget.accessname]["isSave"] = true;
    }
    if (widget.wholelist[9][widget.accessname].containsKey('videos')) {
      if (widget.wholelist[9][widget.accessname]['videos']
          .containsKey('name')) {
      } else {
        widget.wholelist[9][widget.accessname]['videos']['name'] = "";
      }
      if (widget.wholelist[9][widget.accessname]['videos'].containsKey('url')) {
      } else {
        widget.wholelist[9][widget.accessname]['videos']['url'] = "";
      }
    } else {
      // print('Yes,it is');

      widget.wholelist[9][widget.accessname]
          ["videos"] = {'name': '', 'url': ''};
    }
    if (widget.wholelist[9][widget.accessname]['question']["9"]
        .containsKey('MultipleStair')) {
      if (widget.wholelist[9][widget.accessname]['question']["9"]
              ['MultipleStair']
          .containsKey('count')) {
        setState(() {
          stepcount = widget.wholelist[9][widget.accessname]['question']["9"]
              ['MultipleStair']["count"];
        });
      }
    } else {
      // print('hello');
      setState(() {
        widget.wholelist[9][widget.accessname]['question']["9"]
            ['MultipleStair'] = {};
      });
    }
    if (widget.wholelist[9][widget.accessname]['question']["10"]
        .containsKey('Railling')) {
    } else {
      widget.wholelist[9][widget.accessname]['question']["10"]['Railling'] = {
        'OneSided': {},
      };
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
              videoUrl = widget.wholelist[9][widget.accessname]["videos"]["url"]
                      .toString() ??
                  "";
              videoName = widget.wholelist[9][widget.accessname]["videos"]
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
        // print("runtime Type: $runtimeType");
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
    final assesmentprovider = Provider.of<GaragePro>(context);
    // final NewAssesmentProvider assesmentprovider = NewAssesmentProvider();
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
          widget.wholelist[9][widget.accessname]["videos"]["url"] = videoUrl;
          widget.wholelist[9][widget.accessname]["videos"]["name"] = videoName;
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
            assesmentprovider.addVideo(pickedVideo.path);
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
            assesmentprovider.addVideo(pickedVideo.path);
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

    Widget toggleButton(BuildContext context, GaragePro assesmentprovider,
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
                            .wholelist[9][widget.accessname]['question']
                                ['$queIndex']['toggle']
                            .length;
                    i++) {
                  widget.wholelist[9][widget.accessname]['question']
                      ['$queIndex']['toggle'][i] = i == select;
                }
              });
              assesmentprovider.setdata(
                  queIndex,
                  widget.wholelist[9][widget.accessname]['question']
                          ['$queIndex']['toggle'][0]
                      ? 'Yes'
                      : 'No',
                  que);
            } else if (role != "therapist") {
              setState(() {
                for (int i = 0;
                    i <
                        widget
                            .wholelist[9][widget.accessname]['question']
                                ['$queIndex']['toggle']
                            .length;
                    i++) {
                  widget.wholelist[9][widget.accessname]['question']
                      ['$queIndex']['toggle'][i] = i == select;
                }
              });
              assesmentprovider.setdata(
                  queIndex,
                  widget.wholelist[9][widget.accessname]['question']
                          ['$queIndex']['toggle'][0]
                      ? 'Yes'
                      : 'No',
                  que);
            } else {
              _showSnackBar("You can't change the other fields", context);
            }
          },
          isSelected: widget.wholelist[9][widget.accessname]['question']
                  ['$queIndex']['toggle']
              .cast<bool>(),
        ),
      );
    }

    listenDropButton() {
      var test = widget.wholelist[9][widget.accessname]['complete'];
      for (int i = 0;
          i < widget.wholelist[9][widget.accessname]['question'].length;
          i++) {
        assesmentprovider.setdatalisten(i + 1);
        assesmentprovider.setdatalistenthera(i + 1);
      }
      // if (test == 0) {
      //   _showSnackBar(
      //       "You Must Have To Fill The Details First", context);
      // } else {
      if (role == "therapist") {
        // if (assesmentprovider.saveToForm) {
        NewAssesmentRepository().setLatestChangeDate(widget.docID);
        NewAssesmentRepository().setForm(widget.wholelist, widget.docID);
        // Navigator.pop(
        //     context, widget.wholelist[9][widget.accessname]);
        // } else {
        //   _showSnackBar(
        //       "Provide all recommendations", context);
        // }
      } else {
        NewAssesmentRepository().setLatestChangeDate(widget.docID);
        NewAssesmentRepository().setForm(widget.wholelist, widget.docID);
        // Navigator.pop(
        //     context, widget.wholelist[9][widget.accessname]);
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
                              widget.wholelist[9][widget.accessname]['name'];
                        });
                        print(widget.roomname);
                        listenDropButton();
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(
                                builder: (context) => Garage(
                                    widget.roomname,
                                    widget.wholelist,
                                    widget.accessname,
                                    widget.docID)))
                            .then((value) => setState(() {
                                  widget.wholelist[9][widget]['complete'] =
                                      value['complete'];
                                  // widget.wholelist[index]['']
                                }));
                      },
                      value: widget.accessname,
                    ),
                  ),
                )
              : Text('Garage'),
          // automaticallyImplyLeading: false,
          backgroundColor: _colorgreen,
          actions: [
            IconButton(
              icon: Icon(Icons.done_all, color: Colors.white),
              onPressed: () async {
                try {
                  var test = widget.wholelist[9][widget.accessname]['complete'];
                  for (int i = 0;
                      i <
                          widget.wholelist[9][widget.accessname]['question']
                              .length;
                      i++) {
                    assesmentprovider.setdatalisten(i + 1);
                    assesmentprovider.setdatalistenthera(i + 1);
                  }
                  // if (test == 0) {
                  //   _showSnackBar(
                  //       "You Must Have To Fill The Details First", context);
                  // } else {
                  if (role == "therapist") {
                    // if (assesmentprovider.saveToForm) {
                    NewAssesmentRepository().setLatestChangeDate(widget.docID);
                    NewAssesmentRepository()
                        .setForm(widget.wholelist, widget.docID);
                    Navigator.pop(
                        context, widget.wholelist[9][widget.accessname]);
                    // } else {
                    //   _showSnackBar("Provide all recommendations", context);
                    // }
                  } else {
                    NewAssesmentRepository().setLatestChangeDate(widget.docID);
                    NewAssesmentRepository()
                        .setForm(widget.wholelist, widget.docID);
                    Navigator.pop(
                        context, widget.wholelist[9][widget.accessname]);
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
                                                  widget.wholelist[9]
                                                          [widget.accessname]
                                                      ["videos"]["name"] = "";
                                                  widget.wholelist[9]
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
                                                  widget.wholelist[9]
                                                          [widget.accessname]
                                                      ["videos"]["name"] = "";
                                                  widget.wholelist[9]
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
                        SizedBox(height: 15),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .6,
                                child: Text('Threshold to Garage',
                                    style: TextStyle(
                                      color: Color.fromRGBO(10, 80, 106, 1),
                                      fontSize: 20,
                                    )),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .25,
                                child: TextFormField(
                                  initialValue: widget.wholelist[9]
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
                                  keyboardType: TextInputType.phone,
                                  onChanged: (value) {
                                    if (assessor == therapist &&
                                        role == "therapist") {
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                      assesmentprovider.setdata(
                                          1, value, 'Threshold to Garage');
                                    } else if (role != "therapist") {
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                      assesmentprovider.setdata(
                                          1, value, 'Threshold to Garage');
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
                                ? assesmentprovider.getrecomain(
                                    assesmentprovider,
                                    1,
                                    true,
                                    'Comments(if any)',
                                    assessor,
                                    therapist,
                                    role,
                                    context)
                                : SizedBox()
                            : SizedBox(),
                        // Divider(
                        //   height: dividerheight,
                        //   color: Color.fromRGBO(10, 80, 106, 1),
                        // ),
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
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        2, value, 'Flooring Type');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context).requestFocus();
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
                            ? assesmentprovider.getrecomain(
                                assesmentprovider,
                                2,
                                true,
                                'Comments (if any)',
                                assessor,
                                therapist,
                                role,
                                context)
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
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        3, value, 'Floor Coverage');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context).requestFocus();
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
                            ? assesmentprovider.getrecomain(
                                assesmentprovider,
                                3,
                                true,
                                'Comments (if any)',
                                assessor,
                                therapist,
                                role,
                                context)
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
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        4, value, 'Lighting Type');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context).requestFocus();
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
                            ? assesmentprovider.getrecomain(
                                assesmentprovider,
                                4,
                                true,
                                'Specify Type',
                                assessor,
                                therapist,
                                role,
                                context)
                            : SizedBox(),
                        SizedBox(height: 15),
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
                            //         FocusScope.of(context).requestFocus();
                            //         new TextEditingController().clear();
                            //         // print(widget.accessname);
                            //         assesmentprovider.setdata(
                            //             5, value, 'Able to Operate Switches?');
                            //       } else if (role != "therapist") {
                            //         FocusScope.of(context).requestFocus();
                            //         new TextEditingController().clear();
                            //         // print(widget.accessname);
                            //         assesmentprovider.setdata(
                            //             5, value, 'Able to Operate Switches?');
                            //       } else {
                            //         _showSnackBar(
                            //             "You can't change the other fields",
                            //             context);
                            //       }
                            //     },
                            //     value: assesmentprovider.getvalue(5),
                            //   ),
                            // ),
                            toggleButton(context, assesmentprovider, 5,
                                'Able to Operate Switches?')
                          ],
                        ),
                        (assesmentprovider.getvalue(5) != 'Yes' &&
                                assesmentprovider.getvalue(5) != '')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider,
                                5,
                                true,
                                'Comments(if any)',
                                assessor,
                                therapist,
                                role,
                                context)
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
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        6, value, 'Switch Type');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context).requestFocus();
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
                                initialValue: widget.wholelist[9]
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
                                keyboardType: TextInputType.phone,
                                onChanged: (value) {
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        7, value, 'Door Width');
                                    setState(() {
                                      widget.wholelist[9][widget.accessname]
                                          ['question']["7"]['doorwidth'] = 0;

                                      widget.wholelist[9][widget.accessname]
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
                                      widget.wholelist[9][widget.accessname]
                                          ['question']["7"]['doorwidth'] = 0;

                                      widget.wholelist[9][widget.accessname]
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
                        (widget.wholelist[9][widget.accessname]['question']["7"]
                                        ['doorwidth'] <
                                    30 &&
                                widget.wholelist[9][widget.accessname]
                                        ['question']["7"]['doorwidth'] >
                                    0 &&
                                widget.wholelist[9][widget.accessname]
                                        ['question']["7"]['doorwidth'] !=
                                    '')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider,
                                7,
                                true,
                                'Comments (if any)',
                                assessor,
                                therapist,
                                role,
                                context)
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
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       assesmentprovider.setdata(
                            //           8, value, 'Obstacle/Clutter Present?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       assesmentprovider.setdata(
                            //           8, value, 'Obstacle/Clutter Present?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: assesmentprovider.getvalue(8),
                            // )
                            toggleButton(context, assesmentprovider, 8,
                                'Obstacle/Clutter Present?')
                          ],
                        ),

                        (assesmentprovider.getvalue(8) == 'Yes')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider,
                                8,
                                true,
                                'Specify Clutter',
                                assessor,
                                therapist,
                                role,
                                context)
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: Text('Type of steps',
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
                                    assesmentprovider.setdata(
                                        9, value, 'Type of steps');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        9, value, 'Type of steps');
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
                                                      initialValue: widget.wholelist[9]
                                                                      [widget.accessname]
                                                                  ['question']
                                                              ["9"]['additional']
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
                                                          TextInputType.phone,
                                                      onChanged: (value) {
                                                        if (assessor ==
                                                                therapist &&
                                                            role ==
                                                                "therapist") {
                                                          widget.wholelist[9][widget
                                                                          .accessname]
                                                                      [
                                                                      "question"]
                                                                  [
                                                                  "9"]['additional']
                                                              ["count"] = value;
                                                        } else if (role !=
                                                            "therapist") {
                                                          widget.wholelist[9][widget
                                                                          .accessname]
                                                                      [
                                                                      'question']
                                                                  [
                                                                  "9"]['additional']
                                                              ["count"] = value;
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
                                            height: 10,
                                          ),
                                          widget.wholelist[9][widget.accessname]
                                                                  ["question"]
                                                              ["9"]['additional']
                                                          ["count"] !=
                                                      '0' &&
                                                  widget.wholelist[9][widget
                                                                      .accessname]
                                                                  ["question"]
                                                              ["9"]['additional']
                                                          ["count"] !=
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
                                                                          .wholelist[9]
                                                                      [
                                                                      widget
                                                                          .accessname]
                                                                  [
                                                                  'question']["9"]
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
                                                                        // color: colorsset[
                                                                        //     "field${9}"],
                                                                        width: 1),
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      width: 1,
                                                                      // color: colorsset[
                                                                      //     "field${9}"]
                                                                    ),
                                                                  ),
                                                                  labelText:
                                                                      'Step Width in inches:'),
                                                          onChanged: (value) {
                                                            if (assessor ==
                                                                    therapist &&
                                                                role ==
                                                                    "therapist") {
                                                              setState(() {
                                                                widget.wholelist[9]
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
                                                                widget.wholelist[9]
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
                                                                          .wholelist[9]
                                                                      [
                                                                      widget
                                                                          .accessname]
                                                                  [
                                                                  'question']["9"]
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
                                                                        // color: colorsset[
                                                                        //     "field${9}"],
                                                                        width: 1),
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      width: 1,
                                                                      // color: colorsset[
                                                                      //     "field${9}"]
                                                                    ),
                                                                  ),
                                                                  labelText:
                                                                      'Step Height in inches:'),
                                                          onChanged: (value) {
                                                            if (assessor ==
                                                                    therapist &&
                                                                role ==
                                                                    "therapist") {
                                                              setState(() {
                                                                widget.wholelist[9]
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
                                                                widget.wholelist[9]
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
                                                  child: NumericStepButton(
                                                    counterval: stepcount,
                                                    onChanged: (value) {
                                                      if (assessor ==
                                                              therapist &&
                                                          role == "therapist") {
                                                        setState(() {
                                                          widget.wholelist[9][widget
                                                                          .accessname]
                                                                      [
                                                                      'question']["9"]
                                                                  [
                                                                  'MultipleStair']
                                                              ['count'] = value;

                                                          stepcount = widget
                                                                          .wholelist[9]
                                                                      [
                                                                      widget
                                                                          .accessname]
                                                                  [
                                                                  'question']["9"]
                                                              [
                                                              'MultipleStair']['count'];
                                                          if (value > 0) {
                                                            widget.wholelist[9][
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
                                                                .wholelist[9][
                                                                    widget
                                                                        .accessname]
                                                                    ['question']
                                                                    ["9"][
                                                                    'MultipleStair']
                                                                .containsKey(
                                                                    'step${value + 1}')) {
                                                              widget
                                                                  .wholelist[9][
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
                                                                .wholelist[9][
                                                                    widget
                                                                        .accessname]
                                                                    ['question']
                                                                    ["9"][
                                                                    'MultipleStair']
                                                                .containsKey(
                                                                    'step${value + 1}')) {
                                                              widget
                                                                  .wholelist[9][
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
                                                          widget.wholelist[9][widget
                                                                          .accessname]
                                                                      [
                                                                      'question']["9"]
                                                                  [
                                                                  'MultipleStair']
                                                              ['count'] = value;

                                                          stepcount = widget
                                                                          .wholelist[9]
                                                                      [
                                                                      widget
                                                                          .accessname]
                                                                  [
                                                                  'question']["9"]
                                                              [
                                                              'MultipleStair']['count'];
                                                          if (value > 0) {
                                                            widget.wholelist[9][
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
                                                                .wholelist[9][
                                                                    widget
                                                                        .accessname]
                                                                    ['question']
                                                                    ["9"][
                                                                    'MultipleStair']
                                                                .containsKey(
                                                                    'step${value + 1}')) {
                                                              widget
                                                                  .wholelist[9][
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
                                                                .wholelist[9][
                                                                    widget
                                                                        .accessname]
                                                                    ['question']
                                                                    ["9"][
                                                                    'MultipleStair']
                                                                .containsKey(
                                                                    'step${value + 1}')) {
                                                              widget
                                                                  .wholelist[9][
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
                                          SizedBox(height: 10),
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
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
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
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  assesmentprovider.setdata(10, value,
                                      'Railing is present on which side?');
                                } else if (role != "therapist") {
                                  FocusScope.of(context).requestFocus();
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
                            ? assesmentprovider.getrecomain(
                                assesmentprovider,
                                10,
                                true,
                                'Comments (if any)',
                                assessor,
                                therapist,
                                role,
                                context)
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
                                                  widget.wholelist[9][widget
                                                                  .accessname]
                                                              ['question']["10"]
                                                          [
                                                          'Railling']['OneSided']
                                                      ['GoingUp'] = value;
                                                } else if (role !=
                                                    "therapist") {
                                                  widget.wholelist[9][widget
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
                                              value: widget.wholelist[9][
                                                              widget.accessname]
                                                          ['question']["10"]
                                                      ['Railling']['OneSided']
                                                  ['GoingUp'],
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10),
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
                                              value: widget.wholelist[9][
                                                              widget.accessname]
                                                          ['question']["10"]
                                                      ['Railling']['OneSided']
                                                  ['GoingDown'],
                                              onChanged: (value) {
                                                if (assessor == therapist &&
                                                    role == "therapist") {
                                                  widget.wholelist[9][widget
                                                                  .accessname]
                                                              ['question']["10"]
                                                          [
                                                          'Railling']['OneSided']
                                                      ['GoingDown'] = value;
                                                } else if (role !=
                                                    "therapist") {
                                                  widget.wholelist[9][widget
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
                                            )
                                          ],
                                        ),
                                      ),
                                      (role == 'therapist')
                                          ? assesmentprovider.getrecowid(
                                              assesmentprovider, 10)
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
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       assesmentprovider.setdata(
                            //           11, value, 'Smoke Detector Present?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       assesmentprovider.setdata(
                            //           11, value, 'Smoke Detector Present?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: assesmentprovider.getvalue(11),
                            // )
                            toggleButton(context, assesmentprovider, 11,
                                'Smoke Detector Present?')
                          ],
                        ),
                        (assesmentprovider.getvalue(11) == 'No')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider,
                                11,
                                true,
                                'Comments (if any)',
                                assessor,
                                therapist,
                                role,
                                context)
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
                        //     // height: 10000,
                        //     child: TextFormField(
                        //   initialValue: widget.wholelist[9][widget.accessname]
                        //       ['question']["12"]['Answer'],
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
                        //     suffix: Icon(Icons.mic),
                        //   ),
                        //   onChanged: (value) {
                        //     if (assessor == therapist && role == "therapist") {
                        //       FocusScope.of(context).requestFocus();
                        //       new TextEditingController().clear();
                        //       // print(widget.accessname);
                        //       assesmentprovider.setdata(
                        //           12, value, 'Observations');
                        //     } else if (role != "therapist") {
                        //       FocusScope.of(context).requestFocus();
                        //       new TextEditingController().clear();
                        //       // print(widget.accessname);
                        //       assesmentprovider.setdata(
                        //           12, value, 'Observations');
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
                                  controller:
                                      assesmentprovider.controllers["field12"],
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
                                animate:
                                    assesmentprovider.isListening["field12"],
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
                                    onPressed: () {
                                      if (assessor == therapist &&
                                          role == "therapist") {
                                        assesmentprovider.listen(12);
                                        assesmentprovider.setdatalisten(12);
                                      } else if (role != "therapist") {
                                        assesmentprovider.listen(12);
                                        assesmentprovider.setdatalisten(12);
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
                              color: assesmentprovider.colorsset["field${12}"],
                              width: 1,
                            ), //Border.all
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Container(
                        //       width: MediaQuery.of(context).size.width * .4,
                        //       child: Text('Time Completed',
                        //           style: TextStyle(
                        //             color: Color.fromRGBO(10, 80, 106, 1),
                        //             fontSize: 20,
                        //           )),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 15),
                        // Container(
                        //     child: TextFormField(
                        //   enableInteractiveSelection: false,
                        //   focusNode: new AlwaysDisabledFocusNode(),
                        //   initialValue: widget.wholelist[9][widget.accessname]
                        //       ['question']["13"]['Answer'],
                        //   decoration: InputDecoration(
                        //       focusedBorder: OutlineInputBorder(
                        //         borderSide: BorderSide(
                        //             color: Color.fromRGBO(10, 80, 106, 1),
                        //             width: 1),
                        //       ),
                        //       enabledBorder: OutlineInputBorder(
                        //         borderSide: BorderSide(width: 1),
                        //       ),
                        //       suffix: Icon(Icons.mic),
                        //       labelText:
                        //           'Input the Time at The End of Assessment'),
                        //   onChanged: (value) {
                        //     FocusScope.of(context).requestFocus();
                        //     new TextEditingController().clear();
                        //     // print(widget.accessname);
                        //     assesmentprovider.setdata(
                        //         13, value, 'Time Completed');
                        //   },
                        // )),
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
                          widget.wholelist[9][widget.accessname]['complete'];
                      for (int i = 0;
                          i <
                              widget.wholelist[9][widget.accessname]['question']
                                  .length;
                          i++) {
                        assesmentprovider.setdatalisten(i + 1);
                        assesmentprovider.setdatalistenthera(i + 1);
                      }
                      // if (test == 0) {
                      //   _showSnackBar(
                      //       "You Must Have To Fill The Details First", context);
                      // } else {
                      if (role == "therapist") {
                        // if (assesmentprovider.saveToForm) {
                        NewAssesmentRepository()
                            .setLatestChangeDate(widget.docID);
                        NewAssesmentRepository()
                            .setForm(widget.wholelist, widget.docID);
                        Navigator.pop(
                            context, widget.wholelist[9][widget.accessname]);
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
                            context, widget.wholelist[9][widget.accessname]);
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
                    initialValue: widget.wholelist[9][widget.accessname]
                            ['question']["9"]['MultipleStair']['step$index']
                        ['stepwidth'],
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromRGBO(10, 80, 106, 1), width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1, color: Color.fromRGBO(10, 80, 106, 1)),
                        ),
                        labelText: 'Step Width$index (Inches)'),
                    onChanged: (value) {
                      if (assessor == therapist && role == "therapist") {
                        setState(() {
                          widget.wholelist[9][widget.accessname]['question']
                                  ["9"]['MultipleStair']['step$index']
                              ['stepwidth'] = value;
                        });
                      } else if (role != "therapist") {
                        setState(() {
                          widget.wholelist[9][widget.accessname]['question']
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
                    initialValue: widget.wholelist[9][widget.accessname]
                            ['question']["9"]['MultipleStair']['step$index']
                        ['stepheight'],
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromRGBO(10, 80, 106, 1), width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1, color: Color.fromRGBO(10, 80, 106, 1)),
                        ),
                        labelText: 'Step Height$index (Inches)'),
                    onChanged: (value) {
                      if (assessor == therapist && role == "therapist") {
                        setState(() {
                          widget.wholelist[9][widget.accessname]['question']
                                  ["9"]['MultipleStair']['step$index']
                              ['stepheight'] = value;
                        });
                      } else if (role != "therapist") {
                        setState(() {
                          widget.wholelist[9][widget.accessname]['question']
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

  // Widget assesmentprovider.getrecomain(assesmentprovider,int index, bool isthera, String fieldlabel) {
  //   return SingleChildScrollView(
  //     // reverse: true,
  //     child: Container(
  //       // color: Colors.yellow,
  //       child: Column(
  //         children: [
  //           SizedBox(height: 5),
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
  //                             heroTag: "btn$index",
  //                             child: Icon(
  //                               Icons.mic,
  //                               size: 20,
  //                             ),
  //                             onPressed: () {
  //                               _listen(index);
  //                               setdatalisten(index);
  //                             },
  //                           ),
  //                         ),
  //                       ),
  //                     ]),
  //                   ),
  //                   labelText: fieldlabel),
  //               onChanged: (value) {
  //                 FocusScope.of(context).requestFocus();
  //                 new TextEditingController().clear();
  //                 // print(widget.accessname);
  //                 setreco(index, value);
  //               },
  //             ),
  //           ),
  //           (type == 'Therapist' && isthera) ? getrecowid(index) : SizedBox(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget getrecowid(index) {
  //   return Column(
  //     children: [
  //       SizedBox(height: 8),
  //       TextFormField(
  //         controller: _controllerstreco["field$index"],
  //         decoration: InputDecoration(
  //             focusedBorder: OutlineInputBorder(
  //               borderSide:
  //                   BorderSide(color: Color.fromRGBO(10, 80, 106, 1), width: 1),
  //             ),
  //             enabledBorder: OutlineInputBorder(
  //               borderSide: BorderSide(width: 1),
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
  //                   child: FloatingActionButton(
  //                     heroTag: "btn${index + 1}",
  //                     child: Icon(
  //                       Icons.mic,
  //                       size: 20,
  //                     ),
  //                     onPressed: () {
  //                       _listenthera(index);
  //                       setdatalistenthera(index);
  //                     },
  //                   ),
  //                 ),
  //               ]),
  //             ),
  //             labelText: 'Recomendation'),
  //         onChanged: (value) {
  //           FocusScope.of(context).requestFocus();
  //           new TextEditingController().clear();
  //           // print(widget.accessname);
  //           setrecothera(index, value);
  //         },
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

  // void _listenthera(index) async {
  //   if (!_isListening) {
  //     bool available = await _speech.initialize(
  //       onStatus: (val) {
  //         print('onStatus: $val');
  //         setState(() {
  //           // _isListening = false;
  //           //
  //         });
  //       },
  //       onError: (val) => print('onError: $val'),
  //     );
  //     if (available) {
  //       setState(() {
  //         _isListening = true;
  //         // colorsset["field$index"] = Colors.red;
  //         isListening['field$index'] = true;
  //       });
  //       _speech.listen(
  //         onResult: (val) => setState(() {
  //           _controllerstreco["field$index"].text = widget.wholelist[9]
  //                       [widget.accessname]['question'][index]
  //                   ['Recommendationthera'] +
  //               " " +
  //               val.recognizedWords;
  //         }),
  //       );
  //     }
  //   } else {
  //     setState(() {
  //       _isListening = false;
  //       isListening['field$index'] = false;
  //       colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
  //     });
  //     _speech.stop();
  //   }
  // }

  // setdatalistenthera(index) {
  //   setState(() {
  //     widget.wholelist[9][widget.accessname]['question'][index]
  //         ['Recommendationthera'] = _controllerstreco["field$index"].text;
  //     cur = !cur;
  //   });
  // }

  // void _listen(index) async {
  //   if (!_isListening) {
  //     bool available = await _speech.initialize(
  //       onStatus: (val) {
  //         print('onStatus: $val');
  //         setState(() {
  //           // _isListening = false;
  //           //
  //         });
  //       },
  //       onError: (val) => print('onError: $val'),
  //     );
  //     if (available) {
  //       setState(() {
  //         _isListening = true;
  //         colorsset["field$index"] = Colors.red;
  //         isListening['field$index'] = true;
  //       });
  //       _speech.listen(
  //         onResult: (val) => setState(() {
  //           _controllers["field$index"].text = widget.wholelist[9]
  //                   [widget.accessname]['question'][index]['Recommendation'] +
  //               " " +
  //               val.recognizedWords;
  //           if (val.hasConfidenceRating && val.confidence > 0) {
  //             _confidence = val.confidence;
  //           }
  //         }),
  //       );
  //     }
  //   } else {
  //     setState(() {
  //       _isListening = false;
  //       isListening['field$index'] = false;
  //       colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
  //     });
  //     _speech.stop();
  //   }
  // }

  // setdatalisten(index) {
  //   setState(() {
  //     widget.wholelist[9][widget.accessname]['question'][index]
  //         ['Recommendation'] = _controllers["field$index"].text;
  //     cur = !cur;
  //   });
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

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
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
