import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gopher_eye/api.dart';
import 'package:gopher_eye/GetImageDataResponse.dart';

void main() {
  test('Test segmentation job submission', () async {
    var api = ApiServiceController();
    final image = File('test_resources/0025.jpg');

    String result = await api.sendImage(image);

    expect(result, isNotEmpty);
  });

  test('Test plant status retrieval', () async {
    var api = ApiServiceController();
    // This is not good. This plantId can change at any time.
    var plantId = "8ef6a0d6-6a75-429f-8a78-7be81d9aaf09";

    var result = await api.getPlantStatus(plantId);

    expect(result, "complete");
  });

  test('Test plant data retrieval', () async {
    var api = ApiServiceController();
    var plantId = "8ef6a0d6-6a75-429f-8a78-7be81d9aaf09";

    GetImageDataResponse result = await api.getPlantData(plantId);

    expect(result.id, plantId);
    expect(result.image, isNotEmpty);
    expect(result.masks, isNotEmpty);
    expect(result.boundingBoxes, isNotEmpty);
    expect(result.status, "complete");
  });

  test('Test plant image retrieval', () async {
    var api = ApiServiceController();
    var plantId = "8ef6a0d6-6a75-429f-8a78-7be81d9aaf09";


    Uint8List _ = await api.getPlantImage(plantId, 'image');

    // TODO: For now we are going to ignore the image comparison
    // expect(result, File('test_resources/0025.jpg').readAsBytesSync());
  });

  test('Test plant id list retrieval', () async {
    var api = ApiServiceController();

    List result = await api.getPlantIds();

    expect(result.length, greaterThanOrEqualTo(1));
  });
}