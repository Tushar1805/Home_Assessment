import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentrepo.dart';

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
  final firestoreInstance = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, TextEditingController> _controllers = {};
  Map<String, TextEditingController> _controllerstreco = {};
  Map<String, bool> isListening = {};
  bool cur = true;
  int roomatecount = 0;
  int flightcount = 0;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  String role;
  @override
  void initState() {
    super.initState();
    print('helo');
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
    setinitialsdata();
    print(role);
  }

  Future<Null> selectTime1(BuildContext context) async {
    picked1 = await showTimePicker(context: context, initialTime: time1);

    if (picked1 != null) {
      setState(() {
        time1 = picked1;
        widget.wholelist[1][widget.accessname]['question']["4"]['Alone']
            ['From'] = time1;
      });
    }
  }

  Future<Null> selectTime2(BuildContext context) async {
    picked2 = await showTimePicker(context: context, initialTime: time2);

    if (picked2 != null) {
      setState(() {
        time2 = picked2;
        widget.wholelist[1][widget.accessname]['question']["4"]['Alone']
            ['Till'] = time2;
      });
    }
  }

  Future<void> setinitialsdata() async {
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

    if (widget.wholelist[1][widget.accessname]['question']["4"]
        .containsKey('Alone')) {
      setState(() {
        if (widget.wholelist[1][widget.accessname]['question']["4"]['Alone']
            .containsKey('From')) {
          time1 = widget.wholelist[1][widget.accessname]['question']["4"]
              ['Alone']['From'];
        }
        if (widget.wholelist[1][widget.accessname]['question']["4"]['Alone']
            .containsKey('Till')) {
          time2 = widget.wholelist[1][widget.accessname]['question']["4"]
              ['Alone']['Till'];
        }
      });
    } else {
      setState(() {
        widget.wholelist[1][widget.accessname]['question']["4"]['Alone'] = {};
      });
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

    if (widget.wholelist[1][widget.accessname]['question']["11"]
        .containsKey('Flights')) {
      setState(() {
        flightcount = widget.wholelist[1][widget.accessname]['question']["11"]
            ['Flights']["count"];
      });
    } else {
      // print('hello');
      setState(() {
        widget.wholelist[1][widget.accessname]['question']["11"]
            ['Flights'] = {};
      });
    }
  }

  getRole() async {
    FirebaseUser user = await _auth.currentUser();
    await Firestore.instance
        .collection("users")
        .document(user.uid)
        .get()
        .then((value) => setState(() {
              role = value["role"];
            }));
  }

  setdata(index, value, que) {
    widget.wholelist[1][widget.accessname]['question']["$index"]['Question'] =
        que;
    if (value.length == 0) {
      if (widget.wholelist[1][widget.accessname]['question']["$index"]['Answer']
              .length ==
          0) {
      } else {
        setState(() {
          widget.wholelist[1][widget.accessname]['complete'] -= 1;
          widget.wholelist[1][widget.accessname]['question']["$index"]
              ['Answer'] = value;
        });
      }
    } else {
      if (widget.wholelist[1][widget.accessname]['question']["$index"]['Answer']
              .length ==
          0) {
        setState(() {
          widget.wholelist[1][widget.accessname]['complete'] += 1;
        });
      }
      setState(() {
        widget.wholelist[1][widget.accessname]['question']["$index"]['Answer'] =
            value;
        widget.wholelist[1][widget.accessname]['question']["$index"]
            ['Question'] = que;
      });
    }
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
    setState(() {
      widget.wholelist[1][widget.accessname]['question']["$index"]
          ['Recommendationthera'] = value;
    });
  }

  getrecothera(index) {
    return widget.wholelist[1][widget.accessname]['question']["$index"]
        ['Recommendationthera'];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Assesment'),
          automaticallyImplyLeading: false,
          backgroundColor: _colorgreen,
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
                                  setdata(1, value, 'House Type');
                                },
                                value: getvalue(1),
                              ),
                            )
                          ],
                        ),
                        (getvalue(1) == "Other")
                            ? getrecomain(1, false)
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
                                  setdata(2, value, 'Number of Levels');
                                },
                                value: getvalue(2),
                              ),
                            )
                          ],
                        ),
                        (getvalue(2) != '' &&
                                getvalue(2) != '0' &&
                                getvalue(2) != '1')
                            ? Container(
                                padding: EdgeInsets.all(5),
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
                                            child:
                                                Text('Mode Of Transportation',
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
                                                widget.wholelist[1]
                                                            [widget.accessname]
                                                        ['question']["2"]
                                                    ['Modetrnas'] = value;
                                              });
                                            },
                                            value: widget.wholelist[1]
                                                    [widget.accessname]
                                                ['question']["2"]['Modetrnas'],
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    (widget.wholelist[1][widget.accessname]
                                                    ['question']["2"]
                                                ['Modetrnas'] ==
                                            'Other')
                                        ? getrecomain(2, false)
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
                                  DropdownMenuItem(
                                      child: Text('--'), value: ''),
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
                                  setdata(3, value, 'Living on Level');
                                },
                                value: getvalue(3),
                              ),
                            )
                          ],
                        ),
                        (getvalue(3) == 'Other')
                            ? getrecomain(3, false)
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
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
                                  setdata(4, value, 'Living Arrangements');
                                },
                                value: getvalue(4),
                              ),
                            )
                          ],
                        ),
                        (getvalue(4) != 'Never Alone' && getvalue(4) != '')
                            ? (getvalue(4) == 'Alone')
                                ? getrecomain(4, true)
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
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              3, 0, 0, 0),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          4)),
                                                          shape: BoxShape
                                                              .rectangle,
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
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              3, 0, 0, 0),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          4)),
                                                          shape: BoxShape
                                                              .rectangle,
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
                              child: Text('Has Roomate?',
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

                                setdata(5, value, 'Has Roomate?');
                              },
                              value: getvalue(5),
                            )
                          ],
                        ),
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
                                              child: Text('Number Of Roomate:',
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
                                                counterval: roomatecount,
                                                onChanged: (value) {
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
                                                          ['roomate$value'] = {
                                                        'Relationship': '',
                                                        'FirstName': '',
                                                        'LastName': '',
                                                      };

                                                      if (widget.wholelist[1][
                                                              widget.accessname]
                                                              ['question']["5"]
                                                              ['Roomate']
                                                          .containsKey(
                                                              'roomate${value + 1}')) {
                                                        widget.wholelist[1][
                                                                widget
                                                                    .accessname]
                                                                ['question']
                                                                ["5"]['Roomate']
                                                            .remove(
                                                                'roomate${value + 1}');
                                                      }
                                                    } else if (value == 0) {
                                                      if (widget.wholelist[1][
                                                              widget.accessname]
                                                              ['question']["5"]
                                                              ['Roomate']
                                                          .containsKey(
                                                              'roomate${value + 1}')) {
                                                        widget.wholelist[1][
                                                                widget
                                                                    .accessname]
                                                                ['question']
                                                                ["5"]['Roomate']
                                                            .remove(
                                                                'roomate${value + 1}');
                                                      }
                                                    }
                                                  });

                                                  // print(widget.wholelist[1][
                                                  //             widget.accessname]
                                                  //         ['question']["5"]
                                                  //     ['Roomate']);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      (roomatecount > 0)
                                          ? Container(
                                              child: Padding(
                                                padding: EdgeInsets.all(10),
                                                child: ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                      maxHeight: 10000,
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
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text(
                                  'Able to Get In and Out of Doors and Steps?',
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
                                FocusScope.of(context).requestFocus();
                                new TextEditingController().clear();
                                // print(widget.accessname);

                                setdata(6, value,
                                    'Able to Get In and Out of Doors and Steps?');
                              },
                              value: getvalue(6),
                            )
                          ],
                        ),
                        (getvalue(6) != 'Fairy Well' && getvalue(6) != '')
                            ? getrecomain(6, true)
                            : SizedBox(),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Using Assistive Device?',
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

                                setdata(7, value, 'Using Assistive Device?');
                              },
                              value: getvalue(7),
                            )
                          ],
                        ),
                        (getvalue(7) == 'Yes')
                            ? Container(
                                padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          .35,
                                      child: Text('Assistive Device?',
                                          style: TextStyle(
                                            color:
                                                Color.fromRGBO(10, 80, 106, 1),
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
                                          child: Text('4 Whl. Whalker'),
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

                                        setrecothera(7, value);
                                      },
                                      value: getrecothera(7),
                                    )
                                  ],
                                ),
                              )
                            : SizedBox(),
                        SizedBox(
                          height: 15,
                        ),
                        //
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: Text('Gait Pattern Noted',
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

                                  setdata(8, value, 'Gait Pattern Noted');
                                },
                                value: getvalue(8),
                              ),
                            ),
                          ],
                        ),
                        (getvalue(8) != 'Normal')
                            ? getrecomain(8, true)
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .3,
                              child: Text('Access to Curbside',
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
                                    child: Text('Never goes to the curbside'),
                                    value: 'Never goes to the curbside',
                                  ),
                                  DropdownMenuItem(
                                    child:
                                        Text('Sometimes goes to the curbside'),
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

                                  setdata(9, value, 'Access to Curbside');
                                },
                                value: getvalue(9),
                              ),
                            )
                          ],
                        ),
                        (getvalue(9) != 'Never goes to the curbside' &&
                                getvalue(9) != 'Other' &&
                                getvalue(9) != '')
                            ? getrecomain(9, true)
                            : SizedBox(),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Access to Curbside Specify',
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
                                    duration:
                                        const Duration(milliseconds: 2000),
                                    repeatPauseDuration:
                                        const Duration(milliseconds: 100),
                                    repeat: true,
                                    child: FlatButton(
                                      child: Icon(isListening['field${10}']
                                          ? Icons.cancel
                                          : Icons.mic),
                                      onPressed: () {
                                        _listen(10);
                                        setdatalisten(10);
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

                            setdata(10, value, 'Access to Curbside Specify');
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
                                  width: MediaQuery.of(context).size.width * .5,
                                  child: Text('Number of Flight of Stairs',
                                      style: TextStyle(
                                        color: Color.fromRGBO(10, 80, 106, 1),
                                        fontSize: 20,
                                      )),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .35,
                                  child: NumericStepButton(
                                    counterval: flightcount,
                                    onChanged: (value) {
                                      setState(() {
                                        widget.wholelist[1][widget.accessname]
                                                ['question']["11"]['Question'] =
                                            'Number of Flight of Stairs';
                                        widget.wholelist[1][widget.accessname]
                                                ['question']["11"]['Flights'] =
                                            value;
                                        flightcount = widget.wholelist[1]
                                                [widget.accessname]['question']
                                            ["11"]['Flights'];
                                        print(widget.wholelist[1]
                                                [widget.accessname]['question']
                                            ["11"]['Flights']["count"]);
                                        if (value > 0) {
                                          widget.wholelist[1][widget.accessname]
                                                  ['question']["11"]
                                              ['Flights'] = "";

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

                                      print(widget.wholelist[1]
                                              [widget.accessname]['question']
                                          ["11"]['Flights']);
                                    },
                                  ),
                                ),
                              ]),
                        ),
                        (flightcount ?? 0 > 0)
                            ? Container(
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxHeight: 10000,
                                        minHeight:
                                            MediaQuery.of(context).size.height /
                                                10),
                                    child: ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: flightcount,
                                      itemBuilder: (context, index1) {
                                        return flightcountwidget((index1 + 1));
                                      },
                                    ),
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
                              child: Text(
                                  'Smoke Detector Batteries Checked Annualy/Replaced?',
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

                                setdata(12, value,
                                    'Smoke Detector Batteries Checked Annualy/Replaced?');
                              },
                              value: getvalue(12),
                            )
                          ],
                        ),
                        (getvalue(12) == 'No')
                            ? getrecomain(12, true)
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text(
                                  'Person Responsible to Change Smoke Detector batteries',
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
                              suffix: Icon(Icons.mic),
                              labelText: 'Specify Name'),
                          onChanged: (value) {
                            FocusScope.of(context).requestFocus();
                            new TextEditingController().clear();
                            // print(widget.accessname);
                            setdata(13, value,
                                'Person Responsible to Change Smoke Detector batteries');
                          },
                        )),
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
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                            // height: 10000,
                            child: TextFormField(
                          initialValue: getvalue(14),
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
                            FocusScope.of(context).requestFocus();
                            new TextEditingController().clear();
                            // print(widget.accessname);
                            setdata(14, value, 'Observations');
                          },
                        )),
                      ],
                    ),
                  ),
                  Container(
                      child: RaisedButton(
                    child: Text('Done'),
                    onPressed: () {
                      var test = 0;
                      for (int i = 0;
                          i <
                              widget.wholelist[1][widget.accessname]['question']
                                  .length;
                          i++) {
                        setdatalisten(i + 1);
                        setdatalistenthera(i + 1);
                      }
                      if (test == 0) {
                        Navigator.pop(
                            context, widget.wholelist[1][widget.accessname]);
                      }
                      NewAssesmentRepository()
                          .setLatestChangeDate(widget.docID);
                      NewAssesmentRepository()
                          .setForm(widget.wholelist, widget.docID);
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

  Widget getrecomain(int index, bool isthera) {
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
                                _listen(index);
                                setdatalisten(index);
                              },
                            ),
                          ),
                        ),
                      ]),
                    ),
                    labelText: 'Comments'),
                onChanged: (value) {
                  FocusScope.of(context).requestFocus();
                  new TextEditingController().clear();
                  // print(widget.accessname);
                  setreco(index, value);
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
    return Column(
      children: [
        SizedBox(height: 8),
        TextFormField(
          controller: _controllerstreco["field$index"],
          decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromRGBO(10, 80, 106, 1), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1),
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
          //colorsset["field$index"] = Colors.red;
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

  Widget flightcountwidget(index) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            child: Container(
              width: MediaQuery.of(context).size.width * .35,
              child: TextFormField(
                initialValue: widget.wholelist[1][widget.accessname]['question']
                    ["11"]['Flights']['flight$index'],
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
                  setState(() {
                    widget.wholelist[1][widget.accessname]['question']["11"]
                        ['Flights']['flight$index'] = value;
                  });
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

  Widget roomatecountwidget(index) {
    return Container(
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * .3,
                  child: Text('Relationship:',
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
                      setState(() {
                        widget.wholelist[1][widget.accessname]['question']["5"]
                                ['Roomate']['roomate$index']['Relationship'] =
                            value;
                      });
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
                          widget.wholelist[1][widget.accessname]['question']
                                  ["5"]['Roomate']['roomate$index']
                              ['FirstName'] = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
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
                          widget.wholelist[1][widget.accessname]['question']
                                  ["5"]['Roomate']['roomate$index']
                              ['LastName'] = value;
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
