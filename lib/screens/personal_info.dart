// lib/screens/personal_info_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  String name = '';
  String email = '';
  String phone = '';
  // DateTime date='' as DateTime;

  @override
  void initState() {
    super.initState();
    fetchPersonalInfo();
  }

  Future<void> fetchPersonalInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
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
          name = data['name'] ?? '';
          email = data['email'] ?? '';
          phone = data['phone'] ?? '';
          // date =data['date']?? "" as DateTime;
        });
      } else {
        print('Failed to fetch user details: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Personal Information")),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      body: name.isEmpty && email.isEmpty && phone.isEmpty
    ? const Center(child: CircularProgressIndicator())
    : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 100,
              backgroundImage: AssetImage('assets/images/profile_logo.png'), // Replace with your image path
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 24),
          _infoCard(Icons.person, 'Name', name),
          const SizedBox(height: 16),
          _infoCard(Icons.email, 'Email', email),
          const SizedBox(height: 16),
          _infoCard(Icons.phone, 'Phone', phone),
          const SizedBox(height: 16),
          // _infoCard(Icons.calendar_today, 'Created Date', date.toString().split(' ')[0]),
        ],
      ),

floatingActionButton: FloatingActionButton.extended(
  onPressed: () {
    Navigator.pushNamed(context, '/updateDetails'); // Define route accordingly
  },
  label: const Text('Update Details'),
  icon: const Icon(Icons.edit),
  backgroundColor: Colors.green.shade700,
),

    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade700),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

}
