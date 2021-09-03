import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientRepository {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  QuerySnapshot dataset;
  QuerySnapshot datasetorder;

  getUserData() async {
    User firebaseUser = await FirebaseAuth.instance.currentUser;
    var dataname = await firestore
        .collection("users")
        .doc(firebaseUser.uid)
        .get()
        .then((value) {
      return value['name'];
    });
    return await dataname;
  }

  // Future<List> getassessments() async {
  //   final FirebaseUser useruid = await _auth.currentUser();
  //   // String uid;
  //   //  await getcurrentuid().then((value) =>
  //   //    setState(() {
  //   //    if (value is String)
  //   //         uid = value.toString(); //use toString to convert as String
  //   // }););
  //   List list = [];
  //   var assess = firestoreInstance
  //       .collection('assessments')
  //       .where('patient', isEqualTo: useruid.uid)
  //       .getDocuments()
  //       .then((value) => value.documents.forEach((element) {
  //             list.add(element.data);
  //           }));

  //   return list;
  // }
  Future<QuerySnapshot> getAssessments(role) async {
    User user = await _auth.currentUser;

    dataset = await firestore
        .collection('assessments')
        .where('patient', isEqualTo: user.uid)
        .get();
    return dataset;

    // return dataset;
  }

  Future<DocumentSnapshot> getHomeAddresses(String uid) async {
    var data = await firestore.collection('users').doc(uid).get();
    return data;
  }

  Future<String> getassessmentdocid(asessmentdoc) async {
    return asessmentdoc.reference.documentID;
    // dataset.documents.forEach((e) => print(e.reference.documentID));
  }

  Future<DocumentSnapshot> getfielddata(String uid) async {
    var data = await firestore.collection('users').doc(uid).get();
    return data;
  }

  Future<String> saveInDatabase(
      String patientUid, String time, DateTime date) async {
    String docId = await firestore.collection("assessments").doc().id;
    var res = await firestore.collection('assessments').doc(docId).set({
      "form": "",
      "assessmentCompletionDate": "",
      "assessor": "",
      "closureDate": "",
      "currentStatus": "Assessment Scheduled",
      "home": "",
      "latestChangeDate": "",
      "patient": patientUid,
      "scheduleDate": Timestamp.now(),
      "status": "old",
      "therapist": "",
      "timeslot": {"preferredDate": date, "prefferedTime": time},
      "docID": docId,
    });
    return docId.toString();
  }
}
