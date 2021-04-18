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
}
