import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Laundry/laundrybase.dart';
import 'package:tryapp/Assesment/Forms/Laundry/laundrypro.dart';
import 'package:tryapp/Assesment/Forms/ViewVideo.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentrepo.dart';
import 'package:tryapp/constants.dart';
import 'package:path/path.dart';

final _colorgreen = Color.fromRGBO(10, 80, 106, 1);

class LaundryUI extends StatefulWidget {
  String roomname, docID;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  LaundryUI(this.roomname, this.wholelist, this.accessname, this.docID);
  @override
  _LaundryUIState createState() => _LaundryUIState();
}

class _LaundryUIState extends State<LaundryUI> {
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
  bool cur = true;
  String role, assessor, therapist, curUid;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  var test = TextEditingController();
  String videoDownloadUrl, videoUrl, videoName;
  File video;
  bool uploading = false;
  List<DropdownMenuItem<dynamic>> items = [];

  FocusNode focusNode = new FocusNode();
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getAssessData();
    getRole();
    super.initState();
    fillDropItem();
  }

  fillDropItem() {
    List<dynamic> itemList = [];
    setState(() {
      for (var i = 0; i < widget.wholelist[7]['count']; i++) {
        if (widget.wholelist[7]['room${i + 1}']['isUsed'][0]) {
          itemList.add("room${i + 1}".toString());
        }
      }

      itemList.forEach((element) {
        DropdownMenuItem<String> ddmi = DropdownMenuItem<String>(
          child: Text("${widget.wholelist[7][element.toString()]['name']}",
              style: TextStyle(fontSize: 18, color: Colors.white)),
          value: element.toString(),
        );
        items.add(ddmi);
      });
    });
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
              videoUrl = widget.wholelist[7][widget.accessname]["videos"]["url"]
                      .toString() ??
                  "";
              videoName = widget.wholelist[7][widget.accessname]["videos"]
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
    final assesmentprovider = Provider.of<LaundryPro>(context);

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
          widget.wholelist[7][widget.accessname]["videos"]["url"] = videoUrl;
          widget.wholelist[7][widget.accessname]["videos"]["name"] = videoName;
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

    Widget toggleButton(BuildContext context, LaundryPro assesmentprovider,
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
                            .wholelist[7][widget.accessname]['question']
                                ['$queIndex']['toggle']
                            .length;
                    i++) {
                  widget.wholelist[7][widget.accessname]['question']
                      ['$queIndex']['toggle'][i] = i == select;
                }
              });
              assesmentprovider.setdataToggle(
                  queIndex,
                  widget.wholelist[7][widget.accessname]['question']
                          ['$queIndex']['toggle'][0]
                      ? 'Yes'
                      : 'No',
                  que);
            } else if (role != "therapist") {
              setState(() {
                for (int i = 0;
                    i <
                        widget
                            .wholelist[7][widget.accessname]['question']
                                ['$queIndex']['toggle']
                            .length;
                    i++) {
                  widget.wholelist[7][widget.accessname]['question']
                      ['$queIndex']['toggle'][i] = i == select;
                }
              });
              assesmentprovider.setdataToggle(
                  queIndex,
                  widget.wholelist[7][widget.accessname]['question']
                          ['$queIndex']['toggle'][0]
                      ? 'Yes'
                      : 'No',
                  que);
            } else {
              _showSnackBar("You can't change the other fields", context);
            }
          },
          isSelected: widget.wholelist[7][widget.accessname]['question']
                  ['$queIndex']['toggle']
              .cast<bool>(),
        ),
      );
    }

    listenDropButton() {
      var test = widget.wholelist[7][widget.accessname]['complete'];
      for (int i = 0;
          i < widget.wholelist[7][widget.accessname]['question'].length;
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
        //     context, widget.wholelist[7][widget.accessname]);
        // } else {
        //   _showSnackBar(
        //       "Provide all recommendtions", context);
        // }
      } else {
        NewAssesmentRepository().setLatestChangeDate(widget.docID);
        NewAssesmentRepository().setForm(widget.wholelist, widget.docID);
        // Navigator.pop(
        //     context, widget.wholelist[7][widget.accessname]);
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
                              widget.wholelist[7][widget.accessname]['name'];
                        });
                        print(widget.roomname);
                        listenDropButton();
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(
                                builder: (context) => Laundry(
                                    widget.roomname,
                                    widget.wholelist,
                                    widget.accessname,
                                    widget.docID)))
                            .then((value) => setState(() {
                                  widget.wholelist[7][widget]['complete'] =
                                      value['complete'];
                                  // widget.wholelist[index]['']
                                }));
                      },
                      value: widget.accessname,
                    ),
                  ),
                )
              : Text('Laundry'),
          // automaticallyImplyLeading: false,
          backgroundColor: _colorgreen,
          actions: [
            IconButton(
              icon: Icon(Icons.done_all, color: Colors.white),
              onPressed: () async {
                try {
                  var test = widget.wholelist[7][widget.accessname]['complete'];
                  for (int i = 0;
                      i <
                          widget.wholelist[7][widget.accessname]['question']
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
                        context, widget.wholelist[7][widget.accessname]);
                    // } else {
                    //   _showSnackBar("Provide all recommendtions", context);
                    // }
                  } else {
                    NewAssesmentRepository().setLatestChangeDate(widget.docID);
                    NewAssesmentRepository()
                        .setForm(widget.wholelist, widget.docID);
                    Navigator.pop(
                        context, widget.wholelist[7][widget.accessname]);
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
                                                  widget.wholelist[7]
                                                          [widget.accessname]
                                                      ["videos"]["name"] = "";
                                                  widget.wholelist[7]
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
                                                  widget.wholelist[7]
                                                          [widget.accessname]
                                                      ["videos"]["name"] = "";
                                                  widget.wholelist[7]
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
                                width: MediaQuery.of(context).size.width * .6,
                                child: Text('Threshold to Laundry Room',
                                    style: TextStyle(
                                      color: Color.fromRGBO(10, 80, 106, 1),
                                      fontSize: 20,
                                    )),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .25,
                                child: TextFormField(
                                  initialValue: widget.wholelist[7]
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
                                      assesmentprovider.setdata(1, value,
                                          'Threshold to Laundry Room');
                                    } else if (role != "therapist") {
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                      assesmentprovider.setdata(1, value,
                                          'Threshold to Laundry Room');
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
                                    'Comments (if any)',
                                    assessor,
                                    therapist,
                                    role,
                                    context)
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
                        //   color: Color.fromRGBO(10, 70, 106, 1),
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
                        //   color: Color.fromRGBO(10, 70, 106, 1),
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
                        // Divider(
                        //   height: dividerheight,
                        //   color: Color.fromRGBO(10, 70, 106, 1),
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
                            //         assesmentprovider.setdata(
                            //             5, value, 'Able to Operate Switches?');
                            //       } else if (role != "therapist") {
                            //         FocusScope.of(context).requestFocus(focusNode);
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
                                initialValue: widget.wholelist[7]
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
                                      widget.wholelist[7][widget.accessname]
                                          ['question']["7"]['doorwidth'] = 0;

                                      widget.wholelist[7][widget.accessname]
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
                                      widget.wholelist[7][widget.accessname]
                                          ['question']["7"]['doorwidth'] = 0;

                                      widget.wholelist[7][widget.accessname]
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
                        (widget.wholelist[7][widget.accessname]['question']["7"]
                                        ['doorwidth'] <
                                    30 &&
                                widget.wholelist[7][widget.accessname]
                                        ['question']["7"]['doorwidth'] >
                                    0 &&
                                widget.wholelist[7][widget.accessname]
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
                        //   color: Color.fromRGBO(10, 70, 106, 1),
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
                            //       assesmentprovider.setdata(
                            //           8, value, 'Obstacle/Clutter Present?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus(focusNode);
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
                              width: MediaQuery.of(context).size.width * .58,
                              child: Text('Able to access washer & dryer?',
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
                            //       assesmentprovider.setdata(9, value,
                            //           'Able to access washer & dryer?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus(focusNode);
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       assesmentprovider.setdata(9, value,
                            //           'Able to access washer & dryer?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: assesmentprovider.getvalue(9),
                            // )
                            toggleButton(context, assesmentprovider, 9,
                                'Able to access washer & dryer?')
                          ],
                        ),
                        (assesmentprovider.getvalue(9) == 'No' &&
                                assesmentprovider.getvalue(9) != '')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider,
                                9,
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
                              child: Text('Type of washer & dryer',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: DropdownButton(
                                isExpanded: true,
                                items: [
                                  DropdownMenuItem(
                                    child: Text('--'),
                                    value: '',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Elevated'),
                                    value: 'Elevated',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Stackable washer & dryer'),
                                    value: 'Stackable washer & dryer',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Top open washer & dryer'),
                                    value: 'Top open washer & dryer',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Front open washer & dryer'),
                                    value: 'Front open washer & dryer',
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
                                        10, value, 'Type of washer & dryer');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context)
                                        .requestFocus(focusNode);
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(
                                        10, value, 'Type of washer & dryer');
                                  } else {
                                    _showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                                value: assesmentprovider.getvalue(10),
                              ),
                            ),
                          ],
                        ),
                        (assesmentprovider.getvalue(10) ==
                                    'Top open washer & dryer' ||
                                assesmentprovider.getvalue(10) ==
                                    'Front open washer & dryer')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider,
                                10,
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
                              child: Text(
                                  'Where are detergent & supplies stored in?',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: DropdownButton(
                                isExpanded: true,
                                items: [
                                  DropdownMenuItem(
                                    child: Text('--'),
                                    value: '',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Wall mounted cabinets'),
                                    value: 'Wall mounted cabinets',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Shelves - wall mounted'),
                                    value: 'Sheleves - wall mounted',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Shelves - on the floor'),
                                    value: 'Shelves - on the floor',
                                  ),
                                ],
                                onChanged: (value) {
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    FocusScope.of(context)
                                        .requestFocus(focusNode);
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(11, value,
                                        'Where are detergent & supplies  stored in?');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context)
                                        .requestFocus(focusNode);
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(11, value,
                                        'Where are detergent & supplies stored in?');
                                  } else {
                                    _showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                                value: assesmentprovider.getvalue(11),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .58,
                              child: Text('Able to access laundry cabinets?',
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
                            //       assesmentprovider.setdata(12, value,
                            //           'Able to access laundry cabinets?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus(focusNode);
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       assesmentprovider.setdata(12, value,
                            //           'Able to access laundry cabinets?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: assesmentprovider.getvalue(12),
                            // )
                            toggleButton(context, assesmentprovider, 12,
                                'Able to access laundry cabinets?')
                          ],
                        ),
                        (assesmentprovider.getvalue(12) == 'No')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider,
                                12,
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
                            //       assesmentprovider.setdata(
                            //           13, value, 'Smoke Detector Present?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus(focusNode);
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       assesmentprovider.setdata(
                            //           13, value, 'Smoke Detector Present?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: assesmentprovider.getvalue(13),
                            // )
                            toggleButton(context, assesmentprovider, 13,
                                'Smoke Detector Present?')
                          ],
                        ),
                        (assesmentprovider.getvalue(13) == 'No')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider,
                                13,
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
                          height: 5,
                        ),
                        // Container(
                        //     // height: 10000,
                        //     child: TextFormField(
                        //   initialValue: widget.wholelist[7][widget.accessname]
                        //       ['question']['14']['Answer'],
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
                        //       FocusScope.of(context).requestFocus(focusNode);
                        //       new TextEditingController().clear();
                        //       // print(widget.accessname);
                        //       assesmentprovider.setdata(
                        //           14, value, 'Observations');
                        //     } else if (role != "therapist") {
                        //       FocusScope.of(context).requestFocus(focusNode);
                        //       new TextEditingController().clear();
                        //       // print(widget.accessname);
                        //       assesmentprovider.setdata(
                        //           14, value, 'Observations');
                        //     } else {
                        //       _showSnackBar(
                        //           "You can't change the other fields", context);
                        //     }
                        //   },
                        // ))
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
                                      assesmentprovider.controllers["field14"],
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),

                                  onChanged: (value) {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    if (assessor == therapist &&
                                        role == "therapist") {
                                      assesmentprovider.setreco(14, value);
                                      assesmentprovider.setdata(
                                          14, value, 'Oberservations');
                                    } else if (role != "therapist") {
                                      assesmentprovider.setreco(14, value);
                                      assesmentprovider.setdata(
                                          14, value, 'Oberservations');
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
                                    assesmentprovider.isRecognizing['field14'],
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
                                    heroTag: "btn14",
                                    child: Icon(
                                      assesmentprovider.isRecognizing['field14']
                                          ? Icons.stop_circle
                                          : Icons.mic,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      if (assessor == therapist &&
                                          role == "therapist") {
                                        // assesmentprovider.listen(14);
                                        assesmentprovider
                                                .isRecognizing['field14']
                                            ? assesmentprovider
                                                .stopRecording(14)
                                            : assesmentprovider
                                                .streamingRecognize(
                                                    14,
                                                    assesmentprovider
                                                            .controllers[
                                                        "field14"]);
                                        assesmentprovider.setdatalisten(14);
                                      } else if (role != "therapist") {
                                        // assesmentprovider.listen(14);
                                        assesmentprovider
                                                .isRecognizing['field14']
                                            ? assesmentprovider
                                                .stopRecording(14)
                                            : assesmentprovider
                                                .streamingRecognize(
                                                    14,
                                                    assesmentprovider
                                                            .controllers[
                                                        "field14"]);
                                        assesmentprovider.setdatalisten(14);
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
                              color: assesmentprovider.colorsset["field${14}"],
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
                          widget.wholelist[7][widget.accessname]['complete'];
                      for (int i = 0;
                          i <
                              widget.wholelist[7][widget.accessname]['question']
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
                            context, widget.wholelist[7][widget.accessname]);
                        // } else {
                        //   _showSnackBar(
                        //       "Provide all recommendtions", context);
                        // }
                      } else {
                        NewAssesmentRepository()
                            .setLatestChangeDate(widget.docID);
                        NewAssesmentRepository()
                            .setForm(widget.wholelist, widget.docID);
                        Navigator.pop(
                            context, widget.wholelist[7][widget.accessname]);
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
