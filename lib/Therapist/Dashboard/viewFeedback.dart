import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tryapp/Therapist/Dashboard/therapistdash.dart';
import 'package:tryapp/Therapist/Dashboard/therapistpro.dart';

// ignore: must_be_immutable
class ViewFeedback extends StatefulWidget {
  @override
  _ViewFeedbackState createState() => _ViewFeedbackState();
}

class _ViewFeedbackState extends State<ViewFeedback> {
  List<Map<String, dynamic>> list = [];
  List<Map<String, dynamic>> orderedList = [];
  User user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getFeedback();
    getPatientDetails();
  }

  void getFeedback() async {
    await firestore.collection("users").doc(user.uid).get().then((value) {
      if (value.data()["feedback"].length > 0) {
        setState(() {
          list = List<Map<String, dynamic>>.generate(
              value.data()["feedback"].length,
              (int index) => Map<String, dynamic>.from(
                  value.data()["feedback"].elementAt(index)));
          orderedList = List.from(list.reversed);
        });
      } else {
        list = [];
      }
    });
  }

  void getPatientDetails() {}

  Widget getTime(index) {
    var timeString;
    Timestamp time = orderedList[index]['time'];
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(time.millisecondsSinceEpoch);

    timeString = DateFormat('hh:mm a').format(date);
    return Text(
      "$timeString",
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
    );
  }

  Widget getDate(index) {
    var dateString;
    Timestamp time = orderedList[index]['time'];
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(time.millisecondsSinceEpoch);

    dateString = DateFormat('dd MMM yyyy').format(date);
    return Text(
      "$dateString",
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TherapistProvider provider = Provider.of<TherapistProvider>(context);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Therapist()));
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(10, 80, 106, 1),
          title: Text(
            'Feedback',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: (provider.loading1)
            ? Container(
                color: Colors.white,
                child: Center(
                  child: (CircularProgressIndicator(
                      color: Color.fromRGBO(10, 80, 106, 1))),
                ))
            : (provider.document["feedback"].length == 0)
                ? Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * .2,
                          child: Image.asset('assets/nodata.png'),
                        ),
                        Container(
                          child: Container(
                            child: Text(
                              'NO FEEDBACKS',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : Container(
                    child: (provider.loading)
                        ? Center(child: CircularProgressIndicator())
                        : Container(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxHeight: 1000,
                                    minHeight:
                                        MediaQuery.of(context).size.height /
                                            10),
                                child: ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount:
                                        provider.document["feedback"]?.length ??
                                            0,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        padding: EdgeInsets.all(10),
                                        // height: MediaQuery.of(context).size.height * 0.3,
                                        child: Card(
                                          elevation: 10,
                                          borderOnForeground: true,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          color: Colors.blue[50],
                                          child: Container(
                                            padding: EdgeInsets.only(bottom: 0),
                                            child: Column(children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      // height: 30,
                                                      alignment:
                                                          Alignment.centerRight,
                                                      // width: double.infinity,
                                                      // color: Colors.red,
                                                      child: (provider
                                                              .datasetFeedback
                                                              .isNotEmpty)
                                                          ? (provider.datasetFeedback[
                                                                              "$index"]
                                                                          [
                                                                          'url'] !=
                                                                      "" &&
                                                                  provider.datasetFeedback[
                                                                              "$index"]
                                                                          [
                                                                          'url'] !=
                                                                      null)
                                                              ? CircleAvatar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  radius: 17,
                                                                  // backgroundImage: (imgUrl != "" && imgUrl != null)
                                                                  //     ? NetworkImage(imgUrl)
                                                                  //     : Image.asset('assets/therapistavatar.png'),
                                                                  child: ClipOval(
                                                                      clipBehavior: Clip.hardEdge,
                                                                      child: CachedNetworkImage(
                                                                        imageUrl:
                                                                            provider.datasetFeedback["$index"]["url"],
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        width:
                                                                            50,
                                                                        height:
                                                                            50,
                                                                        placeholder:
                                                                            (context, url) =>
                                                                                new CircularProgressIndicator(),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            new Icon(Icons.error),
                                                                      )),
                                                                )
                                                              : CircleAvatar(
                                                                  radius: 17,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  child:
                                                                      ClipOval(
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/patientavatar.png',
                                                                    ),
                                                                  ),
                                                                )
                                                          : SizedBox(),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            provider.datasetFeedback
                                                                    .isNotEmpty
                                                                ? "${provider.datasetFeedback["$index"]["firstName"][0].toString().toUpperCase()}${provider.datasetFeedback["$index"]["firstName"].toString().substring(1)} ${provider.datasetFeedback["$index"]["lastName"][0].toString().toUpperCase()}${provider.datasetFeedback["$index"]["lastName"].toString().substring(1)}"
                                                                : "",
                                                            style: TextStyle(
                                                                fontSize: 20),
                                                          ),
                                                          Container(
                                                            child:
                                                                getDate(index),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .2,
                                                    ),
                                                    // Container(
                                                    //     alignment:
                                                    //         Alignment.topRight,
                                                    //     child: Column(
                                                    //       mainAxisAlignment:
                                                    //           MainAxisAlignment
                                                    //               .start,
                                                    //       crossAxisAlignment:
                                                    //           CrossAxisAlignment
                                                    //               .end,
                                                    //       children: [
                                                    //         Container(
                                                    //           child: getTime(
                                                    //               index),
                                                    //         ),
                                                    //         Container(
                                                    //           child: getDate(
                                                    //               index),
                                                    //         )
                                                    //       ],
                                                    //     )),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                color: Colors.white,
                                                alignment: Alignment.topLeft,
                                                padding: EdgeInsets.fromLTRB(
                                                    15, 15, 15, 5),
                                                child: Column(
                                                  children: [
                                                    InputDecorator(
                                                      decoration:
                                                          InputDecoration(
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          10,
                                                                          80,
                                                                          106,
                                                                          1),
                                                                  width: 1),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  width: 1),
                                                        ),
                                                        // isDense: true,
                                                      ),
                                                      child: Text(
                                                        "${orderedList[index]["feedback"]}",
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: getTime(index),
                                                    )
                                                  ],
                                                ),
                                              ),

                                              // Container(
                                              //   alignment:
                                              //       Alignment.centerRight,
                                              //   child: getTime(index),
                                              // )
                                            ]),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ),
                  ),
      ),
    );
  }
}
