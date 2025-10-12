import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'trips_screen.dart';

class DriverDashboardPage extends StatefulWidget {
  const DriverDashboardPage({super.key});

  @override
  State<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  bool _isAvailable = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String driverId = "CURRENT_DRIVER_ID"; // replace with actual driver UID

  void _acceptRequest(String docId, Map<String, dynamic> req) async {
    // Add to acceptedTrips in Firestore
    await _firestore
        .collection('drivers')
        .doc(driverId)
        .collection('acceptedTrips')
        .add(req);

    // Remove from tripRequests
    await _firestore
        .collection('drivers')
        .doc(driverId)
        .collection('tripRequests')
        .doc(docId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Accepted trip request from ${req['farmer']}")),
    );
  }

  void _rejectRequest(String docId, String farmerName) async {
    await _firestore
        .collection('drivers')
        .doc(driverId)
        .collection('tripRequests')
        .doc(docId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Rejected trip request from $farmerName")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripRequestsRef = _firestore
        .collection('drivers')
        .doc(driverId)
        .collection('tripRequests');

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 4,
                    left: 2,
                    child: Material(
                      elevation: 4,
                      shape: const CircleBorder(),
                      color: Colors.transparent,
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFFFFB74D),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(1, 2),
                        ),
                      ],
                    ),
                    child: Image.asset("assets/logo.png", height: 35),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications, size: 26),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () => _showProfileDialog(context),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFFFB74D),
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                            child: _profileImage == null
                                ? const Icon(Icons.person, color: Colors.black)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tagline
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFFFB74D),
              ),
              child: const Text(
                "තිරසාර ගොවිතැනට නව සවියක්\n"
                "Smart farming Starts here\n"
                "ஸ்மார்ட் விவசாயம் இங்கே தொடங்குகிறது",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),

            // Availability switch
            SwitchListTile(
              title: const Text(
                "Available for Trips",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              value: _isAvailable,
              onChanged: (val) => setState(() => _isAvailable = val),
              activeColor: Colors.black,
              activeTrackColor: const Color(0xFFFF9800),
            ),

            const SizedBox(height: 8),

            // Trip Requests
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: tripRequestsRef.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No trip requests available",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      );
                    }

                    final trips = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: trips.length,
                      itemBuilder: (context, index) {
                        final trip =
                            trips[index].data() as Map<String, dynamic>;
                        final docId = trips[index].id;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 14,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color.fromRGBO(255, 204, 128, 1),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  "🚜 Farmer: ${trip['farmer']}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFF3E0), Colors.white],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(16),
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.scale,
                                          size: 18,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 8),
                                        Text("Capacity: ${trip['capacity']}"),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 18,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Pickup: ${trip['pickup']}",
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.flag,
                                          size: 18,
                                          color: Colors.redAccent,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Dropoff: ${trip['dropoff']}",
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.blueGrey,
                                        ),
                                        const SizedBox(width: 8),
                                        Text("Date: ${trip['date']}"),
                                        const SizedBox(width: 16),
                                        const Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Colors.blueGrey,
                                        ),
                                        const SizedBox(width: 8),
                                        Text("Time: ${trip['time']}"),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => _rejectRequest(
                                            docId,
                                            trip['farmer'],
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            "Reject",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _acceptRequest(docId, trip),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.check,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            "Accept",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Bottom Navigation
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _bottomNavButton(Icons.chat, "Ask me", () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Chatbot feature coming soon..."),
                      ),
                    );
                  }),
                  const SizedBox(width: 25),
                  _bottomNavButton(Icons.list, "My Trips", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DriverTripScreen(driverId: driverId),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            Future<void> _pickProfileImage() async {
              final pickedFile = await _picker.pickImage(
                source: ImageSource.gallery,
              );
              if (pickedFile != null) {
                setState(() => _profileImage = File(pickedFile.path));
                setDialogState(() => _profileImage = File(pickedFile.path));
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            context.push('/driver-registration');
                          },
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: const Icon(Icons.close, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: const Color(0xFFFFB74D),
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.black,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF9800),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Driver Name",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Vehicle: AB-1234 | Lorry",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Contact: +94 77 123 4567",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.go('/role-selection');
                      },
                      child: const Text(
                        "Switch Role",
                        style: TextStyle(color: Colors.white),
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

  Widget _bottomNavButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFFFB74D),
          radius: 24,
          child: IconButton(
            icon: Icon(icon, color: Colors.black),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
