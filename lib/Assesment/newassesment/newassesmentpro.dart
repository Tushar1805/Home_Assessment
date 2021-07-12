import 'package:flutter/material.dart';
import './newassesmentrepo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewAssesmentProvider extends ChangeNotifier {
  final NewAssesmentRepository newRepo = NewAssesmentRepository();

  final FirebaseAuth auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> listofRooms = [];
  var assessmentdatalist;
  var assessmentdoc;
  var docID;

  ///This function is actual local map where all the data of
  ///asssessment form is saved.
  NewAssesmentProvider(this.docID) {
    this.listofRooms = [
      {
        'name': 'Pathway',
        'count': 0,
        'completed': 7,
      },
      {
        'name': 'Living Arrangements',
        'count': 1,
        'completed': 7,
      },
      {
        'name': 'Living Room',
        'count': 0,
        'completed': 4,
      },
      {
        'name': 'Kitchen',
        'count': 0,
        'completed': 3,
      },
      {
        'name': 'Dining Room',
        'count': 0,
        'completed': 10,
      },
      {
        'name': 'Bathroom',
        'count': 0,
        'completed': 1,
      },
      {
        'name': 'Bedroom',
        'count': 0,
        'completed': 5,
      },
      {
        'name': 'Laundry',
        'count': 0,
        'completed': 10,
      },
      {
        'name': 'Patio',
        'count': 0,
        'completed': 9,
      },
      {
        'name': 'Garage',
        'count': 0,
        'completed': 5,
      },
      {
        'name': 'Warehouse',
        'count': 0,
        'completed': 9,
      },
      {
        'name': 'Swimming Pool',
        'count': 0,
        'completed': 9,
      },
    ];
  }

  /// This is a normal getter function to get the list
  /// of rooms
  List<Map<String, dynamic>> getlistdata() {
    return listofRooms;
  }

  getassessmentdata() async {
    assessmentdatalist = await newRepo.getassessmentdata();
    notifyListeners();
  }

  setassessmainstatus(String docID) async {
    newRepo.setassessmentstatus(docID);
  }

  String capitalize(String s) {
    if (s != null) {
      var parts = s.split(' ');
      // print(parts);
      String sum = '';
      parts.forEach(
          (cur) => {sum += cur[0].toUpperCase() + cur.substring(1) + " "});
      return sum;
    }
  }
}

///This function is to get how many quetions are there
///in a particular room. This helps in areas where we need
///to calculate linear progress bar and create a format which
///is specified in below function
gettotal(String classname) {
  if (classname == 'Garage') {
    return 12;
  } else if (classname == 'Patio') {
    return 12;
  } else if (classname == 'Laundry') {
    return 14;
  } else if (classname == 'Bedroom') {
    return 18;
  } else if (classname == 'Bathroom') {
    return 28;
  } else if (classname == 'Dining Room') {
    return 13;
  } else if (classname == 'Kitchen') {
    return 18;
  } else if (classname == 'Living Room') {
    return 12;
  } else if (classname == 'Living Arrangements') {
    return 14;
  } else if (classname == 'Pathway') {
    return 12;
  } else if (classname == 'Basement') {
    return 5;
  } else if (classname == 'Swimming Pool') {
    return 7;
  }
}

/// This fucntion is used to dynamically create a frame in
/// the list of rooms list/map. As specified in gettotal function
/// it takes number of total questions form that function and
/// creates the frame shown below.
getMaps(String classname) {
  int total = gettotal(classname);
  Map rr = {};
  for (int i = 1; i <= total; i++) {
    /// i stands for the rooms count which we will get from the
    /// gettotal fucntion.
    rr["$i"] = {
      'Question': "",
      'Answer': '',
      'Priority': '1',
      //The data from comments field will get saves here.
      //
      //NOTE/WARNING: dont change this name.. It have been used
      //a lot of area ans is highly dependent.
      'Recommendation': '',

      /// This is the recommendation in therapist form.
      'Recommendationthera': '',
      'additional': {}
    };
  }
  return rr;
}

/// This is the informational icons prachi asked to take care of
/// For now its just a text. you can change it from here it
/// will changed in every spot.
Widget getinfo() {
  return Text(
    '?',
    style: TextStyle(
      color: Colors.blueAccent,
    ),
  );
}

/// This fucntion is used to capitalize every initial
/// of any string feeded as name of the room.
String capitalize(String s) {
  if (s != null) {
    var parts = s.split(' ');
    // print(parts);
    String sum = '';
    parts.forEach(
        (cur) => {sum += cur[0].toUpperCase() + cur.substring(1) + " "});
    return sum;
  }
}
