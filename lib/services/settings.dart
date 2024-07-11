import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String? serverUrl;
  final TextEditingController txt = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getServerUrl();
  }

  void _saveServerUrl(String serverUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('serverUrl', serverUrl).then((_) => setState(() {
          this.serverUrl = serverUrl;
          txt.text = serverUrl;
        }));
  }

  void _getServerUrl() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        serverUrl = prefs.getString('serverUrl');
        txt.text = serverUrl ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter server URL',
          ),
          controller: txt,
          onSubmitted: (value) {
            _saveServerUrl(value);
          },
        ),
      ),
    );
  }
}
