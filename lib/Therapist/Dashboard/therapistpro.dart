import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './therapistdashrepo.dart';

class TherapistProvider extends ChangeNotifier {
  // final TherapistRepository therapistRepository = TherapistRepository();

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
  // TherapistProvider() {
  //   getdocset("old");
  // }

  // getdocset(type) async {
  //   loading = true;
  //   notifyListeners();
  //   List dataset = await therapistRepository.getassessments();
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

  // getdocref(asessmentdoc) async {
  //   curretnassessmentdocref =
  //       await therapistRepository.getassessmentdocid(asessmentdoc);
  //   notifyListeners();
  // }

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
  //   data2 = await therapistRepository.getfielddata(uid);
  //   notifyListeners();
  //   return data2;
  // }

  // // getuid() async {
  // //   getq = await oldrepo.getcurrentuid();
  // //   notifyListeners();
  // // }
  //********************************************************************************** */
  final TherapistRepository therarepo = TherapistRepository();
  final Color colorgreen = Color.fromRGBO(10, 80, 106, 1);
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String getq;
  bool assessdisplay = false;
  QuerySnapshot dataset;
  DocumentSnapshot document;
  Map<String, dynamic> datasetorder;
  //  datamain;
  Map<String, dynamic> datasetmain = {};
  Map<String, dynamic> datasetFeedback = {};
  var docs;
  var data2;
  var data3;
  String curretnassessmentdocref, role;
  bool loading = false;
  bool loading1 = false;
  String sortdata = '';
  TherapistProvider(String role) {
    User user = FirebaseAuth.instance.currentUser;
    getdocset(role);
    getFeedback();
    firestore.collection("users").doc(user.uid).get().then((value) {
      if (value.data()["feedback"].exists) {
      } else {
        value.data()["feedback"] = "";
      }
    });
    // print(role);
  }

  getdocset(role) async {
    loading = true;
    notifyListeners();
    dataset = await therarepo.getAssessments(role);
    Map<String, DocumentSnapshot> datasetmaintemp = {};
    for (int i = 0; i < dataset.docs.length; i++) {
      await getfielddata(
        dataset.docs[i]['patient'],
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

  getFeedback() async {
    loading1 = true;
    notifyListeners();
    document = await therarepo.getFeedback();
    Map<String, DocumentSnapshot> datasetmaintemp = {};
    // print(document["feedback"].length);
    if (document["feedback"] != null) {
      for (int i = document["feedback"].length, k = 0;
          i > 0 && k < document["feedback"].length;
          i--, k++) {
        await getfielddata2(document['feedback'][i - 1]["patient"]);
        datasetmaintemp["$k"] = (data3);
      }
      Map<String, dynamic> temptry = {};
      for (int j = 0; j < datasetmaintemp.length; j++) {
        temptry["$j"] = datasetmaintemp["$j"].data();
      }
      datasetFeedback = temptry;
    }

    loading1 = false;
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
    curretnassessmentdocref = await therarepo.getassessmentdocid(asessmentdoc);
    notifyListeners();
  }

  getstatuspatient(role) {
    role = role;
    getdocset(role);
    notifyListeners();
  }

  getoldassess() async {
    docs = await therarepo.getAssessments("nurse/case Manager");
    notifyListeners();
  }

  getfielddata(String uid) async {
    data2 = await therarepo.getfielddata(uid);
    notifyListeners();
    return data2;
  }

  getfielddata2(String uid) async {
    data3 = await therarepo.getfielddata(uid);
    notifyListeners();
    return data3;
  }

  getuid() async {
    getq = await therarepo.getcurrentuid();
    notifyListeners();
  }

  String capitalize(String s) {
    if (s != null) {
      var parts = s.split(' ');
      // print(parts);
      String sum = '';
      if (parts.length > 1) {
        parts.forEach(
            (cur) => {sum += cur[0].toUpperCase() + cur.substring(1) + " "});
        return sum;
      }
    }
  }
}
