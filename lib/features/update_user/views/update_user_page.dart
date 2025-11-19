import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/update_user_cubit.dart';

class UpdateUserPage extends StatefulWidget {
  final Map<String, dynamic> user; // Data user yang dikirim dari Admin Page

  const UpdateUserPage({super.key, required this.user});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();
  
  String _selectedRole = 'user';

  @override
  void initState() {
    super.initState();
    // Isi form dengan data lama
    _nameController = TextEditingController(text: widget.user['name']);
    _emailController = TextEditingController(text: widget.user['email']);
    _selectedRole = widget.user['role'] ?? 'user';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Bungkus halaman dengan BlocProvider UpdateUserCubit
    return BlocProvider(
      create: (context) => UpdateUserCubit(),
      child: Scaffold(
        backgroundColor: const Color(0xFF2E3A85),
        appBar: AppBar(
          title: const Text("Edit User"),
          backgroundColor: const Color(0xFF2E3A85),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocConsumer<UpdateUserCubit, UpdateUserState>(
          listener: (context, state) {
            if (state is UpdateUserSuccess) {
              // Tampilkan pesan sukses
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
              // Kembali ke AdminPage dengan sinyal "true" (artinya ada perubahan)
              Navigator.pop(context, true);
            } else if (state is UpdateUserFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is UpdateUserLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Perbarui Data User",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, 
                              fontWeight: FontWeight.bold, 
                              color: Color(0xFF2E3A85)),
                        ),
                        const SizedBox(height: 24),
                        
                        // Input Nama
                        _buildTextField(
                          controller: _nameController,
                          label: "Nama Lengkap",
                          icon: Icons.person,
                          validator: (val) => val!.isEmpty ? "Nama wajib diisi" : null,
                        ),
                        const SizedBox(height: 16),

                        // Input Email
                        _buildTextField(
                          controller: _emailController,
                          label: "Email",
                          icon: Icons.email,
                          validator: (val) => val!.isEmpty ? "Email wajib diisi" : null,
                        ),
                        const SizedBox(height: 16),

                        // Dropdown Role
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: _inputDecoration("Role", Icons.admin_panel_settings),
                          items: const [
                            DropdownMenuItem(value: 'user', child: Text('User')),
                            DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          ],
                          onChanged: (val) => setState(() => _selectedRole = val!),
                        ),
                        const SizedBox(height: 16),

                        // Input Password
                        _buildTextField(
                          controller: _passwordController,
                          label: "Password Baru",
                          icon: Icons.lock,
                          obscureText: true,
                          helperText: "Kosongkan jika tidak ingin mengubah password",
                        ),
                        const SizedBox(height: 32),

                        // Tombol Simpan
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      // Siapkan Data
                                      final Map<String, dynamic> data = {
                                        'name': _nameController.text,
                                        'email': _emailController.text,
                                        'role': _selectedRole,
                                      };
                                      if (_passwordController.text.isNotEmpty) {
                                        data['password'] = _passwordController.text;
                                      }
                                      
                                      // Panggil Cubit
                                      final userId = widget.user['id'];
                                      context.read<UpdateUserCubit>().updateUser(userId, data);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E3A85),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Simpan Perubahan",
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold)),
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
      ),
    );
  }

  // Helper Widget untuk Text Field agar kodingan lebih rapi
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: _inputDecoration(label, icon).copyWith(
        helperText: helperText,
        helperStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF2E3A85)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,    
      fillColor: Colors.white,
    );
  }
}