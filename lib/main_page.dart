import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_saver/files.dart';
import 'package:gopher_eye/app_database.dart';
import 'package:gopher_eye/image_data.dart';
import 'package:gopher_eye/plant_capture.dart';
import 'package:gopher_eye/plant_info.dart';
import 'package:gopher_eye/settings.dart';
import 'package:http/http.dart' as http;

import 'api.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.plantId});
  final String? plantId;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ApiServiceController api = ApiServiceController();
  // list of items
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
          title: const Text(
            "Welcome, User",
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          automaticallyImplyLeading: true,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.green),
              onPressed: () {
                // Navigate to the settings page when the settings icon is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Settings(),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: double.infinity,
                  height: 150.0,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10.0)),
                  margin: const EdgeInsets.all(16.0),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Identify crop diseases Instantly!",
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            decorationStyle: TextDecorationStyle.wavy,
                            fontWeight: FontWeight.normal,
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                        // bottom right  add arrow icon
                      ],
                    ),
                  ),
                ),
              ),
              // Add a ListView with cards to display the list of items in the plantProcessedInfoList
              Expanded(
                child: ListView.builder(
                  itemCount: plantProcessedInfoList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Navigate to the plant_info page when a card is tapped on the list of items
                        // send the plant info to the plant_info page with current index
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlantInfo(
                              plantInfo: plantProcessedInfoList[index],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        // Define the shape of the card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        // Define how the card's content should be clipped
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        // Define the child widget of the card
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Add padding around the row widget
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Add an image widget to display an image
                                  Image.file(
                                    File(plantProcessedInfoList[index].image!),
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  // Add some spacing between the image and the text
                                  Container(width: 20),
                                  // Add an expanded widget to take up the remaining horizontal space
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        // Add some spacing between the top of the card and the title
                                        Container(height: 5),
                                        // Add some spacing between the title and the subtitle
                                        Container(height: 5),
                                        // Add a subtitle widget
                                        Text(
                                          plantProcessedInfoList[index].status!,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => {
            // navigate to the camera page when the floating action button is pressed
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const PlantCapture()))
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.camera_alt, color: Colors.white),
        ));
  }

  Future<void> _updatePage() async {
    while (true) {
      AppDatabase.getAllImages().then((images) {
        List<ImageData> updatedList = [];
        for (ImageData image in images) {
          if (image.status == 'complete' && image.image != '' && image.image != null) {
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
