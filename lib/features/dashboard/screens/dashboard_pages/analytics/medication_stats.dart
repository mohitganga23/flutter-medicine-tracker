import 'package:flutter/material.dart';
import 'package:flutter_medicine_tracker/features/medication/services/medication_service.dart';
import 'package:horizontal_week_calendar/horizontal_week_calendar.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class MedicationStatsWidget extends StatefulWidget {
  final MedicationService medicationService = MedicationService();

  MedicationStatsWidget({super.key});

  @override
  MedicationStatsWidgetState createState() => MedicationStatsWidgetState();
}

class MedicationStatsWidgetState extends State<MedicationStatsWidget> {
  String? _selectedDateKey;
  Map<String, List<Map<String, dynamic>>>? _selectedDailyStats;
  DateTime? _selectedDate;
  late Future<Map<String, dynamic>> _statsFuture;
  Map<String, Map<String, List<Map<String, dynamic>>>>? _dateWiseStats;
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateKey = DateFormat('yyyy-MM-dd').format(now);
    _selectedDate = now;
    _statsFuture = widget.medicationService.calculateMedicationStats();
  }

  void _updateSelectedDate(DateTime selectedDate) {
    setState(() {
      _isLoadingDetails = true;
      _selectedDate = selectedDate;
      _selectedDateKey = DateFormat('yyyy-MM-dd').format(selectedDate);
      _selectedDailyStats = _dateWiseStats?[_selectedDateKey];
      _isLoadingDetails = false;
    });
  }

  Color _getDayStatusColor(String dateKey) {
    final dailyStats = _dateWiseStats?[dateKey];
    if (dailyStats == null || dailyStats.isEmpty) return Colors.grey;
    bool hasMissed = dailyStats.values.any((dosages) =>
        dosages.any((d) => d['status'] == 'missed'));
    return hasMissed ? Colors.red : Colors.green;
  }

  void _showPieChartDialog(BuildContext context, String medicationName) {
    // Aggregate data for this medication across all dates up to today
    int takenCount = 0;
    int missedCount = 0;
    int pendingCount = 0;

    final now = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(now);

    _dateWiseStats?.forEach((dateKey, dailyStats) {
      // Only include dates up to today
      if (DateTime.parse(dateKey).isBefore(now) || dateKey == todayKey) {
        final dosages = dailyStats[medicationName];
        if (dosages != null) {
          takenCount += dosages.where((d) => d['status'] == 'taken').length;
          missedCount += dosages.where((d) => d['status'] == 'missed').length;
          pendingCount += dosages.where((d) => d['status'] == 'pending').length;
        }
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$medicationName - Overall Stats', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          height: 300,
          width: 300,
          child: takenCount + missedCount + pendingCount == 0
              ? const Center(child: Text('No data available'))
              : PieChart(
            PieChartData(
              sections: [
                if (takenCount > 0)
                  PieChartSectionData(
                    value: takenCount.toDouble(),
                    color: Colors.green,
                    title: 'Taken\n$takenCount',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                if (missedCount > 0)
                  PieChartSectionData(
                    value: missedCount.toDouble(),
                    color: Colors.red,
                    title: 'Missed\n$missedCount',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                if (pendingCount > 0)
                  PieChartSectionData(
                    value: pendingCount.toDouble(),
                    color: Colors.grey,
                    title: 'Pending\n$pendingCount',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medication Tracking"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Error loading stats or no data available'),
            );
          }

          final stats = snapshot.data!;
          _dateWiseStats ??= stats['dateWiseStats'] as Map<String, Map<String, List<Map<String, dynamic>>>>? ?? {};
          final summary = stats['summary'] as Map<String, dynamic>? ?? {};

          DateTime minDate;
          DateTime maxDate;
          DateTime initialDate;
          try {
            minDate = DateTime.parse(stats['dateRange']['start']);
            maxDate = DateTime.parse(stats['dateRange']['end']);
            final now = DateTime.now();

            if (maxDate.isAfter(now)) {
              maxDate = DateTime(now.year, now.month, now.day);
            }

            initialDate = _selectedDate ?? now;
            if (initialDate.isAfter(maxDate) || initialDate.isAtSameMomentAs(maxDate)) {
              initialDate = maxDate.subtract(const Duration(days: 1));
            }
            if (initialDate.isBefore(minDate) || initialDate.isAtSameMomentAs(minDate)) {
              initialDate = minDate.add(const Duration(days: 1));
            }

            if (!minDate.isBefore(initialDate)) {
              minDate = initialDate.subtract(const Duration(days: 1));
            }
            if (!initialDate.isBefore(maxDate)) {
              maxDate = initialDate.add(const Duration(days: 1));
            }

            _selectedDateKey ??= DateFormat('yyyy-MM-dd').format(initialDate);
            _selectedDailyStats ??= _dateWiseStats![_selectedDateKey];
          } catch (e) {
            return Center(
              child: Text('Error parsing dates: $e'),
            );
          }

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Taken',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                          Text('${summary['totalTaken'] ?? 0}'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Missed',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                          Text('${summary['totalMissed'] ?? 0}'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Compliance',
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                          Text('${summary['complianceRate'] ?? '0.0'}%'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              HorizontalWeekCalendar(
                minDate: minDate,
                maxDate: maxDate,
                initialDate: initialDate,
                onDateChange: (selectedDate) {
                  if (!selectedDate.isAfter(DateTime.now())) {
                    _updateSelectedDate(selectedDate);
                  }
                },
                weekStartFrom: WeekStartFrom.Monday,
                activeNavigatorColor: Colors.blue,
                monthColor: Colors.black,
                activeTextColor: Colors.black,
                inactiveTextColor: Colors.grey,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isLoadingDetails
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedDateKey != null)
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getDayStatusColor(_selectedDateKey!),
                                ),
                              ),
                              Text(
                                'Medications for $_selectedDateKey',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          )
                        else
                          const Text('Select a date to view medication details'),
                        const SizedBox(height: 16),
                        if (_selectedDailyStats != null && _selectedDailyStats!.isNotEmpty)
                          ..._selectedDailyStats!.entries.map((medEntry) {
                            final medicationName = medEntry.key;
                            final dosages = medEntry.value;
                            return GestureDetector(
                              onTap: () => _showPieChartDialog(context, medicationName),
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.medication, size: 20, color: Colors.blue),
                                          const SizedBox(width: 8),
                                          Text(
                                            medicationName,
                                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      ...dosages.map((dosage) {
                                        final time = dosage['time'];
                                        final status = dosage['status'];
                                        return ListTile(
                                          leading: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: status == 'taken'
                                                  ? Colors.green
                                                  : (status == 'missed' ? Colors.red : Colors.grey),
                                            ),
                                          ),
                                          title: Text('Dosage at $time'),
                                          trailing: Text(
                                            status.toString().toUpperCase(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: status == 'taken'
                                                  ? Colors.green
                                                  : (status == 'missed' ? Colors.red : Colors.grey),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList()
                        else if (_selectedDateKey != null)
                          const Text('No medication data for this date'),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, size: 10, color: Colors.green),
                    SizedBox(width: 4),
                    Text('Taken'),
                    SizedBox(width: 16),
                    Icon(Icons.circle, size: 10, color: Colors.red),
                    SizedBox(width: 4),
                    Text('Missed'),
                    SizedBox(width: 16),
                    Icon(Icons.circle, size: 10, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Pending'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}