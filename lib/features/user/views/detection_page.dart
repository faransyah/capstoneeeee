import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// ▼▼▼ PERBAIKAN IMPORT SESUAI STRUKTUR FOLDER KAMU ▼▼▼
import 'package:capstone_flutter/features/scan/cubit/scan_cubit.dart';
import 'package:capstone_flutter/features/report/cubit/report_cubit.dart'; 
// ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

class DetectionPage extends StatelessWidget {
  final int level;

  const DetectionPage({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ScanCubit()),
        BlocProvider(create: (context) => ReportCubit()),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text("Deteksi Level $level"),
          backgroundColor: const Color(0xFF2E3A85),
          foregroundColor: Colors.white,
        ),
        body: DetectionBody(level: level),
      ),
    );
  }
}

class DetectionBody extends StatelessWidget {
  final int level;
  const DetectionBody({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportCubit, ReportState>(
      listener: (context, state) {
        if (state is ReportLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Mengirim data..."), duration: Duration(seconds: 1)),
          );
        } else if (state is ReportSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sukses! Laporan tersimpan."), backgroundColor: Colors.green),
          );
          context.read<ScanCubit>().reset();
        } else if (state is ReportFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<ScanCubit, ScanState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Preview Foto
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildPreview(state),
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol Kamera
                if (state is! ScanSuccess && state is! ScanLoading)
                  ElevatedButton.icon(
                    onPressed: () => context.read<ScanCubit>().pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("AMBIL FOTO"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E3A85),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),

                // Hasil & Tombol Submit
                if (state is ScanSuccess) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: state.isCompliant ? Colors.green.shade50 : Colors.red.shade50,
                      border: Border.all(color: state.isCompliant ? Colors.green : Colors.red),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          state.isCompliant ? "PATUH" : "TIDAK PATUH",
                          style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold,
                            color: state.isCompliant ? Colors.green : Colors.red,
                          ),
                        ),
                        if (!state.isCompliant) ...[
                          const Divider(),
                          const Text("Item Hilang:"),
                          Wrap(
                            spacing: 5,
                            children: state.missingItems.map((e) => Chip(
                              label: Text(e, style: const TextStyle(color: Colors.white)),
                              backgroundColor: Colors.red,
                            )).toList(),
                          )
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Tombol Kirim
                  BlocBuilder<ReportCubit, ReportState>(
                    builder: (context, reportState) {
                      if (reportState is ReportLoading) return const Center(child: CircularProgressIndicator());
                      
                      return ElevatedButton(
                        onPressed: () {
                          context.read<ReportCubit>().submitReport(
                            apdLevel: level,
                            isCompliant: state.isCompliant,
                            missingItems: state.missingItems,
                            imageFile: state.image,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Text("KIRIM LAPORAN", style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                  
                  TextButton(
                    onPressed: () => context.read<ScanCubit>().reset(),
                    child: const Text("Ulangi Scan"),
                  )
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreview(ScanState state) {
    if (state is ScanLoading) return const Center(child: CircularProgressIndicator());
    if (state is ScanSuccess) return Image.file(state.image, fit: BoxFit.cover, width: double.infinity);
    return const Center(child: Text("Belum ada foto"));
  }
}