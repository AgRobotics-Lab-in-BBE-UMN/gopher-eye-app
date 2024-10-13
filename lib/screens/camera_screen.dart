// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:gopher_eye/preview_page.dart';
import 'package:gopher_eye/providers/plot_provider.dart';
import 'package:gopher_eye/widgets/mobile_scanner_with_overlay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  List<CameraDescription>? cameras;
  CameraController? controller;
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;

  // Initial values
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = true;
  FlashMode? _currentFlashMode;

  List<File> allFileList = [];

  getPermissionStatus() async {
    await Permission.camera.request();
    var status = await Permission.camera.status;

    if (status.isGranted) {
      log('Camera Permission: GRANTED');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      // Set and initialize the new camera
      onNewCameraSelected(cameras![0]);
    } else {
      log('Camera Permission: DENIED');
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      await GallerySaver.saveImage(file.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Image saved to gallery"),
          backgroundColor: Colors.black,
          action: SnackBarAction(
            label: 'OK',
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            textColor: Colors.white,
          ),
        ),
      );

      return file;
    } on CameraException catch (e) {
      log(e.toString());
      return null;
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      await cameraController
          .lockCaptureOrientation(DeviceOrientation.portraitUp);

      _currentFlashMode = controller!.value.flashMode;
    } on CameraException catch (e) {
      log(e.toString());
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Hide the status bar in Android
    _initializeCamera();
    getPermissionStatus();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PreviewPage(
                      picture: pickedFile,
                    )));
      }
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    onNewCameraSelected(cameras[0]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    controller?.dispose();
    super.dispose();
  }

  Widget _buildCameraPreview(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var previewRatio = width / height;
    return Expanded(child: Stack(children: [
      AspectRatio(
          aspectRatio: previewRatio,
          child: ClipRect(
              child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                      width: controller?.value.previewSize!.height,
                      height: controller?.value.previewSize!.width,
                      child: CameraPreview(
                        controller!,
                        key: const Key('camera_preview'),
                      ))))),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.only(bottom: 60.0),
          color: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGalleyButton(),
              _buildCaptureButton(context),
              _buildQRScannerButton()
            ],
          ))),
    ]));
  }

  InkWell _buildQRScannerButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MobileScannerWithOverlay(),
          ),
        );
      },
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.circle,
            color: Colors.black38,
            size: 60,
          ),
          Icon(
            Icons.qr_code,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    );
  }

  InkWell _buildCaptureButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        XFile? rawImage = await takePicture();

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PreviewPage(
                      picture: rawImage!,
                    )));
      },
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.circle,
            color: Colors.white38,
            size: 80,
          ),
          Icon(
            Icons.circle,
            color: Colors.white,
            size: 65,
          ),
        ],
      ),
    );
  }

  InkWell _buildCameraSwitchButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _isCameraInitialized = false;
        });
        onNewCameraSelected(cameras![_isRearCameraSelected ? 1 : 0]);
        setState(() {
          _isRearCameraSelected = !_isRearCameraSelected;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.circle,
            color: Colors.black38,
            size: 60,
          ),
          Icon(
            _isRearCameraSelected ? Icons.camera_front : Icons.camera_rear,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    );
  }

  InkWell _buildGalleyButton() {
    return InkWell(
      onTap: () {
        _getImageFromGallery();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            image: _imageFile != null
                ? DecorationImage(
                    image: FileImage(_imageFile!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Consumer<PlotProvider>(builder: (context, plot, child) => Text('Camera: Site ${plot.plot}')),
            backgroundColor: Colors.transparent,
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
            leading: const BackButton(
              color: Colors.white,
            )),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: _isCameraPermissionGranted
            ? _isCameraInitialized
                ? Column(
                    children: [
                      _buildCameraPreview(context)
                      // _flashButtonsRibbon(),
                    ],
                  )
                : const Center(
                    child: Text(
                      'LOADING',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Row(),
                  const Text(
                    'Permission denied',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      getPermissionStatus();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Give permission',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Padding _flashButtonsRibbon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 50.0),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              // 0.0,  8.0, 0.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () async {
                      setState(() {
                        _currentFlashMode = FlashMode.off;
                      });
                      await controller!.setFlashMode(
                        FlashMode.off,
                      );
                    },
                    child: Icon(
                      Icons.flash_off,
                      color: _currentFlashMode == FlashMode.off
                          ? Colors.amber
                          : Colors.white,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        _currentFlashMode = FlashMode.auto;
                      });
                      await controller!.setFlashMode(
                        FlashMode.auto,
                      );
                    },
                    child: Icon(
                      Icons.flash_auto,
                      color: _currentFlashMode == FlashMode.auto
                          ? Colors.amber
                          : Colors.white,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        _currentFlashMode = FlashMode.always;
                      });
                      await controller!.setFlashMode(
                        FlashMode.always,
                      );
                    },
                    child: Icon(
                      Icons.flash_on,
                      color: _currentFlashMode == FlashMode.always
                          ? Colors.amber
                          : Colors.white,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        _currentFlashMode = FlashMode.torch;
                      });
                      await controller!.setFlashMode(
                        FlashMode.torch,
                      );
                    },
                    child: Icon(
                      Icons.highlight,
                      color: _currentFlashMode == FlashMode.torch
                          ? Colors.amber
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
