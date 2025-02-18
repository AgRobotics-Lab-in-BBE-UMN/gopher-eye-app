// ignore_for_file: must_be_immutable

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:gopher_eye/services/api.dart';
import 'package:gopher_eye/services/photo_handler.dart';

class PreviewPage extends StatefulWidget {
  PreviewPage({super.key, required this.picture, required this.coordSource});
  final XFile picture;
  final String coordSource;

  @override
  PreviewPageState createState() => PreviewPageState();
}

class PreviewPageState extends State<PreviewPage> {
  final ApiServiceController controller = Get.put(ApiServiceController());
  
  static const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 1,
    timeLimit: Duration(seconds: 5),
  );

  Future<String> getCoordsFromPhone() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error("Location permission is permanently denied.");
      }
    }

    Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);

    return "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
  }

  bool imageUploadConfirmed = false;
  final PhotoHandler _photoHandler = PhotoHandler();
  String coordinates = "";

  @override
  void initState() {
    super.initState();
    loadCoords();
  }

  void loadCoords() async {
    String coords = widget.coordSource == "photo"
      ? await _photoHandler.getCoordsFromPhoto(widget.picture)
      : await getCoordsFromPhone();
    setState(() {
      // updating coordinates
      coordinates = coords;
    });
  }

  void uploadImageData(XFile picture) async {
    imageUploadConfirmed =
        (await controller.sendImage(File(picture.path))).isNotEmpty;
    if (imageUploadConfirmed) {
      controller.isSuccess.value = imageUploadConfirmed;
      debugPrint("Image upload successfully");
    } else {
      debugPrint("Image upload Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Upload Image')),
        body: Center(
          child: Obx(() {
            if (controller.isLoading.value) {
              // Show the loading dialog
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!controller.isDialogShowing) {
                  _showLoadingDialog(context, false);
                  controller.isDialogShowing = true;
                }
              });
            } else if (controller.isSuccess.value) {
              // Show the success dialog
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (controller.isDialogShowing) {
                  _dismissLoadingDialog(context);
                  controller.isDialogShowing = false;
                }
                _showLoadingDialog(context, true);
                controller.isDialogShowing = true;
              });
            } else {
              // Dismiss the loading dialog
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (controller.isDialogShowing) {
                  _dismissLoadingDialog(context);
                  controller.isDialogShowing = false;
                }
              });
            }
            return Center(
              child: Column(children: [
                Image.file(
                  File(widget.picture.path),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.6,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Text(widget.picture.name),
                Text(coordinates),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: _buildCircularButton(Colors.red, Icons.clear)),
                    GestureDetector(
                        onTap: () {
                          uploadImageData(widget.picture);
                        },
                        child: _buildCircularButton(Colors.green, Icons.done)),
                  ],
                )
              ]),
            );
          }),
        ));
  }
}

void _showLoadingDialog(BuildContext context, bool isSuccess) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isSuccess
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Image Upload Successfully"),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // dismiss the dialog
                        _dismissLoadingDialog(context);
                        // navigate to the PreviewListScreen
                        Navigator.pop(context);
                      },
                      child: const Text("Return to Camera"),
                    ),
                  ],
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text("Uploading Image..."),
                  ],
                ),
        ),
      );
    },
  );
}

void _dismissLoadingDialog(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
}

Widget _buildCircularButton(MaterialColor materialColor, IconData iconData) {
  return Container(
    width: 60, // Adjust width as needed
    height: 60, // Adjust height as needed
    decoration: BoxDecoration(
      color: materialColor,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Icon(
        iconData,
        color: Colors.white,
      ),
    ),
  );
}
