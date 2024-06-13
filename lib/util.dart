import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gopher_eye/image_data.dart';
import 'package:gopher_eye/app_database.dart';

// Image getImage(String plantId) {
//   AppDatabase appDatabase = AppDatabase();
//   ImageData? imageData = appDatabase.getImage(plantId);
//   if (imageData != null && imageData.image != null) {
//     return Image.memory(imageData.image!);
//   } else {
//     return Image.asset('assets/placeholder.png');
//   }
// }