// ignore_for_file: prefer_interpolation_to_compose_strings

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

  Future<Map> getRequestQuestion() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(URL + "get-request-question"),
      headers: {
        'Authorization': 'Bearer ' + pref.getString("token").toString(),
        'Content-Type': 'application/json'
      },
    );
    return jsonDecode(response.body);
  }

  Future<String> startReturnProduct(Map m) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "return"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode(m));

    if (jsonDecode(response.body)['ErrorCode'].toString() == "102" ||
        jsonDecode(response.body)['ErrorCode'].toString() == "103") {
      return jsonDecode(response.body)['ErrorMessage'].toString() +
          "\nRequest SR Number: " +
          jsonDecode(response.body)['Response']['request_no'].toString();
    }
    return "Request Failed";
  }

  Future<List> returnReplacementRequestList(String type) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response =
        await http.post(Uri.parse(URL + "return-replacement-request-list"),
            headers: {
              'Authorization': 'Bearer ' + pref.getString("token").toString(),
              'Content-Type': 'application/json'
            },
            body: jsonEncode({"return_type": type.toString()}));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    }
    return [];
  }

  Future<List> brandProductData(String brandId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "brand/products/list"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"brand_id": brandId.toString()}));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response']['brand_products_list'];
    }
    return [];
  }

  Future<List> carouselsWithLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(URL + "store/carousels/list"),
      headers: {
        'Authorization': 'Bearer ' + pref.getString("token").toString(),
        'Content-Type': 'application/json'
      },
    );
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response']['carousels_list'];
    }
    return [];
  }

  Future<List> carouselsWithoutLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(URL + "carousels/list"),
      headers: {
        // 'Authorization': 'Bearer ' + pref.getString("token").toString(),
        'Content-Type': 'application/json'
      },
    );
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response']['carousels_list'];
    }
    return [];
  }
}
