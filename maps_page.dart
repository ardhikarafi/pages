import 'dart:async';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/locker/locker_data.dart';
import 'package:new_popbox/core/models/callback/user/user_login_data.dart';
import 'package:new_popbox/core/models/locker_size_model.dart';
import 'package:new_popbox/core/models/payload/locker_payload.dart';
import 'package:new_popbox/core/models/popbox_service_type.dart';
import 'package:new_popbox/core/utils/global_function.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/utils/static_data.dart';
import 'package:new_popbox/core/viewmodel/locker_viewmodel.dart';
import 'package:new_popbox/ui/item/locker_maps_item.dart';
import 'package:new_popbox/ui/item/locker_size_item.dart';
import 'package:new_popbox/ui/pages/login_page.dart';
import 'package:new_popbox/ui/pages/popsafe_page.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:map_launcher/map_launcher.dart' as Maplauncher;

class MapsPage extends StatefulWidget {
  final bool isDetail;
  final LatLng latLng;

  const MapsPage({Key key, @required this.isDetail, this.latLng})
      : super(key: key);
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  Completer<GoogleMapController> _controller = Completer();

  BitmapDescriptor mapIcon;
  double zoomVal = 5.0;
  List<Marker> _marker = [];

  List<LockerData> lockerDataList = [];
  UserLoginData userData = new UserLoginData();
  String selectedLockerSize = "";
  static RemoteConfig _remoteConfig;
  bool showPopsafe;

  @override
  void initState() {
    _initializeRemoteConfig();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userData = await SharedPreferencesService().getUser();
    });

    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/ic_marker.png",
    ).then((onValue) {
      mapIcon = onValue;
    });

    getLockers();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _determinePosition();
      });
    });
  }

  _initializeRemoteConfig() async {
    if (_remoteConfig == null || showPopsafe == null) {
      _remoteConfig = await RemoteConfig.instance;

      await _fetchRemoteConfig();
    }

    setState(() {});
  }

  Future<void> _fetchRemoteConfig() async {
    try {
      await _remoteConfig.fetch(expiration: const Duration(minutes: 1));
      await _remoteConfig.activateFetched();
      setState(() {
        showPopsafe = _remoteConfig.getBool('pb_v3_popsafe');
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  void getLockers() async {
    var lockerModel = Provider.of<LockerViewModel>(context, listen: false);

    if (lockerModel.newLockerList == null ||
        lockerModel.newLockerList.length == 0) {
      LockerPayload lockerPayload = new LockerPayload();
      lockerPayload.token = GlobalVar.API_TOKEN;
      lockerPayload.countryName = await countryName();
      await lockerModel.getLockerList(
          onSuccess: () {
            setState(() {
              lockerDataList = [];
              lockerDataList = lockerModel.newLockerList;
              if (lockerDataList != null && lockerDataList.length > 0) {
                for (int i = 0; i < lockerDataList.length; i++) {
                  MarkerId markerId = new MarkerId(i.toString());
                  LockerData lockerData = lockerDataList[i];

                  setMarker(lockerData: lockerData, markerId: markerId);
                }
              }
            });
          },
          onError: (_) {},
          context: context,
          lockerPayload: lockerPayload,
          myLatLng: new LatLng(SharedPreferencesService().myLat,
              SharedPreferencesService().myLng));
    } else {
      setState(() {
        lockerDataList = [];
        lockerDataList = lockerModel.newLockerList;

        if (lockerDataList != null && lockerDataList.length > 0) {
          for (int i = 0; i < lockerDataList.length; i++) {
            MarkerId markerId = new MarkerId(i.toString());
            LockerData lockerData = lockerDataList[i];

            setMarker(lockerData: lockerData, markerId: markerId);
          }
        }
      });
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
            _lockerLocationType(),
            _buildContainer(),
          ],
        ),
      ),
    );
  }

  Future<void> _minus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(40.712776, -74.005974), zoom: zoomVal)));
  }

  Future<void> _plus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(40.712776, -74.005974), zoom: zoomVal)));
  }

  Widget _buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 16.0),
        height: 90.0,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: lockerDataList.length,
          itemBuilder: (context, index) {
            LockerData lockerData = lockerDataList[index];
            return InkWell(
              onTap: () {
                showPopUpDetailLocation(
                  context: context,
                  lockerData: lockerData,
                );
              },
              child: Container(
                  padding: EdgeInsets.only(right: 4.0, left: 4.0),
                  width: 75.0.w,
                  child: LockerMapsItem(lockerData: lockerData)),
            );
          },
        ),
      ),
    );
  }

  Widget _lockerLocationType() {
    return Padding(
      padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
      child: Container(
        height: 5.0.h,
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: StaticData().getPopboxServiceType(context).length,
            itemBuilder: (context, index) {
              PopboxServiceType service =
                  StaticData().getPopboxServiceType(context)[index];
              return Container(
                padding: EdgeInsets.only(right: 4.0, left: 4.0),
                width: 30.0.w,
                child: lockerTypeItem(
                  index,
                  service.title,
                ),
              );
            }),
      ),
    );
  }

  int checkedIndex = -1;
  bool isNearest = false;

  Widget lockerTypeItem(int index, String title) {
    bool checked = index == checkedIndex;
    return GestureDetector(
      onTap: () {
        var lockerModel = Provider.of<LockerViewModel>(context, listen: false);
        setState(
          () {
            _determinePosition();
            isNearest = false;
            _marker = [];
            checkedIndex = index;

            lockerDataList = [];
            int markerCounter = 0;
            if (checkedIndex == 0) {
              int nearestCounter = 0;

              List<LockerData> tempLockerDataList = lockerModel.newLockerList;
              if (tempLockerDataList != null && tempLockerDataList.length > 0) {
                tempLockerDataList
                    .sort((a, b) => a.distance.compareTo(b.distance));
              }

              for (var item in tempLockerDataList) {
                if (item.distance <= 5 && nearestCounter <= 9) {
                  nearestCounter++;
                  isNearest = true;
                  lockerDataList.add(item);
                  MarkerId markerId = new MarkerId(nearestCounter.toString());
                  setMarker(lockerData: item, markerId: markerId);
                }
              }

              if (lockerDataList.length <= 10) {
                lockerDataList = [];
                nearestCounter = 0;
              }

              if (lockerDataList == null || lockerDataList.length == 0) {
                nearestCounter++;
                for (var item in tempLockerDataList) {
                  if (item.distance <= 50 && nearestCounter <= 9) {
                    nearestCounter++;
                    isNearest = true;
                    lockerDataList.add(item);
                    MarkerId markerId = new MarkerId(nearestCounter.toString());
                    setMarker(lockerData: item, markerId: markerId);
                  }
                }
              }

              if (lockerDataList.length <= 10) {
                lockerDataList = [];
                nearestCounter = 0;
              }

              if (lockerDataList == null || lockerDataList.length == 0) {
                for (var item in tempLockerDataList) {
                  if (item.distance <= 500 && nearestCounter <= 9) {
                    nearestCounter++;
                    isNearest = true;
                    lockerDataList.add(item);
                    MarkerId markerId = new MarkerId(nearestCounter.toString());
                    setMarker(lockerData: item, markerId: markerId);
                  }
                }
              }

              if (lockerDataList.length <= 10) {
                lockerDataList = [];
                nearestCounter = 0;
              }

              if (lockerDataList == null || lockerDataList.length == 0) {
                for (var item in tempLockerDataList) {
                  if (item.distance <= 5000 && nearestCounter <= 9) {
                    nearestCounter++;
                    isNearest = true;
                    lockerDataList.add(item);
                    MarkerId markerId = new MarkerId(nearestCounter.toString());
                    setMarker(lockerData: item, markerId: markerId);
                  }
                }
              }

              if (lockerDataList.length <= 10) {
                lockerDataList = [];
                nearestCounter = 0;
              }

              if (lockerDataList == null || lockerDataList.length == 0) {
                for (var item in tempLockerDataList) {
                  if (item.distance <= 50000 && nearestCounter <= 9) {
                    nearestCounter++;
                    isNearest = true;
                    lockerDataList.add(item);
                    MarkerId markerId = new MarkerId(nearestCounter.toString());
                    setMarker(lockerData: item, markerId: markerId);
                  }
                }
              }

              // if (isNearest) {
              //   lockerDataList.sort((a, b) => a.distance.compareTo(b.distance));
              // }
            } else if (checkedIndex == 1) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "Apartment/Residential") {
                  lockerDataList.add(item);

                  markerCounter++;

                  MarkerId markerId = new MarkerId(markerCounter.toString());

                  setMarker(lockerData: item, markerId: markerId);
                }
              }

              lockerDataList.sort((a, b) => a.distance.compareTo(b.distance));
            } else if (checkedIndex == 2) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "Shopping Mall") {
                  lockerDataList.add(item);

                  markerCounter++;

                  MarkerId markerId = new MarkerId(markerCounter.toString());

                  setMarker(lockerData: item, markerId: markerId);
                }
              }

              lockerDataList.sort((a, b) => a.distance.compareTo(b.distance));
            } else if (checkedIndex == 3) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "Railway Station") {
                  lockerDataList.add(item);

                  markerCounter++;

                  MarkerId markerId = new MarkerId(markerCounter.toString());

                  setMarker(lockerData: item, markerId: markerId);
                }
              }

              lockerDataList.sort((a, b) => a.distance.compareTo(b.distance));
            } else if (checkedIndex == 4) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "Office") {
                  lockerDataList.add(item);

                  markerCounter++;

                  MarkerId markerId = new MarkerId(markerCounter.toString());

                  setMarker(lockerData: item, markerId: markerId);
                }
              }

              lockerDataList.sort((a, b) => a.distance.compareTo(b.distance));
            } else if (checkedIndex == 5) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "Super/Mini Market") {
                  lockerDataList.add(item);

                  markerCounter++;

                  MarkerId markerId = new MarkerId(markerCounter.toString());

                  setMarker(lockerData: item, markerId: markerId);
                }
              }

              lockerDataList.sort((a, b) => a.distance.compareTo(b.distance));
            } else if (checkedIndex == 6) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "University") {
                  lockerDataList.add(item);

                  markerCounter++;

                  MarkerId markerId = new MarkerId(markerCounter.toString());

                  setMarker(lockerData: item, markerId: markerId);
                }
              }

              lockerDataList.sort((a, b) => a.distance.compareTo(b.distance));
            } else if (checkedIndex == 7) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "Worship Place") {
                  lockerDataList.add(item);

                  markerCounter++;

                  MarkerId markerId = new MarkerId(markerCounter.toString());

                  setMarker(lockerData: item, markerId: markerId);
                }
              }

              lockerDataList.sort((a, b) => a.distance.compareTo(b.distance));
            } else if (checkedIndex == 8) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "Gas Station") {
                  lockerDataList.add(item);

                  markerCounter++;

                  MarkerId markerId = new MarkerId(markerCounter.toString());

                  setMarker(lockerData: item, markerId: markerId);
                }
              }

              lockerDataList.sort((a, b) => a.distance.compareTo(b.distance));
            } else if (checkedIndex == 9) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "Other Public Area") {
                  lockerDataList.add(item);

                  markerCounter++;

                  MarkerId markerId = new MarkerId(markerCounter.toString());

                  setMarker(lockerData: item, markerId: markerId);
                }
              }

              lockerDataList.sort((a, b) => a.distance.compareTo(b.distance));
            }

            if (isNearest) {
              lockerDataList.sort((a, b) => a.distance.compareTo(b.distance));
            }
          },
        );
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: 10.0,
            minWidth: 10.0,
            maxWidth: 100.0.w,
            maxHeight: 100.0.h),
        child: RawMaterialButton(
          fillColor: checked ? PopboxColor.popboxRed : PopboxColor.mdWhite1000,
          splashColor:
              checked ? PopboxColor.popboxRed : PopboxColor.mdWhite1000,
          child: CustomWidget().textMedium(
            title,
            checked ? PopboxColor.mdWhite1000 : PopboxColor.mdGrey700,
            11.0.sp,
            TextAlign.center,
          ),
          onPressed: null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: BorderSide(
              color: checked ? PopboxColor.popboxRed : PopboxColor.mdGrey350,
            ),
          ),
        ),
      ),
    );
  }

  void setMarker(
      {@required LockerData lockerData, @required MarkerId markerId}) {
    if (double.tryParse(lockerData.latitude) != null &&
        double.tryParse(lockerData.longitude) != null) {
      LatLng latLngMarker = LatLng(
        double.tryParse(lockerData.latitude),
        double.tryParse(lockerData.longitude),
      );

      _marker.add(
        new Marker(
          markerId: markerId,
          infoWindow: InfoWindow(title: lockerData.name),
          position: latLngMarker,
          onTap: () {
            showPopUpDetailLocation(
              context: context,
              lockerData: lockerData,
            );
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  Widget _buildGoogleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: googleMaps(_marker),
    );
  }

  Widget googleMaps(List<Marker> _marker) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition:
          CameraPosition(target: LatLng(-6.2060064, 106.7939644), zoom: 12),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: _marker.toSet(),
    );
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 15,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error(AppLocalizations.of(context)
          .translate(LanguageKeys.locationServiceDisabled));
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error(AppLocalizations.of(context)
            .translate(LanguageKeys.locationServicePermanentlyDenied));
      }

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error(AppLocalizations.of(context)
            .translate(LanguageKeys.locationServiceDenied));
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    //return await Geolocator.getCurrentPosition();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);

    //print("latitude " + position.latitude.toString());
    //print("longitude " + position.longitude.toString());
    //print("accuracy " + position.accuracy.toString());
    //print("accuracy " + position.timestamp.toString());

    LatLng latLng = new LatLng(position.latitude, position.longitude);

    if (latLng != null) {
      //print("latLng : " + latLng.latitude.toString());
      //print("latLng : " + latLng.longitude.toString());
      if (latLng.latitude != null &&
          latLng.latitude != 0.0 &&
          latLng.longitude != null &&
          latLng.longitude != 0.0) {
        SharedPreferencesService().setMyLat(latLng.latitude);
        SharedPreferencesService().setMyLng(latLng.longitude);

        MarkerId markerId = new MarkerId("My Location");
        Marker myMarker = new Marker(
          markerId: markerId,
          infoWindow: InfoWindow(
            title:
                AppLocalizations.of(context).translate(LanguageKeys.myLocation),
          ),
          position: new LatLng(position.latitude, position.longitude),
          onTap: () {
            // Handle on marker tap
          },
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        );

        _marker.add(myMarker);

        Future.delayed(const Duration(milliseconds: 500), () {
          googleMaps(_marker);
          setState(() {});
        });

        zoom(15.0, new LatLng(position.latitude, position.longitude));
      }
    }

    return position;
  }

  Future<void> zoom(double zoomVal, LatLng latLng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: zoomVal)));
  }

  int checkedLockerSize = -1;
  Widget lockerItem(BuildContext context, String item, LockerData lockerData,
      int index, Function stateBuilder) {
    bool checked = index == checkedLockerSize;
    return GestureDetector(
      onTap: () {
        if (lockerData.sizeAvailability.contains(item)) {
          selectedLockerSize = item;
          if (mounted) {
            setState(() {
              checkedLockerSize = index;
            });
          }
          stateBuilder(() {
            checkedLockerSize = index;
          });
        }
      },
      child: Container(
        padding:
            const EdgeInsets.only(top: 25, bottom: 25, left: 20, right: 15),
        margin: const EdgeInsets.only(left: 20, right: 20, top: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                checked ? PopboxColor.blue477FFF : PopboxColor.popboxGreyDADADA,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        width: 100.0.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomWidget().textBold(
              item,
              (lockerData.sizeAvailability.contains(item))
                  ? checked
                      ? PopboxColor.blue477FFF
                      : PopboxColor.mdBlack1000
                  : PopboxColor.mdGrey300,
              14,
              TextAlign.left,
            ),
            (lockerData.sizeAvailability.contains(item))
                ? checked
                    ? Icon(
                        Icons.check_circle,
                        color: PopboxColor.blue477FFF,
                        size: 20,
                      )
                    : Container()
                : CustomWidget().textRegular(
                    AppLocalizations.of(context)
                        .translate(LanguageKeys.locationLockerSizeNotAvailable),
                    PopboxColor.red,
                    12,
                    TextAlign.left,
                  )
          ],
        ),
      ),
    );
  }

  _showLockerImage(LockerData lockerData) async {
    await Future.delayed(Duration(milliseconds: 50));
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            PhotoView(imageProvider: NetworkImage(lockerData.imageUrl)));
  }

  void showPopUpDetailLocation({context, LockerData lockerData}) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setstateBuilder) => Container(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //TITLE
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 22.0),
                              child: Stack(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Image.asset(
                                          "assets/images/ic_close_icon.png",
                                          height: 16.0,
                                          width: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: CustomWidget().textBold(
                                      AppLocalizations.of(context).translate(
                                          LanguageKeys.locationDetail),
                                      PopboxColor.mdBlack1000,
                                      12.0.sp,
                                      TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Divider(
                        height: 1.0,
                        color: Colors.grey,
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 15, top: 30, bottom: 30),
                              margin: const EdgeInsets.only(
                                  left: 20, right: 20, top: 30),
                              width: 100.0.w,
                              decoration: BoxDecoration(
                                color: PopboxColor.popboxGreyPopsafe,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //1
                                  CustomWidget().textBold(
                                    lockerData.name,
                                    PopboxColor.mdBlack1000,
                                    14,
                                    TextAlign.left,
                                  ),
                                  SizedBox(height: 5),
                                  CustomWidget().textBold(
                                    lockerData.distance.toString() + " km",
                                    PopboxColor.mdBlack1000,
                                    14,
                                    TextAlign.left,
                                  ),
                                  SizedBox(height: 5),
                                  CustomWidget().textLight(
                                    lockerData.address,
                                    PopboxColor.mdBlack1000,
                                    12,
                                    TextAlign.left,
                                  ),
                                  SizedBox(height: 5),
                                  InkWell(
                                    onTap: () async {
                                      if (lockerData.latitude != null &&
                                          lockerData.latitude != "" &&
                                          lockerData.latitude != "-") {
                                        if (Platform.isIOS) {
                                          await Maplauncher.MapLauncher
                                              .launchMap(
                                            mapType: Maplauncher.MapType.apple,
                                            coords: Maplauncher.Coords(
                                                double.parse(
                                                    lockerData.latitude),
                                                double.parse(
                                                    lockerData.longitude)),
                                            title: lockerData.name,
                                            description: lockerData.address,
                                          );
                                        } else {
                                          await Maplauncher.MapLauncher
                                              .launchMap(
                                            mapType: Maplauncher.MapType.google,
                                            coords: Maplauncher.Coords(
                                                double.parse(
                                                    lockerData.latitude),
                                                double.parse(
                                                    lockerData.longitude)),
                                            title: lockerData.name,
                                            description: lockerData.address,
                                          );
                                        }
                                      }
                                    },
                                    child: CustomWidget().textRegular(
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.seeLocation),
                                      PopboxColor.blue477FFF,
                                      12,
                                      TextAlign.left,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  //2
                                  CustomWidget().textRegular(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.location),
                                    PopboxColor.mdBlack1000,
                                    12,
                                    TextAlign.left,
                                  ),
                                  SizedBox(height: 5),
                                  CustomWidget().textBold(
                                    lockerData.country,
                                    PopboxColor.mdBlack1000,
                                    14,
                                    TextAlign.left,
                                  ),
                                  SizedBox(height: 20),
                                  //3
                                  CustomWidget().textRegular(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.operational),
                                    PopboxColor.mdBlack1000,
                                    12,
                                    TextAlign.left,
                                  ),
                                  SizedBox(height: 5),
                                  CustomWidget().textBold(
                                    lockerData.operationalHour,
                                    PopboxColor.mdBlack1000,
                                    14,
                                    TextAlign.left,
                                  ),
                                  SizedBox(height: 20),
                                  //4
                                  InkWell(
                                    onTap: () {
                                      _showLockerImage(lockerData);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        lockerData.imageUrl,
                                        width: 100,
                                        fit: BoxFit.fitWidth,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            "assets/images/ic_dummy_locker.png",
                                            width: 100,
                                            fit: BoxFit.fitWidth,
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 20, right: 20, top: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomWidget().textBold(
                                    AppLocalizations.of(context).translate(
                                        LanguageKeys.lockerAvailable),
                                    PopboxColor.popboxBlack919191,
                                    12,
                                    TextAlign.left,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showPopUpLockerSizeDetails(
                                          context: context);
                                    },
                                    child: CustomWidget().textBold(
                                      AppLocalizations.of(context).translate(
                                          LanguageKeys.lockerSizeDetail),
                                      PopboxColor.blue477FFF,
                                      12,
                                      TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemCount:
                                    StaticData().getListOfLockersize().length,
                                itemBuilder: (BuildContext context, index) {
                                  String item =
                                      StaticData().getListOfLockersize()[index];

                                  return InkWell(
                                    onTap: () {
                                      if ((lockerData.sizeAvailability
                                          .contains(item))) {
                                        // print("choose AVAILABLE => " + item);
                                      } else {
                                        // print("NOT AVAILABLE");
                                      }
                                    },
                                    child: lockerItem(context, item, lockerData,
                                        index, setstateBuilder),
                                  );
                                }),
                            Container(
                                height: 100, width: 100, color: Colors.white),
                          ],
                        ),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      showPopsafe
                          ? InkWell(
                              onTap: () {
                                if (userData.isGuest == true ||
                                    userData == null) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => LoginPage()));
                                } else {
                                  if (selectedLockerSize == "") {
                                    CustomWidget().showCustomDialog(
                                        context: context,
                                        msg: AppLocalizations.of(context)
                                            .translate(LanguageKeys
                                                .pleaseSelectLockerSize));
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => PopsafePage(
                                          selectedLocker: selectedLockerSize,
                                          lockerData: lockerData,
                                          from: 'location_detail_page',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, bottom: 16, top: 16),
                                decoration: BoxDecoration(
                                  color: PopboxColor.popboxGreyPopsafe,
                                ),
                                child: CustomWidget().customColorButton(
                                    context,
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.orderNow),
                                    PopboxColor.red,
                                    PopboxColor.mdWhite1000),
                              ),
                            )
                          : Container()
                    ],
                  )
                ],
              ),
            ),
          );
        }).whenComplete(() => checkedLockerSize = -1);
  }

  void showPopUpLockerSizeDetails({context, LockerData lockerData}) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setstateBuilder) => Container(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //TITLE
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 22.0),
                          child: Stack(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Image.asset(
                                      "assets/images/ic_close_icon.png",
                                      height: 16.0,
                                      width: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: CustomWidget().textBold(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.lockerSize),
                                  PopboxColor.mdBlack1000,
                                  12.0.sp,
                                  TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Divider(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ListView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount:
                                StaticData().getListOfLockersizedetail().length,
                            itemBuilder: (BuildContext context, index) {
                              LockerSizeModel item = StaticData()
                                  .getListOfLockersizedetail()[index];

                              return InkWell(
                                  onTap: () {},
                                  child: LockerSizeItem(
                                    lockerSizeModel: item,
                                  ));
                            }),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }).whenComplete(() => null);
  }
}
