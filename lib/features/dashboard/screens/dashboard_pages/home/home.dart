import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_medicine_tracker/core/constants/routes.dart';
import 'package:flutter_medicine_tracker/core/utils/navigation_helper.dart';
import 'package:flutter_medicine_tracker/features/dashboard/providers/home_provider.dart';
import 'package:flutter_medicine_tracker/features/dashboard/widgets/medication_card.dart';
import 'package:flutter_medicine_tracker/features/dashboard/widgets/no_medication_available.dart';
import 'package:provider/provider.dart';


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
            title: Text(
              "Dashboard",
              style: Theme.of(context).textTheme.headlineLarge,
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
                  return NoMedicationAvailable();
                }
                return ListView(
                  children: snapshot.data!.docs.map((document) {
                    return MedicationCard(document: document);
                  }).toList(),
                );
              } else {
                return NoMedicationAvailable();
              }
            },
          ),
        );
      },
    );
  }
}
