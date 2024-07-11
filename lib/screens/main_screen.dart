import 'package:flutter/material.dart';
import 'package:gopher_eye/services/api.dart';
import 'package:gopher_eye/services/app_database.dart';
import 'package:gopher_eye/image_data.dart';
import 'package:gopher_eye/screens/result_screen.dart';
import 'package:gopher_eye/widgets/camera_capture_card.dart';
import 'package:gopher_eye/widgets/preview_list.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
      appBar: AppBar(
        shadowColor: Colors.black,
        toolbarHeight: 80,
        elevation: 3,
        title: const SafeArea(
          minimum: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
          child: Text(
            "Gopher Eye",
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
      body: Column(
        children: [
          const CameraCaptureCard(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Preview Results',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ResultScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "view all",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Expanded(child: PreviewList(plantProcessedInfoList: plantProcessedInfoList))
                ],
              ),
            ),
          ),
        ],
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
