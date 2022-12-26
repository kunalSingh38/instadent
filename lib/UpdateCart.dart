import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:instadent/apis/login_api.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/dashboard.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UpdateCartData extends ChangeNotifier {
  String _totalItemCount = "0";
  String _totalItemCost = "0";
  bool _showCart = false;
  String _defaultOffice = "";
  String _defaultPincode = "";
  String _defaultAddress = "";
  bool _listUpdate = false;
  String _deliveryAddress = "Please select delivery address";
  bool _deliveryAddressSelected = false;
  bool _servicable = false;
  String _deliveryTime = "Not serviceable in this area";

  String get counter => _totalItemCount;
  String get counterPrice => _totalItemCost;
  bool get counterShowCart => _showCart;
  String get counterDefaultOffice => _defaultOffice;
  String get counterDefaultPinCode => _defaultPincode;
  String get counterDefaultAddress => _defaultAddress;
  bool get counterListUpdate => _listUpdate;
  bool get counterServicable => _servicable;
  String get counterDeliveryTime => _deliveryTime;
  String get counterDeliveryAddress => _deliveryAddress;
  bool get counterDeliveryAddressSelected => _deliveryAddressSelected;

  Future<void> incrementCounter() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("loggedIn") ?? false) {
      CartAPI().cartBadge().then((value) {
        if (value > 0) {
          CartAPI().cartData().then((value) {
            List temp = value['items'];
            _totalItemCount = temp.length.toString();
            _totalItemCost = value['total_price'].toString();
            _showCart = true;
            notifyListeners();
          });
        } else {
          _totalItemCount = "0";
          _totalItemCost = "0";
          _showCart = false;
          _deliveryAddressSelected = false;
          notifyListeners();
        }
      });
    }
  }

  Future<bool> showCartorNot() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("loggedIn") ?? false) {
      if (_totalItemCount != "0") {
        _showCart = true;
        notifyListeners();
      } else {
        _showCart = false;
        _deliveryAddressSelected = false;
        notifyListeners();
      }
    } else {
      _showCart = false;
      _deliveryAddressSelected = false;
      notifyListeners();
    }
    return true;
  }

  Future<void> setDefaultAddress() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    _defaultPincode = pref.getString('pincode').toString();
    _defaultOffice = pref.getString('address_type').toString();
    _defaultAddress = pref.getString('defaultAddress').toString();
    notifyListeners();
  }

  Future<void> changeSearchView(int index) async {
    DashboardState.currentTab = index;
    notifyListeners();
  }

  Future<void> checkForServiceable() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String currentPincode = pref.getString("pincode").toString();
    var url = URL + "pincode-estimate-delivery";
    var body = {
      "pincode": currentPincode,
    };
    var response = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      _deliveryTime = jsonDecode(response.body)['ItemResponse']
              ['delivery_expected_time']
          .toString();
      _servicable = true;
    } else {
      _deliveryTime = "Not serviceable in this area";
      _servicable = false;
    }
    notifyListeners();
  }

  Future<void> setDeliveryAddress(String address) async {
    _deliveryAddress = address;
    _deliveryAddressSelected = true;
    notifyListeners();
  }
}
