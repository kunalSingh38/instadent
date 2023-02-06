import 'dart:convert';
import 'dart:io';

import 'package:biz_sales_admin/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ItemsAPI {
  Future<Map> itemsListApi(int page) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("${URL}admin/item-list"),
        headers: {
          'Authorization': 'Bearer ${pref.getString("token")}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"page": page.toString()}));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    } else {
      return {};
    }
  }

  Future<Map> itemsDetailsApi(String itemId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("${URL}admin/item-view"),
        headers: {
          'Authorization': 'Bearer ${pref.getString("token")}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"item_id": itemId.toString()}));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    } else {
      return {};
    }
  }
}
