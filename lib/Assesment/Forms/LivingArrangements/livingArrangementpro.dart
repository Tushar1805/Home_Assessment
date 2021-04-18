import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryapp/Assesment/Forms/Formsrepo.dart';

class LivingArrangementsProvider extends ChangeNotifier {
  final FormsRepository formsRepository = FormsRepository();

  final FirebaseAuth auth = FirebaseAuth.instance;
}
