import 'dart:convert';

import 'package:biz_sales_admin/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginAPI {
  Future<Map> loginApi(String emailId, String password) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("${URL}admin-login"),
        headers: {
          // 'Authorization': 'Bearer ${pref.getString("token")}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"email": emailId, "password": password}));
    print(response.body);
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body);
    } else {
      return {};
    }
  }
}
