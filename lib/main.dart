import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gopher_eye/screens/login_screen.dart';
import 'package:gopher_eye/synchronizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
  runApp(const MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(1.0)),
    child: MyApp(),
    // child: MultiProvider(
    //   providers: [
    //   ],
    //   child: const MyApp(),
    // ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Gopher Eye Detection",
      home: LoginScreen(),
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
