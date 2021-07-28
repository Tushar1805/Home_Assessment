import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:tryapp/Assesment/Forms/Pathway/pathwaypro.dart';
import 'package:provider/provider.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentrepo.dart';
import 'package:tryapp/constants.dart';

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
  bool available = false;
  int threeshold = 0;
  Map<String, Color> colorsset = {};
  Map<String, TextEditingController> _controllers = {};
  Map<String, TextEditingController> _controllerstreco = {};
  final firestoreInstance = Firestore.instance;
  Map<String, bool> isListening = {};
  bool cur = true;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  var _textfield = TextEditingController();
  String role, assessor, curUid, therapist;
  int sizes = 30;
  int stepsizes = 0;
  int stepcount = 0;
  bool isColor = false;
  var test = TextEditingController();
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
      _controllerstreco["field${i + 1}"] = TextEditingController();
      isListening["field${i + 1}"] = false;
      _controllers["field${i + 1}"].text = widget.wholelist[0]
          [widget.accessname]['question']["${i + 1}"]['Recommendation'];
      _controllerstreco["field${i + 1}"].text =
          '${widget.wholelist[0][widget.accessname]['question']["${i + 1}"]['Recommendationthera']}';
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
    getRole();
    getAssessData();
    setinitials();
  }

  /// This fucntion helps us to create such fields which will be needed to fill extra
  /// data sunch as fields generated dynamically.
  setinitials() {
    if (widget.wholelist[0][widget.accessname]['question']["8"]
        .containsKey('Railling')) {
    } else {
      widget.wholelist[0][widget.accessname]['question']["8"]['Railling'] = {
        'OneSided': {},
      };
    }
    if (widget.wholelist[0][widget.accessname]['question']["7"]
        .containsKey('MultipleStair')) {
      if (widget.wholelist[0][widget.accessname]['question']["7"]
              ['MultipleStair']
          .containsKey('count')) {
        setState(() {
          stepcount = widget.wholelist[0][widget.accessname]['question']["7"]
              ['MultipleStair']['count'];
        });
      }
    } else {
      widget.wholelist[0][widget.accessname]['question']["7"]
          ['MultipleStair'] = {};
    }
    print(widget.wholelist[0][widget.accessname]['question']["7"]
        ['MultipleStair']);
  }

  /// This fucntion will help us to get role of the logged in user
  Future<String> getRole() async {
    final FirebaseUser useruid = await _auth.currentUser();
    firestoreInstance.collection("users").document(useruid.uid).get().then(
      (value) {
        setState(() {
          role = (value["role"]);
        });
      },
    );
  }

  Future<void> getAssessData() async {
    final FirebaseUser user = await _auth.currentUser();
    firestoreInstance
        .collection("assessments")
        .document(widget.docID)
        .get()
        .then((value) => setState(() {
              curUid = user.uid;
              assessor = value.data["assessor"];
              therapist = value.data["therapist"];
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

// This function is used to control and camera button
//
//  Note: Image picker do not work with speech_to_text.
  Future getImage(bool isCamera) async {
    // File image;
    // if (isCamera) {
    //   // ignore: deprecated_member_use
    //   image = await ImagePicker.pickImage(source: ImageSource.camera);
    // } else {
    //   // ignore: deprecated_member_use
    //   image = await ImagePicker.pickImage(source: ImageSource.gallery);
    // }
    // setState(() {
    //   _image = image;
    // });
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

// UI
  @override
  Widget build(BuildContext context) {
    final pathwaypro = Provider.of<PathwayPro>(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Assesment'),
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
                                width: MediaQuery.of(context).size.width / 1.6,
                                child: Text(
                                  '${widget.roomname}Details',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(10, 80, 106, 1),
                                  ),
                                )),
                            Container(
                              alignment: Alignment.topRight,
                              width: 50,
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
                                  getImage(true);
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
                                FocusScope.of(context).requestFocus();
                                new TextEditingController().clear();
                                // print(widget.accessname);
                                if (assessor == therapist &&
                                    role == "therapist") {
                                  setdata(
                                      1, value, 'Obstacle/Clutter Present?');
                                } else if (role != "therapist") {
                                  setdata(
                                      1, value, 'Obstacle/Clutter Present?');
                                } else {
                                  _showSnackBar(
                                      "You can't change the other fields",
                                      context);
                                }
                              },
                              value: getvalue(1),
                            )
                          ],
                        ),
                        (getvalue(1) == 'Yes') ? getrecomain(1) : SizedBox(),
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
                              child: Text('Ocasionally Uses',
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
                                    setdata(3, value, 'Ocasionally Uses');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    setdata(3, value, 'Ocasionally Uses');
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
                                if (role != "therapist") {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  setdata(4, value, 'Entrance Has Lights?');
                                } else if (assessor == therapist &&
                                    role == "therapist") {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  setdata(4, value, 'Entrance Has Lights?');
                                } else {
                                  _showSnackBar(
                                      "You can't change the other fields",
                                      context);
                                }
                              },
                              value: getvalue(4),
                            )
                          ],
                        ),
                        (getvalue(4) == 'No') ? getrecomain(4) : SizedBox(),
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
                            ? (int.parse(getvalue(5)) < 30 &&
                                    int.parse(getvalue(5)) > 0)
                                ? getrecomain(5)
                                : SizedBox()
                            : SizedBox(),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Smoke Detector?',
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
                                  setdata(6, value, 'Smoke Detector?');
                                } else if (role != "therapist") {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  setdata(6, value, 'Smoke Detector?');
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
                        (getvalue(6) == 'No') ? getrecomain(6) : SizedBox(),

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
                                                      initialValue: widget.wholelist[
                                                                      0]
                                                                  [
                                                                  widget
                                                                      .accessname]
                                                              [
                                                              'question']["7"]
                                                          ['Recommendation'],
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
                                                          setState(() {
                                                            widget.wholelist[0][
                                                                        widget
                                                                            .accessname]
                                                                    [
                                                                    'question']["7"]
                                                                [
                                                                'Recommendation'] = value;
                                                          });
                                                        } else if (role !=
                                                            "therapist") {
                                                          setState(() {
                                                            widget.wholelist[0][
                                                                        widget
                                                                            .accessname]
                                                                    [
                                                                    'question']["7"]
                                                                [
                                                                'Recommendation'] = value;
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
                                          Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 10, 0, 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .4,
                                                    child: TextFormField(
                                                      initialValue: widget
                                                                      .wholelist[0]
                                                                  [
                                                                  widget
                                                                      .accessname]
                                                              ['question']["7"]
                                                          ['Single Step Width'],
                                                      keyboardType:
                                                          TextInputType.phone,
                                                      decoration:
                                                          InputDecoration(
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: colorsset[
                                                                        "field${7}"],
                                                                    width: 1),
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
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
                                                            widget.wholelist[0][
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
                                                            widget.wholelist[0][
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
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .4,
                                                    child: TextFormField(
                                                      initialValue: widget
                                                                      .wholelist[0]
                                                                  [
                                                                  widget
                                                                      .accessname]
                                                              ['question']["7"][
                                                          'Single Step Height'],
                                                      keyboardType:
                                                          TextInputType.phone,
                                                      decoration:
                                                          InputDecoration(
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: colorsset[
                                                                        "field${7}"],
                                                                    width: 1),
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
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
                                                            widget.wholelist[0][
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
                                                            widget.wholelist[0][
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
                                                              'Recommendationthera'] = value;

                                                          stepcount = widget
                                                                          .wholelist[0]
                                                                      [
                                                                      widget
                                                                          .accessname]
                                                                  [
                                                                  'question']["7"]
                                                              [
                                                              'Recommendationthera'];
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
                                                              'Recommendationthera'] = value;

                                                          stepcount = widget
                                                                          .wholelist[0]
                                                                      [
                                                                      widget
                                                                          .accessname]
                                                                  [
                                                                  'question']["7"]
                                                              [
                                                              'Recommendationthera'];
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
                                                              index1 + 1);
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
                              child: Text('Railling',
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
                            ? getrecomain(8)
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
                                          ? getrecowid(8)
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
                            ? (int.parse(getvalue(9)) > 5)
                                ? (role == 'therapist')
                                    ? getrecowid(9)
                                    : SizedBox()
                                : SizedBox()
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
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
                                  child: Text('Fairy Well'),
                                  value: 'Fairy Well',
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
                        (getvalue(10) != 'Fairy Well' && getvalue(10) != '')
                            ? getrecomain(10)
                            : SizedBox(),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
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
                                  child: Text('Fairy Well'),
                                  value: 'Fairy Well',
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
                        (getvalue(11) != 'Fairy Well' && getvalue(11) != '')
                            ? getrecomain(11)
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
                        Container(
                            // height: 10000,
                            child: TextFormField(
                          initialValue: widget.wholelist[0][widget.accessname]
                              ["question"]["12"]["Answer"],
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
                            // suffix: Icon(Icons.mic),
                          ),
                          onChanged: (value) {
                            if (assessor == therapist && role == "therapist") {
                              FocusScope.of(context).requestFocus();
                              new TextEditingController().clear();
                              // print(widget.accessname);
                              setreco(12, value);
                              setdata(12, value, 'Oberservations');
                            } else if (role != "therapist") {
                              FocusScope.of(context).requestFocus();
                              new TextEditingController().clear();
                              // print(widget.accessname);
                              setreco(12, value);
                              setdata(12, value, 'Oberservations');
                            } else {
                              _showSnackBar(
                                  "You can't change the other fields", context);
                            }
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

  /// this fucntion helps us to listent to hte done button at the bottom
  void listenbutton(BuildContext buildContext) {
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
    if (test == 0) {
      _showSnackBar("You Must Have to Fill The Details First", buildContext);
    } else {
      NewAssesmentRepository().setLatestChangeDate(widget.docID);
      NewAssesmentRepository().setForm(widget.wholelist, widget.docID);
      Navigator.pop(context, widget.wholelist[0][widget.accessname]);
    }
  }

  /// This fucntion is to take care of speeck to text mic button and place the text in
  /// the particular field.
  void _listen(index) async {
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
        setState(() {
          // _isListening = true;
          colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
          isListening['field$index'] = true;
        });
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
        );
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
      // isListening['field$index'] = false;
      colorsset["field$index"] = Color.fromRGBO(10, 80, 106, 1);
    });
    _speech.stop();
  }

  /// This function is a helper function of the listen fucntion.
  setdatalisten(index) {
    setState(() {
      widget.wholelist[0][widget.accessname]['question']["$index"]
          ['Recommendation'] = _controllers["field$index"].text;
      cur = !cur;
    });
  }

  /// This is a widget function which returns is the recommendation fields and the
  /// priority field.
  Widget getrecomain(int index) {
    return SingleChildScrollView(
      // reverse: true,
      child: Container(
        // color: Colors.yellow,
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
                    _showSnackBar("You can't change the other fields", context);
                  }
                },
              ),
            ),
            (role == 'therapist') ? getrecowid(index) : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget getrecowid(index) {
    if (widget.wholelist[0][widget.accessname]["question"]["$index"]
            ["Recommendationthera"] !=
        "") {
      isColor = true;
    } else {
      isColor = false;
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
              suffix: Icon(Icons.mic),
              labelStyle:
                  TextStyle(color: (isColor) ? Colors.green : Colors.red),
              labelText: 'Recomendation'),
          onChanged: (value) {
            FocusScope.of(context).requestFocus();
            new TextEditingController().clear();
            // print(widget.accessname);
            setrecothera(index, value);
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

  /// This function is specific for the pathwayui. this is used to generate the
  /// steps field based on dynamic and multiple stairs to store data of each stair
  Widget stepcountswid(index) {
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
                        labelText: 'Step Width$index:'),
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
                        labelText: 'Step Height$index:'),
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
