import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:instadent/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartAPI {
  Future<Map> cartData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(URL + "cart"),
      headers: {
        'Authorization': 'Bearer ' + pref.getString("token").toString(),
        'Content-Type': 'application/json'
      },
    );
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    } else {
      return {};
    }
  }

  Future<int> cartBadge() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(URL + "cart-badge"),
      headers: {
        'Authorization': 'Bearer ' + pref.getString("token").toString(),
        'Content-Type': 'application/json'
      },
    );
    print(response.body);
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return int.parse(jsonDecode(response.body)['Response'].toString());
    }
    return 0;
  }

  Future<bool> addToCart(Map m) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "cart-add"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode(m));
    print(response.body);
    // if (jsonDecode(response.body)['ErrorCode'] == 0) {
    //   return int.parse(jsonDecode(response.body)['Response'].toString());
    // }
    return true;
  }

  Future<bool> emptyCart() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(URL + "cart-empty"),
      headers: {
        'Authorization': 'Bearer ' + pref.getString("token").toString(),
        'Content-Type': 'application/json'
      },
    );

    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return true;
    }
    return false;
  }

  Future<bool> emptyCartItemWise(String id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "cart-delete"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"cart_id": id.toString()}));
    print(response.body);
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return true;
    }
    return false;
  }

  Future<Map> orderHistoryCompleted() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(URL + "orders/completed"),
      headers: {
        'Authorization':
            'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiOTI3MzRiMmE4ZWY3MmFmOTg1M2VhNTBhNzA1MzRhNjNkYWJiNGZlMTg1NjAwMWZmY2M3NDg2ZWNkODc4Zjk1YWMzZDllZmRiYTIxOGU1MjUiLCJpYXQiOjE2NDQ0MTEyMDYsIm5iZiI6MTY0NDQxMTIwNiwiZXhwIjoxNjc1OTQ3MjA2LCJzdWIiOiIxMjkiLCJzY29wZXMiOltdfQ.hDrEDBYVOr1cb0dbx1HUCowAo5le7zVXe75LFyb6wLAGuLHJaSismui24SmRie-u4CKzL0xqxOaImZlOJ5dJhwAhr3omotNAl8Pd3c5SCZ03qTfirMins_NcrYrHf4gSBFZKdECYhf-PWKI-5bqoWhXGSaNXX6wr_DVWJK5ku2x1E8OAcRnubkFfhTqQOJ3oAvR1kvi-kmbgeeWOs6C-GOz8DbHdx1xrSX-O-gdTYJ04Ysvs964tBJF6lQeJsWHQynhvNrPgKbl5-HRUIFE5s7Pm6fjlW4G9R5kLCD1aHJgVsjHQBSEOi3iObaETBET8Ov5JKJwk-FlZXe_ALd7YwI7tTdHGV0P4sYtFW4K5vt1qsrjkk1sIQTHFgiBD4-Uiwarmcz2rM3UlsBkoyBlCL5eBSo9y_zknQFAekJ9Sq1rPb4-cF1m3xDWX5qpQNFnitmKv-TZq7hFKbSnEIF-JJePEnJhrCzfyftk8CjkzdFXZEhtMwh1-Wa2mox530KqNDrW6AYLdPjV7wNG0cV6EkA34oeU2zwEUa3HNMRz95SQpiCOoLmZU-gbElZ4pzGMD0AfOZi51XDNnnIe29GxK_4HO4tHgMvny_p_HZSfaJnvJbb5lXeyCUaUgH_3cN9YEmOAIvAST29fFAh_QXlaKjSJwOIe2ls5bki5CBOwCdNY',
        'Content-Type': 'application/json'
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map> orderDetails(String orderId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "order-detail"),
        headers: {
          'Authorization':
              'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiOTI3MzRiMmE4ZWY3MmFmOTg1M2VhNTBhNzA1MzRhNjNkYWJiNGZlMTg1NjAwMWZmY2M3NDg2ZWNkODc4Zjk1YWMzZDllZmRiYTIxOGU1MjUiLCJpYXQiOjE2NDQ0MTEyMDYsIm5iZiI6MTY0NDQxMTIwNiwiZXhwIjoxNjc1OTQ3MjA2LCJzdWIiOiIxMjkiLCJzY29wZXMiOltdfQ.hDrEDBYVOr1cb0dbx1HUCowAo5le7zVXe75LFyb6wLAGuLHJaSismui24SmRie-u4CKzL0xqxOaImZlOJ5dJhwAhr3omotNAl8Pd3c5SCZ03qTfirMins_NcrYrHf4gSBFZKdECYhf-PWKI-5bqoWhXGSaNXX6wr_DVWJK5ku2x1E8OAcRnubkFfhTqQOJ3oAvR1kvi-kmbgeeWOs6C-GOz8DbHdx1xrSX-O-gdTYJ04Ysvs964tBJF6lQeJsWHQynhvNrPgKbl5-HRUIFE5s7Pm6fjlW4G9R5kLCD1aHJgVsjHQBSEOi3iObaETBET8Ov5JKJwk-FlZXe_ALd7YwI7tTdHGV0P4sYtFW4K5vt1qsrjkk1sIQTHFgiBD4-Uiwarmcz2rM3UlsBkoyBlCL5eBSo9y_zknQFAekJ9Sq1rPb4-cF1m3xDWX5qpQNFnitmKv-TZq7hFKbSnEIF-JJePEnJhrCzfyftk8CjkzdFXZEhtMwh1-Wa2mox530KqNDrW6AYLdPjV7wNG0cV6EkA34oeU2zwEUa3HNMRz95SQpiCOoLmZU-gbElZ4pzGMD0AfOZi51XDNnnIe29GxK_4HO4tHgMvny_p_HZSfaJnvJbb5lXeyCUaUgH_3cN9YEmOAIvAST29fFAh_QXlaKjSJwOIe2ls5bki5CBOwCdNY',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"order_id": orderId.toString()}));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    }
    return {};
  }
}
