import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MaskDetailScreen extends StatefulWidget {
  final String imagePath;
  final dynamic mask;
  final String label;
  final Color color;

  const MaskDetailScreen({
    super.key,
    required this.imagePath,
    required this.mask,
    required this.label,
    required this.color,
  });

  @override
  State<MaskDetailScreen> createState() => _MaskDetailScreenState();
}

class _MaskDetailScreenState extends State<MaskDetailScreen> {
  late double minX, minY, maxX, maxY;
  
  @override
  void initState() {
    super.initState();
    _calculateMaskBounds();
  }
  
  void _calculateMaskBounds() {
    minX = double.infinity;
    minY = double.infinity;
    maxX = 0;
    maxY = 0;
    
    for (int i = 0; i < widget.mask.length; i += 2) {
      final x = widget.mask[i].toDouble();
      final y = widget.mask[i + 1].toDouble();
      
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }
    
    // Add padding around the mask
    final paddingX = (maxX - minX) * 0.1; // 10% padding
    final paddingY = (maxY - minY) * 0.1; // 10% padding
    
    minX = (minX - paddingX).clamp(0.0, double.infinity);
    minY = (minY - paddingY).clamp(0.0, double.infinity);
    maxX = (maxX + paddingX);
    maxY = (maxY + paddingY);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mask Detail: ${widget.label}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ClipRect(
                child: Stack(
                  fit: StackFit.loose,
                  children: [
                    _ZoomedImage(
                      imagePath: widget.imagePath,
                      minX: minX,
                      minY: minY,
                      maxX: maxX,
                      maxY: maxY,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomedImage extends StatefulWidget {
  final String imagePath;
  final double minX, minY, maxX, maxY;

  const _ZoomedImage({
    required this.imagePath,
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  @override
  State<_ZoomedImage> createState() => _ZoomedImageState();
}

class _ZoomedImageState extends State<_ZoomedImage> {
  ui.Image? image;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();
      final img = await decodeImageFromList(bytes);
      setState(() {
        image = img;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading image: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  bool showMask = true;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (image == null) {
      return const Center(child: Text('Failed to load image'));
    }

    final imgWidth = image!.width.toDouble();
    final imgHeight = image!.height.toDouble();
    final cropWidth = imgWidth * (widget.maxX - widget.minX);
    final cropHeight = imgHeight * (widget.maxY - widget.minY);

    // Calculate the center of the mask region
    final cropCenterX = widget.minX * imgWidth + cropWidth / 2;
    final cropCenterY = widget.minY * imgHeight + cropHeight / 2;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text("Show Mask"),
            Switch(
              value: showMask,
              onChanged: (val) {
                setState(() {
                  showMask = val;
                });
              },
            ),
          ],
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scaleX = constraints.maxWidth / cropWidth;
              final scaleY = constraints.maxHeight / cropHeight;
              final scale = scaleX < scaleY ? scaleX : scaleY;

              final offsetX = (constraints.maxWidth / 2) - (cropCenterX * scale);
              final offsetY = (constraints.maxHeight / 2) - (cropCenterY * scale);

              return Stack(
                children: [
                  Positioned(
                    left: offsetX,
                    top: offsetY,
                    width: imgWidth * scale,
                    height: imgHeight * scale,
                    child: Image.file(
                      File(widget.imagePath),
                      width: imgWidth * scale,
                      height: imgHeight * scale,
                      fit: BoxFit.fill,
                    ),
                  ),
                  if (showMask)
                    Positioned(
                      left: offsetX,
                      top: offsetY,
                      width: imgWidth * scale,
                      height: imgHeight * scale,
                      child: CustomPaint(
                        size: Size(imgWidth * scale, imgHeight * scale),
                        painter: _MaskPainter(
                          mask: (context.findAncestorStateOfType<_MaskDetailScreenState>()?.widget.mask ?? []),
                          minX: widget.minX,
                          minY: widget.minY,
                          maxX: widget.maxX,
                          maxY: widget.maxY,
                          imgWidth: imgWidth,
                          imgHeight: imgHeight,
                          scale: scale,
                          color: (context.findAncestorStateOfType<_MaskDetailScreenState>()?.widget.color ?? Colors.red),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MaskPainter extends CustomPainter {
  final dynamic mask;
  final double minX, minY, maxX, maxY;
  final double imgWidth, imgHeight, scale;
  final Color color;

  _MaskPainter({
    required this.mask,
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
    required this.imgWidth,
    required this.imgHeight,
    required this.scale,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (mask == null || mask.isEmpty) return;

    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();

    for (int i = 0; i < mask.length; i += 2) {
      // Convert normalized mask coordinates to image pixel coordinates
      final x = mask[i] * imgWidth;
      final y = mask[i + 1] * imgHeight;

      if (i == 0) {
        path.moveTo(x * scale, y * scale);
      } else {
        path.lineTo(x * scale, y * scale);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
