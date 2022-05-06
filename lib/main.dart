import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tryapp/login/login.dart';
import 'package:tryapp/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Therapist/Dashboard/TherapistDetails.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  print(message.data);
  flutterLocalNotificationsPlugin.show(
      message.data.hashCode,
      message.data['title'],
      message.data['body'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channel.description,
        ),
      ));
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
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
  String token;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot dataset;
  bool loading = false;
  var data2;
  Map<String, dynamic> datasetmain = {};

  void initState() {
    // await _pushNotificationService.initialize();
    var initialzationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initialzationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: android?.smallIcon,
              ),
            ));
      }
    });
    getToken();
  }

  @override
  Widget build(BuildContext context) {
    getdocset() async {
      setState(() {
        loading = true;
      });

      dataset = await firestore.collection("fallassessmnet").get();
      // Map<String, DocumentSnapshot> datasetmaintemp = {};
      // for (int i = 0; i < dataset.docs.length; i++) {
      //   await getfielddata(
      //     dataset.docs[i]['assessee'],
      //   );
      //   datasetmaintemp["$i"] = (data2);
      // }
      Map<String, dynamic> temptry = {};
      for (int j = 0; j < dataset.docs.length; j++) {
        temptry["$j"] = dataset.docs[j].data();
      }

      setState(() {
        datasetmain = temptry;
        loading = false;
      });
      print("datasetMain: ${datasetmain}");
    }

    void _generateCsvFile() async {
      // Map<Permission, PermissionStatus> statuses = await [
      //   Permission.storage,
      // ].request();

      String directory = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_DOWNLOADS);

      await getdocset();
      List<List<dynamic>> rows = [];

      setState(() {
        List<dynamic> row = [];
        row.add("First Name");
        row.add("Last Name");
        row.add("Email");
        row.add("address");
        row.add("Gender");
        row.add("Phone Number");
        row.add("Assessment/answer");
        row.add("Value for answer");
        row.add("Score");
        rows.add(row);
        for (int i = 0; i < datasetmain.length; i++) {
          List<dynamic> row = [];
          row.add(datasetmain["$i"]["firstName"]);
          row.add(datasetmain["$i"]["lastName"]);
          row.add(dataset.docs[i]["email"]);
          row.add(dataset.docs[i]["address"]);
          row.add(dataset.docs[i]["gender"]);
          row.add(dataset.docs[i]["phoneNo"]);
          for (var j = 0; j < dataset.docs[i]["assessment"].length; j++) {
            row.add(dataset.docs[i]["assessment"][j]['answer']);
            row.add(dataset.docs[i]["assessment"][j]['value']);
          }
          row.add(dataset.docs[i]["score"]);
          rows.add(row);
        }

        String csv = const ListToCsvConverter().convert(rows);

        String file = "$directory";
        String filePath = file + "/fallAssessment.csv";
        File f = File(filePath);

        f.writeAsString(csv);
        // OpenFile.open(f.path);
      });

      // String file = "$dir";

      // File f = File(file + "/filename.csv");

      // print("csv: $csv");
    }

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
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20)),
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
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      TherapistDetails(null, null, true)));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Start Trial',
                                    style: TextStyle(
                                      color: Colors.cyan[900],
                                      fontSize: 15,
                                    )),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.navigate_next,
                                  color: Colors.cyan[900],
                                )
                              ],
                            ),
                          ),
                        ))
                      ],
                    ))
              ],
            )),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _generateCsvFile,
      //   tooltip: 'getData',
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  getToken() async {
    token = await FirebaseMessaging.instance.getToken();
    setState(() {
      token = token;
    });
    print(token);
  }

  Future login(String email, String password) async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({"token": token}, SetOptions(merge: true));
      print(
          '////////////////////////////////////////////////////////////////////////////////////////');
      if (user != null) {
        return user.uid;
      } else {
        return null;
      }
    } catch (e) {}
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Login(""),
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
