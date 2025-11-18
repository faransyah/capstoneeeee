// lib/features/login/views/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/login_cubit.dart';

// Pastikan import halaman tujuan benar
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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ❌ JANGAN PAKAI BlocProvider(create:...) DI SINI
    // Langsung return Scaffold, karena Cubit sudah ada di main.dart
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            // Navigasi User vs Admin
            if (state.role == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminPage()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  // Kirim nama user ke UserPage
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
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- LOGO ---
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/logo.png',
                          height: 120,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120, width: 120, color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // --- HEADER TEXT ---
                      Text(
                        "Masuk ke akun Anda",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // --- INPUT EMAIL ---
                      _buildTextField(
                        controller: _usernameController,
                        label: "Email",
                        enabled: state is! LoginLoading,
                      ),
                      const SizedBox(height: 20),

                      // --- INPUT PASSWORD ---
                      _buildTextField(
                        controller: _passwordController,
                        label: "Password",
                        obscureText: true,
                        enabled: state is! LoginLoading,
                      ),
                      const SizedBox(height: 40),

                      // --- TOMBOL LOGIN ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: (state is LoginLoading)
                            ? const Center(
                                child: CircularProgressIndicator(color: Color(0xFF2E3A85)))
                            : ElevatedButton(
                                onPressed: () {
                                  // Memanggil fungsi login dari Global Cubit
                                  context.read<LoginCubit>().login(
                                        _usernameController.text,
                                        _passwordController.text,
                                      );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E3A85),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2E3A85), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}