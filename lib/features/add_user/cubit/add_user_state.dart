// lib/features/add_user/cubit/add_user_state.dart

import 'package:flutter/foundation.dart';

@immutable
sealed class AddUserState {}

final class AddUserInitial extends AddUserState {}

final class AddUserLoading extends AddUserState {}

// State jika sukses, bawa pesan suksesnya
final class AddUserSuccess extends AddUserState {
  final String message;
  AddUserSuccess(this.message);
}

// State jika gagal, bawa pesan errornya
final class AddUserFailure extends AddUserState {
  final String error;
  AddUserFailure(this.error);
}