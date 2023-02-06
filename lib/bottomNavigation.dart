// ignore_for_file: use_key_in_widget_constructors, unrelated_type_equality_checks, prefer_const_constructors

import 'dart:async';

import 'package:flutter_gif/flutter_gif.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:biz_sales_admin/UpdateCart.dart';
import 'package:provider/provider.dart';

import 'dashboard.dart';
import 'package:flutter/material.dart';
import 'tabItem.dart';

class BottomNavigation extends StatelessWidget {
  BottomNavigation(
      {required this.onSelectTab,
      required this.tabs,
      required this.controller0,
      required this.controller1,
      required this.controller2,
      required this.controller3,
      required this.controller4,
      required this.controller});
  final ValueChanged<int> onSelectTab;
  final List<TabItem> tabs;

  FlutterGifController controller0;
  FlutterGifController controller1;
  FlutterGifController controller2;
  FlutterGifController controller3;
  FlutterGifController controller4;
  FlutterGifController controller;
  @override
  Widget build(BuildContext context) {
    bool tap = false;

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
          children: tabs.map((e) {
            if (e.getIndex() == 0) {
              controller = controller0;
            } else if (e.getIndex() == 1) {
              controller = controller1;
            } else if (e.getIndex() == 2) {
              controller = controller2;
            } else if (e.getIndex() == 3) {
              controller = controller3;
            } else if (e.getIndex() == 4) {
              controller = controller4;
            }

            return Expanded(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: InkWell(
                      onTap: () {
                        if (e.getIndex() == 0) {
                          controller1.reset();
                          controller2.reset();
                          controller3.reset();
                          controller4.reset();
                          controller0.animateTo(40,
                              duration: const Duration(milliseconds: 1000));
                          //print(controller0.value);
                        } else if (e.getIndex() == 1) {
                          controller0.reset();
                          controller2.reset();
                          controller3.reset();
                          controller4.reset();
                          controller1.animateTo(40,
                              duration: const Duration(milliseconds: 1000));
                        } else if (e.getIndex() == 2) {
                          controller0.reset();
                          controller1.reset();
                          controller3.reset();
                          controller4.reset();
                          controller2.animateTo(40,
                              duration: const Duration(milliseconds: 1000));
                        } else if (e.getIndex() == 3) {
                          controller0.reset();
                          controller1.reset();
                          controller2.reset();
                          controller4.reset();
                          controller3.animateTo(40,
                              duration: const Duration(milliseconds: 1000));
                        } else if (e.getIndex() == 4) {
                          controller0.reset();
                          controller1.reset();
                          controller2.reset();
                          controller3.reset();
                          controller4.animateTo(40,
                              duration: const Duration(milliseconds: 1000));
                        }
                        return onSelectTab(tabs.indexOf(e));
                      },
                      child: Column(
                        children: [
                          GifImage(
                            controller: controller,
                            height: 28,
                            width: 28,
                            image: AssetImage(e.icon.toString()),
                            color: DashboardState.currentTab == e.getIndex()
                                ? Colors.black
                                : Colors.grey,
                          ),
                          // SizedBox(
                          //   height: 5,
                          // ),
                          Text(
                            e.tabName,
                            style: DashboardState.currentTab == e.getIndex()
                                ? GoogleFonts.montserrat(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black)
                                : GoogleFonts.montserrat(
                                    fontSize: 11,
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
                            ? Colors.black
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10))),
                  ),
                ],
              ),
            );
          }).toList(),
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
