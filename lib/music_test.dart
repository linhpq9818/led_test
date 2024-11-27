import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

class MusicSyncScreen extends StatefulWidget {
  @override
  _MusicSyncScreenState createState() => _MusicSyncScreenState();
}

class _MusicSyncScreenState extends State<MusicSyncScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isTextVisible = true;
  late Timer _waveformTimer;
  late List<double> _waveformData;  // List lưu dữ liệu waveform giả lập
  double _threshold = 0.7;  // Ngưỡng cường độ tối thiểu để nháy chữ
  bool _isTextBlinking = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _waveformData = [];
  }

  // Phân tích dữ liệu âm thanh từ bài nhạc và lấy waveform
  Future<void> _analyzeAudio(String filePath) async {
    setState(() {
      _isAnalyzing = true;
    });

    // Trích xuất waveform từ bài nhạc bằng FFmpeg
    const outputWaveform = "waveform.json";

    await FFmpegKit.execute(
      "-i $filePath -filter_complex 'showwavespic=s=1280x720' -frames:v 1 $outputWaveform",
    );

    // Lấy dữ liệu waveform dạng giả lập, bạn có thể thay đổi bằng dữ liệu thật
    // Ví dụ: Sử dụng dữ liệu dạng list cường độ âm thanh trong bài hát
    // Dữ liệu giả lập từ 0.0 đến 1.0
    setState(() {
      _waveformData = List.generate(100, (index) => (index % 5) / 5); // Các giá trị giả lập
      _isAnalyzing = false;
    });

    debugPrint('Waveform extracted!');
  }

  // Phát nhạc và kiểm tra cường độ âm thanh theo thời gian
  Future<void> _pickAndPlayAudio() async {
    // Mở hộp thoại chọn tệp âm thanh từ thiết bị
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio, // Chỉ chọn tệp âm thanh
    );

    if (result != null) {
      String filePath = result.files.single.path!; // Đường dẫn tệp âm thanh

      // Phân tích dữ liệu sóng âm thanh
      await _analyzeAudio(filePath);

      try {
        await _audioPlayer.setSource(DeviceFileSource(filePath));
        await _audioPlayer.resume(); // Phát nhạc
        setState(() {
          _isPlaying = true;
        });

        // Lắng nghe và kiểm tra waveform
        _waveformTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
          // Giả lập lấy giá trị waveform (thực tế bạn lấy dữ liệu từ file âm thanh)
          double currentWaveformValue = _waveformData[timer.tick % _waveformData.length];

          if (currentWaveformValue > _threshold && !_isTextBlinking) {
            // Nếu waveform vượt quá ngưỡng và chưa nháy chữ, nháy chữ một lần
            setState(() {
              _isTextBlinking = true;
            });
            Future.delayed(Duration(milliseconds: 300), () {
              setState(() {
                _isTextBlinking = false;
              });
            });
          }
        });
      } catch (e) {
        debugPrint("Lỗi khi phát nhạc: $e");
      }
    }
  }
  @override
  void dispose() {
    _audioPlayer.dispose();
    _waveformTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Sync with Waveform'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isPlaying || _isAnalyzing ? null : _pickAndPlayAudio,
              child: _isAnalyzing ? CircularProgressIndicator() : Text("Play Music"),
            ),
            const SizedBox(height: 20),
            AnimatedOpacity(
              opacity: _isTextVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: const Text(
                "Blinking Text",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
