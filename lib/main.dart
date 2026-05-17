import 'package:flutter/material.dart';
import 'package:pakeeza_pos/app.dart';
import 'package:pakeeza_pos/data/database/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.initializeFfi();
  runApp(const PakeezaPosApp());
}
