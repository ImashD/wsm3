// drivers.dart

import 'package:flutter/material.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  bool _isNow = true; // immediate or scheduled
  bool _requestSent = false; // mock driver accepted
  DateTime? _scheduledDateTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Request Drivers",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009688),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Schedule Your Trip",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1DD1A1),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Capacity
                  TextField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.production_quantity_limits),
                      hintText: "Paddy quantity (in MT)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pickup location (map picker)
                  TextField(
                    controller: _pickupController,
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on),
                      hintText: "Select Pickup location",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.map),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MapPickerScreen(
                                title: "Pickup Location",
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() => _pickupController.text = result);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Drop-off location (map picker)
                  TextField(
                    controller: _dropoffController,
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.flag),
                      hintText: "Select Drop-off location",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.map),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MapPickerScreen(
                                title: "Drop-off Location",
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() => _dropoffController.text = result);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Immediate or scheduled
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF009688)),
                      const SizedBox(width: 8),
                      const Text("Request type:"),
                      const SizedBox(width: 16),
                      ChoiceChip(
                        label: const Text("Now"),
                        selected: _isNow,
                        onSelected: (selected) {
                          setState(() => _isNow = true);
                        },
                        selectedColor: const Color(0xFF009688),
                        labelStyle: TextStyle(
                          color: _isNow ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text("Schedule"),
                        selected: !_isNow,
                        onSelected: (selected) {
                          setState(() => _isNow = false);
                        },
                        selectedColor: const Color(0xFF009688),
                        labelStyle: TextStyle(
                          color: !_isNow ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Date & Time picker for scheduled requests
                  if (!_isNow)
                    Row(
                      children: [
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
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _scheduledDateTime = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                });
                              }
                            }
                          },
                          child: Text(
                            _scheduledDateTime == null
                                ? "Click here to select date & time"
                                : "Scheduled: ${_scheduledDateTime!.day}/${_scheduledDateTime!.month}/${_scheduledDateTime!.year} ${_scheduledDateTime!.hour.toString().padLeft(2, '0')}:${_scheduledDateTime!.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // Request button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009688),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_capacityController.text.isEmpty ||
                            _pickupController.text.isEmpty ||
                            _dropoffController.text.isEmpty ||
                            (!_isNow && _scheduledDateTime == null)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all fields"),
                            ),
                          );
                          return;
                        }
                        setState(() => _requestSent = true);
                      },
                      child: const Text(
                        "Request Driver",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mock driver notification
                  if (_requestSent)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: const Color(0xFF1DD1A1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.drive_eta,
                              size: 40,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Driver Mahesh is on the way!",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Pickup: ${_pickupController.text}\nDrop-off: ${_dropoffController.text}" +
                                        (_isNow
                                            ? ""
                                            : "\nScheduled: ${_scheduledDateTime!.day}/${_scheduledDateTime!.month}/${_scheduledDateTime!.year} ${_scheduledDateTime!.hour.toString().padLeft(2, '0')}:${_scheduledDateTime!.minute.toString().padLeft(2, '0')}"),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() => _requestSent = false);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom decorative image
          SizedBox(
            height: 150,
            width: 150,
            child: Image.asset("assets/drivers.png", fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }
}

// Placeholder map picker screen
class MapPickerScreen extends StatelessWidget {
  final String title;
  const MapPickerScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF1DD1A1),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1DD1A1),
          ),
          child: const Text(
            "Select this location",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.pop(context, "Selected Location");
          },
        ),
      ),
    );
  }
}
