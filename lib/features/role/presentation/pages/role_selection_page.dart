import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  bool _isLoading = false;

  /// Check if the current user is already registered in Firestore for a role
  Future<bool> _isUserRegistered(UserRole role, String uid) async {
    late DocumentSnapshot doc;

    switch (role) {
      case UserRole.farmer:
        doc = await FirebaseFirestore.instance
            .collection('farmers')
            .doc(uid)
            .get();
        break;
      case UserRole.driver:
        doc = await FirebaseFirestore.instance
            .collection('drivers')
            .doc(uid)
            .get();
        break;
      case UserRole.labour:
        doc = await FirebaseFirestore.instance
            .collection('labours')
            .doc(uid)
            .get();
        break;
    }

    return doc.exists;
  }

  Future<void> _handleRoleTap(UserRole role) async {
    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      final isRegistered = await _isUserRegistered(role, uid);

      if (!mounted) return;

      if (isRegistered) {
        // Already registered → go to dashboard
        await AuthService().setUserRole(role);

        context.push('/dashboard/${role.name}');
      } else {
        // Not registered → go to registration page
        switch (role) {
          case UserRole.farmer:
            context.push('/role-registration/farmer/step1');
            break;
          case UserRole.driver:
            context.push('/role-registration/driver');
            break;
          case UserRole.labour:
            context.push('/role-registration/labour');
            break;
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildRoleCard({
    required String imagePath,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color overlayColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: Colors.black26,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  overlayColor.withOpacity(0.75),
                  overlayColor.withOpacity(0.45),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: Icon(icon, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF99F6E4)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                      "Choose Your Role",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Select the option that best describes you.\n(You can switch roles later)",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    else
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildRoleCard(
                              imagePath: "assets/farmersR.png",
                              icon: Icons.agriculture,
                              title: "Farmer",
                              subtitle: "Manage your crops and livestock.",
                              overlayColor: Colors.teal.shade600,
                              onTap: () => _handleRoleTap(UserRole.farmer),
                            ),
                            _buildRoleCard(
                              imagePath: "assets/laborsR.png",
                              icon: Icons.work,
                              title: "Labour",
                              subtitle: "Find agricultural work opportunities.",
                              overlayColor: Colors.blue.shade600,
                              onTap: () => _handleRoleTap(UserRole.labour),
                            ),
                            _buildRoleCard(
                              imagePath: "assets/driversR.png",
                              icon: Icons.local_shipping,
                              title: "Driver",
                              subtitle: "Offer transport services.",
                              overlayColor: Colors.orange.shade600,
                              onTap: () => _handleRoleTap(UserRole.driver),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
