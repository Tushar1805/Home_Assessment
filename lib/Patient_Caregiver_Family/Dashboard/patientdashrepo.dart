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
        .where('patient', isEqualTo: useruid.uid)
        .getDocuments()
        .then((value) => value.documents.forEach((element) {
              list.add(element.data);
            }));

    return list;
  }

  Future<String> saveInDatabase(
      String patientUid, String time, DateTime date) async {
    String docId =
        await firestoreInstance.collection("assessments").document().documentID;
    var res = await firestoreInstance
        .collection('assessments')
        .document(docId)
        .setData({
      "form": "",
      "assessmentCompletionDate": "",
      "assessor": "",
      "closureDate": "",
      "currentStatus": "Assessment Scheduled",
      "home": "",
      "latestChangeDate": "",
      "patient": patientUid,
      "scheduleDate": Timestamp.now(),
      "status": "old",
      "therapist": "",
      "timeslot": {"preferredDate": date, "prefferedTime": time},
      "docID": docId,
    });
    return docId.toString();
  }

  Future<DocumentSnapshot> getfielddata(String uid) async {
    var data = await firestoreInstance.collection('users').document(uid).get();
    return data;
  }
}
