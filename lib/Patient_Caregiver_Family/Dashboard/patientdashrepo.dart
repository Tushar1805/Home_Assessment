import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientRepository {
  Firestore firestoreInstance = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  getUserData() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    var dataname = await firestoreInstance
        .collection("users")
        .document(firebaseUser.uid)
        .get()
        .then((value) {
      return value.data['name'];
    });
    return await dataname;
  }
}
