import 'package:flutter/material.dart';
import './newassesmentrepo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewAssesmentProvider extends ChangeNotifier {
  final NewAssesmentRepository newRepo = NewAssesmentRepository();

  final FirebaseAuth auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> listofRooms = [];
  var assessmentdatalist;
  var assessmentdoc;

  NewAssesmentProvider(this.assessmentdoc) {
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

  List<Map<String, dynamic>> getlistdata() {
    return listofRooms;
  }

  getassessmentdata() async {
    assessmentdatalist = await newRepo.getassessmentdata();
    notifyListeners();
  }

  setassessmainstatus() async {
    newRepo.setassessmentstatus(assessmentdoc);
  }
}

gettotal(String classname) {
  if (classname == 'Garage') {
    return 13;
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
    return 11;
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

getMaps(String classname) {
  int total = gettotal(classname);
  Map rr = {};
  for (int i = 1; i <= total; i++) {
    rr[i] = {
      'Answer': '',
      'Priority': '1',
      'Recommendation': '',
      'Recommendationthera': '',
      'additional': {}
    };
  }
  return rr;
}

Widget getinfo() {
  return Text(
    '?',
    style: TextStyle(
      color: Colors.blueAccent,
    ),
  );
}

String capitalize(String s) {
  var parts = s.split(' ');
  print(parts);
  String sum = '';
  parts
      .forEach((cur) => {sum += cur[0].toUpperCase() + cur.substring(1) + " "});
  return sum;
}
