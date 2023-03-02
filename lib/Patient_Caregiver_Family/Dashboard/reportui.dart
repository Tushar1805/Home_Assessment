import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart' show kIsWeb;

class ReportUI extends StatefulWidget {
  List<Map<String, dynamic>> assess;
  String docID, patientUid, therapistUid;
  ReportUI(this.docID, this.patientUid, this.therapistUid, this.assess);
  @override
  _ReportUIState createState() => _ReportUIState();
}

class _ReportUIState extends State<ReportUI> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final firestoreInstance = FirebaseFirestore.instance;
  User curuser;
  var fname,
      lname,
      therafname,
      theralname,
      address,
      email,
      age,
      phone,
      height,
      weight,
      roomName,
      gender,
      handDominance;
  bool _isContainerVisible = true;
  String uid, patient, therapist, docID, fullPath;
  var startingTime, closingTime;
  bool _allowWriteFile = false;
  List<Map<String, dynamic>> assess = [];
  final pdf = pw.Document();
  final Color colorb = Color.fromRGBO(10, 80, 106, 1);
  List<Card> list4 = [];
  List<Card> list5 = [];
  List<Card> list6 = [];

  @override
  void initState() {
    super.initState();
    print("hello first");
    getassessments();
    getUserName();
    getLists();
    // list4 = buildAssesmentUI("1");
    // list5 = buildAssesmentUI("2");
    // list6 = buildAssesmentUI("3");
    // print("hello");
    // print(patient);
    // getPermission();
    getTherapistName(therapist);
  }

  // void getPermission() async {
  //   Map<Permission, PermissionStatus> permissions =
  //       await RunHandler().requestPermissions([Permission.storage]);
  // }

  Future<String> getDirectoryPath() async {
    if (kIsWeb) {
    } else {
      Directory appDocDirectory = await getApplicationDocumentsDirectory();

      Directory directory =
          await new Directory(appDocDirectory.path + '/' + 'dir')
              .create(recursive: true);

      return directory.path;
    }
  }

  // Future downloadFile(Uri uri, path) async {
  //   try {
  //     ProgressDialog progressDialog = ProgressDialog(context,
  //         dialogTransitionType: DialogTransitionType.Bubble,
  //         title: Text("Downloading File"));

  //     progressDialog.show();

  //     await dio.download("", path, onReceiveProgress: (rec, total) {
  //       setState(() {
  //         bool isLoading = true;
  //         String progress = ((rec / total) * 100).toStringAsFixed(0) + "%";
  //         progressDialog.setMessage(Text("Dowloading $progress"));
  //       });
  //     });
  //     progressDialog.dismiss();
  //   } catch (e) {
  //     print("dio error" + e.toString());
  //   }
  // }

  Future<void> getUserName() async {
    final User useruid = await auth.currentUser;
    await firestoreInstance
        .collection("users")
        .doc(widget.patientUid)
        .get()
        .then(
      (value) {
        setState(() {
          if (value.data() != null) {
            fname = (capitalize(value.data()["firstName"].toString()) ??
                "First name not provided");
            lname = (capitalize(value.data()["lastName"].toString()) ??
                "Last name not provided");
            gender = (capitalize(value.data()["gender"].toString()) ??
                "Gender not provided");
            address = (capitalize(value.data()["address"].toString()) ??
                "Address not provided");
            age = (value.data()["age"].toString() ?? "Age not provided");
            phone = (value.data()["mobile"].toString() ??
                "phone number not provided");
            email = (value.data()["email"].toString() ?? "Email not Provided");
            height =
                (value.data()["height"].toString() ?? "Height not provided");
            weight =
                (value.data()["weight"].toString() ?? "Weight not provided");
            handDominance =
                (value.data()["handDominance"].toString() ?? "Right");
          }
          // docID = (value["docID"].toString());
        });
      },
    );
    // print(useruid.uid.toString());
    // print(docID);
    // print("*******************");
    // print(therapist);
    // print("**************");
  }

  Future<void> getTherapistName(String uid) async {
    await firestoreInstance
        .collection("users")
        .doc(widget.therapistUid)
        .get()
        .then(
      (value) {
        if (value.data() != null) {
          setState(() {
            therafname =
                (capitalize(value.data()["firstName"].toString()) ?? "First");
            theralname =
                (capitalize(value.data()["lastName"].toString()) ?? "Last");
            // gender = (capitalize(value.data()["gender"].toString()) ?? "Male");
            // address =
            //     (capitalize(value.data()["houses"][0]["city"].toString()) ??
            //         "Nagpur");
            // age = (value.data()["age"].toString() ?? "21");
            // phone = (value.data()["mobileNo"].toString() ?? "1234567890");
            // email = (value.data()["email"].toString() ?? "user@gmail.com");
            // height = (value.data()["height"].toString() ?? "5.5");
            // weight = (value.data()["weight"].toString() ?? "50");
            // handDominance =
            //     (value.data()["handDominance"].toString() ?? "Right");
          });
        }
        // docID = (value["docID"].toString());
      },
    );
  }

  Future<void> getassessments() async {
    await firestoreInstance
        .collection("assessments")
        .doc(widget.docID)
        .get()
        .then((value) {
      if (value.data() != null) {
        setState(() {
          patient = (value.data()["patient"].toString());
          therapist = (value.data()["therapist"].toString());
        });
        if (value.data()["form"] != null) {
          setState(() {
            assess = List<Map<String, dynamic>>.generate(
                value.data()["form"].length,
                (int index) => Map<String, dynamic>.from(
                    value.data()["form"].elementAt(index)));
          });
        }
        // assess = List.castFrom(value["form"].toList());
        if (value.data()["date"] != null) {
          setState(() {
            startingTime =
                DateFormat.yMd().format(value.data()["date"].toDate()) +
                    " " +
                    DateFormat.jm().format(value.data()["date"].toDate());
          });
        }
        if (value.data()["assessmentCompletionDate"] != null) {
          setState(() {
            closingTime = DateFormat.yMd()
                    .format(value.data()["assessmentCompletionDate"].toDate()) +
                " " +
                DateFormat.jm()
                    .format(value.data()["assessmentCompletionDate"].toDate());
          });
        }
      }
    });

    // print("docID: ${widget.docID}");
    // print("//////////");
    // print("Map: $assess");
  }

  Widget getDate(String label, var date) {
    if (date != null) {
      return Container(
        width: double.infinity,
        child: Text(
          '$label ${date.toDate()} ',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      );
    } else {
      if (label == "Completion Date: ") {
        return Text("$label Yet to be Complete");
      } else {
        return Text("$label Yet to be Begin");
      }
    }
  }

  List<pw.TableRow> buildAssesment(priority) {
    List<pw.TableRow> list = [];
    for (int index = 0; index < 12; index++) {
      int count = assess[index]['count'] ?? 0;
      for (int i = 1; i <= count; i++) {
        int queCount = assess[index]['room$i']['complete'];
        for (int j = 1; j <= queCount; j++) {
          if (assess[index]['room$i']['question']['$j'] != null) {
            if (assess[index]['room$i']['question']['$j']['Priority'] ==
                    priority &&
                assess[index]['room$i']['question']['$j']
                        ['Recommendationthera'] !=
                    "") {
              list.add(
                pw.TableRow(children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Container(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Wrap(children: [
                              pw.Text(
                                  '${assess[index]['name']}: ' +
                                      '${assess[index]['room$i']['name']}: ' +
                                      '${assess[index]['room$i']['question']['$j']['Question']}: ' +
                                      '${assess[index]['room$i']['question']['$j']['Answer']}',
                                  style: pw.TextStyle(fontSize: 16)),
                            ])),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Container(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Wrap(children: [
                              pw.Text(
                                  '${assess[index]['room$i']['question']['$j']['Recommendationthera']}',
                                  style: pw.TextStyle(fontSize: 16)),
                            ]))
                      ]),
                ]),
              );
            }
          }
        }
      }
    }
    return list;
  }

  String formatTimeOfDay(DateTime tod) {
    // final now = new DateTime.now();
    // final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    // final format = DateFormat.jm(); //"6:00 AM"
    // return format.format(dt);
    return DateFormat("MM-dd-yyyy hh:mm").format(tod).toString();
  }

  writeOnPdf() async {
    List<pw.TableRow> list1 = buildAssesment("1");
    List<pw.TableRow> list2 = buildAssesment("2");
    List<pw.TableRow> list3 = buildAssesment("3");

    final ByteData bytes = await rootBundle.load('assets/logo.png');
    final Uint8List byteList = bytes.buffer.asUint8List();
    final ByteData bytes2 = await rootBundle.load('assets/bhbs.png');
    final Uint8List bhbs = bytes2.buffer.asUint8List();

    pw.TableRow buildRow(label, value) {
      return pw.TableRow(children: [
        pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Container(
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Wrap(children: [
                    pw.Text('$label',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ])),
            ]),
        pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Container(
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Wrap(children: [
                    pw.Text('$value', style: pw.TextStyle(fontSize: 16)),
                  ])),
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
          padding: pw.EdgeInsets.only(top: 5, bottom: 5),
          color: color1,
          child:
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
            pw.Center(
                child: pw.Text(' $value',
                    style: pw.TextStyle(
                        fontSize: 18,
                        color: color2,
                        fontWeight: pw.FontWeight.bold))),
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
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                child: pw.Text('Recommendations For',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
              )
            ]),
        pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                child: pw.Text('Recommendations',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
              )
            ]),
      ]);
    }

    // ***************************** Page 1 ****************************

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 0, marginLeft: 0, marginRight: 0, marginTop: 0),
        build: (pw.Context context) {
          return pw.Column(children: [
            pw.Container(
                width: 1000,
                height: 50,
                color: PdfColor.fromHex("0a506a"),
                child: pw.Center(
                    child: pw.Text('Home Safety Assessment',
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 30,
                            fontWeight: pw.FontWeight.bold)))),
            pw.SizedBox(height: 20),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
              pw.Image(
                  pw.MemoryImage(
                    byteList,
                  ),
                  fit: pw.BoxFit.fitHeight),
            ]),
            pw.SizedBox(height: 50),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
              pw.Container(
                  height: 25,
                  child: pw.Text('Patient Name: ',
                      style: pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold))),
              pw.Container(
                  height: 25,
                  child: pw.Text('$fname$lname',
                      style: pw.TextStyle(
                          color: PdfColor.fromHex("ba2020"),
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold))),
            ]),
            pw.SizedBox(height: 20),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
              pw.Container(
                  height: 25,
                  child: pw.Text('Done By: ',
                      style: pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold))),
              pw.Container(
                  height: 25,
                  child: pw.Text('$therafname$theralname',
                      style: pw.TextStyle(
                          color: PdfColor.fromHex("ba2020"),
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold))),
            ]),

            pw.SizedBox(height: 30),
            pw.Padding(
              padding: pw.EdgeInsets.all(10),
              child: pw.Container(
                width: 1000,
                height: 10,
                color: PdfColor.fromHex("0a506a"),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Padding(
                padding: pw.EdgeInsets.all(10),
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Image(
                          pw.MemoryImage(
                            bhbs,
                          ),
                          height: 40,
                          width: 160,
                          fit: pw.BoxFit.fitHeight),
                      pw.Container(
                          height: 25,
                          // color: PdfColor.fromHex("0a506a"),
                          child: pw.Text(
                              '${closingTime ?? 'Date will apppear here'}',
                              style: pw.TextStyle(
                                  color: PdfColor.fromHex("0a506a"),
                                  fontSize: 20,
                                  fontWeight: pw.FontWeight.bold))),
                    ])),

            // pw.Text('Home Safety Assessment',
            //     style: pw.TextStyle(
            //         color: PdfColor.fromHex('3c1758'),
            //         fontSize: 20,
            //         fontWeight: pw.FontWeight.bold)),
            // pw.SizedBox(height: 50),
            // pw.Container(
            //     width: 1000,
            //     height: 60,
            //     color: PdfColor.fromHex('3c1758'),
            //     child: pw.Padding(
            //         padding: pw.EdgeInsets.fromLTRB(180, 20, 10, 10),
            //         child: pw.Text('hello',
            //             style: pw.TextStyle(
            //                 color: PdfColors.white,
            //                 fontSize: 15,
            //                 fontWeight: pw.FontWeight.bold)))),
            // pw.SizedBox(height: 147.5),
          ]);
        },
      ),
    );
    pw.Widget header() {
      return pw.Header(
          outlineColor: PdfColors.white,
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Home Safety Report",
                    style: pw.TextStyle(
                        fontSize: 30, fontWeight: pw.FontWeight.bold)),
                pw.Image(
                    pw.MemoryImage(
                      bhbs,
                    ),
                    height: 30,
                    width: 140,
                    fit: pw.BoxFit.fitHeight),
              ]));
    }

    // Complete page UI

    // pdf.addPage(pw.MultiPage(
    //     header: (context) => header(),
    //     pageFormat: PdfPageFormat.a4.copyWith(
    //         marginBottom: 20, marginLeft: 20, marginRight: 20, marginTop: 0),
    //     build: (pw.Context context) {
    //       return <pw.Widget>[
    //         // pw.Image(
    //         //     pw.MemoryImage(
    //         //       byteList,
    //         //     ),
    //         //     fit: pw.BoxFit.fitHeight),
    //         // pw.Padding(
    //         //     padding: pw.EdgeInsets.only(top: 10),
    //         //     child: pw.Header(
    //         //         outlineColor: PdfColors.white,
    //         //         child: pw.Row(
    //         //             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    //         //             children: [
    //         //               pw.Text("Home Safety Report",
    //         //                   style: pw.TextStyle(
    //         //                       fontSize: 30,
    //         //                       fontWeight: pw.FontWeight.bold)),
    //         //               pw.Image(
    //         //                   pw.MemoryImage(
    //         //                     bhbs,
    //         //                   ),
    //         //                   height: 30,
    //         //                   width: 140,
    //         //                   fit: pw.BoxFit.fitHeight),
    //         //             ]))),
    //         pw.SizedBox(height: 20),
    //         pw.Table(border: pw.TableBorder.all(width: 1), columnWidths: {
    //           0: pw.FixedColumnWidth(200),
    //           1: pw.FixedColumnWidth(200)
    //         }, children: [
    //           pw.TableRow(
    //               decoration:
    //                   pw.BoxDecoration(color: PdfColor.fromHex("#66AD47")),
    //               children: [
    //                 pw.Column(
    //                     crossAxisAlignment: pw.CrossAxisAlignment.start,
    //                     mainAxisAlignment: pw.MainAxisAlignment.start,
    //                     children: [
    //                       pw.Container(
    //                           // width: 200,
    //                           // decoration: pw.BoxDecoration(
    //                           //     color: PdfColor.fromHex("#5cff67")),
    //                           padding: pw.EdgeInsets.all(5),
    //                           child: pw.Wrap(children: [
    //                             pw.Text('Patient',
    //                                 style: pw.TextStyle(
    //                                     fontSize: 18,
    //                                     fontWeight: pw.FontWeight.bold)),
    //                           ]))
    //                     ]),
    //                 pw.Column(
    //                     crossAxisAlignment: pw.CrossAxisAlignment.start,
    //                     mainAxisAlignment: pw.MainAxisAlignment.start,
    //                     children: [
    //                       pw.Container(
    //                           // width: 200,
    //                           // decoration: pw.BoxDecoration(
    //                           //     color: PdfColor.fromHex("#5cff67")),
    //                           padding: pw.EdgeInsets.all(5),
    //                           child: pw.Wrap(children: [
    //                             pw.Text('Details',
    //                                 style: pw.TextStyle(
    //                                     fontSize: 18,
    //                                     fontWeight: pw.FontWeight.bold)),
    //                           ]))
    //                     ]),
    //               ]),
    //           buildRow("Name", "$fname $lname"),
    //           buildRow("Gender", gender),
    //           buildRow("Address", address),
    //           buildRow("Age", age),
    //           buildRow("Email", email),
    //           buildRow("Phone Number", phone),
    //           // buildRow("Height", "$height ft"),
    //           // buildRow("Weight(lbs)", "$weight kg"),
    //           // buildRow("Hand Dominance", handDominance),
    //           // buildRow("Date of Assessment", "10/5/20"),
    //           buildRow("Assessment Start Time", startingTime),
    //           buildRow("Assessment End Time", closingTime),
    //           // buildBlankRow("null ", "null "),
    //         ]),
    //         // buildTableBlankRow("null", "null"),
    //         pw.SizedBox(height: 20),
    //         pw.Table(border: pw.TableBorder.all(width: 1), children: [
    //           // pw.TableRow(children: [pw.Center(child: pw.Text("Priority 1"))]),
    //           buildPriority("Priority 1", PdfColors.red, PdfColors.black),
    //         ]),
    //         pw.Table(border: pw.TableBorder.all(width: 1), columnWidths: {
    //           0: pw.FixedColumnWidth(200),
    //           1: pw.FixedColumnWidth(200)
    //         }, children: [
    //           buildSubHead(),
    //         ]),
    //         pw.Table(border: pw.TableBorder.all(width: 1), columnWidths: {
    //           0: pw.FixedColumnWidth(200),
    //           1: pw.FixedColumnWidth(200)
    //         }, children: [
    //           for (int i = 0; i < list1.length; i++) list1[i]
    //         ]),
    //         // buildTableBlankRow("null", "null"),
    //         pw.SizedBox(height: 20),
    //         pw.Table(border: pw.TableBorder.all(width: 1), children: [
    //           // pw.TableRow(children: [pw.Center(child: pw.Text("Priority 2"))]),
    //           buildPriority("Priority 2", PdfColors.orange, PdfColors.black),
    //         ]),
    //         pw.Table(border: pw.TableBorder.all(width: 1), columnWidths: {
    //           0: pw.FixedColumnWidth(200),
    //           1: pw.FixedColumnWidth(200)
    //         }, children: [
    //           buildSubHead(),
    //         ]),
    //         pw.Table(border: pw.TableBorder.all(width: 1), columnWidths: {
    //           0: pw.FixedColumnWidth(200),
    //           1: pw.FixedColumnWidth(200)
    //         }, children: [
    //           for (int i = 0; i < list2.length; i++) list2[i]
    //         ]),
    //         // buildTableBlankRow("null", "null"),
    //         pw.SizedBox(height: 20),
    //         pw.Table(border: pw.TableBorder.all(width: 1), children: [
    //           // pw.TableRow(children: [pw.Center(child: pw.Text("Priority 3"))]),
    //           buildPriority("Priority 3", PdfColors.yellow, PdfColors.black),
    //         ]),
    //         pw.Table(border: pw.TableBorder.all(width: 1), columnWidths: {
    //           0: pw.FixedColumnWidth(200),
    //           1: pw.FixedColumnWidth(200)
    //         }, children: [
    //           buildSubHead(),
    //         ]),
    //         pw.Table(border: pw.TableBorder.all(width: 1), columnWidths: {
    //           0: pw.FixedColumnWidth(200),
    //           1: pw.FixedColumnWidth(200)
    //         }, children: [
    //           for (int i = 0; i < list3.length; i++) list3[i]
    //         ]),
    //         pw.SizedBox(height: 40),
    //         pw.Text("Disclaimer: ",
    //             style:
    //                 pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
    //         pw.SizedBox(height: 2),
    //         pw.Text("Please Note: ",
    //             style:
    //                 pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
    //         pw.Paragraph(
    //             style: pw.TextStyle(
    //               fontSize: 14,
    //             ),
    //             text:
    //                 "The above recommendations / comments are made to the best of the abilities of this clinician given the present circumstances. Certain recommendations are given with a proactive and preventative approach in mind. These are recommendations / suggestions, decision to apply and implement them into practice is left to the autonomy of the client and his / her judgment of his / her circumstances. The clinician / Organization does not take any responsibility if the client decides not to follow through with these recommendations. Whenever possible, client has been provided with alternative choices and the client chose the options to suit his / her needs, knowledge and circumstances per their perception. This clinician will be available to consult on an as needed basis, should additional consultation needs arise.")
    //       ];
    //     }));

    // User Details

    pdf.addPage(pw.MultiPage(
        header: (context) => header(),
        pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 20, marginLeft: 20, marginRight: 20, marginTop: 0),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.SizedBox(height: 20),
            pw.Table(border: pw.TableBorder.all(width: 1), columnWidths: {
              0: pw.FixedColumnWidth(200),
              1: pw.FixedColumnWidth(200)
            }, children: [
              pw.TableRow(
                  decoration:
                      pw.BoxDecoration(color: PdfColor.fromHex("#66AD47")),
                  children: [
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Container(
                              // width: 200,
                              // decoration: pw.BoxDecoration(
                              //     color: PdfColor.fromHex("#5cff67")),
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Wrap(children: [
                                pw.Text('Patient',
                                    style: pw.TextStyle(
                                        fontSize: 18,
                                        fontWeight: pw.FontWeight.bold)),
                              ]))
                        ]),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Container(
                              // width: 200,
                              // decoration: pw.BoxDecoration(
                              //     color: PdfColor.fromHex("#5cff67")),
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Wrap(children: [
                                pw.Text('Details',
                                    style: pw.TextStyle(
                                        fontSize: 18,
                                        fontWeight: pw.FontWeight.bold)),
                              ]))
                        ]),
                  ]),
              buildRow("Name", "$fname $lname"),
              buildRow("Gender", gender),
              buildRow("Address", address),
              buildRow("Age", age),
              buildRow("Email", email),
              buildRow("Phone Number", phone),
              // buildRow("Height", "$height ft"),
              // buildRow("Weight(lbs)", "$weight kg"),
              // buildRow("Hand Dominance", handDominance),
              // buildRow("Date of Assessment", "10/5/20"),
              buildRow("Assessment Start Time", startingTime),
              buildRow("Assessment End Time", closingTime),
              // buildBlankRow("null ", "null "),
            ]),
          ];
        }));

    //Priority 1

    pdf.addPage(pw.MultiPage(
        header: (context) => header(),
        pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 20, marginLeft: 20, marginRight: 20, marginTop: 0),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.SizedBox(height: 20),
            pw.Table(border: pw.TableBorder.all(width: 1), children: [
              // pw.TableRow(children: [pw.Center(child: pw.Text("Priority 1"))]),
              buildPriority("Priority 1", PdfColors.red, PdfColors.black),
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
          ];
        }));
    //Priority 2
    pdf.addPage(pw.MultiPage(
        header: (context) => header(),
        pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 20, marginLeft: 20, marginRight: 20, marginTop: 0),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.SizedBox(height: 20),
            pw.Table(border: pw.TableBorder.all(width: 1), children: [
              // pw.TableRow(children: [pw.Center(child: pw.Text("Priority 2"))]),
              buildPriority("Priority 2", PdfColors.orange, PdfColors.black),
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
          ];
        }));

// priority 3
    pdf.addPage(pw.MultiPage(
        header: (context) => header(),
        pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 20, marginLeft: 20, marginRight: 20, marginTop: 0),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.SizedBox(height: 20),
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
            pw.SizedBox(height: 40),
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
    // pdf.addPage(
    //   pw.Page(

    //     pageFormat: PdfPageFormat.a4.copyWith(
    //         marginBottom: 20, marginLeft: 20, marginRight: 20, marginTop: 550),
    //     build: (pw.Context context) {
    //       return pw.Column(
    //           mainAxisAlignment: pw.MainAxisAlignment.start,
    //           crossAxisAlignment: pw.CrossAxisAlignment.start,
    //           children: [

    //             pw.Text("Disclaimer: ",
    //                 style: pw.TextStyle(
    //                     fontSize: 14, fontWeight: pw.FontWeight.bold)),
    //             pw.SizedBox(height: 2),
    //             pw.Text("Please Note: ",
    //                 style: pw.TextStyle(
    //                     fontSize: 14, fontWeight: pw.FontWeight.bold)),
    //             pw.Paragraph(
    //                 style: pw.TextStyle(
    //                   fontSize: 14,
    //                 ),
    //                 text:
    //                     "The above recommendations / comments are made to the best of the abilities of this clinician given the present circumstances. Certain recommendations are given with a proactive and preventative approach in mind. These are recommendations / suggestions, decision to apply and implement them into practice is left to the autonomy of the client and his / her judgment of his / her circumstances. The clinician / Organization does not take any responsibility if the client decides not to follow through with these recommendations. Whenever possible, client has been provided with alternative choices and the client chose the options to suit his / her needs, knowledge and circumstances per their perception. This clinician will be available to consult on an as needed basis, should additional consultation needs arise.")
    //           ]);
    //     },
    //   ),
    // );
  }

  Future<void> imageLoader() async {
    pw.MemoryImage(
        (await rootBundle.load('assets/logo.png')).buffer.asUint8List());
  }

  Future savePdf() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    String documentPath = documentDirectory.path;

    File file = File("$documentPath/report.pdf");

    file.writeAsBytesSync(List.from(await pdf.save()));
    // print(documentDirectory);
    // print(documentPath);
    // downloadFile(file.uri, '$documentPath/report.pdf');
  }

  Future<File> pdfAsset() async {
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/report.pdf');
    // ByteData bd = await rootBundle.load('assets/logo.png');
    tempFile.writeAsBytesSync(List.from(await pdf.save()));
    return tempFile;
  }

  List<Card> buildAssesmentUI(priority) {
    List<Card> list = [];
    for (int index = 0; index < 12; index++) {
      if (widget.assess != null) {
        int count = widget.assess[index]['count'];
        for (int i = 1; i <= count; i++) {
          int queCount = widget.assess[index]['room$i']['complete'];
          for (int j = 1; j <= queCount; j++) {
            if (widget.assess[index]['room$i']['question']['$j'] != null) {
              if (widget.assess[index]['room$i']['question']['$j']
                          ['Priority'] ==
                      priority &&
                  widget.assess[index]['room$i']['question']['$j']
                          ['Recommendationthera'] !=
                      "") {
                list.add(
                  Card(
                    shape: roundedRectangleBorder(),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(15, 10, 5, 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.assess[index]['name']}: ${widget.assess[index]['room$i']['name']}',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: colorb),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // Text(
                          //   'Recommendation For: ',
                          //   style: TextStyle(
                          //       fontSize: 18,
                          //       fontWeight: FontWeight.bold,
                          //       color: Colors.black45),
                          // ),
                          Wrap(
                            spacing: 5.0,
                            children: [
                              Text("Question: ",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w200,
                                      color: Colors.black45)),
                              Text(
                                  "${widget.assess[index]['room$i']['question']['$j']['Question']}",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w200)),
                            ],
                          ),

                          Wrap(spacing: 5.0, children: [
                            Text("Answer: ",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w200,
                                    color: Colors.black45)),
                            Text(
                                "${widget.assess[index]['room$i']['question']['$j']['Answer']}",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w200)),
                          ]),
                          SizedBox(
                            height: 10,
                          ),
                          Wrap(children: [
                            Text("Recommendations: ",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w200,
                                    color: Colors.red)),
                            Text(
                                "${widget.assess[index]['room$i']['question']['$j']['Recommendationthera']}",
                                style: TextStyle(
                                  // decoration: TextDecoration.underline,
                                  // decorationColor: Colors.yellow,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w200,
                                )),
                          ]),
                          SizedBox(
                            height: 10,
                          )
                          // Divider(),
                        ],
                      ),
                    ),
                  ),
                  // pw.Column(
                  //     crossAxisAlignment: pw.CrossAxisAlignment.start,
                  //     mainAxisAlignment: pw.MainAxisAlignment.start,
                  //     children: [
                  //       pw.Container(
                  //         padding: pw.EdgeInsets.only(left: 5, right: 5),
                  //         child: pw.Text(
                  //             ' ${assess[index]['room$i']['question']['$j']['Recommendationthera']}',
                  //             style: pw.TextStyle(fontSize: 14)),
                  //       ),
                  //     ]),
                  // ])
                );
              }
            }
          }
        }
      }
    }
    return list;
  }

  RoundedRectangleBorder roundedRectangleBorder() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    );
  }

  getLists() {
    list4 = buildAssesmentUI("1");
    list5 = buildAssesmentUI("2");
    list6 = buildAssesmentUI("3");
  }

  String capitalize(String s) {
    if (s != null) {
      var parts = s.split(' ');
      // print(parts);
      String sum = '';
      parts.forEach(
          (cur) => {sum += cur[0].toUpperCase() + cur.substring(1) + " "});
      return sum;
    }
  }

  @override
  Widget build(BuildContext context) {
    // getassessments();
    _verticalDivider() => BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        );

    // Widget assesment(index, priority) {
    //   int count = assess[index]['count'];
    //   for (int i = 1; i <= count; i++) {
    //     int queCount = assess[index]['room$i']['complete'];
    //     for (int j = 1; j <= queCount; j++) {
    //       if (assess[index]['room$i']['question']['$j']['Priority'] ==
    //               priority &&
    //           assess[index]['room$i']['question']['$j']
    //                   ['Recommendationthera'] !=
    //               "") {
    //         // return Text('${assess[index]['name']}: ' +
    //         //     '${assess[index]['room$i']['name']}: ' +
    //         //     '${assess[index]['room$i']['question']['$j']['Question']}: ' +
    //         //     '${assess[index]['room$i']['question']['$j']['Answer']}: ' +
    //         //     '${assess[index]['room$i']['question']['$j']['Recommendationthera']}');
    //         return Column(
    //           mainAxisAlignment: MainAxisAlignment.start,
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Text(
    //               '${assess[index]['name']}: ${assess[index]['room$i']['name']}',
    //               style: TextStyle(
    //                   fontSize: 20, fontWeight: FontWeight.w900, color: colorb),
    //             ),
    //             Text(
    //               'Recommendation For: ',
    //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200),
    //             ),
    //             Text(
    //                 "Question: ${assess[index]['room$i']['question']['$j']['Question']}",
    //                 style:
    //                     TextStyle(fontSize: 18, fontWeight: FontWeight.w200)),
    //             Text(
    //                 "Answer: ${assess[index]['room$i']['question']['$j']['Answer']}",
    //                 style:
    //                     TextStyle(fontSize: 18, fontWeight: FontWeight.w200)),
    //             Text(
    //                 "Recommendations: ${assess[index]['room$i']['question']['$j']['Recommendationthera']}",
    //                 style:
    //                     TextStyle(fontSize: 18, fontWeight: FontWeight.w200)),
    //             Divider(),
    //           ],
    //         );
    //       }
    //     }
    //   }
    // }

    // List<Column> buildAssesment(priority) {
    //   List<Column> list = [];
    //   for (int index = 0; index < 12; index++) {
    //     int count = assess[index]['count'] ?? 0;
    //     for (int i = 1; i <= count; i++) {
    //       int queCount = assess[index]['room$i']['complete'];
    //       for (int j = 1; j <= queCount; j++) {
    //         if (assess[index]['room$i']['question']['$j'] != null) {
    //           if (assess[index]['room$i']['question']['$j']['Priority'] ==
    //                   priority &&
    //               assess[index]['room$i']['question']['$j']
    //                       ['Recommendationthera'] !=
    //                   "") {
    //             list.add(
    //               Column(
    //                 mainAxisAlignment: MainAxisAlignment.start,
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     '${assess[index]['name']}: ${assess[index]['room$i']['name']}',
    //                     style: TextStyle(
    //                         fontSize: 20,
    //                         fontWeight: FontWeight.w900,
    //                         color: colorb),
    //                   ),
    //                   Text(
    //                     'Recommendation For: ',
    //                     style: TextStyle(
    //                         fontSize: 18, fontWeight: FontWeight.w200),
    //                   ),
    //                   Text(
    //                       "Question: ${assess[index]['room$i']['question']['$j']['Question']}",
    //                       style: TextStyle(
    //                           fontSize: 18, fontWeight: FontWeight.w200)),
    //                   Text(
    //                       "Answer: ${assess[index]['room$i']['question']['$j']['Answer']}",
    //                       style: TextStyle(
    //                           fontSize: 18, fontWeight: FontWeight.w200)),
    //                   Text(
    //                       "Recommendations: ${assess[index]['room$i']['question']['$j']['Recommendationthera']}",
    //                       style: TextStyle(
    //                           fontSize: 18, fontWeight: FontWeight.w200)),
    //                   Divider(),
    //                 ],
    //               ),
    //               // pw.Column(
    //               //     crossAxisAlignment: pw.CrossAxisAlignment.start,
    //               //     mainAxisAlignment: pw.MainAxisAlignment.start,
    //               //     children: [
    //               //       pw.Container(
    //               //         padding: pw.EdgeInsets.only(left: 5, right: 5),
    //               //         child: pw.Text(
    //               //             ' ${assess[index]['room$i']['question']['$j']['Recommendationthera']}',
    //               //             style: pw.TextStyle(fontSize: 14)),
    //               //       ),
    //               //     ]),
    //               // ])
    //             );
    //           }
    //         }
    //       }
    //     }
    //   }
    //   return list;
    // }

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
            Text('$value',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
          ],
        ),
      );
    }

    Row buildRow(label, value) {
      if (value != null) {
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
                  style:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
            ),
          ],
        );
      }
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
                child: buildRow("Patient Name", "$fname$lname"),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              IntrinsicHeight(
                child: buildRow("Gender", gender),
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
                child: buildRow("Height(ft)", height),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              IntrinsicHeight(
                child: buildRow("Weight(kg)", weight),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              IntrinsicHeight(
                child: buildRow("Hand Dominance", handDominance),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              // IntrinsicHeight(
              //   child: buildRow("Date of Assessment", "10/28/),
              // ),
              // Divider(
              //   thickness: 0.5,
              //   color: Colors.grey,
              // ),
              IntrinsicHeight(
                child: buildRow(
                    "Assessment Start Date", startingTime ?? "Yet To Begin"),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              IntrinsicHeight(
                  child: buildRow(
                      "Assessment End Date", closingTime ?? "Yet To Finish")),
            ],
          ),
        ),
      );
    }

    getList(
      var list,
    ) {
      if (list != null && list.length != 0) {
        return ListView.builder(
            itemCount: list.length,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, index2) {
              return Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 5, 5),
                child: list[index2],
              );

              // assesment(
              //     assesmentprovider.getlistdata()[index2]
              //         ['name'],
              //     index,
              //     index2),
            });
      } else {
        return SizedBox(height: 0);
      }
    }

    Widget buildPrioOne() {
      if (list4.length != 0) {
        return Container(
          // shape: roundedRectangleBorder(),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              RaisedButton(
                onPressed: () {},
                textColor: Colors.black,
                padding: const EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.0)),
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.red,
                      // gradient: LinearGradient(
                      //   colors: <Color>[
                      //     Color.fromRGBO(255, 0, 0, 0.35),
                      //     Color.fromRGBO(255, 0, 0, 0.71),
                      //     Color.fromRGBO(255, 0, 0, 1),
                      //   ],
                      // ),
                      borderRadius: BorderRadius.all(Radius.circular(80.0))),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child:
                      const Text('Priority 1', style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              // Divider(color: Colors.black),
              // IntrinsicHeight(
              //   child: Row(
              //     children: [
              //       Text(
              //         'Recommendation for ',
              //         style: TextStyle(
              //             fontSize: 16, color: Color.fromRGBO(10, 80, 106, 1)),
              //       ),
              //       SizedBox(
              //         width: 10,
              //       ),
              //       Container(
              //         decoration: _verticalDivider(),
              //       ),
              //       SizedBox(
              //         width: 10,
              //       ),
              //       Text(
              //         "Recommendation",
              //         style: TextStyle(
              //             fontSize: 16, color: Color.fromRGBO(10, 80, 106, 1)),
              //       )
              //     ],
              //   ),
              // ),
              // Divider(
              //   color: Colors.black,
              // ),
              getList(list4),
            ],
          ),
        );
      } else {
        return Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              RaisedButton(
                onPressed: () {},
                textColor: Colors.black,
                padding: const EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.0)),
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(80.0))),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child:
                      const Text('Priority 1', style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                child: Text(
                    "Congratulations!, According to the data you / your family or caregiver provided and your evaluating therapist who analyzed the data presented to him/her,  it does not seem like there is any immediate need. However, ",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(10, 80, 106, 1))),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                child: Text("ALWAYS BETTER TO BE PROACTIVE & PREPARED! ",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[600])),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                child: Text(
                    "Please review the recommendations made and implement them at your earliest to ensure your safety.",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(10, 80, 106, 1))),
              ),
            ],
          ),
        );
      }
    }

    Widget buildPrioTwo() {
      if (list5.length != 0) {
        return Container(
          // shape: roundedRectangleBorder(),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              RaisedButton(
                onPressed: () {},
                textColor: Colors.black,
                padding: const EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.0)),
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.orange,
                      // gradient: LinearGradient(
                      //   colors: <Color>[
                      //     Color.fromRGBO(255, 80, 0, 0.50),
                      //     Color.fromRGBO(226, 85, 8, 0.75),
                      //     Color.fromRGBO(254, 89, 4, 1),
                      //   ],
                      // ),
                      borderRadius: BorderRadius.all(Radius.circular(80.0))),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child:
                      const Text('Priority 2', style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              // Divider(color: Colors.black),
              // IntrinsicHeight(
              //   child: Row(
              //     children: [
              //       Text(
              //         'Recommendation for ',
              //         style: TextStyle(
              //             fontSize: 16, color: Color.fromRGBO(10, 80, 106, 1)),
              //       ),
              //       SizedBox(
              //         width: 10,
              //       ),
              //       Container(
              //         decoration: _verticalDivider(),
              //       ),
              //       SizedBox(
              //         width: 10,
              //       ),
              //       Text(
              //         "Recommendation",
              //         style: TextStyle(
              //             fontSize: 16, color: Color.fromRGBO(10, 80, 106, 1)),
              //       )
              //     ],
              //   ),
              // ),
              // Divider(
              //   color: Colors.black,
              // ),
              getList(list5)
            ],
          ),
        );
      } else {
        return SizedBox();
      }
    }

    Widget buildPrioThree() {
      if (list6.length != 0) {
        return Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              RaisedButton(
                onPressed: () {},
                textColor: Colors.white,
                padding: const EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.0)),
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.yellow,
                      // gradient: LinearGradient(
                      //   colors: <Color>[
                      //     Color.fromRGBO(232, 233, 96, 0.81),
                      //     Color.fromRGBO(249, 251, 55, 0.85),
                      //     Color.fromRGBO(253, 255, 0, 1),
                      //   ],
                      // ),
                      borderRadius: BorderRadius.all(Radius.circular(80.0))),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: const Text('Priority 3',
                      style: TextStyle(color: Colors.black, fontSize: 18)),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              // Divider(color: Colors.black),
              // IntrinsicHeight(
              //   child: Row(
              //     children: [
              //       Text(
              //         'Recommendation for ',
              //         style: TextStyle(
              //             fontSize: 16, color: Color.fromRGBO(10, 80, 106, 1)),
              //       ),
              //       SizedBox(
              //         width: 10,
              //       ),
              //       Container(
              //         decoration: _verticalDivider(),
              //       ),
              //       SizedBox(
              //         width: 10,
              //       ),
              //       Text(
              //         "Recommendation",
              //         style: TextStyle(
              //             fontSize: 16, color: Color.fromRGBO(10, 80, 106, 1)),
              //       )
              //     ],
              //   ),
              // ),
              // Divider(
              //   color: Colors.black,
              // ),
              getList(list6)
            ],
          ),
        );
      } else {
        return SizedBox();
      }
    }

    return Scaffold(
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
              await imageLoader();
              writeOnPdf();
              // await savePdf();
              pdfAsset().then((file) {
                OpenFile.open(file.path);
              });

              Directory documentDirectory =
                  await getApplicationDocumentsDirectory();
              String documentPath = documentDirectory.path;
              fullPath = "$documentPath/report.pdf";
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => PdfPreviewScreen(
              //           path: fullPath,
              //         )));
              // String path = await ExtStorage.getExternalStoragePublicDirectory(
              //     ExtStorage.DIRECTORY_DOWNLOADS);
              // print(path);
              // SnackBar(content: Text("Report Downloade Successfully"));
            },
          )
        ],
      ),
      // body: PDFViewerScaffold(
      //   path: fullPath,
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.all(20),
            //   child: buildUserCard(),
            // ),
            Padding(padding: const EdgeInsets.all(10), child: buildPrioOne()),
            Padding(padding: const EdgeInsets.all(10), child: buildPrioTwo()),
            Padding(padding: const EdgeInsets.all(10), child: buildPrioThree()),
          ],
        ),
      ),
      backgroundColor: Colors.grey[200],
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
