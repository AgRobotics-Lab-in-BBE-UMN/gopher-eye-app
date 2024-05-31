import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:gopher_eye/plant_upload.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class PlantCapture extends StatefulWidget {
  const PlantCapture({super.key});
  @override
  State<PlantCapture> createState() => _PlantCaptureState();
}

class _PlantCaptureState extends State<PlantCapture> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isCameraPermissionGranted = false;
  late List<CameraDescription> cameras;
  int selectedCameraIndex = 0;
  bool isCapturing = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      _initializeCamera();
    } else {
      await Permission.camera.request();
      if (await Permission.camera.isGranted) {
        _initializeCamera();
      } else {
        setState(() {
          _isCameraPermissionGranted = false;
        });
      }
    }
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras[selectedCameraIndex],
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
    setState(() {
      _isCameraPermissionGranted = true;
    });
  }

  void _switchCamera() {
    selectedCameraIndex = selectedCameraIndex == 0 ? 1 : 0;
    _initializeCamera();
  }

  Future<void> _captureImage() async {
    final CameraController cameraController = _controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return;
    }

    try {
      setState(() {
        isCapturing = true;
      });

      XFile file = await cameraController.takePicture();
      await GallerySaver.saveImage(file.path);
      setState(() {
        isCapturing = false;
      });

      _navigateToUploadScreen(file.path);
    } on CameraException catch (e) {
      log(e.toString());
      setState(() {
        isCapturing = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Handle the selected image here
      log('Image selected: ${pickedFile.path}');
      _navigateToUploadScreen(pickedFile.path);
    }
  }

  Future<void> _navigateToUploadScreen(String imagePath) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlantUploadScreen(imagePath: imagePath),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Capture'),
      ),
      body: _isCameraPermissionGranted
          ? Stack(
              children: [
                FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CameraPreview(_controller);
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                if (isCapturing)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                Positioned(
                  bottom: 30.0,
                  left: 30.0,
                  child: FloatingActionButton(
                    onPressed: _pickImageFromGallery,
                    child: const Icon(Icons.photo),
                  ),
                ),
                Positioned(
                  bottom: 30.0,
                  left: MediaQuery.of(context).size.width / 2 - 30,
                  child: FloatingActionButton(
                    onPressed: _captureImage,
                    child: const Icon(Icons.camera),
                  ),
                ),
                Positioned(
                  bottom: 30.0,
                  right: 30.0,
                  child: FloatingActionButton(
                    onPressed: _switchCamera,
                    child: const Icon(Icons.switch_camera),
                  ),
                ),
              ],
            )
          : const Center(
              child: Text('Camera permission not granted'),
            ),
    );
  }
}
