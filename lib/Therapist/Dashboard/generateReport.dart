import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentpro.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tryapp/Assesment/newassesment/newassesmentrepo.dart';
import 'package:tryapp/Nurse_Case_Manager/Dashboard/nursedash.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/patientdash.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/pdfReview.dart';
import 'package:tryapp/Therapist/Dashboard/therapistdash.dart';

class ReportTheraUI extends StatefulWidget {
  List<Map<String, dynamic>> assess = [];
  String patientUID, therapistUID, docID;
  ReportTheraUI(this.assess, this.patientUID, this.therapistUID, this.docID);
  @override
  _ReportTheraUIState createState() => _ReportTheraUIState();
}

class _ReportTheraUIState extends State<ReportTheraUI> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final firestoreInstance = FirebaseFirestore.instance;
  User curuser;
  var name, address, email, age, phone, height, weight, roomName, role;
  bool _isContainerVisible = true;
  String uid, patient, therapist;
  TimeOfDay startingTime, closingTime;

  final pdf = pw.Document();

  @override
  void initState() {
    super.initState();
    getUserName();
    print(widget.assess);
    getRole();
  }

  getRole() async {
    User user = await auth.currentUser;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get()
        .then((value) => setState(() {
              role = value["role"];
            }));
  }

  Future<void> getUserName() async {
    firestoreInstance.collection("users").doc(widget.patientUID).get().then(
      (value) {
        setState(() {
          name = (value["name"].toString());
          address = (value["Address"].toString());
          age = (value["Age"].toString());
          phone = (value["Details"]["Contact Number"].toString());
          email = (value["email"].toString());
          height = 180.toString();
          weight = 65.toString();
        });
      },
    );
    print(widget.docID);
  }

  // Future<void> getassessments() async {
  //   firestoreInstance
  //       .collection("assessments")
  //       .document(docID.toString())
  //       .get()
  //       .then(
  //     (value) {
  //       setState(() {
  //         // widget.assess = List.castFrom(value["form"].toList());
  //         startingTime = (value["startingTime"]);
  //         closingTime = (value["closingTime"]);
  //         patient = (value["patient"].toString());
  //         therapist = (value["therapist"].toString());
  //       });
  //     },
  //   );
  // print("//////////");
  // print(assess);
  // }

  List<pw.TableRow> buildAssesment(priority) {
    List<pw.TableRow> list = [];
    for (int index = 0; index < 12; index++) {
      int count = widget.assess[index]['count'];
      for (int i = 1; i <= count; i++) {
        int queCount = widget.assess[index]['room$i']['complete'];
        for (int j = 1; j <= queCount; j++) {
          if (widget.assess[index]['room$i']['question']['$j']['Priority'] ==
                  priority &&
              widget.assess[index]['room$i']['question']['$j']
                      ['Recommendationthera'] !=
                  "") {
            list.add(
              pw.TableRow(children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: pw.EdgeInsets.only(left: 5, right: 5),
                        child: pw.Text(
                            ' ${widget.assess[index]['name']}- ' +
                                '${widget.assess[index]['room$i']['name']}- ' +
                                '${widget.assess[index]['room$i']['question']['$j']['Question']}- ' +
                                '${widget.assess[index]['room$i']['question']['$j']['Answer']}: ',
                            style: pw.TextStyle(fontSize: 14)),
                      ),
                    ]),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: pw.EdgeInsets.only(left: 5, right: 5),
                        child: pw.Text(
                            ' ${widget.assess[index]['room$i']['question']['$j']['Recommendationthera']}',
                            style: pw.TextStyle(fontSize: 14)),
                      ),
                    ]),
              ]),
            );
          }
        }
      }
    }
    return list;
  }

  String formatTimeOfDay(TimeOfDay tod) {
    if (tod != null) {
      final now = new DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
      final format = DateFormat.jm(); //"6:00 AM"
      return format.format(dt);
    } else {
      return "";
    }
  }

  Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
    final path = (await getExternalStorageDirectory()).path;
    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open('$path/$fileName');
  }

  writeOnPdf() {
    List<pw.TableRow> list1 = buildAssesment("1");
    List<pw.TableRow> list2 = buildAssesment("2");
    List<pw.TableRow> list3 = buildAssesment("3");

    pw.TableRow buildRow(label, value) {
      return pw.TableRow(children: [
        pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Text(' $label', style: pw.TextStyle(fontSize: 14)),
            ]),
        pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Text(' $value', style: pw.TextStyle(fontSize: 14)),
            ]),
      ]);
    }

    pw.TableRow buildBlankRow(label, value) {
      return pw.TableRow(children: [
        pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Text('$label',
                  style: pw.TextStyle(
                      fontSize: 14, color: PdfColor.fromRYB(0, 0, 0))),
            ]),
        pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Text('$value',
                  style: pw.TextStyle(
                      fontSize: 14, color: PdfColor.fromRYB(0, 0, 0))),
            ]),
      ]);
    }

    pw.Table buildTableBlankRow(label, value) {
      return pw.Table(children: [
        pw.TableRow(children: [
          pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Text('$label',
                    style: pw.TextStyle(
                        fontSize: 14, color: PdfColor.fromRYB(0, 0, 0))),
              ]),
          pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Text('$value',
                    style: pw.TextStyle(
                        fontSize: 14, color: PdfColor.fromRYB(0, 0, 0))),
              ]),
        ]),
      ]);
    }

    pw.TableRow buildPriority(value, color1, color2) {
      return pw.TableRow(children: [
        pw.Container(
          color: color1,
          child:
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
            pw.Center(
                child: pw.Text(' $value',
                    style: pw.TextStyle(fontSize: 14, color: color2))),
          ]),
        ),
      ]);
    }

    pw.TableRow buildSubHead() {
      return pw.TableRow(children: [
        pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text('Recommendations For', style: pw.TextStyle(fontSize: 14)),
            ]),
        pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text('Recommendation', style: pw.TextStyle(fontSize: 14)),
            ]),
      ]);
    }

    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(31),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Header(
                outlineColor: PdfColors.white,
                child: pw.Center(
                    child: pw.Text("Home Safety Report",
                        style: pw.TextStyle(
                            fontSize: 30, fontWeight: pw.FontWeight.bold)))),
            pw.SizedBox(height: 20),
            pw.Table(
                border: pw.TableBorder.all(width: 1),
                defaultColumnWidth: pw.IntrinsicColumnWidth(),
                children: [
                  buildRow("Client", name),
                  buildRow("Gender", "Male"),
                  buildRow("Address", address),
                  buildRow("Age", age),
                  buildRow("Email", email),
                  buildRow("Phone Number", phone),
                  buildRow("Height", "Male"),
                  buildRow("Weight(lbs)", "65"),
                  buildRow("Hand Dominance", "Right"),
                  buildRow("Date of Assessment", "10/5/20"),
                  buildRow(
                      "Assessment Start Time", formatTimeOfDay(startingTime)),
                  buildRow("Assessment End Time", formatTimeOfDay(closingTime)),
                  buildBlankRow("null ", "null "),
                ]),
            buildTableBlankRow("null", "null"),
            pw.Table(border: pw.TableBorder.all(width: 1), children: [
              // pw.TableRow(children: [pw.Center(child: pw.Text("Priority 1"))]),
              buildPriority("Priority 1", PdfColors.red, PdfColors.white),
            ]),
            pw.Table(border: pw.TableBorder.all(width: 1), columnWidths: {
              0: pw.FixedColumnWidth(200),
              1: pw.FixedColumnWidth(200)
            }, children: [
              buildSubHead(),
            ]),
            pw.Table(border: pw.TableBorder.all(width: 1), columnWidths: {
              0: pw.FixedColumnWidth(200),
              1: pw.FixedColumnWidth(200)
            }, children: [
              for (int i = 0; i < list1.length; i++) list1[i]
            ]),
            buildTableBlankRow("null", "null"),
            pw.Table(border: pw.TableBorder.all(width: 1), children: [
              // pw.TableRow(children: [pw.Center(child: pw.Text("Priority 2"))]),
              buildPriority("Priority 2", PdfColors.orange, PdfColors.white),
            ]),
            pw.Table(border: pw.TableBorder.all(width: 1), columnWidths: {
              0: pw.FixedColumnWidth(200),
              1: pw.FixedColumnWidth(200)
            }, children: [
              buildSubHead(),
            ]),
            pw.Table(border: pw.TableBorder.all(width: 1), columnWidths: {
              0: pw.FixedColumnWidth(200),
              1: pw.FixedColumnWidth(200)
            }, children: [
              for (int i = 0; i < list2.length; i++) list2[i]
            ]),
            buildTableBlankRow("null", "null"),
            pw.Table(border: pw.TableBorder.all(width: 1), children: [
              // pw.TableRow(children: [pw.Center(child: pw.Text("Priority 3"))]),
              buildPriority("Priority 3", PdfColors.yellow, PdfColors.black),
            ]),
            pw.Table(border: pw.TableBorder.all(width: 1), columnWidths: {
              0: pw.FixedColumnWidth(200),
              1: pw.FixedColumnWidth(200)
            }, children: [
              buildSubHead(),
            ]),
            pw.Table(border: pw.TableBorder.all(width: 1), columnWidths: {
              0: pw.FixedColumnWidth(200),
              1: pw.FixedColumnWidth(200)
            }, children: [
              for (int i = 0; i < list3.length; i++) list3[i]
            ]),
            pw.SizedBox(height: 10),
            pw.Text("Disclaimer: ",
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 2),
            pw.Text("Please Note: ",
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Paragraph(
                style: pw.TextStyle(
                  fontSize: 14,
                ),
                text:
                    "The above recommendations / comments are made to the best of the abilities of this clinician given the present circumstances. Certain recommendations are given with a proactive and preventative approach in mind. These are recommendations / suggestions, decision to apply and implement them into practice is left to the autonomy of the client and his / her judgment of his / her circumstances. The clinician / Organization does not take any responsibility if the client decides not to follow through with these recommendations. Whenever possible, client has been provided with alternative choices and the client chose the options to suit his / her needs, knowledge and circumstances per their perception. This clinician will be available to consult on an as needed basis, should additional consultation needs arise.")
          ];
        }));
  }

  Future savePdf() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    String documentPath = documentDirectory.path;

    File file = File("$documentPath/report.pdf");

    file.writeAsBytesSync(await pdf.save());
    print(documentDirectory);
    print(documentPath);
  }

  @override
  Widget build(BuildContext context) {
    _verticalDivider() => BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        );

    Widget assesment(index, priority) {
      int count = widget.assess[index]['count'];
      for (int i = 1; i <= count; i++) {
        int queCount = widget.assess[index]['room$i']['complete'];
        for (int j = 1; j <= queCount; j++) {
          if (widget.assess[index]['room$i']['question']['$j']['Priority'] ==
                  priority &&
              widget.assess[index]['room$i']['question']['$j']
                      ['Recommendationthera'] !=
                  null) {
            return Text('${widget.assess[index]['name']}: ' +
                '${widget.assess[index]['room$i']['name']}: ' +
                '${widget.assess[index]['room$i']['question']['$j']['Question']}: ' +
                '${widget.assess[index]['room$i']['question']['$j']['Answer']}: ' +
                '${widget.assess[index]['room$i']['question']['$j']['Recommendationthera']}');
          }
        }
      }
    }

    RoundedRectangleBorder roundedRectangleBorder() {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      );
    }

    // Color standardfont() {
    //   return Color.fromRGBO(10, 80, 106, 1);
    // }

    IntrinsicHeight cardRow(label, value) {
      return IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(
            //   width: 40,
            // ),
            Text('$label ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54)),
            // SizedBox(
            //   width: 10,
            // ),
            Container(
              decoration: _verticalDivider(),
            ),
            // SizedBox(
            //   width: 10,
            // ),
            Text(' $value',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
          ],
        ),
      );
    }

    Row buildRow(label, value) {
      return Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.35,
            padding: EdgeInsets.only(left: 10),
            // alignment: Alignment.centerRight,
            child: Text('$label',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54)),
          ),
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * 0.04,
            decoration: _verticalDivider(),
          ),
          Container(
            padding: EdgeInsets.only(left: 10),
            width: MediaQuery.of(context).size.width * 0.35,
            alignment: Alignment.centerLeft,
            child: Text('$value',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
          ),
        ],
      );
    }

    Widget buildUserCard() {
      return Card(
        shape: roundedRectangleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IntrinsicHeight(
                child: buildRow("Client Name", name),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              IntrinsicHeight(
                child: buildRow("Gender", "Male"),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              IntrinsicHeight(
                child: buildRow("Address", address),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              IntrinsicHeight(
                child: buildRow("Age", age),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              IntrinsicHeight(
                child: buildRow("Email", email),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              IntrinsicHeight(child: buildRow("Phone Number", phone)),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              IntrinsicHeight(
                child: buildRow("Height", height),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              IntrinsicHeight(
                child: buildRow("Weight(lbs)", weight),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              IntrinsicHeight(
                child: buildRow("Hand Dominance", "Right"),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              IntrinsicHeight(
                child: buildRow("Date of Assessment", "10/28/20"),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              IntrinsicHeight(
                child: buildRow("Assessment Start Time", "2 pm"),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              IntrinsicHeight(child: buildRow("Assessment End Time", "3 pm")),
            ],
          ),
        ),
      );
    }

    Widget buildPrioOne() {
      return Card(
        shape: roundedRectangleBorder(),
        child: Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width / 2.5,
                child: RaisedButton(
                  onPressed: () {},
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80.0)),
                  padding: const EdgeInsets.all(0.0),
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[Colors.red, Colors.redAccent],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(80.0)),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(
                          minWidth: 88.0,
                          minHeight: 36.0), // min sizes for Material buttons
                      alignment: Alignment.center,
                      child: const Text(
                        'Priority 1',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Divider(color: Colors.black),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Text(
                      'Recommendation for ',
                      style: TextStyle(
                          fontSize: 16, color: Color.fromRGBO(10, 80, 106, 1)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      decoration: _verticalDivider(),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Recommendation",
                      style: TextStyle(
                          fontSize: 16, color: Color.fromRGBO(10, 80, 106, 1)),
                    )
                  ],
                ),
              ),
              Divider(
                color: Colors.black,
              ),
              ListView.builder(
                  itemCount: widget.assess.length,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index2) {
                    return Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: assesment(index2, "1"),
                    );

                    // assesment(
                    //     assesmentprovider.getlistdata()[index2]
                    //         ['name'],
                    //     index,
                    //     index2),
                  }),
            ],
          ),
        ),
      );
    }

    Widget buildPrioTwo() {
      return Card(
        shape: roundedRectangleBorder(),
        child: Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width / 2.5,
                child: RaisedButton(
                  onPressed: () {},
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80.0)),
                  padding: const EdgeInsets.all(0.0),
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[Colors.orange, Colors.orangeAccent],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(80.0)),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(
                          minWidth: 88.0,
                          minHeight: 36.0), // min sizes for Material buttons
                      alignment: Alignment.center,
                      child: const Text(
                        'Priority 2',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Divider(color: Colors.black),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Text(
                      'Recommendation for ',
                      style: TextStyle(
                          fontSize: 16, color: Color.fromRGBO(10, 80, 106, 1)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      decoration: _verticalDivider(),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Recommendation",
                      style: TextStyle(
                          fontSize: 16, color: Color.fromRGBO(10, 80, 106, 1)),
                    )
                  ],
                ),
              ),
              Divider(
                color: Colors.black,
              ),
              ListView.builder(
                  itemCount: widget.assess.length,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index2) {
                    return Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: assesment(index2, "2"),
                    );

                    // assesment(
                    //     assesmentprovider.getlistdata()[index2]
                    //         ['name'],
                    //     index,
                    //     index2),
                  }),
            ],
          ),
        ),
      );
    }

    Widget buildPrioThree() {
      return Card(
        shape: roundedRectangleBorder(),
        child: Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width / 2.5,
                child: RaisedButton(
                  onPressed: () {},
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80.0)),
                  padding: const EdgeInsets.all(0.0),
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[Colors.yellow, Colors.yellowAccent],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(80.0)),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(
                          minWidth: 88.0,
                          minHeight: 36.0), // min sizes for Material buttons
                      alignment: Alignment.center,
                      child: const Text(
                        'Priority 3',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Divider(color: Colors.black),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Text(
                      'Recommendation for ',
                      style: TextStyle(
                          fontSize: 16, color: Color.fromRGBO(10, 80, 106, 1)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      decoration: _verticalDivider(),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Recommendation",
                      style: TextStyle(
                          fontSize: 16, color: Color.fromRGBO(10, 80, 106, 1)),
                    )
                  ],
                ),
              ),
              Divider(
                color: Colors.black,
              ),
              ListView.builder(
                  itemCount: widget.assess.length,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index2) {
                    return Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: assesment(index2, "3"),

                      // assesment(
                      //     assesmentprovider.getlistdata()[index2]
                      //         ['name'],
                      //     index,
                      //     index2),
                    );
                  }),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        if (role == 'therapist') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Therapist()));
        } else if (role == 'patient') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Patient()));
        } else if (role == 'nurse') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Nurse()));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(10, 80, 106, 1),
          title: Text(
            'Home Safety Report',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.file_download,
                color: Colors.white,
              ),
              highlightColor: Colors.transparent,
              onPressed: () async {
                writeOnPdf();
                await savePdf();

                Directory documentDirectory =
                    await getApplicationDocumentsDirectory();
                String documentPath = documentDirectory.path;
                String fullPath = "$documentPath/report.pdf";
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => PdfPreviewScreen(
                //               path: fullPath,
                //             )));
                // SnackBar snackBar = SnackBar(content: Text("Report Generated"));
                // Navigator.pop(context, true);
                // ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: buildUserCard(),
              ),
              Padding(padding: const EdgeInsets.all(10), child: buildPrioOne()),
              Padding(padding: const EdgeInsets.all(10), child: buildPrioTwo()),
              Padding(
                  padding: const EdgeInsets.all(10), child: buildPrioThree()),
            ],
          ),
        ),
        backgroundColor: Color(0xfff5f5f5),
      ),
    );
  }
}

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   bool _isContainerVisible = true;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             AnimatedOpacity(
//               opacity: _isContainerVisible ? 1.0 : 0.0,
//               duration: Duration(seconds: 1),
//               child: Container(
//                 width: 100,
//                 height: 100,
//                 color: Colors.blue,
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _isContainerVisible = !_isContainerVisible;
//                 });
//               },
//               child: Text("Hello"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
