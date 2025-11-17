// login_state.dart


part of 'login_cubit.dart';
// Menggunakan 'sealed class' (fitur baru Dart) agar lebih aman
@immutable
sealed class LoginState {}

// Kondisi awal, saat halaman baru dibuka
final class LoginInitial extends LoginState {}

// Kondisi saat tombol login ditekan dan sedang menunggu respons API
final class LoginLoading extends LoginState {}

// Kondisi jika login berhasil
// Kondisi jika login berhasil, sekarang membawa data 'role'
final class LoginSuccess extends LoginState {
  final String role;
  LoginSuccess(this.role);
}

// Kondisi jika login gagal (misal, password salah)
final class LoginFailure extends LoginState {
  final String error;
  LoginFailure(this.error);
}