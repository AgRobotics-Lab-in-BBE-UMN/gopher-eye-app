import 'package:flutter/material.dart';
import 'package:gopher_eye/main_page.dart';
import 'package:gopher_eye/synchronizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initPreferences();
  AppDatabase.initDatabase();
  SharedPreferences.getInstance().then((prefs) async {
    while (prefs.getString('serverUrl') == null) {
      await Future.delayed(const Duration(seconds: 1));
    }
    Synchronizer synchronizer =
        Synchronizer(apiUrl: prefs.getString('serverUrl')!);
    synchronizer.syncData();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Plant Disease Detection App',
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

void _initPreferences() {
  SharedPreferences.getInstance().then((prefs) {
    if (prefs.getString('serverUrl') == null) {
      prefs.setString('serverUrl', 'gopher-eye.com');
    }
  });
}
