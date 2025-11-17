// lib/features/login/cubit/login_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';



part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  String getBaseUrl() {
    if (kIsWeb) {
      return "http://127.0.0.1:8000";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    } else {
      return "http://127.0.0.1:8000";
    }
  }

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
          'email': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['access_token'];
        final String role = data['user']['role'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        emit(LoginSuccess(role));
      } else if (response.statusCode == 401 ||
          response.statusCode == 400 ||
          response.statusCode == 422) {
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
      emit(LoginFailure(
          "Tidak dapat terhubung. Periksa koneksi internet Anda."));
    }
  }

  // Fungsi logout yang terpusat
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    emit(LoginInitial());
  }
}