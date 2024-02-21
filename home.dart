import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_popbox/core/bloc/bottom_navigation/bottom_navigation_bloc.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/notif_parcel_model.dart';
import 'package:new_popbox/core/showcase/showcaseview.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/ui/pages/account_page.dart';
import 'package:new_popbox/ui/pages/help_page.dart';
import 'package:new_popbox/ui/pages/home_page.dart';
import 'package:new_popbox/ui/pages/location_page.dart';
import 'package:new_popbox/ui/pages/notification_page.dart';
import 'package:new_popbox/ui/pages/transaction_detail.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:sizer/sizer.dart';

import 'login_page.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  DateTime currentBackPressTime;
  bool isShowDialog = false;
  Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //print("isNotificationOn : " + await isNotificationOn());

      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        //print("aaaaaaa " + DateTime.now().toString());
        if (SharedPreferencesService().onesignalId != null &&
            SharedPreferencesService().onesignalId != "") {
          String onesignalId = SharedPreferencesService().onesignalId;
          String transactionType =
              SharedPreferencesService().notifParcelModel.toMap()["category"];
          String orderIdNotif =
              SharedPreferencesService().notifParcelModel.toMap()["id"];
          String awbNumber =
              SharedPreferencesService().notifParcelModel.toMap()["awb_number"];

          SharedPreferencesService().setOnesignalId("");
          SharedPreferencesService().setNotifParcel(
            NotifParcelModel(
              id: "",
              category: "",
              awbNumber: "",
            ),
          );

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TransactionDetailPage(
                isPopNotif: true,
                transactionType: transactionType,
                orderIdNotif:
                    (transactionType == "popsafe") ? awbNumber : orderIdNotif,
              ),
            ),
          );
        }
      });
    });
    //notificationSettings();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    //print("state : " + state.toString());
    if (state == AppLifecycleState.resumed) {
      //var status = await Permission.notification.status;
      //print("status2 : " + status.toString());
      setState(() {
        //notificationSettings();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int selectedIdx = 0;
    int selectedIdxTemp = 0;

    if (SharedPreferencesService().isHomeNearestLocation != null &&
        SharedPreferencesService().isHomeNearestLocation) {
      selectedIdxTemp = 1;
    }

    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          onWillPop(context);
        },
        child: BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
          builder: (BuildContext context, BottomNavigationState state) {
            if (state is PageLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (SharedPreferencesService().isHomeNearestLocation != null &&
                SharedPreferencesService().isHomeNearestLocation) {
              return LocationPage(from: "nearest");
            }

            if (state is HomePageLoaded) {
              return HomePage(
                isShowcase: false,
              );
            }
            if (state is LocationPageLoaded) {
              return LocationPage(from: "home");
            }
            if (state is HelpPageLoaded) {
              return HelpPage();
            }

            if (state is AccountPageLoaded) {
              return AccountPage();
            }
            return ShowCaseWidget(
              onStart: (index, key) {
                print('onStart: $index, $key');
                //return HomePage();
              },
              onComplete: (index, key) {
                print('onComplete: $index, $key');
                // return HomePage(
                //   isShowcase: false,
                // );
              },
              onFinish: () {
                print('onFinish');
                context.read<BottomNavigationBloc>().add(
                      PageTapped(index: 0),
                    );
              },
              builder: Builder(
                builder: (context) => HomePage(
                  isShowcase: (SharedPreferencesService().isShowCase == null ||
                          SharedPreferencesService().isShowCase == true)
                      ? true
                      : false,
                ),
              ),
              autoPlay: false,
              autoPlayDelay: Duration(seconds: 1),
              autoPlayLockEnable: false,
            );
          },
        ),
      ),
      bottomNavigationBar:
          BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
              builder: (BuildContext context, BottomNavigationState state) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: PopboxColor.popboxBlack919191,
          selectedItemColor: PopboxColor.popboxPrimaryRed,
          backgroundColor: Colors.white,
          unselectedLabelStyle: TextStyle(
            fontFamily: "Montserrat",
            fontSize: 9.0.sp,
            fontWeight: FontWeight.w400,
          ),
          selectedLabelStyle: TextStyle(
              fontFamily: "Montserrat",
              fontSize: 9.0.sp,
              fontWeight: FontWeight.w500),
          currentIndex: context.select((BottomNavigationBloc bloc) {
            if (selectedIdxTemp > 0) {
              selectedIdx = selectedIdxTemp;
              print("currentIndex1 : " + selectedIdx.toString());
              selectedIdxTemp = 0;
            } else {
              selectedIdx = bloc.currentIndex;
              print("currentIndex2 : " + selectedIdx.toString());
            }

            // if (SharedPreferencesService().isHomeNearestLocation != null &&
            //     SharedPreferencesService().isHomeNearestLocation) {
            //   setState(() {
            //     selectedIdx = 1;
            //   });
            // }
            return selectedIdx;
          }),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              label:
                  AppLocalizations.of(context).translate(LanguageKeys.homePage),
              icon: selectedIdx == 0
                  ? new Image.asset(
                      'assets/images/ic_menu_home_active.png',
                      width: 8.0.w,
                      height: 4.0.h,
                    )
                  : new Image.asset(
                      'assets/images/ic_menu_home.png',
                      width: 8.0.w,
                      height: 4.0.h,
                      color: PopboxColor.popboxBlack919191,
                    ),
            ),
            BottomNavigationBarItem(
              icon: selectedIdx == 1
                  ? new Image.asset(
                      'assets/images/ic_menu_location_active.png',
                      width: 8.0.w,
                      height: 4.0.h,
                    )
                  : new Image.asset('assets/images/ic_menu_location.png',
                      width: 8.0.w,
                      height: 4.0.h,
                      color: PopboxColor.popboxBlack919191),
              label:
                  AppLocalizations.of(context).translate(LanguageKeys.location),
            ),
            BottomNavigationBarItem(
              icon: selectedIdx == 2
                  ? new Image.asset(
                      'assets/images/ic_menu_help_active.png',
                      width: 8.0.w,
                      height: 4.0.h,
                    )
                  : new Image.asset(
                      'assets/images/ic_menu_help.png',
                      width: 8.0.w,
                      height: 4.0.h,
                      color: PopboxColor.popboxBlack919191,
                    ),
              label: AppLocalizations.of(context).translate(LanguageKeys.help),
            ),
            BottomNavigationBarItem(
              icon: selectedIdx == 3
                  ? new Image.asset(
                      'assets/images/ic_menu_account_active.png',
                      width: 8.0.w,
                      height: 4.0.h,
                    )
                  : new Image.asset(
                      'assets/images/ic_menu_account.png',
                      width: 8.0.w,
                      height: 4.0.h,
                      color: PopboxColor.popboxBlack919191,
                    ),
              label: SharedPreferencesService().user.isGuest
                  ? AppLocalizations.of(context).translate(LanguageKeys.login)
                  : AppLocalizations.of(context)
                      .translate(LanguageKeys.account),
            ),
          ],
          onTap: (index) {
            selectedIdx = index;
            if (SharedPreferencesService().user.isGuest && selectedIdx == 3) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LoginPage(
                    from: "guest",
                  ),
                ),
              );
            } else {
              context.read<BottomNavigationBloc>().add(
                    PageTapped(index: index),
                  );
            }
          },
        );
      }),
    );
  }

  Future<bool> onWillPop(BuildContext context) {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      CustomWidget().showToastShortV1(
        context: context,
        msg: AppLocalizations.of(context)
            .translate(LanguageKeys.pressBackAgainToExit),
      );
      return Future.value(false);
    } else {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else {
        exit(0);
      }
      return Future.value(true);
    }
  }
}
