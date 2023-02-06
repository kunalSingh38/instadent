// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:biz_sales_admin/apis/items_api.dart';
import 'package:biz_sales_admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ItemDetails extends StatefulWidget {
  Map map = {};
  ItemDetails({required this.map});
  @override
  _ItemDetailsState createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  bool checkbox = false;
  Map itemDetails = {};
  bool isLoading = true;
  ImagePicker _picker = ImagePicker();
  TextEditingController itemName = TextEditingController();
  TextEditingController itemPrice = TextEditingController();
  TextEditingController discount_price = TextEditingController();
  TextEditingController distributor_discount_price = TextEditingController();
  TextEditingController distributor_trade_price = TextEditingController();
  TextEditingController dealer_trade_price = TextEditingController();
  TextEditingController short_description = TextEditingController();
  TextEditingController long_description = TextEditingController();
  TextEditingController dealer_loyalty_points = TextEditingController();
  TextEditingController distributor_loyalty_points = TextEditingController();
  int selectedExpenseValue = 0;
  List taxMaster = [];
  GlobalKey<FormState> form = GlobalKey();

  void loaditem() async {
    ItemsAPI().itemsDetailsApi(widget.map['id'].toString()).then((value) {
      setState(() {
        itemDetails = value;
        isLoading = false;
        checkbox = itemDetails['item']['enabled'] == 1 ? true : false;
        itemName.text = itemDetails['item']['item_name'] == null
            ? ""
            : itemDetails['item']['item_name'].toString();
        itemPrice.text = itemDetails['item']['item_price'] == null
            ? ""
            : itemDetails['item']['item_price'].toString();
        discount_price.text = itemDetails['item']['discount_price'] == null
            ? ""
            : itemDetails['item']['discount_price'].toString();
        distributor_discount_price.text =
            itemDetails['item']['distributor_discount_price'] == null
                ? ""
                : itemDetails['item']['distributor_discount_price'].toString();
        distributor_trade_price.text =
            itemDetails['item']['distributor_trade_price'] == null
                ? ""
                : itemDetails['item']['distributor_trade_price'].toString();
        dealer_trade_price.text =
            itemDetails['item']['dealer_trade_price'] == null
                ? ""
                : itemDetails['item']['dealer_trade_price'].toString();
        selectedExpenseValue =
            int.parse(itemDetails['item']['tax_id'].toString());
        taxMaster.clear();
        taxMaster.addAll(itemDetails['taxList']);

        short_description.text =
            itemDetails['item']['short_description'] == null
                ? ""
                : itemDetails['item']['short_description'].toString();
        long_description.text = itemDetails['item']['long_description'] == null
            ? ""
            : itemDetails['item']['long_description'].toString();
        dealer_loyalty_points.text =
            itemDetails['item']['dealer_loyalty_points'] == null
                ? ""
                : itemDetails['item']['dealer_loyalty_points'].toString();
        distributor_loyalty_points.text =
            itemDetails['item']['distributor_loyalty_points'] == null
                ? ""
                : itemDetails['item']['distributor_loyalty_points'].toString();
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loaditem();
  }

  File file = File("path");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: isLoading
            ? loadingProducts("Loading item details...")
            : Stack(children: [
                Container(
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.white70,
                          blurRadius: 10.0,
                        ),
                      ],
                      color: Colors.teal[300],
                    ),
                    height: MediaQuery.of(context).size.height / 4.5,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(40, 70, 20, 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.map["item_name"].toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 20),
                          ),
                          Text(
                            widget.map["product_code"].toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                fontSize: 16),
                          )
                        ],
                      ),
                    )),
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 130, 20, 20),
                    child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Container(
                              // height: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                border: Border.all()),
                                            child: AspectRatio(
                                                aspectRatio: 1.6,
                                                child: file.existsSync()
                                                    ? Image.memory(
                                                        file.readAsBytesSync())
                                                    : cacheImage(widget
                                                        .map['image']
                                                        .toString())),
                                          ),
                                          file.existsSync()
                                              ? IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      file.delete();
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.clear,
                                                    color: Colors.red,
                                                  ))
                                              : SizedBox()
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "Enable",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ),
                                              Expanded(
                                                child: Checkbox(
                                                    value: checkbox,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        checkbox = !checkbox;
                                                      });
                                                    }),
                                              )
                                            ],
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              XFile image =
                                                  (await _picker.pickImage(
                                                      source: ImageSource
                                                          .gallery))!;
                                              setState(() {
                                                file = File(image.path);
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Update Image",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Image.asset(
                                                    "assets/upload_2.png",
                                                    scale: 30,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                  ],
                                ),
                              )),
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white),
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Category",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    widget.map[
                                                            'category_hirarchy']
                                                            ['parent_name']
                                                        .toString()
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.black),
                                                  ),
                                                  widget.map['category_hirarchy']
                                                                  [
                                                                  'sub_category']
                                                              ['name'] ==
                                                          ""
                                                      ? SizedBox()
                                                      : Text(
                                                          "->" +
                                                              widget.map[
                                                                      'category_hirarchy']
                                                                      [
                                                                      'sub_category']
                                                                      ['name']
                                                                  .toString()
                                                                  .toUpperCase(),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Item Added On",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  itemDetails['item']
                                                          ['created_at']
                                                      .toString()
                                                      .split(" ")[0],
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                )),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Last Updated On",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                    itemDetails['item']
                                                            ['updated_at']
                                                        .toString()
                                                        .split(" ")[0],
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700))),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "L x W x H (cm)",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                  "${itemDetails['item']['item_length']} x ${itemDetails['item']['item_width']} x ${itemDetails['item']['item_height']}",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Available Stock",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                  itemDetails['getLastUpdateStock']
                                                          [0]['stock_in']
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Last Stock Update",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                  itemDetails['getLastUpdateStock']
                                                          [0]['updated_at']
                                                      .toString()
                                                      .split(" ")[0],
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ))),
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Form(
                                key: form,
                                child: Column(
                                  children: [
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value!.isEmpty)
                                            return "Required Field";
                                          else
                                            return null;
                                        },
                                        controller: itemName,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          contentPadding: EdgeInsets.all(10),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          labelText: "Product Name*",
                                          labelStyle: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value!.isEmpty)
                                            return "Required Field";
                                          else
                                            return null;
                                        },
                                        controller: itemPrice,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r"[0-9.]")),
                                          TextInputFormatter.withFunction(
                                              (oldValue, newValue) {
                                            try {
                                              final text = newValue.text;
                                              if (text.isNotEmpty)
                                                double.parse(text);
                                              return newValue;
                                            } catch (e) {}
                                            return oldValue;
                                          }),
                                        ],
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true, signed: false),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          contentPadding: EdgeInsets.all(10),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          labelText: "MRP*",
                                          labelStyle: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value!.isEmpty)
                                            return "Required Field";
                                          else
                                            return null;
                                        },
                                        controller: discount_price,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r"[0-9.]")),
                                          TextInputFormatter.withFunction(
                                              (oldValue, newValue) {
                                            try {
                                              final text = newValue.text;
                                              if (text.isNotEmpty)
                                                double.parse(text);
                                              return newValue;
                                            } catch (e) {}
                                            return oldValue;
                                          }),
                                        ],
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true, signed: false),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          contentPadding: EdgeInsets.all(10),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          labelText: "Dealer Selling Price*",
                                          labelStyle: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value!.isEmpty)
                                            return "Required Field";
                                          else
                                            return null;
                                        },
                                        controller: distributor_discount_price,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r"[0-9.]")),
                                          TextInputFormatter.withFunction(
                                              (oldValue, newValue) {
                                            try {
                                              final text = newValue.text;
                                              if (text.isNotEmpty)
                                                double.parse(text);
                                              return newValue;
                                            } catch (e) {}
                                            return oldValue;
                                          }),
                                        ],
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true, signed: false),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          contentPadding: EdgeInsets.all(10),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          labelText:
                                              "Distributor Selling Price*",
                                          labelStyle: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value!.isEmpty)
                                            return "Required Field";
                                          else
                                            return null;
                                        },
                                        controller: distributor_trade_price,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r"[0-9.]")),
                                          TextInputFormatter.withFunction(
                                              (oldValue, newValue) {
                                            try {
                                              final text = newValue.text;
                                              if (text.isNotEmpty)
                                                double.parse(text);
                                              return newValue;
                                            } catch (e) {}
                                            return oldValue;
                                          }),
                                        ],
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true, signed: false),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          contentPadding: EdgeInsets.all(10),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          labelText: "Distributor Trade Price*",
                                          labelStyle: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value!.isEmpty)
                                            return "Required Field";
                                          else
                                            return null;
                                        },
                                        controller: dealer_trade_price,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r"[0-9.]")),
                                          TextInputFormatter.withFunction(
                                              (oldValue, newValue) {
                                            try {
                                              final text = newValue.text;
                                              if (text.isNotEmpty)
                                                double.parse(text);
                                              return newValue;
                                            } catch (e) {}
                                            return oldValue;
                                          }),
                                        ],
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true, signed: false),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          contentPadding: EdgeInsets.all(10),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          labelText: "Dealer Trade Price*",
                                          labelStyle: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: FormField(
                                          builder: (FormFieldState state) {
                                            return InputDecorator(
                                              decoration: InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                labelText: "Tax*",
                                                labelStyle: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700),
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.all(10),
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                              ),
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton(
                                                  isExpanded: true,
                                                  value: selectedExpenseValue,
                                                  isDense: true,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      selectedExpenseValue =
                                                          int.parse(newValue
                                                              .toString());
                                                    });
                                                    print(taxMaster.where(
                                                        (element) =>
                                                            element['id'] ==
                                                            newValue));
                                                  },
                                                  items: taxMaster.map((value) {
                                                    return DropdownMenuItem(
                                                      value: value['id'],
                                                      child: Text(
                                                        value['tax_name']
                                                            .toString()
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value!.isEmpty)
                                            return "Required Field";
                                          else
                                            return null;
                                        },
                                        controller: short_description,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          contentPadding: EdgeInsets.all(10),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          labelText: "Short Description",
                                          labelStyle: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value!.isEmpty)
                                            return "Required Field";
                                          else
                                            return null;
                                        },
                                        controller: long_description,
                                        maxLines: 3,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          contentPadding: EdgeInsets.all(10),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          labelText: "Long Description",
                                          labelStyle: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Card(
                                            elevation: 5,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value!.isEmpty)
                                                  return "Required Field";
                                                else
                                                  return null;
                                              },
                                              controller: dealer_loyalty_points,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              keyboardType:
                                                  TextInputType.number,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                contentPadding:
                                                    EdgeInsets.all(10),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                labelText:
                                                    "Deal. Loyalty Points*",
                                                labelStyle: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Card(
                                            elevation: 5,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value!.isEmpty)
                                                  return "Required Field";
                                                else
                                                  return null;
                                              },
                                              controller:
                                                  distributor_loyalty_points,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              keyboardType:
                                                  TextInputType.number,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                contentPadding:
                                                    EdgeInsets.all(10),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                labelText:
                                                    "Dist. Loyalty Points*",
                                                labelStyle: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.15,
                                        height: 45,
                                        child: ElevatedButton(
                                            style: ButtonStyle(
                                                shape:
                                                    MaterialStateProperty.all(
                                                        RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                )),
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.teal[700])),
                                            onPressed: () async {
                                              if (form.currentState!
                                                  .validate()) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          "Do you want to update?"
                                                              .toString()),
                                                      action: SnackBarAction(
                                                          label: "Confirm",
                                                          onPressed: () async {
                                                            showLaoding(
                                                                context);
                                                            SharedPreferences
                                                                pref =
                                                                await SharedPreferences
                                                                    .getInstance();

                                                            var request = http
                                                                .MultipartRequest(
                                                                    "POST",
                                                                    Uri.parse(
                                                                        "${URL}admin/item-update"));
                                                            request.headers
                                                                .addAll({
                                                              'Authorization':
                                                                  'Bearer ${pref.getString("token")}',
                                                              'Content-Type':
                                                                  'application/json'
                                                            });

                                                            if (file
                                                                .existsSync()) {
                                                              request.files.add(await http
                                                                      .MultipartFile
                                                                  .fromPath(
                                                                      "item_image",
                                                                      file.path));
                                                            }

                                                            request.fields[
                                                                    "item_id"] =
                                                                widget.map['id']
                                                                    .toString();
                                                            request.fields[
                                                                    "item_name"] =
                                                                itemName.text
                                                                    .toString();
                                                            request.fields[
                                                                    "item_price"] =
                                                                itemPrice.text
                                                                    .toString();
                                                            request.fields[
                                                                    "discount_price"] =
                                                                discount_price
                                                                    .text
                                                                    .toString();
                                                            request.fields[
                                                                    "distributor_discount_price"] =
                                                                distributor_discount_price
                                                                    .text
                                                                    .toString();
                                                            request.fields[
                                                                    "dealer_trade_price"] =
                                                                dealer_trade_price
                                                                    .text
                                                                    .toString();
                                                            request.fields[
                                                                    "distributor_trade_price"] =
                                                                distributor_trade_price
                                                                    .text
                                                                    .toString();
                                                            request.fields[
                                                                    "tax_id"] =
                                                                selectedExpenseValue
                                                                    .toString();
                                                            request.fields[
                                                                    "short_description"] =
                                                                short_description
                                                                    .text
                                                                    .toString();
                                                            request.fields[
                                                                    "long_description"] =
                                                                long_description
                                                                    .text
                                                                    .toString();
                                                            request.fields[
                                                                    "dealer_loyalty_points"] =
                                                                dealer_loyalty_points
                                                                    .text
                                                                    .toString();
                                                            request.fields[
                                                                    "distributor_loyalty_points"] =
                                                                distributor_loyalty_points
                                                                    .text
                                                                    .toString();
                                                            request.fields[
                                                                    "enabled"] =
                                                                checkbox
                                                                    ? "on"
                                                                    : "off";
                                                            print(
                                                                request.fields);
                                                            var response =
                                                                await request
                                                                    .send();
                                                            var respStr =
                                                                await response
                                                                    .stream
                                                                    .bytesToString();
                                                            print(respStr);
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                            loaditem();
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        AlertDialog(
                                                                          title:
                                                                              Text("Item Updated"),
                                                                        ));
                                                          })),
                                                );
                                              }
                                            },
                                            child: Text(
                                              "Update",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ))),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ])))
              ]));
  }
}
