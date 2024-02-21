import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/otp_counter.dart';
import 'package:new_popbox/core/models/payload/login_payload.dart';
import 'package:new_popbox/core/models/payload/otp_validation_payload.dart';
import 'package:new_popbox/core/models/payload/phone_no_payload.dart';
import 'package:new_popbox/core/pinput/pin_put.dart';
import 'package:new_popbox/core/utils/global_function.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/pages/account_info_page.dart';
import 'package:new_popbox/ui/pages/error_network_page.dart';
import 'package:new_popbox/ui/pages/merge_account_info_page.dart';
import 'package:new_popbox/ui/pages/onboarding_page.dart';
import 'package:new_popbox/ui/pages/otp_method_page.dart';
import 'package:new_popbox/ui/pages/pin_page.dart';
import 'package:new_popbox/ui/pages/register_data_page.dart';
import 'package:new_popbox/ui/pages/register_page.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:new_popbox/ui/widget/help_view.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:remove_emoji/remove_emoji.dart';

class OtpVerificationPage extends StatefulWidget {
  final String reason;
  final String platform;
  final String mergePhoneNo;
  final bool showDotsIndicator;

  const OtpVerificationPage(
      {Key key,
      this.reason,
      this.platform,
      this.mergePhoneNo,
      this.showDotsIndicator = true})
      : super(key: key);
  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  final _pageController = PageController();

  LoginPayload loginPayload = new LoginPayload();

  String fcmToken = "";
  String model = "";
  String deviceVersion = "";
  String identifier = "";
  String brand = "";
  String osVersion = "";
  String osType = "";
  bool isOnline = false;
  int citCallMax = 0;

  SharedPreferencesService sharedPrefService;

  OtpValidationPayload otpValidationPayload =
      SharedPreferencesService().otpValidationPayload;
  DateTime currentBackPressTime;
  String phoneNumber = "";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      sharedPrefService = await SharedPreferencesService.instance;

      fcmToken = sharedPrefService.fcmToken;

      List<String> deviceInfo = await getDeviceDetails();
      model = deviceInfo[0];
      deviceVersion = deviceInfo[1];
      identifier = deviceInfo[2];
      brand = deviceInfo[3];
      osVersion = deviceInfo[4];
      osType = deviceInfo[5];

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      String code = packageInfo.buildNumber;

      loginPayload.deviceId =
          identifier.removemoji.replaceAll(RegExp('[^A-Za-z0-9]'), '');
      //devicename
      if (Platform.isAndroid) {
        loginPayload.deviceName = (brand +
                " " +
                model +
                " os version " +
                osVersion +
                " app version " +
                version +
                " build " +
                code)
            .removemoji
            .replaceAll(RegExp('[^A-Za-z0-9]'), '');
      }

      if (Platform.isIOS) {
        loginPayload.deviceName = ("os version " +
                osVersion +
                " app version " +
                version +
                " build " +
                code)
            .removemoji
            .replaceAll(RegExp('[^A-Za-z0-9]'), '');
      }

      loginPayload.appVersions = code;
      loginPayload.deviceType = osType;
      loginPayload.gcmToken = fcmToken;
      loginPayload.onesignalPlayerId = fcmToken;
      loginPayload.token = GlobalVar.API_TOKEN;

      loginPayload.phoneNumber = otpValidationPayload.phone;
      loginPayload.notificationSetting = await isNotificationOn();
    });

    startTimer();
    getPermission().then((value) {
      if (value) {
        PlatformChannel().callStream().listen((event) {
          var arr = event.split("-");
          phoneNumber = arr[0];

          setState(() {
            _pinPutController.text =
                phoneNumber.substring(phoneNumber.length - 6);
          });
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    hasNetwork().then((result) {
      setState(() {
        isOnline = result;
      });
    });
    int dotCounter = 3;
    if (SharedPreferencesService().locationSelected == "PH" &&
        GlobalVar.showUploadIdStep) {
      dotCounter = 4;
    }

    String phoneNo = "";
    String titleCaption = "";

    try {
      phoneNo = SharedPreferencesService().otpValidationPayload.phone;
      // .replaceFirst(RegExp("0"), "", 0)
      // .replaceFirst(RegExp("62"), "", 0)
      // .replaceFirst(RegExp("60"), "")
      // .replaceFirst(RegExp("63"), "");

      if (widget.platform == "call") {
        titleCaption = AppLocalizations.of(context)
            .translate(LanguageKeys.weHaveMadeAnOtpCall);
      } else if (widget.platform == "sms") {
        titleCaption = AppLocalizations.of(context)
            .translate(LanguageKeys.inputSentVerificationCodeSms);
      } else if (widget.platform == "whatsapp") {
        titleCaption = AppLocalizations.of(context)
            .translate(LanguageKeys.inputSentVerificationCodeWa);
      }

      if (phoneNo.startsWith("0")) {
        phoneNo = phoneNo.replaceFirst(RegExp("0"), "");
      }

      if (phoneNo.startsWith("62")) {
        phoneNo = phoneNo.replaceFirst(RegExp("62"), "");
      }

      if (phoneNo.startsWith("60")) {
        phoneNo = phoneNo.replaceFirst(RegExp("60"), "");
      }

      if (phoneNo.startsWith("63")) {
        phoneNo = phoneNo.replaceFirst(RegExp("63"), "");
      }

      titleCaption = titleCaption.replaceAll(
          "%1s", SharedPreferencesService().phoneCode + phoneNo);
    } catch (e) {}

    return Consumer<UserViewModel>(
      builder: (context, model, _) {
        return Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: false,
              body: WillPopScope(
                onWillPop: () {
                  onWillPop(context);
                },
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(),
                          widget.showDotsIndicator
                              ? (widget.reason == "forgot_pin" ||
                                      widget.reason == "register")
                                  ? Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 40.0, 16.0, 0.0),
                                      child: Row(
                                        children: [
                                          _buildPageIndicator(true),
                                          _buildPageIndicator(true),
                                          _buildPageIndicator(false)
                                        ],
                                      ),
                                    )
                                  : Container()
                              : Container(),
                        ],
                      ),
                      widget.platform == "call"
                          ? Container(
                              margin: EdgeInsets.only(top: 35, left: 20),
                              child: CustomWidget().textBold(
                                AppLocalizations.of(context)
                                    .translate(
                                        LanguageKeys.callVerificationTitle)
                                    .replaceAll("%phone", phoneNo),
                                PopboxColor.mdGrey900,
                                16,
                                TextAlign.left,
                              ),
                            )
                          : Container(),
                      widget.platform == "call"
                          ? Container(
                              margin: EdgeInsets.only(left: 20, top: 20),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(
                                          builder: (context) => RegisterPage(
                                                from: "onboarding",
                                              )));
                                },
                                child: Row(
                                  children: [
                                    CustomWidget().textLight(
                                      AppLocalizations.of(context).translate(
                                              LanguageKeys.wrongPhoneNo) +
                                          "? ",
                                      PopboxColor.mdBlack1000,
                                      12,
                                      TextAlign.left,
                                    ),
                                    CustomWidget().textLight(
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.change),
                                      PopboxColor.blue477FFF,
                                      12,
                                      TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 40.0, 16.0, 0.0),
                              child: CustomWidget().textBold(
                                titleCaption,
                                PopboxColor.mdBlack1000,
                                12.0.sp,
                                TextAlign.left,
                              ),
                            ),
                      widget.platform == "call"
                          ? SizedBox(height: 27)
                          : SizedBox(),
                      GestureDetector(
                        onLongPress: () {
                          // print(_formKey.currentState.validate());
                        },
                        child: Container(
                          width: 100.0.w,
                          padding: const EdgeInsets.only(
                              left: 0.0, right: 0.0, top: 48.0),
                          child: PinPut(
                            validator: (s) {
                              if (s.contains('1')) return null;
                              return 'NOT VALID';
                            },
                            useNativeKeyboard: true,
                            onSubmit: (String pin) async {
                              otpValidationPayload.gcmTokenId = fcmToken;
                              otpValidationPayload.token =
                                  GlobalVar.API_TOKEN_INTERNAL;
                              otpValidationPayload.pin = pin;

                              otpValidation(context, otpValidationPayload);
                            },
                            // autovalidateMode: AutovalidateMode.onUserInteraction,
                            withCursor: true,
                            fieldsCount: 6,
                            keyboardType: TextInputType.number,
                            fieldsAlignment: MainAxisAlignment.center,
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.0,
                                fontFamily: "Montserrat",
                                color: Colors.black),
                            eachFieldMargin: EdgeInsets.all(7.0),
                            eachFieldWidth: 40.0,
                            eachFieldHeight: 40.0,
                            focusNode: _pinPutFocusNode,
                            controller: _pinPutController,
                            submittedFieldDecoration: pinPutDecoration,
                            selectedFieldDecoration: pinPutDecoration.copyWith(
                              color: PopboxColor.mdWhite1000,
                              border: Border.all(
                                width: 2,
                                color: PopboxColor.mdGrey250,
                              ),
                            ),
                            followingFieldDecoration: pinPutDecoration,
                            pinAnimationType: PinAnimationType.scale,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: countdownTimer == 0 && (citCallMax >= 1)
                            ? Column(
                                children: [
                                  RichText(
                                    textAlign: TextAlign.left,
                                    softWrap: true,
                                    text: new TextSpan(
                                      text: AppLocalizations.of(context)
                                              .translate(
                                                  LanguageKeys.notReceivedOtp) +
                                          " ",
                                      style: new TextStyle(
                                        fontSize: 11.0.sp,
                                        fontWeight: FontWeight.w400,
                                        color: PopboxColor.mdGrey700,
                                        fontFamily: "Montserrat",
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 20, right: 20, top: 20),
                                    child: CustomButtonRectangle(
                                      onPressed: () =>
                                          Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => OtpMethodPage(
                                            reason: widget.reason,
                                            isCitcall: false,
                                          ),
                                        ),
                                      ),
                                      title: AppLocalizations.of(context)
                                          .translate(LanguageKeys
                                              .verifyWithOtherMethod),
                                      bgColor: PopboxColor.popboxRed,
                                      textColor: PopboxColor.mdWhite1000,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  countdownTimer == 0 && (citCallMax < 1)
                                      ? InkWell(
                                          onTap: () {
                                            if (countdownTimer == 0) {
                                              otpRequest();
                                              citCallMax += 1;
                                            } else {}
                                          },
                                          child: RichText(
                                            textAlign: TextAlign.left,
                                            softWrap: true,
                                            text: new TextSpan(
                                              text: AppLocalizations.of(context)
                                                      .translate(LanguageKeys
                                                          .notReceivedOtp) +
                                                  " ",
                                              style: new TextStyle(
                                                fontSize: 11.0.sp,
                                                fontWeight: FontWeight.w400,
                                                color: PopboxColor.mdGrey700,
                                                fontFamily: "Montserrat",
                                              ),
                                              children: <TextSpan>[
                                                new TextSpan(
                                                    text: AppLocalizations.of(
                                                            context)
                                                        .translate(LanguageKeys
                                                            .resend),
                                                    style: TextStyle(
                                                      color: PopboxColor
                                                          .blue477FFF,
                                                      fontSize: 10.0.sp,
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    )),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 100.0.w,
                                          child: RichText(
                                            textAlign: TextAlign.center,
                                            softWrap: true,
                                            maxLines: 2,
                                            overflow: TextOverflow.fade,
                                            text: new TextSpan(
                                              text: AppLocalizations.of(context)
                                                      .translate(LanguageKeys
                                                          .notReceivedOtpSendIn) +
                                                  " ",
                                              style: new TextStyle(
                                                fontSize: 10.0.sp,
                                                color: PopboxColor.mdGrey700,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Montserrat",
                                              ),
                                              children: <TextSpan>[
                                                new TextSpan(
                                                    text: countdownTimer
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: PopboxColor
                                                          .blue477FFF,
                                                      fontSize: 10.0.sp,
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          callCsBottomSheet(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.fromLTRB(
                              16.0, 150.0, 16.0, 32.0),
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
                                      fontWeight: FontWeight.w500,
                                    )),
                                new TextSpan(
                                  text: " " +
                                      AppLocalizations.of(context).translate(
                                          LanguageKeys
                                              .callPopboxCustomerService),
                                  style: TextStyle(
                                    color: PopboxColor.blue477FFF,
                                    fontSize: 10.0.sp,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w500,
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
        );
      },
    );
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

  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: PopboxColor.mdWhite1000,
    borderRadius: BorderRadius.circular(4.0),
    border: Border.all(color: PopboxColor.mdGrey350),
  );

  void pinVerification(BuildContext context) {
    resetOtp();
    if (widget.reason == "forgot_pin" || widget.reason == "verification") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PinPage(
            loginPayload: loginPayload,
            reason: widget.reason,
          ),
        ),
      );
    } else if (widget.reason == "pre_login_password") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PinPage(
            loginPayload: loginPayload,
            reason: "create_pin",
          ),
        ),
      );
    } else if (widget.reason == "add_phone") {
      PhoneNoPayload phoneNoPayload = new PhoneNoPayload()
        ..memberId = SharedPreferencesService().user.memberId
        ..phone = SharedPreferencesService().otpValidationPayload.phone
        ..sessionId = SharedPreferencesService().user.sessionId
        ..token = GlobalVar.API_TOKEN
        ..status = "VERIFIED";

      final userModel = Provider.of<UserViewModel>(context, listen: false);

      userModel.multiplePhone(
        "add",
        phoneNoPayload,
        context,
        onSuccess: (response) {
          resetOtp();
          setState(() {
            if (sharedPrefService.user != null) {
              response.data.first.pin = sharedPrefService.user.pin;
              response.data.first.isGuest = sharedPrefService.user.isGuest;
            }

            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => AccountInfoPage(
                    from: "otp",
                  ),
                ),
                (Route<dynamic> route) => false);
          });
        },
        onError: (response) {
          CustomWidget().showCustomDialog(
              context: context, msg: response.response.message);
        },
      );
    } else if (widget.reason == "case2" ||
        widget.reason == "case3" ||
        widget.reason == "case6") {
      navigateToMergeInfo(widget.reason);
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => RegisterDataPage()));
    }
  }

  void otpValidation(BuildContext context, OtpValidationPayload payload) {
    final userModel = Provider.of<UserViewModel>(context, listen: false);
    userModel.otpValidation(
      payload,
      context,
      onSuccess: (response) {
        if (response.response.code == "200") {
          resetOtp();
          sharedPrefService.setIsVerifiedRegister(true);

          pinVerification(context);
        } else {
          try {
            CustomWidget().showCustomDialog(
                context: context, msg: response.response.message);
          } catch (e) {
            CustomWidget()
                .showCustomDialog(context: context, msg: e.toString());
          }
        }
      },
      onError: (response) {
        try {
          (isOnline)
              ? CustomWidget().showCustomDialog(
                  context: context, msg: response.response.message)
              : Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ErrorNetworkPage()));
          setState(() {});
        } catch (e) {
          CustomWidget().showCustomDialog(context: context, msg: e.toString());
        }
      },
    );
  }

  Timer _timer;
  int countdownTimer = 30;
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (countdownTimer == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            countdownTimer--;
          });
        }
      },
    );
  }

  void otpRequest() {
    final userModel = Provider.of<UserViewModel>(context, listen: false);
    OtpCounter otpCounter = SharedPreferencesService().otpCounter;
    if (SharedPreferencesService().otpRequestPayload.platform == "whatsapp" &&
        otpCounter.wa == 3) {
      Navigator.pop(context);
    } else if (SharedPreferencesService().otpRequestPayload.platform == "sms" &&
        otpCounter.sms == 3) {
      Navigator.pop(context);
    } else if (SharedPreferencesService().otpRequestPayload.platform ==
            "call" &&
        otpCounter.call == 3) {
      Navigator.pop(context);
    } else {
      userModel.otpRequest(
        SharedPreferencesService().otpRequestPayload,
        context,
        onSuccess: (response) {
          if (response.response.code == "200") {
            OtpValidationPayload otpValidationPayload =
                new OtpValidationPayload();

            otpValidationPayload.phone =
                SharedPreferencesService().otpRequestPayload.phone;
            otpValidationPayload.email =
                SharedPreferencesService().otpRequestPayload.email;

            SharedPreferencesService()
                .setOtpValidationPayload(otpValidationPayload);

            setState(() {
              countdownTimer = 30;
            });
            startTimer();
          } else {
            try {
              CustomWidget().showCustomDialog(
                  context: context, msg: response.response.message);
            } catch (e) {
              CustomWidget()
                  .showCustomDialog(context: context, msg: e.toString());
            }
          }
        },
        onError: (response) {
          try {
            CustomWidget().showCustomDialog(
                context: context, msg: response.response.message);
          } catch (e) {
            CustomWidget()
                .showCustomDialog(context: context, msg: e.toString());
          }
        },
      );
    }
  }

  void resetOtp() {
    setState(() {
      OtpCounter otpCounter = new OtpCounter(wa: 0, sms: 0, call: 0);

      SharedPreferencesService().setOtCounter(otpCounter);
    });
  }

  void navigateToMergeInfo(String from) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MergeAccountInfoPage(
          from: from,
          mergePhoneNo: widget.mergePhoneNo,
        ),
      ),
    );
  }

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isOnline = true;
        return true;
      }

      return false;
    } catch (e) {
      isOnline = false;
    }
    return false;
  }

  Widget _buildPageIndicator(bool active) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.0),
      height: active ? 6.5 : 7.0,
      width: active ? 6.5 : 7.0,
      decoration: BoxDecoration(
        border: Border.all(color: PopboxColor.blue477FFF),
        color: active ? PopboxColor.blue477FFF : PopboxColor.mdWhite1000,
        borderRadius: BorderRadius.circular(30),
      ),
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
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => OnboardingPage(),
          ),
          (Route<dynamic> route) => false);
      return Future.value(true);
    }
  }

  Future<bool> getPermission() async {
    if (await Permission.phone.status == PermissionStatus.granted) {
      return true;
    } else {
      if (await Permission.phone.request() == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }
}

class PlatformChannel {
  static const _channel = EventChannel("asia.popbox.app/callStream");

  Stream callStream() async* {
    yield* _channel.receiveBroadcastStream();
  }
}
