// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:instadent/apis/other_api.dart';
import 'package:instadent/constants.dart';

class ReviewAndRating extends StatefulWidget {
  String orderId = "";
  ReviewAndRating({required this.orderId});
  @override
  _ReviewAndRatingState createState() => _ReviewAndRatingState();
}

class _ReviewAndRatingState extends State<ReviewAndRating> {
  bool isLoading = true;
  List questionList = [];
  double getRating = 0;
  String feedback = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    OtherAPI().feedbackQuestionList(widget.orderId.toString()).then((value) {
      setState(() {
        isLoading = false;
        questionList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          leading: backIcon(context),
          elevation: 0,
        ),
        body: isLoading
            ? loadingProducts("Please wait. Getting your questions.")
            : SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Review & Rating",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontSize: 25),
                              ),
                              Divider(
                                thickness: 0.9,
                                height: 30,
                              ),
                              Column(
                                children: [
                                  Column(
                                    children: questionList.map((e) {
                                      List temp = e['question_option'];
                                      return Column(
                                        children: [
                                          Text(e["question"].toString(),
                                              style: GoogleFonts.montserrat(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              )),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          RadioGroup<String>.builder(
                                            groupValue: feedback,
                                            onChanged: (value) {
                                              setState(() {
                                                feedback = value.toString();
                                              });
                                            },
                                            items: temp
                                                .map((e) =>
                                                    e['options'].toString())
                                                .toList(),
                                            itemBuilder: (item) =>
                                                RadioButtonBuilder(item),
                                            direction: Axis.vertical,
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          1.15,
                                      height: 40,
                                      child: ElevatedButton(
                                          style: ButtonStyle(
                                              shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              )),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.teal[700])),
                                          onPressed: () {},
                                          child: Text(
                                            "Submit",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                                color: Colors.white),
                                          )))
                                ],
                              ),
                              Divider(
                                thickness: 0.9,
                                height: 30,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: RatingBar.builder(
                                  initialRating: 0,
                                  minRating: 0,
                                  direction: Axis.horizontal,
                                  allowHalfRating: false,
                                  itemCount: 5,
                                  glow: false,
                                  itemPadding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.teal,
                                    size: 15,
                                  ),
                                  tapOnlyMode: true,
                                  onRatingUpdate: (rating) {
                                    setState(() {
                                      getRating = rating;
                                    });
                                    print(rating);
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                            ]))
                  ])));
  }
}
