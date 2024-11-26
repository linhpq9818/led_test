import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:marquee/marquee.dart';

class LEDBannerScreen extends StatefulWidget {
  const LEDBannerScreen({super.key});

  @override
  _LEDBannerScreenState createState() => _LEDBannerScreenState();
}

class _LEDBannerScreenState extends State<LEDBannerScreen> {
  // Các giá trị mặc định cho các thuộc tính
  double _fontSize = 30.0;
  double _speed = 30.0;
  Color _textColor = Colors.white;
  bool _isBlinking = false;
  bool _isMovingLeft = true;
  String _text = "Hello, this is a LED banner!";
  TextStyle _textStyle = const TextStyle(fontSize: 30.0);

  void _runLEDText() {
    setState(() {
      // Lấy text style từ người dùng đã chọn
      _textStyle = TextStyle(
        fontSize: _fontSize,
        color: _textColor,
        fontWeight: FontWeight.bold,
        decoration: _isBlinking ? TextDecoration.underline : TextDecoration.none,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LED Banner')),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Các điều khiển cho người dùng
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Enter Text'),
                  onChanged: (value) {
                    setState(() {
                      _text = value;
                    });
                  },
                ),
              ),
              Slider(
                value: _fontSize,
                min: 10,
                max: 100,
                label: 'Font Size',
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                },
              ),
              Slider(
                value: _speed,
                min: 10,
                max: 100,
                label: 'Speed',
                onChanged: (value) {
                  setState(() {
                    _speed = value;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Blink Text'),
                  Switch(
                    value: _isBlinking,
                    onChanged: (value) {
                      setState(() {
                        _isBlinking = value;
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Move Left'),
                  Switch(
                    value: _isMovingLeft,
                    onChanged: (value) {
                      setState(() {
                        _isMovingLeft = value;
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Text Color: '),
                  IconButton(
                    icon: const Icon(Icons.color_lens),
                    onPressed: () async {
                      Color? selectedColor = await showDialog<Color>(
                        context: context,
                        builder: (context) => ColorPickerDialog(),
                      );
                      if (selectedColor != null) {
                        setState(() {
                          _textColor = selectedColor;
                        });
                      }
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _runLEDText,
                child: const Text('Run'),
              ),
              const SizedBox(height: 20),
              // Màn preview
              Container(
                padding: const EdgeInsets.all(8.0),
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Marquee(
                  text: _text,
                  style: _textStyle,
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  velocity: _speed,
                  blankSpace: 100.0,
                  pauseAfterRound: const Duration(seconds: 1),
                  startPadding: 10.0,
                  textDirection: _isMovingLeft ? TextDirection.rtl : TextDirection.ltr,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Dialog để chọn màu
class ColorPickerDialog extends StatelessWidget {
  const ColorPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a color'),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: Colors.white,
          onColorChanged: (color) {
            Navigator.pop(context, color);
          },
        ),
      ),
    );
  }
}