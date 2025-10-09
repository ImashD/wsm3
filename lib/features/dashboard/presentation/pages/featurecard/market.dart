// market.dart

import 'package:flutter/material.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String selectedDistrict = "Colombo";
  String selectedType = "Samba";
  String selectedMoisture = "Dry";

  final List<String> districts = [
    "Colombo",
    "Gampaha",
    "Kalutara",
    "Kandy",
    "Matale",
    "Nuwara Eliya",
    "Galle",
    "Matara",
    "Hambantota",
    "Jaffna",
    "Kilinochchi",
    "Mannar",
    "Vavuniya",
    "Mullaitivu",
    "Batticaloa",
    "Ampara",
    "Trincomalee",
    "Kurunegala",
    "Puttalam",
    "Anuradhapura",
    "Polonnaruwa",
    "Badulla",
    "Monaragala",
    "Ratnapura",
    "Kegalle",
  ];

  final List<String> paddyTypes = [
    "Samba",
    "Naadu (Red)",
    "Naadu (White)",
    "Keeri Samba",
  ];

  final List<Map<String, dynamic>> paddyPrices = [
    {"district": "Colombo", "type": "Samba", "moisture": "Dry", "price": 120},
    {"district": "Colombo", "type": "Samba", "moisture": "Wet", "price": 130},
    {
      "district": "Colombo",
      "type": "Naadu (Red)",
      "moisture": "Dry",
      "price": 110,
    },
    {
      "district": "Colombo",
      "type": "Naadu (Red)",
      "moisture": "Wet",
      "price": 115,
    },
    {
      "district": "Kurunegala",
      "type": "Keeri Samba",
      "moisture": "Dry",
      "price": 135,
    },
    {
      "district": "Kurunegala",
      "type": "Keeri Samba",
      "moisture": "Wet",
      "price": 140,
    },
    {
      "district": "Gampaha",
      "type": "Naadu (White)",
      "moisture": "Dry",
      "price": 105,
    },
    {
      "district": "Gampaha",
      "type": "Naadu (White)",
      "moisture": "Wet",
      "price": 110,
    },
    {
      "district": "Anuradhapura",
      "type": "Samba",
      "moisture": "Dry",
      "price": 125,
    },
    {
      "district": "Anuradhapura",
      "type": "Samba",
      "moisture": "Wet",
      "price": 132,
    },
    {
      "district": "Polonnaruwa",
      "type": "Naadu (Red)",
      "moisture": "Dry",
      "price": 112,
    },
    {
      "district": "Polonnaruwa",
      "type": "Naadu (Red)",
      "moisture": "Wet",
      "price": 118,
    },
    {
      "district": "Badulla",
      "type": "Keeri Samba",
      "moisture": "Dry",
      "price": 138,
    },
    {
      "district": "Badulla",
      "type": "Keeri Samba",
      "moisture": "Wet",
      "price": 145,
    },
    {
      "district": "Matara",
      "type": "Naadu (White)",
      "moisture": "Dry",
      "price": 108,
    },
    {
      "district": "Matara",
      "type": "Naadu (White)",
      "moisture": "Wet",
      "price": 112,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = paddyPrices
        .where(
          (item) =>
              item["district"] == selectedDistrict &&
              item["type"] == selectedType &&
              item["moisture"] == selectedMoisture,
        )
        .toList();

    final others = paddyPrices
        .where(
          (item) =>
              !(item["district"] == selectedDistrict &&
                  item["type"] == selectedType &&
                  item["moisture"] == selectedMoisture),
        )
        .toList();

    final allPrices = paddyPrices.map((e) => e["price"] as int).toList();
    final avgPrice = allPrices.reduce((a, b) => a + b) / allPrices.length;
    final highestPrice = allPrices.reduce((a, b) => a > b ? a : b);
    final lowestPrice = allPrices.reduce((a, b) => a < b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Market Rates",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009688),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: const Color(0xFF76E2C6),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryBox(
                      Icons.trending_flat,
                      "Avg",
                      "Rs. ${avgPrice.toStringAsFixed(1)}",
                    ),
                    _summaryBox(Icons.trending_up, "High", "Rs. $highestPrice"),
                    _summaryBox(Icons.trending_down, "Low", "Rs. $lowestPrice"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filters
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedDistrict,
                    items: districts
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedDistrict = val!),
                    decoration: const InputDecoration(
                      labelText: "District",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedType,
                    items: paddyTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedType = val!),
                    decoration: const InputDecoration(
                      labelText: "Paddy Type",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedMoisture,
                    items: ["Dry", "Wet"]
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedMoisture = val!),
                    decoration: const InputDecoration(
                      labelText: "Moisture",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: [
                  // 🎯 Highlighted selection
                  const Text(
                    "🎯 Your Selection",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (filtered.isEmpty)
                    const Card(
                      child: ListTile(title: Text("No data available")),
                    )
                  else
                    ...filtered.map((item) => _highlightCard(item)).toList(),

                  const SizedBox(height: 16),

                  // 📊 Grouped other market prices
                  const Text(
                    "📊 All Other Market Prices",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._groupByDistrict(others).entries.map((entry) {
                    return ExpansionTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: Colors.teal,
                      ),
                      title: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: entry.value
                          .map((item) => _priceCard(item))
                          .toList(),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _highlightCard(Map<String, dynamic> item) {
    return Card(
      color: const Color(0xFFE8F5E9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: ListTile(
        leading: const Icon(Icons.grain, color: Colors.teal, size: 30),
        title: Text(
          "${item["type"]} - ${item["moisture"]}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "District: ${item["district"]}",
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: Text(
          "Rs. ${item["price"]}/kg",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _priceCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        leading: const Icon(Icons.grain, color: Colors.teal),
        title: Text("${item["type"]} (${item["moisture"]})"),
        trailing: Text(
          "Rs. ${item["price"]}/kg",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _summaryBox(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.black87, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, color: Colors.black)),
      ],
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupByDistrict(
    List<Map<String, dynamic>> items,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item["district"], () => []);
      grouped[item["district"]]!.add(item);
    }
    return grouped;
  }
}
