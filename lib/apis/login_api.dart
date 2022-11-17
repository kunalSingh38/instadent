// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/constants.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
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
    log(phone + "---" + otp);
    log(response.body);

    if (jsonDecode(response.body)["ErrorCode"] == 0) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setBool("loggedIn", true);
      pref.setString("userPhoneNo", phone.toString());
      pref.setString("token", jsonDecode(response.body)["token"].toString());

      return true;
    } else {
      return false;
    }
  }

  Future<Map> registration(Map m) async {
    var response = await http.post(
      Uri.parse(URL + "register"),
      body: m,
    );
    log(m.toString());

    return jsonDecode(response.body);
  }

  Future<bool> profileUpdate(Map m) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(URL + "user/profile-update"),
      headers: {
        'Authorization': 'Bearer ' + pref.getString("token").toString(),
        'Content-Type': 'application/json'
      },
      body: jsonEncode(m),
    );
    print(response.body);
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return true;
    }
    return false;
  }

  Future<List> addressList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
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

  Future<bool> setDefaultAddressAPI(String id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "address/default"),
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

  Future<bool> addAddress(Map m) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "address/add"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode(m));
    print(response.body);
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
    print(response.body);
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

  Future<Map> userProfile() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    print(pref.getString("token").toString());
    var response = await http.post(
      Uri.parse(URL + "profile"),
      headers: {
        'Authorization': 'Bearer ' + pref.getString("token").toString(),
        'Content-Type': 'application/json'
      },
    );
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    }
    return {};
  }

  Future<bool> serviceableOrNot(String pincode) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(URL + "pincode-estimate-delivery"),
      headers: {'Content-Type': 'application/json'},
    );
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      pref.setString("deliveryExpectedTime",
          jsonDecode(response.body)['ItemResponse']['delivery_expected_time']);
      pref.setString("deliveryInstruction",
          jsonDecode(response.body)['ItemResponse']['delivery_instruction']);

      return true;
    } else {
      pref.setString(
          "deliveryExpectedTime", jsonDecode(response.body)['ErrorMessage']);

      return false;
    }
  }
}
