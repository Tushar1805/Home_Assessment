import 'package:flutter/material.dart';

class HomeAddress extends StatefulWidget {
  @override
  _HomeAddressState createState() => _HomeAddressState();
}

class _HomeAddressState extends State<HomeAddress> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(10, 80, 106, 1),
        title: Text(
          'Home Addresses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        child: Center(
          child: Text("Home Addresses to be Implemented Here"),
        ),
      ),
    );
  }
}
