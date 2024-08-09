import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gopher_eye/home_screen.dart';
import 'package:gopher_eye/services/api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraProvider with ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isFlashOn = false;
  bool _isInitialized = false;
  CameraController? get controller => _controller;
  bool get isFlashOn => _isFlashOn;
  bool get isInitialized => _isInitialized;

  XFile? pickedImage;

  Future<void> initializeCameras() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _controller = CameraController(
        _cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller?.initialize();

      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> disposeCameras() async {
    _cameras = await availableCameras();
    _cameras.clear();
    await _controller?.dispose();

    _isInitialized = false;
    notifyListeners();
  }

  //* switching camera

  void switchCamera() async {
    if (_cameras.isEmpty) return;

    int currentIndex = _cameras.indexOf(_controller!.description);
    int newIndex = (currentIndex + 1) % _cameras.length;
    _controller = CameraController(
      _cameras[newIndex],
      ResolutionPreset.high,
    );
    await _controller?.initialize();
    notifyListeners();
  }

  //* flash function
  void toggleFlash() {
    _isFlashOn = !_isFlashOn;
    _controller?.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    notifyListeners();
  }

  //* image capture
  Future<void> captureImage(context) async {
    final XFile image = await _controller!.takePicture();
    pickedImage = image;
    notifyListeners();
  }

//*Gallery Image Picker

  Future<void> galleryImage(context) async {
    final picker = ImagePicker();
    var pickedImages = await picker.pickImage(source: ImageSource.gallery);
    pickedImage = pickedImages;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller?.dispose();

    super.dispose();
  }

  //* Upload section --------------------------------------------------------------

  Future<void> showUploadDialog(BuildContext context, String imagePath) async {
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

    await Future.delayed(const Duration(seconds: 2));

    var success = await uploadImage(context, imagePath);
    Navigator.pop(context);

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      var plantId = prefs.getString('plant_id');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(plantId: plantId),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<bool> uploadImage(BuildContext context, String imagePath) async {
    try {
      File imageFile = File(imagePath);
      ApiServiceController apiServiceController = ApiServiceController();
      String plantId = await apiServiceController.sendImage(imageFile);

      if (!plantId.isEmpty) {
        // Print plant_id
        print('Plant ID: $plantId');

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

  //*QR Code
}
