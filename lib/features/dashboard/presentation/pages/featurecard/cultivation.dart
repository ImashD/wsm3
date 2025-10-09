import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CultivationScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;

  const CultivationScreen({super.key, required this.products});

  @override
  State<CultivationScreen> createState() => _CultivationScreenState();
}

class _CultivationScreenState extends State<CultivationScreen> {
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _selectedProduct;
  List<File> _fieldImages = [];

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.products.firstWhere(
      (prod) => prod['status'] == 'Growing' || prod['status'] == 'Available',
      orElse: () => {},
    );
  }

  Future<void> _addFieldImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _fieldImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  Widget _infoCard(IconData icon, String label, String value, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.teal),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedProduct == null || _selectedProduct!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Cultivation Info"),
          backgroundColor: const Color(0xFF1DD1A1),
        ),
        body: const Center(child: Text("No ongoing cultivation found.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cultivation Info",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009688),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.teal.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Info Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Paddy Type: ${_selectedProduct!['name']}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Highlighted Next Harvest
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Next Expected Harvest: ${_selectedProduct!['harvestDate']}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info Cards Row
                      Row(
                        children: [
                          _infoCard(
                            Icons.terrain,
                            "Area",
                            "${_selectedProduct!['area']}",
                          ),
                          _infoCard(
                            Icons.line_weight,
                            "Quantity",
                            "${_selectedProduct!['quantity']} kg",
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _infoCard(
                            Icons.info,
                            "Status",
                            _selectedProduct!['status'],
                          ),
                          _infoCard(
                            Icons.calendar_today,
                            "Harvest Date",
                            "${_selectedProduct!['harvestDate']}",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cultivation Images Section
              Text(
                "Cultivation Process Images:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
              const SizedBox(height: 8),
              _fieldImages.isEmpty
                  ? const Center(
                      child: Text(
                        "No images added yet",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _fieldImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _fieldImages[index],
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 16),

              // Add/Update Images Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _addFieldImages,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text("Add/Update Images"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DD1A1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
