import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/oldassessments/oldassessmentsbase.dart';
import 'package:tryapp/splash/assesment.dart';

class MidASSESS extends StatefulWidget {
  @override
  _MidASSESSState createState() => _MidASSESSState();
}

class _MidASSESSState extends State<MidASSESS> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assessment'),
        backgroundColor: Color.fromRGBO(10, 80, 106, 1),
      ),
      body: Container(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 60,
              child: RaisedButton(
                  color: Color.fromRGBO(10, 80, 106, 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(color: Color.fromRGBO(10, 80, 106, 1))),
                  child: Text(
                    "Old Assessments",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OldAssessments()));
                  }),
            ),
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 60,
              child: RaisedButton(
                color: Color.fromRGBO(10, 80, 106, 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(color: Color.fromRGBO(10, 80, 106, 1))),
                child: Text(
                  "New Assessments",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AssesmentSplashScreen()));
                },
              ),
            )
          ],
        ),
      )),
    );
  }
}
