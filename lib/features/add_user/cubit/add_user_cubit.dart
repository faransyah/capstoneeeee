// lib/features/add_user/cubit/add_user_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_user_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class AddUserCubit extends Cubit<AddUserState> {
  AddUserCubit() : super(AddUserInitial());

  // === Mengambil Base URL (sama seperti LoginCubit) ===
  String _getBaseUrl() {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    } else {
      return "http://127.0.0.1:8000";
    }
  }
  // Kita pakai endpoint 'register'
  String get _apiUrl => "${_getBaseUrl()}/api/register";
  // ======================================================

  // ▼▼▼ FUNGSI INI SUDAH SAYA UBAH ▼▼▼
  Future<void> createUser({
    required String name,
    // required String username, <-- SUDAH DIHAPUS
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    // 1. Set state jadi Loading
    emit(AddUserLoading());

    try {
      // 2. Ambil token Admin dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null) {
        emit(AddUserFailure("Token admin tidak ditemukan. Silakan login ulang."));
        return;
      }

      // 3. Kirim data ke API (DENGAN TOKEN)
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // <-- INI KUNCI KEAMANANNYA
        },
        body: jsonEncode({
          'name': name,
          // 'username': username, <-- SUDAH DIHAPUS
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );
      // ▲▲▲ SAMPAI SINI UBAHANNYA ▲▲▲

      // 4. Proses respons
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) { // 201 = Created
        emit(AddUserSuccess("User baru berhasil dibuat!"));
      } else if (response.statusCode == 422) {
        // Error validasi
        emit(AddUserFailure(data['errors'].values.first[0]));
      } else {
        emit(AddUserFailure(data['message'] ?? 'Terjadi kesalahan server'));
      }

    } catch (e) {
      emit(AddUserFailure("Tidak dapat terhubung ke server: ${e.toString()}"));
    }
  }
}