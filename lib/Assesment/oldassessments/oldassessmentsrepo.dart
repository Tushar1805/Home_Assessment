import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OldAssessmentRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore firestore = Firestore.instance;
  QuerySnapshot dataset;
  QuerySnapshot datasetorder;

  Future<String> getcurrentuid() async {
    final FirebaseUser user = await _auth.currentUser();
    String useruid = user.uid;
    // print(useruid);
    return useruid;
  }

  Future<QuerySnapshot> getpatients(type, role) async {
    FirebaseUser user = await _auth.currentUser();
    if (role == "therapist") {
      dataset = await firestore
          .collection('assessments')
          .where('therapist', isEqualTo: user.uid)
          .where('status', isEqualTo: type)
          .getDocuments();
      return dataset;
    } else if (role == "nurse/case manager") {
      dataset = await firestore
          .collection('assessments')
          .where('assessor', isEqualTo: user.uid)
          .where('status', isEqualTo: type)
          .getDocuments();
      return dataset;
    }
    // return dataset;
  }

  Future<QuerySnapshot> getpatientsorder(type) async {
    // QuerySnapshot datasetds = await firestore
    //     .collection('users')
    //     .where('role', isEqualTo: 'patient')
    //     .orderBy('age')
    //     .getDocuments();
    datasetorder = await firestore
        .collection('assessments')
        .where('therapist', isEqualTo: await getcurrentuid())
        .where('status', isEqualTo: type)
        .getDocuments();
    print(datasetorder.documents[0].data);

    // print(dataset.documents[0].data['Patient']);
    // return dataset;
  }

  Future<String> getassessmentdocid(asessmentdoc) async {
    return asessmentdoc.reference.documentID;
    // dataset.documents.forEach((e) => print(e.reference.documentID));
  }

  Future<Stream<QuerySnapshot>> getassessments() async {
    var assess = firestore
        .collection('assessments')
        .where('therapist', isEqualTo: getcurrentuid())
        .snapshots();

    return assess;
  }

  Future<DocumentSnapshot> getfielddata(String uid) async {
    var data = await firestore.collection('users').document(uid).get();
    return data;
  }
}



//firestore
            // .collection('Assessments')
            // .where('Therapist', isEqualTo: assesspro.getq)
            // .where('Status', isEqualTo: "old")
            // .snapshots(),
