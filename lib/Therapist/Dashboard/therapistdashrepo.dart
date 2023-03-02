import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TherapistRepository {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  QuerySnapshot dataset;
  QuerySnapshot statusDataset;
  DocumentSnapshot feedback;
  QuerySnapshot datasetorder;
  QuerySnapshot scheduledAssessments;
  QuerySnapshot pendingAssessments;
  QuerySnapshot pendingAssessments2;
  QuerySnapshot closedAssessments;

  Future<String> getcurrentuid() async {
    final User user = await _auth.currentUser;
    String useruid = user.uid;
    // print(useruid);
    return useruid;
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
  //       .where('therapist', isEqualTo: useruid.uid)
  //       .getDocuments()
  //       .then((value) => value.documents.forEach((element) {
  //             list.add(element.data);
  //           }));

  //   return list;
  // }
  Future<QuerySnapshot> getAssessments(role) async {
    User user = _auth.currentUser;

    dataset = await firestore
        .collection('assessments')
        .where('therapist', isEqualTo: user.uid)
        .orderBy("date", descending: true)
        .get();
    return dataset;

    // return dataset;
  }

  // Get Scheduled Assessments
  Future<QuerySnapshot> getScheduledAssessments(role) async {
    User user = _auth.currentUser;

    scheduledAssessments = await firestore
        .collection('assessments')
        .where('therapist', isEqualTo: user.uid)
        .where('currentStatus', isEqualTo: "Assessment Scheduled")
        .orderBy("date", descending: true)
        .get();
    return scheduledAssessments;

    // return dataset;
  }

  // Get all pending assessment which are filled by patients and therapist itself
  Future<QuerySnapshot> getPendingAssessments(role) async {
    User user = _auth.currentUser;

    pendingAssessments = await firestore
        .collection('assessments')
        .where('therapist', isEqualTo: user.uid)
        .where(
          'currentStatus',
          isEqualTo: 'Assessment Finished',
        )
        .orderBy("date", descending: true)
        .get();

    pendingAssessments2 = await firestore
        .collection('assessments')
        .where('therapist', isEqualTo: user.uid)
        .where(
          'currentStatus',
          isEqualTo: 'Assessment in Progress',
        )
        .orderBy("date", descending: true)
        .get();

    await pendingAssessments.docs.addAll(pendingAssessments2.docs);
    return pendingAssessments;

    // return dataset;
  }

  // Get all pending assessment which are filled by patients and therapist itself
  Future<QuerySnapshot> getPendingAssessments2(role) async {
    User user = _auth.currentUser;

    pendingAssessments2 = await firestore
        .collection('assessments')
        .where('therapist', isEqualTo: user.uid)
        .where(
          'currentStatus',
          isEqualTo: 'Assessment Finished',
        )
        .orderBy("date", descending: true)
        .get();
    return pendingAssessments2;

    // return dataset;
  }

  // Get all the closed assessments for the therapist
  Future<QuerySnapshot> getClosedAssessments(role) async {
    User user = _auth.currentUser;

    closedAssessments = await firestore
        .collection('assessments')
        .where('therapist', isEqualTo: user.uid)
        .where('currentStatus', isEqualTo: 'Report Generated')
        .orderBy("date", descending: true)
        .get();
    return closedAssessments;

    // return dataset;
  }

  Future<QuerySnapshot> getAssessmentStatus() async {
    User user = _auth.currentUser;
    statusDataset = await firestore
        .collection('assessments')
        .where('therapist', isEqualTo: user.uid)
        .where('status', isEqualTo: 'new')
        .orderBy("date", descending: true)
        .get();
    return statusDataset;
  }

  Future<DocumentSnapshot> getFeedback() async {
    User user = _auth.currentUser;

    feedback = (await firestore.collection('users').doc(user.uid).get());
    return feedback;

    // return dataset;
  }

  Future<String> getassessmentdocid(asessmentdoc) async {
    return asessmentdoc.reference.documentID;
    // dataset.documents.forEach((e) => print(e.reference.documentID));
  }

  void getUserData() async {
    User firebaseUser = await FirebaseAuth.instance.currentUser;
    firestore.collection("users").doc(firebaseUser.uid).get().then((value) {
      print('karUn');
      print(value.data);
    });
  }

  Future<DocumentSnapshot> getfielddata(String uid) async {
    var data = await firestore.collection('users').doc(uid).get();
    return data;
  }
}
