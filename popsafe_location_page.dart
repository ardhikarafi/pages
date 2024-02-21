import 'dart:io';

import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/locker/locker_data.dart';
import 'package:new_popbox/core/models/payload/locker_payload.dart';
import 'package:new_popbox/core/models/popbox_service_type.dart';
import 'package:new_popbox/core/utils/global_function.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/utils/static_data.dart';
import 'package:new_popbox/core/viewmodel/locker_viewmodel.dart';
import 'package:new_popbox/ui/pages/maps_page.dart';
import 'package:new_popbox/ui/widget/app_widget.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class PopsafeLocation extends StatefulWidget {
  const PopsafeLocation({Key key}) : super(key: key);

  @override
  _PopsafeLocationState createState() => _PopsafeLocationState();
}

class _PopsafeLocationState extends State<PopsafeLocation> {
  List<LockerData> lockerDataList = [];

  //lockerTypeItem
  bool isNearest = false;
  int checkedIndex = -1;
  String cekStatus;
  bool isSearch = false;
  NumberFormat formatCurrency;
  String unit = "";
  List<String> listSizeLocker = [];
  String selectedLanguage;
  LatLng myLatLng;

  @override
  void initState() {
    var lockerModel = Provider.of<LockerViewModel>(context, listen: false);

    setState(() {
      lockerDataList = [];
      lockerDataList = lockerModel.newLockerList;
    });
    selectedLanguage = SharedPreferencesService().languageCode.toUpperCase();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (lockerModel != null &&
          lockerModel.newLockerList != null &&
          lockerModel.newLockerList.length > 0) {
      } else {
        //lockers
        LockerPayload lockerPayload = new LockerPayload();
        lockerPayload.token = GlobalVar.API_TOKEN;
        lockerPayload.countryName = await countryName();
        await lockerModel.getLockerList(
            onSuccess: () {
              lockerDataList = [];
              lockerDataList = lockerModel.newLockerList;
              lockerDataList.sort((a, b) => a.distance.compareTo(b.distance));
            },
            onError: (_) {},
            context: context,
            lockerPayload: lockerPayload,
            myLatLng: myLatLng);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //

  @override
  Widget build(BuildContext context) {
    setCurrencyAndCountry();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: DetailAppBarViewCloseIcon(
          title: AppLocalizations.of(context)
              .translate(LanguageKeys.chooseLockerSafe),
        ),
      ),
      body: Container(
        child: Consumer<LockerViewModel>(
          builder: (context, lockerModel, _) {
            if (lockerModel.loading) return cartShimmerView(context);
            if (lockerModel.newLockerList == null) {
              return Container();
            }

            if (isNearest) {
              lockerDataList.sort((a, b) => a.distance.compareTo(b.distance));
            } else {
              lockerDataList.sort((a, b) => a.name.compareTo(b.name));
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                //Search
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      height: 48,
                      width: MediaQuery.of(context).size.width * 0.68,
                      color: PopboxColor.mdWhite1000,
                      child: TextField(
                        onChanged: (value) => _runSearch(value),
                        cursorColor: PopboxColor.mdGrey700,
                        style: TextStyle(
                          color: PopboxColor.mdBlack1000,
                          fontSize: 12.0.sp,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: new Icon(Icons.search),
                          hintText: AppLocalizations.of(context)
                              .translate(LanguageKeys.searchLocation),
                          hintStyle: TextStyle(
                              color: PopboxColor.mdGrey700, fontSize: 11.0.sp),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7.0)),
                              borderSide: BorderSide(
                                  color: PopboxColor.mdGrey200, width: 1.5)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7.0)),
                              borderSide:
                                  BorderSide(color: PopboxColor.mdGrey200)),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        openMaps(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 20),
                        child: Text(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.seeMap),
                          style: TextStyle(
                            color: PopboxColor.mdGrey700,
                            fontFamily: "Montserrat",
                            fontSize:
                                (selectedLanguage == "EN") ? 9.0.sp : 11.0.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                //Filter
                Padding(
                  padding: EdgeInsets.only(top: 17.0, bottom: 4.0),
                  child: Container(
                    height: 40.0,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          StaticData().getPopboxServiceType(context).length,
                      itemBuilder: (context, index) {
                        PopboxServiceType service =
                            StaticData().getPopboxServiceType(context)[index];
                        return Container(
                            padding: EdgeInsets.only(right: 4.0, left: 4.0),
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: lockerTypeItem(
                              index,
                              service.title,
                            ));
                      },
                    ),
                  ),
                ),
                //Divider Grey
                Container(
                  margin: EdgeInsets.only(top: 15),
                  color: PopboxColor.mdGrey100,
                  width: MediaQuery.of(context).size.width,
                  height: 36,
                  child: Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Text(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.lockerAvailable),
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: 13,
                                color: Colors.grey),
                          ),
                        ),
                        Container(
                          child: Text(
                            (checkedIndex == 0 &&
                                    (SharedPreferencesService().myLat == 0.0 ||
                                        SharedPreferencesService().myLng == 0.0)
                                ? ""
                                : lockerDataList.length.toString() +
                                    " " +
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.locker)),
                            style: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: 13,
                                color: Colors.grey),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                //List
                Expanded(
                  child: (checkedIndex == 0 &&
                          (SharedPreferencesService().myLat == 0.0 ||
                              SharedPreferencesService().myLng == 0.0)
                      ? RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView(children: [
                            Container(
                                margin: EdgeInsets.only(top: 40.0),
                                alignment: Alignment.center,
                                child: CustomWidget().notGrantedLocation(
                                    context, "popsafe_location_page")),
                          ]),
                        )
                      : RefreshIndicator(
                          onRefresh: _refresh,
                          child: Container(
                            child: ListView.builder(
                                itemCount: lockerDataList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  LockerData lockerData = lockerDataList[index];
                                  listSizeLocker = lockerData.sizeAvailability;

                                  return InkWell(
                                    onTap: () {
                                      Navigator.pop(context, lockerData);
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: 20, right: 20, top: 20),
                                      padding: EdgeInsets.only(
                                          left: 15, top: 24, bottom: 24),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 3,
                                              blurRadius: 5,
                                              offset: Offset(0, 3),
                                            )
                                          ]),
                                      child: Row(
                                        children: [
                                          Image.network(lockerData.imageUrl,
                                              fit: BoxFit.fill,
                                              height: 81.0,
                                              width: 81.0, errorBuilder:
                                                  (context, error, stackTrace) {
                                            return Image.asset(
                                                "assets/images/ic_dummy_locker.png",
                                                fit: BoxFit.fill,
                                                height: 81.0,
                                                width: 81.0);
                                          }),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomWidget().textWithOverflow(
                                                  lockerData.name,
                                                  PopboxColor.mdBlack1000,
                                                  FontWeight.w600,
                                                  12.0.sp,
                                                ),
                                                CustomWidget().textWithOverflow(
                                                  lockerData.buildingType,
                                                  PopboxColor.mdRed300,
                                                  FontWeight.w400,
                                                  11.0.sp,
                                                ),
                                                CustomWidget().textWithOverflow(
                                                  lockerData.city,
                                                  PopboxColor.mdBlack1000,
                                                  FontWeight.normal,
                                                  11.0.sp,
                                                ),
                                                SizedBox(height: 10),
                                                CustomWidget().textWithOverflow(
                                                  listSizeLocker.join(" / "),
                                                  PopboxColor.mdBlack1000,
                                                  FontWeight.normal,
                                                  11.0.sp,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        )),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 1500));
    var lockerModel = Provider.of<LockerViewModel>(context, listen: false);
    lockerDataList.clear();
    lockerModel.newLockerList.clear();
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
            });
          },
          onError: (_) {},
          context: context,
          lockerPayload: lockerPayload,
          myLatLng: new LatLng(SharedPreferencesService().myLat,
              SharedPreferencesService().myLng));
    }

    setState(() {
      checkedIndex = -1;
      // lockerDataList = [];
      // lockerDataList = lockerModel.newLockerList;
    });
  }

  void _runSearch(String inputKeyword) {
    var lockerModel = Provider.of<LockerViewModel>(context, listen: false);
    isSearch = true;
    lockerDataList = lockerModel.newLockerList;
    List results;
    if (inputKeyword.isEmpty) {
      isSearch = false;
      results = lockerDataList;
    } else {
      results = lockerDataList
          .where((element) =>
              element.name.toLowerCase().contains(inputKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      checkedIndex = -1;
      lockerDataList = results;
    });
  }

  Widget lockerTypeItem(int index, String title) {
    bool checked = index == checkedIndex;

    return GestureDetector(
      onTap: () {
        var lockerModel = Provider.of<LockerViewModel>(context, listen: false);
        setState(
          () {
            isNearest = false;
            checkedIndex = index;

            lockerDataList = [];

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
                  }
                }
              }
            } else if (checkedIndex == 1) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "Apartment/Residential") {
                  lockerDataList.add(item);
                }
              }
            } else if (checkedIndex == 2) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "Shopping Mall") {
                  lockerDataList.add(item);
                }
              }
            } else if (checkedIndex == 3) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "Railway Station") {
                  lockerDataList.add(item);
                }
              }
            } else if (checkedIndex == 4) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "Office") {
                  lockerDataList.add(item);
                }
              }
            } else if (checkedIndex == 5) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "Super/Mini Market") {
                  lockerDataList.add(item);
                }
              }
            } else if (checkedIndex == 6) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "University") {
                  lockerDataList.add(item);
                }
              }
            } else if (checkedIndex == 7) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "Worship Place") {
                  lockerDataList.add(item);
                }
              }
            } else if (checkedIndex == 8) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "Gas Station") {
                  lockerDataList.add(item);
                }
              }
            } else if (checkedIndex == 9) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "Other Public Area") {
                  lockerDataList.add(item);
                }
              }
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
              )),
        ),
      ),
    );
  }

  void openMaps(BuildContext context) async {
    final serviceStatus = await Permission.locationWhenInUse.serviceStatus;
    final isGpsOn = serviceStatus == ServiceStatus.enabled;
    if (!isGpsOn) {
      print("Turn on location services berfore request permission");
      return;
    }
    final status = await Permission.locationWhenInUse.request();
    if (status == PermissionStatus.granted) {
      print("Open Maps Location => Status Permission Granted");
      if (Platform.isAndroid) {
        //dev if Andro ?
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MapsPage(
                  isDetail: false,
                )));
      } else if (Platform.isIOS) {
        //dev if iOS ?
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MapsPage(
                  isDetail: false,
                )));
      }
    } else if (status == PermissionStatus.denied) {
      print("Open Maps Location => Status Denied");
    } else if (status == PermissionStatus.permanentlyDenied) {
      print("Open Maps Location => Status Permanante");
      await openAppSettings();
    }
  }

  setCurrencyAndCountry() {
    String localFormat = "";
    if (SharedPreferencesService().locationSelected == "ID") {
      localFormat = 'id_ID';
      unit = "Jam";
    } else if (SharedPreferencesService().locationSelected == "MY") {
      localFormat = 'ms_MY';
      unit = "Jem";
    } else {
      localFormat = 'fil_PH';
      unit = "Hours";
    }
    formatCurrency = new NumberFormat.simpleCurrency(locale: localFormat);
  }
}
