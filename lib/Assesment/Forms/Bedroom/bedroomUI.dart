import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Bedroom/bedroompro.dart';

final _colorgreen = Color.fromRGBO(10, 80, 106, 1);

class BedroomUI extends StatefulWidget {
  String roomname, docID;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  BedroomUI(this.roomname, this.wholelist, this.accessname, this.docID);
  @override
  _BedroomUIState createState() => _BedroomUIState();
}

class _BedroomUIState extends State<BedroomUI> {
  final firestoreInstance = Firestore.instance;
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
  String type;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  var _textfield = TextEditingController();
  var test = TextEditingController();
  @override
  void initState() {
    super.initState();
    // _speech = stt.SpeechToText();
    // for (int i = 0;
    //     i < widget.wholelist[6][widget.accessname]['question'].length;
    //     i++) {
    //   _controllers["field${i + 1}"] = TextEditingController();
    //   _controllerstreco["field${i + 1}"] = TextEditingController();
    //   isListening["field${i + 1}"] = false;
    //   _controllers["field${i + 1}"].text = widget.wholelist[6]
    //       [widget.accessname]['question'][i + 1]['Recommendation'];
    //   _controllerstreco["field${i + 1}"].text =
    //       '${widget.wholelist[6][widget.accessname]['question'][i + 1]['Recommendationthera']}';
    //   colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    // }
    // getRole();
    // setinitials();
  }

  // Future<void> setinitials() async {
  //   if (widget.wholelist[6][widget.accessname]['question'][7]
  //       .containsKey('doorwidth')) {
  //   } else {
  //     print('getting created');
  //     widget.wholelist[6][widget.accessname]['question'][7]['doorwidth'] = 0;
  //   }
  // }

  // Future<String> getRole() async {
  //   final FirebaseUser useruid = await _auth.currentUser();
  //   firestoreInstance.collection("users").document(useruid.uid).get().then(
  //     (value) {
  //       setState(() {
  //         type = (value["role"].toString()).split(" ")[0];
  //       });
  //     },
  //   );
  // }

  // setdata(index, value) {
  //   if (value.length == 0) {
  //     if (widget.wholelist[6][widget.accessname]['question'][index]['Answer']
  //             .length ==
  //         0) {
  //     } else {
  //       setState(() {
  //         widget.wholelist[6][widget.accessname]['complete'] -= 1;
  //         widget.wholelist[6][widget.accessname]['question'][index]['Answer'] =
  //             value;
  //       });
  //     }
  //   } else {
  //     if (widget.wholelist[6][widget.accessname]['question'][index]['Answer']
  //             .length ==
  //         0) {
  //       setState(() {
  //         widget.wholelist[6][widget.accessname]['complete'] += 1;
  //       });
  //     }
  //     setState(() {
  //       widget.wholelist[6][widget.accessname]['question'][index]['Answer'] =
  //           value;
  //     });
  //   }
  // }

  // setreco(index, value) {
  //   setState(() {
  //     widget.wholelist[6][widget.accessname]['question'][index]
  //         ['Recommendation'] = value;
  //   });
  // }

  // assesmentprovider.getvalue(index) {
  //   return widget.wholelist[6][widget.accessname]['question'][index]['Answer'];
  // }

  // getreco(index) {
  //   return widget.wholelist[6][widget.accessname]['question'][index]
  //       ['Recommendation'];
  // }

  // setrecothera(index, value) {
  //   setState(() {
  //     widget.wholelist[6][widget.accessname]['question'][index]
  //         ['Recommendationthera'] = value;
  //   });
  // }

  // setprio(index, value) {
  //   setState(() {
  //     widget.wholelist[6][widget.accessname]['question'][index]['Priority'] =
  //         value;
  //   });
  // }

  // getprio(index) {
  //   return widget.wholelist[6][widget.accessname]['question'][index]
  //       ['Priority'];
  // }

  // getrecothera(index) {
  //   return widget.wholelist[6][widget.accessname]['question'][index]
  //       ['Recommendationthera'];
  // }

  @override
  Widget build(BuildContext context) {
    final assesmentprovider = Provider.of<BedroomPro>(context);
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
                            Text(
                              '${widget.roomname} Details:',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(10, 80, 106, 1),
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
                                width: MediaQuery.of(context).size.width * .4,
                                child: Text('Threshold to Bedroom',
                                    style: TextStyle(
                                      color: Color.fromRGBO(10, 80, 106, 1),
                                      fontSize: 20,
                                    )),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .3,
                                child: TextFormField(
                                  initialValue: widget.wholelist[6]
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
                                    FocusScope.of(context).requestFocus();
                                    new TextEditingController().clear();
                                    // print(widget.accessname);
                                    assesmentprovider.setdata(1, value);
                                  },
                                ),
                              ),
                            ]),
                        (assesmentprovider.getvalue(1) != '0' &&
                                assesmentprovider.getvalue(1) != '')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider, 1, true, 'Comments (if any)')
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
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  assesmentprovider.setdata(2, value);
                                },
                                value: assesmentprovider.getvalue(2),
                              ),
                            )
                          ],
                        ),
                        (assesmentprovider.getvalue(2).length > 0)
                            ? assesmentprovider.getrecomain(
                                assesmentprovider, 2, true, 'Comments (if any)')
                            : SizedBox(),
                        SizedBox(height: 15),
                        // Divider(
                        //   height: dividerheight,
                        //   color: Color.fromRGBO(10, 60, 106, 1),
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
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  assesmentprovider.setdata(3, value);
                                },
                                value: assesmentprovider.getvalue(3),
                              ),
                            )
                          ],
                        ),
                        (assesmentprovider.getvalue(3) != 'No covering' &&
                                assesmentprovider.getvalue(3) != '')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider, 3, true, 'Comments (if any)')
                            : SizedBox(),
                        SizedBox(height: 15),
                        // Divider(
                        //   height: dividerheight,
                        //   color: Color.fromRGBO(10, 60, 106, 1),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: Text('Lighting:',
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
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  assesmentprovider.setdata(4, value);
                                },
                                value: assesmentprovider.getvalue(4),
                              ),
                            )
                          ],
                        ),
                        (assesmentprovider.getvalue(4).length > 0)
                            ? assesmentprovider.getrecomain(
                                assesmentprovider, 4, true, 'Specify Type')
                            : SizedBox(),
                        SizedBox(height: 15),
                        // Divider(
                        //   height: dividerheight,
                        //   color: Color.fromRGBO(10, 60, 106, 1),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
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
                                  assesmentprovider.setdata(5, value);
                                },
                                value: assesmentprovider.getvalue(5),
                              ),
                            ),
                          ],
                        ),
                        (assesmentprovider.getvalue(5) != 'No' &&
                                assesmentprovider.getvalue(5) != '')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider, 5, true, 'Comments(if any)')
                            : SizedBox(),
                        SizedBox(height: 15),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
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
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  assesmentprovider.setdata(6, value);
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
                                width: MediaQuery.of(context).size.width * .3,
                                child: TextFormField(
                                  initialValue: widget.wholelist[6]
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
                                    assesmentprovider.setdata(7, value);
                                    setState(() {
                                      widget.wholelist[6][widget.accessname]
                                          ['question']["7"]['doorwidth'] = 0;

                                      widget.wholelist[6][widget.accessname]
                                              ['question']["7"]['doorwidth'] =
                                          int.parse(value);
                                    });
                                  },
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        (widget.wholelist[6][widget.accessname]['question']["7"]
                                        ['doorwidth'] <
                                    30 &&
                                widget.wholelist[6][widget.accessname]
                                        ['question']["7"]['doorwidth'] >
                                    0 &&
                                widget.wholelist[6][widget.accessname]
                                        ['question']["7"]['doorwidth'] !=
                                    '')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider, 7, true, 'Comments (if any)')
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
                              width: MediaQuery.of(context).size.width * .4,
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
                                assesmentprovider.setdata(8, value);
                              },
                              value: assesmentprovider.getvalue(8),
                            )
                          ],
                        ),
                        (assesmentprovider.getvalue(8) == 'Yes')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider, 8, true, 'Specify Clutter')
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
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
                                assesmentprovider.setdata(9, value);
                              },
                              value: assesmentprovider.getvalue(9),
                            )
                          ],
                        ),
                        (assesmentprovider.getvalue(9) == 'No' &&
                                assesmentprovider.getvalue(10) != '')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider, 9, true, 'Comments (if any)')
                            : SizedBox(),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
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

                                assesmentprovider.setdata(10, value);
                              },
                              value: assesmentprovider.getvalue(10),
                            )
                          ],
                        ),
                        (assesmentprovider.getvalue(10) == 'No')
                            ? assesmentprovider.getrecomain(assesmentprovider,
                                10, true, 'Comments (if any)')
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: Text('Type of Bed:',
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
                                    child: Text('Wood'),
                                    value: 'Wood',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Metal'),
                                    value: 'Metal',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Ajustable'),
                                    value: 'Ajustable',
                                  ),
                                ],
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  assesmentprovider.setdata(11, value);
                                },
                                value: assesmentprovider.getvalue(11),
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
                              child: Text('Size of Bed:',
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
                                    child: Text('Twin'),
                                    value: 'Twin',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Double'),
                                    value: 'Double',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Queen'),
                                    value: 'Queen',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('King'),
                                    value: 'King',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Two Twins Joined'),
                                    value: 'Two Twins Joined',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Two Twins Joined'),
                                    value: 'Two Twins Joined',
                                  ),
                                ],
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus();
                                  new TextEditingController().clear();
                                  // print(widget.accessname);
                                  assesmentprovider.setdata(12, value);
                                },
                                value: assesmentprovider.getvalue(12),
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
                              child: Text(
                                  'Client is Able to Get In and Out of The Door?',
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

                                assesmentprovider.setdata(13, value);
                              },
                              value: assesmentprovider.getvalue(13),
                            )
                          ],
                        ),
                        (assesmentprovider.getvalue(13) == 'No')
                            ? assesmentprovider.getrecomain(assesmentprovider,
                                13, true, 'Comments (if any)')
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: Text(
                                  'Client is Able to Access The Night Stand?',
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

                                assesmentprovider.setdata(14, value);
                              },
                              value: assesmentprovider.getvalue(14),
                            )
                          ],
                        ),
                        (assesmentprovider.getvalue(14) == 'No')
                            ? assesmentprovider.getrecomain(assesmentprovider,
                                14, true, 'Comments (if any)')
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: Text(
                                  'Client is Able to Access the Dresser Drawer?',
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
                                assesmentprovider.setdata(15, value);
                              },
                              value: assesmentprovider.getvalue(15),
                            )
                          ],
                        ),
                        (assesmentprovider.getvalue(15) == 'No')
                            ? assesmentprovider.getrecomain(assesmentprovider,
                                15, true, 'Comments (if any)')
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: Text(
                                  'Client is Able to Access Closet/Clothes:',
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

                                assesmentprovider.setdata(16, value);
                              },
                              value: assesmentprovider.getvalue(16),
                            )
                          ],
                        ),
                        SizedBox(height: 5),
                        (assesmentprovider.getvalue(16) == 'No')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider, 16, true, 'Specify: Type')
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: Text(
                                  'Client is Able to Get In and Out of Bed?',
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

                                assesmentprovider.setdata(17, value);
                              },
                              value: assesmentprovider.getvalue(17),
                            )
                          ],
                        ),
                        SizedBox(height: 5),
                        (assesmentprovider.getvalue(17) == 'No')
                            ? assesmentprovider.getrecomain(
                                assesmentprovider, 17, true, 'Specify: Type')
                            : SizedBox(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .4,
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
                          initialValue: widget.wholelist[6][widget.accessname]
                              ['question']["18"]['Answer'],
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
                            FocusScope.of(context).requestFocus();
                            new TextEditingController().clear();
                            // print(widget.accessname);

                            if (value.length == 0) {
                              if (widget
                                      .wholelist[6][widget.accessname]
                                          ['question']["18"]['Answer']
                                      .length ==
                                  0) {
                              } else {
                                setState(() {
                                  widget.wholelist[6][widget.accessname]
                                      ['complete'] -= 1;
                                  widget.wholelist[6][widget.accessname]
                                      ['question']["18"]['Answer'] = value;
                                });
                              }
                            } else {
                              if (widget
                                      .wholelist[6][widget.accessname]
                                          ['question']["18"]['Answer']
                                      .length ==
                                  0) {
                                setState(() {
                                  widget.wholelist[6][widget.accessname]
                                      ['complete'] += 1;
                                });
                              }
                              setState(() {
                                widget.wholelist[6][widget.accessname]
                                    ['question']["18"]['Answer'] = value;
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
                              widget.wholelist[6][widget.accessname]['question']
                                  .length;
                          i++) {
                        assesmentprovider.setdatalisten(i + 1);
                        assesmentprovider.setdatalistenthera(i + 1);
                      }
                      if (test == 0) {
                        Navigator.pop(
                            context, widget.wholelist[6][widget.accessname]);
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

  // Widget assesmentprovider.getrecomain(assesmentprovider,assesmentprovider,int index, bool isthera, String fieldlabel) {
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

  //                         child: FloatingActionButton(
  //                           heroTag: "btn$index",
  //                           child: Icon(
  //                             Icons.mic,
  //                             size: 20,
  //                           ),
  //                           onPressed: () {
  //                             _listen(index);
  //                             setdatalisten(index);
  //                           },
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
  //           _controllerstreco["field$index"].text = widget.wholelist[6]
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
  //     widget.wholelist[6][widget.accessname]['question'][index]
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
  //           _controllers["field$index"].text = widget.wholelist[6]
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
  //     widget.wholelist[6][widget.accessname]['question'][index]
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
