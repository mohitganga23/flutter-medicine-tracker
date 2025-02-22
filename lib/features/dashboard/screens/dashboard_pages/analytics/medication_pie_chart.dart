import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MedicationTrackingScreen extends StatelessWidget {
  const MedicationTrackingScreen({super.key});

  Future<Map<String, Map<String, int>>> calculateMedicationStats() async {
    try {
      String userEmail = FirebaseAuth.instance.currentUser!.email!;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      QuerySnapshot<Map<String, dynamic>> trackingSnapshot = await firestore
          .collection('medications')
          .doc(userEmail)
          .collection('user_medications')
          .get();

      Map<String, Map<String, int>> medicationStats = {};

      DateTime today = DateTime.now();

      for (var doc in trackingSnapshot.docs) {
        String medicationName = doc['medication_name'];
        List<dynamic> dosages = doc['dosages'] ?? [];
        DateTime createdAt = (doc['created_at'] as Timestamp).toDate();

        int taken = 0;
        int missed = 0;

        for (var dosage in dosages) {
          String dosageTime = dosage['time']; // Example: "11:00 AM"
          List<dynamic> tracked =
              dosage.containsKey('tracked') ? dosage['tracked'] : [];

          Set<String> trackedDates = {}; // Stores only taken/missed dates

          for (var entry in tracked) {
            if (entry.containsKey('dateTime') && entry.containsKey('status')) {
              DateTime trackedDateTime =
                  (entry['dateTime'] as Timestamp).toDate();
              String dateOnly =
                  trackedDateTime.toString().substring(0, 10); // "YYYY-MM-DD"

              if (entry['status'] == 'taken') {
                taken++;
              } else if (entry['status'] == 'missed') {
                missed++;
              }

              trackedDates.add(dateOnly); // Store tracked dates
            }
          }

          // Now check for missing dates
          for (DateTime date = createdAt;
              date.isBefore(today) || date.isAtSameMomentAs(today);
              date = date.add(Duration(days: 1))) {
            String dateString =
                date.toString().substring(0, 10); // "YYYY-MM-DD"

            if (!trackedDates.contains(dateString)) {
              missed++; // If not tracked, mark as missed
            }
          }
        }

        medicationStats[medicationName] = {'taken': taken, 'missed': missed};
      }

      return medicationStats;
    } catch (e) {
      print("Error fetching tracking data: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medication Tracking")),
      body: Center(
        child: FutureBuilder<Map<String, Map<String, int>>>(
          future: calculateMedicationStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const Text("No data available");
            }

            return MedicationBarChart(data: snapshot.data!);
          },
        ),
      ),
    );
  }
}

class MedicationBarChart extends StatelessWidget {
  final Map<String, Map<String, int>> data;

  const MedicationBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    int index = 0;

    data.forEach((medication, counts) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barsSpace: 12, // Increased space between bars
          barRods: [
            // Taken Dosages (Gradient Green)
            BarChartRodData(
              toY: counts['taken']!.toDouble(),
              gradient: LinearGradient(
                colors: [Colors.green.shade300, Colors.green.shade700],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              width: 16, // Thicker bars
              borderRadius: BorderRadius.circular(6),
            ),
            // Missed Dosages (Gradient Red)
            BarChartRodData(
              toY: counts['missed']!.toDouble(),
              gradient: LinearGradient(
                colors: [Colors.red.shade300, Colors.red.shade700],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              width: 16,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
          showingTooltipIndicators: [0, 1], // Show tooltips for both bars
        ),
      );
      index++;
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawHorizontalLine: true),
          // Show grid for better readability
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text("Dosage Count",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text("Medications",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Transform.rotate(
                    angle: -0.4, // Tilt labels for readability
                    child: Text(
                      data.keys.elementAt(value.toInt()),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
                reservedSize: 50, // Avoid overlap
              ),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: false,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.black.withOpacity(0.7),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  "${data.keys.elementAt(group.x)}\n",
                  const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: rodIndex == 0 ? "Taken: " : "Missed: ",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    TextSpan(
                      text: "${rod.toY.toInt()}",
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
