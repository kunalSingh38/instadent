import 'package:flutter/material.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateCartData extends ChangeNotifier {
  String _totalItemCount = "0";
  String _totalItemCost = "0";
  bool _showCart = false;

  String get counter => _totalItemCount;
  String get counterPrice => _totalItemCost;
  bool get counterShowCart => _showCart;

  void incrementCounter() async {
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

  void showCartorNot() async {
    print("object1");
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
}
