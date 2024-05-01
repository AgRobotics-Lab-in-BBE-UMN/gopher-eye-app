import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gopher_eye/chatbot_page.dart';
import 'camera_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: SafeArea(
        child:
        Center(
            child: 
              Column(
                  children: [ElevatedButton(
                onPressed: () async {
                  await availableCameras().then((value) => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => CameraPage(cameras: value))));
                },
                child: const Text("Capture Image"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await availableCameras().then((value) => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ChatbotPage())));
                },
                child: const Text("Chatbot"),
              )]
            )
        )
      ),
    );
  }
}