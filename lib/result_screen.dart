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
        shadowColor: Colors.black,
        toolbarHeight: 80,
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
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_outlined),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: plantProcessedInfoList.length,
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
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "View Result",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 3.0),
                    Chip(
                      backgroundColor: Colors.teal,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.teal),
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      label: const Text(
                        "Complete",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
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
                        plantInfo: plantProcessedInfoList[index],
                      ),
                    ),
                  );
                },
              ),
              const Divider(),
            ],
          );
        },
      ),
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
