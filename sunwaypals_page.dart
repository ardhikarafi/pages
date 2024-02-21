import 'dart:io';

import 'package:flutter/material.dart';
import 'package:new_popbox/core/bloc/bottom_navigation/bottom_navigation_bloc.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/payload/sunway_pals_campaign_payload.dart';
import 'package:new_popbox/core/models/payload/sunway_pals_remove_payload.dart';
import 'package:new_popbox/core/models/payload/sunway_pals_validate_payload.dart';
import 'package:new_popbox/core/models/payload/user_check_payload.dart';
import 'package:new_popbox/core/utils/global_function.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/pages/error_network_page.dart';
import 'package:new_popbox/ui/pages/home.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:remove_emoji/remove_emoji.dart';

class SunwaypalsPage extends StatefulWidget {
  @override
  State<SunwaypalsPage> createState() => _SunwaypalsPageState();
}

class _SunwaypalsPageState extends State<SunwaypalsPage> {
  bool isConnectedAccount = true;
  final _sunwaypalsmemberid = TextEditingController();
  final _sunwayCampaignCode = TextEditingController();
  String campaignCodeMessage = "";
  bool campaignCodeResult = true;
  bool isTyping = false;
  String fcmToken = "";
  String model = "";
  String deviceVersion = "";
  String identifier = "";
  String brand = "";
  String osVersion = "";
  String osType = "";
  String notifSetting = "";
  SharedPreferencesService sharedPrefService;
  bool isOnline = false;

  @override
  void initState() {
    if (SharedPreferencesService().user.palsStatus.toString() == "null" ||
        SharedPreferencesService().user.palsStatus.toString() == "removed") {
      isConnectedAccount = false; //false
    } else {
      isConnectedAccount = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (fcmToken == null || fcmToken == "") {
        fcmToken = SharedPreferencesService().fcmToken;
      } else {
        fcmToken = sharedPrefService.fcmToken;
      }

      //DeviceDetail
      List<String> deviceInfo = await getDeviceDetails();
      model = deviceInfo[0];
      deviceVersion = deviceInfo[1];
      identifier = deviceInfo[2];
      brand = deviceInfo[3];
      osVersion = deviceInfo[4];
      osType = deviceInfo[5];
      //Notif
      notifSetting = await isNotificationOn();
      //SharedPref
      sharedPrefService = await SharedPreferencesService.instance;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    hasNetwork().then((result) {
      setState(() {
        isOnline = result;
      });
    });
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        handleWillPop();
      },
      child: Consumer<UserViewModel>(
        builder: (context, model, _) => Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => backStateNav(context)),
                backgroundColor: PopboxColor.mdWhite1000,
              ),
              body: Container(
                margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              connectToSunwayTitle(context),
                              connectToSunwayDesc(context),
                              fieldSunwayIDTitle(),
                              fieldSunwayIDForm(),
                              isConnectedAccount
                                  ? Container()
                                  : fieldSunwayPalsDesc(),
                              SizedBox(height: 30.0),
                              isConnectedAccount
                                  ? Container()
                                  : campaignCodeTitle(),
                              isConnectedAccount
                                  ? Container()
                                  : campaignCodeField(),
                              isConnectedAccount
                                  ? Container()
                                  : fieldSunwayPalsDescResponse()
                            ],
                          ),
                        ],
                      ),
                    ),
                    isConnectedAccount
                        ? Container()
                        : CustomButtonRed(
                            onPressed: () {
                              if (isConnectedAccount) {
                                backStateNav(context);
                              } else {
                                //SUNWAY VALIDATE MEMBER BUTTON
                                var userviewmodel = Provider.of<UserViewModel>(
                                    context,
                                    listen: false);
                                SunwayPalsValidatePayload
                                    sunwayPalsValidatePayload =
                                    new SunwayPalsValidatePayload();
                                sunwayPalsValidatePayload.token =
                                    GlobalVar.API_TOKEN;
                                sunwayPalsValidatePayload.sessionId =
                                    sharedPrefService.user.sessionId;

                                sunwayPalsValidatePayload.palsMemberId =
                                    _sunwaypalsmemberid.text;
                                sunwayPalsValidatePayload.campaignCode =
                                    _sunwayCampaignCode.text;

                                userviewmodel.sunwayValidate(
                                    sunwayPalsValidatePayload, context,
                                    onSuccess: (response) {
                                  isConnectedAccount = true;
                                  _showDialog(
                                      context, response.response.message);
                                  hitUserCheck();
                                }, onError: (response) {
                                  try {
                                    (isOnline)
                                        ? CustomWidget().showCustomDialog(
                                            context: context,
                                            msg: response.response.message)
                                        : Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ErrorNetworkPage()));
                                    setState(() {});
                                  } catch (e) {
                                    CustomWidget().showCustomDialog(
                                        context: context, msg: e.toString());
                                  }
                                });
                              }
                            },
                            title: AppLocalizations.of(context)
                                .translate(LanguageKeys.connect),
                            width: 100.0.w,
                            isActive: true,
                          )
                  ],
                ),
              ),
            ),
            if (model.loading)
              AbsorbPointer(
                child: Container(
                  width: 100.0.w,
                  height: 100.0.h,
                  color: Colors.grey.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget connectToSunwayTitle(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
      child: isConnectedAccount
          ? CustomWidget().textBold(
              AppLocalizations.of(context)
                  .translate(LanguageKeys.accountConnected),
              PopboxColor.mdBlack1000,
              14.0.sp,
              TextAlign.left,
            )
          : CustomWidget().textBold(
              AppLocalizations.of(context)
                  .translate(LanguageKeys.connectToCase)
                  .replaceAll("%1s", "Sunway Pals"),
              PopboxColor.mdBlack1000,
              14.0.sp,
              TextAlign.left,
            ),
    );
  }

  Widget connectToSunwayDesc(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 40.0),
      child: isConnectedAccount
          ? CustomWidget().textRegular(
              AppLocalizations.of(context)
                  .translate(LanguageKeys.sunwayAccountConnectedDesc),
              PopboxColor.mdGrey700,
              11.0.sp,
              TextAlign.left,
            )
          : CustomWidget().textRegular(
              AppLocalizations.of(context)
                  .translate(LanguageKeys.connectToCaseDesc)
                  .replaceAll("%1s", "Sunway Pals"),
              PopboxColor.mdGrey700,
              11.0.sp,
              TextAlign.left,
            ),
    );
  }

  Widget fieldSunwayIDTitle() {
    return Container(
      padding: EdgeInsets.only(bottom: 10.0),
      child: CustomWidget().textBold(
          AppLocalizations.of(context)
              .translate(LanguageKeys.caseMemberId)
              .replaceAll("%1s", "Sunway Pals"),
          PopboxColor.mdBlack1000,
          9.0.sp,
          TextAlign.left),
    );
  }

  Widget campaignCodeTitle() {
    return Container(
      padding: EdgeInsets.only(bottom: 10.0),
      child: CustomWidget().textBold(
          'Campaign Code', PopboxColor.mdBlack1000, 9.0.sp, TextAlign.left),
    );
  }

  Widget fieldSunwayPalsDesc() {
    return Container(
      padding: EdgeInsets.only(top: 7.0),
      child: CustomWidget().textRegular('Enter your member ID',
          PopboxColor.mdBlack1000, 9.0.sp, TextAlign.left),
    );
  }

  Widget fieldSunwayPalsDescResponse() {
    return Container(
      padding: EdgeInsets.only(top: 7.0),
      child: CustomWidget().textRegular(
          campaignCodeMessage,
          campaignCodeResult ? PopboxColor.mdBlack1000 : PopboxColor.red,
          9.0.sp,
          TextAlign.left),
    );
  }

  Widget fieldSunwayIDForm() {
    return Container(
      color: PopboxColor.mdWhite1000,
      child: TextField(
        readOnly: isConnectedAccount ? true : false,
        controller: _sunwaypalsmemberid,
        autocorrect: true,
        cursorColor: PopboxColor.mdGrey700,
        style: TextStyle(
          color: PopboxColor.mdBlack1000,
          fontSize: 12.0.sp,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
            hintText: isConnectedAccount
                ? SharedPreferencesService().user.palsMemberId.toString()
                : "",
            hintStyle: TextStyle(color: PopboxColor.mdGrey900),
            filled: true,
            fillColor: PopboxColor.mdGrey150,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(color: PopboxColor.mdGrey300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(color: PopboxColor.mdGrey300),
            ),
            suffixIcon: InkWell(
              onTap: () {
                CustomWidget().showAlertDialogWithButton(context,
                    noCallBack: () {
                  Navigator.of(context).pop();
                }, yesCallback: () {
                  var userviewmodel =
                      Provider.of<UserViewModel>(context, listen: false);
                  SunwayPalsRemovePayload sunwayPalsRemovePayload =
                      new SunwayPalsRemovePayload();
                  sunwayPalsRemovePayload.token = GlobalVar.API_TOKEN;
                  sunwayPalsRemovePayload.sessionId =
                      sharedPrefService.user.sessionId;
                  sunwayPalsRemovePayload.palsMemberId =
                      sharedPrefService.user.palsMemberId.toString();

                  userviewmodel.sunwayRemove(sunwayPalsRemovePayload, context,
                      onSuccess: (response) {
                    Navigator.pop(context);
                    isConnectedAccount = false;
                    _showDialog(context, response.response.message);
                    hitUserCheck();
                  }, onError: (response) {
                    Navigator.pop(context);
                    try {
                      (isOnline)
                          ? CustomWidget().showCustomDialog(
                              context: context, msg: response.response.message)
                          : Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ErrorNetworkPage()));
                      setState(() {});
                    } catch (e) {
                      CustomWidget().showCustomDialog(
                          context: context, msg: e.toString());
                    }
                  });
                },
                    title: AppLocalizations.of(context)
                        .translate(LanguageKeys.caseMemberId)
                        .replaceAll(
                            "%1s",
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.remove)),
                    message: AppLocalizations.of(context)
                        .translate(LanguageKeys.areYouSureDeleteCase)
                        .replaceAll(
                            "%1s",
                            "Sunway Pals " +
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.account) +
                                "?"),
                    noTitle: AppLocalizations.of(context)
                        .translate(LanguageKeys.cancel),
                    yesTitle: AppLocalizations.of(context)
                        .translate(LanguageKeys.remove));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  isConnectedAccount
                      ? Container(
                          margin:
                              EdgeInsets.only(right: 16, top: 0.0, bottom: 0.0),
                          width: 80.0,
                          height: 40.0,
                          child: Center(
                            child: CustomWidget().textRegular(
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.remove),
                                PopboxColor.red,
                                11.0.sp,
                                TextAlign.center),
                          ),
                        )
                      : Container(),
                ],
              ),
            )),
      ),
    );
  }

  Future<bool> handleWillPop() async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (c) => Home()), (route) => false);
    return true;
  }

  backStateNav(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          context.read<BottomNavigationBloc>().add(
                PageTapped(index: 3),
              );
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (c) => Home()), (route) => false);
        }));
  }

  void _onChangeCampaign(String inputKeyword) {
    if (inputKeyword.length >= 3) {
      isTyping = true;
    } else if (inputKeyword.length == 0) {
      campaignCodeMessage = "";
    } else {
      isTyping = false;
    }
    setState(() {});
  }

  hitUserCheck() {
    final userModel = Provider.of<UserViewModel>(context, listen: false);
    UserCheckPayload userCheckPayload = new UserCheckPayload(
      token: GlobalVar.API_TOKEN,
      phone: sharedPrefService.user.phone,
      deviceId: identifier.removemoji.replaceAll(RegExp('[^A-Za-z0-9]'), ''),
      notificationSetting: notifSetting,
      onesignalPlayerId: fcmToken,
    );
    userModel.userCheck(userCheckPayload, context,
        onSuccess: (response) {}, onError: (response) {});
  }

  Widget campaignCodeField() {
    return Container(
      color: PopboxColor.mdWhite1000,
      height: 58,
      child: TextField(
        onChanged: (_sunwayCampaignCode) {
          _onChangeCampaign(_sunwayCampaignCode);
        },
        controller: _sunwayCampaignCode,
        autocorrect: true,
        cursorColor: PopboxColor.mdGrey700,
        style: TextStyle(
          color: PopboxColor.mdBlack1000,
          fontSize: 12.0.sp,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          contentPadding: new EdgeInsets.only(left: 17),
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                  onTap: () {
                    _sunwayCampaignCode.clear();
                    setState(() {
                      isTyping = false;
                      campaignCodeMessage = "";
                    });
                  },
                  child: Image.asset("assets/images/ic_popsafe_close.png")),
              SizedBox(width: 7),
              InkWell(
                onTap: () {
                  var userviewmodel =
                      Provider.of<UserViewModel>(context, listen: false);
                  SunwayPalsCampaignPayload sunwayPalsCampaignPayload =
                      new SunwayPalsCampaignPayload();
                  sunwayPalsCampaignPayload.token = GlobalVar.API_TOKEN;
                  sunwayPalsCampaignPayload.sessionId =
                      SharedPreferencesService().user.sessionId;
                  sunwayPalsCampaignPayload.campaignCode =
                      _sunwayCampaignCode.text;
                  userviewmodel
                      .sunwayCampaign(sunwayPalsCampaignPayload, context,
                          onSuccess: (response) {
                    setState(() {
                      campaignCodeMessage = response.response.message;
                      campaignCodeResult = true;
                    });
                  }, onError: (response) {
                    try {
                      (isOnline)
                          ? CustomWidget().showCustomDialog(
                              context: context, msg: response.response.message)
                          : Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ErrorNetworkPage()));
                      setState(() {
                        if (isOnline) {
                          campaignCodeMessage = response.response.message;
                          campaignCodeResult = false;
                        } else {
                          campaignCodeMessage = "";
                        }
                      });
                    } catch (e) {
                      CustomWidget().showCustomDialog(
                          context: context, msg: e.toString());
                    }
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 16, top: 6.0, bottom: 6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isTyping
                        ? PopboxColor.popboxRed
                        : PopboxColor.mdGrey300,
                  ),
                  width: 100,
                  child: Center(
                      child: CustomWidget().textRegular(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.use),
                          PopboxColor.mdWhite1000,
                          11.0.sp,
                          TextAlign.center)),
                ),
              ),
            ],
          ),
          hintText: AppLocalizations.of(context)
              .translate(LanguageKeys.inputPromoCode),
          hintStyle: TextStyle(color: PopboxColor.mdGrey500),
          filled: true,
          fillColor: PopboxColor.mdGrey150,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: PopboxColor.mdGrey300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: PopboxColor.mdGrey300),
          ),
        ),
      ),
    );
  }

  _showDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (context) {
          return GestureDetector(
              child: AlertDialog(
                  title: Column(
                    children: <Widget>[
                      Container(
                        child: CustomWidget().textBold('INFO',
                            PopboxColor.mdGrey600, 10.0.sp, TextAlign.left),
                      )
                    ],
                  ),
                  content: CustomWidget().textBold(
                    message,
                    PopboxColor.mdBlack1000,
                    10.0.sp,
                    TextAlign.center,
                  ),
                  actions: <Widget>[]),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (c) => Home()),
                    (route) => false);
              });
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
}
