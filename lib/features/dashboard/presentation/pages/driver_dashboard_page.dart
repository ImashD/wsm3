import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wsm3/features/dashboard/presentation/pages/trips_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverDashboardPage extends StatefulWidget {
  const DriverDashboardPage({super.key});

  @override
  State<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  String? _profileImageUrl;
  bool _isAvailable = false;
  Map<String, dynamic>? _driverData;
  final List<Map<String, String>> _acceptedTrips = [];
  StreamSubscription<DocumentSnapshot>? _driverSubscription;

  @override
  void initState() {
    super.initState();
    _listenToDriverData();
  }

  @override
  void dispose() {
    _driverSubscription?.cancel();
    super.dispose();
  }

  void _listenToDriverData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _driverSubscription = FirebaseFirestore.instance
        .collection('drivers')
        .doc(uid)
        .snapshots()
        .listen((doc) async {
          if (doc.exists) {
            setState(() {
              _driverData = doc.data();
              _isAvailable = doc['available'] ?? false;
            });
          } else {
            await FirebaseFirestore.instance.collection('drivers').doc(uid).set(
              {'available': false},
            );
            setState(() => _isAvailable = false);
          }
        });
  }

  Future<void> _toggleAvailability(bool value) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isAvailable = value);
    await FirebaseFirestore.instance.collection('drivers').doc(uid).set({
      'available': value,
    }, SetOptions(merge: true));
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            context.push('/role-registration/driver');
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
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final pickedFile = await _picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (pickedFile != null) {
                              setState(
                                () => _profileImage = File(pickedFile.path),
                              );
                              setDialogState(() {});
                            }
                          },
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: const Color(0xFFFFB74D),
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : (_profileImageUrl != null
                                          ? NetworkImage(_profileImageUrl!)
                                          : null)
                                      as ImageProvider?,
                            child:
                                (_profileImage == null &&
                                    _profileImageUrl == null)
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFF9800),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _driverData?['fullName'] ?? "Driver Name",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Vehicle: ${_driverData?['vehicleType'] ?? '-'}"),
                    Text("Vehicle No: ${_driverData?['vehicleno'] ?? '-'}"),
                    Text("Contact: ${_driverData?['phone'] ?? '-'}"),
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
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.go('/signin');
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Color(0xFFFF9800)),
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

  Widget _tripRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tripButton(
    String label,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _bottomNavButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFFFB74D),
          radius: 24,
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
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
                          onPressed: () => context.go('/role-selection'),
                        ),
                      ),
                    ),
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
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFFFFB74D),
                            child: Icon(Icons.person, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🔸 Tagline
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFFFB74D),
              ),
              child: const Text(
                "තිරසාර ගොවිතැනට නව සවියක්\nSmart farming Starts here\nஸ்மார்ட் விவசாயம் இங்கே தொடங்குகிறது",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),

            // Availability Switch
            SwitchListTile(
              title: const Text(
                "Available for Trips",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              value: _isAvailable,
              onChanged: (val) => _toggleAvailability(val),
              activeColor: Colors.black,
              activeTrackColor: const Color(0xFFFF9800),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('trip_requests')
                      .where('status', isEqualTo: 'pending')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final trips = snapshot.data!.docs;
                    if (trips.isEmpty) {
                      return const Center(
                        child: Text(
                          "No trip requests available",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: trips.length,
                      itemBuilder: (context, index) {
                        final trip = trips[index];
                        final data = trip.data() as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _tripRow(
                                  Icons.location_on,
                                  "Pickup: ${data['pickup'] ?? '-'}",
                                ),
                                _tripRow(
                                  Icons.location_on,
                                  "Drop-off: ${data['dropoff'] ?? '-'}",
                                ),
                                _tripRow(
                                  Icons.local_shipping,
                                  "Quantity: ${data['quantity'] ?? '0'} MT",
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
                                      onTap: () => _makePhoneCall(
                                        data['contactNumber'] ?? '',
                                      ),
                                      child: Text(
                                        "${data['contactNumber'] ?? '-'}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFF9800),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _tripButton(
                                      "Reject",
                                      Colors.redAccent,
                                      Icons.close,
                                      () async {
                                        await FirebaseFirestore.instance
                                            .collection('trip_requests')
                                            .doc(trip.id)
                                            .update({'status': 'rejected'});
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    _tripButton(
                                      "Accept",
                                      Colors.green,
                                      Icons.check,
                                      () async {
                                        final driverUid = FirebaseAuth
                                            .instance
                                            .currentUser
                                            ?.uid;
                                        if (driverUid == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Driver not logged in",
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        final driverDoc =
                                            await FirebaseFirestore.instance
                                                .collection('drivers')
                                                .doc(driverUid)
                                                .get();
                                        final driverData =
                                            driverDoc.data() ?? {};

                                        final driverName =
                                            driverData['fullName'] ??
                                            'Unknown Driver';
                                        final driverContact =
                                            driverData['phone'] ?? 'N/A';

                                        await FirebaseFirestore.instance
                                            .collection('trip_requests')
                                            .doc(trip.id)
                                            .update({
                                              'status': 'accepted',
                                              'driverId': driverUid,
                                              'driverName': driverName,
                                              'driverContact': driverContact,
                                            });

                                        await FirebaseFirestore.instance
                                            .collection('trips')
                                            .add({
                                              'pickup': data['pickup'] ?? '-',
                                              'dropoff': data['dropoff'] ?? '-',
                                              'quantity':
                                                  data['quantity'] ?? '0',
                                              'contactNumber':
                                                  data['contactNumber'] ?? '-',
                                              'driverId': driverUid,
                                              'status': 'accepted',
                                              'date': DateTime.now().toString(),
                                              'time': TimeOfDay.now().format(
                                                context,
                                              ),
                                            });

                                        setState(() {
                                          _acceptedTrips.add({
                                            "pickup": data['pickup'] ?? '-',
                                            "dropoff": data['dropoff'] ?? '-',
                                            "quantity": data['quantity'] ?? '0',
                                            "contactNumber":
                                                data['contactNumber'] ?? '-',
                                          });
                                        });

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Trip accepted successfully",
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

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
                        builder: (_) => const DriverTripsPage(),
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
}
