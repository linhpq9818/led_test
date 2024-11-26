import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ledbanner_test/speed_provider.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PreviewWidget extends StatefulWidget {
  final String displayText;
  final double fontSize;
  final Color textColor;
  final bool isBlinking;
  final TextDirection textDirection;
  final String selectedFont;
  final Color blurColor;

  const PreviewWidget({
    required this.displayText,
    required this.fontSize,
    required this.textColor,
    required this.isBlinking,
    required this.textDirection,
    required this.selectedFont,
    required this.blurColor,
  });

  @override
  _PreviewWidgetState createState() => _PreviewWidgetState();
}

class _PreviewWidgetState extends State<PreviewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late VideoPlayerController _videoController;
  late bool isBlinking;
  bool isVideoSelected = false;

  @override
  void initState() {
    super.initState();

    final speedProvider = Provider.of<SpeedProvider>(context, listen: false);
    _initializeBlinkController(speedProvider.textBlink);
  }

  void _initializeBlinkController(double textBlinkSpeed) {
    _controller = AnimationController(
      duration: Duration(
          milliseconds:
              textBlinkSpeed.toInt() < 0 ? 100 : textBlinkSpeed.toInt()),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _pickVideo() async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

      if (video != null) {
        _videoController = VideoPlayerController.file(File(video.path));
        await _videoController.initialize();
        _videoController.setLooping(true);
        _videoController.play();
        setState(() {
          isVideoSelected = true;
        });
      } else {
        print("No video selected");
      }
    } catch (e) {
      print("Error picking video: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final speedProvider = Provider.of<SpeedProvider>(context);
    isBlinking = widget.isBlinking;

    if (isBlinking) {
      _controller.stop();
      _controller.duration =
          Duration(milliseconds: speedProvider.textBlink.toInt());
      _controller.reset();
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speedProvider = Provider.of<SpeedProvider>(context, listen: true);

    return Column(
      children: [
        // Button to select video
        ElevatedButton(
          onPressed: _pickVideo,
          child: Text("Select Background Video"),
        ),
        // Display video or default background
        Container(
          width: double.infinity,
          height: 150,
          color: Colors.black,
          child: Stack(children: [
            if (isVideoSelected)
              Container(width: 150, height:double.infinity, child: VideoPlayer(_videoController)),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Marquee(
                  text: widget.displayText.isNotEmpty
                      ? widget.displayText
                      : "Preview Text",
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    color: widget.isBlinking
                        ? (_controller.value < 0.5
                            ? widget.textColor
                            : Colors.transparent)
                        : widget.textColor,
                    fontFamily: widget.selectedFont,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: widget.isBlinking
                            ? (_controller.value < 0.5
                                ? widget.blurColor
                                : Colors.transparent)
                            : widget.blurColor,
                        offset: Offset(5.0, 2.0),
                      ),
                    ],
                    decoration: TextDecoration.none,
                  ),
                  scrollAxis: Axis.horizontal,
                  blankSpace: 20.0,
                  velocity: speedProvider.textSpeed,
                  textDirection: widget.textDirection,
                );
              },
            ),
          ]),
        ),
        // Text Marquee
      ],
    );
  }
}
