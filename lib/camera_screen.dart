import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:gopher_eye/camera_provider.dart';
import 'package:gopher_eye/widgets/QR_Feature/main2.dart';
import 'package:gopher_eye/widgets/qr_result_screen.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CameraStack();
}

class _CameraStack extends State<CameraScreen> {
  XFile? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CameraProvider>(
        builder: (context, provider, child) {
          if (!provider.isInitialized) {
            provider.initializeCameras();
            return const Center(child: CircularProgressIndicator());
          }

          return image == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(
                                  provider.isFlashOn
                                      ? Icons.flash_on
                                      : Icons.flash_off,
                                  color: Colors.white,
                                ),
                                onPressed: provider.toggleFlash,
                              ),
                              const Icon(
                                Icons.settings_rounded,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              CameraPreview(provider.controller!),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildIconButton(
                                        icon: Icons.photo_library,
                                        size: 40,
                                        onPressed: () async {
                                          await provider.galleryImage(context);
                                          setState(() {
                                            image = provider.pickedImage;
                                          });
                                        },
                                      ),
                                      _buildIconButton(
                                          icon: Icons.qr_code_scanner,
                                          size: 40,
                                          onPressed: () {
                                            if (provider.isInitialized) {
                                              provider.disposeCameras();
                                              provider.dispose();
                                            }
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const QRViewExample(),
                                              ),
                                            );
                                            // qrScanner();
                                          }),
                                      _buildIconButton(
                                        icon: Icons.camera_alt_rounded,
                                        size: 40,
                                        onPressed: () async {
                                          await provider.captureImage(context);
                                          setState(() {
                                            image = provider.pickedImage;
                                          });
                                        },
                                      ),
                                      _buildIconButton(
                                        icon: Icons.loop_rounded,
                                        size: 40,
                                        onPressed: provider.switchCamera,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: Image.file(File(image!.path))),
                        Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildActionIconButton(
                                color: Colors.red,
                                icon: Icons.close_rounded,
                                onPressed: () {
                                  setState(() {
                                    image = null;
                                  });
                                },
                              ),
                              _buildActionIconButton(
                                color: Colors.green,
                                icon: Icons.check_rounded,
                                onPressed: () {
                                  provider.showUploadDialog(
                                      context, image!.path);
                                  GallerySaver.saveImage(image!.path);
                                },
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
    );
  }

  Widget _buildIconButton(
      {required IconData icon,
      required double size,
      required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.0),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: size),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildActionIconButton(
      {required Color color,
      required IconData icon,
      required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 2.0),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 40),
        onPressed: onPressed,
      ),
    );
  }

  Future<void> qrScanner() async {
    String result;
    result = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", false, ScanMode.QR);
    debugPrint(result);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QrResultScreen(qrResult: result)));
  }
}
