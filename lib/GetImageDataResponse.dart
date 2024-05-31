// ignore_for_file: file_names

class GetImageDataResponse {
  String? id;
  String? image;
  String? segmentation;
  String? status;

  GetImageDataResponse({this.id, this.image, this.segmentation, this.status});

  GetImageDataResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    segmentation = json['segmentation'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['segmentation'] = segmentation;
    data['status'] = status;
    return data;
  }
}
