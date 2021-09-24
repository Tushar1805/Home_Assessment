import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/patientdashprov.dart';

import '../../constants.dart';

class FeedbackDialogWidget extends StatefulWidget {
  String therapistUid, patientUid;
  PatientProvider pro;
  FeedbackDialogWidget(this.therapistUid, this.patientUid, this.pro);
  @override
  _FeedbackDialogWidgetState createState() => _FeedbackDialogWidgetState();
}

class _FeedbackDialogWidgetState extends State<FeedbackDialogWidget> {
  final _formkey = GlobalKey<FormState>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String feedback = '';
  String uid = FirebaseAuth.instance.currentUser.uid;
  List<Map<String, dynamic>> list = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getFeedback();
  }

  void getFeedback() async {
    await firestore
        .collection("users")
        .doc(widget.therapistUid)
        .get()
        .then((value) {
      if (value.data()["feedback"].length > 0) {
        setState(() {
          list = List<Map<String, dynamic>>.generate(
              value.data()["feedback"].length,
              (int index) => Map<String, dynamic>.from(
                  value.data()["feedback"].elementAt(index)));
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
              height: 8,
            ),
            FeedbackFormWidget(
              onChangedFeedback: (feedback) =>
                  setState(() => this.feedback = feedback),
              onSavedFeedback: save,
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  void save() {
    final isValid = _formkey.currentState.validate();
    if (feedback == "") {
      _showSnackBar("Your feedback is valuable to improve us", context);
    } else {
      final _feedback = {
        "feedback": feedback,
        "patient": widget.patientUid,
        "therapist": widget.therapistUid,
        "time": Timestamp.now(),
      };
      list.add(_feedback);

      // final provider = Provider.of<TodoProvider>(context, listen: false);
      widget.pro.setFeedback(widget.therapistUid, list);
      Navigator.of(context).pop();
      _showSnackBar("Thank you for your feedback", context);
    }
  }
}

class FeedbackFormWidget extends StatelessWidget {
  final String feedback;
  final ValueChanged<String> onChangedFeedback;
  final VoidCallback onSavedFeedback;
  final BuildContext context;

  const FeedbackFormWidget({
    Key key,
    this.feedback = '',
    @required this.onChangedFeedback,
    @required this.onSavedFeedback,
    @required this.context,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildDescription(),
          SizedBox(
            height: 20,
          ),
          buildButton(),
        ],
      ),
    );
  }

  // Widget buildTitle() => TextFormField(
  //       maxLines: 1,
  //       initialValue: title,
  //       onChanged: onChangedTitle,
  //       validator: (title) {
  //         if (title.isEmpty) {
  //           return 'The title cannot be empty';
  //         }
  //         return null;
  //       },
  //       decoration: InputDecoration(
  //         border: UnderlineInputBorder(),
  //         labelText: 'Title',
  //       ),
  //     );
  Widget buildDescription() => TextFormField(
        maxLines: 6,
        initialValue: feedback,
        onChanged: onChangedFeedback,
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
          onPressed: onSavedFeedback,
          child: Text(
            "Save",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
}

class FeedbackThera {
  String feedback;
  String patient;
  String therapist;
  Timestamp time;

  FeedbackThera({
    this.feedback,
    this.patient,
    this.therapist,
    this.time,
  });

  static FeedbackThera fromJson(Map<String, dynamic> json) => FeedbackThera(
        feedback: json['feedback'],
        patient: json['patientUid'],
        therapist: json['therapsitUid'],
        time: json['time'],
      );

  Map<String, dynamic> toJson() => {
        'feedback': feedback,
        'patientUid': patient,
        'therapistUid': therapist,
        'time': time,
      };
}
