import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:instadent/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryAPI {
  Future<List> cartegoryList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(URL + "category"),
      headers: {
        'Authorization': 'Bearer ' + pref.getString("token").toString(),
        'Content-Type': 'application/json'
      },
    );
    print(jsonDecode(response.body)['Response']['category']);
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response']['category'];
    }
    return [];
  }

  Future<List> subCartegoryList(String id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "subcategory"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"parent_id": id.toString()}));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    }
    return [];
  }
}
