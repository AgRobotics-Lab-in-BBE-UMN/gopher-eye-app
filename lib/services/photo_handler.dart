import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';
import 'package:rational/rational.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class PhotoHandler {
  final ImagePicker _picker = ImagePicker();
  late Database _database;

  Future<String> getCoordsFromPhoto(XFile? photo) async {
    if (photo != null) {
      final File imageFile = File(photo.path);
      final Map<String, IfdTag> exifData =
          await readExifFromBytes(await imageFile.readAsBytes());
      double? latitude;
      double? longitude;
      String photoId = photo.name;

      // print("FLAG EXIF Keys: ${exifData.keys.toList()}");
      if (exifData.containsKey('GPS GPSLatitude') &&
          exifData.containsKey('GPS GPSLongitude')) {
        latitude = _convertToDegree(exifData['GPS GPSLatitude']!.values);
        longitude = _convertToDegree(exifData['GPS GPSLongitude']!.values);

        if (exifData['GPS GPSLatitudeRef']!.printable.contains('S')) {
          latitude = -latitude;
        }
        if (exifData['GPS GPSLongitudeRef']!.printable.contains('W')) {
          longitude = -longitude;
        }
        return "Lat: $latitude, Lng: $longitude";
      } else {
        return "Error: No GPS data in the photo.";
      }
    } else {
      return "Error: There is no selected photo";
    }
  }

  double _convertToDegree(IfdValues values) {
    final List ratios = values.toList();
    final degrees = ratios[0].toDouble();
    final minutes = ratios[1].toDouble();
    final seconds = ratios[2].toDouble();
    return degrees + (minutes / 60) + (seconds / 3600);
  }
}
