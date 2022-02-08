import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tryapp/Assesment/newassesment/newassesmentrepo.dart';
import 'package:tryapp/Nurse_Case_Manager/Dashboard/nursedash.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/patientdash.dart';
import 'package:tryapp/Therapist/Dashboard/therapistdash.dart';
import 'newassesmentpro.dart';
import 'cardsUI.dart';
import 'package:provider/provider.dart';

/// This page is about chosing the areas of home available

/// Frame of this page:
///
/// main build fucntion:
///     this fucntion contains
///         1)the appbar
///         2)AREAS OF HOME AVAILABLE CARD:
///         3)LISTVIEW which hepls in building the outer card:
///                    roomOuterCard()
///         4)The next button to call the Cards UI page with provider link.
///
///
/// roomOuterCard(takes provider link, Index from listview):
///     this function cotains:
///         1) the head class name
///         2) counter button to increase and decrease the room count (NumericStepButton) class
///         3) LISTVIEW which helps in building the inner text fields to
///             where we can write the name of individual rooms

/// NumericStepButton class
///   this class is sperately created to build the button to increase and decrease the couunter..

final _colorgreen = Color.fromRGBO(10, 80, 106, 1);

class NewAssesmentUI extends StatefulWidget {
  String docID;
  NewAssesmentUI(this.docID);
  @override
  _NewAssesmentUIState createState() => _NewAssesmentUIState();
}

class _NewAssesmentUIState extends State<NewAssesmentUI> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String role;

  @override
  void initState() {
    super.initState();
    getRole();
    print(role);
  }

  getRole() async {
    var runtimeType;
    User user = await _auth.currentUser;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get()
        .then((value) => setState(() {
              runtimeType = value.data()['role'].runtimeType.toString();
              print("runtime Type: $runtimeType");
              if (runtimeType == "List<dynamic>") {
                for (int i = 0; i < value.data()["role"].length; i++) {
                  if (value.data()["role"][i].toString() == "therapist") {
                    setState(() {
                      role = "therapist";
                    });
                  }
                }
              } else {
                setState(() {
                  role = value.data()["role"];
                });
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    final assesmentprovider = Provider.of<NewAssesmentProvider>(context);
    double _w = MediaQuery.of(context).size.width;
    return WillPopScope(
      /// This will give a pop up whenever we try to get back from the
      /// areas of room available.
      onWillPop: () {
        showDialog(
          context: context,
          // barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text('Alert'),
                content: Text('Want to exit?'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (role == "therapist") {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Therapist()));
                      } else if (role == "nurse/case manager") {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => Nurse()));
                      } else if (role == "patient") {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => Patient()));
                      }
                      // Navigator.pushAndRemoveUntil(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => OldAssessments()),
                      //   (Route<dynamic> route) => false,
                      // );

                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => OldAssessments()));
                    },
                    child: Text('Got It'),
                  ),
                ],
              ),
            );
          },
        );
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Assessment'),
          backgroundColor: _colorgreen,
        ),
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    width: double.infinity,
                    child: Text(
                      'Areas of Home Available',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 30,
                          color: _colorgreen,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: 10000,
                          minHeight: MediaQuery.of(context).size.height / 10),
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: assesmentprovider.getlistdata().length,

                        /// This is the itembuilder to call and hence create the cards for each room
                        /// In this we exclude the LIVING ARRANGEMENTS
                        ///  reason:(Prachi's Suggestion)
                        /// This Living Arrangements will be taken care when we click on next button.
                        itemBuilder: (context, index) {
                          if (assesmentprovider.getlistdata()[index]['name'] ==
                                  'Living Arrangements' ||
                              assesmentprovider.getlistdata()[index]['name'] ==
                                  'Warehouse') {
                            return SizedBox(height: 0);
                          } else {
                            return roomOuterCard(assesmentprovider, index);
                          }
                        },
                      ),
                    ),
                  ),

                  // Animation for list

                  // AnimationLimiter(
                  //     child: ListView.builder(
                  //   padding: EdgeInsets.all(_w / 30),
                  //   physics: BouncingScrollPhysics(
                  //       parent: AlwaysScrollableScrollPhysics()),
                  //   itemCount: assesmentprovider.getlistdata().length,
                  //   itemBuilder: (BuildContext context, int index) {
                  //     return AnimationConfiguration.staggeredList(
                  //       position: index,
                  //       delay: Duration(milliseconds: 100),
                  //       child: SlideAnimation(
                  //         duration: Duration(milliseconds: 2500),
                  //         curve: Curves.fastLinearToSlowEaseIn,
                  //         verticalOffset: -250,
                  //         child: ScaleAnimation(
                  //           duration: Duration(milliseconds: 1500),
                  //           curve: Curves.fastLinearToSlowEaseIn,
                  //           child: Container(
                  //             margin: EdgeInsets.only(bottom: _w / 20),
                  //             height: _w / 4,
                  //             decoration: BoxDecoration(
                  //               color: Colors.white,
                  //               borderRadius:
                  //                   BorderRadius.all(Radius.circular(20)),
                  //               boxShadow: [
                  //                 BoxShadow(
                  //                   color: Colors.black.withOpacity(0.1),
                  //                   blurRadius: 40,
                  //                   spreadRadius: 10,
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // )),
                  Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(15),
                      child: ClipOval(
                        child: Material(
                          color: Colors.orange, // button color
                          child: InkWell(
                            splashColor:
                                Color.fromRGBO(10, 80, 106, 1), // inkwell color
                            child: SizedBox(
                                width: 76,
                                height: 76,
                                child: Icon(Icons.arrow_forward,
                                    color: Colors.white)),
                            onTap: () {
                              /// This is the next button.
                              /// As said earlier we do skip the living Arrangements card so here
                              /// it is taken care of. we do create only a single room for living arrangements

                              assesmentprovider
                                  .setassessmainstatus(widget.docID);
                              for (int i = 0;
                                  i < assesmentprovider.listofRooms.length;
                                  i++) {
                                if (assesmentprovider.listofRooms[i]['name'] ==
                                    'Living Arrangements') {
                                  setState(() {
                                    assesmentprovider.listofRooms[i]
                                        ['room$i'] = {
                                      'name':
                                          '${assesmentprovider.listofRooms[i]['name']}',
                                      'complete': 0,
                                      'total': gettotal(assesmentprovider
                                          .getlistdata()[i]['name']),
                                      'question': getMaps(assesmentprovider
                                          .getlistdata()[i]['name']),
                                    };
                                  });
                                }
                              }

                              /// Here we are calling the Cards UI page where each and every rooms created
                              /// will be displayed but we are also passing the provider link. Because the same data
                              /// will be needing rthe rooms data in further pages.
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CardsUINew(
                                          assesmentprovider.getlistdata(),
                                          widget.docID)));
                              NewAssesmentRepository()
                                  .setAssessmentCurrentStatus(
                                      "Assessment in Progress", widget.docID);
                              NewAssesmentRepository().setForm(
                                  assesmentprovider.getlistdata(),
                                  widget.docID);
                            },
                          ),
                        ),
                      ))
                ],
              )),
        ),
      ),
    );
  }

  /// This function is responsible to  create the cards
  Widget roomOuterCard(NewAssesmentProvider prov, int index) {
    return Card(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 5),
      elevation: 8,
      child: Container(
          width: double.infinity,
          child: Column(
            children: [
              /// this field will display the head name of the card.
              Container(
                  padding: EdgeInsets.all(12),
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Text(
                    "${prov.getlistdata()[index]['name']}:",
                    style: TextStyle(
                        color: _colorgreen,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  )),
              SizedBox(
                height: 15,
              ),
              Container(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Number of ${prov.getlistdata()[index]['name']}(s):",
                              style:
                                  TextStyle(fontSize: 15, color: _colorgreen),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),

                          /// Here we are calling the NumericStepButton class present at the bottom of this
                          /// page. this helps to get the data and here we are using it to create the
                          /// text fields.
                          Expanded(
                            child: NumericStepButton(
                              maxValue: 20,
                              onChanged: (text) {
                                /// Note: Read this to understand below code.
                                /// as we get number count from the numeric button.
                                ///
                                /// Our current frame is(list of rooms):
                                ///         {
                                ///            'name': 'Pathway',
                                ///            'count': 0,
                                ///            'completed': 7,
                                ///         },
                                ///
                                /// What below lines will do:
                                ///   This will make the above frame as:
                                ///
                                ///         {
                                ///            'name': 'Pathway',
                                ///            'count': text, //the count from button will get saved here
                                ///            'completed': 7,
                                ///            'rooms1':{
                                ///                 name://This will help us to save name of room.
                                ///                 complete: //This will help us to save the numbers of
                                ///                           completed fields this far and also help us
                                ///                            to calculate the linear progress bar.
                                ///                 total: // This is the total number of questions in
                                ///                           particular rooms.. This is Static.
                                ///                           We will get this data from gettotal function
                                ///                           from the provider.
                                ///                 question: { //this is explained in getMaps function in provider.
                                ///                   rr1:{
                                ///                       Answer:,
                                ///                       Priority:,
                                ///                       Recommendation:,
                                ///                       Recommendationthera:,
                                ///                       additional:{},
                                ///                      }
                                ///                   }
                                ///             }
                                ///         },
                                ///
                                ///
                                ///
                                setState(
                                  () {
                                    if (text > 0) {
                                      prov.listofRooms[index]['count'] = text;
                                      prov.listofRooms[index]['room$text'] = {
                                        'name':
                                            '${prov.listofRooms[index]['name']} $text',
                                        'complete': 0,
                                        'total': gettotal(
                                            prov.getlistdata()[index]['name']),
                                        'question': getMaps(
                                            prov.getlistdata()[index]['name']),
                                      };

                                      // This will help us to  remove rooms when we reduce the number
                                      // of rooms.
                                      if (prov.listofRooms[index].containsKey(
                                          'room${prov.listofRooms[index]['count'] + 1}')) {
                                        prov.listofRooms[index].remove(
                                            'room${prov.listofRooms[index]['count'] + 1}');
                                      }
                                    } else if (text.toString().length == 0 ||
                                        text == 0) {
                                      if (prov.listofRooms[index].containsKey(
                                          'room${prov.listofRooms[text]['count']}')) {
                                        prov.listofRooms[index].remove(
                                            'room${prov.listofRooms[text]['count']}');
                                      }
                                      prov.listofRooms[index]['count'] = text;
                                      // widget.obstacle = false;

                                    }
                                    // print(prov.listofRooms[index]);
                                  },
                                );
                              },
                            ),
                          )
                        ],
                      ),
                      (prov.listofRooms[index]['count'] > 0)
                          ? Container(
                              child: Padding(
                                padding: EdgeInsets.all(15),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxHeight: 1000,
                                      minHeight:
                                          MediaQuery.of(context).size.height /
                                              10),
                                  child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: prov.listofRooms[index]['count'],
                                    itemBuilder: (context, index1) {
                                      return TextFormField(
                                        decoration: InputDecoration(
                                            labelText:
                                                '${prov.getlistdata()[index]['name']} (Name)'),
                                        onChanged: (text) {
                                          if (text != null) {
                                            prov.listofRooms[index]
                                                    ['room${index1 + 1}']
                                                ['name'] = capitalize(text);
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  )),
            ],
          )),
    );
  }
}

class NumericStepButton extends StatefulWidget {
  final int minValue;
  final int maxValue;

  final ValueChanged<int> onChanged;

  NumericStepButton(
      {Key key, this.minValue = 0, this.maxValue = 10, this.onChanged})
      : super(key: key);

  @override
  State<NumericStepButton> createState() {
    return _NumericStepButtonState();
  }
}

class _NumericStepButtonState extends State<NumericStepButton> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              Icons.remove,
              color: Colors.green,
            ),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 9.0),
            iconSize: 20.0,
            color: Colors.green,
            onPressed: () {
              setState(() {
                if (counter > widget.minValue) {
                  counter--;
                }
                widget.onChanged(counter);
              });
            },
          ),
          Container(
            // width: 20,
            decoration: BoxDecoration(
                border: Border(
              bottom:
                  BorderSide(width: 1.0, color: Color.fromRGBO(10, 80, 106, 1)),
            )),
            child: Text(
              '$counter',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.green,
            ),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 9.0),
            iconSize: 20.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {
                if (counter < widget.maxValue) {
                  counter++;
                }
                widget.onChanged(counter);
              });
            },
          ),
        ],
      ),
    );
  }
}
