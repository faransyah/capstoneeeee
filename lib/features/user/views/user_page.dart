// lib/features/user/views/user_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:capstone_flutter/features/login/cubit/login_cubit.dart';
import 'package:capstone_flutter/features/login/views/login_page.dart';

// Pastikan file ini ada (walau dummy)
import 'detection_page.dart'; 

class UserPage extends StatelessWidget {
  final String userName;

  const UserPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        // Logika Logout:
        // Jika state berubah jadi Initial (artinya token dihapus), lempar ke Login
        if (state is LoginInitial) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Halo, $userName",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Konfirmasi Logout'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          // Panggil logout dari Global Cubit
                          context.read<LoginCubit>().logout();
                        },
                        child: const Text('Logout', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Pilih Level Deteksi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildLevelCard(
                context: context,
                level: 1,
                title: 'Level 1',
                subtitle: 'Deteksi Dasar',
                icon: Icons.looks_one_outlined,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              _buildLevelCard(
                context: context,
                level: 2,
                title: 'Level 2',
                subtitle: 'Deteksi Menengah',
                icon: Icons.looks_two_outlined,
                color: Colors.orange,
              ),
              const SizedBox(height: 20),
              _buildLevelCard(
                context: context,
                level: 3,
                title: 'Level 3',
                subtitle: 'Deteksi Lanjutan',
                icon: Icons.looks_3_outlined,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard({
    required BuildContext context,
    required int level,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetectionPage(level: level),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}