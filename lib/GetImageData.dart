// ignore_for_file: file_names

class GetImageData {
  String? plantId;

  GetImageData({this.plantId});

  GetImageData.fromJson(Map<String, dynamic> json) {
    plantId = json['plant_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['plant_id'] = plantId;
    return data;
  }
}
