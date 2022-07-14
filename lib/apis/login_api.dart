import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:instadent/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginAPI {
  Future<Map> userLogin(String phone) async {
    var response = await http.post(
      Uri.parse(URL + "otp"),
      body: {
        "phone": phone,
      },
    );

    return jsonDecode(response.body);
  }

  Future<bool> otpVerify(String phone, String otp) async {
    var response = await http.post(
      Uri.parse(URL + "verify/otp"),
      body: {"phone": phone, "otp": otp.toString()},
    );

    if (jsonDecode(response.body)["ErrorCode"] == 101) {
      return true;
    } else {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setBool("loggedIn", true);
      pref.setString("userPhoneNo", phone.toString());
      pref.setString("token", jsonDecode(response.body)["token"].toString());
      return false;
    }
  }

  Future<bool> registration(Map m) async {
    var response = await http.post(
      Uri.parse(URL + "register"),
      body: m,
    );

    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return true;
    }
    return false;
  }

  Future<List> addressList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    print(pref.getString("token").toString());
    var response = await http.post(
      Uri.parse(URL + "address/list"),
      headers: {
        'Authorization': 'Bearer ' + pref.getString("token").toString(),
        'Content-Type': 'application/json'
      },
    );

    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    }
    return [];
  }

  Future<bool> setDefaultAddress(String id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "address/default"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"address_id": id.toString()}));
    print(response.body);
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return true;
    }
    return false;
  }

  Future<bool> addAddress(Map m) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "address/add"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode(m));

    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return true;
    }
    return false;
  }

  Future<bool> editAddress(Map m) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "address/update"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode(m));

    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return true;
    }
    return false;
  }

  Future<bool> removeAddress(String id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "address/delete"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"address_id": id.toString()}));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return true;
    }
    return false;
  }
}
