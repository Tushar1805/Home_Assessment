import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/patientdash.dart';
import 'package:tryapp/Patient_Caregiver_Family/Dashboard/patientdashprov.dart';

class HomeAddress extends StatefulWidget {
  @override
  _HomeAddressState createState() => _HomeAddressState();
}

class _HomeAddressState extends State<HomeAddress> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> list = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getAddresses();
    setState(() {
      loading = true;
    });
  }

  getAddresses() async {
    User user = auth.currentUser;

    await firestore.collection("users").doc(user.uid).get().then((value) {
      if (value.data()["houses"] != null) {
        setState(() {
          list = List<Map<String, dynamic>>.generate(
              value.data()["houses"].length,
              (int index) => Map<String, dynamic>.from(
                  value.data()["houses"].elementAt(index)));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // HomeAddressPro assesspro = Provider.of<HomeAddressPro>(context);

    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Patient()));
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(10, 80, 106, 1),
          title: Text(
            'Home Addresses',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: (list.isEmpty)
            ? Center(child: CircularProgressIndicator())
            : (list.length == 0)
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
                              'NO HOME ADDRESSES',
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
                    child: Container(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: 1000,
                            minHeight: MediaQuery.of(context).size.height / 10),
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: list?.length ?? 0,
                          itemBuilder: (context, index) {
                            return Container(
                              // decoration: new BoxDecoration(boxShadow: [
                              //   new BoxShadow(
                              //     color: Colors.grey[100],
                              //     blurRadius: 15.0,
                              //   ),
                              // ]
                              // ),
                              padding: EdgeInsets.all(20),
                              // height: MediaQuery.of(context).size.height * 0.3,
                              child: GestureDetector(
                                child: Card(
                                    elevation: 15,
                                    borderOnForeground: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: Colors.blue[50],
                                    child: Container(
                                        padding: EdgeInsets.only(bottom: 0),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              // color: Colors.red,
                                              padding: EdgeInsets.all(15),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      // '${(list[index]["houseName"] != "") ? list[index]["houseName"] : "Home Name"}' ??
                                                      "House ${index + 1}",
                                                      style: TextStyle(
                                                          fontSize: 30,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Wrap(
                                                    // mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        child: Text(
                                                          // '${(list[index]["houseName"] != "") ? list[index]["houseName"] : "Home Name"}' ??
                                                          "House Name: ",
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color: Colors
                                                                  .black45),
                                                        ),
                                                      ),
                                                      Container(
                                                        child: Text(
                                                          '${list[index][" houseName"].toString()}' ??
                                                              "Home Name",
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),

                                                  Container(
                                                    width: double.infinity,
                                                    child: Wrap(children: [
                                                      Text(
                                                        'Address Line 1: ',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Colors.black45),
                                                      ),
                                                      Text(
                                                        '${list[index]["address1"]}' ??
                                                            "Address Line 1",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ]),
                                                  ),
                                                  SizedBox(height: 10),
                                                  // getDate("Latest Change: ",
                                                  //     snapshot["latestChangeDate"]),
                                                  // SizedBox(height: 2.5),
                                                  // Divider(),
                                                  Container(
                                                    child: Wrap(children: [
                                                      Text(
                                                        'Address Line 2: ',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Colors.black45),
                                                      ),
                                                      Text(
                                                        '${list[index]["address2"]}' ??
                                                            "Address Line 2",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ]),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Container(
                                                    width: double.infinity,
                                                    child: Wrap(children: [
                                                      Text(
                                                        'City: ',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Colors.black45),
                                                      ),
                                                      Text(
                                                        '${list[index]["city"]}' ??
                                                            "Nagpur",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ]),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Container(
                                                    width: double.infinity,
                                                    child: Wrap(children: [
                                                      Text(
                                                        'Country: ',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Colors.black45),
                                                      ),
                                                      Text(
                                                        '${list[index]["country"]}' ??
                                                            "Country",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ]),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Container(
                                                    width: double.infinity,
                                                    child: Wrap(children: [
                                                      Text(
                                                        'State: ',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Colors.black45),
                                                      ),
                                                      Text(
                                                        '${list[index]["state"]}' ??
                                                            "Country",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ]),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Container(
                                                    width: double.infinity,
                                                    child: Wrap(children: [
                                                      Text(
                                                        'Phone No: ',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Colors.black45),
                                                      ),
                                                      Text(
                                                        '${list[index]["phoneNo"]}' ??
                                                            "1234567890",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ]),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Container(
                                                    width: double.infinity,
                                                    child: Wrap(children: [
                                                      Text(
                                                        'Postal Code: ',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Colors.black45),
                                                      ),
                                                      Text(
                                                        '${list[index]["postalCode"]}' ??
                                                            "442301",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ]),
                                                  ),
                                                  SizedBox(height: 10),

                                                  // Container(child: Text('${dataset.data}')),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            )
                                          ],
                                        ))),
                                onTap: () async {
                                  //   print("Hello");
                                  //   await assesspro.getdocref(assessmentdata);
                                  //   // print(assesspro.curretnassessmentdocref);
                                  //   // print(assessmentdata.data);

                                  //   if (assessmentdata.data['Status'] == "new") {
                                  //     Navigator.push(
                                  //         context,
                                  //         MaterialPageRoute(
                                  //             builder: (context) =>
                                  //                 NewAssesment(assesspro.curretnassessmentdocref)));
                                  //   } else {
                                  //     Navigator.push(
                                  //         context,
                                  //         MaterialPageRoute(
                                  //             builder: (context) =>
                                  //                 NewAssesment(assesspro.curretnassessmentdocref)));
                                  //   }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )),
      ),
    );
  }
}
