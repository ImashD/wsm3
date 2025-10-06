import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/auth_service.dart';

class DriverRegistrationPage extends StatefulWidget {
  const DriverRegistrationPage({super.key});

  @override
  State<DriverRegistrationPage> createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _vehicleNoController = TextEditingController();
  final TextEditingController _customVehicleController =
      TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _licenseImageFile;
  String? _selectedVehicleType;

  final List<String> _vehicleTypes = [
    "Car",
    "Lorry",
    "Tractor",
    "Three-wheeler",
    "Bike",
    "Other",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _nicController.dispose();
    _phoneController.dispose();
    _vehicleNoController.dispose();
    _customVehicleController.dispose();
    _experienceController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickLicenseImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _licenseImageFile = File(pickedFile.path));
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_licenseImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload your license image")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      await authService.registerRole(UserRole.driver);
      await authService.setUserRole(UserRole.driver);

      if (!mounted) return;
      context.go('/dashboard/driver');
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
          "$label*",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: TextFormField(
            controller: controller,
            keyboardType: inputType,
            validator: (value) {
              if (value == null || value.isEmpty) return "Please enter $label";
              if (label == "N.I.C" && value.length != 12) {
                return "NIC must be exactly 12 characters";
              }
              if (label == "Phone Number" && value.length < 10) {
                return "Enter a valid phone number";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF9800),
      body: SafeArea(
        child: Column(
          children: [
            // Top header
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
                      backgroundColor: const Color(0xFFFFF3E0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
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
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
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

            // Bottom container with form
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            label: "Name",
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
                            label: "Vehicle Number",
                            hint: "e.g. ABC-1234",
                            controller: _vehicleNoController,
                          ),

                          // Vehicle type dropdown
                          Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              "Vehicle Type*",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedVehicleType,
                            items: _vehicleTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedVehicleType = value);
                            },
                            validator: (value) {
                              if (value == null)
                                return "Please select a vehicle type";
                              if (value == "Other" &&
                                  _customVehicleController.text.isEmpty) {
                                return "Please enter your vehicle type";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFFFE0B2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_selectedVehicleType == "Other")
                            _buildTextField(
                              label: "Custom Vehicle Type",
                              hint: "Enter your vehicle type",
                              controller: _customVehicleController,
                            ),
                          _buildTextField(
                            label: "Experience (years)",
                            hint: "e.g. 5",
                            controller: _experienceController,
                            inputType: TextInputType.number,
                          ),
                          _buildTextField(
                            label: "Email",
                            hint: "Optional email",
                            controller: _emailController,
                            inputType: TextInputType.emailAddress,
                          ),

                          // License upload
                          Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              "Upload Driving License*",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickLicenseImage,
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE0B2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _licenseImageFile == null
                                  ? const Icon(
                                      Icons.upload_file,
                                      size: 40,
                                      color: Colors.black54,
                                    )
                                  : Image.file(
                                      _licenseImageFile!,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Submit button
                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF9800),
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
                          const SizedBox(height: 20),
                        ],
                      ),
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
