import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gopher_eye/providers/plot_provider.dart';
import 'package:gopher_eye/screens/login_screen.dart';
import 'package:gopher_eye/screens/home_screen.dart';
import 'package:gopher_eye/services/synchronizer.dart';
import 'package:gopher_eye/utils/firebase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gopher_eye/services/app_database.dart';
// import 'package:gopher_eye/app_database.dart';
// import 'package:gopher_eye/synchronizer.dart';
import 'package:provider/provider.dart';

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
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String username = prefs.getString('username') ?? '';
  String password = prefs.getString('password') ?? '';
  bool loggedIn = await signIn(username, password);

  Widget screen = loggedIn ? const HomeScreen() : const LoginScreen();
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (context) => PlotProvider())],
    child: MyApp(screen: screen),
  ));
}

class MyApp extends StatelessWidget {
  final Widget screen;
  
  const MyApp({super.key, required this.screen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Gopher Eye Detection",
        home: screen);
    // home: HomeScreen());
  }
}

void _initPreferences() {
  SharedPreferences.getInstance().then((prefs) {
    if (prefs.getString('serverUrl') == null) {
      prefs.setString('serverUrl', 'gopher-eye.com');
    }
  });
}
