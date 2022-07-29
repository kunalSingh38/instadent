// ignore_for_file: use_key_in_widget_constructors, unrelated_type_equality_checks, prefer_const_constructors

import 'package:instadent/UpdateCart.dart';
import 'package:provider/provider.dart';

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
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 13,
      unselectedFontSize: 13,
      currentIndex: DashboardState.currentTab,
      items: tabs
          .map((e) => BottomNavigationBarItem(
                icon: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Image.asset(
                      e.icon.toString(),
                      scale: 30,
                      color: DashboardState.currentTab == e.getIndex()
                          ? Colors.black
                          : Colors.grey,
                    )),
                label: e.tabName,
              ))
          .toList(),
      onTap: (index) {
        if (index == 2) {
          Provider.of<UpdateCartData>(context, listen: false)
              .changeSearchView();
        } else {
          return onSelectTab(
            index,
          );
        }
      },
    );
  }
}
