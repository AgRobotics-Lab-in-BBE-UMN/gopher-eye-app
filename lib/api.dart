import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> sendImage(File image) async {
  // var url = Uri.parse('https://gopher-eye.com/recgnition/image');
  // var request = http.MultipartRequest('POST', url);

  // request.files.add(await http.MultipartFile.fromPath('image', image.path));

  // var response = await request.send();
  // if (response.statusCode == 200) {
  //   print('Image uploaded successfully');
  // } else {
  //   print('Image upload failed');
  // }
}

Future<void> sendAudio(File audio) async {
  // var url = Uri.parse('https://gopher-eye.com/chat-bot/audio');
  // var request = http.MultipartRequest('POST', url);

  // // Replace 'audioPath' with the actual path of your audio file

  // request.files.add(await http.MultipartFile.fromPath('audio', audio.path));

  // var response = await request.send();
  // if (response.statusCode == 200) {
  //   print('Audio uploaded successfully');
  // } else {
  //   print('Audio upload failed');
  // }
}