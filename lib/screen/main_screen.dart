import 'package:flutter/material.dart';
import 'package:schedule_generator/screen/home/home_screen.dart';
import 'package:schedule_generator/screen/service/service_page.dart'; // Ganti dengan layar service untuk budget atau resep makanan

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _indexPage = 0; // Menyimpan index halaman yang sedang aktif
  final PageController _pageController = PageController(); // Controller untuk PageView

  // Fungsi untuk menangani perubahan tab
  void _onItemTapped(int index) {
    setState(() {
      _indexPage = index; // Mengubah index halaman aktif
      _pageController.animateToPage(index, // Menavigasi ke halaman yang sesuai
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController, // Controller PageView
        physics: const NeverScrollableScrollPhysics(), // Memastikan pengguna tidak bisa menggeser halaman
        children: [
          HomeScreen(), // Layar utama aplikasi makanan sehat
          ServiceScreen(), // Layar untuk layanan terkait budget atau resep makanan
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexPage, // Menampilkan tab yang sedang aktif
        onTap: _onItemTapped, // Fungsi ketika tab dipilih
        backgroundColor: Colors.green[800], // Warna latar belakang BottomNavigationBar
        selectedItemColor: Colors.lightGreenAccent, // Warna untuk item yang dipilih
        unselectedItemColor: Colors.white70, // Warna untuk item yang tidak dipilih
        showUnselectedLabels: true, // Menampilkan label item yang tidak dipilih
        type: BottomNavigationBarType.fixed, // Tipe BottomNavigationBar agar item tidak bergerak
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu), // Ikon untuk resep sehat
            label: 'History', // Label untuk menu resep sehat
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money), // Ikon untuk budget
            label: 'Budget', // Label untuk menu pengelolaan budget
          ),
        ],
      ),
    );
  }
}
