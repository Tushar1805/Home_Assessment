import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NurseRepository {
  Firestore firestore = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  QuerySnapshot dataset;
  QuerySnapshot datasetorder;

  void getUserData() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    firestore
        .collection("users")
        .document(firebaseUser.uid)
        .get()
        .then((value) {
      // print('karUn');
      // print(value.data);
    });
  }

  Future<String> getcurrentuid() async {
    final FirebaseUser user = await _auth.currentUser();
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
  //   var assess = firestore
  //       .collection('assessments')
  //       .where('assessor', isEqualTo: useruid.uid)
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
        .where('assessor', isEqualTo: user.uid)
        .getDocuments();
    return dataset;

    // return dataset;
  }

  Future<DocumentSnapshot> getfielddata(String uid) async {
    var data = await firestore.collection('users').document(uid).get();
    return data;
  }

  Future<String> getassessmentdocid(asessmentdoc) async {
    return asessmentdoc.reference.documentID;
    // dataset.documents.forEach((e) => print(e.reference.documentID));
  }

  // Future<Stream<QuerySnapshot>> getassessments() async {
  //   var assess = firestore
  //       .collection('assessments')
  //       .where('therapist', isEqualTo: getcurrentuid())
  //       .snapshots();

  //   return assess;
  // }
}
