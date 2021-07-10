import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TherapistRepository {
  Firestore firestoreInstance = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getcurrentuid() async {
    final FirebaseUser user = await _auth.currentUser();
    String useruid = user.uid;
    // print(useruid);
    return useruid;
  }

  Future<List> getassessments() async {
    final FirebaseUser useruid = await _auth.currentUser();
    // String uid;
    //  await getcurrentuid().then((value) =>
    //    setState(() {
    //    if (value is String)
    //         uid = value.toString(); //use toString to convert as String
    // }););
    List list = [];
    var assess = firestoreInstance
        .collection('assessments')
        .where('therapist', isEqualTo: useruid.uid)
        .getDocuments()
        .then((value) => value.documents.forEach((element) {
              list.add(element.data);
            }));

    return list;
  }

  Future<String> getassessmentdocid(asessmentdoc) async {
    return asessmentdoc.reference.documentID;
    // dataset.documents.forEach((e) => print(e.reference.documentID));
  }

  void getUserData() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    firestoreInstance
        .collection("users")
        .document(firebaseUser.uid)
        .get()
        .then((value) {
      print('karUn');
      print(value.data);
    });
  }

  Future<DocumentSnapshot> getfielddata(String uid) async {
    var data = await firestoreInstance.collection('users').document(uid).get();
    return data;
  }
}
