// part of 'user_cubit.dart';

// // Model sederhana untuk data user, bisa Anda kembangkan nanti
// class UserData {
//   final int id;
//   final String name;
//   final String email;
//   final String role;

//   UserData({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.role,
//   });

//   // Factory constructor untuk membuat instance dari JSON
//   factory UserData.fromJson(Map<String, dynamic> json) {
//     return UserData(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//       role: json['role'],
//     );
//   }
// }

// @immutable
// abstract class UserState {}

// // State awal, belum ada data
// class UserInitial extends UserState {}

// // State saat sedang mengambil data
// class UserLoading extends UserState {}

// // State jika berhasil mengambil data
// class UserSuccess extends UserState {
//   final UserData user;
//   UserSuccess(this.user);
// }

// // State jika gagal mengambil data
// class UserFailure extends UserState {
//   final String error;
//   UserFailure(this.error);
// }