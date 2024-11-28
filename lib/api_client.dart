import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiClient {
  Future<Uint8List> removeBgApi(String assetName) async {
    try {
      // Load image from assets
      final ByteData byteData = await rootBundle.load('assets/images/$assetName');
      final Uint8List imageBytes = byteData.buffer.asUint8List();

      // Make multipart request
      var request = http.MultipartRequest("POST", Uri.parse("https://api.remove.bg/v1.0/removebg"));
      request.files.add(http.MultipartFile.fromBytes("image_file", imageBytes, filename: assetName));
      request.headers.addAll({"X-API-Key": "tErXu7wJFYP3gpoAi5a9SsZB"});

      final response = await request.send();

      if (response.statusCode == 200) {
        http.Response imgRes = await http.Response.fromStream(response);
        print(imgRes.bodyBytes);
        return imgRes.bodyBytes;

      } else {
        throw Exception("Error occurred with response ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error loading or processing the image: $e");
    }
  }
}
