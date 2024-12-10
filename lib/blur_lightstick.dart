import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:ledbanner_test/api_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remove_bg/remove_bg.dart';

import 'light_stick/dropshadow.dart';

class  BlurStick extends StatefulWidget {

  @override
  State<BlurStick> createState() => _BlurStickState();
}
class _BlurStickState extends State<BlurStick> {
  double linearProgress = 0.0;
  Uint8List? bytes; // This will store the processed image
  String? fileName = "lightstick_2.png"; // Default asset file name
  bool isProcessing = false;
  Uint8List? processedImage;
  bool isLoading = false;

  Future<void> _removeBackground() async {
    setState(() {
      isLoading = true;
    });

    try {
      final apiClient = ApiClient();
      final result = await apiClient.removeBgApi('lightstick.png');
      setState(() {
        processedImage = result;
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<File> _writeToTempFile(Uint8List data) async {
    // Write the Uint8List to a temporary file and return it
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/temp_image.png');
    return file.writeAsBytes(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Remove.bg"),
      ),
      body: Center(
        child: DropShadow(
          offset: Offset(25, 25),
          color: Color(0xFF23BEFD),
          blurRadius: 10.0,
          opacity: 0.7 ,
          child: Column(
            children: [
              Image.asset(
                'assets/images/$fileName',
                height: 600,
                width: double.infinity,
              ),

            ],
          ),
                  ),
      ),
    );
  }
}
