import 'dart:convert';
import 'dart:io';

import 'package:biz_sales_admin/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrdersAPI {
  Future<Map> ordersListApi(int page) async {
    print(jsonEncode({"page": page.toString()}));
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("${URL}admin/orders"),
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

  Future<Map> ordersDetailsApi(String orderId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse("${URL}admin/orders/detail"),
        headers: {
          'Authorization': 'Bearer ${pref.getString("token")}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"order_id": orderId.toString()}));
    print(response.body);
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    } else {
      return {};
    }
  }

  Future<String> orderAcceptorReject(String orderId, String status) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
        Uri.parse("${URL}admin/orders/status-change"),
        headers: {
          'Authorization': 'Bearer ${pref.getString("token")}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {"order_id": orderId.toString(), "status": status.toString()}));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    } else {
      return "";
    }
  }

  Future<String> assignPicker(String orderId, String pickerName) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
        Uri.parse("${URL}admin/orders/assign-picker"),
        headers: {
          'Authorization': 'Bearer ${pref.getString("token")}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "order_id": orderId.toString(),
          "picker_id": pickerName.toString()
        }));
    print(response.body);
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    } else {
      return "";
    }
  }

  Future<String> uploadInvoice(
      String orderId, String path, String reamrks) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var request = http.MultipartRequest(
        "POST", Uri.parse("${URL}admin/orders/add-invoice"));
    request.headers.addAll({
      'Authorization': 'Bearer ${pref.getString("token")}',
      'Content-Type': 'application/json'
    });
    request.files.add(await http.MultipartFile.fromPath("invoice", path));
    request.fields["order_id"] = orderId.toString();
    request.fields["textarea"] = reamrks.toString();
    var response = await request.send();
    var respStr = await response.stream.bytesToString();
    print(respStr);
    return jsonDecode(respStr)['Response'];
  }

  Future<String> manualshipping(
      String orderId,
      String path,
      String deliveryName,
      String shippingNo,
      String trackUrl,
      String shippingDetails,
      String fee) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var request = http.MultipartRequest(
        "POST", Uri.parse("${URL}admin/orders/manual-shipping"));
    request.headers.addAll({
      'Authorization': 'Bearer ${pref.getString("token")}',
      'Content-Type': 'application/json'
    });
    request.files.add(await http.MultipartFile.fromPath("attachment", path));
    request.fields["order_id"] = orderId.toString();
    request.fields["delivery_name"] = deliveryName.toString();
    request.fields["shipping_no"] = shippingNo.toString();
    request.fields["track_url"] = trackUrl.toString();
    request.fields["fee"] = fee.toString();
    request.fields["shipping_details"] = shippingDetails.toString();

    var response = await request.send();
    var respStr = await response.stream.bytesToString();
    print(respStr);
    return jsonDecode(respStr)['Response'];
  }

  Future<List<int>> downloadInvoice(String orderId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response =
        await http.post(Uri.parse("${URL}admin/orders/print-invoice"),
            headers: {
              'Authorization': 'Bearer ${pref.getString("token")}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              "order_id": orderId.toString(),
            }));

    return response.bodyBytes;
  }

  Future<String> markComplete(String orderId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response =
        await http.post(Uri.parse("${URL}admin/orders/mark-complete"),
            headers: {
              'Authorization': 'Bearer ${pref.getString("token")}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              "order_id": orderId.toString(),
            }));
    print(response.body);
    return jsonDecode(response.body)['Response'];
  }
}
