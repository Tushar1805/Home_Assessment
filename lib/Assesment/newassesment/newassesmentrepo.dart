import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewAssesmentRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore firestore = Firestore.instance;
  QuerySnapshot dataset;

  Future<String> getcurrentuid() async {
    final FirebaseUser user = await _auth.currentUser();
    String useruid = user.uid;
    // print(useruid);
    return useruid;
  }

  Future<QuerySnapshot> getassessmentdata() async {
    dataset = await firestore
        .collection('Assessments')
        .where('Therapist', isEqualTo: await getcurrentuid())
        .getDocuments();
    return dataset;
  }

  Future<void> setassessmentstatus(assessmentdoc) async {
    var res = await firestore
        .collection('Assessments')
        .document(assessmentdoc)
        .updateData({
      "Status": 'old',
    });
  }
}
