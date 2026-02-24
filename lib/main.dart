import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'services/local_db.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Init Hive + your local DB (settings/profile/recordings)
  await Hive.initFlutter();
  await LocalDb.init();

  runApp(const MyApp());
}
