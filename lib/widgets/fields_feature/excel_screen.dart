import 'package:flutter/material.dart';

class ExcelScreen extends StatelessWidget {
  const ExcelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Excel Screen",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
