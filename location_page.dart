import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart' as Maplauncher;
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/locker/locker_data.dart';
import 'package:new_popbox/core/models/callback/user/user_login_data.dart';
import 'package:new_popbox/core/models/list_filter_user_model.dart';
import 'package:new_popbox/core/models/locker_size_model.dart';
import 'package:new_popbox/core/models/payload/locker_payload.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/utils/static_data.dart';
import 'package:new_popbox/core/viewmodel/locker_viewmodel.dart';
import 'package:new_popbox/ui/item/location_filter_item.dart';
import 'package:new_popbox/ui/item/locker_location_item.dart';
import 'package:new_popbox/ui/item/locker_size_item.dart';
import 'package:new_popbox/ui/pages/location_list_page.dart';
import 'package:new_popbox/ui/pages/login_page.dart';
import 'package:new_popbox/ui/pages/maps_page.dart';
import 'package:new_popbox/ui/pages/popsafe_page.dart';
import 'package:new_popbox/ui/widget/app_widget.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:new_popbox/core/utils/global_function.dart';

class LocationPage extends StatefulWidget {
  final String from;

  const LocationPage({Key key, @required this.from}) : super(key: key);
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String _chosenValue;
  int selectedIndex = -1;
  String searchHint = "";
  List<LockerData> lockerDataList = [];
  LatLng myLatLng;
  //
  int checkedIndex = -1;

  bool isNearest = false;
  bool isOnline = false;
  String phoneNumber = SharedPreferencesService().activePhoneNo.toString();
  String country = "indonesia";
  String selectedLockerSize = "";
  //ondevelop
  List<ListFilterUser> listOfFilterUser = [];
  List<String> listOfFilter = [];
  String _valueFilterNearby = "";
  String _valueFilterApart = "";
  String _valueFilterMall = "";
  String _valueFilterRailway = "";
  String _valueFilterOffice = "";
  String _valueFilterMiniMarket = "";
  String _valueFilterUniversity = "";
  String _valueFilterWorship = "";
  String _valueFilterGasStation = "";
  String _valueFilterParkingArea = "";
  String _valueFilterSportCenter = "";
  String _valueFilterOther = "";
  bool checkedValueNearby = false;
  bool checkedValueApart = false;
  bool checkedValueMall = false;
  bool checkedValueRailway = false;
  bool checkedValueOffice = false;
  bool checkedValueMinimartket = false;
  bool checkedValueUniversity = false;
  bool checkedValueWorship = false;
  bool checkedValueGasStation = false;
  bool checkedValueParkingArea = false;
  bool checkedValueSportCenter = false;
  bool checkedValueOther = false;
  UserLoginData userData = new UserLoginData();
  static RemoteConfig _remoteConfig;
  bool showPopsafe;
  SharedPreferencesService sharedPrefService;

  @override
  void initState() {
    _initializeRemoteConfig();
    if (phoneNumber.startsWith("62")) {
      country = "indonesia";
    } else if (phoneNumber.startsWith("60")) {
      country = "malaysia";
    }
    super.initState();

    SharedPreferencesService().setHomeNearestLocation(false);
    var lockerModel = Provider.of<LockerViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userData = await SharedPreferencesService().getUser();
      sharedPrefService = await SharedPreferencesService.instance;
      //locationSelected
      hasNetwork().then((result) {
        if (mounted) {
          setState(() {
            isOnline = result;
          });
        }
      });

      if (widget.from == "nearest") {
        searchHint =
            AppLocalizations.of(context).translate(LanguageKeys.nearest);
      }

      if (lockerModel != null &&
          lockerModel.newLockerList != null &&
          lockerModel.newLockerList.length > 0) {
        lockerDataList = [];
        if (searchHint == null || searchHint == "") {
          lockerDataList = [];
          lockerDataList = lockerModel.newLockerList;
        }
        lockerDataList.sort((a, b) => a.distance.compareTo(b.distance));
      } else {
        LockerPayload lockerPayload = new LockerPayload();
        lockerPayload.token = GlobalVar.API_TOKEN;

        lockerPayload.countryName = country;
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

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          determinePosition(context).then((value) => myLatLng = value);
        });
      }
    });

    if (widget.from == "nearest") {
      lockerDataList = [];
      lockerDataList = lockerModel.newLockerList;

      checkedIndex = 0;
      isNearest = true;

      if (isNearest) {
        isNearest = false;

        lockerDataList = [];

        if (checkedIndex == 0) {
          int nearestCounter = 0;

          List<LockerData> tempLockerDataList = lockerModel.newLockerList;
          if (tempLockerDataList != null && tempLockerDataList.length > 0) {
            tempLockerDataList.sort((a, b) => a.distance.compareTo(b.distance));
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
        }
      } else {
        lockerDataList.sort((a, b) => a.name.compareTo(b.name));
      }
    }
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

  @override
  void dispose() {
    listOfFilterUser.clear();
    listOfFilter.clear();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 1500));
    lockerDataList.clear();

    searchHint = "";
    //devrafi
    var lockerModel = Provider.of<LockerViewModel>(context, listen: false);
    lockerModel.newLockerList.clear();

    if (lockerModel.newLockerList == null ||
        lockerModel.newLockerList.length == 0) {
      LockerPayload lockerPayload = new LockerPayload();
      lockerPayload.token = GlobalVar.API_TOKEN;
      lockerPayload.countryName = country;
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
      _valueFilterNearby = null;
      _valueFilterApart = null;
      _valueFilterMall = null;
      _valueFilterRailway = null;
      _valueFilterOffice = null;
      _valueFilterMiniMarket = null;
      _valueFilterUniversity = null;
      _valueFilterWorship = null;
      _valueFilterGasStation = null;
      _valueFilterParkingArea = null;
      _valueFilterSportCenter = null;
      _valueFilterOther = null;
      listOfFilterUser = [];
    });
  }

  //Check Connection
  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // print("=====>Internet Tersambung");
        isOnline = true;
        return true;
      }

      return false;
    } catch (e) {
      isOnline = false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!isOnline) {
      return cartShimmerView(context);
    }
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: widget.from == "home" || widget.from == "nearest"
              ? GeneralAppBarView(
                  title: AppLocalizations.of(context)
                      .translate(LanguageKeys.lockerLocation),
                )
              : DetailAppBarViewCloseIcon(
                  title: AppLocalizations.of(context)
                      .translate(LanguageKeys.chooseLockerSafe),
                )),
      body: Container(
          margin: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Consumer<LockerViewModel>(
            builder: (context, model, _) {
              if (model.loading) return cartShimmerView(context);

              if (model.newLockerList == null) {
                return Container();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                builder: (context) => LocationListPage(),
                              ),
                            )
                                .then((value) {
                              setState(() {
                                checkedIndex = -1;
                                lockerDataList = [];

                                if (value["isAll"] == true) {
                                  _refresh();

                                  searchHint = AppLocalizations.of(context)
                                      .translate(LanguageKeys.location);
                                } else {
                                  lockerDataList = value["finalData"];
                                  searchHint = lockerDataList[0].city;
                                }
                              });
                            });
                          },
                          child: Container(
                            width: 72.0.w,
                            //height: 45.0,
                            decoration: BoxDecoration(
                                color: PopboxColor.popboxGreyPopsafe,
                                borderRadius: BorderRadius.circular(8.0)),
                            padding:
                                const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              underline: Container(),
                              icon: Icon(Icons.search),
                              value: _chosenValue,
                              items: <String>[].map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: CustomWidget().textLight(
                                      value,
                                      PopboxColor.mdGrey900,
                                      12,
                                      TextAlign.left),
                                );
                              }).toList(),
                              hint: CustomWidget().textLight(
                                  searchHint == ""
                                      ? AppLocalizations.of(context)
                                          .translate(LanguageKeys.location)
                                      : searchHint,
                                  PopboxColor.mdGrey900,
                                  12,
                                  TextAlign.left),
                              onChanged: (String value) {
                                if (mounted) {
                                  setState(() {
                                    _chosenValue = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            openMaps(context);
                          },
                          child: Container(
                            width: 19.0.w,
                            height: 50,
                            child: Center(
                              child: CustomWidget().textRegular(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.seeMap),
                                  PopboxColor.blue477FFF,
                                  12,
                                  TextAlign.center),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: CustomWidget().textBoldPlus(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.listOfLockerPopbox),
                      PopboxColor.mdBlack1000,
                      14,
                      TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    height: 33.0,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            showPopUpFilter(context: context);
                          },
                          child: LocationFilterItem(
                              isIcon: true,
                              service: "Filter",
                              color: PopboxColor.popboxGrey575757),
                        ),
                        LocationFilterItem(
                            isIcon: false,
                            service: AppLocalizations.of(context)
                                .translate(LanguageKeys.nearest),
                            color: PopboxColor.popboxRed),
                        Expanded(
                          child: ListView.builder(
                            itemCount: listOfFilterUser.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, index) {
                              String item =
                                  listOfFilterUser[index].nameTranslated;
                              return InkWell(
                                  onTap: () {
                                    // print("on TAP => " + item);
                                  },
                                  child: LocationFilterItem(
                                    isIcon: false,
                                    service: item,
                                    color: PopboxColor.popboxRed,
                                  ));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
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
                                      context, "location_page")),
                            ]),
                          )
                        : RefreshIndicator(
                            onRefresh: _refresh,
                            child: ListView.builder(
                                itemCount: lockerDataList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  LockerData lockerData = lockerDataList[index];
                                  return InkWell(
                                    onTap: () {
                                      if (mounted) {
                                        setState(() {
                                          if (selectedIndex != index) {
                                            selectedIndex = index;

                                            if (widget.from == 'popsafe') {
                                              Navigator.pop(
                                                  context, lockerData);
                                            } else {
                                              showPopUpDetailLocation(
                                                context: context,
                                                lockerData: lockerData,
                                              );
                                            }
                                          } else {
                                            selectedIndex = -1;
                                          }
                                        });
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      child: LockerLocationItem(
                                        lockerData: lockerData,
                                      ),
                                    ),
                                  );
                                }),
                          )),
                  ),
                ],
              );
            },
          )),
    );
  }

  int checkedLockerSize = -1;
  Widget lockerItem(BuildContext context, String item, LockerData lockerData,
      int index, Function stateBuilder) {
    bool checked = index == checkedLockerSize;
    return GestureDetector(
      onTap: () {
        if (showPopsafe) {
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
            // print("lockerItem => " + selectedLockerSize.toString());
          }
        } else {}
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

  Widget lockerTypeItem(int index, String title) {
    bool checked = index == checkedIndex;
    (searchHint == "") ? checked = false : {};

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

              //lockerDataList.sort((a, b) => a.name.compareTo(b.name));
            } else if (checkedIndex == 2) {
              for (var item in lockerModel.newLockerList) {
                if (item.buildingType == "Shopping Mall") {
                  lockerDataList.add(item);
                }
              }
              //

              //lockerDataList.sort((a, b) => a.name.compareTo(b.name));
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

            searchHint = title;
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

  _showLockerImage(LockerData lockerData) async {
    await Future.delayed(Duration(milliseconds: 50));
    showDialog(
        context: context,
        builder: (BuildContext context) => Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Center(child: Image.network(lockerData.imageUrl)))
        // PhotoView(imageProvider: NetworkImage(lockerData.imageUrl)),
        );
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
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0),
                                            child: Icon(Icons.close)),
                                      ],
                                    ),
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
                                color: PopboxColor.popboxGreyE5E5E5,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //1
                                  CustomWidget().textBoldPlus(
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
                                  SizedBox(height: 8),
                                  CustomWidget().textLight(
                                    lockerData.address,
                                    PopboxColor.mdBlack1000,
                                    12,
                                    TextAlign.left,
                                  ),
                                  SizedBox(height: 8),
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
                                  CustomWidget().textBold(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.location),
                                    PopboxColor.popboxBlack919191,
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
                                  CustomWidget().textBold(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.operational),
                                    PopboxColor.popboxBlack919191,
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
                                        print("NOT AVAILABLE");
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

  void showPopUpFilter({context, LockerData lockerData}) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setstateBuilder) => Container(
              height: MediaQuery.of(context).size.height * 0.65,
              child: Stack(
                children: [
                  //TITLE
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 22.0),
                        child: Stack(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Icon(Icons.arrow_back),
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    CustomWidget().textBold(
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.filter),
                                      PopboxColor.mdBlack1000,
                                      12.0.sp,
                                      TextAlign.center,
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {
                                    print("taptap");
                                    setstateBuilder(() {
                                      checkedValueNearby = false;
                                      checkedValueApart = false;
                                      checkedValueMall = false;
                                      checkedValueRailway = false;
                                      checkedValueOffice = false;
                                      checkedValueMinimartket = false;
                                      checkedValueUniversity = false;
                                      checkedValueWorship = false;
                                      checkedValueGasStation = false;
                                      checkedValueOther = false;
                                      checkedValueParkingArea = false;
                                      checkedValueSportCenter = false;
                                      _valueFilterNearby = null;
                                      _valueFilterApart = null;
                                      _valueFilterMall = null;
                                      _valueFilterRailway = null;
                                      _valueFilterOffice = null;
                                      _valueFilterMiniMarket = null;
                                      _valueFilterUniversity = null;
                                      _valueFilterWorship = null;
                                      _valueFilterGasStation = null;
                                      _valueFilterOther = null;
                                      _valueFilterParkingArea = null;
                                      _valueFilterSportCenter = null;
                                    });
                                    setState(() {
                                      listOfFilterUser = [];
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(right: 30),
                                    child: CustomWidget().textRegular(
                                      "Reset Filter",
                                      PopboxColor.blue477FFF,
                                      12,
                                      TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Divider(
                        height: 1.0,
                        color: Colors.grey,
                      ),
                      //CONTAIN FILTER
                      Expanded(
                          child: Container(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: ListView(
                          children: [
                            // CheckboxListTile(
                            //   title: CustomWidget().textLight(
                            //       AppLocalizations.of(context)
                            //           .translate(LanguageKeys.nearest),
                            //       Colors.black,
                            //       14,
                            //       TextAlign.left),
                            //   activeColor: PopboxColor.red,
                            //   value: checkedValueNearby,
                            //   onChanged: (newValue) {
                            //     setState(() {
                            //       checkedValueNearby = newValue;
                            //       print(checkedValueNearby.toString());
                            //       if (mounted) {
                            //         setState(() {
                            //           if (checkedValueNearby == false) {
                            //             _valueFilterNearby = "";
                            //             listOfFilterUser.removeWhere(
                            //               (element) =>
                            //                   element.nameTranslated ==
                            //                   AppLocalizations.of(context)
                            //                       .translate(
                            //                           LanguageKeys.nearest),
                            //             );
                            //           } else {
                            //             _valueFilterNearby = "Terdekat";
                            //             // listOfFilterUser.add(ListFilterUser(
                            //             //   id: 1,
                            //             //   name: _valueFilterNearby,
                            //             //   nameTranslated: AppLocalizations.of(
                            //             //           context)
                            //             //       .translate(LanguageKeys.nearest),
                            //             // ));
                            //           }
                            //         });
                            //         setstateBuilder(() {});
                            //       }
                            //     });
                            //   },
                            //   controlAffinity: ListTileControlAffinity
                            //       .trailing, //  <-- leading Checkbox
                            // ),
                            CheckboxListTile(
                              title: CustomWidget().textLight(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.apartment),
                                  Colors.black,
                                  14,
                                  TextAlign.left),
                              activeColor: PopboxColor.red,
                              value: checkedValueApart,
                              onChanged: (newValue) {
                                setState(() {
                                  checkedValueApart = newValue;

                                  if (mounted) {
                                    setState(() {
                                      if (checkedValueApart == false) {
                                        _valueFilterApart = "";
                                        listOfFilterUser.removeWhere(
                                          (element) =>
                                              element.nameTranslated ==
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      LanguageKeys.apartment),
                                        );
                                      } else {
                                        _valueFilterApart =
                                            "Apartment/Residential";
                                        listOfFilterUser.add(ListFilterUser(
                                          id: 2,
                                          name: _valueFilterApart,
                                          nameTranslated:
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      LanguageKeys.apartment),
                                        ));
                                      }
                                    });
                                    setstateBuilder(() {});
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .trailing, //  <-- leading Checkbox
                            ),
                            CheckboxListTile(
                              title: CustomWidget().textLight(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.mall),
                                  Colors.black,
                                  14,
                                  TextAlign.left),
                              activeColor: PopboxColor.red,
                              value: checkedValueMall,
                              onChanged: (newValue) {
                                setState(() {
                                  checkedValueMall = newValue;

                                  if (mounted) {
                                    setState(() {
                                      if (checkedValueMall == false) {
                                        _valueFilterMall = "";
                                        listOfFilterUser.removeWhere(
                                          (element) =>
                                              element.nameTranslated ==
                                              AppLocalizations.of(context)
                                                  .translate(LanguageKeys.mall),
                                        );
                                      } else {
                                        _valueFilterMall = "Shopping Mall";
                                        listOfFilterUser.add(ListFilterUser(
                                          id: 3,
                                          name: _valueFilterMall,
                                          nameTranslated:
                                              AppLocalizations.of(context)
                                                  .translate(
                                            LanguageKeys.mall,
                                          ),
                                        ));
                                      }
                                    });
                                    setstateBuilder(() {});
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .trailing, //  <-- leading Checkbox
                            ),
                            CheckboxListTile(
                              title: CustomWidget().textLight(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.railwayStation),
                                  Colors.black,
                                  14,
                                  TextAlign.left),
                              activeColor: PopboxColor.red,
                              value: checkedValueRailway,
                              onChanged: (newValue) {
                                setState(() {
                                  checkedValueRailway = newValue;

                                  if (mounted) {
                                    setState(() {
                                      if (checkedValueRailway == false) {
                                        _valueFilterRailway = "";
                                        listOfFilterUser.removeWhere(
                                          (element) =>
                                              element.nameTranslated ==
                                              AppLocalizations.of(context)
                                                  .translate(LanguageKeys
                                                      .railwayStation),
                                        );
                                      } else {
                                        _valueFilterRailway = "Railway Station";
                                        listOfFilterUser.add(ListFilterUser(
                                          id: 4,
                                          name: _valueFilterRailway,
                                          nameTranslated:
                                              AppLocalizations.of(context)
                                                  .translate(
                                            LanguageKeys.railwayStation,
                                          ),
                                        ));
                                      }
                                    });
                                    setstateBuilder(() {});
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .trailing, //  <-- leading Checkbox
                            ),
                            CheckboxListTile(
                              title: CustomWidget().textLight(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.office),
                                  Colors.black,
                                  14,
                                  TextAlign.left),
                              activeColor: PopboxColor.red,
                              value: checkedValueOffice,
                              onChanged: (newValue) {
                                setState(() {
                                  checkedValueOffice = newValue;

                                  if (mounted) {
                                    setState(() {
                                      if (checkedValueOffice == false) {
                                        _valueFilterOffice = "";
                                        listOfFilterUser.removeWhere(
                                          (element) =>
                                              element.nameTranslated ==
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      LanguageKeys.office),
                                        );
                                      } else {
                                        _valueFilterOffice = "Office";
                                        listOfFilterUser.add(ListFilterUser(
                                          id: 5,
                                          name: _valueFilterOffice,
                                          nameTranslated:
                                              AppLocalizations.of(context)
                                                  .translate(
                                            LanguageKeys.office,
                                          ),
                                        ));
                                      }
                                    });
                                    setstateBuilder(() {});
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .trailing, //  <-- leading Checkbox
                            ),
                            CheckboxListTile(
                              title: CustomWidget().textLight(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.superMarket),
                                  Colors.black,
                                  14,
                                  TextAlign.left),
                              activeColor: PopboxColor.red,
                              value: checkedValueMinimartket,
                              onChanged: (newValue) {
                                setState(() {
                                  checkedValueMinimartket = newValue;

                                  if (mounted) {
                                    setState(() {
                                      if (checkedValueMinimartket == false) {
                                        _valueFilterMiniMarket = "";
                                        listOfFilterUser.removeWhere(
                                          (element) =>
                                              element.nameTranslated ==
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      LanguageKeys.superMarket),
                                        );
                                      } else {
                                        _valueFilterMiniMarket =
                                            "Super/Mini Market";
                                        listOfFilterUser.add(ListFilterUser(
                                          id: 6,
                                          name: _valueFilterMiniMarket,
                                          nameTranslated:
                                              AppLocalizations.of(context)
                                                  .translate(
                                            LanguageKeys.superMarket,
                                          ),
                                        ));
                                      }
                                    });
                                    setstateBuilder(() {});
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .trailing, //  <-- leading Checkbox
                            ),
                            CheckboxListTile(
                              title: CustomWidget().textLight(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.university),
                                  Colors.black,
                                  14,
                                  TextAlign.left),
                              activeColor: PopboxColor.red,
                              value: checkedValueUniversity,
                              onChanged: (newValue) {
                                setState(() {
                                  checkedValueUniversity = newValue;

                                  if (mounted) {
                                    setState(() {
                                      if (checkedValueUniversity == false) {
                                        _valueFilterUniversity = "";
                                        listOfFilterUser.removeWhere(
                                          (element) =>
                                              element.nameTranslated ==
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      LanguageKeys.university),
                                        );
                                      } else {
                                        _valueFilterUniversity = "University";
                                        listOfFilterUser.add(ListFilterUser(
                                          id: 7,
                                          name: _valueFilterUniversity,
                                          nameTranslated:
                                              AppLocalizations.of(context)
                                                  .translate(
                                            LanguageKeys.university,
                                          ),
                                        ));
                                      }
                                    });
                                    setstateBuilder(() {});
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .trailing, //  <-- leading Checkbox
                            ),
                            (sharedPrefService.locationSelected == "ID")
                                ? CheckboxListTile(
                                    title: CustomWidget().textLight(
                                        AppLocalizations.of(context).translate(
                                            LanguageKeys.worshipPlace),
                                        Colors.black,
                                        14,
                                        TextAlign.left),
                                    activeColor: PopboxColor.red,
                                    value: checkedValueWorship,
                                    onChanged: (newValue) {
                                      setState(() {
                                        checkedValueWorship = newValue;

                                        if (mounted) {
                                          setState(() {
                                            if (checkedValueWorship == false) {
                                              _valueFilterWorship = "";
                                              listOfFilterUser.removeWhere(
                                                (element) =>
                                                    element.nameTranslated ==
                                                    AppLocalizations.of(context)
                                                        .translate(LanguageKeys
                                                            .worshipPlace),
                                              );
                                            } else {
                                              _valueFilterWorship =
                                                  "Worship Place";
                                              listOfFilterUser
                                                  .add(ListFilterUser(
                                                id: 8,
                                                name: _valueFilterWorship,
                                                nameTranslated:
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                  LanguageKeys.worshipPlace,
                                                ),
                                              ));
                                            }
                                          });
                                          setstateBuilder(() {});
                                        }
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity
                                        .trailing, //  <-- leading Checkbox
                                  )
                                : Container(),
                            CheckboxListTile(
                              title: CustomWidget().textLight(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.gasStation),
                                  Colors.black,
                                  14,
                                  TextAlign.left),
                              activeColor: PopboxColor.red,
                              value: checkedValueGasStation,
                              onChanged: (newValue) {
                                setState(() {
                                  checkedValueGasStation = newValue;

                                  if (mounted) {
                                    setState(() {
                                      if (checkedValueGasStation == false) {
                                        _valueFilterGasStation = "";
                                        listOfFilterUser.removeWhere(
                                          (element) =>
                                              element.nameTranslated ==
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      LanguageKeys.gasStation),
                                        );
                                      } else {
                                        _valueFilterGasStation = "Gas Station";
                                        listOfFilterUser.add(ListFilterUser(
                                          id: 9,
                                          name: _valueFilterGasStation,
                                          nameTranslated:
                                              AppLocalizations.of(context)
                                                  .translate(
                                            LanguageKeys.gasStation,
                                          ),
                                        ));
                                      }
                                    });
                                    setstateBuilder(() {});
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .trailing, //  <-- leading Checkbox
                            ),
                            (sharedPrefService.locationSelected == "ID")
                                ? CheckboxListTile(
                                    title: CustomWidget().textLight(
                                        AppLocalizations.of(context).translate(
                                            LanguageKeys.parkingArea),
                                        Colors.black,
                                        14,
                                        TextAlign.left),
                                    activeColor: PopboxColor.red,
                                    value: checkedValueParkingArea,
                                    onChanged: (newValue) {
                                      setState(() {
                                        checkedValueParkingArea = newValue;

                                        if (mounted) {
                                          setState(() {
                                            if (checkedValueParkingArea ==
                                                false) {
                                              _valueFilterParkingArea =
                                                  ""; //CHANGE
                                              listOfFilterUser.removeWhere(
                                                (element) =>
                                                    element.nameTranslated ==
                                                    AppLocalizations.of(context)
                                                        .translate(LanguageKeys
                                                            .parkingArea),
                                              );
                                            } else {
                                              _valueFilterParkingArea =
                                                  "Parking Area";
                                              listOfFilterUser
                                                  .add(ListFilterUser(
                                                id: 10,
                                                name: _valueFilterParkingArea,
                                                nameTranslated:
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                  LanguageKeys.parkingArea,
                                                ),
                                              ));
                                            }
                                          });
                                          setstateBuilder(() {});
                                        }
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity
                                        .trailing, //  <-- leading Checkbox
                                  )
                                : Container(),
                            //sportCenter
                            (sharedPrefService.locationSelected == "ID")
                                ? CheckboxListTile(
                                    title: CustomWidget().textLight(
                                        AppLocalizations.of(context).translate(
                                            LanguageKeys.sportCenter),
                                        Colors.black,
                                        14,
                                        TextAlign.left),
                                    activeColor: PopboxColor.red,
                                    value: checkedValueSportCenter,
                                    onChanged: (newValue) {
                                      setState(() {
                                        checkedValueSportCenter = newValue;
                                        if (mounted) {
                                          setState(() {
                                            if (checkedValueSportCenter ==
                                                false) {
                                              _valueFilterSportCenter =
                                                  ""; //CHANGE
                                              listOfFilterUser.removeWhere(
                                                (element) =>
                                                    element.nameTranslated ==
                                                    AppLocalizations.of(context)
                                                        .translate(LanguageKeys
                                                            .sportCenter),
                                              );
                                            } else {
                                              _valueFilterSportCenter =
                                                  "Sport Center";
                                              listOfFilterUser
                                                  .add(ListFilterUser(
                                                id: 11,
                                                name: _valueFilterSportCenter,
                                                nameTranslated:
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                  LanguageKeys.sportCenter,
                                                ),
                                              ));
                                            }
                                          });
                                          setstateBuilder(() {});
                                        }
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity
                                        .trailing, //  <-- leading Checkbox
                                  )
                                : Container(),
                            CheckboxListTile(
                              title: CustomWidget().textLight(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.otherPublicArea),
                                  Colors.black,
                                  14,
                                  TextAlign.left),
                              activeColor: PopboxColor.red,
                              value: checkedValueOther,
                              onChanged: (newValue) {
                                setState(() {
                                  checkedValueOther = newValue;

                                  if (mounted) {
                                    setState(() {
                                      if (checkedValueOther == false) {
                                        _valueFilterOther = "";
                                        listOfFilterUser.removeWhere(
                                          (element) =>
                                              element.nameTranslated ==
                                              AppLocalizations.of(context)
                                                  .translate(LanguageKeys
                                                      .otherPublicArea),
                                        );
                                      } else {
                                        _valueFilterOther = "Other Public Area";
                                        listOfFilterUser.add(ListFilterUser(
                                          id: 12,
                                          name: _valueFilterOther,
                                          nameTranslated:
                                              AppLocalizations.of(context)
                                                  .translate(
                                            LanguageKeys.otherPublicArea,
                                          ),
                                        ));
                                      }
                                    });
                                    setstateBuilder(() {});
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .trailing, //  <-- leading Checkbox
                            ),
                            SizedBox(height: 20.0.h),
                          ],
                        ),
                      )),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          var lockerModelTemp = Provider.of<LockerViewModel>(
                              context,
                              listen: false);

                          setState(() {
                            lockerDataList = [];
                            //IF TERDEKAT
                            if (_valueFilterNearby == "Terdekat" ||
                                listOfFilterUser.isEmpty) {
                              int nearestCounter = 0;

                              List<LockerData> tempLockerDataList =
                                  lockerModelTemp.newLockerList;
                              if (tempLockerDataList != null &&
                                  tempLockerDataList.length > 0) {
                                tempLockerDataList.sort(
                                    (a, b) => a.distance.compareTo(b.distance));
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

                              if (lockerDataList == null ||
                                  lockerDataList.length == 0) {
                                nearestCounter++;
                                for (var item in tempLockerDataList) {
                                  if (item.distance <= 50 &&
                                      nearestCounter <= 9) {
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

                              if (lockerDataList == null ||
                                  lockerDataList.length == 0) {
                                for (var item in tempLockerDataList) {
                                  if (item.distance <= 500 &&
                                      nearestCounter <= 9) {
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

                              if (lockerDataList == null ||
                                  lockerDataList.length == 0) {
                                for (var item in tempLockerDataList) {
                                  if (item.distance <= 5000 &&
                                      nearestCounter <= 9) {
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

                              if (lockerDataList == null ||
                                  lockerDataList.length == 0) {
                                for (var item in tempLockerDataList) {
                                  if (item.distance <= 50000 &&
                                      nearestCounter <= 9) {
                                    nearestCounter++;
                                    isNearest = true;
                                    lockerDataList.add(item);
                                  }
                                }
                              }
                            }
                            // else if (listOfFilterUser.isEmpty) {
                            //   lockerDataList.clear();
                            // }
                            //IF ELSE
                            else {
                              var lockerModel = Provider.of<LockerViewModel>(
                                  context,
                                  listen: false);
                              for (var item in lockerModel.newLockerList) {
                                for (int i = 0;
                                    i < listOfFilterUser.length;
                                    i++) {
                                  if (item.buildingType
                                      .contains(listOfFilterUser[i].name)) {
                                    lockerDataList.add(item);
                                  }
                                }
                              }
                              lockerDataList.sort(
                                  (a, b) => a.distance.compareTo(b.distance));
                            }
                          });
                          Navigator.pop(context);
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
                                .translate(LanguageKeys.show),
                            PopboxColor.red,
                            PopboxColor.mdWhite1000,
                          ),
                        ),
                      )
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

void openMaps(BuildContext context) async {
  //start devrafi
  final serviceStatus = await Permission.locationWhenInUse.serviceStatus;
  final isGpsOn = serviceStatus == ServiceStatus.enabled;
  if (!isGpsOn) {
    print("Turn on location services berfore request permission");
    //return;
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
  } else if (status == PermissionStatus.permanentlyDenied ||
      status == PermissionStatus.undetermined) {
    print("Open Maps Location => Status Permanante");
    await openAppSettings();
  }
  // finish

  // Map<Permission, PermissionStatus> statuses = await [
  //   Permission.location,
  // ].request();

  // if (statuses[Permission.location].isGranted) {
  //   Navigator.of(context).push(MaterialPageRoute(
  //       builder: (context) => MapsPage(
  //             isDetail: false,
  //           )));
  // } else if (statuses[Permission.location].isPermanentlyDenied) {
  //   //openAppSettings();
  //   AppSettings.openLocationSettings();
  // } else {
  //   if (Platform.isAndroid) {
  //     Permission.location.request();
  //   } else if (Platform.isIOS) {
  //     Navigator.of(context).push(MaterialPageRoute(
  //         builder: (context) => MapsPage(
  //               isDetail: false,
  //             )));
  //   }
  // }
}
