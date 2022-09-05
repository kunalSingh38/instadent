// ignore_for_file: prefer_interpolation_to_compose_strings

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

  Future<Map> productList(String id, String pincode) async {
    print("with login");
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "category-productlist"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"category_id": id.toString()}));
    print(jsonEncode({"category_id": id.toString()}));
    // if (['ErrorCode'] == 0) {
    //   return jsonDecode(response.body)['ItemResponse']['category_products'];
    // }
    return jsonDecode(response.body);
  }

  Future<Map> productListWithoutLogin(String id, String pincode) async {
    print("without login");
    var response = await http.post(Uri.parse(URL + "pincode-productlist"),
        headers: {
          // 'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"category_id": id.toString(), "pincode": pincode}));
    // print(jsonEncode({"category_id": id.toString(), "pincode": pincode}));
    print(response.body);
    // if (['ErrorCode'] == 0) {
    //   return jsonDecode(response.body)['ItemResponse']['category_products'];
    // }
    return jsonDecode(response.body);
  }

  Future<List> searchProducts(String searchData) async {
    print(searchData);
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "products"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"search": searchData.toString()}));

    if (jsonDecode(response.body)['ErrorCode'] == 0 &&
        jsonDecode(response.body)['ItemResponse'] != null) {
      return jsonDecode(response.body)['ItemResponse'];
    }
    return [];
  }

  Future<List> searchProductsWithoutLogin(String searchData) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var response = await http.post(Uri.parse(URL + "pincode-products"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "search": searchData.toString(),
          "pincode": pref.getString("pincode").toString()
        }));

    if (jsonDecode(response.body)['ErrorCode'] == 0 &&
        jsonDecode(response.body)['ItemResponse'] != null) {
      return jsonDecode(response.body)['ItemResponse'];
    }
    return [];
  }

  Future<List> brandCategorywithLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var response = await http.post(
      Uri.parse(URL + "brand/list"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + pref.getString("token").toString(),
      },
    );

    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    }
    return [];
  }

  Future<List> brandCategorywithoutLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var response = await http.post(Uri.parse(URL + "brand/list-pincode"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"pincode": pref.getString("pincode").toString()}));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    }
    return [];
  }

  Future<List> featuredProductsWithLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var response = await http.post(
      Uri.parse(URL + "featured-product"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + pref.getString("token").toString(),
      },
    );

    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['ItemResponse']['data'];
    }
    return [];
  }

  Future<List> featuredProductsWithoutLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var response = await http.post(Uri.parse(URL + "pincode-featured-product"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"pincode": pref.getString("pincode").toString()}));
    print(response.body);
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response']['data'];
    }
    return [];
  }
}
