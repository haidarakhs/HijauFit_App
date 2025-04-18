import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:schedule_generator/screen/main_screen.dart'; // Pastikan path ke MainScreen benar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Hive
  await Hive.initFlutter();

  // Membuka box untuk menyimpan data budget makanan
  var box = await Hive.openBox('foodBox');

  // Menjalankan aplikasi dengan DevicePreview jika diaktifkan
  runApp(
    DevicePreview(
      enabled: true, // Setel ke true hanya jika ingin menggunakan DevicePreview
      builder: (context) => const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainScreen(), // Pastikan MainScreen sudah disesuaikan dengan aplikasi makanan sehat
    );
  }
}
