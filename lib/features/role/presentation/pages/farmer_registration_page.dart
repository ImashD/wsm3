// farmer_registration_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Farmer fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _farmLocationController = TextEditingController();
  final TextEditingController _cropTypeController = TextEditingController();
  final TextEditingController _farmSizeController = TextEditingController();

  bool _isLoading = false;
  String? _qrData;

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
      _phoneController.text = data['phone'] ?? '';
      _farmLocationController.text = data['farmLocation'] ?? '';
      _cropTypeController.text = data['cropType'] ?? '';
      _farmSizeController.text = data['farmSize'] ?? '';

      _generateQrData();
    }
  }

  void _generateQrData() {
    final data = {
      "name": _nameController.text,
      "phone": _phoneController.text,
      "farmLocation": _farmLocationController.text,
      "cropType": _cropTypeController.text,
      "farmSize": _farmSizeController.text,
    };
    setState(() {
      _qrData = data.toString(); // QR code shows all farmer info
    });
  }

  Future<void> _saveFarmer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection('farmers').doc(uid).set({
        "name": _nameController.text,
        "phone": _phoneController.text,
        "farmLocation": _farmLocationController.text,
        "cropType": _cropTypeController.text,
        "farmSize": _farmSizeController.text,
        "uid": uid,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      _generateQrData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farmer profile saved successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmer Registration"),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Full Name"),
                      validator: (val) => val!.isEmpty ? "Enter name" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (val) => val!.isEmpty ? "Enter phone" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _farmLocationController,
                      decoration: const InputDecoration(
                        labelText: "Farm Location",
                      ),
                      validator: (val) =>
                          val!.isEmpty ? "Enter farm location" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _cropTypeController,
                      decoration: const InputDecoration(
                        labelText: "Crop Type(s)",
                      ),
                      validator: (val) =>
                          val!.isEmpty ? "Enter crop type(s)" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _farmSizeController,
                      decoration: const InputDecoration(
                        labelText: "Farm Size (acres)",
                      ),
                      validator: (val) =>
                          val!.isEmpty ? "Enter farm size" : null,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveFarmer,
                        child: const Text("Save & Generate QR"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
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
                          if (_qrData != null && _qrData!.isNotEmpty)
                            QrImageView(
                              // <-- use QrImageView instead of QrImage
                              data: _qrData!,
                              size: 200,
                            )
                          else
                            Image.asset(
                              "assets/sample_qr.png",
                              height: 200,
                              width: 200,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
