import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:tryapp/Assesment/newassesment/newassesmentrepo.dart';
import 'package:tryapp/constants.dart';

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
  bool cur = true;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  Firestore firestoreInstance = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String assessor, curUid, therapist, role;
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
    getAssessData();
    getRole();
    setinitials();
  }

  Future<void> setinitials() async {
    if (widget.wholelist[2][widget.accessname]['question']["7"]
        .containsKey('doorwidth')) {
    } else {
      widget.wholelist[2][widget.accessname]['question']["7"]['doorwidth'] = 0;
    }
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

  Future<String> getRole() async {
    final FirebaseUser useruid = await _auth.currentUser();
    firestoreInstance.collection("users").document(useruid.uid).get().then(
      (value) {
        setState(() {
          role = (value["role"].toString()).split(" ")[0];
        });
      },
    );
  }

  setdata(index, value, que) {
    widget.wholelist[2][widget.accessname]['question']["$index"]['Question'] =
        que;
    if (value.length == 0) {
      if (widget.wholelist[2][widget.accessname]['question']["$index"]['Answer']
              .length ==
          0) {
      } else {
        setState(() {
          widget.wholelist[2][widget.accessname]['complete'] -= 1;
          widget.wholelist[2][widget.accessname]['question']["$index"]
              ['Answer'] = value;
        });
      }
    } else {
      if (widget.wholelist[2][widget.accessname]['question']["$index"]['Answer']
              .length ==
          0) {
        setState(() {
          widget.wholelist[2][widget.accessname]['complete'] += 1;
        });
      }
      setState(() {
        widget.wholelist[2][widget.accessname]['question']["$index"]['Answer'] =
            value;
      });
    }
  }

  setreco(index, value) {
    setState(() {
      widget.wholelist[2][widget.accessname]['question']["$index"]
          ['Recommendation'] = value;
    });
  }

  getvalue(index) {
    return widget.wholelist[2][widget.accessname]['question']["$index"]
        ['Answer'];
  }

  getreco(index) {
    return widget.wholelist[2][widget.accessname]['question']["$index"]
        ['Recommendation'];
  }

  setrecothera(index, value) {
    setState(() {
      widget.wholelist[2][widget.accessname]['question']["$index"]
          ['Recommendationthera'] = value;
    });
  }

  setprio(index, value) {
    setState(() {
      widget.wholelist[2][widget.accessname]['question']["$index"]['Priority'] =
          value;
    });
  }

  getprio(index) {
    return widget.wholelist[2][widget.accessname]['question']["$index"]
        ['Priority'];
  }

  getrecothera(index) {
    return widget.wholelist[2][widget.accessname]['question']["$index"]
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
                  if (test == 0) {
                    _showSnackBar(
                        "You Must Have to Fill The Details First", context);
                  } else {
                    NewAssesmentRepository().setLatestChangeDate(widget.docID);
                    NewAssesmentRepository()
                        .setForm(widget.wholelist, widget.docID);
                    Navigator.pop(
                        context, widget.wholelist[2][widget.accessname]);
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
                                onPressed: () {},
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
                                        FocusScope.of(context).requestFocus();
                                        new TextEditingController().clear();
                                        // print(widget.accessname);
                                        setdata(1, value,
                                            'Threshold to Living Room');
                                      } else if (role != "therapist") {
                                        FocusScope.of(context).requestFocus();
                                        new TextEditingController().clear();
                                        // print(widget.accessname);
                                        setdata(1, value,
                                            'Threshold to Living Room');
                                      } else {
                                        _showSnackBar(
                                            "You can't change the other fields",
                                            context);
                                      }
                                    }),
                              ),
                            ]),
                        SizedBox(height: 10),
                        (getvalue(1) != "")
                            ? (int.parse(getvalue(1)) > 5)
                                ? getrecomain(1, true, "Comments (if any)")
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
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                      setdata(2, value, 'Flooring Type');
                                    } else if (role != "therapist") {
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                      setdata(2, value, 'Flooring Type');
                                    } else {
                                      _showSnackBar(
                                          "You can't change the other fields",
                                          context);
                                    }
                                  },
                                  value: getvalue(2)),
                            )
                          ],
                        ),
                        (getvalue(2) == 'Wood - Smooth Finish' ||
                                getvalue(2) == 'Tile - Smooth Finish')
                            ? getrecomain(2, true, "Comments (if any)")
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
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    setdata(3, value, 'Floor Coverage');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    setdata(3, value, 'Floor Coverage');
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
                        (getvalue(3) != 'No covering' && getvalue(3) != '')
                            ? getrecomain(3, true, 'Comments (if any)')
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Lighting Types',
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
                                      setdata(4, value, 'Lighting Types');
                                    } else if (role != "therapist") {
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                      setdata(4, value, 'Lighting Types');
                                    } else {
                                      _showSnackBar(
                                          "You can't change the other fields",
                                          context);
                                    }
                                  },
                                  value: getvalue(4)),
                            )
                          ],
                        ),
                        (getvalue(4) == 'Inadequate')
                            ? getrecomain(4, true, 'Specify Type')
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
                              child: Text('Switches Able to Operate',
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
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                      setdata(
                                          5, value, 'Switches Able to Operate');
                                    } else if (role != "therapist") {
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                      setdata(
                                          5, value, 'Switches Able to Operate');
                                    } else {
                                      _showSnackBar(
                                          "You can't change the other fields",
                                          context);
                                    }
                                  },
                                  value: getvalue(5)),
                            ),
                          ],
                        ),
                        (getvalue(5) == 'No' && getvalue(5) != '')
                            ? getrecomain(5, true, 'Comments(if any)')
                            : SizedBox(),

                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Switch Types',
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
                                      child: Text('Mutlti Location'),
                                      value: 'Mutlti Location',
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
                                      setdata(6, value, 'Switch Types');
                                    } else if (role != "therapist") {
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                      setdata(6, value, 'Switch Types');
                                    } else {
                                      _showSnackBar(
                                          "You can't change the other fields",
                                          context);
                                    }
                                  },
                                  value: getvalue(6)),
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
                                  initialValue: getvalue(7),
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
                                      setdata(7, value, 'Door Width');
                                      setState(() {
                                        widget.wholelist[2][widget.accessname]
                                            ['question']["7"]['doorwidth'] = 0;

                                        widget.wholelist[2][widget.accessname]
                                                ['question']["7"]['doorwidth'] =
                                            int.parse(value);
                                      });
                                    } else if (role != "therapist") {
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);
                                      setdata(7, value, 'Door Width');
                                      widget.wholelist[2][widget.accessname]
                                          ['question']["7"]['doorwidth'] = 0;

                                      widget.wholelist[2][widget.accessname]
                                              ['question']["7"]['doorwidth'] =
                                          int.parse(value);
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
                        (widget.wholelist[2][widget.accessname]['question']["7"]
                                        ['doorwidth'] <
                                    30 &&
                                widget.wholelist[2][widget.accessname]
                                        ['question']["7"]['doorwidth'] >
                                    0 &&
                                widget.wholelist[2][widget.accessname]
                                        ['question']["7"]['doorwidth'] !=
                                    '')
                            ? getrecomain(7, true, 'Comments (if any)')
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
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  setdata(
                                      8, value, 'Obstacle/Clutter Present?');
                                } else if (role != "therapist") {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  setdata(
                                      8, value, 'Obstacle/Clutter Present?');
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
                        (getvalue(8) == 'Yes')
                            ? getrecomain(8, true, 'Specify Clutter')
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
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    setdata(
                                        9, value, 'Able to Access Telephone?');
                                  } else if (role != "therapist") {
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    setdata(
                                        9, value, 'Able to Access Telephone?');
                                  } else {
                                    _showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                },
                                value: getvalue(9))
                          ],
                        ),
                        (getvalue(9) != 'Yes' && getvalue(9) != '')
                            ? getrecomain(
                                9,
                                true,
                                'Comments (if any)',
                              )
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
                                            _showSnackBar(
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
                                  } else if (role != "therapist") {
                                  } else {
                                    _showSnackBar(
                                        "You can't change the other fields",
                                        context);
                                  }
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  setdata(10, value, 'Smoke Detector?');
                                },
                                value: getvalue(10))
                          ],
                        ),
                        (getvalue(10) == 'No')
                            ? getrecomain(10, true, 'Comments (if any)')
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
                            suffix: Icon(Icons.mic),
                          ),
                          onChanged: (value) {
                            if (assessor == therapist && role == "therapist") {
                            } else if (role != "therapist") {
                            } else {
                              _showSnackBar(
                                  "You can't change the other fields", context);
                            }
                            FocusScope.of(context).requestFocus();
                            new TextEditingController().clear();
                            // print(widget.accessname);
                            widget.wholelist[2][widget.accessname]['question']
                                ["11"]['Question'] = 'Observations';

                            if (value.length == 0) {
                              if (widget
                                      .wholelist[2][widget.accessname]
                                          ['question']['11']['Answer']
                                      .length ==
                                  0) {
                              } else {
                                setState(() {
                                  widget.wholelist[2][widget.accessname]
                                      ['complete'] -= 1;
                                  widget.wholelist[2][widget.accessname]
                                      ['question']["11"]['Answer'] = value;
                                });
                              }
                            } else {
                              if (widget
                                      .wholelist[2][widget.accessname]
                                          ['question']["11"]['Answer']
                                      .length ==
                                  0) {
                                setState(() {
                                  widget.wholelist[2][widget.accessname]
                                      ['complete'] += 1;
                                });
                              }
                              setState(() {
                                widget.wholelist[2][widget.accessname]
                                    ['question']["11"]['Answer'] = value;
                              });
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
                      if (test == 0) {
                        _showSnackBar(
                            "You Must Have to Fill The Details First", context);
                      } else {
                        NewAssesmentRepository()
                            .setLatestChangeDate(widget.docID);
                        NewAssesmentRepository()
                            .setForm(widget.wholelist, widget.docID);
                        Navigator.pop(
                            context, widget.wholelist[0][widget.accessname]);
                      }
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

  Widget getrecomain(int index, bool isthera, String fieldlabel) {
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
            (role == 'therapist' && isthera) ? getrecowid(index) : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget getrecowid(index) {
    if (widget.wholelist[2][widget.accessname]["question"]["$index"]
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
          colorsset["field$index"] = Colors.red;
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
