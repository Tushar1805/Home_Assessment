import 'package:flutter/material.dart';

class ProvideMedicalHistory extends StatefulWidget {
  @override
  _ProvideMedicalHistoryState createState() => _ProvideMedicalHistoryState();
}

class _ProvideMedicalHistoryState extends State<ProvideMedicalHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(10, 80, 106, 1),
        title: Text(
          'Provide Medical History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        child: Center(
          child: Text("Provide Medical History is to be Implementted Here"),
        ),
      ),
    );
  }
}
