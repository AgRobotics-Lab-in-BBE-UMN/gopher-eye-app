import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:gopher_eye/services/api.dart';
import 'package:gopher_eye/services/app_database.dart';
import 'package:gopher_eye/image_data.dart';
import 'package:path_provider/path_provider.dart';

class Synchronizer {
  final String apiUrl;

  Synchronizer({required this.apiUrl});

  Future<void> syncData() async {
    ApiServiceController api = ApiServiceController();

    while (true) {
      List<String> plantIds = await api.getPlantIds();
      for (String plantId in plantIds) {
        try {
          ImageData? imageData = await AppDatabase.getImage(plantId);
          if (imageData == null) {
            imageData = await api.getPlantData(plantId);
            Uint8List imageBytes = await api.getPlantImage(plantId, 'image');
            final directory = await getApplicationDocumentsDirectory();
            final imagePath = '${directory.path}/$plantId.jpg';
            await File(imagePath).writeAsBytes(imageBytes);
            imageData.image = imagePath;
            await AppDatabase.insertImage(imageData);
          } else if (imageData.status != 'complete') {
            ImageData updatedImageData = await api.getPlantData(plantId);
            await AppDatabase.insertBoundingBoxes(
                plantId, updatedImageData.boundingBoxes!);
            await AppDatabase.insertMasks(plantId, updatedImageData.masks!);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Failed to get image data for $plantId: $e');
          }
        }
      }
      await Future.delayed(const Duration(seconds: 30));
    }
  }
}
