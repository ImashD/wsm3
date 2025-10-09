import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  final String phone = "+94 11 233 5414";
  final String email = "info@pmb.lk";
  final String address =
      "6th Floor, Housing Secretariate, Sir Chittampalam A. Gardiner Mw, Colombo 02";
  final String mapUrl =
      "https://www.google.com/maps/dir//WRJW%2B7P3,+Colombo/@6.9306223,79.7644006,12z/data=!4m8!4m7!1m0!1m5!1m1!1s0x3ae2596cd00a22df:0xe41779524bbd4959!2m2!1d79.8468561!2d6.930649?entry=ttu&g_ep=EgoyMDI1MDkxNy4wIKXMDSoASAFQAw%3D%3D";

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF009688),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Optional: Add logo image here
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Image.asset(
                "assets/pmb_logo.png",
                height: 100,
                fit: BoxFit.contain,
              ),
            ),

            const Text(
              "Paddy Marketing Board",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 36),

            // Phone
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.teal),
                title: Text(phone),
                subtitle: const Text(
                  "\nTap to call",
                  style: TextStyle(color: Colors.teal),
                ),
                onTap: () => _launchUrl("tel:$phone"),
              ),
            ),
            const SizedBox(height: 12),

            // Email
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.email, color: Colors.teal),
                title: Text(email),
                subtitle: const Text(
                  "\nTap to send email",
                  style: TextStyle(color: Colors.teal),
                ),
                onTap: () => _launchUrl("mailto:$email"),
              ),
            ),
            const SizedBox(height: 12),

            // Address
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.teal),
                title: Text(address),
                subtitle: const Text(
                  "\nTap to view on map",
                  style: TextStyle(color: Colors.teal),
                ),
                onTap: () => _launchUrl(mapUrl),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
