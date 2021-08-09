import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Formsrepo.dart';

import 'package:path/path.dart';

class LivingProvider extends ChangeNotifier {
  final FormsRepository formsRepository = FormsRepository();

  final FirebaseAuth auth = FirebaseAuth.instance;
  String videoName = '';
  String videoDownloadUrl;
  String selectedRequestId;
  String videoUrl;
  File video;
  bool isVideoSelected = false;

  Future<void> addVideo(String path) {
    video = File(path);
    videoName = basename(video.path);
    isVideoSelected = true;
    notifyListeners();
  }

  void deleteVideo() {
    video = null;
    videoName = '';
    isVideoSelected = false;
    notifyListeners();
  }

  Future<void> uploadVideo() async {
    try {
      print("*************Uploading Video************");
      String name = 'applicationVideos/' + DateTime.now().toIso8601String();
      StorageReference ref = FirebaseStorage.instance.ref().child(name);

      StorageUploadTask upload = ref.putFile(video);
      String url =
          (await (await upload.onComplete).ref.getDownloadURL()).toString();
      videoDownloadUrl = url;
      print("************Url = $videoDownloadUrl**********");
    } catch (e) {
      print(e.toString());
    }
  }
}
