// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gopher_eye/GetImageDataResponse.dart';
import 'package:http/http.dart' as http;

class ApiServiceController extends GetxController {
  var isLoading = false.obs;
  bool isDialogShowing = false;
  var isSuccess = false.obs;
  String plantId = "";

  Future<bool> sendImage(File image) async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 5));
      var url = Uri.parse("192.168.1.77:5000/dl/segmentation");
      var request = http.MultipartRequest('PUT', url);
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        debugPrint("Image uploaded successfully");
        // Read the response body as a string
        var responseBody = await response.stream.bytesToString();
        // Parse the JSON string into a Map
        var parsedJson = jsonDecode(responseBody);
        // Get the 'plant_id' value from the Map
        plantId = parsedJson['plant_id'];
        debugPrint("Plant ID: $plantId");
        return true;
      } else {
        debugPrint("Image upload failed");
        return false;
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<List<GetImageDataResponse>> getPlantData(plantId) async {
    try {
      isLoading.value = true;

      final queryParameters = {'plant_id': plantId};
      final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
      var url =
          Uri.http("http://192.168.1.77:5000", 'plant/data', queryParameters);
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        List<dynamic> data = jsonDecode(response.body);
        List<GetImageDataResponse> imageDataList =
            data.map((item) => GetImageDataResponse.fromJson(item)).toList();
        return imageDataList;
      } else {
        // If the server returns an error response, throw an exception
        throw Exception('Failed to load image data');
      }
    } catch (e) {
      // Catch any errors that occur during the request
      debugPrint("Error: $e");
      return List.empty();
    } finally {
      // Set isLoading to false after the request is complete
      isLoading.value = false;
    }
  }

  // getPlantImage function by plant_id and imageName
  Future<List<GetImageDataResponse>> getPlantImage(
      String plantId, String imageName) async {
    try {
      isLoading.value = true;
      final queryParameters = {'plant_id': plantId, 'image_name': imageName};
      final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
      var url =
          Uri.http("http://192.168.1.77:5000", '/plant/image', queryParameters);
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        List<dynamic> data = jsonDecode(response.body);
        List<GetImageDataResponse> imageDataList =
            data.map((item) => GetImageDataResponse.fromJson(item)).toList();
        return imageDataList;
      } else {
        // If the server returns an error response, throw an exception
        throw Exception('Failed to load image data');
      }
    } catch (e) {
      // Catch any errors that occur during the request
      debugPrint("Error: $e");
      return List.empty();
    } finally {
      // Set isLoading to false after the request is complete
      isLoading.value = false;
    }
  }

  // get_plant_status function by plant_id
  Future<String> getPlantStatus(String plantId) async {
    try {
      isLoading.value = true;
      final queryParameters = {'plant_id': plantId};
      final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
      var url =
          Uri.http("http://192.168.1.77:5000", 'plant/status', queryParameters);
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        var data = jsonDecode(response.body);
        return data['status'];
      } else {
        // If the server returns an error response, throw an exception
        throw Exception('Failed to load image data');
      }
    } catch (e) {
      // Catch any errors that occur during the request
      debugPrint("Error: $e");
      return "";
    } finally {
      // Set isLoading to false after the request is complete
      isLoading.value = false;
    }
  }
}
