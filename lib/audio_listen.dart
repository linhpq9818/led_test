import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';

import 'package:just_audio/just_audio.dart';

class AudioAnalyzer extends StatefulWidget {
  @override
  _AudioAnalyzerState createState() => _AudioAnalyzerState();
}

class _AudioAnalyzerState extends State<AudioAnalyzer> {
  final AudioPlayer _player = AudioPlayer();
  double _amplitude = 0;
  final double _threshold = 0.5; // Ngưỡng âm lượng
  bool _isAboveThreshold = false;


  AnimatedOpacity buildAnimatedText() {
    return AnimatedOpacity(
      opacity: _isAboveThreshold ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: Text(''),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Analyzer'),
      ),
      body: Center(
        child: buildAnimatedText(),
      )
    );
  }
}