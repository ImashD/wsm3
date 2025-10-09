// lib/drawer/products.dart

import 'package:flutter/material.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  final List<Map<String, String>> paddies = const [
    {
      "name": "Keeri Samba",
      "price": "150",
      "area": "Mostly in Eastern & Northern provinces",
      "tips":
          "Short grain, aromatic rice. Requires careful water management and organic fertilizers.",
      "popularity": "Grown by 60% of farmers in selected regions",
      "image": "assets/keeri_samba.png",
    },
    {
      "name": "Naadu (Red)",
      "price": "100",
      "area": "Southern dry zones",
      "tips":
          "Red rice variety, good for health. Needs well-drained soil and minimal fertilizer.",
      "popularity": "Grown by 30% of farmers in dry zones",
      "image": "assets/red_naadu.png",
    },
    {
      "name": "Naadu (White)",
      "price": "120",
      "area": "Wet zone and mid-country",
      "tips":
          "White rice, easy to cook. Thrives in waterlogged fields and moderate fertilizer use.",
      "popularity": "Grown by 25% of farmers in wet zones",
      "image": "assets/white_naadu.png",
    },
    {
      "name": "Samba",
      "price": "180",
      "area": "Eastern & Northern provinces",
      "tips":
          "Popular long grain aromatic rice. Needs high water, nutrient-rich soil, and careful pest control.",
      "popularity": "Grown by 40% of farmers in selected regions",
      "image": "assets/samba.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Product List",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009688),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: paddies.length,
        itemBuilder: (context, index) {
          final paddy = paddies[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image + Price stacked vertically
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          paddy["image"]!,
                          width: 80,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              size: 16,
                              color: Colors.teal,
                            ),
                            const SizedBox(width: 4),
                            Text("Rs. ${paddy["price"]}/kg"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Other details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paddy["name"]!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Area
                        Row(
                          children: [
                            const Icon(
                              Icons.landscape,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Expanded(child: Text(paddy["area"]!)),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Tips
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.teal[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                size: 16,
                                color: Colors.teal,
                              ),
                              const SizedBox(width: 4),
                              Expanded(child: Text(paddy["tips"]!)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Popularity
                        Row(
                          children: [
                            const Icon(
                              Icons.people,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Expanded(child: Text(paddy["popularity"]!)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
