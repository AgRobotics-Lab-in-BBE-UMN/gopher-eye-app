import 'package:flutter/material.dart';

class PlotProvider extends ChangeNotifier {
  int _plot = 0;

  int get plot => _plot;

  void setPlot(int value) {
    _plot = value;
    notifyListeners();
  }
}