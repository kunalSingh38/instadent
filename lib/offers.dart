import 'package:flutter/material.dart';
import 'package:instadent/constants.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: bottomSheet(),
      body: Center(
        child: Container(
          child: Image.asset("assets/logo.png"),
        ),
      ),
    );
  }
}
