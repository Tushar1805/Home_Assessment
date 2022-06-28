import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tryapp/Assesment/newassesment/scheduleAssessment.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/patientdash.dart';
import 'package:tryapp/Therapist/Dashboard/TherapistDetails.dart';

import '../constants.dart';

class PatientDetails extends StatefulWidget {
  final TherapistClass therapist;
  final PatientClass patient;
  final bool needTherapist;
  PatientDetails(this.therapist, this.patient, this.needTherapist, {Key key})
      : super(key: key);

  @override
  _PatientDetailsState createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String fname,
      lname,
      email,
      address1 = "",
      address2 = "",
      phone,
      age,
      gender,
      uid,
      role;
  bool loadingPage = false;

  void initState() {
    super.initState();
    // getUserInfo();
  }

  getUserInfo() async {
    User curUser = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(curUser.uid)
        .get()
        .then((value) => setState(() {
              role = value["role"];
              uid = curUser.uid;
            }));
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
        initialValue: (widget.patient != null) ? widget.patient.fname : "",
        decoration: formInputDecoration("Enter Patient's First Name"),
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
        initialValue: (widget.patient != null) ? widget.patient.lname : "",
        decoration: formInputDecoration("Enter Patient's Last Name"),
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
        initialValue: (widget.patient != null) ? widget.patient.email : "",
        decoration:
            formInputDecoration("Enter Patient's Email Address (Username)"),
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
        initialValue: (widget.patient != null) ? widget.patient.mobile : "",
        keyboardType: TextInputType.phone,
        decoration: formInputDecoration("Enter Patient's Mobile Number"),
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

  Widget _buildAddress1(var text) {
    return TextFormField(
        initialValue: (widget.patient != null) ? widget.patient.address : "",
        decoration: formInputDecoration(text),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Address Line 1 is Required';
          }
          return null;
        },
        onSaved: (String value) {
          address1 = value;
        });
  }

  Widget _buildAddress2(var text) {
    return TextFormField(
        initialValue: (widget.patient != null) ? widget.patient.address : "",
        decoration: formInputDecoration(text),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Address Line 2 is Required';
          }
          return null;
        },
        onSaved: (String value) {
          address2 = value;
        });
  }

  Widget _buildAge() {
    return TextFormField(
        initialValue: (widget.patient != null) ? widget.patient.age : "",
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

  // Widget _buildGender() {
  //   return TextFormField(
  //       decoration: formInputDecoration("Enter Gender"),
  //       validator: (String value) {
  //         if (value.isEmpty) {
  //           return 'Gender is Required';
  //         }
  //         return null;
  //       },
  //       onSaved: (String value) {
  //         gender = value;
  //       });
  // }

  void showSubmitDialog(bool isSuccess) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
                child: Text(
              isSuccess ? 'Success' : 'Error',
              style: lightBlackTextStyle().copyWith(fontSize: 18),
            )),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                      isSuccess
                          ? 'Profile updated successfully!'
                          : 'Something went wrong! try again...',
                      style:
                          normalTextStyle().copyWith(color: redOrangeColor())),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: FlatButton(
                  onPressed: () {
                    if (isSuccess) {
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    width: MediaQuery.of(context).size.width / 3,
                    decoration: new BoxDecoration(
                      gradient: new LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            redOrangeColor(),
                            redOrangeColor(),
                            orangeColor()
                          ]),
                      borderRadius: BorderRadius.all(
                        Radius.circular(40.0),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'OK',
                        style: whiteTextStyle().copyWith(
                            fontSize: 15.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        });
  }

  // Future<void> therapistDetails(TherapistClass user, String uid) async {
  //   final docTodo = FirebaseFirestore.instance.collection('Users').doc(uid);

  //   await docTodo.update(user.toJson());
  // }

  PatientClass patientDetails() {
    setState(() {
      loadingPage = true;
    });
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return null;
    } else {
      final patient = PatientClass(
        fname: fname,
        lname: lname,
        email: email,
        role: "patient",
        address: address1 + ', ' + address2,
        mobile: phone,
        age: age,
        // gender: gender,
      );

      // therapistDetails(therapist, uid);
      // setState(() {
      //   showSubmitDialog(true);
      //   loadingPage = false;
      // });
      return patient;
    }
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
            padding: const EdgeInsets.only(left: 10.0, top: 40, bottom: 10.0),
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
                Text('Patient Details', style: titleBarWhiteTextStyle()),
              ],
            ),
          ),
          decoration: new BoxDecoration(color: Color.fromRGBO(10, 80, 106, 1)),
        ),
        foregroundColor: Color.fromRGBO(10, 80, 106, 1),
        backgroundColor: Color.fromRGBO(10, 80, 106, 1),
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
          child: Container(
        // height: MediaQuery.of(context).size.height * 0.8,
        margin: EdgeInsets.all(24),
        child: Column(children: [
          Form(
            key: _formKey,
            // child: Stack(children: [
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
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
              _buildAddress1("Enter Home Address Line 1"),
              SizedBox(
                height: 15,
              ),
              _buildAddress2("Enter Home Address Line 2"),
              SizedBox(
                height: 15,
              ),
              _buildPhone(),
              SizedBox(
                height: 15,
              ),
              _buildAge(),
              // SizedBox(
              //   height: 15,
              // ),
              // _buildGender(),
              // SizedBox(
              //   height: 50,
              // ),
            ]),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    if (!_formKey.currentState.validate()) {
                      return;
                    }
                    _formKey.currentState.save();

                    PatientClass patient = patientDetails();
                    bool check = await checkIfEmailInUse(patient.email);

                    check
                        ? showSnackBar(context,
                            "Email already exists use a different email address")
                        : Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => TherapistDetails(
                                widget.therapist,
                                patient,
                                widget.needTherapist)));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.38,
                    height: 40.0,
                    decoration: new BoxDecoration(
                      color: Color.fromRGBO(10, 80, 106, 1),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Previous',
                        style: whiteTextStyle().copyWith(
                            fontSize: 15.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (!_formKey.currentState.validate()) {
                      return;
                    }
                    _formKey.currentState.save();

                    PatientClass patient = patientDetails();
                    bool check = await checkIfEmailInUse(patient.email);

                    check
                        ? showSnackBar(context,
                            "Email already exists use a different email address")
                        : Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => ScheduleAssessment(
                                    widget.therapist,
                                    patient,
                                    widget.needTherapist)));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.38,
                    height: 40.0,
                    decoration: new BoxDecoration(
                      color: Color.fromRGBO(10, 80, 106, 1),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Next',
                        style: whiteTextStyle().copyWith(
                            fontSize: 15.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ]),
      )),
    );
  }
}

class PatientClass {
  String fname, lname, role, address, mobile, email, age, gender, isNewUser;

  PatientClass(
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

  static PatientClass fromJson(Map<String, dynamic> json) => PatientClass(
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
