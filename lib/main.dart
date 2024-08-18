import 'package:flutter/material.dart';
import 'package:gopher_eye/screens/login_screen.dart';
import 'package:gopher_eye/screens/main_screen.dart';
import 'package:gopher_eye/services/synchronizer.dart';
import 'package:gopher_eye/widgets/fields_feature/field_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gopher_eye/services/app_database.dart';
// import 'package:gopher_eye/app_database.dart';
import 'package:gopher_eye/camera_provider.dart';
import 'package:gopher_eye/camera_provider.dart';
import 'package:gopher_eye/home_screen.dart';
// import 'package:gopher_eye/synchronizer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
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
  runApp(MediaQuery(
    data: const MediaQueryData(textScaler: TextScaler.linear(1.0)),
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CameraProvider()),
        ChangeNotifierProvider(create: (context) => FieldProvider()),
      ],
      child: const MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Gopher Eye Detection",
        // home: LoginScreen()
        home: HomeScreen());
  }
}

void _initPreferences() {
  SharedPreferences.getInstance().then((prefs) {
    if (prefs.getString('serverUrl') == null) {
      prefs.setString('serverUrl', 'gopher-eye.com');
    }
  });
}
