import 'package:flutter/material.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  final List<Map<String, String>> promotions = const [
    {
      "title": "Subsidy on Fertilizer",
      "description":
          "Farmers receive 20% discount on fertilizer purchases under government scheme.",
      "validity": "Valid until: 31-Dec-2025",
    },
    {
      "title": "Bonus for Wet Paddy Sales",
      "description":
          "Extra Rs. 5 per kg for wet paddy sold to certified mills.",
      "validity": "Valid for 2025 season",
    },
    {
      "title": "Seed Distribution Program",
      "description":
          "Free high-quality seeds distributed to farmers registered in the cooperative.",
      "validity": "Available: Jan - Mar 2025",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Promotions", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF009688),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              // Note about promotions (centered)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    "Note: These promotions are provided by the government and may vary seasonally.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Promotion cards
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: promotions.length,
                itemBuilder: (context, index) {
                  final promo = promotions[index];
                  final isEven = index % 2 == 0;
                  final gradientColors = isEven
                      ? [Colors.teal.shade50, Colors.teal.shade100]
                      : [Colors.orange.shade50, Colors.orange.shade100];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: isEven ? Alignment.topLeft : Alignment.topRight,
                        end: isEven
                            ? Alignment.bottomRight
                            : Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isEven
                                  ? Colors.teal[200]
                                  : Colors.orange[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isEven ? Icons.campaign : Icons.local_florist,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  promo["title"]!,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isEven
                                        ? Colors.teal[900]
                                        : Colors.orange[900],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  promo["description"]!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  promo["validity"]!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                  ),
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
