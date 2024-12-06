import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../auth/LoginScreen.dart';
import '../orders/OrderConfirmationScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "Welcome";
  String email = "Loading...";
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      if (currentUser != null) {
        email = currentUser!.email ?? 'No Email';

        if (currentUser!.displayName != null &&
            currentUser!.displayName!.isNotEmpty) {
          username = currentUser!.displayName!;
        }
        else {

          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .get();

          if (userDoc.exists) {
            username = userDoc['username'] ?? 'User';
          } else {
            username = 'User';
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      username = 'Error';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF15203D),
        body: currentUser == null
            ? const Center(
          child: Text(
            'No user logged in.',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
            : SingleChildScrollView(
          child: Column(
            children: [
              // Display User Info
              Container(
                padding: EdgeInsets.all(screenSize.width * 0.05),
                child: Column(
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: screenSize.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Options Section
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.05),
                child: Column(
                  children: [
                    _buildProfileOption(
                      context,
                      icon: Icons.privacy_tip,
                      title: 'Privacy Policy',
                      onTap: () {
                        // Navigate to Privacy Policy
                      },
                    ),
                    _buildProfileOption(
                      context,
                      icon: Icons.history,
                      title: 'My Order',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderConfirmationScreen(
                              userId: currentUser!.uid,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildProfileOption(
                      context,
                      icon: Icons.location_on,
                      title: 'Shipping Address',
                      onTap: () {
                        // Navigate to Shipping Address
                      },
                    ),
                    _buildProfileOption(
                      context,
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        // Navigate to Settings
                      },
                    ),
                    _buildProfileOption(
                      context,
                      icon: Icons.logout,
                      title: 'Log out',
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context,
      {required IconData icon,
        required String title,
        required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue.withOpacity(0.2),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
