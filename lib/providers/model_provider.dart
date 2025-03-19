// lib/providers/model_provider.dart
import 'package:flutter/foundation.dart';

class ModelProvider with ChangeNotifier {
  String _currentModel = 'grape';

  String get currentModel => _currentModel;

  void setModel(String model) {
    _currentModel = model;
    notifyListeners();
  }
}
