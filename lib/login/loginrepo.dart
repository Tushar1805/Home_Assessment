import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  String type;
  // FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getUserData() async {
    User firebaseUser = await FirebaseAuth.instance.currentUser;
    firestoreInstance
        .collection("users")
        .doc(firebaseUser.uid)
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
    firestoreInstance.collection("users").doc(uid).get().then((value) {
      typeuser = (value['role'].toString());
    });
    return typeuser;
  }

  //signup with email and password
  Future register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User useer = result.user;
      if (useer != null) {
        return useer.uid;
      } else {
        return null;
      }
    } catch (e) {}
  }

  Future login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User useer = result.user;
      print("******************result: $result**************");

      if (useer != null) {
        return useer.uid;
      } else {
        return null;
      }
    } catch (e) {}
  }
}
