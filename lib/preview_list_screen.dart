import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gopher_eye/GetImageDataResponse.dart';

import 'package:gopher_eye/api.dart';

class PreviewListScreen extends StatelessWidget {
  final ApiServiceController controller = Get.put(ApiServiceController());

  PreviewListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GetImageDataResponse>>(
      future: controller.getPlantData(controller.plantId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<GetImageDataResponse> imageDataList = snapshot.data!;
          // Display your data using imageDataList
          return ListView.builder(
            itemCount: imageDataList.length,
            itemBuilder: (context, index) {
              return Card(
                // Define the shape of the card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                // Define how the card's content should be clipped
                clipBehavior: Clip.antiAliasWithSaveLayer,
                // Define the child widget of the card
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Add padding around the row widget
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Add an image widget to display an image
                          Image.asset(
                            imageDataList[index].image!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          // Add some spacing between the image and the text
                          Container(width: 20),
                          // Add an expanded widget to take up the remaining horizontal space
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Add some spacing between the top of the card and the title
                                Container(height: 5),
                                // Add a title widget
                                Text(
                                  imageDataList[index].segmentation!,
                                  style: MyTextSample.title(context)!.copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                                // Add some spacing between the title and the subtitle
                                Container(height: 5),
                                // Add a subtitle widget
                                Text(
                                  imageDataList[index].status!,
                                  style: MyTextSample.body1(context)!.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                ),
                                // Add some spacing between the subtitle and the text
                                // Container(height: 10),
                                // Add a text widget to display some text
                                // Text(
                                //   MyStringsSample.card_text,
                                //   maxLines: 2,
                                //   style: MyTextSample.subhead(context)!.copyWith(
                                //     color: Colors.grey[700],
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}

class ImgSample {
  static String get(String name) {
    return 'assets/images/$name';
  }
}

class MyTextSample {
  static TextStyle? display4(BuildContext context) {
    return Theme.of(context).textTheme.displayLarge;
  }

  static TextStyle? display3(BuildContext context) {
    return Theme.of(context).textTheme.displayMedium;
  }

  static TextStyle? display2(BuildContext context) {
    return Theme.of(context).textTheme.displaySmall;
  }

  static TextStyle? display1(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium;
  }

  static TextStyle? headline(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall;
  }

  static TextStyle? title(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge;
  }

  static TextStyle medium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          fontSize: 18,
        );
  }

  static TextStyle? subhead(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium;
  }

  static TextStyle? body2(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge;
  }

  static TextStyle? body1(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium;
  }

  static TextStyle? caption(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall;
  }

  static TextStyle? button(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(letterSpacing: 1);
  }

  static TextStyle? subtitle(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall;
  }

  static TextStyle? overline(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall;
  }
}
