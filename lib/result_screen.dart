import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gopher_eye/api.dart';
import 'package:gopher_eye/app_database.dart';
import 'package:gopher_eye/image_data.dart';

import 'package:gopher_eye/plant_info.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  ApiServiceController api = ApiServiceController();
  List<ImageData> plantProcessedInfoList = [];

  @override
  void initState() {
    super.initState();
    _updatePage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // backgroundColor: Colors.cyan[300],
        shadowColor: Colors.black, toolbarHeight: 80,
        elevation: 3,
        title: const SafeArea(
          minimum: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
          child: Text(
            "Preview Results",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.more_horiz_outlined))
        ],
      ),
      body: Expanded(
          child: ListView.builder(
        itemCount: plantProcessedInfoList.length,
        // itemCount: 5,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                leading: Image.file(
                  File(plantProcessedInfoList[index].image!),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
                title: const Text(
                  "Date",
                  style: TextStyle(fontSize: 12),
                ),
                subtitle: const Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "View Diagnosis",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                    SizedBox(height: 3.0),
                    Chip(
                      surfaceTintColor: Colors.red,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.teal),
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      label: Text(
                        "Complete",
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    )
                  ],
                )),
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
                              plantInfo: plantProcessedInfoList[index])));
                },
              ),
              const Divider(),
            ],
          );
        },
      )),
    );
  }

  Future<void> _updatePage() async {
    while (true) {
      AppDatabase.getAllImages().then((images) {
        List<ImageData> updatedList = [];
        for (ImageData image in images) {
          if (image.status == 'complete' &&
              image.image != '' &&
              image.image != null) {
            updatedList.add(image);
          }
        }
        setState(() {
          plantProcessedInfoList = updatedList;
        });
      });

      await Future.delayed(const Duration(seconds: 5));
    }
  }
}
