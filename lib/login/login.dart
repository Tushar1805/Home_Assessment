import 'package:flutter/material.dart';
import './loginUI.dart';
import 'loginpro.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class Login extends StatelessWidget {
  var pass;
  Login(this.pass);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ChangeNotifierProvider<LoginProvider>(
      create: (_) => LoginProvider(),
      child: LoginForm(pass),
    )));
  }
}
