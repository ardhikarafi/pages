import 'dart:io';

import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/locker/locker_city_data.dart';
import 'package:new_popbox/core/models/callback/locker/locker_data.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/locker_viewmodel.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:map_launcher/map_launcher.dart' as Maplauncher;

class LocationListPage extends StatefulWidget {
  final String from;

  const LocationListPage({Key key, this.from}) : super(key: key);
  @override
  _LocationListPageState createState() => _LocationListPageState();
}

class _LocationListPageState extends State<LocationListPage> {
  TextEditingController searchController = new TextEditingController();
  List<LockerData> lockerDataList = [];

  bool isSearch = false;
  int lengthOfItem = 6;
  bool isExpand = false;
  @override
  void initState() {
    var lockerModel = Provider.of<LockerViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        searchController.addListener(() {
          setState(() {
            isSearch = false;
            lockerDataList = [];
            checkedCityIndex = -1;
            checkedLockerIndex = -1;
          });

          if (searchController.text.length > 2) {
            setState(() {
              isSearch = true;
              String keyword = searchController.text
                  .toLowerCase()
                  .replaceAll("apartment", "apt.")
                  .replaceAll("apartemen", "apt.");

              for (var lockerData in lockerModel.newLockerList) {
                if (lockerData.name
                        .toLowerCase()
                        .contains(keyword.toLowerCase()) ||
                    lockerData.city
                        .toLowerCase()
                        .contains(keyword.toLowerCase()) ||
                    lockerData.address
                        .toLowerCase()
                        .contains(keyword.toLowerCase())) {
                  lockerDataList.add(lockerData);
                }
              }

              if (lockerDataList != null && lockerDataList.length > 0) {
                lockerDataList.sort((a, b) => a.name.compareTo(b.name));
              }
            });
          }
          //print('First text field: ' + searchController.text);
        });
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          elevation: 0.5,
          backgroundColor: PopboxColor.mdWhite1000,
          title: CustomWidget().textAppBar(
              AppLocalizations.of(context)
                  .translate(LanguageKeys.searchLocation),
              PopboxColor.mdBlack1000,
              16,
              TextAlign.center),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 30.0, bottom: 20),
              child: TextField(
                controller: searchController,
                enableInteractiveSelection: false,
                cursorColor: PopboxColor.mdGrey900,
                keyboardType: TextInputType.text,
                style: TextStyle(
                  color: PopboxColor.mdGrey900,
                  fontSize: 12,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      .translate(LanguageKeys.search),
                  hintStyle: TextStyle(color: PopboxColor.mdGrey500),
                  filled: true,
                  fillColor: PopboxColor.popboxGreyPopsafe,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide:
                        BorderSide(color: PopboxColor.mdGrey300, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: PopboxColor.mdGrey300),
                  ),
                  contentPadding: EdgeInsets.only(
                    bottom: 50.0 / 2,
                    left: 12.0,
                    right: 0.0,
                  ),
                  suffixIcon: Container(
                    width: 4.0,
                    height: 4.0,
                    padding: const EdgeInsets.only(right: 12.0, left: 16.0),
                    child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Icon(Icons.search, color: Colors.grey)),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 20, bottom: 15),
                child: CustomWidget().textBoldPlus(
                  AppLocalizations.of(context)
                      .translate(LanguageKeys.listOfCityLocation),
                  PopboxColor.mdBlack1000,
                  14,
                  TextAlign.left,
                ),
              ),
            ),
            Flexible(
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.0, top: 0.0),
                  child: contentWidget()),
            ),
            (isExpand == true)
                ? Container()
                : InkWell(
                    onTap: () {
                      setState(() {
                        isExpand = true;
                      });
                    },
                    child: CustomWidget().textLight(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.showAllArea),
                      PopboxColor.blue477FFF,
                      12,
                      TextAlign.center,
                    ),
                  )
          ],
        ));
  }

  Widget contentWidget() {
    if (isSearch && lockerDataList != null && lockerDataList.length > 0) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: lockerDataList.length,
        itemBuilder: (context, position) {
          LockerData lockerData = lockerDataList[position];
          return lockerItem(position, lockerData);
        },
      );
    } else if (isSearch &&
        (lockerDataList == null || lockerDataList.length == 0)) {
      return CustomWidget().lockerNotFound(context);
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: isExpand
            ? SharedPreferencesService().lockerCityResponse.data.length
            : lengthOfItem,
        itemBuilder: (context, position) {
          LockerCityData lockerCityData =
              SharedPreferencesService().lockerCityResponse.data[position];
          return lockerCityItem(position, lockerCityData.city);
        },
      );
    }
  }

  int checkedCityIndex = -1;
  Widget lockerCityItem(int index, String title) {
    bool checked = index == checkedCityIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          checkedCityIndex = index;

          if (checkedCityIndex == 0) {
            Navigator.pop(context, {"finalData": null, "isAll": true});
          } else {
            List<LockerData> finalData = [];
            var lockerModel =
                Provider.of<LockerViewModel>(context, listen: false);
            for (var lockerData in lockerModel.newLockerList) {
              if (lockerData.city.toLowerCase().contains(title.toLowerCase())) {
                finalData.add(lockerData);
              }
            }

            Navigator.pop(context, {"finalData": finalData, "isAll": false});
          }
        });
      },
      child: Container(
        height: 59,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
                  child: CustomWidget().textBold(
                    title,
                    PopboxColor.mdBlack1000,
                    12,
                    TextAlign.left,
                  ),
                ),
                checked
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
                            child: Image.asset(
                              "assets/images/ic_checked_green.png",
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 4.0),
              child: Divider(
                height: 1.0,
                color: Colors.grey,
              ),
            )
          ],
        ),
      ),
    );
  }

  int checkedLockerIndex = -1;
  Widget lockerItem(int index, LockerData lockerData) {
    bool checked = index == checkedLockerIndex;
    return GestureDetector(
      onTap: () {
        showPopUpDetailLocation(context: context, lockerData: lockerData);
      },
      child: Container(
        height: 59,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 100.0.w,
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
                  child: CustomWidget().textBold(
                    lockerData.name,
                    PopboxColor.mdBlack1000,
                    12,
                    TextAlign.left,
                  ),
                ),
                checked
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
                            child: Image.asset(
                              "assets/images/ic_checked_green.png",
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
            Container(
              height: 0.5,
              width: 80.0.w,
              color: PopboxColor.popboxGreyECE9E9,
            ),
          ],
        ),
      ),
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
                                      // _showLockerImage(lockerData);
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
                            // Container(
                            //   margin: const EdgeInsets.only(
                            //       left: 20, right: 20, top: 20),
                            //   child: Row(
                            //     mainAxisAlignment:
                            //         MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       CustomWidget().textBold(
                            //         AppLocalizations.of(context).translate(
                            //             LanguageKeys.lockerAvailable),
                            //         PopboxColor.popboxBlack919191,
                            //         12,
                            //         TextAlign.left,
                            //       ),
                            //       InkWell(
                            //         onTap: () {
                            //           // showPopUpLockerSizeDetails(
                            //           //     context: context);
                            //         },
                            //         child: CustomWidget().textBold(
                            //           AppLocalizations.of(context).translate(
                            //               LanguageKeys.lockerSizeDetail),
                            //           PopboxColor.blue477FFF,
                            //           12,
                            //           TextAlign.left,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // ListView.builder(
                            //     shrinkWrap: true,
                            //     physics: ClampingScrollPhysics(),
                            //     itemCount:
                            //         StaticData().getListOfLockersize().length,
                            //     itemBuilder: (BuildContext context, index) {
                            //       String item =
                            //           StaticData().getListOfLockersize()[index];

                            //       return InkWell(
                            //         onTap: () {
                            //           if ((lockerData.sizeAvailability
                            //               .contains(item))) {
                            //             print("choose AVAILABLE => " + item);
                            //           } else {
                            //             print("NOT AVAILABLE");
                            //           }
                            //         },
                            //         child: lockerItem(context, item, lockerData,
                            //             index, setstateBuilder),
                            //       );
                            //     }),
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
                      // showPopsafe
                      //     ? InkWell(
                      //         onTap: () {
                      //           if (userData.isGuest == true ||
                      //               userData == null) {
                      //             Navigator.of(context).push(MaterialPageRoute(
                      //                 builder: (context) => LoginPage()));
                      //           } else {
                      //             if (selectedLockerSize == "") {
                      //               CustomWidget().showCustomDialog(
                      //                   context: context,
                      //                   msg: AppLocalizations.of(context)
                      //                       .translate(LanguageKeys
                      //                           .pleaseSelectLockerSize));
                      //             } else {
                      //               Navigator.of(context).push(
                      //                 MaterialPageRoute(
                      //                   builder: (context) => PopsafePage(
                      //                     selectedLocker: selectedLockerSize,
                      //                     lockerData: lockerData,
                      //                     from: 'location_detail_page',
                      //                   ),
                      //                 ),
                      //               );
                      //             }
                      //           }
                      //         },
                      //         child: Container(
                      //           padding: const EdgeInsets.only(
                      //               left: 16, right: 16, bottom: 16, top: 16),
                      //           decoration: BoxDecoration(
                      //             color: PopboxColor.popboxGreyPopsafe,
                      //           ),
                      //           child: CustomWidget().customColorButton(
                      //               context,
                      //               AppLocalizations.of(context)
                      //                   .translate(LanguageKeys.orderNow),
                      //               PopboxColor.red,
                      //               PopboxColor.mdWhite1000),
                      //         ),
                      //       )
                      //     : Container()
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  // Future scan() async {
  //   try {
  //     var result = await BarcodeScanner.scan().then((value) {
  //       if (value != null) {
  //         print("barcode : " + value.rawContent);
  //         setState(() => this.barcode = value.toString());
  //       }
  //     });

  //     //setState(() => this.barcode = barcode);
  //   } on PlatformException catch (e) {
  //     if (e.code == BarcodeScanner.cameraAccessDenied) {
  //       setState(() {
  //         this.barcode = 'The user did not grant the camera permission!';
  //       });
  //     } else {
  //       setState(() => this.barcode = 'Unknown error: $e');
  //     }
  //   } on FormatException {
  //     setState(() => this.barcode =
  //         'null (User returned using the "back"-button before scanning anything. Result)');
  //   } catch (e) {
  //     setState(() => this.barcode = 'Unknown error: $e');
  //   }
  // }
}
