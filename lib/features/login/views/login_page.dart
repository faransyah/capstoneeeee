// lib/features/login/views/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/login_cubit.dart';

// Import halaman tujuan
import 'package:capstone_flutter/features/user/views/user_page.dart';
import 'package:capstone_flutter/features/admin/views/admin_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Warna Tema sesuai gambar (Teal/Hijau Tosca)
  final Color _primaryColor = const Color(0xFF0C9869); 
  final Color _backgroundColor = const Color(0xFF0C9869);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Background warna hijau
      backgroundColor: _backgroundColor,
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            if (state.role == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminPage()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UserPage(userName: state.name),
                ),
              );
            }
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(state.error),
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: SizedBox(
              height: size.height,
              child: Stack(
                children: [
                  // --- BAGIAN ATAS (Text & Gambar) ---
                  Positioned(
                    top: size.height * 0.12,
                    left: 24,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello!",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Selamat Datang", // Ganti nama aplikasi kamu
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: size.height * 0.08,
                    right: 10,
                    child: Container(
                      width: 120, // Lebar pot
                      height: 120, // Tinggi pot
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // <--- Ini yang bikin bulat!
                        color: Colors.white, // Warna background pot (putih)
                        boxShadow: [ // Agar ada sedikit efek kedalaman
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval( // <--- Ini yang memotong gambar jadi lingkaran
                        child: Image.asset(
                          'assets/logo.png', // Pastikan path gambar logo kamu benar
                          fit: BoxFit.cover, // Gambar akan mengisi area lingkaran tanpa distorsi
                          errorBuilder: (ctx, err, st) => const Icon(
                            Icons.local_florist,
                            size: 80,
                            color: Color(0xFF0C9869),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // --- BAGIAN BAWAH (Form Putih) ---
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: size.height * 0.7, // Mengambil 70% layar
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Judul Form
                          const Text(
                            "Masuk Ke Akun Anda",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Input Email/Username
                          _buildCustomTextField(
                            controller: _usernameController,
                            hintText: "Email",
                            icon: Icons.person_outline,
                            enabled: state is! LoginLoading,
                          ),
                          const SizedBox(height: 20),

                          // Input Password
                          _buildCustomTextField(
                            controller: _passwordController,
                            hintText: "Password",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            enabled: state is! LoginLoading,
                          ),

                          

                          // Tombol Login
                          SizedBox(
                            height: 55,
                            child: state is LoginLoading
                                ? Center(child: CircularProgressIndicator(color: _primaryColor))
                                : ElevatedButton(
                                    onPressed: () {
                                      context.read<LoginCubit>().login(
                                            _usernameController.text,
                                            _passwordController.text,
                                          );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 50),

                          

                       

                          
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget Custom TextField agar mirip gambar (Putih bersih dengan shadow/border halus)
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none, // Hilangkan border default
          ),
          filled: true,
          fillColor: Colors.grey[50], // Agak abu sangat muda
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // Widget Tombol Sosmed
  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}