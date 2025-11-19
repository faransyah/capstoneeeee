import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

part 'update_user_state.dart';

class UpdateUserCubit extends Cubit<UpdateUserState> {
  UpdateUserCubit() : super(UpdateUserInitial());

  String getBaseUrl() {
    if (kIsWeb) return "http://127.0.0.1:8000";
    if (Platform.isAndroid) return "http://10.0.2.2:8000";
    return "http://127.0.0.1:8000";
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    emit(UpdateUserLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        emit(UpdateUserFailure("Token hilang. Silakan login ulang."));
        return;
      }

      final response = await http.put(
        Uri.parse('${getBaseUrl()}/api/users/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        emit(UpdateUserSuccess("User berhasil diperbarui!"));
      } else {
        final body = jsonDecode(response.body);
        final msg = body['message'] ?? "Gagal update. Kode: ${response.statusCode}";
        // Jika ada error validasi spesifik
        if (body['errors'] != null) {
           // Ambil error pertama saja biar simpel
           final errors = body['errors'] as Map;
           final firstError = errors.values.first[0];
           emit(UpdateUserFailure(firstError));
        } else {
           emit(UpdateUserFailure(msg));
        }
      }
    } catch (e) {
      emit(UpdateUserFailure("Error koneksi: ${e.toString()}"));
    }
  }
}