import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gopher_eye/camera_screen.dart';
import 'package:gopher_eye/image_data.dart';
import 'package:gopher_eye/plant_info.dart';
import 'package:gopher_eye/screens/result_screen.dart';
import 'package:gopher_eye/services/api.dart';
import 'package:gopher_eye/services/app_database.dart';
import 'package:gopher_eye/widgets/fields_feature/field_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.plantId});
  final String? plantId;

  @override
  State<StatefulWidget> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  ApiServiceController api = ApiServiceController();
  List<ImageData> plantProcessedInfoList = [];

  @override
  void initState() {
    super.initState();
    _updatePage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        toolbarHeight: 80,
        elevation: 3,
        automaticallyImplyLeading: false,
        title: const SafeArea(
          minimum: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
          child: Text(
            "Gopher Eye",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FieldScreen(),
                    ));
              },
              child: const Text("Fields")),
          // IconButton(
          //     onPressed: () {
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (context) => const ExcelScreen(),
          //           ));
          //     },
          //     icon: const Icon(Icons.library_add_outlined)),

          // IconButton(
          //     onPressed: () {Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (context) => const FieldScreen(),
          //           ));}, icon: const Icon(Icons.note_alt_rounded)),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Identify Your Diseases!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Column(
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/images/take_a_picture.png'),
                                    width: 40,
                                    height: 50,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Take a'),
                                  Text('Picture'),
                                ],
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 60,
                                color: Colors.blueGrey,
                              ),
                              Column(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/diagnosis.svg",
                                    width: 40,
                                    height: 50,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('See'),
                                  const Text('diagnosis'),
                                ],
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: Colors.blueGrey, size: 60),
                              const Column(
                                children: [
                                  Image(
                                      image: AssetImage(
                                          'assets/images/get_medicine.png'),
                                      width: 40,
                                      height: 50),
                                  SizedBox(height: 8),
                                  Text('Get'),
                                  Text('medicine'),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: MaterialButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CameraScreen(),
                                  ),
                                );
                              },
                              color: const Color.fromARGB(255, 13, 108, 186),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 90, vertical: 6),
                                child: Text(
                                  "Take a Picture",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                      const SizedBox(height: 8),
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
                      ),
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
                                  const Text(
                                    "View Diagnosis",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18),
                                  ),
                                  const SizedBox(height: 3.0),
                                  Chip(
                                    surfaceTintColor: Colors.red,
                                    elevation: 6,
                                    shape: const RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.teal),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0))),
                                    label: Text(
                                      plantProcessedInfoList[index].status!,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 13),
                                    ),
                                  ),
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
                                        plantInfo:
                                            plantProcessedInfoList[index]),
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
