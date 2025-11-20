import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io'; // Wajib untuk File
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
    required File imageFile, // <--- TAMBAHAN WAJIB: Parameter File Foto
  }) async {
    emit(ReportLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        emit(ReportFailure("Token hilang. Silakan login ulang."));
        return;
      }

      final uri = Uri.parse('${getBaseUrl()}/api/reports');
      
      // ▼▼▼ PERUBAHAN PENTING: Pake MultipartRequest ▼▼▼
      var request = http.MultipartRequest('POST', uri);
      
      // 1. Header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json', 
        // Jangan set Content-Type manual, biarkan Multipart yg atur boundary-nya
      });

      // 2. Data Teks (Fields)
      // Multipart cuma terima String, jadi semua data harus di-convert ke String
      request.fields['apd_level'] = apdLevel.toString();
      request.fields['is_compliant'] = isCompliant ? '1' : '0'; // "true" / "false"
      
      // Array/List harus di-encode jadi JSON String biar bisa dikirim
      request.fields['missing_items'] = jsonEncode(missingItems); 

      // 3. Data File (Upload Gambar)
      // 'image' adalah nama key yang akan dibaca oleh Laravel ($request->file('image'))
      request.files.add(await http.MultipartFile.fromPath(
        'image', 
        imageFile.path
      ));

      // 4. Kirim Request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // 5. Cek Hasil
      if (response.statusCode == 201 || response.statusCode == 200) {
        emit(ReportSuccess("Laporan berhasil disimpan!"));
      } else {
        final msg = jsonDecode(response.body)['message'] ?? "Gagal kirim data: ${response.statusCode}";
        emit(ReportFailure(msg));
      }
    } catch (e) {
      emit(ReportFailure("Error koneksi: $e"));
    }
  }
} 