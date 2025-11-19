// lib/features/user/views/user_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:capstone_flutter/features/login/cubit/login_cubit.dart';
import 'package:capstone_flutter/features/login/views/login_page.dart';

// Pastikan file ini ada
import 'detection_page.dart'; 

class UserPage extends StatelessWidget {
  final String userName;

  const UserPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        // Logika Logout: Jika token hilang, kembali ke Login
        if (state is LoginInitial) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        // ▼▼▼ 1. BACKGROUND BIRU SEPERTI ADMIN PAGE ▼▼▼
        backgroundColor: const Color(0xFF2E3A85),
        
        appBar: AppBar(
          // ▼▼▼ 2. APPBAR MENYATU DENGAN BACKGROUND ▼▼▼
          backgroundColor: const Color(0xFF2E3A85),
          foregroundColor: Colors.white, // Teks & Icon Putih
          elevation: 0,
          title: Row(
            children: [
              // Opsional: Menambahkan Icon User kecil di sebelah nama
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.person, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                "Halo, $userName",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
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
              // ▼▼▼ 3. TEKS JUDUL JADI PUTIH ▼▼▼
              const Text(
                'Pilih Level Deteksi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Ubah warna jadi putih
                ),
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
      elevation: 0, // Flat look seperti admin
      // ▼▼▼ 4. CARD JADI PUTIH BENING (GLASSMORPHISM) ▼▼▼
      color: Colors.white.withOpacity(0.9),
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
              // Icon tetap berwarna agar kontras
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: const TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87 // Teks dalam card tetap gelap
                    )
                  ),
                  Text(
                    subtitle, 
                    style: TextStyle(
                      fontSize: 14, 
                      color: Colors.grey[700] // Subtitle abu gelap
                    )
                  ),
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