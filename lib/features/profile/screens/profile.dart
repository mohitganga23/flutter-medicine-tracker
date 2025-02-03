import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/navigation_helper.dart';
import '../services/profile_service.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final ProfileService _profileService = ProfileService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              var userData = await _profileService.getUserProfile();

              if (!context.mounted) return;
              await NavigationHelper.push(
                context,
                EditProfileScreen(userProfile: userData!.data()!),
              );

              setState(() {});
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>?>?>(
        future: _profileService.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          var data = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: data['profile_photo_url'] != ""
                        ? NetworkImage(data['profile_photo_url'])
                        : const AssetImage('assets/default_profile.png')
                            as ImageProvider,
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    data['name'] != "" ? data['name'] : 'Anonymous',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['email'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple[100],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.deepPurple[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildProfileDetailRow(
                            'Username',
                            data['username'],
                          ),
                          const Divider(thickness: 0.15, color: Colors.white),
                          buildProfileDetailRow(
                            'Age',
                            data['age'] != "-" ? data['age'] : 'Not specified',
                          ),
                          const Divider(thickness: 0.15, color: Colors.white),
                          buildProfileDetailRow(
                            'Gender',
                            data['gender'] != "-"
                                ? data['gender']
                                : 'Not specified',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildProfileDetailRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.deepPurple[200],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}
