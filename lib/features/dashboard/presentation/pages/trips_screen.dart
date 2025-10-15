import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverTripsPage extends StatefulWidget {
  const DriverTripsPage({super.key});

  @override
  State<DriverTripsPage> createState() => _DriverTripsPageState();
}

class _DriverTripsPageState extends State<DriverTripsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _launchCaller(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _markAsCompleted(String tripId) async {
    await FirebaseFirestore.instance
        .collection('trip_requests')
        .doc(tripId)
        .update({'status': 'completed'});
  }

  @override
  Widget build(BuildContext context) {
    final driverUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: const Text(
          "My Trips",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF9800),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
        shadowColor: Colors.orangeAccent.withOpacity(0.5),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          tabs: const [
            Tab(text: "Accepted"),
            Tab(text: "Completed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTripsStream(driverUid, 'accepted'),
          _buildTripsStream(driverUid, 'completed'),
        ],
      ),
    );
  }

  Widget _buildTripsStream(String? driverUid, String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trip_requests')
          .where('driverId', isEqualTo: driverUid)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF9800)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              status == 'accepted'
                  ? "No accepted trips yet 🚛"
                  : "No completed trips yet ✅",
              style: const TextStyle(
                fontSize: 17,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        final trips = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final doc = trips[index];
            final data = doc.data() as Map<String, dynamic>;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 18),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.9),
                          Colors.orange.shade50.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFE0B2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.local_shipping,
                                  color: Color(0xFFFF9800),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                status == 'accepted'
                                    ? "Ongoing Trip"
                                    : "Completed Trip",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: status == 'accepted'
                                      ? Colors.green.shade50
                                      : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: status == 'accepted'
                                        ? const Color(0xFF388E3C)
                                        : const Color(0xFF1976D2),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _detailRow("Pickup", data["pickup"]),
                          _detailRow("Drop-off", data["dropoff"]),
                          _detailRow(
                            "Quantity",
                            "${data["quantity"] ?? '-'} MT",
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  final phone = data["contactNumber"] ?? '';
                                  if (phone.isNotEmpty) _launchCaller(phone);
                                },
                                icon: const Icon(
                                  Icons.phone,
                                  color: Color(0xFFFF9800),
                                  size: 20,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  final phone = data["contactNumber"] ?? '';
                                  if (phone.isNotEmpty) _launchCaller(phone);
                                },
                                child: Text(
                                  data["contactNumber"] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFFFF9800),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                          if (status == 'accepted') ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF43A047),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                ),
                                onPressed: () async {
                                  await _markAsCompleted(doc.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Trip marked as completed ✅",
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Color(0xFF43A047),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text(
                                  "Mark as Completed",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
