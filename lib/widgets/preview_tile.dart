import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gopher_eye/image_data.dart';
import 'package:gopher_eye/plant_info.dart';

class PreviewTile extends StatefulWidget {
  const PreviewTile(
      {super.key, required this.index, required this.plantProcessedInfo});
  final int index;
  final ImageData plantProcessedInfo;

  @override
  // ignore: library_private_types_in_public_api
  _PreviewTileState createState() => _PreviewTileState();
}

class _PreviewTileState extends State<PreviewTile> {

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.file(
        File(widget.plantProcessedInfo.image!),
        height: 100,
        width: 100,
        fit: BoxFit.cover,
      ),
      title: const Text(
        "Date",
        style: TextStyle(fontSize: 12),
      ),
      subtitle: const Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "View Result",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 3.0),
          Chip(
            backgroundColor: Colors.teal,
            elevation: 6,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.teal),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            label: Text(
              "Complete",
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
              ),
            ),
          )
        ],
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 30.0,
        color: Colors.black,
      ),
      tileColor: Colors.transparent,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantInfo(
              plantInfo: widget.plantProcessedInfo,
            ),
          ),
        );
      },
    );
  }
}
