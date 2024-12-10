
import 'package:flutter/material.dart';

class MusicSycnProvider extends ChangeNotifier{
  bool _isBlink = false;
  bool get isBlink => _isBlink;
  void initState(){
    _isBlink = true;
    notifyListeners();
  }
  void setBlink(bool blink){
    _isBlink = blink;
    notifyListeners();
  }

}