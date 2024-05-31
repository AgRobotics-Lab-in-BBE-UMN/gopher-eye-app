import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingDialogController extends GetxController {
  var isLoading = false.obs;

  void showLoadingDialog() {
    isLoading.value = true;

    Get.defaultDialog(
      title: "",
      backgroundColor: Colors.white,
      content: Obx(() {
        return isLoading.value
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Loading..."),
                ],
              )
            : Container();
      }),
      barrierDismissible: false,
    );

    // Simulate a delay for loading
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.back(); // Close the dialog
    });
  }
}
