import 'package:flutter/material.dart';

class BannerProvider extends ChangeNotifier {
  double fontSize = 24.0;
  double speed = 50.0; // tốc độ chạy
  Color textColor = Colors.red;
  bool isBlinking = false;
  String direction = "left";
  String fontFamily = 'Roboto';

  void updateFontSize(double size) {
    fontSize = size;
    notifyListeners();
  }

  void updateSpeed(double value) {
    speed = value;
    notifyListeners();
  }

  void updateColor(Color color) {
    textColor = color;
    notifyListeners();
  }

  void toggleBlinking(bool value) {
    isBlinking = value;
    notifyListeners();
  }

  void updateDirection(String dir) {
    direction = dir;
    notifyListeners();
  }

  void updateFontFamily(String font) {
    fontFamily = font;
    notifyListeners();
  }
}
