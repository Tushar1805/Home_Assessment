import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NurseRepository {
  Firestore firestoreInstance = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

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
        .where('assessor', isEqualTo: useruid.uid)
        .getDocuments()
        .then((value) => value.documents.forEach((element) {
              list.add(element.data);
            }));

    return list;
  }

  Future<DocumentSnapshot> getfielddata(String uid) async {
    var data = await firestoreInstance.collection('users').document(uid).get();
    return data;
  }
}
