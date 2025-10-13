import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverTripsPage extends StatefulWidget {
  final List<Map<String, String>>? acceptedTrips; // optional parameter
  const DriverTripsPage({super.key, this.acceptedTrips});

  @override
  State<DriverTripsPage> createState() => _DriverTripsPageState();
}

class _DriverTripsPageState extends State<DriverTripsPage> {
  String? statusFilter;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    Query tripsQuery = FirebaseFirestore.instance
        .collection('trips')
        .where('driverId', isEqualTo: uid)
        .orderBy('date', descending: true);

    if (statusFilter != null) {
      tripsQuery = tripsQuery.where('status', isEqualTo: statusFilter);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9800),
        title: Text(
          statusFilter != null
              ? "${statusFilter![0].toUpperCase()}${statusFilter!.substring(1)} Trips"
              : "My Trips",
          style: TextStyle(color: Colors.white),
        ),

        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: tripsQuery.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final trips = snapshot.data!.docs;

          if (trips.isEmpty) {
            return const Center(
              child: Text(
                "No trips found",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index].data()! as Map<String, dynamic>;
              final status = trip['status'] ?? 'pending';
              Color statusColor;

              switch (status) {
                case 'completed':
                  statusColor = Colors.green;
                  break;
                case 'cancelled':
                  statusColor = Colors.red;
                  break;
                default:
                  statusColor = Colors.orange;
              }

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
                      Text(
                        trip['title'] ?? 'Trip',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 6),
                          Text(trip['date'] ?? ''),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 6),
                          Text(trip['time'] ?? ''),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 18,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Expanded(child: Text(trip['location'] ?? '')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.work,
                            size: 18,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          Text("Vehicle: ${trip['vehicleType'] ?? '-'}"),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          status.toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: statusColor,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
