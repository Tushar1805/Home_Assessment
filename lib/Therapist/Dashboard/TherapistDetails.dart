import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tryapp/Patient_Caregiver_Family/patientDetails.dart';

import '../../constants.dart';

class TherapistDetails extends StatefulWidget {
  final TherapistClass therapist;
  final PatientClass patient;
  bool needTherapist;
  TherapistDetails(this.therapist, this.patient, this.needTherapist, {Key key})
      : super(key: key);

  @override
  _TherapistDetailsState createState() => _TherapistDetailsState();
}

class _TherapistDetailsState extends State<TherapistDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String fname, lname, email, address, phone, age, gender, uid, role;
  bool loadingPage = false;
  var _groupValue = -1;

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
        initialValue: (widget.therapist != null) ? widget.therapist.fname : "",
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
        initialValue: (widget.therapist != null) ? widget.therapist.lname : "",
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
        initialValue: (widget.therapist != null) ? widget.therapist.email : "",
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
        initialValue: (widget.therapist != null) ? widget.therapist.mobile : "",
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
        initialValue:
            (widget.therapist != null) ? widget.therapist.address : "",
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
        initialValue: (widget.therapist != null) ? widget.therapist.age : "",
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
        // value: (widget.therapist != null) ? widget.therapist.gender : "",
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
                          ? 'Profile Updated Successfully!'
                          : 'Something Went Wrong! Try Again...',
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

  TherapistClass therapistDetails() {
    setState(() {
      loadingPage = true;
    });
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return null;
    } else {
      final therapist = TherapistClass(
        fname: fname,
        lname: lname,
        email: email,
        role: "therapist",
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
      return therapist;
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
        toolbarHeight: 72,
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
                Text('Therapist Details', style: titleBarWhiteTextStyle()),
              ],
            ),
          ),
          decoration: new BoxDecoration(color: Color.fromRGBO(10, 80, 106, 1)),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Container(
            height: MediaQuery.of(context).size.height,
            margin: EdgeInsets.all(24),
            child: Column(
              children: [
                // Container(
                //   padding: EdgeInsets.all(10),
                //   child: Text(
                //     "Choose which therapist you want.",
                //     style: TextStyle(
                //         fontSize: 18, color: Color.fromRGBO(10, 80, 106, 1)),
                //   ),
                // ),
                RadioListTile(
                  value: 0,
                  groupValue: _groupValue,
                  title: Text("I need a therapist from BHBS"),
                  onChanged: (newValue) => setState(() {
                    // assessor = newValue;
                    _groupValue = 0;
                  }),
                  activeColor: Colors.blue,
                ),
                RadioListTile(
                  value: 1,
                  groupValue: _groupValue,
                  title: Text("My Therapist"),
                  onChanged: (newValue) => setState(() {
                    // assessor = newValue;
                    _groupValue = 1;
                  }),
                  activeColor: Colors.blue,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.595,
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(children: [
                          (_groupValue != 0)
                              ? Form(
                                  key: _formKey,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                        // _buildAge(),
                                        // SizedBox(
                                        //   height: 15,
                                        // ),
                                        // _buildGender(),
                                        // SizedBox(
                                        //   height: 50,
                                        // ),
                                      ]),
                                )
                              : SizedBox(),
                        ]),
                      ),
                      // Positioned(
                      // top: MediaQuery.of(context).size.height * 0.52,
                      // left: MediaQuery.of(context).size.width * 0.4,
                      Container(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () async {
                            if (_groupValue == 0) {
                              setState(() {
                                widget.needTherapist = false;
                              });
                            } else {
                              setState(() {
                                widget.needTherapist = true;
                              });
                            }
                            if (_groupValue != 0) {
                              if (!_formKey.currentState.validate()) {
                                return;
                              }
                              _formKey.currentState.save();

                              TherapistClass therapist = therapistDetails();
                              bool check =
                                  await checkIfEmailInUse(therapist.email);
                              print("$check");

                              (check && _groupValue > 0)
                                  ? showSnackBar(
                                      context,
                                      _groupValue != -1
                                          ? "Email already exists use a different email address"
                                          : "Select one of the options")
                                  : Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => PatientDetails(
                                              therapist,
                                              widget.patient,
                                              widget.needTherapist)));
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PatientDetails(
                                      new TherapistClass(),
                                      widget.patient,
                                      widget.needTherapist)));
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
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
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // ),
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}

class TherapistClass {
  String fname, lname, role, address, mobile, email, age, gender, isNewUser;

  TherapistClass(
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

  static TherapistClass fromJson(Map<String, dynamic> json) => TherapistClass(
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

class Utils {
  static DateTime toDateTime(Timestamp value) {
    if (value == null) return null;

    return value.toDate();
  }

  static DateTime fromDateTimeToJson(DateTime date) {
    if (date == null) return null;

    return date.toUtc();
  }
}
