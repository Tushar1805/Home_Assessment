import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tryapp/Assesment/Forms/LivingArrangements/livingArrangementpro.dart';
import 'package:path/path.dart';
import 'package:tryapp/Therapist/Dashboard/therapistdash.dart';

import 'Nurse_Case_Manager/Dashboard/nursedash.dart';
import 'Patient_Caregiver_Family/Dashboard/patientdash.dart';
import 'constants.dart';

class ViewPhoto extends StatefulWidget {
  String imgUrl, role;
  ViewPhoto(this.imgUrl, this.role);
  @override
  _ViewPhotoState createState() => _ViewPhotoState();
}

class _ViewPhotoState extends State<ViewPhoto> {
  String imageDownloadUrl, imageUrl, imageName;
  File image;
  bool uploading = false;

  String getName(String path) {
    RegExp exp = RegExp('\/((?:.(?!\/))+\$)');
    String fileName = exp.firstMatch(path).group(1);
    print(fileName); // image1.png
  }

  Future<void> setPhoto(String url) async {
    final FirebaseUser useruid = await FirebaseAuth.instance.currentUser();
    await Firestore.instance
        .collection("users")
        .document(useruid.uid)
        .setData({'url': url}, merge: true);
  }

  Future<void> upload(File image, BuildContext context) async {
    setState(() {
      uploading = true;
    });
    try {
      print("*************Uploading Image************");
      String name = 'applicationImages/' + DateTime.now().toIso8601String();
      StorageReference ref = FirebaseStorage.instance.ref().child(name);

      StorageUploadTask upload = ref.putFile(image);
      String url =
          (await (await upload.onComplete).ref.getDownloadURL()).toString();
      setState(() {
        imageUrl = url;
        print("************Url = $imageUrl**********");
        imageName = basename(image.path);
        print("************Url = $imageName**********");
        setPhoto(imageUrl);
        uploading = false;
        if (widget.role == "therapist") {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Therapist()));
        } else if (widget.role == "nurse/case manager") {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Nurse()));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Patient()));
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future deleteFile(String imagePath) async {
    String imagePath1 = 'asssessmentImages/' + imagePath;
    try {
      // FirebaseStorage.instance
      //     .ref()
      //     .child(imagePath1)
      //     .delete()
      //     .then((_) => print('Successfully deleted $imagePath storage item'));
      StorageReference ref = await FirebaseStorage.instance
          .ref()
          .getStorage()
          .getReferenceFromUrl(imagePath);
      ref.delete();

      // FirebaseStorage firebaseStorege = FirebaseStorage.instance;
      // StorageReference storageReference = firebaseStorege.getReferenceFromUrl(imagePath);

      print('deleteFile(): file deleted');
      setPhoto("");
      // return url;
    } catch (e) {
      print('  deleteFile(): error: ${e.toString()}');
      throw (e.toString());
    }
  }

  void deleteVideo() {
    setState(() {
      image = null;
      imageUrl = '';
      widget.imgUrl = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    // final provider = widget.provider;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          automaticallyImplyLeading: false,
          backwardsCompatibility: false,
          actions: [
            IconButton(
              tooltip: "Edit Profile Photo",
              icon: Icon(Icons.photo_camera_back, color: Colors.white),
              onPressed: () async {
                (widget.imgUrl != "" && widget.imgUrl != null)
                    ? await deleteFile(widget.imgUrl)
                    : null;
                final pickedImage =
                    await ImagePicker().getImage(source: ImageSource.gallery);
                if (pickedImage != null) {
                  setState(() async {
                    await upload(File(pickedImage?.path), context);
                  });
                } else {
                  // Navigator.pop(context);
                  setState(() {});
                  final snackBar =
                      SnackBar(content: Text('Image Not Selected!'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
            (widget.imgUrl != "" && widget.imgUrl != null)
                ? IconButton(
                    tooltip: "Delete Profile Photo",
                    icon: Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: () async {
                      await deleteFile(widget.imgUrl);
                      if (widget.role == "therapist") {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => Therapist()));
                      } else if (widget.role == "nurse/case manager") {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Nurse()));
                      } else {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Patient()));
                      }
                    })
                : Container(),
          ],
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Color.fromRGBO(10, 80, 106, 1), // status bar color
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light, //status bar brigtness
          ),
          flexibleSpace: Container(
            width: MediaQuery.of(context).size.width,
            child: new Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 40, bottom: 10.0),
              child: Row(
                children: [
                  IconButton(
                      tooltip: "Back",
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text("Edit Profile photo", style: titleBarWhiteTextStyle()),
                ],
              ),
            ),
            decoration: new BoxDecoration(
              color: Color.fromRGBO(10, 80, 106, 1),
            ),
          ),
        ),
        body: (uploading)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : (widget.imgUrl != "" && widget.imgUrl != null)
                ? Container(
                    child: Center(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: PhotoView(
                          backgroundDecoration:
                              BoxDecoration(color: Colors.white),
                          loadingChild: loading(),
                          imageProvider: (widget.imgUrl.isNotEmpty)
                              ? new NetworkImage(widget.imgUrl)
                              : null,
                        )),
                  ))
                : Container(
                    child: Center(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 70,
                          child: ClipOval(
                            child: (widget.role == "therapist")
                                ? Image.asset('assets/therapistavatar.png')
                                : (widget.role == "nurse/case manager")
                                    ? Image.asset('assets/nurseavatar.png')
                                    : Image.asset('assets/patientavatar.png'),
                          ),
                        )),
                  ))
        // : Container(
        //     child: Center(
        //     child: SizedBox(
        //         width: MediaQuery.of(context).size.width,
        //         child: PhotoView(
        //           backgroundDecoration: BoxDecoration(color: Colors.white),
        //           loadingChild: loading(),
        //           imageProvider: (widget.imgUrl.isNotEmpty)
        //               ? NetworkImage(widget.imgUrl)
        //               : null,
        //         )),
        // ))
        );
  }
}
