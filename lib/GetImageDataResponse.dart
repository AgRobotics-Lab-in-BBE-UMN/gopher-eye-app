// ignore_for_file: file_names

import 'dart:typed_data';

class GetImageDataResponse {
  String? id;
  Uint8List? image;
  List? masks;
  List? boundingBoxes;
  String? status;

  GetImageDataResponse({this.id, this.image, this.status, this.masks, this.boundingBoxes});

  GetImageDataResponse.fromJson(Map<String, dynamic> json) {
    id = json['plant_id'];
    image = null;
    status = json['status'];
    masks = json['masks'];
    boundingBoxes = json['bounding_boxes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['status'] = status;
    data['masks'] = masks;
    data['bounding_boxes'] = boundingBoxes;
    return data;
  }
}
