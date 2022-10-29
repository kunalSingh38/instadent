// ignore_for_file: must_be_immutable, prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_html/flutter_html.dart';
import 'package:instadent/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Policy_View extends StatefulWidget {
  String policy;
  String data;
  Policy_View({required this.policy, required this.data});

  @override
  _Policy_ViewState createState() => _Policy_ViewState();
}

class _Policy_ViewState extends State<Policy_View> {
  bool loading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.policy);
    print(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          bottom: loading
              ? PreferredSize(
                  preferredSize: Size(double.infinity, 1.0),
                  child: LinearProgressIndicator(),
                )
              : null,
          backgroundColor: Colors.white,
          leading: backIcon(context),
          elevation: 3,
          title: Text(
            widget.policy.toString(),
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: WebView(
              initialUrl: widget.data.toString(),
              onProgress: (int progress) {
                if (progress == 100) {
                  setState(() {
                    loading = false;
                  });
                }
              },
              javascriptMode: JavascriptMode.unrestricted),
        ));
  }
}
