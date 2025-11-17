// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/login/cubit/login_cubit.dart';
import 'features/admin/cubit/admin_cubit.dart';
import 'features/login/views/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan MultiBlocProvider agar bisa menyediakan banyak cubit sekaligus
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginCubit()),
        BlocProvider(create: (_) => AdminCubit()), // ✅ AdminCubit tersedia
      ],
      child: MaterialApp(
        title: 'Capstone Flutter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E3A85)),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
