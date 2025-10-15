import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  bool _isNow = true;
  DateTime? _scheduledDateTime;
  int _quantity = 0;
  bool _isLoading = false;

  Future<void> _sendTripRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_quantity <= 0 ||
        _pickupController.text.isEmpty ||
        _dropoffController.text.isEmpty ||
        _contactController.text.isEmpty ||
        (!_isNow && _scheduledDateTime == null)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final farmerDoc = await FirebaseFirestore.instance
          .collection('farmers')
          .doc(user.uid)
          .get();
      final farmerData = farmerDoc.data() ?? {};
      final farmerName = farmerData['name'] ?? 'Unknown Farmer';
      final farmerNIC = farmerData['nic'] ?? 'N/A';
      final farmerArea = farmerData['area'] ?? 'N/A';

      await FirebaseFirestore.instance.collection('trip_requests').add({
        'pickup': _pickupController.text,
        'dropoff': _dropoffController.text,
        'quantity': _quantity,
        'isNow': _isNow,
        'scheduledTime': _scheduledDateTime,
        'status': 'pending',
        'farmerId': user.uid,
        'farmerName': farmerName,
        'farmerNIC': farmerNIC,
        'farmerArea': farmerArea,
        'driverId': null,
        'driverContact': null,
        'contactNumber': _contactController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Trip request sent!")));

      _pickupController.clear();
      _dropoffController.clear();
      _contactController.clear();
      _quantity = 0;
      _scheduledDateTime = null;
      _isNow = true;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _callDriver(String phone) async {
    if (phone.isEmpty) return;
    final url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: const Text(
          "Request Drivers",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF009688),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTripRequestCard(),
                const SizedBox(height: 24),
                Text(
                  "My Requests",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                _buildMyRequestsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripRequestCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Schedule Your Trip",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(_pickupController, "Pickup Location"),
          const SizedBox(height: 16),
          _buildTextField(_dropoffController, "Drop-off Location"),
          const SizedBox(height: 16),
          _buildQuantitySelector(),
          const SizedBox(height: 16),
          _buildTextField(
            _contactController,
            "Contact Number",
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTripTypeSelector(),
          if (!_isNow) _buildScheduleButton(),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendTripRequest,
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
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Send Request",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRequestsList() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trip_requests')
          .where('farmerId', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(
              child: Text("No trips yet", style: TextStyle(fontSize: 16)),
            ),
          );
        }

        // Get the trips and sort locally by timestamp (newest first)
        final trips = snapshot.data!.docs.toList();
        trips.sort((a, b) {
          final tsA = a['timestamp'] as Timestamp?;
          final tsB = b['timestamp'] as Timestamp?;
          return (tsB?.millisecondsSinceEpoch ?? 0).compareTo(
            tsA?.millisecondsSinceEpoch ?? 0,
          );
        });

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final data = trips[index].data() as Map<String, dynamic>;
            final status = (data['status'] ?? 'pending').toString();

            Color statusColor;
            if (status == 'accepted') {
              statusColor = Colors.green;
            } else if (status == 'completed') {
              statusColor = Colors.blue;
            } else {
              statusColor = Colors.orange;
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pickup: ${data['pickup'] ?? '-'}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Drop-off: ${data['dropoff'] ?? '-'}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text("Status: "),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (status == 'accepted' &&
                        (data['driverName']?.toString().isNotEmpty ?? false))
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          "Driver Name: ${data['driverName']}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (status == 'accepted' &&
                        (data['driverContact']?.toString().isNotEmpty ?? false))
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: GestureDetector(
                          onTap: () => _callDriver(data['driverContact']),
                          child: Text(
                            "📞 ${data['driverContact']}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.teal[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text("Quantity:", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.teal),
          onPressed: () => setState(() {
            if (_quantity > 0) _quantity--;
          }),
        ),
        Text("$_quantity MT", style: const TextStyle(fontSize: 16)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
          onPressed: () => setState(() {
            _quantity++;
          }),
        ),
      ],
    );
  }

  Widget _buildTripTypeSelector() {
    return Row(
      children: [
        const Text("Trip Type:", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 16),
        ChoiceChip(
          label: const Text("Now"),
          selected: _isNow,
          selectedColor: Colors.teal,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(color: _isNow ? Colors.white : Colors.black87),
          onSelected: (_) => setState(() => _isNow = true),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text("Schedule"),
          selected: !_isNow,
          selectedColor: Colors.teal,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(color: !_isNow ? Colors.white : Colors.black87),
          onSelected: (_) => setState(() => _isNow = false),
        ),
      ],
    );
  }

  Widget _buildScheduleButton() {
    return TextButton(
      onPressed: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
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
            ? "Select Date & Time"
            : "Scheduled: ${_scheduledDateTime.toString()}",
        style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w500),
      ),
    );
  }
}
