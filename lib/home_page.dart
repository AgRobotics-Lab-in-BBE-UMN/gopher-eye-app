import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'camera_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text(
          "Welcome, User",
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        )),
        body: SafeArea(
            child: Container(
                height: 250.0,
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(186, 178, 178, 0.45),
                    borderRadius: BorderRadius.circular(10.0)),
                margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                child: Stack(
                  children: [
                    Positioned(
                        top: 10,
                        left: 18,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset(
                            'assets/Btn1_img.jpg',
                            height: 150.0,
                            width: 320.0,
                            fit: BoxFit.fill,
                          ),
                        )),
                    const Positioned(
                      top: 175,
                      left: 20,
                      child: Text(
                        "Identify crop diseases Instantly!",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15.0),
                      ),
                    ),
                    Positioned(
                      left: 240,
                      top: 200,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await availableCameras().then((value) =>
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          CameraPage(cameras: value))));
                        },
                        icon: const Icon(Icons.camera),
                        label: const Text("Snap"),
                      ),
                    )
                  ],
                )

                // body: SafeArea(
                //     child: Center(
                //         child: Column(children: [
                //   ElevatedButton(
                //     onPressed: () async {
                //       await availableCameras().then((value) => Navigator.push(context,
                //           MaterialPageRoute(builder: (_) => CameraPage(cameras: value))));
                //     },
                //     child: const Text("Capture Image"),
                //   ),
                //   ElevatedButton(
                //     onPressed: () async {
                //       await availableCameras().then((value) => Navigator.push(
                //           context, MaterialPageRoute(builder: (_) => ChatbotPage())));
                //     },
                //     child: const Text("Chatbot"),
                //   )
                // ]))                // ),
                )));
  }
}
