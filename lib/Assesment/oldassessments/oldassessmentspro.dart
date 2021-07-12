import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './oldassessmentsrepo.dart';
import 'dart:collection';
import 'package:deep_collection/deep_collection.dart';

class OldAssessmentsProvider extends ChangeNotifier {
  final OldAssessmentRepo oldrepo = OldAssessmentRepo();
  final Color colorgreen = Color.fromRGBO(10, 80, 106, 1);
  final Firestore firestore = Firestore.instance;
  String getq;
  bool assessdisplay = false;
  QuerySnapshot dataset;
  Map<String, dynamic> datasetorder;
  //  datamain;
  Map<String, dynamic> datasetmain = {};
  var docs;
  var data2;
  String curretnassessmentdocref, role;
  bool loading = false;
  String sortdata = '';
  OldAssessmentsProvider(String role) {
    getdocset("old", role);
    // print(role);
  }

  getdocset(type, role) async {
    loading = true;
    notifyListeners();
    dataset = await oldrepo.getpatients(type, role);
    Map<String, DocumentSnapshot> datasetmaintemp = {};
    for (int i = 0; i < dataset.documents.length; i++) {
      await getfielddata(
        dataset.documents[i].data['patient'],
      );
      datasetmaintemp["$i"] = (data2);
    }
    Map<String, dynamic> temptry = {};
    for (int j = 0; j < datasetmaintemp.length; j++) {
      temptry["$j"] = datasetmaintemp["$j"].data;
    }
    datasetmain = temptry;
    loading = false;
    notifyListeners();
  }

  getsorteddata(sortby, type) async {
    if (sortby == '') {
      Map<String, dynamic> datatemp = {};
      for (int i = 0; i < dataset.documents.length; i++) {
        datatemp["$i"] = dataset.documents[i].data;
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
      // print(datasetmaintemp["0"].data);
      // datasetmain =
      Map<String, dynamic> temptry = {};
      for (int j = 0; j < datasetmaintemp.length; j++) {
        temptry["$j"] = datasetmaintemp["$j"].data;
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
    curretnassessmentdocref = await oldrepo.getassessmentdocid(asessmentdoc);
    notifyListeners();
  }

  getstatuspatient(type, role) {
    (type == 'new') ? assessdisplay = true : assessdisplay = false;
    role = role;
    getdocset(type, role);
    notifyListeners();
  }

  getoldassess() async {
    docs = await oldrepo.getassessments();
    notifyListeners();
  }

  getfielddata(String uid) async {
    data2 = await oldrepo.getfielddata(uid);
    notifyListeners();
    return data2;
  }

  getuid() async {
    getq = await oldrepo.getcurrentuid();
    notifyListeners();
  }

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
