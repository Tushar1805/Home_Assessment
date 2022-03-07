import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Bathroom/bathroompro.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentrepo.dart';
import 'package:tryapp/constants.dart';
import 'package:path/path.dart';

import '../ViewVideo.dart';

final _colorgreen = Color.fromRGBO(10, 80, 106, 1);

class BathroomUI extends StatefulWidget {
  String roomname, docID;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  BathroomUI(this.roomname, this.wholelist, this.accessname, this.docID);
  @override
  _BathroomUIState createState() => _BathroomUIState();
}

class _BathroomUIState extends State<BathroomUI> {
  String assessor, therapist, curUid, role;
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  var test = TextEditingController();
  String videoDownloadUrl, videoUrl, videoName;
  File video;
  bool uploading = false;
  @override
  void initState() {
    super.initState();
    setinitials();
    getAssessData();
    getRole();
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
              // if (widget.wholelist[5][widget.accessname].contains("videos"))
              videoUrl = widget.wholelist[5][widget.accessname]["videos"]["url"]
                      .toString() ??
                  "";
              videoName = widget.wholelist[5][widget.accessname]["videos"]
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

  Future<void> setinitials() async {
    if (widget.wholelist[5][widget.accessname].containsKey('isSave')) {
    } else {
      widget.wholelist[5][widget.accessname]["isSave"] = true;
    }
    if (widget.wholelist[5][widget.accessname].containsKey('videos')) {
      if (widget.wholelist[5][widget.accessname]['videos']
          .containsKey('name')) {
      } else {
        widget.wholelist[5][widget.accessname]['videos']['name'] = "";
      }
      if (widget.wholelist[5][widget.accessname]['videos'].containsKey('url')) {
      } else {
        widget.wholelist[5][widget.accessname]['videos']['url'] = "";
      }
    } else {
      // print('Yes,it is');

      widget.wholelist[5][widget.accessname]
          ["videos"] = {'name': '', 'url': ''};
    }
    if (widget.wholelist[5][widget.accessname]['question']["7"]
        .containsKey('doorwidth')) {
    } else {
      print('getting created');
      widget.wholelist[5][widget.accessname]['question']["7"]['doorwidth'] = 0;
    }
    if (widget.wholelist[5][widget.accessname]['question']["9"]
        .containsKey('telephoneType')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["9"]['telephoneType'] =
          '';
    }

    if (widget.wholelist[5][widget.accessname]['question']["15"]
        .containsKey('ManageInOut')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["15"]['ManageInOut'] =
          '';
    }

    if (widget.wholelist[5][widget.accessname]['question']["16"]
        .containsKey('Grabbar')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["16"]['Grabbar'] = {};
    }

    if (widget.wholelist[5][widget.accessname]['question']["16"]['Grabbar']
        .containsKey('Grabplacement')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["16"]['Grabbar']
          ["Grabplacement"] = '';
    }

    if (widget.wholelist[5][widget.accessname]['question']["16"]['Grabbar']
        .containsKey('sidefentrance')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["16"]['Grabbar']
          ['sidefentrance'] = '';
    }

    if (widget.wholelist[5][widget.accessname]['question']["16"]['Grabbar']
        .containsKey('distanceFromFloor')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["16"]['Grabbar']
          ['distanceFromFloor'] = '';
    }
    if (widget.wholelist[5][widget.accessname]['question']["16"]['Grabbar']
        .containsKey('grabBarLength')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["16"]['Grabbar']
          ['grabBarLength'] = '';
    }

    if (widget.wholelist[5][widget.accessname]['question']["20"]
        .containsKey('')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["16"]['Grabbar']
          ['grabBarLength'] = '';
    }
    if (widget.wholelist[5][widget.accessname]['question']["20"]
        .containsKey('ManageInOut')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["20"]['ManageInOut'] =
          '';
    }

    if (widget.wholelist[5][widget.accessname]['question']["5"]
        .containsKey('toggle')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["5"]
          ['toggle'] = <bool>[true, false];
    }
    if (widget.wholelist[5][widget.accessname]['question']["8"]
        .containsKey('toggle')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["8"]
          ['toggle'] = <bool>[true, false];
    }

    if (widget.wholelist[5][widget.accessname]['question']["9"]
        .containsKey('toggle')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["9"]
          ['toggle'] = <bool>[true, false];
    }
    if (widget.wholelist[5][widget.accessname]['question']["10"]
        .containsKey('toggle')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["10"]
          ['toggle'] = <bool>[true, false];
    }

    if (widget.wholelist[5][widget.accessname]['question']["12"]
        .containsKey('toggle')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["12"]
          ['toggle'] = <bool>[true, false];
    }

    if (widget.wholelist[5][widget.accessname]['question']["13"]
        .containsKey('toggle')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["13"]
          ['toggle'] = <bool>[true, false];
    }

    if (widget.wholelist[5][widget.accessname]['question']["14"]
        .containsKey('toggle')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["14"]
          ['toggle'] = <bool>[true, false];
    }

    if (widget.wholelist[5][widget.accessname]['question']["15"]
        .containsKey('toggle')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["15"]
          ['toggle'] = <bool>[true, false];
    }
    if (widget.wholelist[5][widget.accessname]['question']["16"]
        .containsKey('toggle')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["16"]
          ['toggle'] = <bool>[true, false];
    }
    if (widget.wholelist[5][widget.accessname]['question']["16"]["Grabbar"]
        .containsKey('toggle')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["16"]['Grabbar']
          ['toggle'] = <bool>[true, false];
    }
    if (widget.wholelist[5][widget.accessname]['question']["18"]
        .containsKey('toggle')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["18"]
          ['toggle'] = <bool>[true, false];
    }

    if (widget.wholelist[5][widget.accessname]['question']["20"]
        .containsKey('toggle')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["20"]
          ['toggle'] = <bool>[true, false];
    }

    if (widget.wholelist[5][widget.accessname]['question']["20"]
        .containsKey('toggle2')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["20"]
          ['toggle2'] = <bool>[true, false];
    }

    if (widget.wholelist[5][widget.accessname]['question']["21"]
        .containsKey('toggle')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["21"]
          ['toggle'] = <bool>[true, false];
    }

    if (widget.wholelist[5][widget.accessname]['question']["23"]
        .containsKey('toggle')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["23"]
          ['toggle'] = <bool>[true, false];
    }

    if (widget.wholelist[5][widget.accessname]['question']["24"]
        .containsKey('toggle')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["24"]
          ['toggle'] = <bool>[true, false];
    }

    if (widget.wholelist[5][widget.accessname]['question']["20"]
        .containsKey('ManageInOut')) {
    } else {
      widget.wholelist[5][widget.accessname]['question']["20"]['ManageInOut'] =
          '';
    }

    // if (widget.wholelist[5][widget.accessname]['question']["17"]
    //     .containsKey('sidefentrance')) {
    // } else {
    //   widget.wholelist[5][widget.accessname]['question']["17"]
    //       ['sidefentrance'] = '';
    // }
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

  Widget toggleButton(
      BuildContext context, BathroomPro pro, int queIndex, String que) {
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
                          .wholelist[5][widget.accessname]['question']
                              ['$queIndex']['toggle']
                          .length;
                  i++) {
                widget.wholelist[5][widget.accessname]['question']['$queIndex']
                    ['toggle'][i] = i == select;
              }
            });
            pro.setdata(
                queIndex,
                widget.wholelist[5][widget.accessname]['question']['$queIndex']
                        ['toggle'][0]
                    ? 'Yes'
                    : 'No',
                que);
          } else if (role != "therapist") {
            setState(() {
              for (int i = 0;
                  i <
                      widget
                          .wholelist[5][widget.accessname]['question']
                              ['$queIndex']['toggle']
                          .length;
                  i++) {
                widget.wholelist[5][widget.accessname]['question']['$queIndex']
                    ['toggle'][i] = i == select;
              }
            });
            pro.setdata(
                queIndex,
                widget.wholelist[5][widget.accessname]['question']['$queIndex']
                        ['toggle'][0]
                    ? 'Yes'
                    : 'No',
                que);
          } else {
            _showSnackBar("You can't change the other fields", context);
          }
        },
        isSelected: widget.wholelist[5][widget.accessname]['question']
                ['$queIndex']['toggle']
            .cast<bool>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assesmentprovider = Provider.of<BathroomPro>(context);
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
          widget.wholelist[5][widget.accessname]["videos"]["url"] = videoUrl;
          widget.wholelist[5][widget.accessname]["videos"]["name"] = videoName;
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
          XFile pickedVideo =
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

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: (widget.roomname != null)
              ? Text("${widget.roomname}")
              : Text('Bathroom'),
          automaticallyImplyLeading: false,
          backgroundColor: _colorgreen,
          actions: [
            IconButton(
              icon: Icon(Icons.done_all, color: Colors.white),
              onPressed: () async {
                try {
                  listenbutton(assesmentprovider, context);
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
                                                  widget.wholelist[5]
                                                          [widget.accessname]
                                                      ["videos"]["name"] = "";
                                                  widget.wholelist[5]
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
                                                  widget.wholelist[5]
                                                          [widget.accessname]
                                                      ["videos"]["name"] = "";
                                                  widget.wholelist[5]
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
                              child: Text('Threshold to Living Room',
                                  style: TextStyle(
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                    fontSize: 20,
                                  )),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .25,
                              child: TextFormField(
                                  initialValue: assesmentprovider.getvalue(1),
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
                                          1, value, 'Threshold to Living Room');
                                    } else if (role != "therapist") {
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);

                                      assesmentprovider.setdata(
                                          1, value, 'Threshold to Living Room');
                                    } else {
                                      _showSnackBar(
                                          "You can't change the other fields",
                                          context);
                                    }

                                    // print(assesmentprovider.getvalue(1));
                                  }),
                            ),
                          ],
                        ),
                        (assesmentprovider.getvalue(1) != '')
                            ? (double.parse(assesmentprovider.getvalue(1)) > 5)
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
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: DropdownButton(
                                isExpanded: true,
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
                                    assesmentprovider.setdata(
                                        2, value, 'Flooring Type');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
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
                        //   color: Color.fromRGBO(10, 20, 102, 1),
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
                        //   color: Color.fromRGBO(10, 20, 102, 1),
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
                        (assesmentprovider.getvalue(4) == "Inadequate")
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
                        //   color: Color.fromRGBO(10, 20, 102, 1),
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
                                'Able to Operate Switches?'),
                          ],
                        ),
                        SizedBox(height: 10),
                        (assesmentprovider.getvalue(5) != 'Yes' &&
                                assesmentprovider.getvalue(5) != '')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider,
                                5,
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
                                  initialValue: assesmentprovider.getvalue(7),
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
                                          7, value, 'Door Width');
                                      setState(() {
                                        widget.wholelist[5][widget.accessname]
                                            ['question']["7"]['doorwidth'] = 0;

                                        widget.wholelist[5][widget.accessname]
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
                                        widget.wholelist[5][widget.accessname]
                                            ['question']["7"]['doorwidth'] = 0;

                                        widget.wholelist[5][widget.accessname]
                                                ['question']["7"]['doorwidth'] =
                                            double.parse(value);
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
                        SizedBox(
                          height: 5,
                        ),
                        (widget.wholelist[5][widget.accessname]['question']["7"]
                                        ['doorwidth'] <
                                    30 &&
                                widget.wholelist[5][widget.accessname]
                                        ['question']["7"]['doorwidth'] >
                                    0 &&
                                widget.wholelist[5][widget.accessname]
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
                        //   color: Color.fromRGBO(10, 70, 105, 1),
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
                                'Obstacle/Clutter Present?'),
                          ],
                        ),
                        SizedBox(height: 10),
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
                              child: Text('Able to Access Telephone?',
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
                            //           9, value, 'Able to Access Telephone?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       assesmentprovider.setdata(
                            //           9, value, 'Able to Access Telephone?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: assesmentprovider.getvalue(9),
                            // )
                            toggleButton(context, assesmentprovider, 9,
                                'Able to Access Telephone?'),
                          ],
                        ),
                        SizedBox(height: 10),
                        (assesmentprovider.getvalue(9) != 'Yes' &&
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
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .6,
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
                                            widget.wholelist[5]
                                                        [widget.accessname]
                                                    ['question']["9"]
                                                ['telephoneType'] = value;
                                          } else if (role != "therapist") {
                                            FocusScope.of(context)
                                                .requestFocus();
                                            new TextEditingController().clear();
                                            // print(widget.accessname);
                                            widget.wholelist[5]
                                                        [widget.accessname]
                                                    ['question']["9"]
                                                ['telephoneType'] = value;
                                          } else {
                                            _showSnackBar(
                                                "You can't change the other fields",
                                                context);
                                          }
                                        },
                                        value: widget.wholelist[5]
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
                            //           10, value, 'Smoke Detector Present?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       assesmentprovider.setdata(
                            //           10, value, 'Smoke Detector Present?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: assesmentprovider.getvalue(10),
                            // )
                            toggleButton(context, assesmentprovider, 10,
                                'Smoke Detector Present?'),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        (assesmentprovider.getvalue(10) == 'No')
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
                              width: MediaQuery.of(context).size.width * .35,
                              child: Text(
                                  'Able to manage through the doorway & in/out of the bathroom?',
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

                                  assesmentprovider.setdata(11, value,
                                      'Able to manage through the doorway & in/out of the bathroom?');
                                } else if (role != "therapist") {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);

                                  assesmentprovider.setdata(11, value,
                                      'Able to manage through the doorway & in/out of the bathroom?');
                                } else {
                                  _showSnackBar(
                                      "You can't change the other fields",
                                      context);
                                }
                              },
                              value: assesmentprovider.getvalue(11),
                            )
                          ],
                        ),
                        (assesmentprovider.getvalue(11) != 'Fairly Well' &&
                                assesmentprovider.getvalue(11) != '')
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
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .58,
                              child: Text('Has access to medicine cabinet?',
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

                            //       assesmentprovider.setdata(12, value,
                            //           'Has access to medicine cabinet?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);

                            //       assesmentprovider.setdata(12, value,
                            //           'Has access to medicine cabinet?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: assesmentprovider.getvalue(12),
                            // )
                            toggleButton(context, assesmentprovider, 12,
                                'Has access to medicine cabinet?'),
                          ],
                        ),
                        SizedBox(
                          height: 10,
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
                              child: Text('Has access to cabinet under sink?',
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

                            //       assesmentprovider.setdata(13, value,
                            //           'Has access to cabinet under sink?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);

                            //       assesmentprovider.setdata(13, value,
                            //           'Has access to cabinet under sink?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: assesmentprovider.getvalue(13),
                            // )
                            toggleButton(context, assesmentprovider, 13,
                                'Has access to cabinet under sink?'),
                          ],
                        ),
                        SizedBox(
                          height: 10,
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
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: Text('Shower Present?',
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
                            //           14, value, 'Shower: Present?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);

                            //       assesmentprovider.setdata(
                            //           14, value, 'Shower: Present?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: assesmentprovider.getvalue(14),
                            // )
                            toggleButton(context, assesmentprovider, 14,
                                'Shower: Present?')
                          ],
                        ),
                        SizedBox(height: 10),
                        (assesmentprovider.getvalue(14) == 'Yes')
                            ? TextFormField(
                                // null,
                                controller:
                                    assesmentprovider.controllers["field${14}"],
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: assesmentprovider
                                              .colorsset["field${14}"],
                                          width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: assesmentprovider
                                              .colorsset["field${14}"]),
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
                                            animate: assesmentprovider
                                                .isListening['field${14}'],
                                            glowColor:
                                                Theme.of(context).primaryColor,
                                            endRadius: 500.0,
                                            duration: const Duration(
                                                milliseconds: 2000),
                                            repeatPauseDuration: const Duration(
                                                milliseconds: 100),
                                            repeat: true,
                                            child: FloatingActionButton(
                                              child: Icon(
                                                Icons.mic,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                if (assessor == therapist &&
                                                    role == "therapist") {
                                                  assesmentprovider.listen(14);
                                                  assesmentprovider
                                                      .setdatalisten(14);
                                                } else if (role !=
                                                    "therapist") {
                                                  assesmentprovider.listen(14);
                                                  assesmentprovider
                                                      .setdatalisten(14);
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
                                    labelText:
                                        'Specify seat, usage & type of shower'),
                                onChanged: (value) {
                                  if (assessor == therapist &&
                                      role == "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setreco(14, value);
                                  } else if (role != "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setreco(14, value);
                                  } else {
                                    _showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                              )
                            : SizedBox(),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .58,
                              child:
                                  Text('Able to manage in & out of the shower?',
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
                            //       assesmentprovider.setdata(15, value,
                            //           'Able to manage in & out of the shower?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       assesmentprovider.setdata(15, value,
                            //           'Able to manage in & out of the shower?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: assesmentprovider.getvalue(15),
                            // )
                            toggleButton(context, assesmentprovider, 15,
                                'Able to manage in & out of the shower?'),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        (assesmentprovider.getvalue(15) == 'No')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider,
                                15,
                                true,
                                'Comments (if any)',
                                assessor,
                                therapist,
                                role,
                                context)
                            : SizedBox(height: 15),
                        (assesmentprovider.getvalue(15) == 'Yes')
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
                                                .4,
                                            child: Text(
                                                'Able to manage in & out of the shower independently or with assistance?',
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
                                                child: Text(
                                                    'With Assistive Device'),
                                                value: 'With Assistive Device',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Independently'),
                                                value: 'Independently',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('With Assistance'),
                                                value: 'With Assistance',
                                              ),
                                            ],
                                            onChanged: (value) {
                                              if (assessor == therapist &&
                                                  role == "therapist") {
                                                widget.wholelist[5]
                                                            [widget.accessname]
                                                        ['question']["15"]
                                                    ['ManageInOut'] = value;
                                              } else if (role != "therapist") {
                                                widget.wholelist[5]
                                                            [widget.accessname]
                                                        ['question']["15"]
                                                    ['ManageInOut'] = value;
                                              } else {
                                                _showSnackBar(
                                                    "You can't change the other fields",
                                                    context);
                                              }
                                            },
                                            value: widget.wholelist[5]
                                                        [widget.accessname]
                                                    ['question']["15"]
                                                ['ManageInOut'],
                                          )
                                        ],
                                      ),
                                    ),
                                    (widget.wholelist[5][widget.accessname]
                                                        ['question']["15"]
                                                    ['ManageInOut'] !=
                                                "" &&
                                            widget.wholelist[5]
                                                            [widget.accessname]
                                                        ['question']["15"]
                                                    ['ManageInOut'] !=
                                                "Independently")
                                        ? assesmentprovider.getrecomain(
                                            assesmentprovider,
                                            15,
                                            true,
                                            'Comments (if any)',
                                            assessor,
                                            therapist,
                                            role,
                                            context)
                                        : SizedBox(),
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
                              width: MediaQuery.of(context).size.width * .58,
                              child: Text('Grab Bars Present?',
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
                            //           16, value, 'Grab Bars Present?');
                            //       if (value == 'No') {
                            //         setState(() {
                            //           assesmentprovider.grabbarneeded = false;
                            //         });
                            //       }
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       assesmentprovider.setdata(
                            //           16, value, 'Grab Bars Present?');
                            //       if (value == 'No') {
                            //         setState(() {
                            //           assesmentprovider.grabbarneeded = false;
                            //         });
                            //       }
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: assesmentprovider.getvalue(16),
                            // )
                            toggleButton(context, assesmentprovider, 16,
                                'Grab Bars Present?')
                          ],
                        ),
                        SizedBox(height: 10),
                        (assesmentprovider.getvalue(16) == 'Yes')
                            ? Column(
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
                                              .4,
                                          child: Text('Grab Bar Type',
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
                                              child: Text('Chrome'),
                                              value: 'Chrome',
                                            ),
                                            DropdownMenuItem(
                                              child: Text('Metal'),
                                              value: 'Metal',
                                            ),
                                            DropdownMenuItem(
                                              child: Text('Stainless Steel'),
                                              value: 'Stainless Steel',
                                            ),
                                            DropdownMenuItem(
                                              child: Text('Plastic'),
                                              value: 'Plastic',
                                            ),
                                          ],
                                          onChanged: (value) {
                                            if (assessor == therapist &&
                                                role == "therapist") {
                                              setState(() {
                                                widget.wholelist[5][widget
                                                                .accessname]
                                                            ['question']["16"]
                                                        ['Grabbar']
                                                    ['Grabbartype'] = value;
                                              });
                                            } else if (role != "therapist") {
                                              setState(() {
                                                widget.wholelist[5][widget
                                                                .accessname]
                                                            ['question']["16"]
                                                        ['Grabbar']
                                                    ['Grabbartype'] = value;
                                              });
                                            } else {
                                              _showSnackBar(
                                                  "You can't change the other fields",
                                                  context);
                                            }
                                          },
                                          value: widget.wholelist[5]
                                                      [widget.accessname]
                                                  ['question']["16"]['Grabbar']
                                              ['Grabbartype'],
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
                                              .6,
                                          child: Text('Grab Bar Attachment',
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
                                              child: Text('Removable'),
                                              value: 'Removable',
                                            ),
                                            DropdownMenuItem(
                                              child: Text('Fixed'),
                                              value: 'Fixed',
                                            ),
                                          ],
                                          onChanged: (value) {
                                            if (assessor == therapist &&
                                                role == "therapist") {
                                              setState(() {
                                                widget.wholelist[5][widget
                                                                .accessname]
                                                            ['question']["16"]
                                                        ['Grabbar']
                                                    ['Grabattachment'] = value;
                                              });
                                            } else if (role != "therapist") {
                                              setState(() {
                                                widget.wholelist[5][widget
                                                                .accessname]
                                                            ['question']["16"]
                                                        ['Grabbar']
                                                    ['Grabattachment'] = value;
                                              });
                                            } else {
                                              _showSnackBar(
                                                  "You can't change the other fields",
                                                  context);
                                            }
                                          },
                                          value: widget.wholelist[5]
                                                      [widget.accessname]
                                                  ['question']["16"]['Grabbar']
                                              ['Grabattachment'],
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
                                              .6,
                                          child: Text('Grab Bar Placement',
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
                                              value: 'left',
                                            ),
                                            DropdownMenuItem(
                                              child: Text('Right'),
                                              value: 'right',
                                            ),
                                            DropdownMenuItem(
                                              child: Text('Both Sides'),
                                              value: 'Both Sides',
                                            ),
                                          ],
                                          onChanged: (value) {
                                            if (assessor == therapist &&
                                                role == "therapist") {
                                              FocusScope.of(context)
                                                  .requestFocus();
                                              new TextEditingController()
                                                  .clear();
                                              // print(widget.accessname);
                                              setState(() {
                                                widget.wholelist[5][widget
                                                                .accessname]
                                                            ['question']["16"]
                                                        ['Grabbar']
                                                    ['Grabplacement'] = value;
                                              });
                                              // assesmentprovider.setdata(17,
                                              //     value, 'Grab Bar Placement');
                                            } else if (role != "therapist") {
                                              FocusScope.of(context)
                                                  .requestFocus();
                                              new TextEditingController()
                                                  .clear();
                                              // print(widget.accessname);
                                              setState(() {
                                                widget.wholelist[5][widget
                                                                .accessname]
                                                            ['question']["16"]
                                                        ['Grabbar']
                                                    ['Grabplacement'] = value;
                                              });
                                              // assesmentprovider.setdata(17,
                                              //     value, 'Grab Bar Placement');
                                            } else {
                                              _showSnackBar(
                                                  "You can't change the other fields",
                                                  context);
                                            }
                                          },
                                          value: widget.wholelist[5]
                                                      [widget.accessname]
                                                  ['question']["16"]['Grabbar']
                                              ['Grabplacement'],
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  (widget.wholelist[5][widget.accessname]
                                                  ['question']["16"]['Grabbar']
                                              ['Grabplacement'] !=
                                          '')
                                      ? Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .4,
                                                child: Text(
                                                    'Grab bar is present in which side of the shower entrance?',
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
                                                    child: Text(
                                                        'Facing the Shower'),
                                                    value: 'Facing the Shower',
                                                  ),
                                                  DropdownMenuItem(
                                                    child: Text(
                                                        'On the Back Wall'),
                                                    value: 'On the Back Wall',
                                                  ),
                                                ],
                                                onChanged: (value) {
                                                  if (assessor == therapist &&
                                                      role == "therapist") {
                                                    FocusScope.of(context)
                                                        .requestFocus();
                                                    new TextEditingController()
                                                        .clear();
                                                    // print(widget.accessname);
                                                    setState(() {
                                                      widget.wholelist[5][widget
                                                                      .accessname]
                                                                  ['question']
                                                              ["16"]['Grabbar'][
                                                          'sidefentrance'] = value;
                                                    });
                                                  } else if (role !=
                                                      "therapist") {
                                                    FocusScope.of(context)
                                                        .requestFocus();
                                                    new TextEditingController()
                                                        .clear();
                                                    // print(widget.accessname);
                                                    setState(() {
                                                      widget.wholelist[5][widget
                                                                      .accessname]
                                                                  ['question']
                                                              ["16"]['Grabbar'][
                                                          'sidefentrance'] = value;
                                                    });
                                                  } else {
                                                    _showSnackBar(
                                                        "You can't change the other fields",
                                                        context);
                                                  }
                                                },
                                                value: widget.wholelist[5]
                                                            [widget.accessname]
                                                        ['question']["16"][
                                                    'Grabbar']['sidefentrance'],
                                              )
                                            ],
                                          ),
                                        )
                                      : SizedBox(),
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
                                                .6,
                                            child: Text(
                                                'Grab Bar Distance From Floor',
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
                                                .25,
                                            child: TextFormField(
                                              initialValue: widget.wholelist[5][
                                                              widget.accessname]
                                                          ['question']["16"]
                                                      ['Grabbar']
                                                  ['distanceFromFloor'],
                                              decoration: InputDecoration(
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Color.fromRGBO(
                                                            10, 80, 106, 1),
                                                        width: 1),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        BorderSide(width: 1),
                                                  ),
                                                  labelText: '(Inches)'),
                                              keyboardType: TextInputType.phone,
                                              onChanged: (value) {
                                                if (assessor == therapist &&
                                                    role == "therapist") {
                                                  FocusScope.of(context)
                                                      .requestFocus();
                                                  new TextEditingController()
                                                      .clear();
                                                  setState(() {
                                                    widget.wholelist[5][widget
                                                                    .accessname]
                                                                ['question']
                                                            ["16"]['Grabbar'][
                                                        'distanceFromFloor'] = value;
                                                  });
                                                  // print(widget.accessname);
                                                  // assesmentprovider.setdata(
                                                  //     18,
                                                  //     value,
                                                  //     'Grab Bar Distance From Floor');
                                                } else if (role !=
                                                    "therapist") {
                                                  FocusScope.of(context)
                                                      .requestFocus();
                                                  new TextEditingController()
                                                      .clear();
                                                  // print(widget.accessname);
                                                  setState(() {
                                                    widget.wholelist[5][widget
                                                                    .accessname]
                                                                ['question']
                                                            ["16"]['Grabbar'][
                                                        'distanceFromFloor'] = value;
                                                  });
                                                  // assesmentprovider.setdata(
                                                  //     18,
                                                  //     value,
                                                  //     'Grab Bar Distance From Floor');
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  (widget.wholelist[5][widget.accessname]
                                                  ['question']["16"]['Grabbar']
                                              ['distanceFromFloor'] !=
                                          "")
                                      ? (double.parse(widget.wholelist[5]
                                                              [widget.accessname]
                                                          ['question']["16"]
                                                      ['Grabbar']
                                                  ['distanceFromFloor']) >
                                              120)
                                          ? assesmentprovider.getrecomain(
                                              assesmentprovider,
                                              16,
                                              true,
                                              "Comments (if any)",
                                              assessor,
                                              therapist,
                                              role,
                                              context)
                                          : SizedBox()
                                      : SizedBox(),
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
                                                .4,
                                            child: Text('Grab Bar Length',
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
                                                .25,
                                            child: TextFormField(
                                              initialValue: widget.wholelist[5]
                                                          [widget.accessname]
                                                      ['question']["16"]
                                                  ['Grabbar']['grabBarLength'],
                                              decoration: InputDecoration(
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Color.fromRGBO(
                                                            10, 80, 106, 1),
                                                        width: 1),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        BorderSide(width: 1),
                                                  ),
                                                  labelText: '(Inches)'),
                                              keyboardType: TextInputType.phone,
                                              onChanged: (value) {
                                                if (assessor == therapist &&
                                                    role == "therapist") {
                                                  FocusScope.of(context)
                                                      .requestFocus();
                                                  new TextEditingController()
                                                      .clear();
                                                  // print(widget.accessname);

                                                  setState(() {
                                                    widget.wholelist[5][widget
                                                                    .accessname]
                                                                ['question']
                                                            ["16"]['Grabbar'][
                                                        'grabBarLength'] = value;
                                                  });
                                                  // assesmentprovider.setdata(
                                                  //     19, value, 'Grab Bar Length');
                                                } else if (role !=
                                                    "therapist") {
                                                  FocusScope.of(context)
                                                      .requestFocus();
                                                  new TextEditingController()
                                                      .clear();
                                                  // print(widget.accessname);
                                                  setState(() {
                                                    widget.wholelist[5][widget
                                                                    .accessname]
                                                                ['question']
                                                            ["16"]['Grabbar'][
                                                        'grabBarLength'] = value;
                                                  });
                                                  // assesmentprovider.setdata(
                                                  //     19, value, 'Grab Bar Length');
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              )
                            : (assesmentprovider.getvalue(16) != 'Yes' &&
                                    assesmentprovider.getvalue(16) != '')
                                ? Column(
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
                                                  .4,
                                              child: Text('Grab Bar Needed?',
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        10, 80, 106, 1),
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
                                            //       setState(() {
                                            //         widget.wholelist[5][widget
                                            //                         .accessname]
                                            //                     ['question']
                                            //                 ["16"]['Grabbar']
                                            //             ['Grabneeded'] = value;
                                            //       });
                                            //     } else if (role !=
                                            //         "therapist") {
                                            //       setState(() {
                                            //         widget.wholelist[5][widget
                                            //                         .accessname]
                                            //                     ['question']
                                            //                 ["16"]['Grabbar']
                                            //             ['Grabneeded'] = value;
                                            //       });
                                            //     } else {
                                            //       _showSnackBar(
                                            //           "You can't change the other fields",
                                            //           context);
                                            //     }
                                            //   },
                                            //   value: widget.wholelist[5]
                                            //               [widget.accessname]
                                            //           ['question']["16"]
                                            //       ['Grabbar']['Grabneeded'],
                                            // ),
                                            Container(
                                              height: 35,
                                              child: ToggleButtons(
                                                borderColor: Colors.black,
                                                fillColor: Colors.green,
                                                borderWidth: 0,
                                                selectedBorderColor:
                                                    Colors.black,
                                                selectedColor: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      'Yes',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      'No',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                ],
                                                onPressed: (int select) {
                                                  if (assessor == therapist &&
                                                      role == "therapist") {
                                                    setState(() {
                                                      for (int i = 0;
                                                          i <
                                                              widget
                                                                  .wholelist[5][
                                                                      widget
                                                                          .accessname]
                                                                      [
                                                                      'question']
                                                                      ["16"][
                                                                      'Grabbar']
                                                                      ['toggle']
                                                                  .length;
                                                          i++) {
                                                        widget.wholelist[5][widget
                                                                        .accessname]
                                                                    ['question']
                                                                [
                                                                "16"]['Grabbar']
                                                            [
                                                            'toggle'][i] = i == select;
                                                      }
                                                      widget.wholelist[5][widget.accessname]
                                                                      ['question']
                                                                  ["16"]['Grabbar']
                                                              ['toggle'][0]
                                                          ? widget.wholelist[5]
                                                                      [widget.accessname]['question']
                                                                  ["16"]['Grabbar']['Grabneeded'] =
                                                              "Yes"
                                                          : widget.wholelist[5]
                                                                          [widget.accessname]
                                                                      ['question']
                                                                  ["16"]['Grabbar']
                                                              ['Grabneeded'] = "No";
                                                    });
                                                  } else if (role !=
                                                      "therapist") {
                                                    setState(() {
                                                      for (int i = 0;
                                                          i <
                                                              widget
                                                                  .wholelist[5][
                                                                      widget
                                                                          .accessname]
                                                                      [
                                                                      'question']
                                                                      ["16"][
                                                                      'Grabbar']
                                                                      ['toggle']
                                                                  .length;
                                                          i++) {
                                                        widget.wholelist[5][widget
                                                                        .accessname]
                                                                    ['question']
                                                                [
                                                                "16"]['Grabbar']
                                                            [
                                                            'toggle'][i] = i == select;
                                                      }
                                                      widget.wholelist[5][widget.accessname]
                                                                      ['question']
                                                                  ["16"]['Grabbar']
                                                              ['toggle'][0]
                                                          ? widget.wholelist[5]
                                                                      [widget.accessname]['question']
                                                                  ["16"]['Grabbar']['Grabneeded'] =
                                                              "Yes"
                                                          : widget.wholelist[5]
                                                                          [widget.accessname]
                                                                      ['question']
                                                                  ["16"]['Grabbar']
                                                              ['Grabneeded'] = "No";
                                                    });
                                                  } else {
                                                    _showSnackBar(
                                                        "You can't change the other fields",
                                                        context);
                                                  }
                                                },
                                                isSelected: widget.wholelist[5]
                                                        [widget.accessname]
                                                        ['question']["16"]
                                                        ['Grabbar']['toggle']
                                                    .cast<bool>(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      (widget.wholelist[5][widget.accessname]
                                                              ['question']["16"]
                                                          ['Grabbar']
                                                      ['Grabneeded'] !=
                                                  'No' &&
                                              widget.wholelist[5]
                                                              [widget.accessname]
                                                          ['question']["16"][
                                                      'Grabbar']['Grabneeded'] !=
                                                  '')
                                          ? Column(
                                              children: [
                                                Container(
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
                                                        child: Text(
                                                            'Grab Bar Type',
                                                            style: TextStyle(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      10,
                                                                      80,
                                                                      106,
                                                                      1),
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
                                                            child:
                                                                Text('Chrome'),
                                                            value: 'Chrome',
                                                          ),
                                                          DropdownMenuItem(
                                                            child:
                                                                Text('Metal'),
                                                            value: 'Metal',
                                                          ),
                                                          DropdownMenuItem(
                                                            child: Text(
                                                                'Stainless Steel'),
                                                            value:
                                                                'Stainless Steel',
                                                          ),
                                                          DropdownMenuItem(
                                                            child:
                                                                Text('Plastic'),
                                                            value: 'Plastic',
                                                          ),
                                                        ],
                                                        onChanged: (value) {
                                                          if (assessor ==
                                                                  therapist &&
                                                              role ==
                                                                  "therapist") {
                                                            setState(() {
                                                              widget.wholelist[
                                                                              5]
                                                                          [
                                                                          widget
                                                                              .accessname]['question']
                                                                      [
                                                                      "16"]['Grabbar']
                                                                  [
                                                                  'Grabbartype'] = value;
                                                            });
                                                          } else if (role !=
                                                              "therapist") {
                                                            setState(() {
                                                              widget.wholelist[
                                                                              5]
                                                                          [
                                                                          widget
                                                                              .accessname]['question']
                                                                      [
                                                                      "16"]['Grabbar']
                                                                  [
                                                                  'Grabbartype'] = value;
                                                            });
                                                          } else {
                                                            _showSnackBar(
                                                                "You can't change the other fields",
                                                                context);
                                                          }
                                                        },
                                                        value: widget.wholelist[
                                                                            5][
                                                                        widget
                                                                            .accessname]
                                                                    ['question']
                                                                [
                                                                "16"]['Grabbar']
                                                            ['Grabbartype'],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Container(
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
                                                            .6,
                                                        child: Text(
                                                            'Grab Bar Attachment',
                                                            style: TextStyle(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      10,
                                                                      80,
                                                                      106,
                                                                      1),
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
                                                            child: Text(
                                                                'Removable'),
                                                            value: 'Removable',
                                                          ),
                                                          DropdownMenuItem(
                                                            child:
                                                                Text('Fixed'),
                                                            value: 'Fixed',
                                                          ),
                                                        ],
                                                        onChanged: (value) {
                                                          if (assessor ==
                                                                  therapist &&
                                                              role ==
                                                                  "therapist") {
                                                            setState(() {
                                                              widget.wholelist[
                                                                              5]
                                                                          [
                                                                          widget
                                                                              .accessname]['question']
                                                                      [
                                                                      "16"]['Grabbar']
                                                                  [
                                                                  'Grabattachment'] = value;
                                                            });
                                                          } else if (role !=
                                                              "therapist") {
                                                            setState(() {
                                                              widget.wholelist[
                                                                              5]
                                                                          [
                                                                          widget
                                                                              .accessname]['question']
                                                                      [
                                                                      "16"]['Grabbar']
                                                                  [
                                                                  'Grabattachment'] = value;
                                                            });
                                                          } else {
                                                            _showSnackBar(
                                                                "You can't change the other fields",
                                                                context);
                                                          }
                                                        },
                                                        value: widget.wholelist[
                                                                            5][
                                                                        widget
                                                                            .accessname]
                                                                    ['question']
                                                                [
                                                                "16"]['Grabbar']
                                                            ['Grabattachment'],
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
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .6,
                                                        child: Text(
                                                            'Grab Bar Placement',
                                                            style: TextStyle(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      10,
                                                                      80,
                                                                      106,
                                                                      1),
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
                                                            value: 'left',
                                                          ),
                                                          DropdownMenuItem(
                                                            child:
                                                                Text('Right'),
                                                            value: 'right',
                                                          ),
                                                          DropdownMenuItem(
                                                            child: Text(
                                                                'Both Sides'),
                                                            value: 'Both Sides',
                                                          ),
                                                        ],
                                                        onChanged: (value) {
                                                          if (assessor ==
                                                                  therapist &&
                                                              role ==
                                                                  "therapist") {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus();
                                                            new TextEditingController()
                                                                .clear();
                                                            // print(widget.accessname);
                                                            setState(() {
                                                              widget.wholelist[
                                                                              5]
                                                                          [
                                                                          widget
                                                                              .accessname]['question']
                                                                      [
                                                                      "16"]['Grabbar']
                                                                  [
                                                                  'Grabplacement'] = value;
                                                            });
                                                            // assesmentprovider.setdata(17,
                                                            //     value, 'Grab Bar Placement');
                                                          } else if (role !=
                                                              "therapist") {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus();
                                                            new TextEditingController()
                                                                .clear();
                                                            // print(widget.accessname);
                                                            setState(() {
                                                              widget.wholelist[
                                                                              5]
                                                                          [
                                                                          widget
                                                                              .accessname]['question']
                                                                      [
                                                                      "16"]['Grabbar']
                                                                  [
                                                                  'Grabplacement'] = value;
                                                            });
                                                            // assesmentprovider.setdata(17,
                                                            //     value, 'Grab Bar Placement');
                                                          } else {
                                                            _showSnackBar(
                                                                "You can't change the other fields",
                                                                context);
                                                          }
                                                        },
                                                        value: widget.wholelist[
                                                                            5][
                                                                        widget
                                                                            .accessname]
                                                                    ['question']
                                                                [
                                                                "16"]['Grabbar']
                                                            ['Grabplacement'],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                (widget.wholelist[5][widget
                                                                        .accessname]
                                                                    ['question']
                                                                [
                                                                "16"]['Grabbar']
                                                            ['Grabplacement'] !=
                                                        '')
                                                    ? Container(
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
                                                              child: Text(
                                                                  'Grab bar is present in which side of the shower entrance?',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            10,
                                                                            80,
                                                                            106,
                                                                            1),
                                                                    fontSize:
                                                                        20,
                                                                  )),
                                                            ),
                                                            DropdownButton(
                                                              items: [
                                                                DropdownMenuItem(
                                                                  child: Text(
                                                                      '--'),
                                                                  value: '',
                                                                ),
                                                                DropdownMenuItem(
                                                                  child: Text(
                                                                      'Facing the Shower'),
                                                                  value:
                                                                      'Facing the Shower',
                                                                ),
                                                                DropdownMenuItem(
                                                                  child: Text(
                                                                      'On the Back Wall'),
                                                                  value:
                                                                      'On the Back Wall',
                                                                ),
                                                              ],
                                                              onChanged:
                                                                  (value) {
                                                                if (assessor ==
                                                                        therapist &&
                                                                    role ==
                                                                        "therapist") {
                                                                  FocusScope.of(
                                                                          context)
                                                                      .requestFocus();
                                                                  new TextEditingController()
                                                                      .clear();
                                                                  // print(widget.accessname);
                                                                  setState(() {
                                                                    widget.wholelist[5][widget.accessname]['question']["16"]
                                                                            [
                                                                            'Grabbar']
                                                                        [
                                                                        'sidefentrance'] = value;
                                                                  });
                                                                } else if (role !=
                                                                    "therapist") {
                                                                  FocusScope.of(
                                                                          context)
                                                                      .requestFocus();
                                                                  new TextEditingController()
                                                                      .clear();
                                                                  // print(widget.accessname);
                                                                  setState(() {
                                                                    widget.wholelist[5][widget.accessname]['question']["16"]
                                                                            [
                                                                            'Grabbar']
                                                                        [
                                                                        'sidefentrance'] = value;
                                                                  });
                                                                } else {
                                                                  _showSnackBar(
                                                                      "You can't change the other fields",
                                                                      context);
                                                                }
                                                              },
                                                              value: widget.wholelist[
                                                                              5]
                                                                          [
                                                                          widget
                                                                              .accessname]['question']
                                                                      [
                                                                      "16"]['Grabbar']
                                                                  [
                                                                  'sidefentrance'],
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    : SizedBox(),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
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
                                                              .6,
                                                          child: Text(
                                                              'Grab Bar Distance From Floor',
                                                              style: TextStyle(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        10,
                                                                        80,
                                                                        106,
                                                                        1),
                                                                fontSize: 20,
                                                              )),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .25,
                                                          child: TextFormField(
                                                            initialValue: widget
                                                                            .wholelist[5]
                                                                        [widget
                                                                            .accessname]
                                                                    [
                                                                    'question']["16"]['Grabbar']
                                                                [
                                                                'distanceFromFloor'],
                                                            decoration:
                                                                InputDecoration(
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Color.fromRGBO(
                                                                              10,
                                                                              80,
                                                                              106,
                                                                              1),
                                                                          width:
                                                                              1),
                                                                    ),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              width: 1),
                                                                    ),
                                                                    labelText:
                                                                        '(Inches)'),
                                                            keyboardType:
                                                                TextInputType
                                                                    .phone,
                                                            onChanged: (value) {
                                                              if (assessor ==
                                                                      therapist &&
                                                                  role ==
                                                                      "therapist") {
                                                                FocusScope.of(
                                                                        context)
                                                                    .requestFocus();
                                                                new TextEditingController()
                                                                    .clear();
                                                                setState(() {
                                                                  widget.wholelist[
                                                                              5]
                                                                          [
                                                                          widget
                                                                              .accessname]['question']["16"]['Grabbar']
                                                                      [
                                                                      'distanceFromFloor'] = value;
                                                                });
                                                                // print(widget.accessname);
                                                                // assesmentprovider.setdata(
                                                                //     18,
                                                                //     value,
                                                                //     'Grab Bar Distance From Floor');
                                                              } else if (role !=
                                                                  "therapist") {
                                                                FocusScope.of(
                                                                        context)
                                                                    .requestFocus();
                                                                new TextEditingController()
                                                                    .clear();
                                                                // print(widget.accessname);
                                                                setState(() {
                                                                  widget.wholelist[
                                                                              5]
                                                                          [
                                                                          widget
                                                                              .accessname]['question']["16"]['Grabbar']
                                                                      [
                                                                      'distanceFromFloor'] = value;
                                                                });
                                                                // assesmentprovider.setdata(
                                                                //     18,
                                                                //     value,
                                                                //     'Grab Bar Distance From Floor');
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
                                                // SizedBox(
                                                //   height: 10,
                                                // ),
                                                // (widget.wholelist[5][widget.accessname]
                                                //                 ['question']["16"]['Grabbar']
                                                //             ['distanceFromFloor'] !=
                                                //         "")
                                                //     ? (double.parse(widget.wholelist[5]
                                                //                             [widget.accessname]
                                                //                         ['question']["16"]
                                                //                     ['Grabbar']
                                                //                 ['distanceFromFloor']) >
                                                //             120)
                                                //         ? assesmentprovider.getrecomain(
                                                //             assesmentprovider,
                                                //             16,
                                                //             true,
                                                //             "Comments (if any)",
                                                //             assessor,
                                                //             therapist,
                                                //             role,
                                                //             context)
                                                //         : SizedBox()
                                                //     : SizedBox(),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
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
                                                          child: Text(
                                                              'Grab Bar Length',
                                                              style: TextStyle(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        10,
                                                                        80,
                                                                        106,
                                                                        1),
                                                                fontSize: 20,
                                                              )),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .25,
                                                          child: TextFormField(
                                                            initialValue: widget
                                                                            .wholelist[5]
                                                                        [widget
                                                                            .accessname]
                                                                    [
                                                                    'question']["16"]['Grabbar']
                                                                [
                                                                'grabBarLength'],
                                                            decoration:
                                                                InputDecoration(
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Color.fromRGBO(
                                                                              10,
                                                                              80,
                                                                              106,
                                                                              1),
                                                                          width:
                                                                              1),
                                                                    ),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              width: 1),
                                                                    ),
                                                                    labelText:
                                                                        '(Inches)'),
                                                            keyboardType:
                                                                TextInputType
                                                                    .phone,
                                                            onChanged: (value) {
                                                              if (assessor ==
                                                                      therapist &&
                                                                  role ==
                                                                      "therapist") {
                                                                FocusScope.of(
                                                                        context)
                                                                    .requestFocus();
                                                                new TextEditingController()
                                                                    .clear();
                                                                // print(widget.accessname);

                                                                setState(() {
                                                                  widget.wholelist[
                                                                              5]
                                                                          [
                                                                          widget
                                                                              .accessname]['question']["16"]['Grabbar']
                                                                      [
                                                                      'grabBarLength'] = value;
                                                                });
                                                                // assesmentprovider.setdata(
                                                                //     19, value, 'Grab Bar Length');
                                                              } else if (role !=
                                                                  "therapist") {
                                                                FocusScope.of(
                                                                        context)
                                                                    .requestFocus();
                                                                new TextEditingController()
                                                                    .clear();
                                                                // print(widget.accessname);
                                                                setState(() {
                                                                  widget.wholelist[
                                                                              5]
                                                                          [
                                                                          widget
                                                                              .accessname]['question']["16"]['Grabbar']
                                                                      [
                                                                      'grabBarLength'] = value;
                                                                });
                                                                // assesmentprovider.setdata(
                                                                //     19, value, 'Grab Bar Length');
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
                                                SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            )
                                          : SizedBox(),
                                      assesmentprovider.getrecomain(
                                          assesmentprovider,
                                          16,
                                          true,
                                          'Comments (if any)',
                                          assessor,
                                          therapist,
                                          role,
                                          context)
                                    ],
                                  )
                                : SizedBox(),

                        SizedBox(
                          height: 15,
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Container(
                        //       width: MediaQuery.of(context).size.width * .6,
                        //       child: Text('Grab Bar Placement',
                        //           style: TextStyle(
                        //             color: Color.fromRGBO(10, 80, 106, 1),
                        //             fontSize: 20,
                        //           )),
                        //     ),
                        //     DropdownButton(
                        //       items: [
                        //         DropdownMenuItem(
                        //           child: Text('--'),
                        //           value: '',
                        //         ),
                        //         DropdownMenuItem(
                        //           child: Text('Left'),
                        //           value: 'left',
                        //         ),
                        //         DropdownMenuItem(
                        //           child: Text('Right'),
                        //           value: 'right',
                        //         ),
                        //         DropdownMenuItem(
                        //           child: Text('Both Sides'),
                        //           value: 'Both Sides',
                        //         ),
                        //       ],
                        //       onChanged: (value) {
                        //         if (assessor == therapist &&
                        //             role == "therapist") {
                        //           FocusScope.of(context).requestFocus();
                        //           new TextEditingController().clear();
                        //           // print(widget.accessname);
                        //           assesmentprovider.setdata(
                        //               17, value, 'Grab Bar Placement');
                        //         } else if (role != "therapist") {
                        //           FocusScope.of(context).requestFocus();
                        //           new TextEditingController().clear();
                        //           // print(widget.accessname);
                        //           assesmentprovider.setdata(
                        //               17, value, 'Grab Bar Placement');
                        //         } else {
                        //           _showSnackBar(
                        //               "You can't change the other fields",
                        //               context);
                        //         }
                        //       },
                        //       value: assesmentprovider.getvalue(17),
                        //     )
                        //   ],
                        // ),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        // (assesmentprovider.getvalue(17) != '')
                        //     ? Container(
                        //         child: Row(
                        //           mainAxisAlignment:
                        //               MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             Container(
                        //               width: MediaQuery.of(context).size.width *
                        //                   .4,
                        //               child: Text(
                        //                   'Grab bar is present in which side of the shower entrance?',
                        //                   style: TextStyle(
                        //                     color:
                        //                         Color.fromRGBO(10, 80, 106, 1),
                        //                     fontSize: 20,
                        //                   )),
                        //             ),
                        //             DropdownButton(
                        //               items: [
                        //                 DropdownMenuItem(
                        //                   child: Text('--'),
                        //                   value: '',
                        //                 ),
                        //                 DropdownMenuItem(
                        //                   child: Text('Facing the Shower'),
                        //                   value: 'Facing the Shower',
                        //                 ),
                        //                 DropdownMenuItem(
                        //                   child: Text('On the Back Wall'),
                        //                   value: 'On the Back Wall',
                        //                 ),
                        //               ],
                        //               onChanged: (value) {
                        //                 if (assessor == therapist &&
                        //                     role == "therapist") {
                        //                   FocusScope.of(context).requestFocus();
                        //                   new TextEditingController().clear();
                        //                   // print(widget.accessname);
                        //                   setState(() {
                        //                     widget.wholelist[5]
                        //                                 [widget.accessname]
                        //                             ['question']["17"]
                        //                         ['sidefentrance'] = value;
                        //                   });
                        //                 } else if (role != "therapist") {
                        //                   FocusScope.of(context).requestFocus();
                        //                   new TextEditingController().clear();
                        //                   // print(widget.accessname);
                        //                   setState(() {
                        //                     widget.wholelist[5]
                        //                                 [widget.accessname]
                        //                             ['question']["17"]
                        //                         ['sidefentrance'] = value;
                        //                   });
                        //                 } else {
                        //                   _showSnackBar(
                        //                       "You can't change the other fields",
                        //                       context);
                        //                 }
                        //               },
                        //               value: widget.wholelist[5]
                        //                       [widget.accessname]['question']
                        //                   ["17"]['sidefentrance'],
                        //             )
                        //           ],
                        //         ),
                        //       )
                        //     : SizedBox(),

                        // SizedBox(
                        //   height: 15,
                        // ),
                        // Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Container(
                        //         width: MediaQuery.of(context).size.width * .6,
                        //         child: Text('Grab Bar Distance From Floor',
                        //             style: TextStyle(
                        //               color: Color.fromRGBO(10, 80, 106, 1),
                        //               fontSize: 20,
                        //             )),
                        //       ),
                        //       SizedBox(
                        //         width: MediaQuery.of(context).size.width * .25,
                        //         child: TextFormField(
                        //           initialValue: assesmentprovider.getvalue(18),
                        //           decoration: InputDecoration(
                        //               focusedBorder: OutlineInputBorder(
                        //                 borderSide: BorderSide(
                        //                     color:
                        //                         Color.fromRGBO(10, 80, 106, 1),
                        //                     width: 1),
                        //               ),
                        //               enabledBorder: OutlineInputBorder(
                        //                 borderSide: BorderSide(width: 1),
                        //               ),
                        //               labelText: '(Inches)'),
                        //           keyboardType: TextInputType.phone,
                        //           onChanged: (value) {
                        //             if (assessor == therapist &&
                        //                 role == "therapist") {
                        //               FocusScope.of(context).requestFocus();
                        //               new TextEditingController().clear();
                        //               // print(widget.accessname);
                        //               assesmentprovider.setdata(18, value,
                        //                   'Grab Bar Distance From Floor');
                        //             } else if (role != "therapist") {
                        //               FocusScope.of(context).requestFocus();
                        //               new TextEditingController().clear();
                        //               // print(widget.accessname);
                        //               assesmentprovider.setdata(18, value,
                        //                   'Grab Bar Distance From Floor');
                        //             } else {
                        //               _showSnackBar(
                        //                   "You can't change the other fields",
                        //                   context);
                        //             }
                        //           },
                        //         ),
                        //       ),
                        //     ]),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        // (assesmentprovider.getvalue(18) != "")
                        //     ? (double.parse(assesmentprovider.getvalue(18)) >
                        //             120)
                        //         ? assesmentprovider.getrecomain(
                        //             assesmentprovider,
                        //             18,
                        //             true,
                        //             "Comments (if any)",
                        //             assessor,
                        //             therapist,
                        //             role,
                        //             context)
                        //         : SizedBox()
                        //     : SizedBox(),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        // Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Container(
                        //         width: MediaQuery.of(context).size.width * .4,
                        //         child: Text('Grab Bar Length',
                        //             style: TextStyle(
                        //               color: Color.fromRGBO(10, 80, 106, 1),
                        //               fontSize: 20,
                        //             )),
                        //       ),
                        //       SizedBox(
                        //         width: MediaQuery.of(context).size.width * .25,
                        //         child: TextFormField(
                        //           initialValue: assesmentprovider.getvalue(19),
                        //           decoration: InputDecoration(
                        //               focusedBorder: OutlineInputBorder(
                        //                 borderSide: BorderSide(
                        //                     color:
                        //                         Color.fromRGBO(10, 80, 106, 1),
                        //                     width: 1),
                        //               ),
                        //               enabledBorder: OutlineInputBorder(
                        //                 borderSide: BorderSide(width: 1),
                        //               ),
                        //               labelText: '(Inches)'),
                        //           keyboardType: TextInputType.phone,
                        //           onChanged: (value) {
                        //             if (assessor == therapist &&
                        //                 role == "therapist") {
                        //               FocusScope.of(context).requestFocus();
                        //               new TextEditingController().clear();
                        //               // print(widget.accessname);
                        //               assesmentprovider.setdata(
                        //                   19, value, 'Grab Bar Length');
                        //             } else if (role != "therapist") {
                        //               FocusScope.of(context).requestFocus();
                        //               new TextEditingController().clear();
                        //               // print(widget.accessname);
                        //               assesmentprovider.setdata(
                        //                   19, value, 'Grab Bar Length');
                        //             } else {
                        //               _showSnackBar(
                        //                   "You can't change the other fields",
                        //                   context);
                        //             }
                        //           },
                        //         ),
                        //       ),
                        //     ]),
                        // SizedBox(
                        //   height: 15,
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .6,
                              child: Text('Faucet/Control Placement',
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
                                  child: Text('Front'),
                                  value: 'Front',
                                ),
                                DropdownMenuItem(
                                  child: Text('Side'),
                                  value: 'Side',
                                ),
                                DropdownMenuItem(
                                  child: Text('Back'),
                                  value: 'Back',
                                ),
                              ],
                              onChanged: (value) {
                                if (assessor == therapist &&
                                    role == "therapist") {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  assesmentprovider.setdata(
                                      17, value, 'Faucet/Control: Placement');
                                } else if (role != "therapist") {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  assesmentprovider.setdata(
                                      17, value, 'Faucet/Control Placement');
                                } else {
                                  _showSnackBar(
                                      "You can't change the other fields",
                                      context);
                                }
                              },
                              value: assesmentprovider.getvalue(17),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .58,
                              child: Text('Hand-Held Shower Present?',
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
                            //           18, value, 'Hand-Held Shower Present?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       assesmentprovider.setdata(
                            //           18, value, 'Hand-Held Shower Present?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: assesmentprovider.getvalue(18),
                            // )
                            toggleButton(context, assesmentprovider, 18,
                                "Hand-Held Shower Present?"),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .45,
                              child: Text('Type of Wall',
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
                                  child: Text('Tile'),
                                  value: 'Tile',
                                ),
                                DropdownMenuItem(
                                  child: Text('Fiberglass'),
                                  value: 'Fiberglass',
                                ),
                                DropdownMenuItem(
                                  child: Text('Moulded'),
                                  value: 'Moulded',
                                ),
                                DropdownMenuItem(
                                  child: Text('Stucco'),
                                  value: 'Stucco',
                                ),
                                DropdownMenuItem(
                                  child: Text('Brick'),
                                  value: 'Brick',
                                ),
                                DropdownMenuItem(
                                  child: Text('Other'),
                                  value: 'Other',
                                ),
                              ],
                              onChanged: (value) {
                                if (assessor == therapist &&
                                    role == "therapist") {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  assesmentprovider.setdata(
                                      19, value, 'Type of Wall');
                                } else if (role != "therapist") {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  assesmentprovider.setdata(
                                      19, value, 'Type of Wall');
                                } else {
                                  _showSnackBar(
                                      "You can't change the other fields",
                                      context);
                                }
                              },
                              value: assesmentprovider.getvalue(19),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .58,
                              child: Text('Tub Present?',
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
                            //           20, value, 'Tub Present?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       assesmentprovider.setdata(
                            //           20, value, 'Tub Present?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: assesmentprovider.getvalue(20),
                            // )
                            toggleButton(
                                context, assesmentprovider, 20, 'Tub Present?'),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        (assesmentprovider.getvalue(20) != 'No')
                            ? Column(
                                children: [
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
                                              .58,
                                          child: Text(
                                              'Able to enter/exit the tub independently?',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    10, 80, 106, 1),
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
                                        //       FocusScope.of(context)
                                        //           .requestFocus();
                                        //       new TextEditingController()
                                        //           .clear();
                                        //       // print(widget.accessname);
                                        //       setState(() {
                                        //         widget.wholelist[5]
                                        //                     [widget.accessname]
                                        //                 ['question']["20"]
                                        //             ['ManageInOut'] = value;
                                        //       });
                                        //       // assesmentprovider.setdata(20, value,
                                        //       //     'Able to Enter/Exit the Tub Independently?');
                                        //     } else if (role != "therapist") {
                                        //       FocusScope.of(context)
                                        //           .requestFocus();
                                        //       new TextEditingController()
                                        //           .clear();
                                        //       // print(widget.accessname);
                                        //       setState(() {
                                        //         widget.wholelist[5]
                                        //                     [widget.accessname]
                                        //                 ['question']["20"]
                                        //             ['ManageInOut'] = value;
                                        //       });
                                        //       // assesmentprovider.setdata(20, value,
                                        //       //     'Able to Enter/Exit the Tub Independently?');
                                        //     } else {
                                        //       _showSnackBar(
                                        //           "You can't change the other fields",
                                        //           context);
                                        //     }
                                        //   },
                                        //   value: widget.wholelist[5]
                                        //           [widget.accessname]
                                        //       ['question']["20"]['ManageInOut'],
                                        // ),
                                        Container(
                                          height: 35,
                                          child: ToggleButtons(
                                            borderColor: Colors.black,
                                            fillColor: Colors.green,
                                            borderWidth: 0,
                                            selectedBorderColor: Colors.black,
                                            selectedColor: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Yes',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'No',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                            ],
                                            onPressed: (int select) {
                                              if (assessor == therapist &&
                                                  role == "therapist") {
                                                setState(() {
                                                  for (int i = 0;
                                                      i <
                                                          widget
                                                              .wholelist[5][
                                                                  widget
                                                                      .accessname]
                                                                  ['question']
                                                                  ["20"]
                                                                  ['toggle2']
                                                              .length;
                                                      i++) {
                                                    widget.wholelist[5][widget
                                                                    .accessname]
                                                                ['question']
                                                            ['20']['toggle2']
                                                        [i] = i == select;
                                                  }
                                                  widget.wholelist[5]
                                                                  [widget.accessname]
                                                              ['question']['20']
                                                          ['toggle2'][0]
                                                      ? widget.wholelist[5]
                                                                      [widget.accessname]
                                                                  ['question']["20"]
                                                              ['ManageInOut'] =
                                                          'Yes'
                                                      : widget.wholelist[5]
                                                                  [widget.accessname]
                                                              ['question']["20"]
                                                          ['ManageInOut'] = 'No';
                                                });
                                              } else if (role != "therapist") {
                                                setState(() {
                                                  for (int i = 0;
                                                      i <
                                                          widget
                                                              .wholelist[5][
                                                                  widget
                                                                      .accessname]
                                                                  ['question']
                                                                  ["20"]
                                                                  ['toggle2']
                                                              .length;
                                                      i++) {
                                                    widget.wholelist[5][widget
                                                                    .accessname]
                                                                ['question']
                                                            ['20']['toggle2']
                                                        [i] = i == select;
                                                  }
                                                  widget.wholelist[5]
                                                                  [widget.accessname]
                                                              ['question']['20']
                                                          ['toggle2'][0]
                                                      ? widget.wholelist[5]
                                                                      [widget.accessname]
                                                                  ['question']["20"]
                                                              ['ManageInOut'] =
                                                          'Yes'
                                                      : widget.wholelist[5]
                                                                  [widget.accessname]
                                                              ['question']["20"]
                                                          ['ManageInOut'] = 'No';
                                                });
                                              } else {
                                                _showSnackBar(
                                                    "You can't change the other fields",
                                                    context);
                                              }
                                            },
                                            isSelected: widget.wholelist[5]
                                                    [widget.accessname]
                                                    ['question']['20']
                                                    ['toggle2']
                                                .cast<bool>(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  ((widget.wholelist[5][widget.accessname]
                                                  ['question']["20"]
                                              ['ManageInOut'] ==
                                          'No'))
                                      ? assesmentprovider.getrecomain(
                                          assesmentprovider,
                                          20,
                                          true,
                                          'Comments (if any)',
                                          assessor,
                                          therapist,
                                          role,
                                          context)
                                      : SizedBox()
                                ],
                              )
                            : (assesmentprovider.getvalue(20) == 'No')
                                ? assesmentprovider.getrecomain(
                                    assesmentprovider,
                                    20,
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
                              child:
                                  Text('Able to access faucets Independently?',
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
                            //       assesmentprovider.setdata(21, value,
                            //           'Able to access faucets Independently?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       assesmentprovider.setdata(21, value,
                            //           'Able to access faucets Independently?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: assesmentprovider.getvalue(21),
                            // )
                            toggleButton(context, assesmentprovider, 21,
                                'Able to access faucets Independently?'),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        (assesmentprovider.getvalue(21) == 'No')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider,
                                21,
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
                                width: MediaQuery.of(context).size.width * .4,
                                child: Text('Commode Height',
                                    style: TextStyle(
                                      color: Color.fromRGBO(10, 80, 106, 1),
                                      fontSize: 20,
                                    )),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .25,
                                child: TextFormField(
                                  initialValue: assesmentprovider.getvalue(22),
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
                                          22, value, 'Commode Height');
                                    } else if (role != "therapist") {
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                      assesmentprovider.setdata(
                                          22, value, 'Commode Height');
                                    } else {
                                      _showSnackBar(
                                          "You can't change the other fields",
                                          context);
                                    }
                                  },
                                ),
                              ),
                            ]),

                        (assesmentprovider.getvalue(22) != "")
                            ? (double.parse(assesmentprovider.getvalue(22)) >
                                    20)
                                ? assesmentprovider.getrecomain(
                                    assesmentprovider,
                                    22,
                                    true,
                                    "Comments (if any)",
                                    assessor,
                                    therapist,
                                    role,
                                    context)
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
                              child:
                                  Text('Can get on/off commode independently?',
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
                            //       assesmentprovider.setdata(23, value,
                            //           'Can get on/off commode independently?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       assesmentprovider.setdata(23, value,
                            //           'Can get on/off commode independently?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: assesmentprovider.getvalue(23),
                            // )
                            toggleButton(context, assesmentprovider, 23,
                                'Can get on/off commode independently?'),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        (assesmentprovider.getvalue(23) == 'No')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider,
                                23,
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
                              child:
                                  Text('Able to flush Commode independently?',
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
                            //       assesmentprovider.setdata(24, value,
                            //           'Able to flush commode independently?');
                            //     } else if (role != "therapist") {
                            //       FocusScope.of(context).requestFocus();
                            //       new TextEditingController().clear();
                            //       // print(widget.accessname);
                            //       assesmentprovider.setdata(24, value,
                            //           'Able to flush commode independently?');
                            //     } else {
                            //       _showSnackBar(
                            //           "You can't change the other fields",
                            //           context);
                            //     }
                            //   },
                            //   value: assesmentprovider.getvalue(24),
                            // )
                            toggleButton(context, assesmentprovider, 24,
                                'Able to flush commode independently?'),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        (assesmentprovider.getvalue(24) == 'No')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider,
                                24,
                                true,
                                'Comments (if any)',
                                assessor,
                                therapist,
                                role,
                                context)
                            : SizedBox(),
                        SizedBox(height: 15),

///////////////////////////////////////////////////OBSERVATION////////////////////////////////////////////////
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

                        // Divider(
                        //   height: dividerheight,
                        //   color: Color.fromRGBO(10, 80, 106, 1),
                        // ),
                        SizedBox(height: 15),
                        // Container(
                        //     // height: 10000,
                        //     child: TextFormField(
                        //   initialValue: assesmentprovider.getvalue(25),
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
                        //           25, value, 'Observations');
                        //     } else if (role != "therapist") {
                        //       FocusScope.of(context).requestFocus();
                        //       new TextEditingController().clear();
                        //       // print(widget.accessname);
                        //       assesmentprovider.setdata(
                        //           25, value, 'Observations');
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
                                  showCursor: assesmentprovider.cur,
                                  controller:
                                      assesmentprovider.controllers["field25"],
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),

                                  onChanged: (value) {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    if (assessor == therapist &&
                                        role == "therapist") {
                                      assesmentprovider.setreco(25, value);
                                      assesmentprovider.setdata(
                                          25, value, 'Oberservations');
                                    } else if (role != "therapist") {
                                      assesmentprovider.setreco(25, value);
                                      assesmentprovider.setdata(
                                          25, value, 'Oberservations');
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
                                    assesmentprovider.isListening['field25'],
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
                                    heroTag: "btn25",
                                    child: Icon(
                                      Icons.mic,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      if (assessor == therapist &&
                                          role == "therapist") {
                                        assesmentprovider.listen(25);
                                        assesmentprovider.setdatalisten(25);
                                      } else if (role != "therapist") {
                                        assesmentprovider.listen(25);
                                        assesmentprovider.setdatalisten(25);
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
                              color: assesmentprovider.colorsset["field${25}"],
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
                    color: _colorgreen,
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onPressed: () {
                      listenbutton(assesmentprovider, context);
                      // NewAssesmentRepository()
                      //     .setLatestChangeDate(widget.docID);
                      // NewAssesmentRepository()
                      //     .setForm(widget.wholelist, widget.docID);
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

  void listenbutton(BathroomPro assesmentprovider, BuildContext buildContext) {
    var test = widget.wholelist[5][widget.accessname]['complete'];
    print(test);
    for (int i = 0;
        i < widget.wholelist[5][widget.accessname]['question'].length;
        i++) {
      assesmentprovider.setdatalisten(i + 1);
      assesmentprovider.setdatalistenthera(i + 1);
    }
    // if (test == 0) {
    //   _showSnackBar("You Must Have To Fill The Details First", buildContext);
    // } else {
    if (role == "therapist") {
      // if (assesmentprovider.saveToForm) {
      NewAssesmentRepository().setLatestChangeDate(widget.docID);
      NewAssesmentRepository().setForm(widget.wholelist, widget.docID);
      Navigator.pop(buildContext, widget.wholelist[5][widget.accessname]);
      // } else {
      //   _showSnackBar("Provide all recommendations", buildContext);
      // }
    } else {
      NewAssesmentRepository().setLatestChangeDate(widget.docID);
      NewAssesmentRepository().setForm(widget.wholelist, widget.docID);
      Navigator.pop(buildContext, widget.wholelist[5][widget.accessname]);
    }
    // }
  }

  // Widget getrecomain(
  //     assesmentprovider, int index, bool isthera, String fieldlabel) {
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
  //               showCursor: assesmentprovider.cur,
  //               controller: assesmentprovider.controllers["field$index"],
  //               decoration: InputDecoration(
  //                   focusedBorder: OutlineInputBorder(
  //                     borderSide: BorderSide(
  //                         color: assesmentprovider.colorsset["field$index"],
  //                         width: 1),
  //                   ),
  //                   enabledBorder: OutlineInputBorder(
  //                     borderSide: BorderSide(
  //                         width: 1,
  //                         color: assesmentprovider.colorsset["field$index"]),
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
  //                           animate:
  //                               assesmentprovider.isListening['field$index'],
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
  //                 assesmentprovider.setreco(index, value);
  //               },
  //             ),
  //           ),
  //           (assesmentprovider.type == 'Therapist' && isthera)
  //               ? getrecowid(assesmentprovider, index)
  //               : SizedBox(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget getrecowid(assesmentprovider, index) {
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
  //           assesmentprovider.setrecothera(index, value);
  //           print('hejdfdf');
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
  //                   assesmentprovider.setprio(index, value);
  //                 },
  //                 groupValue: assesmentprovider.getprio(index),
  //               ),
  //               Text('1'),
  //               Radio(
  //                 value: '2',
  //                 onChanged: (value) {
  //                   setState(() {
  //                     assesmentprovider.setprio(index, value);
  //                   });
  //                 },
  //                 groupValue: assesmentprovider.getprio(index),
  //               ),
  //               Text('2'),
  //               Radio(
  //                 value: '3',
  //                 onChanged: (value) {
  //                   setState(() {
  //                     assesmentprovider.setprio(index, value);
  //                   });
  //                 },
  //                 groupValue: assesmentprovider.getprio(index),
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
  //           _controllerstreco["field$index"].text = widget.wholelist[5]
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
  //     widget.wholelist[5][widget.accessname]['question'][index]
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
  //         // colorsset["field$index"] = Colors.red;
  //         isListening['field$index'] = true;
  //       });
  //       _speech.listen(
  //         onResult: (val) => setState(() {
  //           _controllers["field$index"].text = widget.wholelist[5]
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
  //     widget.wholelist[5][widget.accessname]['question'][index]
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
