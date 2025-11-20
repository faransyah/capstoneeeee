// lib/features/admin/views/admin_page.dart

import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'; 
import 'package:open_file/open_file.dart';        
import 'package:shared_preferences/shared_preferences.dart';

// Import halaman lain (Sesuaikan path jika berbeda)
import 'package:capstone_flutter/features/add_user/views/add_user_page.dart';
import 'package:capstone_flutter/features/login/views/login_page.dart';
import 'package:capstone_flutter/features/login/cubit/login_cubit.dart';
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
    // Panggil data user saat halaman dibuka
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

  // ▼▼▼ 1. LOGIKA DOWNLOAD DINAMIS (TERIMA TANGGAL) ▼▼▼
  Future<void> downloadExcel({DateTime? start, DateTime? end}) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            SizedBox(width: 15),
            Text("Mengunduh Laporan Excel..."),
          ],
        ),
        duration: Duration(seconds: 2), 
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      // Ganti IP sesuai environment
      // Emulator: 10.0.2.2 | HP Fisik: IP Laptop (misal 192.168.1.5)
      final String baseUrl = "http://10.0.2.2:8000"; 
      
      // Bangun URL dasar
      String urlString = '$baseUrl/api/reports/export/excel';

      // Jika ada tanggal, tambahkan parameter query
      if (start != null && end != null) {
        final startStr = "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
        final endStr = "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";
        urlString += "?start_date=$startStr&end_date=$endStr";
      }

      final url = Uri.parse(urlString);

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Cek apakah server mengirim JSON error
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.contains('application/json')) {
           throw Exception("Server mengirim teks error, bukan Excel.");
        }

        // Tentukan lokasi simpan
        Directory? directory;
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        // Nama file unik
        final fileName = 'Laporan_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final savePath = '${directory?.path ?? "/storage/emulated/0/Download"}/$fileName';
        final file = File(savePath);

        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Disimpan di: Download/$fileName"),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }

        // Buka file otomatis
        final result = await OpenFile.open(savePath);
        if (result.type != ResultType.done) {
           print("Gagal auto-open: ${result.message}");
        } 

      } else {
        throw Exception("Gagal download. Server: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ▼▼▼ 2. MENU PILIHAN DOWNLOAD (POPUP) ▼▼▼
  void showDownloadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const Text("Export Data Laporan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              
              // Opsi 1: Semua Data
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(Icons.all_inbox, color: Colors.blue),
                ),
                title: const Text("Download Semua Data"),
                subtitle: const Text("Semua riwayat laporan"),
                onTap: () {
                  Navigator.pop(context);
                  downloadExcel(); // Tanpa parameter = Semua
                },
              ),
              const Divider(),
              
              // Opsi 2: Pilih Tanggal
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  child: const Icon(Icons.date_range, color: Colors.orange),
                ),
                title: const Text("Pilih Rentang Tanggal"),
                subtitle: const Text("Filter data spesifik"),
                onTap: () async {
                  Navigator.pop(context);
                  
                  // Tampilkan Date Range Picker
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2024), // Atur tahun awal
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF2E3A85),
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    }
                  );

                  if (picked != null) {
                    downloadExcel(start: picked.start, end: picked.end);
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: const Color(0xFF2E3A85),
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          backgroundColor: const Color(0xFF2E3A85),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            // ▼▼▼ TOMBOL EXPORT DATA ▼▼▼
            IconButton(
              onPressed: () {
                showDownloadOptions(); // Panggil Popup Menu
              },
              icon: const Icon(Icons.file_download),
              tooltip: 'Export Excel',
            ),
            
            // Tombol Logout
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
                        child: const Text('Logout', style: TextStyle(color: Colors.red)),
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
            )
          ],
        ),
        
        // Body (List User)
        body: BlocConsumer<AdminCubit, AdminState>(
          listener: (context, state) {
            if (state is AdminFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(state.error),
                ),
              );
              if (state.error.contains("Token") || state.error.contains("Sesi")) {
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
        
        // FAB Tambah User
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
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // Widget untuk menampilkan list user (Sama seperti sebelumnya)
  Widget _buildBody(BuildContext context, AdminState state) {
    if (state is AdminLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (state is AdminFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.white70),
              const SizedBox(height: 16),
              Text('Oops! Terjadi kesalahan', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
              const SizedBox(height: 10),
              Text(state.error, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.read<AdminCubit>().fetchUsers(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF2E3A85)),
                child: const Text('Coba Lagi'),
              )
            ],
          ),
        ),
      );
    }

    if (state is AdminSuccess) {
      final users = state.filteredUsers;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Cari user...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            Text("Daftar User (${users.length})", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Expanded(
              child: users.isEmpty
                  ? Center(child: Text(_searchController.text.isEmpty ? 'Belum ada data user.' : 'User tidak ditemukan.', style: const TextStyle(fontSize: 16, color: Colors.white70)))
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 0,
                          color: Colors.white.withOpacity(0.9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.transparent,
                              child: ClipOval(
                                child: Image.asset('assets/user.png', width: 40, height: 40, fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 30, color: Color(0xFF2E3A85)),
                                ),
                              ),
                            ),
                            title: Text(user['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                            subtitle: Text(user['role'] ?? '', style: TextStyle(color: Colors.grey[700])),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  color: Colors.blue.shade700,
                                  onPressed: () async {
                                    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => UpdateUserPage(user: user)));
                                    if (result == true) context.read<AdminCubit>().fetchUsers();
                                  },
                                ),
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
                                          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Batal")),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(ctx).pop();
                                              final userId = user['id'];
                                              if (userId != null) context.read<AdminCubit>().deleteUser(userId);
                                            },
                                            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
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

    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }
}