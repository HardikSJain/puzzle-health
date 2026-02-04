import 'package:flutter/material.dart';

import 'app.dart';
import 'core/shared_preference/shared_preference_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferenceManager.init();
  runApp(const App());
}
