// import 'package:flutter/material.dart';

// enum FieldType { Numeric, Text, Image }

// class Field {
//   String fieldName;
//   IconData fieldIcon;
//   bool isSelected;
//   FieldType fieldType;

//   Field(this.fieldName, this.fieldIcon, this.isSelected, this.fieldType);
// }

// class FieldProvider extends ChangeNotifier {
//   List<Field> _field = [];

//   List<Field> get field => _field;

//   void addFields(Field field) {
//     _field.add(field);
//     notifyListeners();
//   }

//   void updateField(int index, Field newField) {
//     _field[index] = newField;
//     notifyListeners();
//   }

//   void removeField(int index, Field field) {
//     _field.removeAt(index);
//     notifyListeners();
//   }

//   void fieldSelection(int index) {
//     _field[index].isSelected = !_field[index].isSelected;
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum FieldType { Numeric, Text, Image }

class Field {
  String fieldName;
  IconData fieldIcon;
  bool isSelected;
  FieldType fieldType;

  Field(this.fieldName, this.fieldIcon, this.isSelected, this.fieldType);

  Map<String, dynamic> toJson() {
    return {
      'fieldName': fieldName,
      'fieldIcon': fieldIcon.codePoint,
      'isSelected': isSelected,
      'fieldType': fieldType.toString(),
    };
  }

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      json['fieldName'],
      IconData(json['fieldIcon'], fontFamily: 'MaterialIcons'),
      json['isSelected'],
      FieldType.values.firstWhere((e) => e.toString() == json['fieldType']),
    );
  }
}

class FieldProvider extends ChangeNotifier {
  List<Field> _fields = [];

  List<Field> get fields => _fields;

  FieldProvider() {
    _loadFields();
  }

  void addFields(Field field) {
    _fields.add(field);
    _saveFields();
    notifyListeners();
  }

  void updateField(int index, Field newField) {
    _fields[index] = newField;
    _saveFields();
    notifyListeners();
  }

  void removeField(int index, field) {
    _fields.removeAt(index);
    _saveFields();
    notifyListeners();
  }

  void fieldSelection(int index) {
    _fields[index].isSelected = !_fields[index].isSelected;
    _saveFields();
    notifyListeners();
  }

  Future<void> _saveFields() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> fieldsJson =
        _fields.map((field) => json.encode(field.toJson())).toList();
    await prefs.setStringList('fields', fieldsJson);
  }

  Future<void> _loadFields() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? fieldsJson = prefs.getStringList('fields');
    if (fieldsJson != null) {
      _fields = fieldsJson
          .map((fieldJson) => Field.fromJson(json.decode(fieldJson)))
          .toList();
      notifyListeners();
    }
  }
}
