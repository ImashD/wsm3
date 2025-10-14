// farmer_registration_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

class FarmerRegistrationPage extends StatefulWidget {
  const FarmerRegistrationPage({super.key});

  @override
  State<FarmerRegistrationPage> createState() => _FarmerRegistrationPageState();
}

class _FarmerRegistrationPageState extends State<FarmerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedDistrict;
  String? _selectedCrop;
  int _area = 0;
  bool _isLoading = false;
  String? _qrData;

  final List<String> _crops = [
    "Samba",
    "Naadu (RED)",
    "Naadu (WHITE)",
    "Keeri Samba",
  ];

  final List<String> _districts = [
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

  @override
  void initState() {
    super.initState();
    _loadFarmerData();
  }

  Future<void> _loadFarmerData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('farmers').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      _nicController.text = data['nic'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _selectedCrop = data['crop'] ?? '';
      _selectedDistrict = data['district'];
      _area = data['area'] ?? 0;
      _generateQrData();
      setState(() {});
    }
  }

  void _generateQrData() {
    final data = {
      "name": _nameController.text,
      "nic": _nicController.text,
      "phone": _phoneController.text,
      "district": _selectedDistrict,
      "crop": _selectedCrop,
      "area": _area,
    };
    setState(() {
      _qrData = data.toString();
    });
  }

  Future<void> _saveFarmer() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select district")));
      return;
    }

    if (_selectedCrop == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select crop type")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      print("🟡 Starting _saveFarmer()...");
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final uid = user.uid;
      print("✅ Current UID: $uid");

      print("📦 Saving farmer to Firestore...");
      await _firestore.collection('farmers').doc(uid).set({
        "uid": uid,
        "name": _nameController.text.trim(),
        "nic": _nicController.text.trim(),
        "phone": _phoneController.text.trim(),
        "crop": _selectedCrop,
        "district": _selectedDistrict,
        "area": _area,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
      print("✅ Farmer saved successfully to Firestore.");

      _generateQrData();
      print("🧩 QR data generated.");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Farmer profile saved successfully.')),
        );
        print("➡️ Navigating to /dashboard/farmer");
        context.go('/dashboard/farmer');
      }
    } catch (e, stack) {
      print("🔥 Firestore Error: $e");
      print(stack);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving farmer: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
      print("🟢 _saveFarmer() completed");
    }
  }

  // ---------- Reusable UI widgets ----------
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 320,
          child: TextFormField(
            controller: controller,
            keyboardType: inputType,
            validator:
                validator ??
                (val) =>
                    val == null || val.isEmpty ? "Please enter $label" : null,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color.fromARGB(255, 118, 226, 198),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 320,
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            hint: Text("Select $label"),

            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromARGB(255, 118, 226, 198),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
            ),
            validator: (value) => value == null ? "Please select $label" : null,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNumericField({
    required String label,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    String unit = "",
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 320,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 118, 226, 198),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                onPressed: value > 0 ? onDecrement : null,
              ),
              Text(
                "$value $unit",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: onIncrement,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Current UID: ${_auth.currentUser?.uid}");

    return Scaffold(
      backgroundColor: const Color(0xFF1DD1A1),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Stack(
              children: [
                Container(height: 160, color: const Color(0xFF1DD1A1)),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Material(
                    elevation: 4,
                    shape: const CircleBorder(),
                    color: Colors.transparent,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFFE1FCF9),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 46,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1FCF9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.asset('assets/logo.png', height: 50),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Farmer Registration",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Form area
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1DD1A1),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          label: "Full Name",
                          hint: "Your full name",
                          controller: _nameController,
                        ),
                        _buildTextField(
                          label: "N.I.C",
                          hint: "Your NIC number",
                          controller: _nicController,
                        ),
                        _buildTextField(
                          label: "Phone Number",
                          hint: "07XXXXXXXX",
                          controller: _phoneController,
                          inputType: TextInputType.phone,
                        ),
                        const Divider(thickness: 1),
                        const SizedBox(height: 10),

                        const Text(
                          "Cultivation Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1DD1A1),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildDropdownField(
                          label: "Type of Crops Grown",
                          items: _crops,
                          selectedValue: _selectedCrop,
                          onChanged: (value) {
                            setState(() => _selectedCrop = value);
                          },
                        ),
                        _buildNumericField(
                          label: "Land Size (in acres)",
                          value: _area,
                          unit: "years",
                          onIncrement: () => setState(() => _area++),
                          onDecrement: () =>
                              setState(() => _area = _area > 0 ? _area - 1 : 0),
                        ),

                        _buildDropdownField(
                          label: "Location (District)",
                          items: _districts,
                          selectedValue: _selectedDistrict,
                          onChanged: (value) {
                            setState(() => _selectedDistrict = value);
                          },
                        ),

                        const SizedBox(height: 20),
                        Center(
                          child: SizedBox(
                            width: 220,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveFarmer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  4,
                                  96,
                                  71,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Save & REGISTER",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (_qrData != null && _qrData!.isNotEmpty)
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  "Farmer QR Code",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                QrImageView(data: _qrData!, size: 200),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
