import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gopher_eye/GetImageDataResponse.dart';
import 'package:gopher_eye/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PlantInfo extends StatelessWidget {
  const PlantInfo({super.key, required this.plantInfo});

  final GetImageDataResponse plantInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Plant Information",
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Stack(children: <Widget>[
                        // Container(
                        //   height: 100,
                        //   color: Colors.red,
                        // ),
                        Image.memory(plantInfo.image!),
                        Positioned.fill(
                            child: LayoutBuilder(
                          builder: (context, constraints) => CustomPaint(
                            painter: BoundingBoxes(
                                plantInfo.boundingBoxes,
                                constraints.maxWidth,
                                constraints.maxHeight),
                          ),
                        )),
                        Positioned.fill(
                            child: LayoutBuilder(
                          builder: (context, constraints) => CustomPaint(
                            painter: Masks(
                                plantInfo.masks,
                                constraints.maxWidth,
                                constraints.maxHeight),
                          ),
                        )),
                      ]),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      "Name: ${plantInfo.id}",
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      "Description: ${plantInfo.id}",
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      "Status: ${plantInfo.status}",
                    ),
                    const SizedBox(height: 10.0),
                    if (plantInfo.status == 'completed')
                      Text(
                        "disease: ${plantInfo.id}",
                      ),
                    const SizedBox(height: 10.0),
                    if (plantInfo.status == 'completed')
                      Text(
                        "Plant Cure: ${plantInfo.id}",
                      ),
                    const SizedBox(height: 10.0),
                    // Add a button to fetch the plant status
                    ElevatedButton(
                      onPressed: () async {
                        if (plantInfo.id == null) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          var plantId = prefs.getString('plant_id');
                          if (plantId != null) {
                            final status = await fetchPlantStatus(plantId);
                            if (status != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Plant status: $status'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to fetch plant status'),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Plant ID not found'),
                              ),
                            );
                          }
                        } else {
                          final status = await fetchPlantStatus(plantInfo.id!);
                          if (status != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Plant status: $status'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to fetch plant status'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Center(child: Text('Fetch Plant Status')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> fetchPlantStatus(String plantId) async {
    ApiServiceController api = ApiServiceController();

    try {
      final String status = await api.getPlantStatus(plantId);
      if (status.isNotEmpty) {
        return status;
      } else {
        print('Failed to fetch plant status');
        return null;
      }
    } catch (e) {
      print('Error occurred while fetching plant status: $e');
      return null;
    }
  }
}

class BoundingBoxes extends CustomPainter {
  final List<dynamic>? boundingBoxes;
  final double widthScale;
  final double heightScale;

  BoundingBoxes(this.boundingBoxes, this.widthScale, this.heightScale);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < boundingBoxes!.length; i += 1) {
      final x = boundingBoxes![i][0];
      final y = boundingBoxes![i][1];
      final width = boundingBoxes![i][2] - boundingBoxes![i][0];
      final height = boundingBoxes![i][3] - boundingBoxes![i][1];
      canvas.drawRect(
          Rect.fromLTWH(widthScale * x, heightScale * y, widthScale * width,
              heightScale * height),
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Masks extends CustomPainter {
  final List<dynamic>? masks;
  final double widthScale;
  final double heightScale;

  Masks(this.masks, this.widthScale, this.heightScale);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < masks!.length; i += 1) {
      final mask = masks![i];
      final path = Path();
      for (int j = 0; j < mask.length; j += 1) {
        final x = mask[j][0];
        final y = mask[j][1];
        if (j == 0) {
          path.moveTo(widthScale * x, heightScale * y);
        } else {
          path.lineTo(widthScale * x, heightScale * y);
        }
      }
      path.close();
      final color = Color((Random().nextDouble() * 0xFFFFFF).toInt());
      paint.color = color.withOpacity(0.5);
      canvas.drawPath(path, paint..style = PaintingStyle.fill);
      paint.color = color.withOpacity(1.0);
      canvas.drawPath(path, paint..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
