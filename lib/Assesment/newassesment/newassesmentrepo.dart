import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewAssesmentRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot dataset;

  Future<String> getcurrentuid() async {
    final User user = await _auth.currentUser;
    String useruid = user.uid;
    // print(useruid);
    return useruid;
  }

  Future<QuerySnapshot> getassessmentdata() async {
    dataset = await firestore
        .collection('Assessments')
        .where('Therapist', isEqualTo: await getcurrentuid())
        .get();
    return dataset;
  }

  Future<void> setassessmentstatus(assessmentdoc) async {
    var res = await firestore.collection('assessments').doc(assessmentdoc).set({
      "status": 'old',
    }, SetOptions(merge: true));
  }

  Future<void> setForm(List<Map<String, dynamic>> list, docID) async {
    await firestore
        .collection("assessments")
        .doc(docID)
        .set({"form": list}, SetOptions(merge: true));
  }

  Future<void> setAssessmentCompletionDate(docID) async {
    await firestore.collection("assessments").doc(docID).set(
        {"assessmentCompletionDate": Timestamp.now()}, SetOptions(merge: true));
  }

  Future<void> updateAssessor(uid, docID) async {
    await firestore
        .collection("assessments")
        .doc(docID)
        .update({"assessor": uid});
  }

  Future<void> updateClosureDate(Timestamp date, docID) async {
    await firestore
        .collection("assessments")
        .doc(docID)
        .update({"closureDate": date});
  }

  Future<void> updateHome(home, docID) async {
    await firestore.collection("assessments").doc(docID).update({"home": home});
  }

  Future<void> setLatestChangeDate(docID) async {
    await firestore
        .collection("assessments")
        .doc(docID)
        .set({"latestChangeDate": Timestamp.now()}, SetOptions(merge: true));
  }

  Future<void> updatePatient(uid, docID) async {
    await firestore
        .collection("assessments")
        .doc(docID)
        .update({"patient": uid});
  }

  Future<void> updateScheduleDate(Timestamp date, docID) async {
    await firestore
        .collection("assessments")
        .doc(docID)
        .update({"scheduleDate": date});
  }

  Future<void> setStatus(status, docID) async {
    await firestore
        .collection("assessments")
        .doc(docID)
        .set({"status": status}, SetOptions(merge: true));
  }

  Future<void> updateTherapist(uid, docID) async {
    await firestore
        .collection("assessments")
        .doc(docID)
        .update({"therapist": uid});
  }

  Future<void> updateTimeslot(timeslot, docID) async {
    await firestore
        .collection("assessments")
        .doc(docID)
        .update({"timeslot": timeslot});
  }

  Future<void> setAssessmentCurrentStatus(String status, docID) async {
    await firestore
        .collection("assessments")
        .doc(docID)
        .set({"currentStatus": status}, SetOptions(merge: true));
  }

  Future<String> setAssessmentData() async {
    String docId = await firestore.collection("assessments").doc().id;
    var res = await firestore.collection('assessments').doc(docId).set({
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
    }, SetOptions(merge: true));
    return docId.toString();
  }
}
