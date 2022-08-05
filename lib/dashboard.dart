// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'package:flutter/material.dart';
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

class DashboardState extends State<Dashboard> {
  // this is static property so other widget throughout the app
  // can access it simply by AppState.currentTab
  static int currentTab = 0;
  // list tabs here
  List<TabItem> tabs = [
    TabItem(
      tabName: "Home",
      icon: "assets/home.png",
      page: HomeScreen(),
    ),
    TabItem(
      tabName: "Categories",
      icon: "assets/categories.png",
      page: AllCategoriesScreen(),
    ),
    TabItem(
      tabName: "Search",
      icon: "assets/search.png",
      page: SearchScreen(),
    ),
    TabItem(
      tabName: "Brands",
      icon: "assets/offers.png",
      page: OffersScreen(),
    ),
    TabItem(
      tabName: "Account",
      icon: "assets/account.png",
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<UpdateCartData>(context, listen: false).showCartorNot();
    Provider.of<UpdateCartData>(context, listen: false).setDefaultAddress();
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
          return viewModel.counterShowSearch
              ? SearchScreen()
              : IndexedStack(
                  index: currentTab,
                  children: tabs.map((e) => e.page).toList(),
                );
        }),
        // Bottom navigation

        bottomNavigationBar:
            Consumer<UpdateCartData>(builder: (context, viewModel, child) {
          return viewModel.counterShowSearch
              ? SizedBox()
              : BottomNavigation(
                  onSelectTab: selectTab,
                  tabs: tabs,
                );
        }),
      ),
    );
  }
}
