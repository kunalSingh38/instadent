// ignore_for_file: must_be_immutable, prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:instadent/constants.dart';

class Policy_View extends StatefulWidget {
  String policy;
  String data;
  Policy_View({required this.policy, required this.data});

  @override
  _Policy_ViewState createState() => _Policy_ViewState();
}

class _Policy_ViewState extends State<Policy_View> {
  String htmlData = "";
  void loadAssets() async {
    var data =
        await rootBundle.loadString("assets/policy/" + widget.data.toString());
    setState(() {
      htmlData = data;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: SafeArea(
          child: Scrollbar(
        interactive: true,
        isAlwaysShown: true,
        radius: Radius.circular(10),
        thickness: 8,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Html(data: htmlData.toString()),
          ),
        ),
      )),
    );
  }
}
