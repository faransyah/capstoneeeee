import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit() : super(AdminInitial());

  String getBaseUrl() {
    if (kIsWeb) return "http://127.0.0.1:8000";
    if (Platform.isAndroid) return "http://10.0.2.2:8000";
    return "http://127.0.0.1:8000";
  }

  Future<void> fetchUsers() async {
    emit(AdminLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        emit(const AdminFailure("Token tidak ditemukan. Silakan login ulang."));
        return;
      }

      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        final users = data.cast<Map<String, dynamic>>();
        emit(AdminSuccess(allUsers: users, filteredUsers: users));
      } else if (response.statusCode == 401) {
        emit(const AdminFailure("Sesi Anda telah berakhir. Silakan login ulang."));
      } else {
        emit(AdminFailure(
            "Gagal memuat data. Server merespon: ${response.statusCode}"));
      }
    } catch (e) {
      emit(AdminFailure("Terjadi kesalahan: ${e.toString()}"));
    }
  }

  void filterUsers(String query) {
    final current = state;
    if (current is AdminSuccess) {
      final filtered = current.allUsers
          .where((u) => (u['name'] ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
      emit(current.copyWith(filteredUsers: filtered));
    }
  }

  // Pastikan argumen di dalam kurung HANYA (int id)
  Future<void> deleteUser(int id) async {
    try {
      // Ambil token DI SINI, bukan dari parameter
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        emit(const AdminFailure("Token hilang. Silakan login ulang."));
        return;
      }

      final response = await http.delete(
        Uri.parse('${getBaseUrl()}/api/users/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Berhasil, refresh data
        fetchUsers();
      } else {
        emit(AdminFailure("Gagal menghapus user. Kode: ${response.statusCode}"));
        // Refresh agar list tetap muncul jika gagal
        fetchUsers();
      }
    } catch (e) {
      emit(AdminFailure("Error koneksi saat menghapus: $e"));
    }
  }
}
