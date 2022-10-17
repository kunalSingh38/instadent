// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:io';

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
    print(response.body);
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
    var response = await http.post(Uri.parse(URL + "store/carousels/list"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"type": "all"}));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response']['carousels_list'];
    }
    return [];
  }

  Future<List> carouselsWithoutLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String postalCode = pref.getString('pincode').toString();
    var response = await http.post(Uri.parse(URL + "carousels/list"),
        headers: {
          // 'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"type": "all", "pincode": postalCode.toString()}));

    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response']['carousels_list'];
    }
    return [];
  }

  Future<List> feedbackQuestionList(String orderId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var response = await http.post(
      Uri.parse(URL + "feedbackquestion/" + orderId.toString()),
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

  Future<Map> singleProductDetails(String productId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "product-details"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"product_id": productId.toString()}));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['ItemResponse'];
    }
    return {};
  }

  Future<List> homePageBanner(String imageFor) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "banners"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"banner_location": imageFor.toString()}));
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response']['home_banner'];
    }
    return [];
  }

  Future<bool> saveUserFeedback(Map m) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "userfeedback/add"),
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

  Future<bool> addUserRating(Map m) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "userrating/add"),
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

  Future<List> ratingListResponseImages() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(URL + "rating/list"),
      headers: {
        'Authorization': 'Bearer ' + pref.getString("token").toString(),
        'Content-Type': 'application/json'
      },
    );
    print(response.body);
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return jsonDecode(response.body)['Response'];
    }
    return [];
  }

  Future<bool> reorderAPI(String orderId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL + "cart-add-recent-order"),
        headers: {
          'Authorization': 'Bearer ' + pref.getString("token").toString(),
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"order_number": orderId.toString()}));

    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      return true;
    }
    return false;
  }

  Future<bool> profilePhotoUpload(String path) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var request =
        http.MultipartRequest('POST', Uri.parse(URL + "profile_update"));
    request.files.add(http.MultipartFile('profile_image',
        File(path).readAsBytes().asStream(), File(path).lengthSync(),
        filename: path.split("/").last));
    request.headers.addAll({
      'Authorization': 'Bearer ' + pref.getString("token").toString(),
      'Content-Type': 'application/json'
    });
    var res = await request.send();
    var respStr = await res.stream.bytesToString();
    print(respStr);
    return true;
  }
}
