// lib/features/admin/views/admin_page.dart

import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'; 
import 'package:open_file/open_file.dart';        
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart'; // Pastikan import ini ada

// Import halaman lain
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
  
  // Warna Utama Hijau Modern
  final Color primaryColor = const Color(0xFF0C9869);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
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

  // --- LOGIKA DOWNLOAD EXCEL (TETAP SAMA) ---
  Future<void> downloadExcel({DateTime? start, DateTime? end}) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
          const SizedBox(width: 15), 
          Text("Mengunduh Laporan Excel...", style: GoogleFonts.openSans()),
        ]),
        duration: const Duration(seconds: 2), backgroundColor: const Color(0xFF0C9869),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      // Ganti IP sesuai environment
      final String baseUrl = "http://10.0.2.2:8000"; 
      String urlString = '$baseUrl/api/reports/export/excel';

      if (start != null && end != null) {
        final startStr = "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
        final endStr = "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";
        urlString += "?start_date=$startStr&end_date=$endStr";
      }

      final response = await http.get(Uri.parse(urlString), headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        Directory? directory;
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) directory = await getExternalStorageDirectory();
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        final fileName = 'Laporan_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final savePath = '${directory?.path ?? "/storage/emulated/0/Download"}/$fileName';
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Disimpan di: Download/$fileName", style: GoogleFonts.openSans()), 
              backgroundColor: Colors.green
            )
          );
        }
        await OpenFile.open(savePath);
      } else {
        throw Exception("Gagal download: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e", style: GoogleFonts.openSans()), backgroundColor: Colors.red));
      }
    }
  }

  // --- POPUP DOWNLOAD (TAMPILAN DIPERBARUI FONTNYA) ---
  void showDownloadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              Text("Export Laporan", style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              ListTile(
                leading: CircleAvatar(backgroundColor: primaryColor.withOpacity(0.1), child: Icon(Icons.all_inbox, color: primaryColor)),
                title: Text("Download Semua Data", style: GoogleFonts.openSans()),
                onTap: () { Navigator.pop(context); downloadExcel(); },
              ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(backgroundColor: Colors.orange.withOpacity(0.1), child: const Icon(Icons.date_range, color: Colors.orange)),
                title: Text("Pilih Rentang Tanggal", style: GoogleFonts.openSans()),
                onTap: () async {
                  Navigator.pop(context);
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context, firstDate: DateTime(2024), lastDate: DateTime.now(),
                    builder: (context, child) => Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.light(primary: primaryColor, onPrimary: Colors.white, onSurface: Colors.black),
                        textTheme: GoogleFonts.openSansTextTheme(), // Apply font to date picker
                      ),
                      child: child!,
                    )
                  );
                  if (picked != null) downloadExcel(start: picked.start, end: picked.end);
                },
              ),
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
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6), // Abu-abu muda modern
        body: Column(
          children: [
            // ▼▼▼ HEADER MODERN ▼▼▼
            _buildModernHeader(),

            // ▼▼▼ BODY UTAMA ▼▼▼
            Expanded(
              child: BlocConsumer<AdminCubit, AdminState>(
                listener: (context, state) {
                  if (state is AdminFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(state.error, style: GoogleFonts.openSans())));
                    if (state.error.contains("Token")) context.read<LoginCubit>().logout();
                  }
                },
                builder: (context, state) {
                  return RefreshIndicator(
                    color: primaryColor,
                    onRefresh: () => context.read<AdminCubit>().fetchUsers(),
                    child: _buildUserList(state),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddUserPage()));
            if (result == true) context.read<AdminCubit>().fetchUsers();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // HEADER CUSTOM
  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 30),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Admin Dashboard", style: GoogleFonts.openSans(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(onPressed: showDownloadOptions, icon: const Icon(Icons.file_download, color: Colors.white)),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Konfirmasi Logout', style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
                          content: Text('Yakin ingin keluar?', style: GoogleFonts.openSans()),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.openSans())),
                            TextButton(onPressed: () { Navigator.pop(ctx); context.read<LoginCubit>().logout(); }, child: Text('Logout', style: GoogleFonts.openSans(color: Colors.red))),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          // SEARCH BAR
          TextField(
            controller: _searchController,
            style: GoogleFonts.openSans(color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Cari user...',
              hintStyle: GoogleFonts.openSans(color: Colors.grey[500]),
              prefixIcon: Icon(Icons.search, color: primaryColor),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            ),
          ),
        ],
      ),
    );
  }

  // LIST USER MODERN
  Widget _buildUserList(AdminState state) {
    if (state is AdminLoading) return Center(child: CircularProgressIndicator(color: primaryColor));
    
    if (state is AdminFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(state.error, style: GoogleFonts.openSans(color: Colors.grey[600])),
            TextButton(
              onPressed: () => context.read<AdminCubit>().fetchUsers(), 
              child: Text('Coba Lagi', style: GoogleFonts.openSans(color: primaryColor))
            )
          ],
        ),
      );
    }

    if (state is AdminSuccess) {
      final users = state.filteredUsers;
      if (users.isEmpty) {
        return Center(child: Text(_searchController.text.isEmpty ? 'Belum ada data.' : 'User tidak ditemukan.', style: GoogleFonts.openSans(color: Colors.grey[500])));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryColor.withOpacity(0.5), width: 2)),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[100],
                  child: Image.asset('assets/user.png', width: 35, errorBuilder: (ctx, err, st) => Icon(Icons.person, color: primaryColor)),
                ),
              ),
              // Gunakan Font Open Sans disini
              title: Text(user['name'] ?? '', style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text(user['role'] ?? '', style: GoogleFonts.openSans(color: Colors.grey[500], fontSize: 13)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tombol Edit
                  _actionButton(Icons.edit, Colors.blue[50]!, Colors.blue, () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => UpdateUserPage(user: user)));
                    if (result == true) context.read<AdminCubit>().fetchUsers();
                  }),
                  const SizedBox(width: 8),
                  // Tombol Hapus
                  _actionButton(Icons.delete_outline, Colors.red[50]!, Colors.red, () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text("Hapus User", style: GoogleFonts.openSans(fontWeight: FontWeight.bold)), 
                        content: Text("Hapus '${user['name']}'?", style: GoogleFonts.openSans()),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Batal", style: GoogleFonts.openSans())),
                          TextButton(
                            onPressed: () { Navigator.pop(ctx); if (user['id'] != null) context.read<AdminCubit>().deleteUser(user['id']); },
                            child: Text("Hapus", style: GoogleFonts.openSans(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      );
    }
    return Center(child: CircularProgressIndicator(color: primaryColor));
  }

  Widget _actionButton(IconData icon, Color bg, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}