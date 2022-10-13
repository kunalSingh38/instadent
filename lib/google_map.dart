// ignore_for_file: prefer_final_fields, prefer_const_constructors, unnecessary_new, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:instadent/add_update_address.dart';
import 'package:instadent/address.dart';
import 'package:instadent/constants.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class GoogleMapForAddress extends StatefulWidget {
  String lat = "";
  String long = "";
  GoogleMapForAddress({required this.lat, required this.long});
  @override
  _GoogleMapForAddressState createState() => _GoogleMapForAddressState();
}

class _GoogleMapForAddressState extends State<GoogleMapForAddress> {
  double latitude = 0;
  double longitude = 0;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  int _markerIdCounter = 0;
  Completer<GoogleMapController> _controller = Completer();

  late CameraPosition _kLake;

  String _markerIdVal({bool increment = false}) {
    String val = 'marker_id_$_markerIdCounter';
    if (increment) _markerIdCounter++;
    return val;
  }

  void _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    // if ([INITIAL_LOCATION] != null) {
    MarkerId markerId = MarkerId(_markerIdVal());
    LatLng position = LatLng(latitude, longitude);
    Marker marker = Marker(
      markerId: markerId,
      position: position,
      draggable: false,
    );
    setState(() {
      _markers[markerId] = marker;
    });

    Future.delayed(Duration(seconds: 1), () async {
      GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 17.0,
          ),
        ),
      );
    });
    // }
  }

  Future<void> _getAddress(value) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(value.latitude, value.longitude);
    Placemark place = placemarks[0];
    print(placemarks[0]);
    setState(() {
      locatlity = place.subLocality.toString();
      address = place.subAdministrativeArea.toString() +
          " ," +
          place.name.toString() +
          " ," +
          place.subLocality.toString() +
          " ," +
          place.locality.toString() +
          " ," +
          place.postalCode.toString() +
          " ," +
          place.country.toString();
      pincode = place.postalCode.toString();
    });
  }

  String locatlity = "";
  String address = "";
  String pincode = "";
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      latitude = double.parse(widget.lat);
      longitude = double.parse(widget.long);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: backIcon(context),
        elevation: 3,
        title: const Text(
          "Your current location",
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GoogleMap(
              markers: Set<Marker>.of(_markers.values),
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: 14.4750,
              ),
              myLocationEnabled: true,
              onCameraIdle: () {
                _getAddress(LatLng(latitude, longitude));
              },
              onCameraMove: (CameraPosition position) {
                if (_markers.length > 0) {
                  MarkerId markerId = MarkerId(_markerIdVal());
                  Marker? marker = _markers[markerId];
                  Marker updatedMarker = marker!.copyWith(
                    positionParam: position.target,
                  );

                  setState(() {
                    _markers[markerId] = updatedMarker;
                    latitude = position.target.latitude;
                    longitude = position.target.longitude;
                  });
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey))),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        "SELECT DELIVERY LOCATION",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "assets/marker.png",
                          scale: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          locatlity,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        address,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 45,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                )),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.teal[800])),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AddressListScreen(m: {
                                            "address_type":
                                                locatlity.toString(),
                                            "address": address.toString(),
                                            "pincode": pincode.toString()
                                          })));
                            },
                            child: Text(
                              "CONFIRM LOCATION",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.white),
                            )))
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: Text('To the lake!'),
      //   icon: Icon(Icons.directions_boat),
      // ),
    );
  }

  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  // }
}
