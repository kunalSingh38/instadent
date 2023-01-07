import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:instadent/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartAPI {
  Future<Map> cartData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse("${URL}cart"),
      headers: {
        'Authorization': 'Bearer ${pref.getString("token")}',
        'Content-Type': 'application/json'
      },
    );
    print("crtt---" + response.body);
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    } else {
      return {};
    }
  }

  Future<int> cartBadge() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse("${URL}cart-badge"),
      headers: {
        'Authorization': 'Bearer ${pref.getString("token")}',
        'Content-Type': 'application/json'
      },
    );
    print("test---" + response.body);
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return int.parse(jsonDecode(response.body)['Data']['badge'].toString());
    }
    return 0;
  }

  Future<bool> addToCart(Map m) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("${URL}cart-add"),
        headers: {
          'Authorization': 'Bearer ${pref.getString("token")}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(m));
    print(response.body);
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> emptyCart() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse("${URL}cart-empty"),
      headers: {
        'Authorization': 'Bearer ${pref.getString("token")}',
        'Content-Type': 'application/json'
      },
    );

    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return true;
    }
    return false;
  }

  Future<bool> emptyCartItemWise(String id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("${URL}cart-delete"),
        headers: {
          'Authorization': 'Bearer ${pref.getString("token")}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"cart_id": id.toString()}));

    print(response.body);
    print(jsonEncode({"cart_id": id.toString()}));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return true;
    }
    return false;
  }

  Future<Map> orderDetails(String orderId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("${URL}order-detail"),
        headers: {
          'Authorization': 'Bearer ${pref.getString("token")}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"order_id": orderId.toString()}));
    print(response.body);
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    }
    return {};
  }

  Future<Map> placeOrder() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse("${URL}placeorder"),
      headers: {
        'Authorization': 'Bearer ${pref.getString("token")}',
        'Content-Type': 'application/json'
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map> placePendingOrder(String orderId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("${URL}pending-placeorder"),
        headers: {
          'Authorization': 'Bearer ${pref.getString("token")}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"order_id": orderId.toString()}));
    return jsonDecode(response.body);
  }

  Future<Map> cashOnDelivery() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse("${URL}placeorder-cod"),
      headers: {
        'Authorization': 'Bearer ${pref.getString("token")}',
        'Content-Type': 'application/json'
      },
    );
    print("coo-----" + response.body);
    return jsonDecode(response.body);
  }

  Future<Map> paymentUpdate(String orderId, String paymentId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("${URL}transaction-update"),
        headers: {
          'Authorization': 'Bearer ${pref.getString("token")}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "razorpay_order_id": orderId.toString(),
          "razorpay_payment_id": paymentId.toString()
        }));
    print(response.body);
    return jsonDecode(response.body);
  }

  Future<bool> cancelOrder(String orderId, String reason) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("${URL}order-cancel"),
        headers: {
          'Authorization': 'Bearer ${pref.getString("token")}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "order_id": orderId.toString(),
          "cancel_reason": reason.toString()
        }));

    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return true;
    }
    return false;
  }

  Future<Map> orderHistory(String url) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    print(pref.getString("token").toString());
    var response = await http.post(
      Uri.parse(URL + url),
      headers: {
        'Authorization': 'Bearer ${pref.getString("token")}',
        'Content-Type': 'application/json'
      },
    );

    return jsonDecode(response.body);
  }

  Future<List> recentOrderItems() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse("${URL}recent-order-items"),
      headers: {
        'Authorization': 'Bearer ${pref.getString("token")}',
        'Content-Type': 'application/json'
      },
    );
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    }
    return [];
  }

  Future<List> bannerCarusalProductList(String id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("${URL}carousels/item/list"),
        headers: {
          'Authorization': 'Bearer ${pref.getString("token")}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"carousel_id": id.toString()}));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response']['carousels_list']['items'];
    }
    return [];
  }
}
