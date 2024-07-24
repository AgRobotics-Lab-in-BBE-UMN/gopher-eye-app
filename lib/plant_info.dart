import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gopher_eye/image_data.dart';

import 'package:gopher_eye/services/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PlantInfo extends StatefulWidget {
  const PlantInfo({super.key, required this.plantInfo});
  final ImageData plantInfo;

  @override
  _PlantInfoState createState() => _PlantInfoState();
}

class _PlantInfoState extends State<PlantInfo> {
  bool areBoundingBoxesVisible = true;
  bool areMasksVisible = true;
  List<Color> maskColors = [];

  void initSatte() {
    super.initState();
    for (int i = 0; i < widget.plantInfo.masks!.length; i += 1) {
      maskColors.add(Color((Random().nextDouble() * 0xFFFFFF).toInt()));
    }
  }

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
        child: SingleChildScrollView(
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
                          Image.file(File(widget.plantInfo.image!)),
                          Visibility(
                              visible: areBoundingBoxesVisible,
                              child: Positioned.fill(
                                  child: LayoutBuilder(
                                      builder: (context, constraints) =>
                                          CustomPaint(
                                            painter: BoundingBoxes(
                                                widget.plantInfo.boundingBoxes,
                                                constraints.maxWidth,
                                                constraints.maxHeight),
                                          )))),
                          Visibility(
                              visible: areMasksVisible,
                              child: Positioned.fill(
                                  child: Masks(
                                      masks: widget.plantInfo.masks,
                                      colors: maskColors)))
                        ]),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        "Name: ${widget.plantInfo.id}",
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        "Description: ${widget.plantInfo.id}",
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        "Status: ${widget.plantInfo.status}",
                      ),
                      const SizedBox(height: 10.0),
                      if (widget.plantInfo.status == 'completed')
                        Text(
                          "disease: ${widget.plantInfo.id}",
                        ),
                      const SizedBox(height: 10.0),
                      if (widget.plantInfo.status == 'completed')
                        Text(
                          "Plant Cure: ${widget.plantInfo.id}",
                        ),
                      const SizedBox(height: 10.0),
                      Row(children: [
                        Text("Show Bounding Boxes"),
                        Switch(
                          value: areBoundingBoxesVisible,
                          onChanged: (value) {
                            setState(() {
                              areBoundingBoxesVisible = value;
                            });
                          },
                        )
                      ]),
                      Row(children: [
                        Text("Show Masks"),
                        Switch(
                          value: areMasksVisible,
                          onChanged: (value) {
                            setState(() {
                              areMasksVisible = value;
                            });
                          },
                        )
                      ]),
                      // Add a button to fetch the plant status
                      ElevatedButton(
                        onPressed: () async {
                          if (widget.plantInfo.id == null) {
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
                                    content:
                                        Text('Failed to fetch plant status'),
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
                            final status =
                                await fetchPlantStatus(widget.plantInfo.id!);
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

class Masks extends StatelessWidget {
  final List<Color> colors;
  final List<dynamic>? masks;

  const Masks({super.key, required this.masks, required this.colors});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) => CustomPaint(
              painter: MasksPainter(
                  masks, constraints.maxWidth, constraints.maxHeight, colors),
            ));
  }
}

class MasksPainter extends CustomPainter {
  final List<dynamic>? masks;
  final double widthScale;
  final double heightScale;
  final List<Color> colors;

  MasksPainter(this.masks, this.widthScale, this.heightScale, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < masks!.length; i += 1) {
      final mask = masks![i];
      final path = Path();
      for (int j = 0; j < mask.length; j += 2) {
        final x = mask[j];
        final y = mask[j + 1];
        if (j == 0) {
          path.moveTo(widthScale * x, heightScale * y);
        } else {
          path.lineTo(widthScale * x, heightScale * y);
        }
      }
      path.close();

      if (colors.length < masks!.length) {
        colors.add(Color((Random().nextDouble() * 0xFFFFFF).toInt()));
      }
      final color = colors[i];
      paint.color = color.withOpacity(0.5);
      canvas.drawPath(path, paint..style = PaintingStyle.fill);
      paint.color = color.withOpacity(1.0);
      canvas.drawPath(path, paint..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
