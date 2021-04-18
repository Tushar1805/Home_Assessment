import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestoreInstance = Firestore.instance;
  String type;
  // FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getUserData() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    firestoreInstance
        .collection("users")
        .document(firebaseUser.uid)
        .get()
        .then((value) {
      print('karUn');
      // String type = value.data['role'];
    });
    return type;
  }

  Future<String> getPage(uid) async {
    String typeuser;
    // FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    firestoreInstance.collection("users").document(uid).get().then((value) {
      typeuser = (value.data['role'].toString());
    });
    return typeuser;
  }

  //signup with email and password
  Future register(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser useer = result.user;
      if (useer != null) {
        return useer.uid;
      } else {
        return null;
      }
    } catch (e) {}
  }

  Future login(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser useer = result.user;

      if (useer != null) {
        return useer.uid;
      } else {
        return null;
      }
    } catch (e) {}
  }
}
