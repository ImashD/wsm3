// stores.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  GoogleMapController? _mapController;

  // Mock store data
  final List<Map<String, dynamic>> stores = [
    {
      "name": "Kurunegala Central Store",
      "owner": "Mr. Perera",
      "address": "No. 12, Main Road, Kurunegala",
      "capacity": "500 MT",
      "status": "Active",
      "lat": 7.4863,
      "lng": 80.3623,
    },
    {
      "name": "Anuradhapura Paddy Store",
      "owner": "Mr. Silva",
      "address": "New Town, Anuradhapura",
      "capacity": "300 MT",
      "status": "Under Maintenance",
      "lat": 8.3114,
      "lng": 80.4037,
    },
    {
      "name": "Polonnaruwa Main Store",
      "owner": "Ms. Kumari",
      "address": "Market Road, Polonnaruwa",
      "capacity": "450 MT",
      "status": "Active",
      "lat": 7.9403,
      "lng": 81.0188,
    },
  ];

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  void _loadMarkers() {
    for (var store in stores) {
      _markers.add(
        Marker(
          markerId: MarkerId(store["name"]),
          position: LatLng(store["lat"], store["lng"]),
          infoWindow: InfoWindow(
            title: store["name"],
            snippet: store["address"],
            onTap: () => _showStoreDetails(context, store),
          ),
        ),
      );
    }
    setState(() {});
  }

  void _moveToStore(Map<String, dynamic> store) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(store["lat"], store["lng"]), 14),
    );
    _showStoreDetails(context, store);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Store Locations",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009688),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: const CameraPosition(
              target: LatLng(7.8731, 80.7718), // Center of Sri Lanka
              zoom: 7,
            ),
            markers: _markers,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
          ),

          // Autocomplete search bar (top)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Autocomplete<Map<String, dynamic>>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable.empty();
                }
                return stores.where(
                  (store) => store["name"].toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },
              displayStringForOption: (store) => store["name"],
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: "Search store by name...",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
              onSelected: (store) {
                _moveToStore(store);
              },
            ),
          ),

          // "View Stores" button (bottom center)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.list),
                label: const Text(
                  "View Stores",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) {
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: stores.map((store) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(
                                Icons.store,
                                color: Colors.teal,
                              ),
                              title: Text(store["name"]),
                              subtitle: Text(store["address"]),
                              trailing: Icon(
                                Icons.circle,
                                color: store["status"] == "Active"
                                    ? Colors.green
                                    : Colors.red,
                                size: 14,
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                _moveToStore(store);
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📌 Attractive popup store details
  void _showStoreDetails(BuildContext context, Map<String, dynamic> store) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.store, size: 40, color: Colors.black),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      store["name"],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.teal, height: 20),
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(
                    "Owner: ${store["owner"]}",
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.teal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Address: ${store["address"]}",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.storage, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(
                    "Capacity: ${store["capacity"]}",
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.info,
                    color: store["status"] == "Active"
                        ? Colors.greenAccent
                        : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Status: ${store["status"]}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: store["status"] == "Active"
                          ? Colors.greenAccent
                          : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.teal,
                  ),
                  child: const Text("Close"),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
