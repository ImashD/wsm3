// lib/drawer/reports.dart

import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // Placeholder data
  final List<Map<String, dynamic>> reports = [
    {
      "date": "2025-09-15",
      "paddyType": "Keeri Samba",
      "quality": "Wet",
      "quantity": "120",
      "price": "120",
      "mill": "Colombo Mill",
    },
    {
      "date": "2025-09-12",
      "paddyType": "Naadu (Red)",
      "quality": "Dry",
      "quantity": "80",
      "price": "100",
      "mill": "Kandy Mill",
    },
    {
      "date": "2025-09-10",
      "paddyType": "Naadu (White)",
      "quality": "Wet",
      "quantity": "60",
      "price": "105",
      "mill": "Galle Mill",
    },
    {
      "date": "2025-09-08",
      "paddyType": "Samba",
      "quality": "Dry",
      "quantity": "150",
      "price": "110",
      "mill": "Jaffna Mill",
    },
  ];

  String? filterPaddyType;
  String? filterMill;
  DateTimeRange? filterDateRange;

  List<Map<String, dynamic>> get filteredReports {
    return reports.where((report) {
      final matchPaddy =
          filterPaddyType == null || report["paddyType"] == filterPaddyType;
      final matchMill = filterMill == null || report["mill"] == filterMill;
      final reportDate = DateTime.parse(report["date"]);
      final matchDate =
          filterDateRange == null ||
          (reportDate.isAfter(
                filterDateRange!.start.subtract(const Duration(days: 1)),
              ) &&
              reportDate.isBefore(
                filterDateRange!.end.add(const Duration(days: 1)),
              ));
      return matchPaddy && matchMill && matchDate;
    }).toList();
  }

  Future<void> pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        filterDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalQty = filteredReports.fold(
      0,
      (sum, item) => sum + int.parse(item["quantity"]),
    );
    final totalAmount = filteredReports.fold(
      0,
      (sum, item) =>
          sum + int.parse(item["quantity"]) * int.parse(item["price"]),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sales Reports",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009688),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filters section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Paddy Type dropdown
                    DropdownButton<String>(
                      hint: const Text("Select Paddy Type"),
                      value: filterPaddyType,
                      items:
                          [
                                "Keeri Samba",
                                "Naadu (Red)",
                                "Naadu (White)",
                                "Samba",
                              ]
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          filterPaddyType = value;
                        });
                      },
                    ),
                    // Mill dropdown
                    DropdownButton<String>(
                      hint: const Text("Select Mill"),
                      value: filterMill,
                      items:
                          [
                                "Colombo Mill",
                                "Kandy Mill",
                                "Galle Mill",
                                "Jaffna Mill",
                              ]
                              .map(
                                (mill) => DropdownMenuItem(
                                  value: mill,
                                  child: Text(mill),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          filterMill = value;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Centered Date Range Picker
                Center(
                  child: ElevatedButton.icon(
                    onPressed: pickDateRange,
                    icon: const Icon(Icons.date_range, color: Colors.white),
                    label: Text(
                      filterDateRange == null
                          ? "Select Date Range"
                          : "${filterDateRange!.start.day}-${filterDateRange!.start.month}-${filterDateRange!.start.year} to ${filterDateRange!.end.day}-${filterDateRange!.end.month}-${filterDateRange!.end.year}",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009688),
                    ),
                  ),
                ),

                // Clear filters
                if (filterPaddyType != null ||
                    filterMill != null ||
                    filterDateRange != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        filterPaddyType = null;
                        filterMill = null;
                        filterDateRange = null;
                      });
                    },
                    child: const Text(
                      "Clear Filters",
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
              ],
            ),
          ),

          // Summary Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.kitchen, color: Colors.teal, size: 28),
                        const SizedBox(height: 4),
                        const Text(
                          "Total Quantity",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("$totalQty kg"),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          color: Colors.green,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Total Earnings",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("Rs. $totalAmount"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Reports List
          Expanded(
            child: filteredReports.isEmpty
                ? const Center(child: Text("No reports found"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      final sales =
                          int.parse(report["quantity"]) *
                          int.parse(report["price"]);
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: Paddy Type + Date
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    report["date"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    report["paddyType"],
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Quality badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: report["quality"] == "Dry"
                                      ? Colors.orange[200]
                                      : Colors.blue[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  report["quality"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Details: Quantity, Price, Mill, Sales
                              Row(
                                children: [
                                  const Icon(
                                    Icons.kitchen,
                                    size: 16,
                                    color: Colors.teal,
                                  ),
                                  const SizedBox(width: 4),
                                  Text("${report["quantity"]} kg"),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.attach_money,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text("Rs. ${report["price"]}/kg"),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.store,
                                    size: 16,
                                    color: Colors.brown,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(report["mill"]),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.monetization_on,
                                    size: 16,
                                    color: Colors.purple,
                                  ),
                                  const SizedBox(width: 4),
                                  Text("Sales: Rs. $sales"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
