import 'package:flutter/material.dart';

class LaborsScreen extends StatefulWidget {
  const LaborsScreen({super.key});

  @override
  State<LaborsScreen> createState() => _LaborsScreenState();
}

class _LaborsScreenState extends State<LaborsScreen> {
  final TextEditingController _wageController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  DateTime? _selectedDate;
  bool _requestSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Request Labors",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009688),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Plan your labour request",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1DD1A1),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Date picker
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF009688),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (pickedDate != null) {
                            setState(() => _selectedDate = pickedDate);
                          }
                        },
                        child: Text(
                          _selectedDate == null
                              ? "Pick the date to begin labour work"
                              : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Wage per day
                  TextField(
                    controller: _wageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.money),
                      hintText: "Wage per day (LKR)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Number of days
                  TextField(
                    controller: _daysController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.schedule),
                      hintText: "Number of days",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Special instructions
                  TextField(
                    controller: _instructionsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.note),
                      hintText: "Special instructions (optional)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009688),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _submitRequest,
                      child: const Text(
                        "Send Request",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_requestSent)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade100,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Text(
                    "Your labour request has been sent successfully!",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _submitRequest() {
    if (_selectedDate == null ||
        _wageController.text.isEmpty ||
        _daysController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _requestSent = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _requestSent = false);
      _wageController.clear();
      _daysController.clear();
      _instructionsController.clear();
      _selectedDate = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Labour request submitted successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
