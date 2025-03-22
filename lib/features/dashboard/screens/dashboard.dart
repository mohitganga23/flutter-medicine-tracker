import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_medicine_tracker/features/dashboard/screens/dashboard_pages/analytics/medication_stats.dart';
import 'package:icons_plus/icons_plus.dart';

import 'dashboard_pages/account/account.dart';
import 'dashboard_pages/analytics/medication_pie_chart.dart';
import 'dashboard_pages/home/home.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedBottomNavigationItem = 0;

  static const List<BottomNavigationBarItem> _bottomNavigationBarItems = [
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.home),
      label: "Home",
    ),
    BottomNavigationBarItem(
      icon: Icon(OctIcons.graph),
      label: "Analytics",
    ),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.person_alt_circle),
      label: "Account",
    ),
  ];

  static final List<Widget> _pages = [
    HomePage(),
    MedicationStatsWidget(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomNavigationItem,
        onTap: _onItemTapped,
        items: _bottomNavigationBarItems,
      ),
      body: _pages.elementAt(_selectedBottomNavigationItem),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedBottomNavigationItem = index);
  }
}
