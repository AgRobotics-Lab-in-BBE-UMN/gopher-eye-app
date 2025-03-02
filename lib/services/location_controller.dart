import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationController extends GetxController {
  var latestPhoto = Rx<XFile?>(null);
  var latestCoords = Rx<LatLng?>(null);

  void updateLatestLocation(double latitude, double longitude, XFile photo) {
    latestCoords.value = LatLng(latitude, longitude);
    latestPhoto.value = photo;
  }
}
