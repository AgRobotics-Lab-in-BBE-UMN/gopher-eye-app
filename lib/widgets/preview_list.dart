import 'package:flutter/material.dart';
import 'package:gopher_eye/image_data.dart';
import 'package:gopher_eye/widgets/preview_tile.dart';

class PreviewList extends StatefulWidget {
  const PreviewList({super.key, required this.plantProcessedInfoList});
  final List<ImageData> plantProcessedInfoList;

  @override
  // ignore: library_private_types_in_public_api
  _PreviewListState createState() => _PreviewListState();
}

class _PreviewListState extends State<PreviewList> {

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.plantProcessedInfoList.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              PreviewTile(index: index, plantProcessedInfo: widget.plantProcessedInfoList[index]),
              const Divider(),
            ],
          );
        },
      );
  }
}
