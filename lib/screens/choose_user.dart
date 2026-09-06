import 'package:flutter/material.dart';
import 'package:flutterapk/screens/donarhome_screen.dart';
import 'package:flutterapk/screens/ngohome_screen.dart';
import 'package:flutterapk/screens/signin_screen.dart';
import 'package:flutterapk/services/app_state.dart';

class chooseUser extends StatefulWidget {
  const chooseUser({super.key});

  @override
  State<chooseUser> createState() => _chooseUserState();
}

class _chooseUserState extends State<chooseUser> {
  bool _isLoading = false;

  void _logout() {
    AppState.instance.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = AppState.instance.currentUserName.isNotEmpty
        ? AppState.instance.currentUserName
        : "User";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'WeFeed - Select Your Role',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 2,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/images/food.png',
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome, $userName!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select how you would like to participate today',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildRoleCard(
                    title: "Food Donor",
                    subtitle: "List and donate surplus food with photos, quantity, expiry time & pickup location.",
                    icon: Icons.volunteer_activism,
                    color: Colors.green.shade600,
                    onTap: _navigateToDonor,
                  ),
                  const SizedBox(height: 20),
                  _buildRoleCard(
                    title: "NGO / Receiver",
                    subtitle: "Browse available food donations in real time, claim orders & arrange volunteer pickups.",
                    icon: Icons.groups_3_rounded,
                    color: Colors.orange.shade800,
                    onTap: _navigateToNgo,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, color: Colors.deepPurple, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Designed by Ganesh Kothule",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDonor() async {
    setState(() => _isLoading = true);
    AppState.instance.currentRole = 'donor';
    await Future.delayed(const Duration(milliseconds: 250));
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DonarHomeScreen()),
      );
      setState(() => _isLoading = false);
    }
  }

  void _navigateToNgo() async {
    setState(() => _isLoading = true);
    AppState.instance.currentRole = 'ngo';
    await Future.delayed(const Duration(milliseconds: 250));
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NgoHomeScreen()),
      );
      setState(() => _isLoading = false);
    }
  }
}