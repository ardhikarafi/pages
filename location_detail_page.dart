import 'dart:io';

import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/locker/locker_data.dart';
import 'package:new_popbox/core/models/callback/user/user_login_data.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/ui/item/locker_detail_info_item.dart';
import 'package:new_popbox/ui/pages/login_page.dart';
import 'package:new_popbox/ui/pages/popsafe_page.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/rendering.dart';

class LocationDetailPage extends StatefulWidget {
  LockerData lockerData;

  LocationDetailPage({Key key, this.lockerData});

  @override
  _LocationDetailPageState createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  LockerData lockerData;
  ScrollController _controller;
  bool silverCollapsed = false;
  String myTitle = "";
  String selectedLockerSize = "";
  Color favoriteColor = PopboxColor.mdGrey100;
  UserLoginData userData = new UserLoginData();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userData = await SharedPreferencesService().getUser();
    });

    _controller = ScrollController();

    _controller.addListener(
      () {
        if (_controller.offset > 220 && !_controller.position.outOfRange) {
          if (!silverCollapsed) {
            // do what ever you want when silver is collapsing !

            myTitle = lockerData.name;
            favoriteColor = PopboxColor.mdRed100;
            silverCollapsed = true;
            setState(() {});
          }
        }
        if (_controller.offset <= 220 && !_controller.position.outOfRange) {
          if (silverCollapsed) {
            // do what ever you want when silver is expanding !

            myTitle = "";
            favoriteColor = PopboxColor.mdGrey100;
            silverCollapsed = false;
            setState(() {});
          }
        }
      },
    );

    setState(() {
      this.lockerData = widget.lockerData;
    });

    //print("lockerData : " + lockerData.lockerId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;
    int sizeAvailabilityLength = lockerData.sizeAvailability.length;
    bool isSizeAvailability = true;
    if (sizeAvailabilityLength == 0) {
      isSizeAvailability = false;
    }
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          controller: _controller,
          headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: PopboxColor.popboxRed,
                automaticallyImplyLeading: true,
                leading: IconButton(
                  icon: Image.asset(
                    "assets/images/ic_back_black.png",
                    //fit: BoxFit.fitHeight,
                    height: 16.0,
                    width: 16.0,
                    color: PopboxColor.mdWhite1000,
                  ),
                  onPressed: () => Navigator.pop(
                    context,
                    false,
                  ),
                ),
                expandedHeight: 35.0.h,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  collapseMode: CollapseMode.pin,
                  title: Padding(
                    padding: EdgeInsets.only(bottom: 2.0),
                    child: CustomWidget().textBoldProduct(
                      myTitle,
                      PopboxColor.mdWhite1000,
                      12.0.sp,
                      1,
                    ),
                  ),
                  background: Image.network(
                    lockerData.imageUrl,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/images/ic_dummy_locker.png",
                        fit: BoxFit.cover,
                      );
                    },
                    fit: BoxFit.cover,
                  ),
                ),
                actions: <Widget>[],
              )
            ];
          },
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  silverCollapsed
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05)
                      : SizedBox(),
                  Container(
                    padding: EdgeInsets.fromLTRB(16.0, 28.0, 16.0, 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomWidget().textBoldProduct(
                            lockerData.name, PopboxColor.mdGrey900, 14.0.sp, 2),
                        Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: CustomWidget().textMediumProduct(
                              lockerData.address,
                              PopboxColor.mdGrey700,
                              12.0.sp,
                              3),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 120.0,
                              padding: EdgeInsets.only(top: 8.0, bottom: 0.0),
                              child: CustomButtonGeneral(
                                onPressed: () async {
                                  //print("mnsfknf");
                                  if (lockerData.latitude != null &&
                                      lockerData.latitude != "" &&
                                      lockerData.latitude != "-") {
                                    if (Platform.isIOS) {
                                      await MapLauncher.launchMap(
                                        mapType: MapType.apple,
                                        coords: Coords(
                                            double.parse(lockerData.latitude),
                                            double.parse(lockerData.longitude)),
                                        title: lockerData.name,
                                        description: lockerData.address,
                                      );
                                    } else {
                                      await MapLauncher.launchMap(
                                        mapType: MapType.google,
                                        coords: Coords(
                                            double.parse(lockerData.latitude),
                                            double.parse(lockerData.longitude)),
                                        title: lockerData.name,
                                        description: lockerData.address,
                                      );
                                    }
                                  }
                                },
                                title: AppLocalizations.of(context)
                                    .translate(LanguageKeys.seeLocation),
                                bgColor: PopboxColor.mdWhite1000,
                                textColor: PopboxColor.popboxRed,
                                fontSize: 11.0.sp,
                                height: 32.0,
                                borderColor: PopboxColor.popboxRed,
                                width: 10.0.w,
                              ),
                            ),
                            lockerData.distance < 50001
                                ? CustomWidget().textBoldProduct(
                                    lockerData.distance.toString() + " km",
                                    PopboxColor.mdGrey500,
                                    11.0.sp,
                                    1)
                                : Container(),
                          ],
                        )
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey),
                  Container(
                    padding: EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomWidget().textBoldProduct(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.lockerAvailable),
                            PopboxColor.mdGrey900,
                            10.0.sp,
                            2),
                        CustomWidget().textRegular(
                            AppLocalizations.of(context).translate(LanguageKeys
                                .locationDetailChooseLockerMoreInfo),
                            PopboxColor.mdGrey900,
                            10.0.sp,
                            TextAlign.left),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 8.0, bottom: 0.0, left: 0.0, right: 0.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            child: sizeAvalabilityWidget(
                                isSizeAvailability, sizeAvailabilityLength),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: Divider(color: Colors.grey),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LockerDetailInfoItem(
                            title: AppLocalizations.of(context)
                                .translate(LanguageKeys.location),
                            addressDetail: lockerData.addressDetail),
                        Divider(color: Colors.grey),
                        LockerDetailInfoItem(
                            title: AppLocalizations.of(context)
                                .translate(LanguageKeys.operational),
                            addressDetail: lockerData.operationalHour),
                        Divider(color: Colors.grey),
                      ],
                    ),
                  ),
                  SharedPreferencesService().isMyV3ShowPopsafeVersion ==
                              false &&
                          SharedPreferencesService().locationSelected == "MY"
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 16.0,
                                  top: 18.0,
                                  right: 16.0,
                                  bottom: 8.0),
                              child: CustomButtonRedSmaller(
                                onPressed: () {
                                  if (userData.isGuest == true ||
                                      userData == null) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage()));
                                  } else {
                                    if (checkedIndex < 0) {
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
                                title: AppLocalizations.of(context)
                                    .translate(LanguageKeys.orderNow),
                                fontSize: 11.0.sp,
                                height: 50.0,
                                width: 90.0.w,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget sizeAvalabilityWidget(bool isSizeAvalability, int length) {
    if (isSizeAvalability) {
      return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: length,
        itemBuilder: (context, index) {
          String sizeAvailability = "-";

          try {
            sizeAvailability = lockerData.sizeAvailability[index];
          } catch (e) {}

          return Container(
            margin: EdgeInsets.only(right: 21),
            width: 40,
            child: lockerSizeItem(
              index,
              sizeAvailability,
            ),
          );
        },
      );
    } else {
      return CustomWidget().textBold(
        "-",
        PopboxColor.mdBlack1000,
        13.0.sp,
        TextAlign.center,
      );
    }
  }

  Widget _buildFab() {
    //starting fab position
    final double defaultTopMargin = 216.0 - 4.0;
    //pixels from top where scaling should start
    final double scaleStart = 96.0;
    //pixels from top where scaling should end
    final double scaleEnd = scaleStart / 2;

    double top = defaultTopMargin;
    double scale = 1.0;
    if (_controller.hasClients) {
      double offset = _controller.offset;
      top -= offset;
      if (offset < defaultTopMargin - scaleStart) {
        //offset small => don't scale down
        scale = 1.0;
      } else if (offset < defaultTopMargin - scaleEnd) {
        //offset between scaleStart and scaleEnd => scale down
        scale = (defaultTopMargin - scaleEnd - offset) / scaleEnd;
      } else {
        //offset passed scaleEnd => hide fab
        scale = 0.0;
      }
    }

    return new Positioned(
      top: top,
      right: 16.0,
      child: new Transform(
        transform: new Matrix4.identity()..scale(scale),
        alignment: Alignment.center,
        child: new FloatingActionButton(
          onPressed: () => {},
          child: new Icon(Icons.add),
        ),
      ),
    );
  }

  int checkedIndex = -1;

  Widget lockerSizeItem(int index, String title) {
    bool checked = index == checkedIndex;
    return GestureDetector(
        onTap: () {
          if (mounted) {
            setState(() {
              checkedIndex = index;
              selectedLockerSize = title;
            });
          }
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: 1.0.h,
              minWidth: 1.0.w,
              maxWidth: 100.0.w,
              maxHeight: 100.0.h),
          child: RawMaterialButton(
            fillColor: PopboxColor.mdGrey200,
            splashColor: PopboxColor.mdWhite1000,
            child: CustomWidget().textBold(
              title,
              checked ? PopboxColor.mdRed400 : PopboxColor.mdBlack1000,
              12.0.sp,
              TextAlign.center,
            ),
            onPressed: null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(
                width: 2,
                color: checked ? PopboxColor.mdRed400 : PopboxColor.mdGrey200,
              ),
            ),
          ),
        ));
  }
}
