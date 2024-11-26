import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:ledbanner_test/preview_screen.dart';
import 'package:ledbanner_test/speed_provider.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

class LedBannerHome extends StatefulWidget {
  @override
  _LedBannerHomeState createState() => _LedBannerHomeState();
}

class _LedBannerHomeState extends State<LedBannerHome>
    with SingleTickerProviderStateMixin {
  String displayText = "LED Banner Text";
  double fontSize = 20.0;
  double scrollSpeed = 10.0;
  Color textColor = Colors.red;
  bool isBlinking = false;
  TextDirection textDirection = TextDirection.ltr;
  String selectedFont = 'Roboto';
  double blinkValue = 0;
  List<String> fonts = ['Roboto', 'Arial', 'Courier New', 'Times New Roman'];
  Color blurColor = Colors.black;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final speedProvider = Provider.of<SpeedProvider>(context, listen: false);
    _initializeBlinkController(speedProvider.textBlink);
  }

  void _initializeBlinkController(double textBlinkSpeed) {
    _controller = AnimationController(
      duration: Duration(milliseconds: textBlinkSpeed.toInt() < 0 ? 100 :  textBlinkSpeed.toInt()),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final speedProvider = Provider.of<SpeedProvider>(context);

    if (isBlinking) {
      // Dừng controller nếu đang chạy
      _controller.stop();

      // Cập nhật duration
      _controller.duration =
          Duration(milliseconds: speedProvider.textBlink.toInt());

      // Khởi động lại nhấp nháy
      _controller.reset();
      _controller.repeat(reverse: true);
    } else {
      _controller.stop(); // Dừng nhấp nháy nếu isBlinking = false
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speedProvider = Provider.of<SpeedProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: const Text("LED Banner"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Preview:"),
            // _buildPreview(),
            PreviewWidget(
              displayText: displayText,
              fontSize: fontSize,
              textColor: textColor,
              isBlinking: isBlinking,
              textDirection: textDirection,
              selectedFont: selectedFont,
              blurColor: blurColor,
            ),
            const Text("Text:"),
            TextField(
              onChanged: (value) {
                setState(() {
                  displayText = value;
                });
              },
              decoration: const InputDecoration(hintText: "Enter text"),
            ),
            const SizedBox(height: 10),
            const Text("Font Size:"),
            Slider(
              value: fontSize,
              min: 10,
              max: 100,
              label: fontSize.toString(),
              onChanged: (value) {
                setState(() {
                  fontSize = value;
                });
              },
            ),
            const Text("Scroll Speed:"),

            //SPEED
            Slider(
              value: speedProvider.textSpeed,
              min: 10,
              max: 300,
              // divisions: 19,
              label: speedProvider.textSpeed.toString(),
              onChanged: (value) {
                speedProvider.setTextSpeed(value);
              },
              onChangeEnd: (value) {
                print('speed:  ${value}');
              },
            ),
            const Text("Text Color:"),
            Row(
              children: [
                ElevatedButton(
                  onPressed: ()=>  _pickColor('text'),
                  child: const Text("Pick Color"),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: textColor,
                    shape: BoxShape.circle,
                  ),
                ),

              ],
            ),
            const Text("Blinking Effect:"),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    speedProvider.setTextBlink(0); // Tắt nhấp nháy
                    isBlinking = false;
                  },
                  child: const Text("0"),
                ),
                TextButton(
                  onPressed: () {
                    isBlinking = true;
                    speedProvider.setTextBlink(400); // 0.5 giây/vòng
                  },
                  child: const Text("0.5"),
                ),
                TextButton(
                  onPressed: () {
                    isBlinking = true;
                    speedProvider.setTextBlink(300); // 1.0 giây/vòng
                  },
                  child: const Text("1.0"),
                ),
                TextButton(
                  onPressed: () {
                    isBlinking = true;
                    speedProvider.setTextBlink(200); // 1.5 giây/vòng
                  },
                  child: const Text("1.5"),
                ),
                TextButton(
                  onPressed: () {
                    isBlinking = true;
                    speedProvider.setTextBlink(100); // 2.0 giây/vòng
                  },
                  child: const Text("2.0"),
                ),
              ],
            ),

            const Text("Scroll Direction:"),
            DropdownButton<TextDirection>(
              value: textDirection,
              items: const [
                DropdownMenuItem(
                  value: TextDirection.ltr,
                  child: Text("Left to Right"),
                ),
                DropdownMenuItem(
                  value: TextDirection.rtl,
                  child: Text("Right to Left"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  switch (value) {
                    case TextDirection.ltr:
                      textDirection = TextDirection.ltr;
                      break;
                    case TextDirection.rtl:
                      textDirection = TextDirection.rtl;
                      break;
                    default:
                      textDirection = TextDirection.ltr; // Giá trị mặc định
                  }
                });
              },
            ),

            const Text("Font:"),
            DropdownButton<String>(
              value: selectedFont,
              items: fonts.map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(font),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedFont = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text("blur color:"),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _pickColor('blur'),
                  child: const Text("Pick Color"),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: blurColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await SystemChrome.setPreferredOrientations([
                    DeviceOrientation.landscapeRight,
                    DeviceOrientation.landscapeLeft
                  ]);
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PreviewWidget(
                          displayText: displayText,
                          fontSize: fontSize,
                          textColor: textColor,
                          isBlinking: isBlinking,
                          textDirection: textDirection,
                          selectedFont: selectedFont,
                          blurColor: blurColor,
                      ),
                    ),
                  ).then((_) {
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitDown,
                      DeviceOrientation.portraitUp
                    ]);
                  });
                },
                child: const Text("RUN"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildPreview() {
  //   final speedProvider = Provider.of<SpeedProvider>(context, listen: true);
  //
  //   return AnimatedBuilder(
  //     animation: _controller,
  //     builder: (context, child) {
  //       return Container(
  //         height: 150,
  //         color: Colors.black,
  //         child: Marquee(
  //           text: displayText.isNotEmpty ? displayText : "Preview Text",
  //           style: TextStyle(
  //             fontSize: fontSize,
  //             color: isBlinking
  //                 ? (_controller.value < 0.5 ? textColor : Colors.transparent)
  //                 : textColor,
  //             fontFamily: selectedFont,
  //           ),
  //           scrollAxis: Axis.horizontal,
  //           blankSpace: 20.0,
  //           velocity: speedProvider.textSpeed,
  //           textDirection: textDirection,
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<void> _pickColor(String colorType) async {
    Color selectedColor = colorType == 'blur' ? blurColor : textColor; // Lấy giá trị hiện tại

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn màu'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                selectedColor = color; // Cập nhật giá trị tạm thời
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('HỦY'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('CHỌN'),
              onPressed: () {
                setState(() {
                  // Cập nhật màu gốc dựa trên loại
                  if (colorType == 'blur') {
                    blurColor = selectedColor;
                  } else if (colorType == 'text') {
                    textColor = selectedColor;
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
