import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gopher_eye/image_data.dart';
import 'package:gopher_eye/plant_capture.dart';
import 'package:gopher_eye/plant_info.dart';
import 'package:gopher_eye/screens/camera_screen.dart';
import 'package:gopher_eye/screens/result_screen.dart';
import 'package:gopher_eye/services/api.dart';
import 'package:gopher_eye/services/app_database.dart';
import 'package:gopher_eye/widgets/camera_capture_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.plantId}) : super(key: key);
  final String? plantId;

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ApiServiceController api = ApiServiceController();
  List<ImageData> plantProcessedInfoList = [];

//   @override
//   void initState() {
//     super.initState();
//     _updatePage();
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        toolbarHeight: 80,
        elevation: 3,
        title: const SafeArea(
          minimum: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
          child: Text(
            "Gopher Eye",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Identify Your Diseases!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                CameraCaptureCard(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Preview Results',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ResultScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "view all",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: plantProcessedInfoList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ListTile(
                              leading: Image.file(
                                File(plantProcessedInfoList[index].image!),
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                              title: const Text(
                                "Date",
                                style: TextStyle(fontSize: 12),
                              ),
                              subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "View Result",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 3.0),
                                  Chip(
                                    backgroundColor: Colors.teal,
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      side:
                                          const BorderSide(color: Colors.teal),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                    ),
                                    label: const Text(
                                      "Complete",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                                size: 30.0,
                                color: Colors.black,
                              ),
                              tileColor: Colors.transparent,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlantInfo(
                                      plantInfo: plantProcessedInfoList[index],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePage() async {
    while (true) {
      AppDatabase.getAllImages().then((images) {
        List<ImageData> updatedList = [];
        for (ImageData image in images) {
          if (image.status == 'complete' &&
              image.image != '' &&
              image.image != null) {
            updatedList.add(image);
          }
        }
        setState(() {
          plantProcessedInfoList = updatedList;
        });
      });

      await Future.delayed(const Duration(seconds: 5));
    }
  }
}
