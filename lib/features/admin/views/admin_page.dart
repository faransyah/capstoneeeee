// lib/features/admin/views/admin_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:capstone_flutter/features/add_user/views/add_user_page.dart';
import 'package:capstone_flutter/features/login/views/login_page.dart';
import 'package:capstone_flutter/features/login/cubit/login_cubit.dart';
// Pastikan import ini sesuai dengan lokasi file UpdateUserPage kamu
import 'package:capstone_flutter/features/update_user/views/update_user_page.dart'; 
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Panggil data saat halaman dibuka
    context.read<AdminCubit>().fetchUsers();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<AdminCubit>().filterUsers(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    // Listener untuk Logout Global
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginInitial) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        // Background Biru
        backgroundColor: const Color(0xFF2E3A85),
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          backgroundColor: const Color(0xFF2E3A85),
          foregroundColor: Colors.white,
          elevation: 0,
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
                        child: const Text('Batal'),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                      TextButton(
                        child: const Text('Logout',
                            style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.read<LoginCubit>().logout();
                        },
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            )
          ],
        ),
        // Body dengan BlocConsumer untuk AdminCubit
        body: BlocConsumer<AdminCubit, AdminState>(
          listener: (context, state) {
            if (state is AdminFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(state.error),
                ),
              );
              // Jika error karena token, logout paksa
              if (state.error.contains("Token") ||
                  state.error.contains("Sesi")) {
                context.read<LoginCubit>().logout();
              }
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<AdminCubit>().fetchUsers(),
              child: _buildBody(context, state),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2E3A85),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddUserPage()),
            );
            if (result == true) {
              context.read<AdminCubit>().fetchUsers();
            }
          },
          tooltip: 'Tambah User Baru',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AdminState state) {
    // Loading
    if (state is AdminLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // Error View
    if (state is AdminFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.white70),
              const SizedBox(height: 16),
              Text(
                'Oops! Terjadi kesalahan',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                state.error,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.read<AdminCubit>().fetchUsers(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2E3A85),
                ),
                child: const Text('Coba Lagi'),
              )
            ],
          ),
        ),
      );
    }

    // Success View
    if (state is AdminSuccess) {
      final users = state.filteredUsers;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Cari user...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              "Daftar User (${users.length})",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 12),
            
            // List User
            Expanded(
              child: users.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'Belum ada data user.'
                            : 'User tidak ditemukan.',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 0,
                          // Card Putih Bening
                          color: Colors.white.withOpacity(0.9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            
                            // --- FOTO USER (user.png) ---
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.transparent,
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/user.png', // Pastikan file ini ada
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person, 
                                        size: 30, color: Color(0xFF2E3A85));
                                  },
                                ),
                              ),
                            ),
                            
                            // Nama & Role
                            title: Text(user['name'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    color: Colors.black87)),
                            subtitle: Text(user['role'] ?? '',
                                style: TextStyle(color: Colors.grey[700])),
                            
                            // Tombol Edit & Delete
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ▼▼▼ TOMBOL EDIT (UPDATE) SUDAH AKTIF ▼▼▼
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  color: Colors.blue.shade700,
                                  onPressed: () async {
                                    // Navigasi ke UpdateUserPage
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => UpdateUserPage(user: user),
                                      ),
                                    );
                                    
                                    // Jika update berhasil (result == true), refresh data
                                    if (result == true) {
                                      context.read<AdminCubit>().fetchUsers();
                                    }
                                  },
                                ),
                                
                                // ▼▼▼ TOMBOL DELETE (HAPUS) SUDAH DIPERBAIKI ▼▼▼
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red.shade700,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Hapus User"),
                                        content: Text("Yakin ingin mengapus user '${user['name']}'?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(ctx).pop(),
                                            child: const Text("Batal"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(ctx).pop(); // Tutup dialog
                                              
                                              final userId = user['id'];
                                              if (userId != null) {
                                                context.read<AdminCubit>().deleteUser(userId);
                                              }
                                            },
                                            child: const Text("Hapus", 
                                                style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    }

    return const Center(
        child: CircularProgressIndicator(color: Colors.white));
  }
}