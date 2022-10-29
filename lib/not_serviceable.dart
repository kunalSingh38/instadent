// // ignore_for_file: prefer_interpolation_to_compose_strings

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:instadent/UpdateCart.dart';
// import 'package:instadent/address.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class NonServiceable extends StatefulWidget {
//   const NonServiceable({Key? key}) : super(key: key);

//   @override
//   _NonServiceableState createState() => _NonServiceableState();
// }

// class _NonServiceableState extends State<NonServiceable> {
//   String deliveryTime = "";
//   void setData() async {
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     setState(() {
//       deliveryTime = pref.getString("deliveryExpectedTime").toString();
//     });
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     setData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         showDialog(
//             context: context,
//             builder: (context) => Dialog(
//                   backgroundColor: Colors.transparent.withOpacity(0),
//                   elevation: 0,
//                   child: Stack(
//                     alignment: Alignment.bottomCenter,
//                     children: [
//                       Image.asset("assets/exit.png"),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Expanded(
//                               child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: ElevatedButton(
//                                 style: ButtonStyle(
//                                     backgroundColor: MaterialStateProperty.all(
//                                         Colors.grey[200])),
//                                 onPressed: () {
//                                   Navigator.of(context).pop();
//                                 },
//                                 child: Text(
//                                   "CANCEL",
//                                   style: TextStyle(color: Colors.black),
//                                 )),
//                           )),
//                           Expanded(
//                               child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: ElevatedButton(
//                                 style: ButtonStyle(
//                                     backgroundColor: MaterialStateProperty.all(
//                                         Colors.blue[800])),
//                                 onPressed: () {
//                                   SystemNavigator.pop();
//                                 },
//                                 child: Text("CONFIRM",
//                                     style: TextStyle(color: Colors.white))),
//                           )),
//                         ],
//                       )
//                     ],
//                   ),
//                 ));

//         return true;
//       },
//       child: Consumer<UpdateCartData>(builder: (context, viewModel, child) {
//         return Scaffold(
//             body: SafeArea(
//                 child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     flex: 9,
//                     child: Text(deliveryTime,
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                         style: GoogleFonts.montserrat(
//                             fontWeight: FontWeight.w800,
//                             fontSize: 14,
//                             color: Colors.black)),
//                   ),
//                   Expanded(
//                       child: Image.asset(
//                     "assets/account.png",
//                     scale: 15,
//                   ))
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               child: InkWell(
//                 onTap: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => AddressListScreen(
//                                 m: {},
//                               ))).then((value) async {});
//                 },
//                 child: Row(
//                   children: [
//                     Expanded(
//                       flex: 20,
//                       child: Text(
//                           viewModel.counterDefaultOffice
//                                   .toString()
//                                   .toUpperCase() +
//                               ", " +
//                               viewModel.counterDefaultAddress
//                                   .toString()
//                                   .replaceAll(" ,", ", "),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                           style: GoogleFonts.montserrat(
//                               fontWeight: FontWeight.w400, fontSize: 14)),
//                     ),
//                     Expanded(child: Icon(Icons.arrow_drop_down))
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 40,
//             ),
//             Image.asset("assets/service.jpg")
//           ],
//         )));
//       }),
//     );
//   }
// }
