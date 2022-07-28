import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:instadent/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtherAPI {
  Future<bool> requestProduct(
      String productName, String brandName, String quantity) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "customer-request-product"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "product_name": productName.toString(),
          "brand_name": brandName.toString(),
          "quantity": quantity.toString()
        }));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> contactUs(String name, String email, String phone,
      String subject, String content) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "contact-us"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "name": name.toString(),
          "mobile_no": phone.toString(),
          "email": email.toString(),
          "subject": subject.toString(),
          "query": content.toString()
        }));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return true;
    } else {
      return false;
    }
  }
}
