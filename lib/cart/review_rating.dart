// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:instadent/apis/other_api.dart';
import 'package:instadent/constants.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ReviewAndRating extends StatefulWidget {
  String orderId = "";
  ReviewAndRating({required this.orderId});
  @override
  _ReviewAndRatingState createState() => _ReviewAndRatingState();
}

class _ReviewAndRatingState extends State<ReviewAndRating> {
  bool isLoading = true;
  List questionList = [];
  int currentIndex = 0;
  bool submitLoading = false;
  List ratingImages = [];
  final introKey = GlobalKey<IntroductionScreenState>();
  bool showRating = false;
  void _onIntroEnd(context) {
    print("object");
  }

  Widget getAnswerWidget(String type, List options, Map ele) {
    if (type == "1") {
      return SizedBox(
          height: MediaQuery.of(context).size.height / 1.9,
          child: ListView(
            children: options
                .map((e) => RadioListTile(
                    contentPadding: EdgeInsets.all(0),
                    value: e['options'].toString(),
                    groupValue: ele['userAnswer'].toString(),
                    title: Text(e['options'].toString()),
                    onChanged: (val) {
                      setState(() {
                        ele['userAnswer'] = val.toString();
                      });
                    }))
                .toList(),
          ));
    } else if (type == "2") {
      return SizedBox(
        height: MediaQuery.of(context).size.height / 2.3,
        child: ListView(
          children: options
              .map((e) => CheckboxListTile(
                  value: e['userAnswer'],
                  onChanged: (val) {
                    setState(() {
                      e['userAnswer'] = !e['userAnswer'];
                    });
                  },
                  title: Text(e['options'].toString())))
              .toList(),
        ),
      );
    } else if (type == "3") {
      return TextFormField(
        maxLines: 10,
        controller: ele['userAnswer'],
        decoration:
            InputDecoration(border: OutlineInputBorder(), counterText: ""),
      );
    } else {
      return Center(
        child: Column(
          children: [
            showRating
                ? CachedNetworkImage(
                    imageUrl:
                        ratingImages[int.parse(ele['rating'].toString()) - 1]
                                ['icon']
                            .toString(),
                    fit: BoxFit.fill,
                    height: 150,
                    width: 150,
                    errorWidget: (context, url, error) {
                      return Image.asset(
                        "assets/logo.png",
                      );
                    },
                  )
                : SizedBox(),
            SizedBox(
              height: 60,
            ),
            RatingBar.builder(
              initialRating: 0,
              minRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              glow: false,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.teal,
                size: 15,
              ),
              tapOnlyMode: true,
              onRatingUpdate: (rating) {
                setState(() {
                  ele['rating'] =
                      double.parse(rating.toString()).toStringAsFixed(0);
                  showRating = true;
                });
              },
            )
          ],
        ),
      );
    }
  }

  int indecSelected = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    OtherAPI().feedbackQuestionList(widget.orderId.toString()).then((value) {
      setState(() {
        isLoading = false;
        questionList.clear();
        questionList = value;
        questionList.add({
          "question_type_id": "rating",
          "rating": "0",
          "question": "",
          "question_option": []
        });
        questionList.forEach((element) {
          if (element['question_type_id'].toString() == "1") {
            element['userAnswer'] = "";
          } else if (element['question_type_id'].toString() == "3") {
            element['userAnswer'] = TextEditingController();
          } else if (element['question_type_id'].toString() == "2") {
            List temp = element['question_option'];
            temp.forEach((el) {
              el['userAnswer'] = false;
            });
          }
        });
      });
      print(jsonEncode(questionList));
    });
    OtherAPI().ratingListResponseImages().then((value) {
      setState(() {
        ratingImages.clear();
        ratingImages.addAll(value);
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
          title: Text(
            "Review & Rating",
            style: TextStyle(color: Colors.black),
          ),
        ),
        bottomSheet: InkWell(
          onTap: () {
            switch (
                questionList[indecSelected]['question_type_id'].toString()) {
              case "1":
                if (questionList[indecSelected]['userAnswer']
                    .toString()
                    .isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Please select an option.".toString()),
                        duration: Duration(seconds: 1)),
                  );
                } else {
                  Map map = {};
                  map["question_id"] =
                      questionList[indecSelected]['q_id'].toString();
                  map["question_type_id"] = "1";
                  map["answer"] =
                      questionList[indecSelected]['userAnswer'].toString();
                  map["order_id"] = widget.orderId.toString();
                  print(jsonEncode(map));
                  setState(() {
                    submitLoading = true;
                  });
                  OtherAPI().saveUserFeedback(map).then((value) {
                    setState(() {
                      submitLoading = false;
                    });
                    if (value) {
                      if (indecSelected < questionList.length - 1) {
                        setState(() {
                          indecSelected = indecSelected + 1;
                        });
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text("Error occured try again.".toString()),
                            duration: Duration(seconds: 1)),
                      );
                    }
                  });
                }
                break;
              case "2":
                List answerList =
                    questionList[indecSelected]['question_option'];
                var exist = answerList
                    .where((element) => element['userAnswer'] == true);
                if (exist.length == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text("Please check alteast one option.".toString()),
                        duration: Duration(seconds: 1)),
                  );
                } else {
                  List temp = [];
                  exist.forEach((element) {
                    temp.add(element['options'].toString());
                  });
                  Map map = {};
                  map["question_id"] =
                      questionList[indecSelected]['q_id'].toString();
                  map["question_type_id"] = "1";
                  map["answer"] = temp.join(",");
                  map["order_id"] = widget.orderId.toString();
                  print(jsonEncode(map));
                  setState(() {
                    submitLoading = true;
                  });
                  OtherAPI().saveUserFeedback(map).then((value) {
                    setState(() {
                      submitLoading = false;
                    });
                    if (value) {
                      if (indecSelected < questionList.length - 1) {
                        setState(() {
                          indecSelected = indecSelected + 1;
                        });
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text("Error occured try again.".toString()),
                            duration: Duration(seconds: 1)),
                      );
                    }
                  });
                }
                break;
              case "3":
                if (questionList[indecSelected]['userAnswer']
                    .text
                    .toString()
                    .isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Please write your review.".toString()),
                        duration: Duration(seconds: 1)),
                  );
                } else {
                  Map map = {};
                  map["question_id"] =
                      questionList[indecSelected]['q_id'].toString();
                  map["question_type_id"] = "3";
                  map["answer"] =
                      questionList[indecSelected]['userAnswer'].text.toString();
                  map["order_id"] = widget.orderId.toString();
                  print(jsonEncode(map));
                  setState(() {
                    submitLoading = true;
                  });
                  OtherAPI().saveUserFeedback(map).then((value) {
                    setState(() {
                      submitLoading = false;
                    });
                    if (value) {
                      if (indecSelected < questionList.length - 1) {
                        setState(() {
                          indecSelected = indecSelected + 1;
                        });
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text("Error occured try again.".toString()),
                            duration: Duration(seconds: 1)),
                      );
                    }
                  });
                }
                break;
              case "rating":
                if (questionList[indecSelected]['rating'].toString() == "0") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Please give your rating.".toString()),
                        duration: Duration(seconds: 1)),
                  );
                } else {
                  Map map = {};

                  map["emoji_rating"] =
                      questionList[indecSelected]['rating'].toString();
                  map["order_id"] = widget.orderId.toString();
                  print(jsonEncode(map));
                  setState(() {
                    submitLoading = true;
                  });
                  OtherAPI().addUserRating(map).then((value) {
                    setState(() {
                      submitLoading = false;
                    });
                    if (value) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Rating and Review done.".toString()),
                            duration: Duration(seconds: 1)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text("Error occured try again.".toString()),
                            duration: Duration(seconds: 1)),
                      );
                    }
                  });
                }
                break;
            }
          },
          child: Container(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.teal[800],
                  ),
                  child: Center(
                    child: Text(
                      indecSelected == questionList.length - 1
                          ? "Submit"
                          : "Submit & Next",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w300),
                    ),
                  )),
            ),
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: submitLoading,
          child: isLoading
              ? loadingProducts("Please wait. Getting your questions.")
              : IndexedStack(
                  index: indecSelected,
                  children: questionList
                      .map((e) => Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e["question"].toString(),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    )),
                                SizedBox(
                                  height: 20,
                                ),
                                getAnswerWidget(
                                    e['question_type_id'].toString(),
                                    e['question_option'],
                                    e)
                              ],
                            ),
                          ))
                      .toList()),
        )
        // : ContainedTabBarView(
        //     callOnChangeWhileIndexIsChanging: true,
        //     tabBarProperties: TabBarProperties(

        //         height: 0,
        //         indicatorColor: Colors.teal,
        //         indicatorWeight: 5,
        //         background: Container(
        //           color: Colors.grey[300],
        //         )),
        //     tabs: questionList
        //         .map((e) => Text(
        //               '-',
        //               style: TextStyle(
        //                   color: Colors.black, fontWeight: FontWeight.w600),
        //             ))
        //         .toList(),
        //     initialIndex: indecSelected,

        //     onChange: (index) {
        //       setState(() {
        //         indecSelected = index;
        //       });
        //       print(indecSelected);
        //     },
        //     views: questionList
        //         .map((e) => Padding(
        //               padding: const EdgeInsets.all(20),
        //               child: Column(
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: [
        //                   Text(e["question"].toString(),
        //                       style: GoogleFonts.montserrat(
        //                         fontSize: 16,
        //                         fontWeight: FontWeight.w600,
        //                       )),
        //                   SizedBox(
        //                     height: 20,
        //                   ),
        //                   getAnswerWidget(e['question_type_id'].toString(),
        //                       e['question_option'], e)
        //                 ],
        //               ),
        //             ))
        //         .toList()),

        // IntroductionScreen(
        //     key: introKey,
        //     globalBackgroundColor: Colors.white,
        //     onChange: (val) {},
        //     pages: questionList.map((e) {
        //       List options = e['question_option'];
        //       return PageViewModel(
        //           decoration: PageDecoration(titleTextStyle: TextStyle()),
        //           titleWidget: Text(e["question"].toString(),
        //               style: GoogleFonts.montserrat(
        //                 fontSize: 16,
        //                 fontWeight: FontWeight.w600,
        //               )),
        //           footer: Container(
        //               width: 100,
        //               height: 50,
        //               decoration: BoxDecoration(
        //                   color: Colors.teal,
        //                   borderRadius: BorderRadius.circular(25)),
        //               child: Padding(
        //                 padding: EdgeInsets.all(8.0),
        //                 child: Center(
        //                     child: Text(
        //                   "Submit",
        //                   style: GoogleFonts.lato(
        //                       fontSize: 14,
        //                       fontWeight: FontWeight.w900,
        //                       color: Colors.white),
        //                 )),
        //               )),
        //           bodyWidget: getAnswerWidget(
        //               e['question_type_id'].toString(), options, e));
        //     }).toList(),
        //     onDone: () => _onIntroEnd(context),
        //     //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
        //     showSkipButton: false,
        //     skipOrBackFlex: 0,
        //     nextFlex: 0,
        //     showBackButton: true,
        //     //rtl: true, // Display as right-to-left
        //     back: const Icon(Icons.arrow_back, color: Colors.teal),
        //     // skip: const Text('Skip',
        //     //     style: TextStyle(
        //     //         fontWeight: FontWeight.w900,
        //     //         fontSize: 14,
        //     //         color: Color(0xff5A5B6A))),
        //     // showNextButton: false,

        //     next: const Icon(Icons.arrow_forward, color: Colors.teal),

        //     done: InkWell(
        //       onTap: () => _onIntroEnd(context),
        //       child: Container(
        //           width: 100,
        //           height: 50,
        //           decoration: BoxDecoration(
        //               color: Colors.teal,
        //               borderRadius: BorderRadius.circular(25)),
        //           child: Padding(
        //             padding: EdgeInsets.all(8.0),
        //             child: Center(
        //                 child: Text(
        //               "Submit",
        //               style: GoogleFonts.lato(
        //                   fontSize: 14,
        //                   fontWeight: FontWeight.w900,
        //                   color: Colors.white),
        //             )),
        //           )),
        //     ),
        //     curve: Curves.fastLinearToSlowEaseIn,
        //     controlsMargin: const EdgeInsets.all(16),
        //     controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        //     dotsDecorator: const DotsDecorator(
        //       size: Size(10.0, 10.0),
        //       color: Colors.teal,
        //       activeSize: Size(20.0, 10.0),
        //       activeColor: Colors.teal,
        //       activeShape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.all(Radius.circular(25.0)),
        //       ),
        //     ),
        //     dotsContainerDecorator: const ShapeDecoration(
        //       color: Colors.white,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.all(Radius.circular(8.0)),
        //       ),
        //     ),
        //   )

        // Center(
        //   child: ,
        // ),
        // SizedBox(
        //   height: 30,
        // ),
        );
  }
}
