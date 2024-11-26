import 'package:flutter/cupertino.dart';

class SpeedProvider extends ChangeNotifier{
  double _textSpeed = 100.0;
  double get textSpeed => _textSpeed;
  double _textBlink = 1.0;
  double get textBlink => _textBlink;

  void initState(){
    _textSpeed = 20.0;
    _textBlink = 0;
    notifyListeners();
  }
  void setTextSpeed(double speed){
    _textSpeed = speed;
    notifyListeners();
  }
  void setTextBlink(double blinkValue){
    _textBlink = blinkValue;
    notifyListeners();
  }

}