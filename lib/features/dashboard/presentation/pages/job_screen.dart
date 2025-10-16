import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class LabourJobScreen extends StatefulWidget {
  const LabourJobScreen({super.key});

  @override
  State<LabourJobScreen> createState() => _LabourJobScreenState();
}

class _LabourJobScreenState extends State<LabourJobScreen>
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
        .collection('labour_requests')
        .doc(tripId)
        .update({'status': 'completed'});
  }

  @override
  Widget build(BuildContext context) {
    final labourUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: const Text(
          "My Jobs",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00ACC1),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
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
          _buildJobsStream(labourUid, 'accepted'),
          _buildJobsStream(labourUid, 'completed'),
        ],
      ),
    );
  }

  Widget _buildJobsStream(String? labourUid, String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('labour_requests')
          .where('workerId', isEqualTo: labourUid)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00ACC1)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              status == 'accepted'
                  ? "No accepted jobs yet"
                  : "No completed jobs yet",
              style: const TextStyle(fontSize: 17, color: Colors.black54),
            ),
          );
        }

        final jobs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final doc = jobs[index];
            final data = doc.data() as Map<String, dynamic>;

            final formattedDate = data['date'] != null
                ? DateFormat(
                    'yyyy-MM-dd',
                  ).format((data['date'] as Timestamp).toDate())
                : '-';

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
                          Colors.blue.shade50.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.15),
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
                                  color: Color(0xFFB2EBF2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.work,
                                  color: Color(0xFF00ACC1),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                status == 'accepted'
                                    ? "Ongoing Job"
                                    : "Completed Job",
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
                          _detailRow("Job", data["instructions"]),
                          _detailRow("Duration", "${data["numOfDays"]} day(s)"),
                          _detailRow("Wage", "Rs.${data["wage"]}"),
                          _detailRow("Date", formattedDate),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.phone, color: Color(0xFF00ACC1)),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  final phone =
                                      data['farmerPhone'] ?? '0774567890';
                                  if (phone.isNotEmpty) _launchCaller(phone);
                                },
                                child: Text(
                                  data['farmerPhone'] ?? '0774567890',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (status == 'accepted') ...[
                            const SizedBox(height: 12),
                            Center(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00ACC1),
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
