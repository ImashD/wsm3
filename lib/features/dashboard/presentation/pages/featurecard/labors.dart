import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class LaborsScreen extends StatefulWidget {
  const LaborsScreen({super.key});

  @override
  State<LaborsScreen> createState() => _LaborsScreenState();
}

class _LaborsScreenState extends State<LaborsScreen> {
  final TextEditingController _wageController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  DateTime? _selectedDate;
  int _numOfDays = 0;
  bool _isLoading = false;

  Future<void> _sendLabourRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_selectedDate == null ||
        _wageController.text.isEmpty ||
        _numOfDays <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
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

      await FirebaseFirestore.instance.collection('labour_requests').add({
        'date': _selectedDate,
        'wage': int.tryParse(_wageController.text) ?? 0,
        'numOfDays': _numOfDays,
        'instructions': _instructionsController.text,
        'status': 'pending',
        'farmerId': user.uid,
        'farmerName': farmerName,
        'farmerNIC': farmerNIC,
        'farmerArea': farmerArea,
        'workerId': null,
        'workerContact': null,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Job request sent!")));

      // Reset form
      _wageController.clear();
      _instructionsController.clear();
      _selectedDate = null;
      _numOfDays = 0;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _callWorker(String phone) async {
    if (phone.isEmpty) return;
    final url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: const Text(
          "Request Labors",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009688),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLabourRequestCard(),
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
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('labour_requests')
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
                    child: Text(
                      "No requests yet",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }

              final requests = snapshot.data!.docs.toList();
              requests.sort((a, b) {
                final tsA = a['timestamp'] as Timestamp?;
                final tsB = b['timestamp'] as Timestamp?;
                return (tsB?.millisecondsSinceEpoch ?? 0).compareTo(
                  tsA?.millisecondsSinceEpoch ?? 0,
                );
              });

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final data = requests[index].data() as Map<String, dynamic>;
                  final status = (data['status'] ?? 'pending').toString();

                  Color statusColor;
                  if (status == 'accepted') {
                    statusColor = Colors.green;
                  } else if (status == 'completed') {
                    statusColor = Colors.blue;
                  } else {
                    statusColor = Colors.orange;
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Date: ${data['date'] != null ? (data['date'] as Timestamp).toDate().toLocal().toString().split(' ')[0] : '-'}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text("Wage/day: LKR ${data['wage']}"),
                          Text("No of Days: ${data['numOfDays']}"),
                          if ((data['instructions'] ?? '').isNotEmpty)
                            Text("Instructions: ${data['instructions']}"),
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
                          if (status == 'accepted' &&
                              (data['workerContact']?.toString().isNotEmpty ??
                                  false))
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: GestureDetector(
                                onTap: () => _callWorker(data['workerContact']),
                                child: Text(
                                  "📞 ${data['workerContact']}",
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
          ),
        ],
      ),
    );
  }

  Widget _buildLabourRequestCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Schedule Labour Request",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // Date picker
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.teal),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      setState(() => _selectedDate = pickedDate);
                    }
                  },
                  child: Text(
                    _selectedDate == null
                        ? "Choose start date"
                        : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    style: const TextStyle(fontSize: 16, color: Colors.teal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextField(_wageController, "Wage per day (LKR)"),

            const SizedBox(height: 16),

            // Number of days
            Row(
              children: [
                const Text(
                  "Number of days:",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.teal),
                  onPressed: () {
                    if (_numOfDays > 0) setState(() => _numOfDays--);
                  },
                ),
                Text("$_numOfDays days"),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.teal),
                  onPressed: () => setState(() => _numOfDays++),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextField(
              _instructionsController,
              "Special instructions (optional)",
            ),

            const SizedBox(height: 24),

            // Submit button
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendLabourRequest,
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
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
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
}
