import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Formsrepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../constants.dart';

class LivingArrangementsProvider extends ChangeNotifier {
  stt.SpeechToText _speech;
  bool _isListening = false;
  TimeOfDay time1;
  TimeOfDay time2;
  TimeOfDay picked1;
  TimeOfDay picked2;
  bool available = false;
  Map<String, Color> colorsset = {};
  final firestoreInstance = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, TextEditingController> _controllers = {};
  Map<String, TextEditingController> _controllerstreco = {};
  Map<String, bool> isListening = {};
  bool cur = true;
  int roomatecount = 0;
  int flightcount = 0;
  Color colorb = Color.fromRGBO(10, 80, 106, 1);
  String type;
  String roomname;
  var accessname;
  List<Map<String, dynamic>> wholelist;
  String imageName = '';
  String imageDownloadUrl;
  String imageUrl;
  File image;
  bool isImageSelected = false;
  List<String> mediaList = [];
  String videoName = '';
  String videoDownloadUrl;
  String selectedRequestId;
  String videoUrl;
  File video;
  bool isVideoSelected = false;

  LivingArrangementsProvider(this.roomname, this.wholelist, this.accessname) {
    print('helo');
    time1 = TimeOfDay.now();
    time2 = TimeOfDay.now();
    _speech = stt.SpeechToText();
    for (int i = 0; i < wholelist[1][accessname]['question'].length; i++) {
      _controllers["field${i + 1}"] = TextEditingController();
      _controllerstreco["field${i + 1}"] = TextEditingController();
      isListening["field${i + 1}"] = false;
      _controllers["field${i + 1}"].text =
          wholelist[1][accessname]['question']["${i + 1}"]['Recommendation'];
      _controllerstreco["field${i + 1}"].text =
          '${wholelist[1][accessname]['question']["${i + 1}"]['Recommendationthera']}';
      colorsset["field${i + 1}"] = Color.fromRGBO(10, 80, 106, 1);
    }
    getRole();
    setinitialsdata();
  }

  Future<Null> selectTime1(BuildContext context) async {
    picked1 = await showTimePicker(context: context, initialTime: time1);

    if (picked1 != null) {
      time1 = picked1;
      wholelist[1][accessname]['question']["4"]['Alone']['From'] = time1;
      notifyListeners();
    }
  }

  Future<Null> selectTime2(BuildContext context) async {
    picked2 = await showTimePicker(context: context, initialTime: time2);

    if (picked2 != null) {
      time2 = picked2;
      wholelist[1][accessname]['question']["4"]['Alone']['Till'] = time2;
      notifyListeners();
    }
  }

  Future<void> setinitialsdata() async {
    if (wholelist[1][accessname].containsKey('isSave')) {
    } else {
      wholelist[1][accessname]["isSave"] = true;
    }
    if (wholelist[1][accessname].containsKey('videos')) {
      if (wholelist[1][accessname]['videos'].containsKey('name')) {
      } else {
        wholelist[1][accessname]['videos']['name'] = "";
      }
      if (wholelist[1][accessname]['videos'].containsKey('url')) {
      } else {
        wholelist[1][accessname]['videos']['url'] = "";
      }
    } else {
      // print('Yes,it is');

      wholelist[1][accessname]["videos"] = {'name': '', 'url': ''};
    }
    if (wholelist[1][accessname]['question']["2"].containsKey('Modetrnas')) {
    } else {
      wholelist[1][accessname]['question']["2"]['Modetrnas'] = '';
      wholelist[1][accessname]['question']["2"]['Modetrnasother'] = '';
      notifyListeners();
    }

    if (wholelist[1][accessname]['question']["4"].containsKey('Alone')) {
      if (wholelist[1][accessname]['question']["4"]['Alone']
          .containsKey('From')) {
        // time1 = int.parse(wholelist[1][widget.accessname]['question']["4"]
        //     ['Alone']['From']);
        time1 = TimeOfDay(
            hour: int.parse(wholelist[1][accessname]['question']["4"]['Alone']
                    ['From']
                .split(":")[0]),
            minute: int.parse(wholelist[1][accessname]['question']["4"]['Alone']
                    ['From']
                .split(":")[1]));
      }
      if (wholelist[1][accessname]['question']["4"]['Alone']
          .containsKey('Till')) {
        time2 = TimeOfDay(
            hour: int.parse(wholelist[1][accessname]['question']["4"]['Alone']
                    ['Till']
                .split(":")[0]),
            minute: int.parse(wholelist[1][accessname]['question']["4"]['Alone']
                    ['Till']
                .split(":")[1]));
      }

      notifyListeners();
    } else {
      wholelist[1][accessname]['question']["4"]['Alone'] = {};
      notifyListeners();
    }

    if (wholelist[1][accessname]['question']['5'].containsKey('toggle')) {
      if (wholelist[1][accessname]['question']["5"]['Answer'].length == 0) {
        setdata(5, 'Yes', 'Has Room-mate?');
      }
      notifyListeners();
    } else {
      wholelist[1][accessname]['question']['5']['toggle'] = <bool>[true, false];
      if (wholelist[1][accessname]['question']["5"]['Answer'].length == 0) {
        setdata(5, 'Yes', 'Has Room-mate?');
      }
      notifyListeners();
    }

    if (wholelist[1][accessname]['question']["5"].containsKey('Roomate')) {
      if (wholelist[1][accessname]['question']["5"]['Roomate']
          .containsKey('count')) {
        roomatecount =
            wholelist[1][accessname]['question']["5"]['Roomate']['count'];
        notifyListeners();
      }
    } else {
      print('Yes,it is');

      wholelist[1][accessname]['question']["5"]['Roomate'] = {};
      notifyListeners();
    }

    if (wholelist[1][accessname]['question']['7'].containsKey('toggle')) {
      if (wholelist[1][accessname]['question']["7"]['Answer'].length == 0) {
        setdata(7, 'Yes', 'Using assistive device?');
      }
      notifyListeners();
    } else {
      wholelist[1][accessname]['question']['7']['toggle'] = <bool>[true, false];
      if (wholelist[1][accessname]['question']["7"]['Answer'].length == 0) {
        setdata(7, 'Yes', 'Using assistive device?');
      }
      notifyListeners();
    }

    if (wholelist[1][accessname]['question']["11"].containsKey('Flights')) {
      if (wholelist[1][accessname]['question']["11"]['Flights']
          .containsKey('count')) {
        flightcount =
            wholelist[1][accessname]['question']["11"]['Flights']["count"];
      }
      notifyListeners();
    } else {
      wholelist[1][accessname]['question']["11"]['Flights'] = {};
      wholelist[1][accessname]['question']["11"]['Answer'] = 0;
      notifyListeners();
    }

    if (wholelist[1][accessname]['question']['12'].containsKey('toggle')) {
      if (wholelist[1][accessname]['question']["12"]['Answer'].length == 0) {
        setdata(
            12, 'Yes', 'Smoke detector batteries checked annually/replaced?');
      }
      notifyListeners();
    } else {
      wholelist[1][accessname]['question']['12']
          ['toggle'] = <bool>[true, false];
      if (wholelist[1][accessname]['question']["12"]['Answer'].length == 0) {
        setdata(
            12, 'Yes', 'Smoke detector batteries checked annually/replaced?');
      }
      notifyListeners();
    }
  }

  Future<void> getRole() async {
    var runtimeType;
    final User useruid = await _auth.currentUser;
    firestoreInstance.collection("users").doc(useruid.uid).get().then((value) {
      runtimeType = value.data()['role'].runtimeType.toString();
      print("runtime Type: $runtimeType");
      if (runtimeType == "List<dynamic>") {
        for (int i = 0; i < value.data()["role"].length; i++) {
          if (value.data()["role"][i].toString() == "therapist") {
            type = "therapist";
          }
        }
      } else {
        type = value.data()["role"];
      }
    });

    notifyListeners();
  }

  Future<void> addVideo(String path) {
    video = File(path);
    videoName = basename(video.path);
    isVideoSelected = true;
    notifyListeners();
  }

  void _showSnackBar(snackbar, BuildContext buildContext) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 3),
      content: Container(
        height: 30.0,
        child: Center(
          child: Text(
            '$snackbar',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
          ),
        ),
      ),
      backgroundColor: lightBlack(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
    );
    ScaffoldMessenger.of(buildContext)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  Future<void> addImage(String path) {
    image = File(path);
    imageName = basename(image.path);
    isImageSelected = true;
    notifyListeners();
  }

  void deleteImage() {
    image = null;
    imageName = '';
    isImageSelected = false;
    notifyListeners();
  }

  void addMedia(String url) {
    if (mediaList.length < 3) {
      mediaList.add(url);
      notifyListeners();
    }
  }

  void deleteMedia(int index) {
    mediaList.removeAt(index);
    notifyListeners();
  }

  Future<String> uploadImage(image) async {
    try {
      String name = 'applicationImages/' + DateTime.now().toIso8601String();
      final ref = FirebaseStorage.instance.ref().child(name);
      ref.putFile(image);
      String url = (await ref.getDownloadURL()).toString();
      imageDownloadUrl = url;
      print(imageDownloadUrl);
      return imageDownloadUrl;
    } catch (e) {
      print(e.toString());
    }
  }
  // String name = 'applicationImages/' + DateTime.now().toIso8601String();
  // final ref = FirebaseStorage.instance.ref().child(name);
  // ref.putFile(image);
  // String url = await ref.getDownloadURL();
  // imageDownloadUrl = url;
  // return imageDownloadUrl;

  // Future chooseFile() async {
  //   final picker = ImagePicker();
  //   String path =
  //       (await picker.getImage(source: ImageSource.gallery, imageQuality: 40))
  //           .path;

  //   uploadFile(File(path));
  // }

  Future uploadFile(List<File> image) async {
    try {
      for (var img in image) {
        print("***********this is the line of error************");
        String url = await uploadImage(img);
        mediaList.add(url);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future deleteFile(String imagePath, context) async {
    String imagePath1 = 'asssessmentImages/' + imagePath;
    try {
      // FirebaseStorage.instance
      //     .ref()
      //     .child(imagePath1)
      //     .delete()
      //     .then((_) => print('Successfully deleted $imagePath storage item'));
      Reference ref = await FirebaseStorage.instance.refFromURL(imagePath);
      ref.delete();

      // FirebaseStorage firebaseStorege = FirebaseStorage.instance;
      // StorageReference storageReference = firebaseStorege.getReferenceFromUrl(imagePath);

      print('deleteFile(): file deleted');
      // return url;
    } catch (e) {
      print('  deleteFile(): error: ${e.toString()}');
      throw (e.toString());
    }
  }

  setdata(index, String value, que) {
    wholelist[1][accessname]['question']["$index"]['Question'] = que;
    if (value.length == 0) {
      if (wholelist[1][accessname]['question']["$index"]['Answer'].length ==
          0) {
      } else {
        wholelist[1][accessname]['complete'] -= 1;
        wholelist[1][accessname]['question']["$index"]['Answer'] = value;
        notifyListeners();
      }
    } else {
      if (wholelist[1][accessname]['question']["$index"]['Answer'].length ==
          0) {
        wholelist[1][accessname]['complete'] += 1;
        notifyListeners();
      }

      wholelist[1][accessname]['question']["$index"]['Answer'] = value;
      notifyListeners();
    }
  }

  setFlightData(index, int value, que) {
    wholelist[1][accessname]['question']["$index"]['Question'] = que;
    if (value == 0) {
      if (wholelist[1][accessname]['question']["$index"]['Answer'] == 0) {
      } else {
        wholelist[1][accessname]['complete'] -= 1;
        wholelist[1][accessname]['question']["$index"]['Answer'] = value;
      }
      notifyListeners();
    } else {
      if (wholelist[1][accessname]['question']["$index"]['Answer'] == 0) {
        wholelist[1][accessname]['complete'] += 1;
      }
      wholelist[1][accessname]['question']["$index"]['Answer'] = value;
      notifyListeners();
    }
  }

  setreco(index, value) {
    wholelist[1][accessname]['question']["$index"]['Recommendation'] = value;
    notifyListeners();
  }

  getvalue(index) {
    return wholelist[1][accessname]['question']["$index"]['Answer'];
  }

  getreco(index) {
    return wholelist[1][accessname]['question']["$index"]['Recommendation'];
  }

  setprio(index, value) {
    wholelist[1][accessname]['question']["$index"]['Priority'] = value;
    notifyListeners();
  }

  getprio(index) {
    return wholelist[1][accessname]['question']["$index"]['Priority'];
  }

  setrecothera(index, value) {
    wholelist[1][accessname]['question']["$index"]['Recommendationthera'] =
        value;
    notifyListeners();
  }

  getrecothera(index) {
    return wholelist[1][accessname]['question']["$index"]
        ['Recommendationthera'];
  }
}
