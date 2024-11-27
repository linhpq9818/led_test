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

class _AudioAmplitudePageState extends State<AudioAmplitudePage> with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late PlayerController _waveformsController;
  List<double>? _waveformData;
  // This will be used to pick the audio file
  String? _audioFilePath;
  bool _isPlaying = false;
  double _amplitude = 0;
  double _threshold = 0;
  bool _isTextBlinking = false;

  late Timer _waveformTimer;
  String _amplitudeResult = 'Unknown';
  final _audioAnalyzerPlugin = AudioAnalyzer();
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _waveformsController = PlayerController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

  }

  Future<void> _pickAudioFile() async {
    // Sử dụng FilePicker để chọn file âm thanh
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      setState(() {
        _audioFilePath = filePath;
      });
    } else {
      // Người dùng đã hủy chọn file
      debugPrint("Không có file âm thanh nào được chọn.");
    }
  }

  Future<void> _playAudio() async {
    if (_audioFilePath != null) {
      await _audioPlayer.setFilePath(_audioFilePath!);
      await _audioPlayer.play();


      int lastCheckedTime = 0;
      List<int> amplitudes = await _audioAnalyzerPlugin.getAmplitudes(_audioFilePath!);

      _audioPlayer.positionStream.listen((position) {

        // Kiểm tra mỗi 100ms
        if (position.inMilliseconds - lastCheckedTime >= 10) {
          lastCheckedTime = position.inMilliseconds;

          // Tính toán chỉ số biên độ
          int index = (position.inMilliseconds / 1000 * 40).floor(); // 40 mẫu/giây
          if (index < amplitudes.length) {
            _amplitude = amplitudes[index].toDouble();
            _threshold = amplitudes.reduce((a, b) => a > b ? a : b).toDouble() * 0.7;
            setState(() {
              _isPlaying = true;
            });
            _listenToMusicIntensity(_amplitude);
            print("Amplitude at ${position.inMilliseconds}ms: $_amplitude");
            print('threshold at :${_amplitude} ms: $_threshold');
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
  void _listenToMusicIntensity(double intensity) {
    // Kiểm tra biên độ ngay lập tức mà không cần Timer
    if (intensity < _threshold) {
      // Nếu intensity dưới ngưỡng, bật nháy chữ và điều khiển AnimationController
      if (!_isTextBlinking) {
        setState(() {
          _isTextBlinking = true; // Bật nháy
        });
        _animationController.forward(from: 0.0);  // Khởi động hoạt ảnh từ đầu
      }
    } else {
      // Khi intensity > threshold, tắt nháy
      if (_isTextBlinking) {
        setState(() {
          _isTextBlinking = false;  // Tắt nháy
        });

        // Dừng hoạt ảnh khi intensity > threshold
        _animationController.stop();
      }
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
            const SizedBox(height: 20),
            AnimatedOpacity(
              opacity: _isTextBlinking ? 1.0 : 0.0,
              duration: Duration(milliseconds: 10),  // Để chữ nháy nhanh
              child: Text(
                "Synchronized Text",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  shadows: [
                    Shadow(
                      blurRadius: 20,
                      color: Colors.black,
                      offset: Offset(5, 5),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}