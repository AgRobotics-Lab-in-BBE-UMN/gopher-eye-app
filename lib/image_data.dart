class ImageData {
  String? id;
  String? image;
  List<List<double>>? masks;
  List<List<double>>? boundingBoxes;
  List<String>? labels;
  String? status;

  ImageData({this.id, this.image, this.status, this.masks, this.boundingBoxes, this.labels});

  ImageData.fromJson(Map<String, dynamic> json) {
    id = json['plant_id'];
    image = null;
    status = json['status'];
    masks = [];
    for (int i = 0; i < json['masks'].length; i++) {
      masks!.add(json['masks'][i]
          .cast<List>()
          .toList()
          .expand((i) => i as List)
          .toList()
          .cast<double>()
          .toList());
    }
    boundingBoxes = [];
    for (var box in json['bounding_boxes']) {
      boundingBoxes!.add(box.cast<double>().toList());
    }
    labels = json['labels'].cast<String>().toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['status'] = status;
    data['masks'] = masks;
    data['bounding_boxes'] = boundingBoxes;
    data['labels'] = labels;
    return data;
  }
}
