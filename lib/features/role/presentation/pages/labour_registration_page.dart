import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/auth_service.dart';

class LabourRegistrationPage extends StatefulWidget {
  const LabourRegistrationPage({super.key});

  @override
  State<LabourRegistrationPage> createState() => _LabourRegistrationPageState();
}

class _LabourRegistrationPageState extends State<LabourRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _nicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _customSkillController = TextEditingController();
  int _experience = 0;
  int _age = 18;

  String? _selectedSkill;

  final List<String> _skills = [
    "Harvesting",
    "Planting",
    "Transporting",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data()?['labourDetails'];
        if (data != null) {
          setState(() {
            _nameController.text = data['name'] ?? '';
            _nicController.text = data['nic'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _addressController.text = data['address'] ?? '';
            _age = data['age'] ?? 18;
            _experience = data['experience'] ?? 0;
            _selectedSkill = data['skill'];
            if (_selectedSkill != null && !_skills.contains(_selectedSkill!)) {
              _selectedSkill = "Other";
              _customSkillController.text = data['skill'] ?? '';
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading labour data: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _customSkillController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      final skill = _selectedSkill == "Other"
          ? _customSkillController.text
          : _selectedSkill;

      final labourData = {
        "name": _nameController.text,
        "nic": _nicController.text,
        "phone": _phoneController.text,
        "address": _addressController.text,
        "age": _age,
        "experience": _experience,
        "skill": skill,
      };

      // ✅ Update Firestore directly
      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
      await userDoc.set({
        "role": "labour",
        "labourDetails": labourData,
      }, SetOptions(merge: true));

      await authService.setUserRole(UserRole.labour);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Details saved successfully!")),
      );

      context.push('/dashboard/labour');
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
    required String hint,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
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
              if (value == null || value.isEmpty) return "Please enter $label";

              if (label == "Full Name") {
                final nameReg = RegExp(r'^[A-Za-z ]+$');
                if (!nameReg.hasMatch(value)) {
                  return "Name must contain only English letters";
                }
              }

              if (label == "N.I.C") {
                final oldNIC = RegExp(r'^[0-9]{9}[vV]$');
                final newNIC = RegExp(r'^[0-9]{12}$');
                if (!oldNIC.hasMatch(value) && !newNIC.hasMatch(value)) {
                  return "Invalid NIC format (e.g., 123456789V or 200012345678)";
                }
              }

              if (label == "Phone Number") {
                final phoneReg = RegExp(r'^[0-9]{10,}$');
                if (!phoneReg.hasMatch(value)) {
                  return "Enter a valid phone number";
                }
              }

              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFBBDEFB),
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
            color: const Color(0xFFBBDEFB),
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
      backgroundColor: const Color(0xFF2196F3),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Container(height: 160, color: const Color(0xFF2196F3)),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Material(
                    elevation: 4,
                    shape: const CircleBorder(),
                    color: Colors.transparent,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFFBBDEFB),
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
                            color: const Color(0xFFBBDEFB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.asset('assets/logo.png', height: 50),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Labour Registration",
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
                        _buildNumericField(
                          label: "Age",
                          value: _age,
                          unit: "years",
                          onIncrement: () => setState(() => _age++),
                          onDecrement: () =>
                              setState(() => _age > 18 ? _age-- : 18),
                        ),
                        _buildTextField(
                          label: "Address",
                          hint: "Your home address",
                          controller: _addressController,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Skill",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedSkill,
                          hint: const Text("Select Your Skill Type"),
                          items: _skills
                              .map(
                                (skill) => DropdownMenuItem(
                                  value: skill,
                                  child: Text(skill),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() {
                            _selectedSkill = value;
                          }),
                          validator: (value) =>
                              value == null ? "Please select a skill" : null,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFBBDEFB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_selectedSkill == "Other")
                          _buildTextField(
                            label: "Custom Skill",
                            hint: "Enter your skill",
                            controller: _customSkillController,
                          ),
                        _buildNumericField(
                          label: "Driving Experience",
                          value: _experience,
                          unit: "years",
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
                                4,
                                63,
                                111,
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
