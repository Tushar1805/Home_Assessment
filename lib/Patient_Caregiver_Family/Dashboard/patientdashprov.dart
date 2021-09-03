import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './patientdashrepo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientProvider extends ChangeNotifier {
  // final PatientRepository patientRepository = PatientRepository();

  // final FirebaseAuth auth = FirebaseAuth.instance;

  // // inputData() async {
  // //   final FirebaseUser user = await auth.currentUser();
  // //   final uid = user.uid;
  // //   return uid;
  // //   // here you write the codes to input the data into firestore
  // // }

  // final Color colorgreen = Color.fromRGBO(10, 80, 106, 1);
  // final Firestore firestore = Firestore.instance;
  // String getq;
  // bool assessdisplay = false;
  // QuerySnapshot dataset;
  // Map<String, dynamic> datasetorder;
  // //  datamain;
  // List datasetmain = [];
  // // Map<String, dynamic> datasetmain = {};
  // var docs;
  // var data2;
  // String curretnassessmentdocref;
  // bool loading = false;
  // String sortdata = '';
  // PatientProvider() {
  //   getdocset("old");
  // }

  // getdocset(type) async {
  //   loading = true;
  //   notifyListeners();
  //   List dataset = await patientRepository.getassessments();
  //   // Map<String, DocumentSnapshot> datasetmaintemp = {};
  //   // for (int i = 0; i < dataset.documents.length; i++) {
  //   //   await getfielddata(
  //   //     dataset.documents[i].data['Patient'],
  //   //   );
  //   //   datasetmaintemp["$i"] = (data2);
  //   // }
  //   // Map<String, dynamic> temptry = {};
  //   // for (int j = 0; j < datasetmaintemp.length; j++) {
  //   //   temptry["$j"] = datasetmaintemp["$j"].data;
  //   // }
  //   // datasetmain = temptry;
  //   datasetmain = dataset;
  //   notifyListeners();
  //   loading = false;
  //   notifyListeners();
  // }

  // // getsorteddata(sortby, type) async {
  // //   if (sortby == '') {
  // //     Map<String, dynamic> datatemp = {};
  // //     for (int i = 0; i < dataset.documents.length; i++) {
  // //       datatemp["$i"] = dataset.documents[i].data;
  // //     }
  // //     final sorted = SplayTreeMap.from(
  // //         datatemp,
  // //         (key1, key2) => datatemp[key1]["StartDate"]
  // //             .compareTo(datatemp[key2]["StartDate"]));
  // //     datasetorder = HashMap.from(sorted);
  // //     notifyListeners();
  // //     // print(datasetorder);
  // //     var i = 0;
  // //     Map<String, dynamic> temptry2 = {};
  // //     datasetorder.forEach((k, v) {
  // //       temptry2["$i"] = v;
  // //       i++;
  // //     });
  // //     // print(temptry2);
  // //     Map<String, DocumentSnapshot> datasetmaintemp = {};
  // //     for (int i = 0; i < temptry2.length; i++) {
  // //       await getfielddata(
  // //         temptry2["$i"]['Patient'],
  // //       );
  // //       datasetmaintemp["$i"] = (data2);
  // //     }
  // //     print(datasetmaintemp["0"].data);
  // //     // datasetmain =
  // //     Map<String, dynamic> temptry = {};
  // //     for (int j = 0; j < datasetmaintemp.length; j++) {
  // //       temptry["$j"] = datasetmaintemp["$j"].data;
  // //     }
  // //     datasetmain = temptry;
  // //     loading = false;
  // //     notifyListeners();
  // //     print(datasetmain);

  // //     return;
  // //   }
  // //   final sorted = SplayTreeMap.from(
  // //       datasetmain,
  // //       (key1, key2) => datasetmain[key1]["$sortby"]
  // //           .compareTo(datasetmain[key2]["$sortby"]));

  // //   datasetmain = HashMap.from(sorted);
  // //   var i = 0;
  // //   Map<String, dynamic> temptry2 = {};
  // //   sorted.forEach((k, v) {
  // //     temptry2["$i"] = v;
  // //     i++;
  // //   });

  // //   datasetmain = temptry2;
  // //   notifyListeners();
  // //   print(datasetmain);
  // // }

  // // getdocref(asessmentdoc) async {
  // //   curretnassessmentdocref = await oldrepo.getassessmentdocid(asessmentdoc);
  // //   notifyListeners();
  // // }

  // // getstatuspatient(type) {
  // //   (type == 'new') ? assessdisplay = true : assessdisplay = false;
  // //   getdocset(type);
  // //   notifyListeners();
  // // }

  // // getoldassess() async {
  // //   docs = await oldrepo.getassessments();
  // //   notifyListeners();
  // // }

  // getfielddata(String uid) async {
  //   data2 = await patientRepository.getfielddata(uid);
  //   notifyListeners();
  //   return data2;
  // }

  // // getuid() async {
  // //   getq = await oldrepo.getcurrentuid();
  // //   notifyListeners();
  // // }
// }
/************************/
  final PatientRepository patientrepo = PatientRepository();
  final Color colorgreen = Color.fromRGBO(10, 80, 106, 1);
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String getq;
  bool assessdisplay = false;
  QuerySnapshot dataset;
  QuerySnapshot home;
  Map<String, dynamic> datasetorder;
  //  datamain;
  Map<String, dynamic> datasetmain = {};
  Map<String, dynamic> homemain = {};
  var docs;
  var data2;
  String curretnassessmentdocref, role;
  bool loading = false;
  String sortdata = '';
  PatientProvider(String role) {
    getdocset(role);
    // print(role);
  }

  // getHomeAddresses() async {
  //   loading = true;
  //   notifyListeners();
  //   home = await patientrepo.getHomeAddresses();
  //   Map<String, DocumentSnapshot> homemaintemp = {};
  //   for (int i = 0; i < home.docs.length; i++) {
  //     await getfielddata(
  //       home.docs[i]['houses'],
  //     );
  //     homemaintemp["$i"] = (data2);
  //   }
  //   Map<String, dynamic> temptry = {};
  //   for (int j = 0; j < homemaintemp.length; j++) {
  //     temptry["$j"] = homemaintemp["$j"].data();
  //   }
  //   homemain = temptry;
  //   loading = false;
  //   notifyListeners();
  // }

  getdocset(role) async {
    loading = true;
    notifyListeners();
    dataset = await patientrepo.getAssessments(role);
    Map<String, DocumentSnapshot> datasetmaintemp = {};
    for (int i = 0; i < dataset.docs.length; i++) {
      await getfielddata(
        dataset.docs[i]['therapist'],
      );
      datasetmaintemp["$i"] = (data2);
    }
    Map<String, dynamic> temptry = {};
    for (int j = 0; j < datasetmaintemp.length; j++) {
      temptry["$j"] = datasetmaintemp["$j"].data();
    }
    datasetmain = temptry;
    loading = false;
    notifyListeners();
  }

  getsorteddata(sortby, type) async {
    if (sortby == '') {
      Map<String, dynamic> datatemp = {};
      for (int i = 0; i < dataset.docs.length; i++) {
        datatemp["$i"] = dataset.docs[i].data();
      }
      final sorted = SplayTreeMap.from(
          datatemp,
          (key1, key2) => datatemp[key1]["StartDate"]
              .compareTo(datatemp[key2]["StartDate"]));
      datasetorder = HashMap.from(sorted);
      notifyListeners();
      // print(datasetorder);
      var i = 0;
      Map<String, dynamic> temptry2 = {};
      datasetorder.forEach((k, v) {
        temptry2["$i"] = v;
        i++;
      });
      // print(temptry2);
      Map<String, DocumentSnapshot> datasetmaintemp = {};
      for (int i = 0; i < temptry2.length; i++) {
        await getfielddata(
          temptry2["$i"]['Patient'],
        );
        datasetmaintemp["$i"] = (data2);
      }
      print(datasetmaintemp["0"].data());
      // datasetmain =
      Map<String, dynamic> temptry = {};
      for (int j = 0; j < datasetmaintemp.length; j++) {
        temptry["$j"] = datasetmaintemp["$j"].data();
      }
      datasetmain = temptry;
      loading = false;
      notifyListeners();
      // print(datasetmain);

      return;
    }
    final sorted = SplayTreeMap.from(
        datasetmain,
        (key1, key2) => datasetmain[key1]["$sortby"]
            .compareTo(datasetmain[key2]["$sortby"]));

    datasetmain = HashMap.from(sorted);
    var i = 0;
    Map<String, dynamic> temptry2 = {};
    sorted.forEach((k, v) {
      temptry2["$i"] = v;
      i++;
    });

    datasetmain = temptry2;
    notifyListeners();
    // print(datasetmain);
  }

  getdocref(asessmentdoc) async {
    curretnassessmentdocref =
        await patientrepo.getassessmentdocid(asessmentdoc);
    notifyListeners();
  }

  getstatuspatient(role) {
    role = role;
    getdocset(role);
    notifyListeners();
  }

  getoldassess() async {
    docs = await patientrepo.getAssessments("patient");
    notifyListeners();
  }

  getfielddata(String uid) async {
    data2 = await patientrepo.getfielddata(uid);
    notifyListeners();
    return data2;
  }

  // getuid() async {
  //   getq = await patientrepo.getcurrentuid();
  //   notifyListeners();
  // }

  String capitalize(String s) {
    if (s != null) {
      var parts = s.split(' ');
      // print(parts);
      String sum = '';
      parts.forEach(
          (cur) => {sum += cur[0].toUpperCase() + cur.substring(1) + " "});
      return sum;
    }
  }
}
