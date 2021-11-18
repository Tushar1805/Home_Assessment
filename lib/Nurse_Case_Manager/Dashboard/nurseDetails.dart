import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tryapp/Patient_Caregiver_Family/patientDetails.dart';
import 'package:tryapp/Therapist/Dashboard/TherapistDetails.dart';

import '../../constants.dart';
import '../../main.dart';

class NurseDetails extends StatefulWidget {
  final TherapistClass therapist;
  final PatientClass patient;
  final bool needTherapist;
  const NurseDetails(this.therapist, this.patient, this.needTherapist,
      {Key key})
      : super(key: key);

  @override
  _NurseDetailsState createState() => _NurseDetailsState();
}

class _NurseDetailsState extends State<NurseDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String fname, lname, email, address, phone, age, gender, uid, role;
  bool loadingPage = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var loading = false;

  void initState() {
    super.initState();
    // getUserInfo();
  }

  void showSnackBar(context, value) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 3),
      content: Container(
        height: 20.0,
        child: Center(
          child: Text(
            '$value',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
          ),
        ),
      ),
      backgroundColor: lightBlack(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  Widget _buildfName() {
    return TextFormField(
        // initialValue: (widget.patient != null) ? widget.patient.fname : "",
        decoration: formInputDecoration("Enter Your First Name"),
        validator: (String value) {
          if (value.isEmpty) {
            return 'First name is Required';
          }
          return null;
        },
        onSaved: (String value) {
          fname = value;
        });
  }

  Widget _buildlName() {
    return TextFormField(
        // initialValue: (widget.patient != null) ? widget.patient.lname : "",
        decoration: formInputDecoration("Enter Your Last Name"),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Last name is Required';
          }
          return null;
        },
        onSaved: (String value) {
          lname = value;
        });
  }

  Widget _buildEmail() {
    return TextFormField(
        // initialValue: (widget.patient != null) ? widget.patient.email : "",
        decoration: formInputDecoration("Enter Email Address (Username)"),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Email is Required';
          }
          if (!RegExp(
                  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
              .hasMatch(value)) {
            return 'Please Enter a valid Email Address';
          }
          return null;
        },
        onSaved: (String value) {
          email = value;
        });
  }

  Widget _buildPhone() {
    return TextFormField(
        // initialValue: (widget.patient != null) ? widget.patient.mobile : "",
        keyboardType: TextInputType.phone,
        decoration: formInputDecoration("Enter Mobile Number"),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Phone Number is Required';
          }
          return null;
        },
        onSaved: (String value) {
          phone = value;
        });
  }

  Widget _buildAddress() {
    return TextFormField(
        // initialValue: (widget.patient != null) ? widget.patient.address : "",
        decoration: formInputDecoration("Enter Hospital Address"),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Address is Required';
          }
          return null;
        },
        onSaved: (String value) {
          address = value;
        });
  }

  Widget _buildAge() {
    return TextFormField(
        // initialValue: (widget.patient != null) ? widget.patient.age : "",
        keyboardType: TextInputType.number,
        decoration: formInputDecoration("Enter Age"),
        // ignore: missing_return
        validator: (String value) {
          int age = int.tryParse(value);
          if (age == null || age <= 0) {
            return 'Age is Required';
          }
          return null;
        },
        onSaved: (String value) {
          age = value;
        });
  }

  Widget _buildGender() {
    return Container(
      child: DropdownButtonFormField<String>(
        // value: (widget.patient != null) ? widget.patient.gender : "",
        decoration: formInputDecoration("Select Gender"),
        items: <String>[
          'Male',
          'Female',
          'Other',
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: new Text(value),
            onTap: () {
              gender = value;
            },
          );
        }).toList(),
        onChanged: (_) {},
      ),
    );
  }

  Future<bool> checkIfEmailInUse(String emailAddress) async {
    try {
      // Fetch sign-in methods for the email address
      final list =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailAddress);

      // In case list is not empty
      if (list.isNotEmpty) {
        // Return true because there is an existing
        // user using the email address
        return true;
      } else {
        // Return false because email adress is not in use
        return false;
      }
    } catch (error) {
      // Handle error
      // ...
      return true;
    }
  }

  NurseClass nurseDetails() {
    setState(() {
      loadingPage = true;
    });
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return null;
    } else {
      final nurse = NurseClass(
        fname: fname,
        lname: lname,
        email: email,
        role: "nurse/case manager",
        address: address,
        mobile: phone,
        age: age,
        // gender: gender,
      );

      // therapistDetails(therapist, uid);
      // setState(() {
      //   showSubmitDialog(true);
      //   loadingPage = false;
      // });
      return nurse;
    }
  }

  scheduleAssessment(String therapistUid, String patientUid, String assessor) {
    var doc = firestore.collection("assessments").doc().id;

    firestore.collection("assessments").doc(doc).set({
      "therapist": therapistUid,
      "patient": patientUid,
      "assessor": assessor,
      'docID': doc,
      'date': DateTime.now(),
      'status': 'new',
      'home': widget.patient.address,
      'currentStatus': "Assessment Scheduled",
    }).then((value) => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyHomePage())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color.fromRGBO(10, 80, 106, 1), // status bar color
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light, //status bar brigtness
        ),
        flexibleSpace: Container(
          width: MediaQuery.of(context).size.width,
          child: new Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 10, bottom: 10.0),
            child: Row(
              children: [
                IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                SizedBox(
                  width: 10.0,
                ),
                Text('Case Manager Details', style: titleBarWhiteTextStyle()),
              ],
            ),
          ),
          decoration: new BoxDecoration(color: Color.fromRGBO(10, 80, 106, 1)),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Container(
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Stack(children: [
              SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildfName(),
                      SizedBox(
                        height: 15,
                      ),
                      _buildlName(),
                      SizedBox(
                        height: 15,
                      ),
                      _buildEmail(),
                      SizedBox(
                        height: 15,
                      ),
                      // _buildPhone(),
                      // SizedBox(
                      //   height: 15,
                      // ),
                      _buildAddress(),
                      SizedBox(
                        height: 15,
                      ),
                      _buildPhone(),
                      SizedBox(
                        height: 15,
                      ),
                      _buildAge(),
                      SizedBox(
                        height: 15,
                      ),
                      // _buildGender(),
                      // SizedBox(
                      //   height: 50,
                      // ),
                    ]),
              ),
              Container(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // TextButton(
                    //   onPressed: () async {
                    //     if (!_formKey.currentState.validate()) {
                    //       return;
                    //     }
                    //     _formKey.currentState.save();

                    //     NurseClass patient = nurseDetails();
                    //     bool check = await checkIfEmailInUse(patient.email);

                    //     check
                    //         ? showSnackBar(context,
                    //             "Email already exists use a different email address")
                    //         : Navigator.of(context).push(MaterialPageRoute(
                    //             builder: (context) => TherapistDetails(
                    //                 widget.therapist, patient)));
                    //   },
                    //   child: Container(
                    //     width: MediaQuery.of(context).size.width * 0.38,
                    //     height: 40.0,
                    //     decoration: new BoxDecoration(
                    //       color: Color.fromRGBO(10, 80, 106, 1),
                    //       borderRadius: BorderRadius.all(
                    //         Radius.circular(5.0),
                    //       ),
                    //     ),
                    //     child: Center(
                    //       child: Text(
                    //         'Previous',
                    //         style: whiteTextStyle().copyWith(
                    //             fontSize: 15.0, fontWeight: FontWeight.w600),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        if (!_formKey.currentState.validate()) {
                          return;
                        }
                        _formKey.currentState.save();

                        NurseClass nurse = nurseDetails();
                        bool check = await checkIfEmailInUse(nurse.email);

                        if (check) {
                          showSnackBar(context,
                              "Email already exists use a different email address");
                        } else {
                          User therapist, patient, nurseUser;
                          if (widget.needTherapist) {
                            await auth
                                .createUserWithEmailAndPassword(
                                    email: widget.therapist.email,
                                    password: "123456")
                                .then((value) => therapist = value.user);
                            firestore
                                .collection("users")
                                .doc(therapist.uid)
                                .set(widget.therapist.toJson(),
                                    SetOptions(merge: true));
                          }

                          await auth
                              .createUserWithEmailAndPassword(
                                  email: widget.patient.email,
                                  password: "123456")
                              .then((value) => patient = value.user);
                          await auth
                              .createUserWithEmailAndPassword(
                                  email: nurse.email, password: "123456")
                              .then((value) => nurseUser = value.user);

                          firestore.collection("users").doc(patient.uid).set(
                              widget.patient.toJson(), SetOptions(merge: true));
                          firestore
                              .collection("users")
                              .doc(nurseUser.uid)
                              .set(nurse.toJson(), SetOptions(merge: true));

                          (widget.needTherapist)
                              ? scheduleAssessment(
                                  therapist.uid, patient.uid, nurseUser.uid)
                              : scheduleAssessment(
                                  "KFJgI4NcS5VmpWvk2fb8Kk2fhXE3",
                                  patient.uid,
                                  nurseUser.uid);
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 40.0,
                        decoration: new BoxDecoration(
                          color: Color.fromRGBO(10, 80, 106, 1),
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                        child: Center(
                          child: (!loading)
                              ? Text(
                                  'Schedule Assessment',
                                  style: whiteTextStyle().copyWith(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600),
                                )
                              : Container(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          )),
    );
  }
}

class NurseClass {
  String fname, lname, role, address, mobile, email, age, gender, isNewUser;

  NurseClass(
      {this.fname,
      this.lname,
      this.role,
      this.email,
      this.address,
      this.mobile,
      this.age,
      // this.gender,
      this.isNewUser = "true"});

  Map<String, dynamic> toJson() => {
        'firstName': fname,
        'lastName': lname,
        'email': email,
        'role': role,
        'mobile': mobile,
        'address': address,
        'age': age,
        // 'gender': gender,
        'newUser': isNewUser
      };

  static NurseClass fromJson(Map<String, dynamic> json) => NurseClass(
        fname: json['firstName'],
        lname: json['lastName'],
        email: json['email'],
        role: json['role'],
        mobile: json['mobile'],
        address: json['address'],
        age: json['age'],
        // gender: json['gender'],
        isNewUser: json['newUser'],
      );
}
