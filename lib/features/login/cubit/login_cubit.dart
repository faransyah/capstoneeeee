// lib/features/login/cubit/login_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // Tetap impor untuk cek Android
import 'package:flutter/foundation.dart'; // Impor ini untuk kIsWeb

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

 String getBaseUrl() {
  if (kIsWeb) {
    // 1. Jika ini adalah build WEB (Chrome, Edge, dll.)
    // Gunakan localhost/127.0.0.1
    // (Ini akan terhubung ke API di laptop Anda)
    return "http://127.0.0.1:8000"; 
  } else if (Platform.isAndroid) {
    // 2. Jika ini adalah build NATIVE Android
    // Gunakan IP khusus emulator
    return "http://10.0.2.2:8000";
  } else {
    // 3. Jika ini adalah build NATIVE lainnya (iOS, Windows, dll.)
    // Gunakan localhost
    return "http://127.0.0.1:8000";
  }
}

  // Ingat, kita "akali" jadi /api/login walau field-nya email
  String get _apiUrl => "${getBaseUrl()}/api/login";

  Future<void> login(String username, String password) async {
    emit(LoginLoading());

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          // Kita kirim 'email' walau field di UI namanya 'username'
          'email': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        
        final data = jsonDecode(response.body);
        final String token = data['access_token'];

        // ▼▼▼ INI PERBAIKANNYA ▼▼▼
        
        // 1. Ambil 'role' dari objek 'user'
        final String role = data['user']['role'];

        // 2. Simpan token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // 3. Kirim state Success LENGKAP DENGAN ROLE-nya
        emit(LoginSuccess(role)); // <-- Ini perbaikannya

        // ▲▲▲ SAMPAI SINI ▲▲▲

      } else if (response.statusCode == 401 || response.statusCode == 400 || response.statusCode == 422) {
        final data = jsonDecode(response.body);
        String errorMessage = "Terjadi kesalahan";
        if (data['message'] != null) {
          errorMessage = data['message'];
        } else if (data['errors'] != null && data['errors'] is Map) {
          errorMessage = data['errors'].values.first[0];
        }
        emit(LoginFailure(errorMessage));
      } else {
        emit(LoginFailure('Error Server: ${response.statusCode}'));
      }
    } catch (e) {
      emit(LoginFailure("Tidak dapat terhubung. Periksa koneksi internet Anda."));
    }
  }
}