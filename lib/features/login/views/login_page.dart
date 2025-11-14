// lib/features/login/view/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';

// Impor ini akan terpakai setelah listener-nya diperbaiki
import 'package:capstone_flutter/features/admin/views/admin_page.dart';
import 'package:capstone_flutter/features/home/user_page.dart';

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

  

// ... (Bagian import dan class _LoginPageState tetap sama)

@override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (context) => LoginCubit(), // <-- Pastikan ini LoginCubit
    child: Scaffold(
      // ▼▼▼ PERUBAHAN WARNA BACKGROUND ▼▼▼
      // Kita ubah jadi abu-abu sangat terang agar Card putihnya terlihat
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      // ▲▲▲ AKHIR PERUBAHAN ▲▲▲

      body: BlocConsumer<LoginCubit, LoginState>(
        // ▼▼▼ LISTENER TETAP SAMA ▼▼▼
        listener: (context, state) {
          if (state is LoginSuccess) {
            // ... (logika navigasi Anda sudah benar)
            if (state.role == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminPage()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UserPage()),
              );
            }
          } else if (state is LoginFailure) {
            // ... (logika snackbar Anda sudah benar)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(state.error),
              ),
            );
          }
        },
        // ▲▲▲ SAMPAI SINI ▲▲▲

        // ▼▼▼ KITA HANYA MENGUBAH BUILDER ▼▼▼
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Card(
                // Card akan otomatis berwarna putih di sini
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/logo.png', // GANTI INI
                          height: 120,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: 120,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              child: const Center(child: Text("Logo Anda")),
                            );
                          },
                        ),
                      ),
                      
                      // ▼▼▼ TAMBAHAN TEKS BARU ▼▼▼
                      const SizedBox(height: 16), // Jarak dari logo
                      Text(
                        "Masuk ke akun Anda",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // ▲▲▲ AKHIR TAMBAHAN ▲▲▲

                      const SizedBox(height: 40), // Jarak ke email
                      
                      _buildTextField(
                        controller: _usernameController,
                        label: "Email", // Label kita ubah jadi Email
                        enabled: state is! LoginLoading,
                      ),
                      
                      // SizedBox(height: 20) tetap dihapus agar 'nempel'

                      _buildTextField(
                        controller: _passwordController,
                        label: "Password",
                        obscureText: true,
                        enabled: state is! LoginLoading,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: (state is LoginLoading)
                            ? const Center(
                                child: CircularProgressIndicator(
                                  // Warna ini (biru) akan kontras
                                  // dengan background Card putih
                                  color: Color(0xFF2E3A85),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {
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
                                  "login",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                      // Ikon Fingerprint tetap dihapus
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        // ▲▲▲ SAMPAI SINI ▲▲▲
      ),
    ),
  );
}

// Widget _buildTextField tidak berubah dari sebelumnya
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
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    ),
  );
}
}