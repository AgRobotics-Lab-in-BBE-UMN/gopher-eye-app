// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gopher_eye/image_data.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceController extends GetxController {
  var isLoading = false.obs;
  bool isDialogShowing = false;
  var isSuccess = false.obs;
  String plantId = "";

  Future<String> sendImage(File image) async {
    String serverURL = await _getServerURL();
    isLoading.value = true;
    try {
      var url = Uri.http(serverURL, 'dl/segmentation');
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
        return plantId;
      } else {
        debugPrint("Image upload failed");
        return "";
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      isLoading.value = false;
    }
    return "";
  }

  Future<ImageData> getPlantData(plantId) async {
    try {
      String serverURL = await _getServerURL();
      isLoading.value = true;

      final queryParameters = {'plant_id': plantId};
      final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
      var url = Uri.http(serverURL, 'plant/data', queryParameters);
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        ImageData imageData =
            ImageData.fromJson(jsonDecode(response.body));
        return imageData;
      } else {
        // If the server returns an error response, throw an exception
        throw Exception('Failed to load image data');
      }
    } catch (e) {
      // Catch any errors that occur during the request
      debugPrint("Error: $e");
      return ImageData();
    } finally {
      // Set isLoading to false after the request is complete
      isLoading.value = false;
    }
  }

  // getPlantImage function by plant_id and imageName
  Future<Uint8List> getPlantImage(String plantId, String imageName) async {
    try {
      String serverURL = await _getServerURL();
      isLoading.value = true;
      final queryParameters = {'plant_id': plantId, 'image_name': imageName};
      final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
      var url = Uri.http(serverURL, '/plant/image', queryParameters);
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        // If the server returns an error response, throw an exception
        throw Exception('Failed to load image data');
      }
    } catch (e) {
      // Catch any errors that occur during the request
      debugPrint("Error: $e");
      throw Exception('Failed to load image data');
    } finally {
      // Set isLoading to false after the request is complete
      isLoading.value = false;
    }
  }

  // get_plant_status function by plant_id
  Future<String> getPlantStatus(String plantId) async {
    try {
      String serverURL = await _getServerURL();
      isLoading.value = true;
      final queryParameters = {'plant_id': plantId};
      final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
      var url = Uri.http(serverURL, 'plant/status', queryParameters);
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        var data = jsonDecode(response.body);
        return data['status'];
      } else {
        // If the server returns an error response, throw an exception
        throw Exception('Failed to retireve status');
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

  Future<List<String>> getPlantIds() async {
    try {
      String serverURL = await _getServerURL();
      isLoading.value = true;
      final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
      var url = Uri.http(serverURL, 'plant/ids');
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        List<String> data = jsonDecode(response.body)['plant_ids'].cast<String>().toList();
        return data;
      } else {
        // If the server returns an error response, throw an exception
        throw Exception('Failed to retireve status');
      }
    } catch (e) {
      // Catch any errors that occur during the request
      debugPrint("Error: $e");
      return [];
    } finally {
      // Set isLoading to false after the request is complete
      isLoading.value = false;
    }
  }

  Future<String> _getServerURL() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('serverUrl') ?? 'gopher-eye.com';
  }
}
