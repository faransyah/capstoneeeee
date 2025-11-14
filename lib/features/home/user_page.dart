import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Halaman Beranda")),
      body: const Center(
        child: Text(
          "SELAMAT DATANG, USER!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}