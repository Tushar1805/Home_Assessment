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
        .collection('assessments')
        .document(assessmentdoc)
        .setData({
      "status": 'old',
    }, merge: true);
  }

  Future<void> setForm(List<Map<String, dynamic>> list, docID) async {
    await firestore
        .collection("assessments")
        .document(docID)
        .setData({"form": list}, merge: true);
  }

  Future<void> setAssessmentCompletionDate(docID) async {
    await firestore
        .collection("assessments")
        .document(docID)
        .setData({"assessmentCompletionDate": Timestamp.now()}, merge: true);
  }

  Future<void> updateAssessor(uid, docID) async {
    await firestore
        .collection("assessments")
        .document(docID)
        .updateData({"assessor": uid});
  }

  Future<void> updateClosureDate(Timestamp date, docID) async {
    await firestore
        .collection("assessments")
        .document(docID)
        .updateData({"closureDate": date});
  }

  Future<void> updateHome(home, docID) async {
    await firestore
        .collection("assessments")
        .document(docID)
        .updateData({"home": home});
  }

  Future<void> setLatestChangeDate(docID) async {
    await firestore
        .collection("assessments")
        .document(docID)
        .setData({"latestChangeDate": Timestamp.now()}, merge: true);
  }

  Future<void> updatePatient(uid, docID) async {
    await firestore
        .collection("assessments")
        .document(docID)
        .updateData({"latestChangeDate": uid});
  }

  Future<void> updateScheduleDate(Timestamp date, docID) async {
    await firestore
        .collection("assessments")
        .document(docID)
        .updateData({"scheduleDate": date});
  }

  Future<void> setStatus(status, docID) async {
    await firestore
        .collection("assessments")
        .document(docID)
        .setData({"status": status}, merge: true);
  }

  Future<void> updateTherapist(uid, docID) async {
    await firestore
        .collection("assessments")
        .document(docID)
        .updateData({"therapist": uid});
  }

  Future<void> updateTimeslot(timeslot, docID) async {
    await firestore
        .collection("assessments")
        .document(docID)
        .updateData({"timeslot": timeslot});
  }

  Future<void> setAssessmentCurrentStatus(String status, docID) async {
    await firestore
        .collection("assessments")
        .document(docID)
        .setData({"currentStatus": status}, merge: true);
  }

  Future<String> setAssessmentData() async {
    String docId =
        await firestore.collection("assessments").document().documentID;
    var res =
        await firestore.collection('assessments').document(docId).setData({
      // "form": list,
      "assessmentCompletionDate": "",
      "assessor": "",
      "closureDate": "",
      "currentStatus": "",
      "home": "",
      "latestChangeDate": "",
      "patient": "",
      "scheduleDate": "",
      "status": "",
      "therapist": "",
      "timeslot": "",
      "docID": docId,
    });
    return docId.toString();
  }
}
