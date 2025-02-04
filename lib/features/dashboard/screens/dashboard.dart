import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dashboard_pages/account/account.dart';
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
      icon: Icon(CupertinoIcons.person_alt_circle),
      label: "Account",
    ),
  ];

  static const List<Widget> _pages = [HomePage(), AccountPage()];

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
