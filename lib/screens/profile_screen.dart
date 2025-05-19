import 'package:flutter/material.dart';
import 'package:happy_farm/main.dart';
import 'package:happy_farm/screens/order_screen.dart';
import 'package:happy_farm/screens/wishlist_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:happy_farm/screens/personal_info.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onBack;
  const ProfileScreen({super.key, required this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String email = '';
  String profileImage = '';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId'); // assume you stored it earlier
    final token = prefs.getString('token');

    if (userId != null && token != null) {
      final url = Uri.parse('https://api.sabbafarm.com/api/user/$userId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          name = data['name'] ?? 'Unknown';
          email = data['email'] ?? 'No email';
          print("Namemanoj:${name}");
        });
      } else {
        print('Failed to load profile: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(child: Text("My Profile")),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png', // Replace with your logo path
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 40),
            _buildOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
      child: Row(
        children: [
          // Profile Image with edit button
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/profile_logo.png'),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    final options = [
      {
        'icon': Icons.person_outlined,
        'title': 'Personal Information',
        'subtitle': 'Manage your personal details',
        'function': () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const PersonalInfoScreen(),
          ));
        }
      },
      {
        'icon': Icons.lock_outlined,
        'title': 'Security',
        'subtitle': 'Change password and security settings',
        'function': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                onBack: () => Navigator.pop(context),
              ),
            ),
          );
        }
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help & Support',
        'subtitle': 'Get assistance and answers',
        'function': () {
         Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                onBack: () => Navigator.pop(context),
              ),
            ),
          );
        }
      },
      {
        'icon': Icons.logout,
        'title': 'Logout',
        'subtitle': 'Sign out of your account',
        'function': () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs
              .clear(); // or use remove('userId') & remove('token') if needed

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      }
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          ...options.map((option) => _buildOptionTile(
                context,
                icon: option['icon'] as IconData,
                title: option['title'] as String,
                subtitle: option['subtitle'] as String,
                onTap: option['function'] as VoidCallback,
              )),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        // Handle navigation
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
