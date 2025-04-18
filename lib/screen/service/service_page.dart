import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:schedule_generator/network/gemini_service.dart';
import 'package:shimmer/shimmer.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  bool _isLoading = false;
  final List<Map<String, dynamic>> _recipes = [];
  final TextEditingController _recipeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? errorMessage;

  late Box _recipeDB;

  List<String> ingredients = [];
  List<String> steps = [];
  String? price;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  void _initializeHive() async {
    await Hive.initFlutter();
    _recipeDB = await Hive.openBox('foodBox');
  }

  void handleSingleAction() async {
    if (_recipeController.text.isEmpty || _priceController.text.isEmpty) return;

    final String enteredPrice = _priceController.text;

    setState(() {
      _recipes.clear();
      _recipes.add({
        'nama_resep': _recipeController.text,
        'ingredients': '',
        'steps': '',
      });
      _isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await GeminiServices.generateRecipe(_recipes);

      if (result == null || result.containsKey('error')) {
        setState(() {
          _isLoading = false;
          ingredients.clear();
          steps.clear();
          price = null;
          errorMessage = result?['error'] ?? 'Gagal menghasilkan resep.';
        });
        return;
      }

      setState(() {
        ingredients = List<String>.from(result['ingredients'] ?? []);
        steps = List<String>.from(result['steps'] ?? []);
        price = enteredPrice; // Menyimpan harga dari input sebelum clear
        _isLoading = false;
      });

      await _recipeDB.put('recipe', {
        'nama_resep': result['nama_resep'],
        'ingredients': result['ingredients'],
        'steps': result['steps'],
        'price': enteredPrice,
      });

      // Kosongkan input setelah berhasil
      _recipeController.clear();
      _priceController.clear();

    } catch (e) {
      setState(() {
        _isLoading = false;
        ingredients.clear();
        steps.clear();
        price = null;
        errorMessage = 'Gagal menghasilkan resep\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text(
          'Makanan Sehat dengan Budget',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        actions: [
          
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _recipeController,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                hintText: 'Nama Resep Makanan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.green[100],
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                hintText: 'Harga Resep',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.green[100],
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : handleSingleAction,
              label: Text(
                _isLoading ? 'Generating...' : 'Generate Recipe',
                style: const TextStyle(color: Colors.white),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.fastfood, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_isLoading && errorMessage != null)
              Card(
                color: Colors.red[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isLoading)
              Column(
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const SizedBox(height: 40, width: 300),
                      ),
                    ),
                  ),
                ),
              ),
            if (!_isLoading && (ingredients.isNotEmpty || steps.isNotEmpty))
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${_recipes[0]['nama_resep']}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.green[200],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bahan",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          ...ingredients.map((item) => Text('- $item')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Langkah Pembuatan',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  ...steps.asMap().entries.map((entry) => Card(
                        color: Colors.green[300],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: Text('${entry.key + 1}'),
                          title: Text(
                            entry.value,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      )),
                  const SizedBox(height: 20),
                  if (price != null && price!.isNotEmpty)
                    Card(
                      color: Colors.green[300],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Harga: $price',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
