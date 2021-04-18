import 'package:flutter/material.dart';
import './loginUI.dart';
import 'loginpro.dart';
import 'package:provider/provider.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ChangeNotifierProvider<LoginProvider>(
      create: (_) => LoginProvider(),
      child: LoginForm(),
      //
    )));
  }
}
