// import 'dart:convert';
// import 'dart:io';
// import 'package.flutter/foundation.dart';
// import 'package.flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// // Impor file state dan model dari folder 'admin'
// import 'admin_state.dart';
// import '../models/user_model.dart';

// // --- HELPER KITA TARUH DI SINI ---
// String _getBaseUrl() {
//   if (kIsWeb) return "http://127.0.0.1:8000";
//   if (Platform.isAndroid) return "http://10.0.2.2:8000";
//   return "http://127.0.0.1:8000";
// }

// Future<Map<String, String>> _getAuthHeaders() async {
//   final prefs = await SharedPreferences.getInstance();
//   // Pastikan key-nya 'auth_token'
//   final token = prefs.getString('auth_token');

//   if (token == null) {
//     throw Exception('Token tidak ditemukan. Silakan login ulang.');
//   }

//   return {
//     'Authorization': 'Bearer $token',
//     'Accept': 'application/json',
//   };
// }
// // --- AKHIR DARI HELPER ---


// class AdminCubit extends Cubit<AdminState> {
//   // Saat Cubit dibuat, langsung mulai di state Initial
//   AdminCubit() : super(AdminInitial()) {
//     // Dan langsung panggil fungsi untuk memuat data
//     fetchUsers();
//   }

//   // --- FUNGSI UNTUK MEMUAT DATA DARI API ---
//   Future<void> fetchUsers() async {
//     // 1. Emit state Loading (UI akan menampilkan putar-putar)
//     emit(AdminLoading());

//     try {
//       // 2. Ambil URL dan Header dari Helper
//       final url = Uri.parse('${_getBaseUrl()}/api/users');
//       final headers = await _getAuthHeaders();

//       // 3. Panggil API
//       final response = await http.get(url, headers: headers);

//       // 4. Proses Respons
//       if (response.statusCode == 200) {
//         final List<dynamic> responseData = json.decode(response.body)['data'];
//         final List<User> users =
//             responseData.map((json) => User.fromJson(json)).toList();

//         // 5. Emit state Sukses dengan data user
//         emit(AdminSuccess(
//           allUsers: users,
//           filteredUsers: users, // Awalnya, daftar filter = semua user
//         ));
//       } else {
//         // Handle error server (termasuk 401/403)
//         final data = json.decode(response.body);
//         final message = data['message'] ?? 'Gagal memuat data.';
//         emit(AdminFailure('$message (Status: ${response.statusCode})'));
//       }
//     } catch (e) {
//       // Handle error koneksi atau token tidak ditemukan
//       emit(AdminFailure(e.toString()));
//     }
//   }

//   // --- FUNGSI UNTUK MELAKUKAN PENCARIAN ---
//   void filterUsers(String query) {
//     // Kita hanya bisa filter jika state-nya Sukses (sudah ada data)
//     final currentState = state;
//     if (currentState is AdminSuccess) {
//       final allUsers = currentState.allUsers;

//       if (query.isEmpty) {
//         // Jika query kosong, tampilkan semua user
//         emit(currentState.copyWith(filteredUsers: allUsers));
//       } else {
//         // Jika ada query, filter dari daftar 'allUsers'
//         final filteredList = allUsers.where((user) {
//           return user.name.toLowerCase().contains(query.toLowerCase());
//         }).toList();

//         // Emit state baru dengan daftar 'filteredUsers' yang sudah diupdate
//         emit(currentState.copyWith(filteredUsers: filteredList));
//       }
//     }
//   }
// } 