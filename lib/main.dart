import 'package:flutter/material.dart';
import 'package:tryapp/login/login.dart';
import 'package:tryapp/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(10, 80, 106, 1),
      body: Center(
        // decoration: new BoxDecoration(
        //   color: Colors.white,
        //   ,
        // ),
        child: Column(
          children: [
            Container(
                child: Column(
              children: [
                Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * .5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      // color: Colors.lightGreen[600].withOpacity(0.7),
                      // image: DecorationImage(
                      //     image: AssetImage('assets/piclog.png'),
                      //     fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Image.asset(
                          'assets/logo.png',
                          width: 174.0,
                          height: 174.0,
                        ),
                      ),
                    )),
                Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * .5,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 130,
                        ),
                        Container(
                            child: SizedBox(
                          width: 230,
                          height: 50,
                          child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              padding: EdgeInsets.all(10),
                              color: Colors.lightGreen[800],
                              onPressed: () {
                                Navigator.of(context).push(
                                    // context,
                                    // MaterialPageRoute(
                                    //     builder: (context) => Login())
                                    _createRoute());
                              },
                              child: Text('Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ))),
                        )),
                        SizedBox(height: 10),
                        Container(
                            child: SizedBox(
                          width: 230,
                          height: 50,
                          child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                // side: BorderSide(color: Colors.red)
                              ),
                              padding: EdgeInsets.all(10),
                              color: Colors.white,
                              onPressed: () {},
                              child: Text('Sign Up',
                                  style: TextStyle(
                                    color: Colors.cyan[900],
                                    fontSize: 15,
                                  ))),
                        ))
                      ],
                    ))
              ],
            )),
          ],
        ),
      ),
    );
  }

  Future login(String email, String password) async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser useer = result.user;
      print(
          '////////////////////////////////////////////////////////////////////////////////////////');
      if (useer != null) {
        return useer.uid;
      } else {
        return null;
      }
    } catch (e) {}
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Login(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
