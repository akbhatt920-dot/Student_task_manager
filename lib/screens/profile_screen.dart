import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Header
          Container(
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 80, left: 24, right: 24, bottom: 24),
              child: Column(
                children: [
                  // Profile Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 60,
                          backgroundColor: Color(0xFF0F172A),
                          child: Icon(Icons.person, size: 60, color: Color(0xFF3B82F6)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Name and Info
                  Text(
                    currentUser?.email?.split('@').first ?? "Student User",
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentUser?.email ?? "No email",
                    style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  
                  // Live Stats Area using FutureBuilder
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance.collection('tasks').where('userId', isEqualTo: currentUser?.uid).get(),
                    builder: (context, snapshot) {
                      String totalCount = "-";
                      String completedCount = "-";
                      
                      if (snapshot.hasData) {
                        totalCount = snapshot.data!.docs.length.toString();
                        completedCount = snapshot.data!.docs.where((d) => (d.data() as Map)['isCompleted'] == true).length.toString();
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: _buildProfileStat("Tasks", totalCount, Icons.list_alt, const Color(0xFF3B82F6)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildProfileStat("Completed", completedCount, Icons.check_circle_outline, const Color(0xFF10B981)),
                          ),
                        ],
                      );
                    }
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Settings Options
                  _buildSettingsRow(Icons.settings_outlined, "Settings", onTap: () {}),
                  _buildSettingsRow(Icons.color_lens_outlined, "Appearance", onTap: () {}),
                  _buildSettingsRow(Icons.notifications_outlined, "Notifications", onTap: () {}),
                  const SizedBox(height: 16),
                  _buildSettingsRow(Icons.logout, "Log Out", isDestructive: true, onTap: () async {
                    await FirebaseAuth.instance.signOut();
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(IconData icon, String title, {bool isDestructive = false, required VoidCallback onTap}) {
    final color = isDestructive ? Colors.redAccent : Colors.white;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 16)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}