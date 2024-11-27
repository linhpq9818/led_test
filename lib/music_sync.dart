import 'dart:async';
import 'dart:io';

import 'package:audio_analyzer/audio_analyzer.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
class AudioAmplitudePage extends StatefulWidget {
  const AudioAmplitudePage({super.key});

  @override
  _AudioAmplitudePageState createState() => _AudioAmplitudePageState();
}

class _AudioAmplitudePageState extends State<AudioAmplitudePage> {
  late AudioPlayer _audioPlayer;
  late PlayerController _waveformsController;
  List<double>? _waveformData;
  // This will be used to pick the audio file
  String? _audioFilePath;
  double _amplitude = 0;
  String _amplitudeResult = 'Unknown';
  final _audioAnalyzerPlugin = AudioAnalyzer();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _waveformsController = PlayerController();
  }

  // Method to pick the audio file
  // Method to pick the audio file
  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _audioFilePath = result.files.single.path;
      });
      // Load the waveform data
      await _waveformsController.preparePlayer(path: _audioFilePath!);
    }
  }
  Future<void> _playAudio() async {
    if (_audioFilePath != null) {
      await _audioPlayer.setFilePath(_audioFilePath!);
      await _audioPlayer.play();

      int lastCheckedTime = 0;
      List<int> amplitudes = await _audioAnalyzerPlugin.getAmplitudes(_audioFilePath!);

      _audioPlayer.positionStream.listen((position) {
        print("Current position: ${position.inMilliseconds}");

        // Kiểm tra mỗi 100ms
        if (position.inMilliseconds - lastCheckedTime >= 100) {
          lastCheckedTime = position.inMilliseconds;

          // Tính toán chỉ số biên độ
          int index = (position.inMilliseconds / 1000 * 40).floor(); // 40 mẫu/giây
          if (index < amplitudes.length) {
            double amplitude = amplitudes[index].toDouble();
            setState(() {
              _amplitude = amplitude;
            });
            print("Amplitude at ${position.inMilliseconds}ms: $amplitude");
          } else {
            print("Index out of range: $index");
          }
        }
      });
    }
  }


  Future<double> getAmplitudeAtTime(String path, Duration currentPosition) async {
    try {
      // Gửi thời điểm hiện tại vào phương thức để lấy biên độ
      List<int> amplitudes = await _audioAnalyzerPlugin.getAmplitudes(path);

      // Lấy giá trị biên độ tại thời điểm cuối cùng
      if (amplitudes.isNotEmpty) {
        double amplitude = amplitudes.isNotEmpty ? amplitudes.last.toDouble() : 0.123;


      // Cập nhật UI
        setState(() {
          _amplitudeResult = 'Amplitude at ${currentPosition.inMilliseconds}ms: $amplitude';
        });

        print('Amplitude at ${currentPosition.inMilliseconds}ms: $amplitude');
        return amplitude;
      } else {
        print('No amplitude data available at ${currentPosition.inMilliseconds}ms.');
        return 0.0;
      }
    } on PlatformException catch (e) {
      print('Error getting amplitude: $e');
      return 0.0; // Trả về giá trị mặc định nếu có lỗi
    }
  }


  @override
  void dispose() {
    _audioPlayer.dispose();
    _waveformsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Amplitude from Audio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Button to pick the audio file
            ElevatedButton(
              onPressed: _pickAudioFile,
              child: const Text('Pick Audio File'),
            ),
            if (_audioFilePath != null)
              Column(
                children: [
                  Text("Playing audio: $_amplitude"),
                  // Button to start playing and printing amplitude
                  ElevatedButton(
                    onPressed: _playAudio,
                    child: const Text('Play Audio and Track Amplitude'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}