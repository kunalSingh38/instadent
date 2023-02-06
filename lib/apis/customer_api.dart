import 'dart:convert';
import 'dart:io';

import 'package:biz_sales_admin/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CustomerAPI {
  Future<Map> customerListApi(int page) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse("${URL}admin/customer-list"),
      headers: {
        'Authorization': 'Bearer ${pref.getString("token")}',
        'Content-Type': 'application/json'
      },
    );
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    } else {
      return {};
    }
  }

  Future<Map> customerDetailsApi(String customerId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("${URL}admin/customer-view"),
        headers: {
          'Authorization': 'Bearer ${pref.getString("token")}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"user_id": customerId.toString()}));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    } else {
      return {};
    }
  }

  Future<String> customerAuthorize(String customerId,
      String selectedExpenseValue, String type, String reason) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("${URL}admin/customer-authorize"),
        headers: {
          'Authorization': 'Bearer ${pref.getString("token")}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "user_id": customerId.toString(),
          "authorize": selectedExpenseValue,
          "reason": reason
        }));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    }
    return "Error";
  }
}
