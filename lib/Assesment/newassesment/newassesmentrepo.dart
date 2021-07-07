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
        .updateData({
      "Status": 'old',
    });
  }

  Future<void> updateForm(List<Map<String, dynamic>> list, docID) async {
    await firestore
        .collection("assessments")
        .document(docID)
        .updateData({"form": list});
  }

  Future<void> updateAssessmentCompletionDate(Timestamp date, docID) async {
    await firestore
        .collection("assessments")
        .document(docID)
        .updateData({"assessmentCompletionDate": date});
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

  Future<void> updateLatestChangeDate(Timestamp date, docID) async {
    await firestore
        .collection("assessments")
        .document(docID)
        .updateData({"latestChangeDate": date});
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

  Future<void> updateStatus(status, docID) async {
    await firestore
        .collection("assessments")
        .document(docID)
        .updateData({"status": status});
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
