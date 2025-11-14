// lib/features/add_user/view/add_user_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/add_user_cubit.dart';
import '../cubit/add_user_state.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  // Buat controller untuk setiap field
  final _nameC = TextEditingController();
  // final _usernameC = TextEditingController(); <-- HAPUS
  final _emailC = TextEditingController();
  final _passwordC = TextEditingController();
  final _confirmPasswordC = TextEditingController();

  @override
  void dispose() {
    _nameC.dispose();
    // _usernameC.dispose(); <-- HAPUS
    _emailC.dispose();
    _passwordC.dispose();
    _confirmPasswordC.dispose();
    super.dispose();
  }

  // Fungsi helper untuk buat textfield
  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        obscureText: label.toLowerCase().contains('password'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddUserCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Tambah User Baru")),
        body: BlocConsumer<AddUserCubit, AddUserState>(
          // Listener untuk SnackBar
          listener: (context, state) {
            if (state is AddUserSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(state.message),
                ),
              );
              Navigator.pop(context); 
            } else if (state is AddUserFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(state.error),
                ),
              );
            }
          },
          // Builder untuk UI
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTextField(_nameC, "Nama Lengkap"),
                  // _buildTextField(_usernameC, "Username"), <-- HAPUS
                  _buildTextField(_emailC, "Email"),
                  _buildTextField(_passwordC, "Password"),
                  _buildTextField(_confirmPasswordC, "Konfirmasi Password"),
                  const SizedBox(height: 20),

                  (state is AddUserLoading)
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            if (_passwordC.text != _confirmPasswordC.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text("Password konfirmasi tidak cocok!"),
                                ),
                              );
                              return;
                            }

                            // Panggil cubit
                            context.read<AddUserCubit>().createUser(
                                  name: _nameC.text,
                                  // username: _usernameC.text, <-- HAPUS
                                  email: _emailC.text,
                                  password: _passwordC.text,
                                  passwordConfirmation: _confirmPasswordC.text,
                                );
                          },
                          child: const Text("Simpan User"),
                        )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}