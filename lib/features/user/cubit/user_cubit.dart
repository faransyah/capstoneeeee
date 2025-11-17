// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:meta/meta.dart';

// // 1. --- PENTING: GANTI DENGAN PATH LOGIN CUBIT ANDA ---
// import 'package:capstone_flutter/features/login/views/login_page.dart';

// part 'user_state.dart';

// class UserCubit extends Cubit<UserState> {
//   // 2. --- Kita "menyuntikkan" LoginCubit ---
//   final LoginCubit _loginCubit;

//   UserCubit(this._loginCubit) : super(UserInitial());

//   // Fungsi helper untuk Base URL (sama seperti di LoginCubit)
//   String getBaseUrl() {
//     if (kIsWeb) {
//       return "http://127.0.0.1:8000";
//     } else if (Platform.isAndroid) {
//       return "http://10.0.2.2:8000";
//     } else {
//       return "http://127.0.0.1:8000";
//     }
//   }

//   // Fungsi untuk mengambil data user yang sedang login
//   Future<void> fetchUserDetails() async {
//     emit(UserLoading());
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? token = prefs.getString('auth_token');

//       if (token == null) {
//         // Jika tidak ada token, paksa logout
//         _loginCubit.logout();
//         return;
//       }

//       final response = await http.get(
//         Uri.parse("${getBaseUrl()}/api/user"), // Backend Anda punya rute ini
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $token', // Kirim token
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final user = UserData.fromJson(data);
//         emit(UserSuccess(user));
//       } else if (response.statusCode == 401) {
//         // Jika token tidak valid (unauthorized), paksa logout
//         _loginCubit.logout();
//       } else {
//         emit(UserFailure(
//             'Gagal mengambil data user: ${response.statusCode}'));
//       }
//     } catch (e) {
//       emit(UserFailure("Tidak dapat terhubung. Periksa koneksi internet Anda."));
//     }
//   }

//   // 3. --- Fungsi logout ---
//   // Perhatikan bahwa dia hanya memanggil fungsi logout milik LoginCubit
//   Future<void> logout() async {
//     // Biarkan LoginCubit yang menangani penghapusan token
//     // dan pengubahan state-nya
//     await _loginCubit.logout();
//   }
// }