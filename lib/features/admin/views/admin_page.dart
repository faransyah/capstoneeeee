// lib/features/admin/views/admin_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:capstone_flutter/features/add_user/views/add_user_page.dart';
import 'package:capstone_flutter/features/login/views/login_page.dart';

// ▼▼▼ PASTIKAN IMPOR INI ADA DAN TIDAK DUPLIKAT ▼▼▼
import 'package:capstone_flutter/features/login/cubit/login_cubit.dart';
// ▲▲▲ IMPOR INI MEMPERBAIKI ERROR 'LoginState' ANDA ▲▲▲

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
    // Tambahkan listener untuk search bar
    _searchController.addListener(_onSearchChanged);
    
    // Panggil fetchUsers() saat halaman pertama kali dimuat
    context.read<AdminCubit>().fetchUsers();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Panggil filterUsers di cubit setiap kali teks berubah
    context.read<AdminCubit>().filterUsers(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    // Kita tambahkan 2 Listener:
    // 1. (Luar) Listener untuk LoginCubit (Global Logout)
    // 2. (Dalam) Listener untuk AdminCubit (Error Handling Halaman Ini)

    // ▼▼▼ INI PERBAIKAN TYPO ANDA ('L' besar) ▼▼▼
    return BlocListener<LoginCubit, LoginState>(
      // 1. DENGARKAN GLOBAL LOGOUT
      listener: (context, state) {
        if (state is LoginInitial) {
          // Jika LoginCubit kembali ke Initial (setelah logout)
          // paksa kembali ke LoginPage
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          actions: [
            // Tombol logout sekarang memanggil LoginCubit
            IconButton(
              onPressed: () {
                // Tampilkan dialog konfirmasi
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
                          // Panggil logout dari LoginCubit
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
        // BlocConsumer untuk membangun UI dan menangani error AdminCubit
        body: BlocConsumer<AdminCubit, AdminState>(
          // 2. DENGARKAN ERROR LOKAL (TOKEN EXPIRED, DLL)
          listener: (context, state) {
            if (state is AdminFailure) {
              // Jika fetchUsers gagal (misal token expired/tidak ada)
              // Tampilkan pesan error...
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(state.error),
                ),
              );
              // ...dan panggil global logout jika errornya soal token
              if (state.error.contains("Token") ||
                  state.error.contains("Sesi")) {
                context.read<LoginCubit>().logout();
              }
            }
          },
          // BUILDER untuk membangun UI
          builder: (context, state) {
            return RefreshIndicator(
              // Tambahkan pull-to-refresh
              onRefresh: () => context.read<AdminCubit>().fetchUsers(),
              child: _buildBody(context, state),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Refresh data setelah kembali dari AddUserPage
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddUserPage()),
            );
            // Jika AddUserPage mengembalikan 'true', refresh data
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
    // Tampilkan loading di tengah
    if (state is AdminLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Tampilkan error jika state = AdminFailure
    if (state is AdminFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Oops! Terjadi kesalahan',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                state.error,
                style: TextStyle(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.read<AdminCubit>().fetchUsers(),
                child: const Text('Coba Lagi'),
              )
            ],
          ),
        ),
      );
    }

    // Tampilkan data jika state = AdminSuccess
    if (state is AdminSuccess) {
      final users = state.filteredUsers;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              // Hapus onChanged dari sini karena sudah di handle listener
              decoration: InputDecoration(
                hintText: 'Cari user...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Daftar User (${users.length})",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: users.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'Belum ada data user.'
                            : 'User tidak ditemukan.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    )
                  // Pastikan ListView bisa di-scroll walaupun item sedikit
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            title: Text(user['name'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(user['role'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Tooltip(
                                  message: 'Edit User',
                                  child: IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    color: Colors.blue.shade700,
                                    onPressed: () {
                                      // TODO: Logika Edit
                                    },
                                  ),
                                ),
                                Tooltip(
                                  message: 'Hapus User',
                                  child: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    color: Colors.red.shade700,
                                    onPressed: () {
                                      // TODO: Logika Hapus
                                    },
                                  ),
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

    // State awal (AdminInitial)
    return const Center(child: Text("Memuat..."));
  }
}