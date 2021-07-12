import 'package:flutter/material.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/patientdash.dart';

class HomeAddress extends StatefulWidget {
  @override
  _HomeAddressState createState() => _HomeAddressState();
}

class _HomeAddressState extends State<HomeAddress> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Patient()));
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(10, 80, 106, 1),
          title: Text(
            'Home Addresses',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          child: Center(
            child: Text("Home Addresses yet to be Implemented"),
          ),
        ),
      ),
    );
  }
}
