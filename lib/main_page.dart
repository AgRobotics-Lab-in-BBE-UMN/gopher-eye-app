import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gallery_saver/files.dart';
import 'package:gopher_eye/GetImageDataResponse.dart';
import 'package:gopher_eye/plant_capture.dart';
import 'package:gopher_eye/plant_info.dart';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.plantId});
  final String? plantId;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Map<String, dynamic>? _plantData;
  // list of items
  List<GetImageDataResponse> plantProcessedInfoList = List<
          GetImageDataResponse>.generate(
      5,
      (index) =>
          // Generate a list of items with the following properties
          // every item has a unique id, image, segmentation, and status
          // evry 2nd item has a status of 'completed' and the rest have a status of 'pending'
          GetImageDataResponse(
              image: 'assets/Btn1_img.jpg',
              segmentation: 'Plant ${index + 1}',
              status: index % 2 == 0 ? 'completed' : 'pending'));

  @override
  void initState() {
    super.initState();
    if (widget.plantId != null) {
      _fetchPlantData(widget.plantId!);
    }
  }

  Future<void> _fetchPlantData(String plantId) async {
    const url = 'http://192.168.29.249:8000/plant/data';
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'plant_id': plantId});
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      setState(() {
        _plantData = jsonDecode(response.body);
      });
    } else {
      print('Failed to fetch plant data: ${response.statusCode}');
    }
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
                                Image.asset(
                                  plantProcessedInfoList[index].image!,
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
                                      // Add a title widget
                                      Text(
                                        plantProcessedInfoList[index]
                                            .segmentation!,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
          // na vigate to the camera page when the floating action button is pressed
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const PlantCapture()))
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}
