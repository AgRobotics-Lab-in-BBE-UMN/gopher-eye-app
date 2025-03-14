import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gopher_eye/services/app_database.dart';
import 'package:intl/intl.dart';

class LocationController extends GetxController {
  var latestPhoto = Rxn<XFile>();
  var latestCoords = Rxn<LatLng>();

  Future<void> updateLatestLocation(
      double latitude, double longitude, XFile photo) async {
    latestCoords.value = LatLng(latitude, longitude);
    latestPhoto.value = photo;
    String photoId = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    await AppDatabase.insertPhotoCoords(photoId, latitude, longitude);
  }
}
