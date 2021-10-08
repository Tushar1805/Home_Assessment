import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/patientdashprov.dart';
import 'package:tryapp/rating.dart';

import '../../constants.dart';

class FeedbackDialogWidget extends StatefulWidget {
  String therapistUid, patientUid, docID;
  PatientProvider pro;
  FeedbackDialogWidget(
      this.therapistUid, this.patientUid, this.docID, this.pro);
  @override
  _FeedbackDialogWidgetState createState() => _FeedbackDialogWidgetState();
}

class _FeedbackDialogWidgetState extends State<FeedbackDialogWidget> {
  final _formkey = GlobalKey<FormState>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String feedback = '';
  String uid = FirebaseAuth.instance.currentUser.uid;
  User user = FirebaseAuth.instance.currentUser;
  int stars;
  String desc;
  List<Map<String, dynamic>> list = [];
  bool loading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getFeedback();
  }

  void getFeedback() async {
    setState(() {
      loading = true;
    });
    User user = FirebaseAuth.instance.currentUser;
    await firestore
        .collection("users")
        .doc(widget.therapistUid)
        .get()
        .then((value) {
      if (value.data().containsKey("feedback")) {
        if (value.data()["feedback"].length > 0) {
          setState(() {
            list = List<Map<String, dynamic>>.generate(
                value.data()["feedback"].length,
                (int index) => Map<String, dynamic>.from(
                    value.data()["feedback"].elementAt(index)));
          });
          loop:
          for (var i = 0; i < list.length; i++) {
            if (list[i]["patient"] == user.uid &&
                list[i]['docID'] == widget.docID) {
              setState(() {
                desc = list[i]["feedback"];
                widget.pro.stars = list[i]["rating"];
              });
              break loop;
            } else {
              setState(() {
                desc = "";
                widget.pro.stars = 0;
              });
            }
          }
        }
      } else {
        firestore
            .collection("users")
            .doc(widget.therapistUid)
            .set({"feedback": ""}, SetOptions(merge: true));
      }
      // print(list);
    });
    // print("desc: $desc");
    setState(() {
      loading = false;
      stars = widget.pro.stars;
    });
  }

  void _showSnackBar(snackbar, BuildContext buildContext) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 3),
      content: Container(
        height: 30.0,
        child: Center(
          child: Text(
            '$snackbar',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
          ),
        ),
      ),
      backgroundColor: lightBlack(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
    );
    ScaffoldMessenger.of(buildContext)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void _showAnotherSnackBar() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Your feedback is valuable to improve us"),
    ));
  }

  Widget buildDescription() => TextFormField(
        maxLines: 6,
        initialValue: desc.toString() ?? "",
        onChanged: (feedback) => setState(() => desc = feedback),
        validator: (feedback) {
          if (feedback.isEmpty) {
            _showSnackBar("Feedback cannot be empty", this.context);
          }
          return null;
        },
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromRGBO(10, 80, 106, 1), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1),
          ),
          // isDense: true,
        ),
      );

  Widget buildButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Color.fromRGBO(10, 80, 106, 1)),
          ),
          onPressed: save,
          child: Text(
            "Save",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return (loading)
        ? Center(child: CircularProgressIndicator())
        : AlertDialog(
            key: _scaffoldKey,
            content: Form(
              key: _formkey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feedback For Therapist',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color.fromRGBO(10, 80, 106, 1),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  // FeedbackFormWidget(
                  //   rating: widget.pro.stars ?? 0,
                  //   feedback: desc ?? "",
                  //   onChangedFeedback: (feedback) =>
                  //       setState(() => desc = feedback),
                  //   onSavedFeedback: save,
                  //   context: context,
                  //   pro: widget.pro,
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.06,
                        width: MediaQuery.of(context).size.width * 0.56,
                        color: Colors.white,
                        // decoration: BoxDecoration(
                        //   borderRadius: BorderRadius.circular(10),
                        //   color: Colors.white,
                        // ),
                        // padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                        child: StarRating(
                          rating: stars ?? 0,
                          onRatingChanged: (rating) =>
                              setState(() => stars = rating),
                          color: Color(0xffffbb20),
                          iconSize: 35.0,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.08,
                        child: Text(
                          "$stars/5",
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  buildDescription(),
                  SizedBox(
                    height: 20,
                  ),
                  buildButton(),
                ],
              ),
            ),
          );
  }

  void save() {
    bool hide = false;
    final isValid = _formkey.currentState.validate();
    if (desc == "" && widget.pro.stars == 0) {
      _showSnackBar("Your feedback is valuable to improve us", context);
    } else {
      loop:
      for (var i = 0; i < list.length; i++) {
        if (list[i]["patient"] == user.uid &&
            list[i]['docID'] == widget.docID) {
          list[i]["feedback"] = desc;
          list[i]["rating"] = stars;
          list[i]["timing"] = Timestamp.now();

          // final provider = Provider.of<TodoProvider>(context, listen: false);
          widget.pro.setFeedback(widget.therapistUid, list);
          Navigator.of(context).pop();
          _showSnackBar("Thank you for your feedback", context);
          setState(() {
            hide = true;
          });
          break loop;
        }
      }
      if (!hide) {
        final _feedback = {
          "feedback": desc,
          "patient": widget.patientUid,
          "therapist": widget.therapistUid,
          "docID": widget.docID,
          "time": Timestamp.now(),
          "rating": stars,
        };
        list.add(_feedback);

        // final provider = Provider.of<TodoProvider>(context, listen: false);
        widget.pro.setFeedback(widget.therapistUid, list);
        Navigator.of(context).pop();
        _showSnackBar("Thank you for your feedback", context);
      }
    }
  }
}

// class FeedbackFormWidget extends StatefulWidget {
//   final String feedback;
//   final ValueChanged<String> onChangedFeedback;
//   final VoidCallback onSavedFeedback;
//   final BuildContext context;
//   int rating;
//   PatientProvider pro;
//   // int stars;

//   FeedbackFormWidget(
//       {Key key,
//       this.feedback,
//       this.rating,
//       @required this.onChangedFeedback,
//       @required this.onSavedFeedback,
//       @required this.context,
//       this.pro})
//       : super(key: key);

//   @override
//   _FeedbackFormWidgetState createState() => _FeedbackFormWidgetState();
// }

// class _FeedbackFormWidgetState extends State<FeedbackFormWidget> {
//   int stars = 0;
//   void _showSnackBar(snackbar, BuildContext buildContext) {
//     final snackBar = SnackBar(
//       duration: const Duration(seconds: 3),
//       content: Container(
//         height: 30.0,
//         child: Center(
//           child: Text(
//             '$snackbar',
//             style: TextStyle(fontSize: 14.0, color: Colors.white),
//           ),
//         ),
//       ),
//       backgroundColor: lightBlack(),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
//     );
//     ScaffoldMessenger.of(buildContext)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(snackBar);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // print("widget.feedback : ${widget.feedback}");
//     setState(() {
//       // stars = widget.rating;
//       widget.pro.stars = widget.rating;
//     });
//     print("stars : $stars");
//     return SingleChildScrollView(
//       child: Column(
//         // mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             height: MediaQuery.of(context).size.height * 0.06,
//             width: MediaQuery.of(context).size.width * 0.8,
//             color: Colors.white,
//             // decoration: BoxDecoration(
//             //   borderRadius: BorderRadius.circular(10),
//             //   color: Colors.white,
//             // ),
//             // padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
//             child: StarRating(
//               rating: stars ?? 0,
//               onRatingChanged: (rating) => setState(() => stars = rating),
//               color: Color(0xffffbb20),
//               iconSize: 40.0,
//             ),
//           ),
//           buildDescription(),
//           SizedBox(
//             height: 20,
//           ),
//           buildButton(),
//         ],
//       ),
//     );
//   }

//   Widget buildDescription() => TextFormField(
//         maxLines: 6,
//         initialValue: widget.feedback.toString() ?? "",
//         onChanged: widget.onChangedFeedback,
//         validator: (feedback) {
//           if (feedback.isEmpty) {
//             _showSnackBar("Feedback cannot be empty", this.context);
//           }
//           return null;
//         },
//         decoration: InputDecoration(
//           focusedBorder: OutlineInputBorder(
//             borderSide:
//                 BorderSide(color: Color.fromRGBO(10, 80, 106, 1), width: 1),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(width: 1),
//           ),
//           // isDense: true,
//         ),
//       );

//   Widget buildButton() => SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           style: ButtonStyle(
//             backgroundColor:
//                 MaterialStateProperty.all(Color.fromRGBO(10, 80, 106, 1)),
//           ),
//           onPressed: widget.onSavedFeedback,
//           child: Text(
//             "Save",
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       );
// }

// class FeedbackFormWidget extends StatelessWidget {
//   final String feedback;
//   final ValueChanged<String> onChangedFeedback;
//   final VoidCallback onSavedFeedback;
//   final BuildContext context;
//   final double rating;

//   const FeedbackFormWidget({
//     Key key,
//     this.feedback = '',
//     this.rating,
//     @required this.onChangedFeedback,
//     @required this.onSavedFeedback,
//     @required this.context,
//   }) : super(key: key);

//   void _showSnackBar(snackbar, BuildContext buildContext) {
//     final snackBar = SnackBar(
//       duration: const Duration(seconds: 3),
//       content: Container(
//         height: 30.0,
//         child: Center(
//           child: Text(
//             '$snackbar',
//             style: TextStyle(fontSize: 14.0, color: Colors.white),
//           ),
//         ),
//       ),
//       backgroundColor: lightBlack(),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
//     );
//     ScaffoldMessenger.of(buildContext)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(snackBar);
//   }

//   @override
//   Widget build(BuildContext context) {
//     double stars = this.rating;
//     return SingleChildScrollView(
//       child: Column(
//         // mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             height: MediaQuery.of(context).size.height * 0.06,
//             width: MediaQuery.of(context).size.width * 0.8,
//             color: Colors.white,
//             // decoration: BoxDecoration(
//             //   borderRadius: BorderRadius.circular(10),
//             //   color: Colors.white,
//             // ),
//             // padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
//             child: StarRating(
//               rating: stars ?? 0,
//               onRatingChanged: (rating) {
//                 stars = rating;
//               },
//               color: Color(0xffffbb20),
//               iconSize: 40.0,
//             ),
//           ),
//           buildDescription(),
//           SizedBox(
//             height: 20,
//           ),
//           buildButton(),
//         ],
//       ),
//     );
//   }

//   // Widget buildTitle() => TextFormField(
//   //       maxLines: 1,
//   //       initialValue: title,
//   //       onChanged: onChangedTitle,
//   //       validator: (title) {
//   //         if (title.isEmpty) {
//   //           return 'The title cannot be empty';
//   //         }
//   //         return null;
//   //       },
//   //       decoration: InputDecoration(
//   //         border: UnderlineInputBorder(),
//   //         labelText: 'Title',
//   //       ),
//   //     );
//   Widget buildDescription() => TextFormField(
//         maxLines: 6,
//         initialValue: feedback,
//         onChanged: onChangedFeedback,
//         validator: (feedback) {
//           if (feedback.isEmpty) {
//             _showSnackBar("Feedback cannot be empty", this.context);
//           }
//           return null;
//         },
//         decoration: InputDecoration(
//           focusedBorder: OutlineInputBorder(
//             borderSide:
//                 BorderSide(color: Color.fromRGBO(10, 80, 106, 1), width: 1),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(width: 1),
//           ),
//           // isDense: true,
//         ),
//       );

//   Widget buildButton() => SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           style: ButtonStyle(
//             backgroundColor:
//                 MaterialStateProperty.all(Color.fromRGBO(10, 80, 106, 1)),
//           ),
//           onPressed: onSavedFeedback,
//           child: Text(
//             "Save",
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       );
// }

class FeedbackThera {
  String feedback;
  String patient;
  String therapist;
  double rating;
  Timestamp time;

  FeedbackThera({
    this.feedback,
    this.patient,
    this.therapist,
    this.rating,
    this.time,
  });

  static FeedbackThera fromJson(Map<String, dynamic> json) => FeedbackThera(
        feedback: json['feedback'],
        patient: json['patientUid'],
        therapist: json['therapsitUid'],
        rating: json['rating'],
        time: json['time'],
      );

  Map<String, dynamic> toJson() => {
        'feedback': feedback,
        'patientUid': patient,
        'therapistUid': therapist,
        'rating': rating,
        'time': time,
      };
}
