// ignore_for_file: use_key_in_widget_constructors, unrelated_type_equality_checks, prefer_const_constructors

import 'package:google_fonts/google_fonts.dart';
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
    return Material(
      elevation: 30,
      shadowColor: Colors.red,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(width: 0.9, color: Colors.grey))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: tabs
              .map((e) => Expanded(
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: InkWell(
                            onTap: () {
                              return onSelectTab(tabs.indexOf(e));
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  e.icon.toString(),
                                  scale: 27,
                                  color:
                                      DashboardState.currentTab == e.getIndex()
                                          ? Colors.teal[800]
                                          : Colors.grey,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  e.tabName,
                                  style:
                                      DashboardState.currentTab == e.getIndex()
                                          ? GoogleFonts.montserrat(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.teal[800])
                                          : GoogleFonts.montserrat(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey),
                                )
                              ],
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.linear,
                          height: 3,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: DashboardState.currentTab == e.getIndex()
                                  ? Colors.teal[800]
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10))),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
    // return BottomNavigationBar(
    //   type: BottomNavigationBarType.fixed,
    //   selectedItemColor: Colors.black,
    //   unselectedItemColor: Colors.grey,
    //   selectedFontSize: 13,
    //   unselectedFontSize: 13,
    //   selectedLabelStyle: TextStyle(fontWeight: FontWeight.w800),
    //   currentIndex: DashboardState.currentTab,
    //   showSelectedLabels: true,
    //   items: tabs
    //       .map((e) => BottomNavigationBarItem(
    //             icon: Padding(
    //                 padding: const EdgeInsets.only(
    //                   bottom: 5,
    //                 ),
    //                 child: Image.asset(
    //                   e.icon.toString(),
    //                   scale: 30,
    //                   color: DashboardState.currentTab == e.getIndex()
    //                       ? Colors.black
    //                       : Colors.grey,
    //                 )),
    //             label: e.tabName,
    //           ))
    //       .toList(),
    //   onTap: (index) {
    //     // if (index == 2) {
    //     //   Provider.of<UpdateCartData>(context, listen: false)
    //     //       .changeSearchView();
    //     // } else {
    //     return onSelectTab(
    //       index,
    //     );
    //     // }
    //   },
    // );
  }
}
