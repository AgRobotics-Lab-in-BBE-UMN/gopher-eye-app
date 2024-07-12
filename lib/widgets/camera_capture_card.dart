import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gopher_eye/plant_capture.dart';

class CameraCaptureCard extends StatelessWidget{
  const CameraCaptureCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Identify Your Diseases!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Column(
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/images/take_a_picture.png'),
                                    width: 40,
                                    height: 50,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Take a'),
                                  Text('Picture'),
                                ],
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 60,
                                color: Colors.blueGrey,
                              ),
                              Column(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/diagnosis.svg",
                                    width: 40,
                                    height: 50,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('See'),
                                  const Text('Result'),
                                ],
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: Colors.blueGrey, size: 60),
                              const Column(
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/images/get_medicine.png'),
                                    width: 40,
                                    height: 50,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Get'),
                                  Text('treatment'),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: MaterialButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PlantCapture(),
                                  ),
                                );
                              },
                              color: const Color.fromARGB(255, 13, 108, 186),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 90, vertical: 6),
                                child: Text(
                                  "Take a Picture",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

}