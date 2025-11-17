import 'package:flutter/foundation.dart';

@immutable
sealed class AdminState {
  const AdminState();
}

final class AdminInitial extends AdminState {}

final class AdminLoading extends AdminState {}

final class AdminFailure extends AdminState {
  final String error;
  const AdminFailure(this.error);
}

final class AdminSuccess extends AdminState {
  final List<Map<String, dynamic>> allUsers;
  final List<Map<String, dynamic>> filteredUsers;

  const AdminSuccess({
    required this.allUsers,
    required this.filteredUsers,
  });

  AdminSuccess copyWith({
    List<Map<String, dynamic>>? allUsers,
    List<Map<String, dynamic>>? filteredUsers,
  }) {
    return AdminSuccess(
      allUsers: allUsers ?? this.allUsers,
      filteredUsers: filteredUsers ?? this.filteredUsers,
    );
  }
}
