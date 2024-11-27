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
        getAmplitude(_audioFilePath!);
      });
      // Load the waveform data
      await _waveformsController.preparePlayer(path: _audioFilePath!);
    }
  }
  Future<void> _playAudio() async {
    if (_audioFilePath != null) {
      await _audioPlayer.setFilePath(_audioFilePath!);
      await _audioPlayer.play();

      int lastCheckedTime = 0;  // Khởi tạo thời gian kiểm tra biên độ cuối cùng

      _audioPlayer.positionStream.listen((position) async {
        // Kiểm tra giá trị position có trả về đúng không
        print("Current position: ${position.inMilliseconds}");

        // Kiểm tra biên độ mỗi giây (1000ms)
        if (position.inMilliseconds - lastCheckedTime >= 100) {
          // Cập nhật thời gian kiểm tra biên độ cuối cùng
          lastCheckedTime = position.inMilliseconds;

          // Lấy biên độ
          double amplitude = await getAmplitude(_audioFilePath!);
          setState(() {
            _amplitude = amplitude;
          });
          print("Amplitude at ${position.inMilliseconds}ms: $_amplitude");
        }
      });
    }
  }

  Future<double> getAmplitude(String path) async {
    try {
      // Lấy biên độ từ plugin
      List<int> amplitudes = await _audioAnalyzerPlugin.getAmplitudes(path);

      // Kiểm tra xem danh sách amplitudes có rỗng không
      if (amplitudes.isEmpty) {
        print('No amplitudes data available.');
        return 0.0; // Nếu không có dữ liệu, trả về 0.0
      }

      // Lấy giá trị biên độ cuối cùng
      double amplitude = amplitudes.last.toDouble();

      // Cập nhật UI với giá trị biên độ
      setState(() {
        _amplitudeResult = 'Amplitude: $amplitude';
      });

      print('Amplitude: $amplitude');
      return amplitude;
    } on PlatformException catch (e) {
      print('Error getting amplitude: $e');
      setState(() {
        _amplitudeResult = 'Failed to get amplitude.';
      });
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