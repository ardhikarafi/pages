import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:new_popbox/core/bloc/bottom_navigation/bottom_navigation_bloc.dart';
import 'package:new_popbox/core/models/about_popbox_model.dart';
import 'package:new_popbox/core/models/callback/parcel/unfinish_parcel_data.dart';
import 'package:new_popbox/core/utils/hex_color.dart';
import 'package:new_popbox/core/utils/static_data.dart';
import 'package:new_popbox/ui/item/about_popbox_item.dart';
import 'package:new_popbox/ui/pages/home.dart';
import 'package:new_popbox/ui/pages/login_page.dart';
import 'package:new_popbox/ui/pages/popsafe_page.dart';
import 'package:new_popbox/ui/pages/transaction_new_page.dart';
import 'package:new_popbox/ui/widget/help_view.dart';
import 'package:new_popbox/ui/widget/multi_account_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart'
as permission_handler;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/locker/locker_data.dart';
import 'package:new_popbox/core/models/callback/user/user_login_data.dart';
import 'package:new_popbox/core/models/payload/locker_payload.dart';
import 'package:new_popbox/core/models/payload/notification_unread_badge_payload.dart';
import 'package:new_popbox/core/models/payload/promo_payload.dart';
import 'package:new_popbox/core/showcase/showcaseview.dart';
import 'package:new_popbox/core/utils/global_function.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/locker_viewmodel.dart';
import 'package:new_popbox/core/viewmodel/notification_viewmodel.dart';
import 'package:new_popbox/core/viewmodel/promo_viewmodel.dart';
import 'package:new_popbox/ui/item/banner_slider_item.dart';
import 'package:new_popbox/ui/item/locker_home_item.dart';
import 'package:new_popbox/ui/pages/notification_page.dart';
import 'package:new_popbox/ui/pages/search_page.dart';
import 'package:new_popbox/ui/pages/tracking_page.dart';
import 'package:new_popbox/ui/pages/verify_info_page.dart';
import 'package:new_popbox/ui/widget/app_widget.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final bool isShowcase;
  HomePage({Key key, @required this.isShowcase}) : super();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentBannerSlider = 0;
  int _currentAboutSlider = 0;
  UserLoginData userData = new UserLoginData();
  PackageInfo packageInfo;
  GlobalKey _one = GlobalKey();
  //GlobalKey _two = GlobalKey();
  GlobalKey _three = GlobalKey();
  GlobalKey _four = GlobalKey();

  int unreadNotifCounter = 0;
  String isNotification = "on";
  bool isFirstTap = false;
  bool isFirstDisplay;
  int valueLastRecommendUpdate = 0;
  int valueLastRecommendUpdateIos = 0;
  // bool everUpdated = false;
  List<LockerData> lockerDataList = [];
  List<UnfinishParcelData> unfinishParcelList;
  SharedPreferencesService sharedPreferences;
  String dateRemind = SharedPreferencesService().dateRemind;
  int differenceTest;
  int minimumVersion;
  int liveVersion;
  int buildCode;
  int minimumVersionIoS;
  int liveVersionIos;
  String valueCampaign ="";
  String valueLinkCampaign = "";
  Timer _timer;
  String dateNow;

  //Firebase
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);
  bool showSunway;
  bool showPopsafe;
  bool isPopUpRecommendShow = false;
  bool isPopUpForceShow = false;
  static RemoteConfig _remoteConfig;
  List<Widget> itemOfCloser = [];
  List<AboutPopBoxModel> listOfAbout = [];

  @override
  void initState() {
    _initializeRemoteConfig();
    DateTime nowDevice = DateTime.now();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    dateNow = dateFormat.format(nowDevice);

    //DateRemind
    SharedPreferencesService.instance.then((SharedPreferencesService sp) {
      sharedPreferences = sp;
      dateRemind = sharedPreferences.dateRemind;
      showSunway = sharedPreferences.showSunway;
      if (dateRemind == null) {
        dateRemind = "1 Mar 2022 00:00";
        SharedPreferencesService().setRemindLater(dateRemind);
      }
      if (showSunway == null) {
        showSunway = false;
      } else {
        //
      }

      DateTime now = DateTime.now();
      String dateTimeNowFormated = DateFormat('dd MMM yyyy HH:mm').format(now);
      final formatedTime = DateFormat('dd MMM yyyy HH:mm');
      final nowtime = formatedTime.parse(dateTimeNowFormated);
      final starttime = formatedTime.parse(dateRemind);

      if (sharedPreferences.isFirstDisplay != null) {
        isFirstDisplay = sharedPreferences.isFirstDisplay;

      }

      if (sharedPreferences.isFirstTapRecommendUpdate != null) {
        isFirstTap = sharedPreferences.isFirstTapRecommendUpdate;
      }

      if (sharedPreferences.getValueLastRecommendUpdate != null) {
        valueLastRecommendUpdate =
            sharedPreferences.getValueLastRecommendUpdate;
      }
      if (sharedPreferences.getValueLastRecommendUpdateIos != null) {
        valueLastRecommendUpdateIos =
            sharedPreferences.getValueLastRecommendUpdateIos;
      }

      differenceTest = nowtime.difference(starttime).inDays;

      if (SharedPreferencesService().isShowCase == false &&
          SharedPreferencesService().locationSelected == "MY" &&
          SharedPreferencesService().user.palsIsNewUser == true && //true
          differenceTest >= 1 && //PopUp Diff Time >=1
          showSunway == true &&
          (SharedPreferencesService().user.palsStatus == "removed" ||
              SharedPreferencesService().user.palsStatus == "null")) {
        _showDialogSunwayInfo();
      }
    });

    var lockerModel = Provider.of<LockerViewModel>(context, listen: false);
    var promoModel = Provider.of<PromoViewModel>(context, listen: false);
    var notificationModel =
    Provider.of<NotificationViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
        final sharedPrefService = await SharedPreferencesService.instance;
        userData = await SharedPreferencesService().getUser();
        isNotification = await isNotificationOn();
        listOfAbout = StaticData().getListOfAboutPopbox(context: context);

        //GET LIST OF ABOUT POPBOX
        for (var i = 0; i < listOfAbout.length; i++) {
          itemOfCloser.add(AboutPopboxItem(item: listOfAbout[i]));
        }

        Permission.location.status.then((value) {
          if (value.isPermanentlyDenied || value.isUndetermined) {
            if (mounted) {
              getLockers(new LatLng(SharedPreferencesService().myLat,
                  SharedPreferencesService().myLng));
            }

            if (widget.isShowcase && userData.isGuest == false) {
              SharedPreferencesService().setShowCase(false);
              ShowCaseWidget.of(context)
              //.startShowCase([_one, _two, _three, _four]);
                  .startShowCase([_one, _three, _four]);
            }
          } else {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  determinePosition(context).then((value) {
                    if (value != null &&
                        value.latitude != null &&
                        value.latitude != 0.0) {
                      if (mounted) {
                        getLockers(new LatLng(SharedPreferencesService().myLat,
                            SharedPreferencesService().myLng));
                      }

                      if (widget.isShowcase && userData.isGuest == false) {
                        SharedPreferencesService().setShowCase(false);
                        ShowCaseWidget.of(context)
                        //.startShowCase([_one, _two, _three, _four]);
                            .startShowCase([_one, _three, _four]);
                      }
                    }
                  });
                });
              }
            });
          }
        });

        if (userData != null &&
            userData.isGuest == false &&
            widget.isShowcase == false) {}
        if (mounted) {
          PromoPayload promoPayload = new PromoPayload();
          promoPayload.country = sharedPrefService.locationSelected;

          promoPayload.token = GlobalVar.API_TOKEN_INTERNAL;
          await promoModel.getPromoList(
              context: context,
              onSuccess: () {},
              onError: (_) {},
              payload: promoPayload);
        }

        if (mounted) {
          if (notificationModel.notificationUnreadTotal != null) {
            unreadNotifCounter = notificationModel.newNotificationUnreadTotal;
          } else {
            NotificationUnreadBadgePayload notificationUnreadBadgePayload =
            new NotificationUnreadBadgePayload()
              ..sessionId = SharedPreferencesService().user.sessionId
              ..token = GlobalVar.API_TOKEN;

            await notificationModel.notificationUnreadBadge(
              notificationUnreadBadgePayload,
              context,
              onSuccess: (response) {
                setState(() {
                  unreadNotifCounter = response.data.total;
                });
              },
              onError: (response) {},
            );
          }
        }

        lockerDataList = [];
        lockerDataList = lockerModel.newLockerList;
        lockerDataList.sort((a, b) => a.distance.compareTo(b.distance));
      },
    );

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }


  void _resetTimer() {
    _timer.cancel(); // Cancel the existing timer

  }


  _initializeRemoteConfig() async {
    if (_remoteConfig == null ||
        showSunway == null ||
        showPopsafe == null ||
        minimumVersion == null ||
        liveVersion == null ||
        minimumVersionIoS == null ||
        liveVersionIos == null ||
        valueCampaign == null||
        valueLinkCampaign == null) {
      _remoteConfig = await RemoteConfig.instance;
      await _fetchRemoteConfig();
    }

    setState(() {});
  }

  Future<void> _fetchRemoteConfig() async {
    packageInfo = await PackageInfo.fromPlatform();
    try {
      await _remoteConfig.fetch(expiration: const Duration(minutes: 1));
      await _remoteConfig.activateFetched();
      setState(() {
        showSunway        = _remoteConfig.getBool('pb_v3_sunway_pals');
        showPopsafe       = _remoteConfig.getBool('pb_v3_popsafe');
        minimumVersion    = _remoteConfig.getInt('pb_v3_minimum_version');
        liveVersion       = _remoteConfig.getInt('pb_v3_recommend_version');
        minimumVersionIoS = _remoteConfig.getInt('pb_v3_minimum_version_ios');
        liveVersionIos    = _remoteConfig.getInt('pb_v3_recommend_version_ios');
        valueCampaign     = _remoteConfig.getString('pb_popup_campaign_dev');
        valueLinkCampaign = _remoteConfig.getString('pb_popup_campaign_url');
        _checkVersion();
      });
      SharedPreferencesService().setShowSunwayPals(showSunway);
    } catch (e) {
      // print('Error: ${e.toString()}');
    }
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     setState(() {
  //     });
  //   }
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      var notificationStatus = await Permission.notification.status;

      if (mounted) {
        setState(() {
          if (notificationStatus.isGranted) {
            isNotification = "on";
          } else {
            isNotification = "off";
          }
          //notificationSettings();
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: PopboxColor.mdWhite1000,
        statusBarIconBrightness: Brightness.dark));

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: HomeAppBarView(
          keyOne: _one,
          notifCounter: unreadNotifCounter,
          notifCallback: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NotificationPage(
                  onesignalId: "",
                ),
              ),
            );
          },
          searchCallback: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SearchPage(),
              ),
            );
          },
          isShowcase: widget.isShowcase,
          isGuest: userData.isGuest,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    showAccount(context);
                  },
                  child: CustomWidget().switchAccountHome(context),
                ),
                SizedBox(height: 10.0)
              ],
            ),
            Expanded(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                addAutomaticKeepAlives: false,
                children: [
                  (isNotification == "on" || userData.isGuest)
                      ? Container()
                      : GestureDetector(
                    onTap: () {
                      AppSettings.openNotificationSettings();
                    },
                    child: Container(
                      decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.circular(10.0),
                        color: PopboxColor.blue477FFF,
                      ),
                      margin: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 16.0),
                      padding:
                      EdgeInsets.fromLTRB(20.0, 11.0, 20.0, 11.0),
                      child: Row(
                        children: [
                          Icon(Icons.notifications_none,
                              color: Colors.white),
                          Container(
                            margin: EdgeInsets.only(left: 10.0),
                            child: CustomWidget().textRegular(
                              AppLocalizations.of(context).translate(
                                  LanguageKeys.turnOnYourNotification),
                              Colors.white,
                              11.0.sp,
                              TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  phVerificationStatus(),
                  //ON DEVELOP
                  // Container(
                  //   padding: const EdgeInsets.only(top: 0.0),
                  //   child: new TransactionView(
                  //     isHeader: true,
                  //     isHome: true,
                  //     isSearchable: false,
                  //     keyThree: _three,
                  //     isShowcase: widget.isShowcase,
                  //     from: "home",
                  //   ),
                  // ),
                  TransactionNewPage(
                    isHeader: true,
                    isHome: true,
                    isSearchable: false,
                    keyThree: _three,
                    isShowcase: widget.isShowcase,
                    from: "home",
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CustomWidget().textBoldPlus(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.popboxServices),
                          PopboxColor.popboxBlackGrey,
                          16,
                          TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  //popboxServiceItem
                  //show intro
                  widget.isShowcase && userData.isGuest == false
                      ? CustomWidget().showcaseView(
                    key: _four,
                    child: popboxServiceItem(),
                    context: context,
                    isLast: true,
                    content: AppLocalizations.of(context)
                        .translate(LanguageKeys.showcaseFeatureContent),
                    showHeader: false,
                  )
                      : popboxServiceItem(),
                  SizedBox(height: 10),
                  //PROMO
                  Consumer<PromoViewModel>(
                    builder: (context, promoModel1, _) {
                      if (promoModel1.loading) return cartShimmerView(context);
                      List<Widget> promoWidget1 = [];
                      if (promoModel1.promoList != null &&
                          promoModel1.promoList.length > 0) {
                        for (var i = 0; i < promoModel1.promoList.length; i++) {
                          promoWidget1.add(BannerSliderItem(
                            promoData: promoModel1.promoList[i],
                            analytics: analytics,
                            observer: observer,
                          ));
                        }
                      }
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                top: 10.0, left: 0.0, right: 0.0, bottom: 12.0),
                            child: CarouselSlider(
                              options: CarouselOptions(
                                height: 162.0,
                                enlargeCenterPage: false,
                                viewportFraction: 0.9,
                                aspectRatio: 2.0,
                                autoPlay: true,
                                autoPlayInterval: Duration(milliseconds: 5000),
                                disableCenter: true,
                                enableInfiniteScroll: false,
                                pageSnapping: true,
                                enlargeStrategy:
                                CenterPageEnlargeStrategy.scale,
                                initialPage: 0,
                                onPageChanged: (index, reason) {
                                  if (mounted) {
                                    setState(() {
                                      _currentBannerSlider = index;
                                    });
                                  }
                                },
                              ),
                              items: promoWidget1,
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      );
                    },
                  ),

                  Container(
                    margin: const EdgeInsets.only(left: 16.0, right: 16.0),
                    width: 100.0.w,
                    child: CustomWidget().textBoldPlus(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.knowPopboxClosely),
                      PopboxColor.popboxBlackGrey,
                      16,
                      TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 20),
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 125.0,
                      enlargeCenterPage: true,
                      viewportFraction: 0.90,
                      aspectRatio: 2.0,
                      autoPlay: false,
                      autoPlayInterval: Duration(milliseconds: 3000),
                      disableCenter: true,
                      enableInfiniteScroll: false,
                      pageSnapping: true,
                      enlargeStrategy: CenterPageEnlargeStrategy.height,
                      initialPage: 0,
                      onPageChanged: (index, reason) {
                        if (mounted) {
                          setState(() {
                            _currentAboutSlider = index;
                          });
                        }
                      },
                    ),
                    items: itemOfCloser,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: itemOfCloser.map(
                          (value) {
                        int index = itemOfCloser.indexOf(value);
                        return Padding(
                          padding:
                          const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 24.0),
                          child: Container(
                            width: 5.0,
                            height: 5.0,
                            margin: EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 2.0),
                            decoration: _currentAboutSlider == index
                                ? BoxDecoration(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0)),
                              shape: BoxShape.rectangle,
                              color: PopboxColor.blue477FFF,
                            )
                                : BoxDecoration(
                              borderRadius:
                              BorderRadius.all(Radius.circular(4)),
                              shape: BoxShape.rectangle,
                              color: HexColor("#E3E3E3"),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget lockerWidget() {
    if (SharedPreferencesService().myLat == 0.0 ||
        SharedPreferencesService().myLng == 0.0) {
      return GestureDetector(
        onTap: () async {
          // Permission.location.status.then((value) {
          //   if (!value.isGranted) {
          //     if (Platform.isAndroid) {
          //       Permission.location.request().whenComplete(() => getLockers(
          //           new LatLng(SharedPreferencesService().myLat,
          //               SharedPreferencesService().myLng)));
          //     } else {
          //       //AppSettings.openLocationSettings();
          //       //Permission.location.shouldShowRequestRationale;
          //       Geolocator.requestPermission().whenComplete(() => getLockers(
          //           new LatLng(SharedPreferencesService().myLat,
          //               SharedPreferencesService().myLng)));
          //     }
          //   }
          // });
          // Map<Permission, PermissionStatus> statuses = await [
          //   Permission.location,
          // ].request();

          // if (statuses[Permission.location].isGranted) {
          //   getLockers(new LatLng(SharedPreferencesService().myLat,
          //       SharedPreferencesService().myLng));
          // } else if (statuses[Permission.location].isPermanentlyDenied) {
          //   //openAppSettings();
          //   AppSettings.openLocationSettings();
          // } else {
          //   if (Platform.isAndroid) {
          //     Permission.location.request();
          //   } else if (Platform.isIOS) {
          //     getLockers(new LatLng(SharedPreferencesService().myLat,
          //         SharedPreferencesService().myLng));
          //   }
          // }

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

          getLockers(new LatLng(SharedPreferencesService().myLat,
              SharedPreferencesService().myLng));
        },
        child: Container(
          decoration: new BoxDecoration(
            borderRadius: new BorderRadius.circular(8.0),
            color: PopboxColor.mdYellow100,
          ),
          margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
          padding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0),
                child: CustomWidget().textRegular(
                  AppLocalizations.of(context)
                      .translate(LanguageKeys.enableYourLocationToShowLocation),
                  PopboxColor.mdGrey900,
                  10.0.sp,
                  TextAlign.left,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButtonGeneral(
                    bgColor: PopboxColor.popboxRed,
                    borderColor: PopboxColor.popboxRed,
                    textColor: PopboxColor.mdWhite1000,
                    circularRounded: 5.0,
                    isBold: true,
                    onPressed: () async {
                      final serviceStatus =
                      await Permission.locationWhenInUse.serviceStatus;
                      final isGpsOn = serviceStatus == ServiceStatus.enabled;
                      if (!isGpsOn) {
                        print(
                            "Turn on location services berfore request permission");
                        return;
                      }
                      final status =
                      await Permission.locationWhenInUse.request();
                      if (status == PermissionStatus.granted) {
                        print(
                            "LockerWidget Location => Status Permission Granted");
                        //Refresh Home
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => Home(),
                        ));
                      } else if (status == PermissionStatus.denied) {
                        print("LockerWidget Location => Status Denied");
                      } else if (status == PermissionStatus.permanentlyDenied) {
                        print("LockerWidget Location => Status Permanante");
                        await permission_handler.openAppSettings();
                      }
                    },
                    title: AppLocalizations.of(context)
                        .translate(LanguageKeys.enable),
                    width: 130,
                    height: 35.0,
                    fontSize: 10.0.sp,
                  )
                ],
              )
            ],
          ),
        ),
        //CustomWidget().notGrantedLocation(context),
      );
    } else {
      var lockerModel = Provider.of<LockerViewModel>(context, listen: false);
      lockerDataList = lockerModel.newLockerList;
      if (lockerDataList != null && lockerDataList.length > 0) {
        lockerDataList.sort((a, b) => a.distance.compareTo(b.distance));
      }

      return lockerDataList == null || lockerDataList.length == 0
          ? cartShimmerView(context)
          : Container(
        padding: EdgeInsets.fromLTRB(12.0, 20.0, 12.0, 0.0),
        height: 42.0.h,
        child: StaggeredGridView.countBuilder(
          scrollDirection: Axis.horizontal,
          crossAxisCount: 6,
          itemCount:
          lockerDataList.length > 5 ? 5 : lockerDataList.length,
          itemBuilder: (BuildContext context, int index) {
            if (lockerDataList != null && lockerDataList.length > 0) {
              LockerData lockerData = lockerDataList[index];
              return LockerHomeItem(
                  lockerData: lockerData, dx: 3.0, dy: 3.0);
            } else {
              return Container();
            }
          },
          staggeredTileBuilder: (int index) =>
          new StaggeredTile.count(8, 3),
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 4.0,
        ),
      );
    }
  }

  int checkedIndex = 0;

  Widget lockerTypeItem(int index, String title) {
    bool checked = index == checkedIndex;
    return GestureDetector(
      onTap: () {
        if (mounted) {
          setState(() {
            checkedIndex = index;
          });
        }
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

  Widget popboxServiceItem() {
    //NEW
    return Container(
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //Parcel
          GestureDetector(
            onTap: () {
              if (SharedPreferencesService().user.isGuest == null ||
                  SharedPreferencesService().user.isGuest) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(
                      from: "guest",
                    ),
                  ),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TransactionNewPage(
                      isHeader: false,
                      isHome: false,
                      isSearchable: true,
                      isShowcase: false,
                      keyThree: null,
                      from: "parcel",
                    ),
                  ),
                );
              }
            },
            child: Container(
              width: 28.0.w,
              height: 28.0.w,
              decoration: BoxDecoration(
                color: HexColor("#FFE99B"),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 11, top: 17),
                    child: CustomWidget().textBoldPlus(
                      AppLocalizations.of(context).translate(LanguageKeys.take),
                      PopboxColor.mdGrey900,
                      12,
                      TextAlign.center,
                    ),
                  ),
                  Image.asset(
                    "assets/images/ic_service_parcel.png",
                    width: 70,
                    fit: BoxFit.fitWidth,
                  ),
                ],
              ),
            ),
          ),
          //Popsafe
          (SharedPreferencesService().locationSelected == "ID")
              ? GestureDetector(
            onTap: () {
              if (showPopsafe == true) {
                if (SharedPreferencesService().user.isGuest == null ||
                    SharedPreferencesService().user.isGuest) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LoginPage(
                        from: "guest",
                      ),
                    ),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            PopsafePage(from: 'popbox_service_item')),
                  );
                }
              } else {
                showPopsafeInfo(context: context);
              }
            },
            child: Container(
              width: 28.0.w,
              height: 28.0.w,
              decoration: BoxDecoration(
                color: HexColor("#A3FFBD"),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 11, top: 17),
                    child: CustomWidget().textBoldPlus(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.deposit),
                      PopboxColor.mdGrey900,
                      12,
                      TextAlign.center,
                    ),
                  ),
                  Image.asset(
                    "assets/images/ic_service_popsafe.png",
                    width: 55,
                    fit: BoxFit.fitWidth,
                  ),
                ],
              ),
            ),
          )
              : Container(),
          //Tracking
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TrackingPage(),
                ),
              );
            },
            child: Container(
              width: 28.0.w,
              height: 28.0.w,
              decoration: BoxDecoration(
                color: HexColor("#D6EBFF"),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 11, top: 17),
                    child: CustomWidget().textBoldPlus(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.tracking),
                      PopboxColor.mdGrey900,
                      12,
                      TextAlign.center,
                    ),
                  ),
                  Image.asset(
                    "assets/images/ic_service_tracking.png",
                    width: 54,
                    fit: BoxFit.fitWidth,
                  ),
                ],
              ),
            ),
          ),
          //development : production
          //PopShop
          // SizedBox(width: 10.0),
          // (SharedPreferencesService().locationSelected == "ID" &&
          //         flavor == "production")
          //     ? GestureDetector(
          //         onTap: () {
          //           if (SharedPreferencesService().user.isGuest == null ||
          //               SharedPreferencesService().user.isGuest) {
          //             Navigator.of(context).push(
          //               MaterialPageRoute(
          //                 builder: (context) => LoginPage(
          //                   from: "guest",
          //                 ),
          //               ),
          //             );
          //           } else {
          //             Navigator.of(context).push(
          //               MaterialPageRoute(
          //                 builder: (context) => PopShopPage(),
          //               ),
          //             );
          //           }
          //         },
          //         child: Column(
          //           children: [
          //             Container(
          //               width: MediaQuery.of(context).size.width * 0.27,
          //               height: 121.0,
          //               decoration: BoxDecoration(
          //                 image: DecorationImage(
          //                   image:
          //                       AssetImage("assets/images/ic_menu_parcel.png"),
          //                 ),
          //               ),
          //             ),
          //             CustomWidget().textBold(
          //               AppLocalizations.of(context)
          //                   .translate(LanguageKeys.shop),
          //               PopboxColor.mdGrey900,
          //               12.0.sp,
          //               TextAlign.center,
          //             ),
          //           ],
          //         ),
          //       )
          //     : Container(),
        ],
      ),
    );
  }

  Widget phVerificationStatus() {
    if (SharedPreferencesService().user.isGuest == false) {
      if (SharedPreferencesService().locationSelected == "PH") {
        if (SharedPreferencesService().user.statusIdentity == "" ||
            SharedPreferencesService().user.statusIdentity == null) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            child: Stack(
              children: [
                Image.asset(
                  "assets/images/ic_bg_verify_account_rejected.png",
                  width: 100.0.w,
                  fit: BoxFit.fitWidth,
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomWidget().textBold(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.verifyYourAccount),
                              PopboxColor.mdWhite1000,
                              10.0.sp,
                              TextAlign.left),
                          Container(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: CustomButtonGeneral(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => VerifyInfoPage(
                                      from: "verify",
                                    ),
                                  ),
                                );
                              },
                              title: AppLocalizations.of(context)
                                  .translate(LanguageKeys.verifyAccount),
                              fontSize: 10.0.sp,
                              width: 150.0,
                              height: 30.0,
                              bgColor: PopboxColor.mdWhite1000,
                              borderColor: PopboxColor.mdWhite1000,
                              textColor: PopboxColor.mdBlack1000,
                              circularRounded: 5.0,
                              isBold: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        } else if (SharedPreferencesService().user.statusIdentity ==
            "REJECTED") {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            child: Stack(
              children: [
                Image.asset(
                  "assets/images/ic_bg_verify_account_rejected.png",
                  width: 100.0.w,
                  fit: BoxFit.fitWidth,
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomWidget().textBold(
                              AppLocalizations.of(context).translate(
                                  LanguageKeys.thisDocumentWasRejected),
                              PopboxColor.mdWhite1000,
                              10.0.sp,
                              TextAlign.left),
                          Container(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: CustomButtonGeneral(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => VerifyInfoPage(
                                      from: "re-verify",
                                    ),
                                  ),
                                );
                              },
                              title: AppLocalizations.of(context)
                                  .translate(LanguageKeys.reVerify),
                              fontSize: 10.0.sp,
                              width: 100.0,
                              height: 30.0,
                              bgColor: PopboxColor.mdWhite1000,
                              borderColor: PopboxColor.mdWhite1000,
                              textColor: PopboxColor.mdBlack1000,
                              circularRounded: 5.0,
                              isBold: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (SharedPreferencesService().user.statusIdentity ==
            "PENDING_VERIFICATION") {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            child: Stack(
              children: [
                Image.asset(
                  "assets/images/ic_bg_verify_account_pending.png",
                  width: 100.0.w,
                  fit: BoxFit.fitWidth,
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: CustomWidget().textBold(
                          AppLocalizations.of(context).translate(
                              LanguageKeys.yourAccountInVerificationProcess),
                          PopboxColor.mdWhite1000,
                          10.0.sp,
                          TextAlign.left),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }
    }

    return Container();
  }

  void getLockers(LatLng myLatLng) async {
    var lockerModel = Provider.of<LockerViewModel>(context, listen: false);
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
  }

  void showAccount(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            color: Color(0xFF737373),
            child: Container(
              decoration: new BoxDecoration(
                  color: PopboxColor.mdWhite1000,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(12.0),
                      topRight: const Radius.circular(12.0))),
              child: new Wrap(
                children: <Widget>[
                  MultiAccountWidget(),
                ],
              ),
            ),
          );
        });
  }

  //POPUP DIALOG SUNWAY PALS
  _showDialogSunwayInfo() async {
    await Future.delayed(Duration(milliseconds: 50));
    showDialog(
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) => Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                    onTap: () {
                      DateTime now = DateTime.now();
                      String dateTimeNowFormated =
                      DateFormat('dd MMM yyyy HH:mm').format(now);

                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      SharedPreferencesService()
                          .setRemindLater(dateTimeNowFormated);
                    },
                    child: Icon(Icons.close, color: Colors.white))),
            Container(
              width: 350,
              height: 60.0.h,
              color: PopboxColor.mdWhite1000,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/ic_sunwaypals_popbox.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  Column(
                    children: [
                      SizedBox(height: 5.0),
                      CustomWidget().textBold("Are you Sunway Pals member?",
                          PopboxColor.mdBlack1000, 11.0.sp, TextAlign.center),
                      SizedBox(height: 10.0),
                      Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                        child: CustomWidget().textRegular(
                          'Hurry up and link your account now to earn 5 Pals point each time you collect a parcel from PopBox! \n\nFor new users registered within May-Oct 2022, stand a chance to win up to 5000 Pals points! *TnC apply.',
                          PopboxColor.mdBlack1000,
                          8.0.sp,
                          TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => setState(() {
                        context.read<BottomNavigationBloc>().add(
                          PageTapped(index: 3),
                        );
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (c) => Home()),
                                (route) => false);
                      }));
                    },
                    child: Container(
                      height: 30.0,
                      margin: EdgeInsets.only(left: 33, right: 33, bottom: 10),
                      decoration: BoxDecoration(
                        color: PopboxColor.popboxRed,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: CustomWidget().textBold('Link Pals Account',
                            PopboxColor.mdWhite1000, 9.0.sp, null),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //POPUP DIALOG FORCE UPDATE
  _showDialogInfoUpdate({bool isForce}) async {
    isPopUpForceShow = true;
    await Future.delayed(Duration(milliseconds: 50));
    showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          side: BorderSide(color: Colors.white),
        ),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isForce
                ? Container()
                : Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  SharedPreferencesService().setTapRecommendUpdate(true);
                  _checkCampaign();
                  //setValueRecommendVersion
                  if (Platform.isAndroid) {
                    SharedPreferencesService()
                        .setValueRecommendVersion(liveVersion);
                  } else {
                    SharedPreferencesService()
                        .setValueRecommendVersion(liveVersionIos);
                  }

                  Navigator.pop(context);
                },
                child: Icon(Icons.close, color: Colors.black),
              ),
            ),
            Container(
              width: 330,
              height: 60.0.h,
              color: PopboxColor.mdWhite1000,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/ic_forceupdate.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  Column(
                    children: [
                      SizedBox(height: 5.0),
                      CustomWidget().textBoldPlus(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.popboxAppUpdate),
                          PopboxColor.mdBlack1000,
                          16,
                          TextAlign.center),
                      SizedBox(height: 5.0),
                      Container(
                        child: CustomWidget().textLight(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.popboxAppUpdateNote),
                          PopboxColor.mdBlack1000,
                          12,
                          TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      gotoStore();
                    },
                    child: Container(
                      height: 45.0,
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: PopboxColor.popboxRed,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: CustomWidget().textBold(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.updateNow),
                            PopboxColor.mdWhite1000,
                            9.0.sp,
                            null),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //POPUP CAMPAIGN
  _showDialogCampaignz({bool isForce}) async {
    isPopUpRecommendShow = true;
    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    String campaignDate = dateFormat.format(now);
    SharedPreferencesService().setDateShowCampaign(campaignDate);
    SharedPreferencesService().setShowCampaign(true);
    await Future.delayed(Duration(milliseconds: 50));
    showDialog(
      useSafeArea: true,
      context: context,
      builder: (context) {
        return
          Dialog( child: Container(
            width: 300, // Set the desired width
            height: 400, // Set the desired height
            child: Stack(
            children: [
              GestureDetector(
                onTap: () async {
                  if(valueLinkCampaign == ""){
                    Navigator.of(context).pop();
                  }else{
                    await analytics.setCurrentScreen(
                      screenName: "Popup Campaign",
                      screenClassOverride: 'BannerSliderItem',
                    );

                    openURL(valueLinkCampaign.toString());
                  }
                  // Add your desired action when the image is clicked
                },
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: CachedNetworkImage(
                      imageUrl: valueCampaign,
                      fit: BoxFit.cover, // Adjust the image fit as needed
                      placeholder: (context, url) => Center(
                      child: Container(
                      width: 50, // Set the desired width
                      height: 50, // Set the desired height
                      child: CircularProgressIndicator(), // Show a loading circle as a placeholder
                        ),
                      ),
                      // Placeholder widget while loading
                      errorWidget: (context, url, error) => Icon(Icons.error), // Error widget if the image fails to load
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () async {
                    // SharedPreferences prefs = await SharedPreferences.getInstance();
                    // // Update the last shown date and time to the current date and time.
                    // await prefs.setString('lastShownDateTime', DateTime.now().toIso8601String());
                    // print('rdlog buildCode: ${buildCode.toString()}');


                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
        );
      },
    );


  }


  void gotoStore() async {
    const urlAndroid =
        'https://play.google.com/store/apps/details?id=asia.popbox.app&hl=id&gl=US&pli=1';
    const urlIos = 'https://apps.apple.com/id/app/popbox-asia/id1196265583';

    if (Platform.isIOS) {
      if (await canLaunch(urlIos)) {
        await launch(urlIos);
      } else {
        throw 'Could not launch $urlIos';
      }
    } else {
      if (await canLaunch(urlAndroid)) {
        await launch(urlAndroid);
      } else {
        throw 'Could not launch $urlAndroid';
      }
    }
  }

  void callCsBottomSheet(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Image.asset(
                            "assets/images/ic_back_black.png",
                            height: 16.0,
                            width: 16.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 32.0),
                          child: CustomWidget().textBold(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.info),
                            PopboxColor.mdBlack1000,
                            13.0.sp,
                            TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Divider(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: new HelpView(),
                ),
              ],
            ),
          );
        });
  }

  void showPopsafeInfo({context}) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setstateBuilder) => Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //TITLE
                  Image.asset("assets/images/ic_hand_popsafe.png"),
                  CustomWidget().textBoldPlus(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.onDevelopment),
                      PopboxColor.mdBlack1000,
                      16,
                      TextAlign.center),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: CustomWidget().textRegular(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.onDevelopmentNotes),
                        PopboxColor.mdBlack1000,
                        14,
                        TextAlign.center),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin:
                      const EdgeInsets.only(left: 23, right: 23, top: 35),
                      child: CustomButtonRectangle(
                        bgColor: PopboxColor.red,
                        fontSize: 14,
                        textColor: Colors.white,
                        title: AppLocalizations.of(context)
                            .translate(LanguageKeys.understand),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      callCsBottomSheet(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 32.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        softWrap: true,
                        text: new TextSpan(
                          style: new TextStyle(
                            fontSize: 12.0.sp,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            new TextSpan(
                                text: AppLocalizations.of(context)
                                    .translate(LanguageKeys.needHelp),
                                style: TextStyle(
                                  color: PopboxColor.mdGrey700,
                                  fontSize: 10.0.sp,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w400,
                                )),
                            new TextSpan(
                              text: " " +
                                  AppLocalizations.of(context).translate(
                                      LanguageKeys.callPopboxCustomerService),
                              style: TextStyle(
                                color: PopboxColor.blue477FFF,
                                fontSize: 10.0.sp,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).whenComplete(() => null);
  }

  void _pupUpRecommendUpdate() {
    SharedPreferencesService().setFirstDisplay(false);
    isPopUpRecommendShow = true;
    //RECOMMEND UPDATE
    if (Platform.isAndroid) {
      if (isFirstTap == false) {
        _showDialogInfoUpdate(isForce: false);
      } else if (isFirstTap == true && valueLastRecommendUpdate != 0) {
        _showDialogInfoUpdate(isForce: false);
      }
    } else if (Platform.isIOS) {
      if (isFirstTap == false) {
        _showDialogInfoUpdate(isForce: false);
      } else if (isFirstTap == true && valueLastRecommendUpdateIos != 0) {
        _showDialogInfoUpdate(isForce: false);
      }
    }
  }

  Future<void> _checkVersion() async {
    buildCode = int.parse(packageInfo.buildNumber);
    isFirstDisplay = sharedPreferences.isFirstDisplay;

    if (widget.isShowcase == false) {
      if (Platform.isAndroid) {
        if (minimumVersion != null && liveVersion != null) {
          if (userData.isGuest == true) {
            //GUEST MODE
            if (minimumVersion > buildCode && widget.isShowcase == false) {
              //FORCE UPDATE
              _showDialogInfoUpdate(isForce: true);
            }
            if ((buildCode == minimumVersion || buildCode > minimumVersion) &&
                buildCode < liveVersion &&
                valueLastRecommendUpdate != 0 &&
                widget.isShowcase == false) {
              //RECOMMEND UPDATE
              if(isFirstDisplay == true){
                _pupUpRecommendUpdate();
              }
            }
            if (buildCode < liveVersion &&
                valueLastRecommendUpdate < liveVersion &&
                widget.isShowcase == false) {
              if(isFirstDisplay == true){
                _pupUpRecommendUpdate();
              }
            }
          } else {
            //LOGIN MODE
            if (widget.isShowcase == false) {
              if (minimumVersion > buildCode) {
                //FORCE UPDATE
                _showDialogInfoUpdate(isForce: true);
              }
              if (buildCode < liveVersion &&
                  valueLastRecommendUpdate < liveVersion &&
                  widget.isShowcase == false) {
                if(isFirstDisplay == true){
                  _pupUpRecommendUpdate();
                }              }
              // if ((buildCode == minimumVersion || buildCode > minimumVersion) &&
              //     buildCode < liveVersion) {
              //   //RECOMMEND UPDATE
              //   if (widget.isShowcase == false && isFirstTap == false) {
              //     if(isFirstDisplay == true){
              //       _pupUpRecommendUpdate();
              //       print('rdlog _pupUpRecommendUpdate: 4');
              //     }
              //   } else {}
              // }
            }
          }
        } else {
          _fetchRemoteConfig();
        }
      } else if (Platform.isIOS) {
        if (minimumVersionIoS != null && liveVersionIos != null) {
          if (userData.isGuest == true) {
            //GUEST MODE
            if (minimumVersionIoS > buildCode && widget.isShowcase == false) {
              //FORCE UPDATE
              _showDialogInfoUpdate(isForce: true);
            }
            if ((buildCode == minimumVersionIoS ||
                buildCode > minimumVersionIoS) &&
                buildCode < liveVersionIos &&
                valueLastRecommendUpdateIos != 0 &&
                widget.isShowcase == false) {
              //RECOMMEND UPDATE
              if(isFirstDisplay == true){
                _pupUpRecommendUpdate();
              }
            }
            if (buildCode < liveVersionIos &&
                valueLastRecommendUpdateIos < liveVersionIos &&
                widget.isShowcase == false) {
              if(isFirstDisplay == true){
                _pupUpRecommendUpdate();
              }
            }
          } else {
            //LOGIN MODE
            if (widget.isShowcase == false) {
              if (minimumVersionIoS > buildCode) {
                //FORCE UPDATE
                _showDialogInfoUpdate(isForce: true);
              }
              if (buildCode < liveVersionIos &&
                  valueLastRecommendUpdateIos < liveVersionIos &&
                  widget.isShowcase == false) {
                if(isFirstDisplay == true){
                  _pupUpRecommendUpdate();
                }
              }
              if ((buildCode == minimumVersionIoS ||
                  buildCode > minimumVersionIoS) &&
                  buildCode < liveVersionIos) {
                //RECOMMEND UPDATE
                if (widget.isShowcase == false && isFirstTap == false) {
                  if(isFirstDisplay == true){
                    _pupUpRecommendUpdate();
                  }
                  //_showDialogInfoUpdate(isForce: false);
                } else {}
              }
            }
          }
        } else {
          _fetchRemoteConfig();
        }
      }
    }

    _checkCampaign();
  }

  void _checkCampaign() async {
    print("campaign: "+valueCampaign.toString());
      if (widget.isShowcase == false &&  sharedPreferences.isFirstTapRecommendUpdate != null) {
        if(valueCampaign != ""){
          _startTimerCampaign();
        }
      }else if(widget.isShowcase == false &&  sharedPreferences.isFirstTapRecommendUpdate == true){
        if(valueCampaign != ""){
          _startTimerCampaign();
        }
      }else if(widget.isShowcase == false && isPopUpRecommendShow == false){
        if(valueCampaign != ""){
          _startTimerCampaign();
        }
      }
    }

  void _startTimerCampaign() {
    if(isFirstDisplay == true){
      DateTime now = DateTime.now();
      DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      String campaignDate = dateFormat.format(now);
      SharedPreferencesService().setDateShowCampaign(campaignDate);
    }else{
      String getLastShowCampaign = sharedPreferences.getDateLastCampaign;
      SharedPreferencesService().setDateShowCampaign(getLastShowCampaign);
    }
    checkDateCampaign();
  }

  void checkDateCampaign() {
    String getLastShowCampaign  = sharedPreferences.getDateLastCampaign;
    bool getStatusCampaign      = sharedPreferences.isShowCampaign;


    if(isFirstDisplay == true ){
      SharedPreferencesService().setFirstDisplay(false);
      _showDialogCampaignz(isForce: false);
    }else{
      String testDate = "2023-10-22";
      if(getLastShowCampaign != null){
        if(dateNow != getLastShowCampaign || getStatusCampaign == false){
          SharedPreferencesService().setFirstDisplay(false);
          isPopUpRecommendShow = true;
          _showDialogCampaignz(isForce: false);
        }else{
          print('rdlog not today 0');
        }
      }else{
        print('rdlog not today 1');
        DateTime now = DateTime.now();
        DateFormat dateFormat = DateFormat('yyyy-MM-dd');
        String campaignDate = dateFormat.format(now);
        SharedPreferencesService().setDateShowCampaign(campaignDate);
        SharedPreferencesService().setShowCampaign(false);

        checkDateCampaign();
      }

    }

  }


    // else if(widget.isShowcase == false && isPopUpForceShow == false){
    //   print('rdlog Campaign3: ${valueCampaign.toString()}');
    //   if(valueCampaign != ""){
    //     _showDialogCampaignz(isForce: false);
    //   }else{
    //     //tidak tampil popup campagin-nya
    //   }
    // }
  }



  Future<void> openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Could not launch $url. No app found to handle the intent.");
      // You can display an error message to the user or take some other action here.
    }


}
