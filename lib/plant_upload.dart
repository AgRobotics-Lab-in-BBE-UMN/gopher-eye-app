// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gopher_eye/services/api.dart';
import 'package:gopher_eye/screens/main_screen.dart';
// import 'package:gopher_eye/api.dart';
import 'package:gopher_eye/home_screen.dart';
import 'package:gopher_eye/main_page.dart';
import 'package:gopher_eye/plant_capture.dart';
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
    try {
      File imageFile = File(imagePath);
      ApiServiceController apiServiceController = ApiServiceController();
      String plantId = await apiServiceController.sendImage(imageFile);

      if (plantId.isNotEmpty) {
        // Print plant_id
        if (kDebugMode) {
          print('Plant ID: $plantId');
        }

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
      prefs.getString('plant_id');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
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
