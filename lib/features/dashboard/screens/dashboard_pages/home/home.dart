import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_medicine_tracker/features/dashboard/providers/home_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../core/utils/navigation_helper.dart';
import '../../../../medication/screens/add_medication.dart';
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
              NavigationHelper.push(context, const AddMedicationForm());
            },
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: homeProvider.getMedication(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
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
