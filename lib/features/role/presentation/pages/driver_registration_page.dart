import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/auth_service.dart';

class DriverRegistrationPage extends StatefulWidget {
  const DriverRegistrationPage({super.key});

  @override
  State<DriverRegistrationPage> createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _nicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _vehiclenoController = TextEditingController();
  String? _selectedVehicle;
  int _experience = 0;

  final List<String> _vehicles = [
    "Lorry",
    "Tractor",
    "Three-Wheel",
    "Bike",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data()?['driverDetails'];
      if (data != null) {
        setState(() {
          _nameController.text = data['fullName'] ?? '';
          _nicController.text = data['nic'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _licenseController.text = data['license'] ?? '';
          _vehiclenoController.text = data['vehicleno'] ?? '';
          _selectedVehicle = data['vehicleType'];
          _experience = data['experience'] ?? 0;
        });
      }
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      final driverData = {
        "fullName": _nameController.text,
        "nic": _nicController.text,
        "phone": _phoneController.text,
        "license": _licenseController.text,
        "vehicleno": _vehiclenoController.text,
        "vehicleType": _selectedVehicle,
        "experience": _experience,
      };

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        "role": "driver",
        "driverDetails": driverData,
      }, SetOptions(merge: true));

      await AuthService().setUserRole(UserRole.driver);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Driver details saved!")));

      context.push('/dashboard/driver');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    String? hint,
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
            validator: (value) {
              if (value == null || value.isEmpty) return "Enter Your $label";

              if (label == "Full Name") {
                final nameReg = RegExp(r'^[A-Za-z ]+$');
                if (!nameReg.hasMatch(value)) {
                  return "Name must contain only letters";
                }
              }

              if (label == "N.I.C") {
                final oldNIC = RegExp(r'^[0-9]{9}[vV]$');
                final newNIC = RegExp(r'^[0-9]{12}$');
                if (!oldNIC.hasMatch(value) && !newNIC.hasMatch(value)) {
                  return "Invalid NIC format";
                }
              }

              if (label == "Phone Number") {
                final phoneReg = RegExp(r'^[0-9]{10,}$');
                if (!phoneReg.hasMatch(value)) {
                  return "Invalid phone number";
                }
              }

              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFFFE0B2),
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

  Widget _buildNumericField({
    required String label,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    String unit = "years",
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
            color: const Color(0xFFFFE0B2),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
    return Scaffold(
      backgroundColor: const Color(0xFFFF9800),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Container(height: 160, color: const Color(0xFFFF9800)),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Material(
                    elevation: 4,
                    shape: const CircleBorder(),
                    color: Colors.transparent,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFFFFE0B2),
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
                            color: const Color(0xFFFFE0B2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.asset('assets/logo.png', height: 50),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Driver Registration",
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
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
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
                          hint: "Your phone number",
                          controller: _phoneController,
                          inputType: TextInputType.phone,
                        ),
                        _buildTextField(
                          label: "Driving License ID",
                          hint: "Your driving license ID",
                          controller: _licenseController,
                        ),

                        _buildTextField(
                          label: "Vehicle Number",
                          hint: "Your vehicle number (e.g. ABC-1234)",
                          controller: _licenseController,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Vehicle Type",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedVehicle,
                          hint: const Text("Select Vehicle Type"),
                          items: _vehicles
                              .map(
                                (v) =>
                                    DropdownMenuItem(value: v, child: Text(v)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedVehicle = val),
                          validator: (val) =>
                              val == null ? "Select a vehicle" : null,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFFFE0B2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        _buildNumericField(
                          label: "Driving Experience",
                          value: _experience,
                          onIncrement: () => setState(() => _experience++),
                          onDecrement: () => setState(
                            () => _experience > 0 ? _experience-- : 0,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                199,
                                103,
                                0,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
                        const SizedBox(height: 20),
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
