import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'job_screen.dart';
import '../../../../core/services/auth_service.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Stream<QuerySnapshot> _pendingJobsStream() {
    return FirebaseFirestore.instance
        .collection('labour_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  final List<Map<String, String>> _acceptedJobs = [];

  Future<void> _acceptJob(
    Map<String, dynamic> jobData,
    String requestId,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Update the labour_requests document
    await FirebaseFirestore.instance
        .collection('labour_requests')
        .doc(requestId)
        .update({
          'status': 'accepted',
          'workerId': uid,
          'workerContact': await _getLabourPhone(uid),
        });

    // Add to labour's myJobs
    await FirebaseFirestore.instance
        .collection('labours')
        .doc(uid)
        .collection('myJobs')
        .doc(requestId)
        .set(jobData);

    // Update farmer's myRequests
    await FirebaseFirestore.instance
        .collection('farmers')
        .doc(jobData['farmerId'])
        .collection('myRequests')
        .doc(requestId)
        .update({'status': 'accepted'});

    setState(() {
      _acceptedJobs.add(
        jobData.map((key, value) => MapEntry(key, value.toString())),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Accepted job from ${jobData['farmerName']}")),
    );
  }

  Future<void> _rejectJob(String requestId, String farmerName) async {
    await FirebaseFirestore.instance
        .collection('labour_requests')
        .doc(requestId)
        .update({'status': 'rejected'});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Rejected job from $farmerName")));
  }

  Future<String> _getLabourPhone(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('labours')
        .doc(uid)
        .get();
    return doc.data()?['phone'] ?? '';
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: _pendingJobsStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());
                    final jobs = snapshot.data!.docs;
                    if (jobs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No job requests available",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        final doc = jobs[index];
                        final job = doc.data() as Map<String, dynamic>;
                        final requestId = doc.id;

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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.work,
                                          size: 18,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Instructions: ${job['instructions']}",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
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
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Duration: ${job['numOfDays']} day(s)",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.monetization_on,
                                          size: 18,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Wage: Rs.${job['wage']}",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
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
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Date: ${job['date'].toDate()}",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          size: 18,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () async {
                                            final url =
                                                'tel:${job['farmerPhone']}';
                                            if (await canLaunchUrl(
                                              Uri.parse(url),
                                            )) {
                                              await launchUrl(Uri.parse(url));
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Cannot launch phone dialer",
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            job['farmerPhone'] ?? "0772578614",

                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => _rejectJob(
                                            requestId,
                                            job['farmerName'],
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
                                              _acceptJob(job, requestId),
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
                        builder: (_) => const LabourJobScreen(),
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
                        Text("Contact: ${labour?['phone'] ?? "0761602451"}"),
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
