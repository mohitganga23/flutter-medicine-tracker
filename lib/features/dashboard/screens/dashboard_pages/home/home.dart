import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/routes.dart';
import '../../../../../core/utils/navigation_helper.dart';
import '../../../providers/home_provider.dart';
import '../../../widgets/medication_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  loadNotifications() {
    Provider.of<HomeProvider>(context, listen: false).loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 90,
            automaticallyImplyLeading: false,
            title: const Text(
              "Dashboard",
              style: TextStyle(fontSize: 36),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            label: const Text("Add Medication"),
            icon: const Icon(Icons.add_outlined, size: 24),
            onPressed: () {
              NavigationHelper.pushNamed(context, AppRoutes.addMedication);
            },
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: homeProvider.getMedication(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesome.pills_solid, size: 60.h),
                        SizedBox(height: 10.h),
                        Text(
                          "No medications available."
                          "\nClick below to add medication.",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }
                return ListView(
                  children: snapshot.data!.docs.map((document) {
                    return MedicationCard(document: document);
                  }).toList(),
                );
              } else {
                return const Center(child: Text("No medications available"));
              }
            },
          ),
        );
      },
    );
  }
}
