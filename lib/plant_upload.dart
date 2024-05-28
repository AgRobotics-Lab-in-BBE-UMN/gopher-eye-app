// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gopher_eye/main_page.dart';
import 'package:gopher_eye/plant_capture.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PlantUploadScreen extends StatelessWidget {
  final String imagePath;

  const PlantUploadScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.65;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(
              File(imagePath),
              width: double.infinity,
              height: imageHeight,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Image Path: $imagePath',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showUploadDialog(context, imagePath);
              },
              child: const Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _uploadImage(BuildContext context, String imagePath) async {
    const url =
        'http://192.168.1.77:5000/dl/segmentation'; // Replace with your Flask server address

    try {
      var request = http.MultipartRequest('PUT', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        var plantId = jsonResponse['plant_id'];
        // Print plant_id
        print('Plant ID: $plantId');
        // Save plant_id to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('plant_id', plantId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully and plant_id saved.'),
          ),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload image.'),
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred: $e'),
        ),
      );
      return false;
    }
  }

  Future<void> _showUploadDialog(BuildContext context, String imagePath) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Uploading Image'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please wait while the image is being uploaded...'),
                SizedBox(height: 20),
                Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        );
      },
    );

    // Simulate a delay of 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    var success = await _uploadImage(context, imagePath);
    Navigator.pop(context); // Close the dialog after upload completes

    if (success) {
      // Navigate back to MainPage on successful upload
      final prefs = await SharedPreferences.getInstance();
      var plantId = prefs.getString('plant_id');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(plantId: plantId),
        ),
      );
    } else {
      // Navigate back to PlantCapture if there's an error
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PlantCapture()),
      );
    }
  }
}
