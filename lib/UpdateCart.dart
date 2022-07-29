import 'package:flutter/material.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:instadent/apis/login_api.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateCartData extends ChangeNotifier {
  String _totalItemCount = "0";
  String _totalItemCost = "0";
  bool _showCart = false;
  String _defaultOffice = "";
  String _defaultPincode = "";
  String _defaultAddress = "";
  bool _showSearch = false;

  String get counter => _totalItemCount;
  String get counterPrice => _totalItemCost;
  bool get counterShowCart => _showCart;
  String get counterDefaultOffice => _defaultOffice;
  String get counterDefaultPinCode => _defaultPincode;
  String get counterDefaultAddress => _defaultAddress;
  bool get counterShowSearch => _showSearch;

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
          notifyListeners();
        }
      });
    }
  }

  Future<void> showCartorNot() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("loggedIn") ?? false) {
      if (_totalItemCount != "0") {
        _showCart = true;
        notifyListeners();
      } else {
        _showCart = false;
        notifyListeners();
      }
    } else {
      _showCart = false;
      notifyListeners();
    }
  }

  Future<void> setDefaultAddress() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    _defaultPincode = pref.getString('pincode').toString();
    _defaultOffice = pref.getString('address_type').toString();
    _defaultAddress = pref.getString('defaultAddress').toString();
  }

  Future<void> changeSearchView() async {
    _showSearch = !_showSearch;
    notifyListeners();
  }
}
