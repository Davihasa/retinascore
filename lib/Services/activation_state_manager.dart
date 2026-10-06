import 'package:flutter/material.dart';

class ActivationState extends ChangeNotifier {
  bool _activated = false;

  bool get activated => _activated;

  void toggle() {
    _activated = !_activated;
    notifyListeners();
  }

  void setActivated(bool value){
    _activated = value;
  }
}