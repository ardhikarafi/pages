import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:new_popbox/core/models/payload/login_payload.dart';
import 'package:new_popbox/core/models/payload/user_check_payload.dart';
import 'package:new_popbox/core/utils/global_function.dart';
import 'package:new_popbox/core/utils/library.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/item/account_settings_item.dart';
import 'package:new_popbox/ui/pages/account_info_page.dart';
import 'package:new_popbox/ui/pages/language_page.dart';
import 'package:new_popbox/ui/pages/payment_history_page.dart';
import 'package:new_popbox/ui/pages/sunwaypals_page.dart';
import 'package:new_popbox/ui/pages/webview_page.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:remove_emoji/remove_emoji.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/user/user_login_data.dart';

import 'account_address_page.dart';
import 'account_emailverification_page.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with WidgetsBindingObserver {
  bool isConnected;
  bool showSunway;
  static RemoteConfig _remoteConfig;
  SharedPreferencesService sharedPrefService;
  bool isAccountAddress = false;
  String isEmailVerified = "";
  String emailAddress = "";
  UserLoginData userData = new UserLoginData();
  LoginPayload loginPayload = new LoginPayload();
  String identifier = "";
  String isNotification = "";
  String fcmToken = "";
  bool isVerifiedEmail = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      sharedPrefService = await SharedPreferencesService.instance;
      UserLoginData userData = await SharedPreferencesService().getUser();

      try {
        if (userData.statusEmail == "UNVERIFIED") {
          isVerifiedEmail = false;
        } else {
          isVerifiedEmail = true;
        }
      } catch (e) {}

      // isEmailVerified   = sharedPrefService.user.statusEmail;
      // print("====> isEmailVerified == " + isEmailVerified);
      if (userData != null) {
        if (isEmailVerified == "") {
          isEmailVerified = sharedPrefService.user.statusEmail;
        }
        if (emailAddress == "") {
          emailAddress = sharedPrefService.user.email;
        }
      }
      fcmToken = sharedPrefService.fcmToken;
      if (fcmToken == null || fcmToken == "") {
        setOnesignal(this.context);
      }

      isNotification = await isNotificationOn();
      loginPayload.deviceId =
          identifier.removemoji.replaceAll(RegExp('[^A-Za-z0-9]'), '');
      loginPayload.notificationSetting = isNotification;
      loginPayload.onesignalPlayerId = fcmToken;

      if (sharedPrefService.user.accountTypeAddress != null) {
        setState(() {
          isAccountAddress = true;
        });
      }
    });
    if (SharedPreferencesService().user.palsStatus.toString() == "null" ||
        SharedPreferencesService().user.palsStatus.toString() == "removed") {
      isConnected = false; //false
    } else {
      isConnected = true;
    }

    super.initState();
    _initializeRemoteConfig();
    //_userCheck(this.context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //_userCheck(this.context);
    }
  }

  void _userCheck(BuildContext context) async {
    final userModel = Provider.of<UserViewModel>(context, listen: false);
    UserCheckPayload userCheckPayload = new UserCheckPayload(
      token: GlobalVar.API_TOKEN,
      phone: SharedPreferencesService().user.phone.replaceAll("", ""),
      deviceId: loginPayload.deviceId,
      notificationSetting: loginPayload.notificationSetting,
      onesignalPlayerId: loginPayload.onesignalPlayerId,
    );

    userModel.userCheck(userCheckPayload, context, isSaveCallbak: false,
        onSuccess: (response) async {
      setState(() {
        isEmailVerified = response.data.first.statusEmail;
        emailAddress = response.data.first.email;
        //SharedPreferencesService().setShowCase(true);
        if (isEmailVerified == "UNVERIFIED") {
          SharedPreferencesService().setVerifiedEmail(false);
        } else {
          SharedPreferencesService().setVerifiedEmail(true);
        }
      });
    }, onError: (response) {
      //case 1 :
      if (response.response.code == 400) {
        // print("case1");
      } else {
        try {
          CustomWidget().showCustomDialog(
              context: context, msg: response.response.message);
        } catch (e) {
          CustomWidget().showCustomDialog(context: context, msg: e.toString());
        }
      }
    });
  }

  _initializeRemoteConfig() async {
    if (_remoteConfig == null || showSunway == null) {
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
        showSunway = _remoteConfig.getBool('pb_v3_sunway_pals');
      });
    } catch (e) {
      // print('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: GeneralAppBarView(
          title: AppLocalizations.of(context).translate(LanguageKeys.account),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: RefreshIndicator(
            onRefresh: _doUserCheck,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    //physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height,
                        child: Padding(
                          padding: EdgeInsets.only(left: 16.0, right: 16.0),
                          child: ListView(
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            children: [
                              (SharedPreferencesService().locationSelected ==
                                          "MY" &&
                                      showSunway == true)
                                  ? sunwayPalsMY()
                                  : Container(),
                              SizedBox(height: 15),
                              (isEmailVerified == "UNVERIFIED")
                                  ? alertEmailVerification(
                                      context, emailAddress)
                                  : Container(),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 0.0,
                                    right: 0.0,
                                    top: 16.0,
                                    bottom: 10.0),
                                child: CustomWidget().textLight(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.account),
                                  PopboxColor.mdGrey900,
                                  12,
                                  TextAlign.left,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AccountInfoPage(),
                                    ),
                                  );
                                },
                                child: AccountSettingsItem(
                                  image: "assets/images/ic_settings_user.png",
                                  title: AppLocalizations.of(context)
                                      .translate(LanguageKeys.accountInfo),
                                  isNew: false,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AccountAddressPage(
                                        isAddressFilled: isAccountAddress,
                                        type: sharedPrefService
                                            .user.accountTypeAddress,
                                      ),
                                    ),
                                  );
                                },
                                child: AccountSettingsItem(
                                  image: "assets/images/ic_house_line.png",
                                  title: AppLocalizations.of(context)
                                      .translate(LanguageKeys.address),
                                  isNew: false,
                                  withText: isAccountAddress ? false : true,
                                  textOption: isAccountAddress
                                      ? ""
                                      : AppLocalizations.of(context)
                                          .translate(LanguageKeys.caseNotFilled)
                                          .replaceAll(
                                              "%s",
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      LanguageKeys.address)),
                                ),
                              ),
                              // InkWell(
                              //   onTap: () {
                              //     Navigator.of(context).push(
                              //       MaterialPageRoute(
                              //         builder: (context) => PaymentHistory(),
                              //       ),
                              //     );
                              //   },
                              //   child: AccountSettingsItem(
                              //     image: "assets/images/receipt.png",
                              //     title: AppLocalizations.of(context)
                              //         .translate(LanguageKeys.paymentHistory),
                              //     isNew: false,
                              //   ),
                              // ),
                              // Padding(
                              //   padding: EdgeInsets.only(
                              //       left: 0.0, right: 0.0, top: 30.0),
                              //   child: CustomWidget().textLight(
                              //     AppLocalizations.of(context)
                              //         .translate(LanguageKeys.support),
                              //     PopboxColor.mdGrey900,
                              //     12,
                              //     TextAlign.left,
                              //   ),
                              // ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => LanguagePage(
                                              reason: "language",
                                            ),
                                          ),
                                        );
                                      },
                                      child: AccountSettingsItem(
                                        image:
                                            "assets/images/ic_settings_language.png",
                                        title: AppLocalizations.of(context)
                                            .translate(
                                                LanguageKeys.changeLanguage),
                                        isNew: false,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => WebviewPage(
                                              reason: "tnc",
                                              appbarTitle:
                                                  AppLocalizations.of(context)
                                                      .translate(LanguageKeys
                                                          .termCondition),
                                            ),
                                          ),
                                        );
                                      },
                                      child: AccountSettingsItem(
                                        image: "assets/images/ic_tnc.png",
                                        title: AppLocalizations.of(context)
                                            .translate(
                                                LanguageKeys.termCondition),
                                        isNew: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomWidget().textLight(
                    "v " + SharedPreferencesService().appVersion,
                    PopboxColor.mdBlack1000,
                    12,
                    TextAlign.center),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sunwayPalsMY() {
    return GestureDetector(
      onTap: () {
        Navigator.of(this.context).push(
          MaterialPageRoute(
            builder: (context) => SunwaypalsPage(),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: 5.0),
        padding: EdgeInsets.only(left: 15.0, right: 15.0),
        width: 100.0.w,
        height: 56.0,
        decoration: BoxDecoration(
          color: PopboxColor.redFF322A,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(top: 9.0, bottom: 9.0),
              child: Image.asset(
                "assets/images/ic_sunwaypals.png",
                fit: BoxFit.contain,
              ),
            ),
            Container(
              height: 100.0.h,
              margin: EdgeInsets.only(top: 11.0, bottom: 11.0),
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              decoration: BoxDecoration(
                color: PopboxColor.mdWhite1000,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Align(
                  alignment: Alignment.center,
                  child: isConnected
                      ? Row(
                          children: [
                            CustomWidget().textMedium(
                              'Connected',
                              PopboxColor.mdGrey900,
                              10.0.sp,
                              TextAlign.left,
                            ),
                            SizedBox(width: 4.0),
                            Icon(Icons.verified, color: Colors.green),
                          ],
                        )
                      : Container(
                          child: CustomWidget().textMedium(
                            'Connect to ID Pals',
                            PopboxColor.mdGrey900,
                            10.0.sp,
                            TextAlign.left,
                          ),
                        )),
            )
          ],
        ),
      ),
    );
  }

  Widget alertEmailVerification(BuildContext context, String emailAddress) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AccountEmailverificationPage(
                emailAddress: emailAddress, isVerifiedEmail: isVerifiedEmail),
          ),
        );
      },
      child: Container(
        width: 100.0.w,
        padding:
            const EdgeInsets.only(left: 25, right: 15, top: 24, bottom: 24),
        decoration: BoxDecoration(
            color: Color(0xffFFF7EA), borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Color(0xffFFC773),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget().textBoldPlus(
                  AppLocalizations.of(context)
                      .translate(LanguageKeys.notYetVerification),
                  PopboxColor.mdBlack1000,
                  13,
                  TextAlign.left,
                ),
                SizedBox(height: 4),
                CustomWidget().textMedium(
                  AppLocalizations.of(context)
                      .translate(LanguageKeys.doVerification),
                  PopboxColor.mdBlack1000,
                  11,
                  TextAlign.left,
                ),
                SizedBox(height: 2),
                CustomWidget().textBoldPlus(
                  AppLocalizations.of(context)
                      .translate(LanguageKeys.verifyNow),
                  Color(0xffFF9D09),
                  11,
                  TextAlign.left,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _doUserCheck() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 100));
    final userModel = Provider.of<UserViewModel>(this.context, listen: false);

    UserCheckPayload userCheckPayload = new UserCheckPayload(
      token: GlobalVar.API_TOKEN,
      phone: SharedPreferencesService().user.phone.replaceAll("", ""),
      deviceId: loginPayload.deviceId,
      notificationSetting: loginPayload.notificationSetting,
      onesignalPlayerId: loginPayload.onesignalPlayerId,
    );

    userModel.userCheck(userCheckPayload, this.context, isSaveCallbak: false,
        onSuccess: (response) async {
      setState(() {
        isEmailVerified = response.data.first.statusEmail;
        emailAddress = response.data.first.email;
        //SharedPreferencesService().setShowCase(true);
        if (isEmailVerified == "UNVERIFIED") {
          SharedPreferencesService().setVerifiedEmail(false);
        } else {
          SharedPreferencesService().setVerifiedEmail(true);
        }
      });
    }, onError: (response) {
      //case 1 :
      if (response.response.code == 400) {
        // print("case1");
      } else {
        try {
          CustomWidget().showCustomDialog(
              context: this.context, msg: response.response.message);
        } catch (e) {
          CustomWidget()
              .showCustomDialog(context: this.context, msg: e.toString());
        }
      }
    });
  }
}
