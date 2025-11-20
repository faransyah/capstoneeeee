import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

part 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  ReportCubit() : super(ReportInitial());

  String getBaseUrl() {
    // Sesuaikan IP (Emulator: 10.0.2.2, HP Fisik: IP Laptop)
    if (kIsWeb) return "http://127.0.0.1:8000";
    if (Platform.isAndroid) return "http://10.0.2.2:8000"; 
    return "http://127.0.0.1:8000";
  }

  Future<void> submitReport({
    required int apdLevel,
    required bool isCompliant,
    required List<String> missingItems,
  }) async {
    emit(ReportLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        emit(ReportFailure("Token hilang. Silakan login ulang."));
        return;
      }

      final url = Uri.parse('${getBaseUrl()}/api/reports');
      
      final body = {
        'apd_level': apdLevel,
        'is_compliant': isCompliant,
        'missing_items': missingItems,
        'image_path': null, // Nanti diisi kalau sudah ada upload foto
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        emit(ReportSuccess("Laporan berhasil disimpan!"));
      } else {
        final msg = jsonDecode(response.body)['message'] ?? "Gagal kirim data";
        emit(ReportFailure(msg));
      }
    } catch (e) {
      emit(ReportFailure("Error koneksi: $e"));
    }
  }
} 