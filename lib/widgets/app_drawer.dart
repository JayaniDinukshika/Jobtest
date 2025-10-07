import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Add this import for secure storage

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logow.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Pinky Petals Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.amber),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.grid_view, color: Colors.grey),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/products');
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.grey),
            title: const Text('Cart'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/cart');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.grey),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          // Logout ListTile (updated to navigate to /welcome on success)
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              // Close the drawer first
              Navigator.pop(context);

              // Create secure storage instance
              final storage = const FlutterSecureStorage();

              // Perform logout
              try {
                // Sign out from Firebase
                await FirebaseAuth.instance.signOut();

                // Clear all cached login data (email, dates, etc.)
                await storage.deleteAll();

                // Show success snackbar BEFORE navigation (to ensure it displays)
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }

                // Navigate to welcome screen and remove all previous routes
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');


                }
              } catch (e) {
                // Handle logout error (e.g., network issue)
                if (context.mounted) {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     content: Text('Logout failed: $e'),
                  //     backgroundColor: Colors.red,
                  //   ),
                  // );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}