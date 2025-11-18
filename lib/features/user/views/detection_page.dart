// lib/features/user/views/detection_page.dart

import 'package:flutter/material.dart';

class DetectionPage extends StatelessWidget {
  final int level;

  const DetectionPage({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Deteksi Level $level")),
      body: const Center(
        child: Text("Fitur Deteksi Akan Dibuat Nanti"),
      ),
    );
  }
}