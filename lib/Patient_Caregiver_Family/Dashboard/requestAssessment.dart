import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentpro.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentrepo.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/patientdash.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/patientdashrepo.dart';
import 'package:tryapp/constants.dart';

final _colorgreen = Color.fromRGBO(10, 80, 106, 1);

class RequestAssessment extends StatefulWidget {
  @override
  _RequestAssessmentState createState() => _RequestAssessmentState();
}

class _RequestAssessmentState extends State<RequestAssessment> {
  String name, docID;
  TimeOfDay time;
  DateTime date;
  TimeOfDay pickedTime;
  DayPeriod pickedDate;

  void initState() {
    super.initState();
    getUserName();
    time = TimeOfDay.now();
    date = DateTime.now();
  }

  Future<void> getUserName() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await Firestore.instance
        .collection("users")
        .document(user.uid)
        .get()
        .then((value) {
      setState(() {
        name = value["firstName"];
      });
    });
    print(user.uid);
  }

  Future<Null> selectTime1(BuildContext context) async {
    pickedTime = await showTimePicker(context: context, initialTime: time);

    if (pickedTime != null) {
      setState(() {
        time = pickedTime;
        print(time);
      });
    }
  }

  TextEditingController _datecontroller = new TextEditingController();

  var myFormat = DateFormat('d-MM-yyyy');

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    setState(() {
      date = picked ?? date;
      print(date);
    });
  }

  static DateTime fromDateTimeToJson(DateTime date) {
    if (date == null) return null;

    return date.toUtc();
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  static void showSnackBar(BuildContext context, String text) =>
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          duration: const Duration(seconds: 3),
          content: Container(
            height: 30.0,
            child: Center(
              child: Text(
                '$text',
                style: TextStyle(fontSize: 14.0, color: Colors.white),
              ),
            ),
          ),
          backgroundColor: lightBlack(),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(10, 80, 106, 1),
          title: Text(
            'Request Assessment',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Welcome,",
                      style: TextStyle(
                          fontSize: 37, color: Color.fromRGBO(10, 80, 106, 1)),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: Text(
                      "${NewAssesmentProvider("").capitalize(name)}",
                      style: TextStyle(
                          fontSize: 37, color: Color.fromRGBO(10, 80, 106, 1)),
                    ),
                  ),
                ]),

            SizedBox(height: 20),
            // Container(
            //   child: Card(
            //     child: Text("Home Addresses resides here"),
            //   ),
            // ),
            // SizedBox(
            //   height: 20,
            // ),
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 15,
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Preferred Time:',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(3, 0, 0, 0),
                          width: MediaQuery.of(context).size.width * .4,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: _colorgreen,
                                width: 1,
                              )),
                          child: InkWell(
                            onTap: () {
                              selectTime1(context);
                            },
                            child: Row(children: [
                              Container(
                                // color: Colors.red,
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.alarm),
                              ),
                              Text(
                                '${time.hour}:${time.minute}',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(width: 10),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          'Preferred Date:',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(3, 0, 0, 0),
                          width: MediaQuery.of(context).size.width * 0.5,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: _colorgreen,
                                width: 1,
                              )),
                          child: InkWell(
                            onTap: () {
                              _selectDate(context);
                              print(date);
                            },
                            child: Row(children: [
                              Container(
                                // color: Colors.red,
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.calendar_today),
                              ),
                              SizedBox(width: 10),
                              Text(
                                '${date.day}:${date.month}:${date.year}',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(width: 10),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                height: 85,
                child: RaisedButton(
                  onPressed: () async {
                    FirebaseUser user =
                        await FirebaseAuth.instance.currentUser();
                    try {
                      // docID = await PatientRepository().saveInDatabase(user.uid,
                      //     formatTimeOfDay(time), fromDateTimeToJson(date));
                      showSnackBar(
                          context, "Assessment Scheduled Successfully");
                      print(docID);
                    } catch (e) {
                      showSnackBar(context, "Something Went Wrong");
                      print(StackTrace.current);
                    }
                    // Navigator.of(context).pushReplacement(
                    //     MaterialPageRoute(builder: (context) => Patient()));
                    print(docID);
                  },
                  color: Color.fromRGBO(10, 80, 106, 1),
                  child: Center(
                    child: Text(
                      "Request Assessment",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  textColor: Colors.white,
                ))
          ]),
        ));
  }
}
