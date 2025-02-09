import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../../../core/utils/navigation_helper.dart';
import '../../../core/constants/routes.dart';
import '../services/profile_service.dart';
import '../widgets/profile_details_row.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () async {
              var userData = await _profileService.getUserProfile();

              if (!context.mounted) return;
              await NavigationHelper.pushNamed(
                context,
                AppRoutes.editProfile,
                arguments: userData!.data()!,
              );

              setState(() {});
            },
            icon: const Icon(Icons.edit),
            color: Colors.white,
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 120.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade700,
                          Colors.deepPurpleAccent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundImage: data['profile_photo_url'] != ""
                            ? NetworkImage(data['profile_photo_url'])
                            : const AssetImage('assets/default_profile.png')
                                as ImageProvider,
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    data['name'] != "" ? data['name'] : 'Anonymous',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['email'],
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black.withValues(alpha: 0.2),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileDetailsRow(
                            title: 'Username',
                            value: data['username'],
                            iconData: HeroIcons.user,
                          ),
                          const Divider(thickness: 0.2, color: Colors.white),
                          ProfileDetailsRow(
                            title: 'Age',
                            value: data['age'] != "-"
                                ? data['age']
                                : 'Not specified',
                            iconData: FontAwesome.calendar,
                          ),
                          const Divider(thickness: 0.2, color: Colors.white),
                          ProfileDetailsRow(
                            title: 'Gender',
                            value: data['gender'] != "-"
                                ? data['gender']
                                : 'Not specified',
                            iconData: Bootstrap.gender_ambiguous,
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
}
