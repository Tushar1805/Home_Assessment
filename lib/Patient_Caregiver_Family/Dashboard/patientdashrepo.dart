import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientRepository {
  Firestore firestore = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  QuerySnapshot dataset;
  QuerySnapshot datasetorder;

  getUserData() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    var dataname = await firestore
        .collection("users")
        .document(firebaseUser.uid)
        .get()
        .then((value) {
      return value.data['name'];
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
    FirebaseUser user = await _auth.currentUser();

    dataset = await firestore
        .collection('assessments')
        .where('patient', isEqualTo: user.uid)
        .getDocuments();
    return dataset;

    // return dataset;
  }

  Future<String> getassessmentdocid(asessmentdoc) async {
    return asessmentdoc.reference.documentID;
    // dataset.documents.forEach((e) => print(e.reference.documentID));
  }

  Future<DocumentSnapshot> getfielddata(String uid) async {
    var data = await firestore.collection('users').document(uid).get();
    return data;
  }

  Future<String> saveInDatabase(
      String patientUid, String time, DateTime date) async {
    String docId =
        await firestore.collection("assessments").document().documentID;
    var res =
        await firestore.collection('assessments').document(docId).setData({
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
