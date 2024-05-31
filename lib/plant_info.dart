import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gopher_eye/GetImageDataResponse.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PlantInfo extends StatelessWidget {
  const PlantInfo({super.key, required this.plantInfo});

  final GetImageDataResponse plantInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Plant Information",
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(plantInfo.image!),
                    const SizedBox(height: 10.0),
                    Text(
                      "Name: ${plantInfo.segmentation}",
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      "Description: ${plantInfo.segmentation}",
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      "Status: ${plantInfo.status}",
                    ),
                    const SizedBox(height: 10.0),
                    if (plantInfo.status == 'completed')
                      Text(
                        "disease: ${plantInfo.segmentation}",
                      ),
                    const SizedBox(height: 10.0),
                    if (plantInfo.status == 'completed')
                      Text(
                        "Plant Cure: ${plantInfo.segmentation}",
                      ),
                    const SizedBox(height: 10.0),
                    // Add a button to fetch the plant status
                    ElevatedButton(
                      onPressed: () async {
                        if (plantInfo.id == null) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          var plantId = prefs.getString('plant_id');
                          if (plantId != null) {
                            final status = await fetchPlantStatus(plantId);
                            if (status != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Plant status: $status'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to fetch plant status'),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Plant ID not found'),
                              ),
                            );
                          }
                        } else {
                          final status = await fetchPlantStatus(plantInfo.id!);
                          if (status != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Plant status: $status'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to fetch plant status'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Center(child: Text('Fetch Plant Status')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> fetchPlantStatus(String plantId) async {
    final url = Uri.parse('http://192.168.1.77:5000/plant/status');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'plant_id': plantId});

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['status'];
      } else {
        print('Failed to fetch plant status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error occurred while fetching plant status: $e');
      return null;
    }
  }
}
