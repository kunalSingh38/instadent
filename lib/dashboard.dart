// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/account.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:instadent/brand/brands.dart';
import 'package:instadent/category/all_categories.dart';
import 'package:instadent/home.dart';
import 'package:instadent/search/search.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tabItem.dart';
import 'bottomNavigation.dart';

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  // this is static property so other widget throughout the app
  // can access it simply by AppState.currentTab
  static int currentTab = 0;
  // list tabs here
  List<TabItem> tabs = [
    TabItem(
      tabName: "Home",
      icon: "assets/home-ac.gif",
      page: HomeScreen(),
    ),
    TabItem(
      tabName: "Categories",
      icon: "assets/categories-ac.gif",
      page: AllCategoriesScreen(),
    ),
    TabItem(
      tabName: "Search",
      icon: "assets/search-ac.gif",
      page: SearchScreen(),
    ),
    TabItem(
      tabName: "Brands",
      icon: "assets/offers-ac.gif",
      page: OffersScreen(),
    ),
    TabItem(
      tabName: "Account",
      icon: "assets/account-ac.gif",
      page: AccountScreen(),
    ),
  ];

  DashboardState() {
    // indexing is necessary for proper funcationality
    // of determining which tab is active
    tabs.asMap().forEach((index, details) {
      details.setIndex(index);
    });
  }

  // sets current tab index
  // and update state
  void selectTab(int index) {
    // if (index == 2) {
    //   Navigator.push(
    //       context, MaterialPageRoute(builder: (context) => SearchScreen()));
    // } else {
    setState(() {
      currentTab = index;
    });
    tabs[index].key.currentState?.popUntil((route) => route.isFirst);
    // }
  }

  late FlutterGifController controller;
  late FlutterGifController controller0;
  late FlutterGifController controller1;
  late FlutterGifController controller2;
  late FlutterGifController controller3;
  late FlutterGifController controller4;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller0 = FlutterGifController(vsync: this);
    controller1 = FlutterGifController(vsync: this);
    controller2 = FlutterGifController(vsync: this);
    controller3 = FlutterGifController(vsync: this);
    controller4 = FlutterGifController(vsync: this);
    controller = FlutterGifController(vsync: this);

    Provider.of<UpdateCartData>(context, listen: false).showCartorNot();
    Provider.of<UpdateCartData>(context, listen: false).setDefaultAddress();
    controller1.reset();
    controller2.reset();
    controller3.reset();
    controller4.reset();
    controller0.animateTo(40, duration: const Duration(milliseconds: 1000));
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope handle android back btn
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await tabs[currentTab].key.currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          // if not on the 'main' tab
          if (currentTab != 0) {
            // select 'main' tab
            selectTab(0);
            // back button handled by app
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      // this is the base scaffold
      // don't put appbar in here otherwise you might end up
      // with multiple appbars on one screen
      // eventually breaking the app
      child: Scaffold(
        // indexed stack shows only one child
        body: Consumer<UpdateCartData>(builder: (context, viewModel, child) {
          return IndexedStack(
            index: currentTab,
            children: tabs.map((e) => e.page).toList(),
          );
        }),
        // Bottom navigation

        bottomNavigationBar:
            Consumer<UpdateCartData>(builder: (context, viewModel, child) {
          return BottomNavigation(
            onSelectTab: selectTab,
            tabs: tabs,
            controller0: controller0,
            controller1: controller1,
            controller2: controller2,
            controller3: controller3,
            controller4: controller4,
            controller: controller,
          );
        }),
      ),
    );
  }
}
