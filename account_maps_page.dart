import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/account_maps_data.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';

class AccountMapsPage extends StatefulWidget {
  @override
  State<AccountMapsPage> createState() => _AccountMapsPageState();
}

class _AccountMapsPageState extends State<AccountMapsPage> {
  Completer<GoogleMapController> _controller = Completer();
  AccountMapsData accountMapsData;

  double latNow = 0;
  double lngNow = 0;

  List<Marker> _marker = [];
  String _currentAddress = "";

  @override
  void initState() {
    _determinePosition();
    super.initState();
  }

  Future<Position> _determinePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
    latNow = position.latitude;
    lngNow = position.longitude;
    Future.delayed(const Duration(milliseconds: 500), () {
      googleMaps(_marker);
      setState(() {});
    });

    zoom(15.0, new LatLng(position.latitude, position.longitude));
    _getAddressFromLatLng(lat: position.latitude, lng: position.longitude);

    return position;
  }

  _getAddressFromLatLng({double lat, double lng}) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      Placemark place = placemarks[0];
      setState(() {
        AccountMapsData accountMapsData = new AccountMapsData()
          ..administrativeArea = place.administrativeArea
          ..locality = place.locality
          ..postalCode = place.postalCode
          ..subAdministrativeArea = place.subAdministrativeArea
          ..subLocality = place.subLocality;
        this.accountMapsData = accountMapsData;
      });
    } catch (e) {
      // print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: DetailAppBarView(
            title:
                AppLocalizations.of(context).translate(LanguageKeys.location),
          ),
        ),
        body: Stack(
          children: <Widget>[
            _buildGoogleMap(context),
            Align(alignment: Alignment.bottomCenter, child: _button(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: googleMaps(_marker),
    );
  }

  Widget _button(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: CustomButtonRectangle(
        bgColor: Color(0xffFF0B09),
        fontSize: 14,
        textColor: Colors.white,
        title: AppLocalizations.of(context).translate(LanguageKeys.use),
        onPressed: () {
          Navigator.pop(context, accountMapsData);
        },
      ),
    );
  }

  Future<void> zoom(double zoomVal, LatLng latLng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: zoomVal)));
  }

  Widget googleMaps(List<Marker> _marker) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition:
          CameraPosition(target: LatLng(-6.2060064, 106.7939644), zoom: 5),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: Set<Marker>.of(
        <Marker>[
          Marker(
            onTap: () {
              // print("latNow => " + latNow.toString());
              // print("lngNow => " + lngNow.toString());
              // print(“TAPTAPTAP”);
            },
            draggable: true,
            markerId: MarkerId("1"),
            position: LatLng(latNow, lngNow),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: const InfoWindow(
              title: 'My Location',
            ),
            onDragEnd: ((value) {
              latNow = value.latitude;
              lngNow = value.longitude;
              _getAddressFromLatLng(lat: latNow, lng: lngNow);
            }),
          )
        ],
      ),
    );
  }
}
