import 'package:flutter/material.dart';

class QrResultScreen extends StatelessWidget {
  final String qrResult;

  const QrResultScreen({super.key, required this.qrResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Result')),
      body: Center(
        child: Text(qrResult),
      ),
    );
  }
}
