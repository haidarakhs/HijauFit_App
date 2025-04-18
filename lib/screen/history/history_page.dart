import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);



  void deleteHistory(Box box, int index) async {
    await box.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    final Box _foodBox = Hive.box('foodBox');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Makanan Sehat'),
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: _foodBox.listenable(),
          builder: (context, Box box, _) {
            final foods = box.values
                .where((food) => food is Map && food.containsKey('nama_resep'))
                .map<Map<String, dynamic>>((food) {
              final mapFood = Map<String, dynamic>.from(food);
              mapFood['bahan'] = List<String>.from(food['bahan'] ?? []);
              mapFood['langkah'] = List<String>.from(food['langkah'] ?? []);
              return mapFood;
            }).toList();

            if (foods.isEmpty) {
              return const Center(
                child: Text(
                  'Anda belum memiliki riwayat makanan.',
                  style: TextStyle(fontSize: 24, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat Anda',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: foods.length,
                      itemBuilder: (context, index) {
                        final food = foods[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: const Icon(Icons.fastfood, color: Colors.green),
                            title: Text(
                              food['nama_resep'] ?? 'Tanpa Nama',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text('Klik untuk lihat detail'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteHistory(box, index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
