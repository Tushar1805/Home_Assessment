import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  bool available = false;
  Map<String, Color> colorsset = {};
  Map<String, TextEditingController> _controllers = {};
  Map<String, bool> isListening = {};
  bool cur = true;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    for (int i = 0;
        i < widget.wholelist[2][widget.accessname]['question'].length;
        i++) {
      _controllers["field${i + 1}"] = TextEditingController();
      isListening["field${i + 1}"] = false;
      _controllers["field${i + 1}"].text = widget.wholelist[2]
          [widget.accessname]['question']["${i + 1}"]['Recommendation'];
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
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
                              width: MediaQuery.of(context).size.width * .67,
                              child: Text(
                                '${widget.roomname} Details:',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(10, 80, 106, 1),
                                ),
                              ),
                            ),
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
                                width: MediaQuery.of(context).size.width * .5,
                                child: Text('Threshold to Living Room',
                                    style: TextStyle(
                                      color: Color.fromRGBO(10, 80, 106, 1),
                                      fontSize: 20,
                                    )),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .3,
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
                                      FocusScope.of(context).requestFocus();
                                      new TextEditingController().clear();
                                      // print(widget.accessname);

                                      if (value.length == 0) {
                                        if (widget
                                                .wholelist[2][widget.accessname]
                                                    ['question']["1"]['Answer']
                                                .length ==
                                            0) {
                                        } else {
                                          setState(() {
                                            widget.wholelist[2]
                                                    [widget.accessname]
                                                ['complete'] -= 1;
                                            widget.wholelist[2]
                                                        [widget.accessname]
                                                    ['question']["1"]
                                                ['Answer'] = value;
                                          });
                                        }
                                      } else {
                                        if (widget
                                                .wholelist[2][widget.accessname]
                                                    ['question']["1"]['Answer']
                                                .length ==
                                            0) {
                                          setState(() {
                                            widget.wholelist[2]
                                                    [widget.accessname]
                                                ['complete'] += 1;
                                          });
                                        }
                                        setState(() {
                                          widget.wholelist[2][widget.accessname]
                                                  ['question']["1"]['Answer'] =
                                              value;
                                        });
                                      }
                                      // print(widget.wholelist[2]
                                      //         [widget.accessname]['question'][1]
                                      //     ['Answer']);
                                    }),
                              ),
                            ]),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
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
                                    child: Text('Ceramic Tiles'),
                                    value: 'Tile',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Hardwood'),
                                    value: 'Hardwood',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Laminate'),
                                    value: 'Laminate',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Carpet'),
                                    value: 'Carpet',
                                  ),
                                ],
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  if (value.length == 0) {
                                    if (widget
                                            .wholelist[2][widget.accessname]
                                                ['question']["2"]['Answer']
                                            .length ==
                                        0) {
                                    } else {
                                      setState(() {
                                        widget.wholelist[2][widget.accessname]
                                            ['complete'] -= 1;
                                        widget.wholelist[2][widget.accessname]
                                            ['question']["2"]['Answer'] = value;
                                      });
                                    }
                                  } else {
                                    if (widget
                                            .wholelist[2][widget.accessname]
                                                ['question']["2"]['Answer']
                                            .length ==
                                        0) {
                                      setState(() {
                                        widget.wholelist[2][widget.accessname]
                                            ['complete'] += 1;
                                      });
                                    }
                                    setState(() {
                                      widget.wholelist[2][widget.accessname]
                                          ['question']["2"]['Answer'] = value;
                                    });
                                  }
                                },
                                value: widget.wholelist[2][widget.accessname]
                                    ['question']["2"]['Answer'],
                              ),
                            )
                          ],
                        ),
                        (widget
                                    .wholelist[2][widget.accessname]['question']
                                        ["2"]['Answer']
                                    .length >
                                0)
                            ? TextFormField(
                                maxLines: null,
                                controller: _controllers["field${2}"],
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: colorsset["field${2}"],
                                          width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: colorsset["field${2}"]),
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
                                            animate: isListening['field${2}'],
                                            glowColor:
                                                Theme.of(context).primaryColor,
                                            endRadius: 300.0,
                                            duration: const Duration(
                                                milliseconds: 2000),
                                            repeatPauseDuration: const Duration(
                                                milliseconds: 100),
                                            repeat: true,
                                            child: FlatButton(
                                              child: Icon(
                                                  isListening['field${2}']
                                                      ? Icons.cancel
                                                      : Icons.mic),
                                              onPressed: () {
                                                _listen(2);
                                                setdatalisten(2);
                                              },
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                    labelText: 'Enter Comments (if any)'),
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);

                                  setState(() {
                                    widget.wholelist[2][widget.accessname]
                                            ['question']["2"]
                                        ['Recommendation'] = value;
                                  });
                                },
                              )
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
                                    child: Text('Ceramic Tiles'),
                                    value: 'Tile',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Hardwood'),
                                    value: 'Hardwood',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Laminate'),
                                    value: 'Laminate',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Carpet'),
                                    value: 'Carpet',
                                  ),
                                ],
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);

                                  if (value.length == 0) {
                                    if (widget
                                            .wholelist[2][widget.accessname]
                                                ['question']["3"]['Answer']
                                            .length ==
                                        0) {
                                    } else {
                                      setState(() {
                                        widget.wholelist[2][widget.accessname]
                                            ['complete'] -= 1;
                                        widget.wholelist[2][widget.accessname]
                                            ['question']["3"]['Answer'] = value;
                                      });
                                    }
                                  } else {
                                    if (widget
                                            .wholelist[2][widget.accessname]
                                                ['question']["3"]['Answer']
                                            .length ==
                                        0) {
                                      setState(() {
                                        widget.wholelist[2][widget.accessname]
                                            ['complete'] += 1;
                                      });
                                    }
                                    setState(() {
                                      widget.wholelist[2][widget.accessname]
                                          ['question']["3"]['Answer'] = value;
                                    });
                                  }
                                },
                                value: widget.wholelist[2][widget.accessname]
                                    ['question']['3']['Answer'],
                              ),
                            )
                          ],
                        ),
                        (widget
                                    .wholelist[2][widget.accessname]['question']
                                        ["3"]['Answer']
                                    .length >
                                0)
                            ? TextFormField(
                                maxLines: null,
                                controller: _controllers["field${3}"],
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: colorsset["field${3}"],
                                          width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: colorsset["field${3}"]),
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
                                            animate: isListening['field${3}'],
                                            glowColor:
                                                Theme.of(context).primaryColor,
                                            endRadius: 300.0,
                                            duration: const Duration(
                                                milliseconds: 2000),
                                            repeatPauseDuration: const Duration(
                                                milliseconds: 100),
                                            repeat: true,
                                            child: FlatButton(
                                              child: Icon(
                                                  isListening['field${3}']
                                                      ? Icons.cancel
                                                      : Icons.mic),
                                              onPressed: () {
                                                _listen(3);
                                                setdatalisten(3);
                                              },
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                    labelText: 'Specify Coverage (if any)'),
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);

                                  setState(() {
                                    widget.wholelist[2][widget.accessname]
                                            ['question']["3"]
                                        ['Recommendation'] = value;

                                    // print(assesmentprovider.listofRooms[2]);
                                    // print(
                                    //     widget.wholelist[2][widget.accessname]);
                                  });
                                },
                              )
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
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Lighting Types:',
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
                                    child: Text('Incandescent'),
                                    value: 'Bulb',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Halogen'),
                                    value: 'Halogen',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('LED'),
                                    value: 'LED',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('CFLs'),
                                    value: 'CFLs',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('WiFi Capable'),
                                    value: 'WiFi Capable',
                                  ),
                                ],
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);

                                  if (value.length == 0) {
                                    if (widget
                                            .wholelist[2][widget.accessname]
                                                ['question']["4"]['Answer']
                                            .length ==
                                        0) {
                                    } else {
                                      setState(() {
                                        widget.wholelist[2][widget.accessname]
                                            ['complete'] -= 1;
                                        widget.wholelist[2][widget.accessname]
                                            ['question']["4"]['Answer'] = value;
                                      });
                                    }
                                  } else {
                                    if (widget
                                            .wholelist[2][widget.accessname]
                                                ['question']["4"]['Answer']
                                            .length ==
                                        0) {
                                      setState(() {
                                        widget.wholelist[2][widget.accessname]
                                            ['complete'] += 1;
                                      });
                                    }
                                    setState(() {
                                      widget.wholelist[2][widget.accessname]
                                          ['question']['4']['Answer'] = value;
                                    });
                                  }
                                },
                                value: widget.wholelist[2][widget.accessname]
                                    ['question']["4"]['Answer'],
                              ),
                            )
                          ],
                        ),
                        (widget
                                    .wholelist[2][widget.accessname]['question']
                                        ["4"]['Answer']
                                    .length >
                                0)
                            ? TextFormField(
                                maxLines: null,
                                controller: _controllers["field${4}"],
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: colorsset["field${4}"],
                                          width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: colorsset["field${4}"]),
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
                                            animate: isListening['field${4}'],
                                            glowColor:
                                                Theme.of(context).primaryColor,
                                            endRadius: 300.0,
                                            duration: const Duration(
                                                milliseconds: 2000),
                                            repeatPauseDuration: const Duration(
                                                milliseconds: 100),
                                            repeat: true,
                                            child: FlatButton(
                                              child: Icon(
                                                  isListening['field${4}']
                                                      ? Icons.cancel
                                                      : Icons.mic),
                                              onPressed: () {
                                                _listen(4);
                                                setdatalisten(4);
                                              },
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                    labelText: 'Specify Lighting Type'),
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);

                                  setState(() {
                                    widget.wholelist[2][widget.accessname]
                                            ['question']["4"]
                                        ['Recommendation'] = value;
                                  });
                                },
                              )
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
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Switches: Client Able to Operate:',
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

                                  if (value.length == 0) {
                                    if (widget
                                            .wholelist[2][widget.accessname]
                                                ['question']["5"]['Answer']
                                            .length ==
                                        0) {
                                    } else {
                                      setState(() {
                                        widget.wholelist[2][widget.accessname]
                                            ['complete'] -= 1;
                                        widget.wholelist[2][widget.accessname]
                                            ['question']["5"]['Answer'] = value;
                                      });
                                    }
                                  } else {
                                    if (widget
                                            .wholelist[2][widget.accessname]
                                                ['question']["5"]['Answer']
                                            .length ==
                                        0) {
                                      setState(() {
                                        widget.wholelist[2][widget.accessname]
                                            ['complete'] += 1;
                                      });
                                    }
                                    setState(() {
                                      widget.wholelist[2][widget.accessname]
                                          ['question']["5"]['Answer'] = value;
                                    });
                                  }
                                },
                                value: widget.wholelist[2][widget.accessname]
                                    ['question']["5"]['Answer'],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Switch Types:',
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
                                    child: Text('Push Button'),
                                    value: 'pushbutton',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Rotary'),
                                    value: 'rotary',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Toggle'),
                                    value: 'toggle',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Slide'),
                                    value: 'slide',
                                  ),
                                ],
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);

                                  if (value.length == 0) {
                                    if (widget
                                            .wholelist[2][widget.accessname]
                                                ['question']["6"]['Answer']
                                            .length ==
                                        0) {
                                    } else {
                                      setState(() {
                                        widget.wholelist[2][widget.accessname]
                                            ['complete'] -= 1;
                                        widget.wholelist[2][widget.accessname]
                                            ['question']["6"]['Answer'] = value;
                                      });
                                    }
                                  } else {
                                    if (widget
                                            .wholelist[2][widget.accessname]
                                                ['question']["6"]['Answer']
                                            .length ==
                                        0) {
                                      setState(() {
                                        widget.wholelist[2][widget.accessname]
                                            ['complete'] += 1;
                                      });
                                    }
                                    setState(() {
                                      widget.wholelist[2][widget.accessname]
                                          ['question']["6"]['Answer'] = value;
                                    });
                                  }
                                },
                                value: widget.wholelist[2][widget.accessname]
                                    ['question']["6"]['Answer'],
                              ),
                            ),
                          ],
                        ),
                        (widget
                                    .wholelist[2][widget.accessname]['question']
                                        ["6"]['Answer']
                                    .length >
                                0)
                            ? TextFormField(
                                maxLines: null,
                                controller: _controllers["field${6}"],
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: colorsset["field${6}"],
                                          width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: colorsset["field${6}"]),
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
                                            animate: isListening['field${6}'],
                                            glowColor:
                                                Theme.of(context).primaryColor,
                                            endRadius: 300.0,
                                            duration: const Duration(
                                                milliseconds: 2000),
                                            repeatPauseDuration: const Duration(
                                                milliseconds: 100),
                                            repeat: true,
                                            child: FlatButton(
                                              child: Icon(
                                                  isListening['field${6}']
                                                      ? Icons.cancel
                                                      : Icons.mic),
                                              onPressed: () {
                                                _listen(6);
                                                setdatalisten(6);
                                              },
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                    labelText: 'Specify Switch Type.'),
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);

                                  setState(() {
                                    widget.wholelist[2][widget.accessname]
                                            ['question']["6"]
                                        ['Recommendation'] = value;
                                  });
                                },
                              )
                            : SizedBox(),
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
                                  initialValue: widget.wholelist[2]
                                          [widget.accessname]['question']["7"]
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
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);

                                    if (value.length == 0) {
                                      if (widget
                                              .wholelist[2][widget.accessname]
                                                  ['question']["7"]['Answer']
                                              .length ==
                                          0) {
                                      } else {
                                        setState(() {
                                          widget.wholelist[7][widget.accessname]
                                              ['complete'] -= 1;
                                          widget.wholelist[2][widget.accessname]
                                                  ['question']["7"]['Answer'] =
                                              value;
                                        });
                                      }
                                    } else {
                                      if (widget
                                              .wholelist[2][widget.accessname]
                                                  ['question']['7']['Answer']
                                              .length ==
                                          0) {
                                        setState(() {
                                          widget.wholelist[2][widget.accessname]
                                              ['complete'] += 1;
                                        });
                                      }
                                      setState(() {
                                        widget.wholelist[2][widget.accessname]
                                            ['question']["7"]['Answer'] = value;
                                      });
                                    }
                                    // print(widget.wholelist[8]
                                    //         [widget.accessname]['question'][7]
                                    //     ['Answer']);
                                  }),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        (true)
                            ? TextFormField(
                                maxLines: null,
                                controller: _controllers["field${7}"],
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: colorsset["field${7}"],
                                          width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: colorsset["field${7}"]),
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
                                            animate: isListening['field${7}'],
                                            glowColor:
                                                Theme.of(context).primaryColor,
                                            endRadius: 300.0,
                                            duration: const Duration(
                                                milliseconds: 2000),
                                            repeatPauseDuration: const Duration(
                                                milliseconds: 100),
                                            repeat: true,
                                            child: FlatButton(
                                              child: Icon(
                                                  isListening['field${7}']
                                                      ? Icons.cancel
                                                      : Icons.mic),
                                              onPressed: () {
                                                _listen(7);
                                                setdatalisten(7);
                                              },
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                    labelText: 'Enter Comments (if any)'),
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);

                                  setState(() {
                                    widget.wholelist[2][widget.accessname]
                                            ['question']["7"]
                                        ['Recommendation'] = value;
                                  });
                                },
                              )
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
                              width: MediaQuery.of(context).size.width * .5,
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

                                if (value.length == 0) {
                                  if (widget
                                          .wholelist[2][widget.accessname]
                                              ['question']["8"]['Answer']
                                          .length ==
                                      0) {
                                  } else {
                                    setState(() {
                                      widget.wholelist[2][widget.accessname]
                                          ['complete'] -= 1;
                                      widget.wholelist[2][widget.accessname]
                                          ['question']["8"]['Answer'] = value;
                                    });
                                  }
                                } else {
                                  if (widget
                                          .wholelist[2][widget.accessname]
                                              ['question']["8"]['Answer']
                                          .length ==
                                      0) {
                                    setState(() {
                                      widget.wholelist[2][widget.accessname]
                                          ['complete'] += 1;
                                    });
                                  }
                                  setState(() {
                                    widget.wholelist[2][widget.accessname]
                                        ['question']["8"]['Answer'] = value;
                                  });
                                }
                              },
                              value: widget.wholelist[2][widget.accessname]
                                  ['question']["8"]['Answer'],
                            )
                          ],
                        ),
                        (widget.wholelist[2][widget.accessname]['question']["8"]
                                    ['Answer'] ==
                                'Yes')
                            ? TextFormField(
                                maxLines: null,
                                controller: _controllers["field${8}"],
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: colorsset["field${8}"],
                                          width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: colorsset["field${8}"]),
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
                                            animate: isListening['field${8}'],
                                            glowColor:
                                                Theme.of(context).primaryColor,
                                            endRadius: 300.0,
                                            duration: const Duration(
                                                milliseconds: 2000),
                                            repeatPauseDuration: const Duration(
                                                milliseconds: 100),
                                            repeat: true,
                                            child: FlatButton(
                                              child: Icon(
                                                  isListening['field${8}']
                                                      ? Icons.cancel
                                                      : Icons.mic),
                                              onPressed: () {
                                                _listen(8);
                                                setdatalisten(8);
                                              },
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                    labelText: 'Specify clutter'),
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);

                                  setState(() {
                                    widget.wholelist[2][widget.accessname]
                                            ['question']["8"]
                                        ['Recommendation'] = value;
                                  });
                                },
                              )
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Client is Able to Access Telephone?',
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

                                if (value.length == 0) {
                                  if (widget
                                          .wholelist[2][widget.accessname]
                                              ['question']["9"]['Answer']
                                          .length ==
                                      0) {
                                  } else {
                                    setState(() {
                                      widget.wholelist[2][widget.accessname]
                                          ['complete'] -= 1;
                                      widget.wholelist[2][widget.accessname]
                                          ['question']["9"]['Answer'] = value;
                                    });
                                  }
                                } else {
                                  if (widget
                                          .wholelist[2][widget.accessname]
                                              ['question']["9"]['Answer']
                                          .length ==
                                      0) {
                                    setState(() {
                                      widget.wholelist[2][widget.accessname]
                                          ['complete'] += 1;
                                    });
                                  }
                                  setState(() {
                                    widget.wholelist[2][widget.accessname]
                                        ['question']["9"]['Answer'] = value;
                                  });
                                }
                              },
                              value: widget.wholelist[2][widget.accessname]
                                  ['question']["9"]['Answer'],
                            )
                          ],
                        ),
                        (widget.wholelist[2][widget.accessname]['question']["9"]
                                    ['Answer'] ==
                                'Yes')
                            ? TextFormField(
                                maxLines: null,
                                controller: _controllers["field${9}"],
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: colorsset["field${9}"],
                                          width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: colorsset["field${9}"]),
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
                                            animate: isListening['field${9}'],
                                            glowColor:
                                                Theme.of(context).primaryColor,
                                            endRadius: 300.0,
                                            duration: const Duration(
                                                milliseconds: 2000),
                                            repeatPauseDuration: const Duration(
                                                milliseconds: 100),
                                            repeat: true,
                                            child: FlatButton(
                                              child: Icon(
                                                  isListening['field${9}']
                                                      ? Icons.cancel
                                                      : Icons.mic),
                                              onPressed: () {
                                                _listen(9);
                                                setdatalisten(9);
                                              },
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                    labelText: 'Specify Phone Type'),
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);

                                  setState(() {
                                    widget.wholelist[2][widget.accessname]
                                            ['question']["9"]
                                        ['Recommendation'] = value;
                                  });
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
                                FocusScope.of(context).requestFocus();
                                new TextEditingController().clear();
                                // print(widget.accessname);

                                if (value.length == 0) {
                                  if (widget
                                          .wholelist[2][widget.accessname]
                                              ['question']["10"]['Answer']
                                          .length ==
                                      0) {
                                  } else {
                                    setState(() {
                                      widget.wholelist[2][widget.accessname]
                                          ['complete'] -= 1;
                                      widget.wholelist[2][widget.accessname]
                                          ['question']["10"]['Answer'] = value;
                                    });
                                  }
                                } else {
                                  if (widget
                                          .wholelist[2][widget.accessname]
                                              ['question']['10']['Answer']
                                          .length ==
                                      0) {
                                    setState(() {
                                      widget.wholelist[2][widget.accessname]
                                          ['complete'] += 1;
                                    });
                                  }
                                  setState(() {
                                    widget.wholelist[2][widget.accessname]
                                        ['question']["10"]['Answer'] = value;
                                  });
                                }
                              },
                              value: widget.wholelist[2][widget.accessname]
                                  ['question']["10"]['Answer'],
                            )
                          ],
                        ),
                        (widget.wholelist[2][widget.accessname]['question']
                                    ["10"]['Answer'] ==
                                'Yes')
                            ? TextFormField(
                                maxLines: null,
                                controller: _controllers["field${10}"],
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: colorsset["field${10}"],
                                          width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: colorsset["field${10}"]),
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
                                            glowColor:
                                                Theme.of(context).primaryColor,
                                            endRadius: 300.0,
                                            duration: const Duration(
                                                milliseconds: 2000),
                                            repeatPauseDuration: const Duration(
                                                milliseconds: 100),
                                            repeat: true,
                                            child: FlatButton(
                                              child: Icon(
                                                  isListening['field${10}']
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
                                    labelText: 'Enter Comments (if any)'),
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);

                                  setState(() {
                                    widget.wholelist[2][widget.accessname]
                                            ['question']["10"]
                                        ['Recommendation'] = value;
                                  });
                                },
                              )
                            : SizedBox(),

                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Text('Observations:',
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
                            FocusScope.of(context).requestFocus();
                            new TextEditingController().clear();
                            // print(widget.accessname);

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
                    child: Text('Done'),
                    onPressed: () {
                      var test = 0;
                      for (int i = 0;
                          i <
                              widget.wholelist[2][widget.accessname]['question']
                                  .length;
                          i++) {
                        // print(colorsset["field${i + 1}"]);
                        if (colorsset["field${i + 1}"] == Colors.red) {
                          showDialog(
                              context: context,
                              builder: (context) => CustomDialog(
                                  title: "Not Saved",
                                  description:
                                      "Please click cancel button to save the field"));
                          test = 1;
                        }
                      }
                      if (test == 0) {
                        Navigator.pop(
                            context, widget.wholelist[2][widget.accessname]);
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
