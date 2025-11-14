// import 'package:flutter/foundation.dart';
// import '../models/user_model.dart'; // Impor model dari folder models

// @immutable
// sealed class AdminState {
//   const AdminState();
// }

// // 1. Kondisi Awal / Kosong
// final class AdminInitial extends AdminState {}

// // 2. Kondisi Sedang Memuat Data dari API
// final class AdminLoading extends AdminState {}

// // 3. Kondisi Gagal Memuat Data
// final class AdminFailure extends AdminState {
//   final String error;
//   const AdminFailure(this.error);
// }

// // 4. Kondisi Sukses Memuat Data
// final class AdminSuccess extends AdminState {
//   final List<User> allUsers;      // Daftar asli dari API
//   final List<User> filteredUsers; // Daftar yang ditampilkan (setelah filter)

//   const AdminSuccess({
//     required this.allUsers,
//     required this.filteredUsers,
//   });

//   // Fungsi helper 'copyWith' agar mudah update state saat mencari
//   AdminSuccess copyWith({
//     List<User>? allUsers,
//     List<User>? filteredUsers,
//   }) {
//     return AdminSuccess(
//       allUsers: allUsers ?? this.allUsers,
//       filteredUsers: filteredUsers ?? this.filteredUsers,
//     );
//   }
// }