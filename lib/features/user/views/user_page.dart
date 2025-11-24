// lib/features/user/views/user_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:capstone_flutter/features/login/cubit/login_cubit.dart';
import 'package:capstone_flutter/features/login/views/login_page.dart';

// Pastikan file ini ada di satu folder
import 'detection_page.dart'; 

class UserPage extends StatelessWidget {
  final String userName;

  // Warna Utama (Hijau)
  final Color primaryColor = const Color(0xFF0C9869);

  const UserPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    // 1. LOGIKA LOGIN/LOGOUT (TIDAK DIUBAH)
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginInitial) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        // Background abu-abu sangat muda agar kartu putih terlihat menonjol
        backgroundColor: const Color(0xFFF5F7F6), 
        body: Column(
          children: [
            // ▼▼▼ HEADER CUSTOM (HIJAU MELENGKUNG) ▼▼▼
            _buildModernHeader(context),

            // ▼▼▼ LIST MENU LEVEL ▼▼▼
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                children: [
                  const Text(
                    "Pilih Tingkat Deteksi",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildModernCard(
                    context: context,
                    level: 1,
                    title: 'Level 1',
                    subtitle: 'Masker & Sarung Tangan',
                    icon: Icons.shield_outlined,
                  ),
                  const SizedBox(height: 16),

                  _buildModernCard(
                    context: context,
                    level: 2,
                    title: 'Level 2',
                    subtitle: 'Level 1 + Hazmat Suit',
                    icon: Icons.security,
                  ),
                  const SizedBox(height: 16),

                  _buildModernCard(
                    context: context,
                    level: 3,
                    title: 'Level 3',
                    subtitle: 'Full Protection (High Risk)',
                    icon: Icons.health_and_safety,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Header Hijau Melengkung
  Widget _buildModernHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Info User
          Row(
            children: [
              // Avatar Putih
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: primaryColor),
                ),
              ),
              const SizedBox(width: 15),
              // Teks Nama
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selamat Datang,",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    userName, // Data Dinamis
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Tombol Logout (Logika Tetap Sama)
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: () {
                // Panggil Dialog Logout
                _showLogoutDialog(context);
              },
            ),
          )
        ],
      ),
    );
  }

  // Widget Kartu Modern
  Widget _buildModernCard({
    required BuildContext context,
    required int level,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // 2. LOGIKA NAVIGASI (TIDAK DIUBAH)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetectionPage(level: level),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icon Box Hijau Muda
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: primaryColor, size: 30),
                ),
                const SizedBox(width: 20),
                
                // Teks Judul
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Panah
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[300], size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 3. LOGIKA LOGOUT (TIDAK DIUBAH)
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Konfirmasi Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<LoginCubit>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}