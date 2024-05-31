// ignore_for_file: must_be_immutable

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:gopher_eye/api.dart';
import 'package:gopher_eye/preview_list_screen.dart';

class PreviewPage extends StatelessWidget {
  PreviewPage({super.key, required this.picture});
  final ApiServiceController controller = Get.put(ApiServiceController());

  final XFile picture;
  bool imageUploadConfirmed = false;
  void uploadImageData(XFile picture) async {
    imageUploadConfirmed = (await controller.sendImage(File(picture.path)));
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
                  File(picture.path),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.7,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Text(picture.name),
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
                          uploadImageData(picture);
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PreviewListScreen()));
                      },
                      child: const Text("Preview"),
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
