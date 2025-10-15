import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'job_screen.dart';
import '../../../../core/services/auth_service.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class LabourDashboardPage extends StatefulWidget {
  const LabourDashboardPage({super.key});

  @override
  State<LabourDashboardPage> createState() => _LabourDashboardPageState();
}

class _LabourDashboardPageState extends State<LabourDashboardPage> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  bool _isAvailable = true;

  StreamSubscription<DocumentSnapshot>? _labourSubscription;

  @override
  void initState() {
    super.initState();
    _listenToLabourData();
  }

  void _listenToLabourData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _labourSubscription = FirebaseFirestore.instance
        .collection('labours')
        .doc(uid)
        .snapshots()
        .listen((doc) async {
          if (doc.exists) {
            final data = doc.data()!;
            setState(() {
              _isAvailable = data['available'] ?? false;
            });
          } else {
            // If doc doesn’t exist, create it once
            await FirebaseFirestore.instance.collection('labours').doc(uid).set(
              {'available': false},
            );
            setState(() {
              _isAvailable = false;
            });
          }
        });
  }

  Future<void> _toggleAvailability(bool value) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _isAvailable = value;
    });

    await FirebaseFirestore.instance.collection('labours').doc(uid).set({
      'available': value,
    }, SetOptions(merge: true));
  }

  Future<void> _pickProfileImage(Function setDialogState) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _profileImage = file;
      });

      setDialogState(() {
        _profileImage = file;
      });
    }
  }

  // ✅ Fetch labour details (updated — no labourDetails subfield)
  Future<Map<String, dynamic>?> fetchLabourDetails() async {
    final uid = AuthService().getCurrentUserId();
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('labours')
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return doc.data();
  }

  final List<Map<String, String>> _jobRequests = [
    {
      "farmer": "Sunil Perera",
      "jobType": "Harvesting",
      "location": "Kurunegala",
      "duration": "4 hrs",
      "date": "2025-09-12",
      "time": "08:30 AM",
    },
    {
      "farmer": "Anjali Silva",
      "jobType": "Planting",
      "location": "Gampaha",
      "duration": "6 hrs",
      "date": "2025-09-13",
      "time": "02:00 PM",
    },
  ];

  final List<Map<String, String>> _acceptedJobs = [];

  void _acceptJob(int index) {
    setState(() {
      _acceptedJobs.add(_jobRequests[index]);
      _jobRequests.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Accepted job from ${_acceptedJobs.last["farmer"]}"),
      ),
    );
  }

  void _rejectJob(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Rejected job from ${_jobRequests[index]["farmer"]}"),
      ),
    );
    setState(() {
      _jobRequests.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 15, 12, 15),
              child: Stack(
                alignment: Alignment.center,
                children: [
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
                    child: Image.asset("assets/logo.png", height: 40),
                  ),

                  // Back button
                  Positioned(
                    top: 4,
                    left: 2,
                    child: Material(
                      elevation: 4,
                      shape: const CircleBorder(),
                      color: Colors.transparent,
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF00BCD4),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => context.go('/role-selection'),
                        ),
                      ),
                    ),
                  ),

                  // Notification + Profile icons
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
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFF00BCD4),
                            child: Icon(Icons.person, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ✅ Tagline
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF00BCD4),
              ),
              child: const Text(
                "තිරසාර ගොවිතැනට නව සවියක්\n"
                "Smart farming Starts here\n"
                "ஸ்மார்ட் விவசாயம் இங்கே தொடங்குகிறது",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),

            // ✅ Availability switch
            SwitchListTile(
              title: const Text(
                "Available for Work",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              value: _isAvailable,
              onChanged: (val) => _toggleAvailability(val),

              activeColor: Colors.black,
              activeTrackColor: const Color(0xFF00ACC1),
            ),

            const SizedBox(height: 8),

            // ✅ Job Requests
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: _jobRequests.isEmpty
                    ? const Center(
                        child: Text(
                          "No job requests available",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _jobRequests.length,
                        itemBuilder: (context, index) {
                          final job = _jobRequests[index];
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
                                    color: Color(0xFF80DEEA),
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    "🚜 Farmer: ${job["farmer"]}",
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
                                      colors: [Color(0xFFE0F7FA), Colors.white],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(16),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.work,
                                            size: 18,
                                            color: Colors.black54,
                                          ),
                                          const SizedBox(width: 8),
                                          Text("Job: ${job["jobType"]}"),
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
                                              "Location: ${job["location"]}",
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.timer,
                                            size: 18,
                                            color: Colors.blueGrey,
                                          ),
                                          const SizedBox(width: 8),
                                          Text("Duration: ${job["duration"]}"),
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
                                          Text("Date: ${job["date"]}"),
                                          const SizedBox(width: 16),
                                          const Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Colors.blueGrey,
                                          ),
                                          const SizedBox(width: 8),
                                          Text("Time: ${job["time"]}"),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () => _rejectJob(index),
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
                                            onPressed: () => _acceptJob(index),
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
                      ),
              ),
            ),

            // ✅ Bottom navigation
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
                  _bottomNavButton(Icons.list, "My Jobs", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LabourJobScreen(acceptedJobs: _acceptedJobs),
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

  // ✅ Profile Dialog
  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<Map<String, dynamic>?>(
                  future: fetchLabourDetails(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final labour = snapshot.data;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(ctx);
                                context.push('/role-registration/labour');
                              },
                              child: const Icon(
                                Icons.edit,
                                color: Color(0xFF00ACC1),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(ctx),
                              child: const Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: const Color(0xFF80DEEA),
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                              child: _profileImage == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _pickProfileImage(setDialogState),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00BCD4),
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
                        Text(
                          labour?['name'] ?? "Labour Name",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Speciality: ${labour?['skill'] ?? "General Farm Work"}",
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Contact: ${labour?['phone'] ?? "+94 77 123 4567"}",
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00ACC1),
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
                        const SizedBox(height: 2),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.go('/signin');
                          },
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: const Color(0xFF00ACC1)),
                          ),
                        ),
                      ],
                    );
                  },
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
          backgroundColor: const Color(0xFF00BCD4),
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

  @override
  void dispose() {
    _labourSubscription?.cancel();
    super.dispose();
  }
}
