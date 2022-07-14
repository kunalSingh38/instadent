// ignore_for_file: use_key_in_widget_constructors

import 'dashboard.dart';
import 'package:flutter/material.dart';
import 'tabItem.dart';

class BottomNavigation extends StatelessWidget {
  BottomNavigation({
    required this.onSelectTab,
    required this.tabs,
  });
  final ValueChanged<int> onSelectTab;
  final List<TabItem> tabs;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 13,
        unselectedFontSize: 13,
        currentIndex: DashboardState.currentTab,
        items: tabs
            .map(
              (e) => _buildItem(
                index: e.getIndex(),
                icon: e.icon,
                tabName: e.tabName,
              ),
            )
            .toList(),
        onTap: (index) => onSelectTab(
          index,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildItem(
      {int? index, String? icon, String? tabName}) {
    return BottomNavigationBarItem(
      icon: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Image.asset(
            icon.toString(),
            scale: 30,
            color:
                DashboardState.currentTab == index ? Colors.black : Colors.grey,
          )),
      label: tabName,
    );
    // }
  }

  Color _tabColor({int? index}) {
    return DashboardState.currentTab == index ? Colors.black : Colors.grey;
  }
}
