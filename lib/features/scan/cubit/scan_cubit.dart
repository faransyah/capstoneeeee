import 'dart:io';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// --- STATE ---
abstract class ScanState {}
class ScanInitial extends ScanState {}
class ScanLoading extends ScanState {}

class ScanSuccess extends ScanState {
  final File image;
  final bool isCompliant;
  final List<String> missingItems;

  ScanSuccess(this.image, this.isCompliant, this.missingItems);
}

class ScanFailure extends ScanState {
  final String error;
  ScanFailure(this.error);
}

// --- CUBIT ---
class ScanCubit extends Cubit<ScanState> {
  ScanCubit() : super(ScanInitial());

  final ImagePicker _picker = ImagePicker();

  // Data Item Mocking
  final List<String> _apdItems = [
    'Masker Medis', 'Sarung Tangan', 'Hazmat Suit', 
    'Penutup Kepala', 'Sepatu Boots', 'Face Shield'
  ];

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50, 
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        emit(ScanLoading());

        // 1. Simulasi Loading
        await Future.delayed(const Duration(seconds: 2));

        // 2. Mocking Logic (Random)
        final random = Random();
        bool isCompliant = random.nextDouble() > 0.3; // 70% Patuh
        List<String> missingItems = [];

        if (!isCompliant) {
          int count = random.nextInt(2) + 1;
          Set<String> tempItems = {};
          while(tempItems.length < count) {
            tempItems.add(_apdItems[random.nextInt(_apdItems.length)]);
          }
          missingItems = tempItems.toList();
        }

        emit(ScanSuccess(imageFile, isCompliant, missingItems));
      }
    } catch (e) {
      emit(ScanFailure("Gagal mengambil gambar: $e"));
    }
  }

  void reset() {
    emit(ScanInitial());
  }
}