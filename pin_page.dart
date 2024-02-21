import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:new_popbox/core/bloc/bottom_navigation/bottom_navigation_bloc.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/user/login_response.dart';
import 'package:new_popbox/core/models/payload/change_profile_payload.dart';

import 'package:new_popbox/core/models/payload/create_pin_payload.dart';
import 'package:new_popbox/core/models/payload/delete_account_payload.dart';
import 'package:new_popbox/core/models/payload/edit_pin_payload.dart';
import 'package:new_popbox/core/models/payload/hooks_slack_payload.dart';
import 'package:new_popbox/core/models/payload/login_payload.dart';
import 'package:new_popbox/core/models/payload/logout_payload.dart';
import 'package:new_popbox/core/models/payload/one_signal_external_payload.dart';
import 'package:new_popbox/core/models/payload/register_payload.dart';
import 'package:new_popbox/core/models/payload/user_check_payload.dart';
import 'package:new_popbox/core/pinput/pin_put.dart';
import 'package:new_popbox/core/utils/global_function.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/pages/account_info_page.dart';
import 'package:new_popbox/ui/pages/error_network_page.dart';
import 'package:new_popbox/ui/pages/login_page.dart';
import 'package:new_popbox/ui/pages/otp_method_page.dart';
import 'package:new_popbox/ui/pages/register_id_page.dart';
import 'package:new_popbox/ui/pages/register_page.dart';
import 'package:new_popbox/ui/pages/splash_screen_page.dart';
import 'package:new_popbox/ui/pages/success_page.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:new_popbox/ui/widget/splash_screen_welcome_widget.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:remove_emoji/remove_emoji.dart';

class PinPage extends StatefulWidget {
  final LoginPayload loginPayload;
  final String reason;
  final String removeAccReason;
  const PinPage(
      {@required this.loginPayload,
      @required this.reason,
      this.removeAccReason});
  @override
  _PinPageState createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  final _pageController = PageController();

  int _pageIndex = 0;
  String fcmToken = "";
  String model = "";
  String deviceVersion = "";
  String identifier = "";
  String brand = "";
  String osVersion = "";
  String osType = "";
  String subTitle = "";
  LoginResponse loginResponse;
  bool isOnline = false;
  String oneSignalExternalUserId = "";
  bool loading = false;
  String locationSelected = "";

  final List<Color> _bgColors = [
    Colors.white,
    const Color.fromRGBO(43, 36, 198, 1),
    Colors.white,
    const Color.fromRGBO(75, 83, 214, 1),
    const Color.fromRGBO(43, 46, 66, 1),
  ];

  RegisterPayload registerPayload;
  CreatePinPayload createPinPayload = new CreatePinPayload();

  var dialog;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        // hasNetwork().then((result) {
        //   setState(() {
        //     isOnline = result;
        //   });
        // });
        //
        final sharedPrefService = await SharedPreferencesService.instance;
        fcmToken = sharedPrefService.fcmToken;
        oneSignalExternalUserId = sharedPrefService.getOneSignalExternalUserId;
        locationSelected = sharedPrefService.locationSelected;

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

        try {
          widget.loginPayload.deviceId =
              identifier.removemoji.replaceAll(RegExp('[^A-Za-z0-9]'), '');
          //devicename
          if (Platform.isAndroid) {
            widget.loginPayload.deviceName = (brand +
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
            widget.loginPayload.deviceName = ("os version " +
                    osVersion +
                    " app version " +
                    version +
                    " build " +
                    code)
                .removemoji
                .replaceAll(RegExp('[^A-Za-z0-9]'), '');
          }
          widget.loginPayload.appVersions = code;
          widget.loginPayload.deviceType = osType;
          widget.loginPayload.gcmToken = fcmToken;
          widget.loginPayload.onesignalPlayerId = null;
          widget.loginPayload.notificationSetting = await isNotificationOn();
        } catch (e) {}
      },
    );

    try {
      registerPayload = SharedPreferencesService().registerPayload;
    } catch (e) {}

    super.initState();
  }

  AppLocalizations appLocalizations;

  @override
  Widget build(BuildContext context) {
    hasNetwork().then((result) {
      setState(() {
        isOnline = result;
      });
    });
    return Consumer<UserViewModel>(
      builder: (context, model, _) {
        return WillPopScope(
          // ignore: missing_return
          onWillPop: () {
            handleWillPop();
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Stack(
                fit: StackFit.passthrough,
                children: <Widget>[
                  AnimatedContainer(
                    color: _bgColors[_pageIndex],
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(0.0),
                    child: PageView(
                        scrollDirection: Axis.vertical,
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => _pageIndex = index);
                        },
                        children: [
                          FractionallySizedBox(
                            heightFactor: 1.0,
                            child: Center(child: onlySelectedBorderPinPut()),
                          ),
                        ]),
                  ),
                  if (model.loading || loading)
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
          ),
        );
      },
    );
  }

  Future<bool> handleWillPop() async {
    if (widget.reason == "login" || widget.reason == "expired") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } else if (widget.reason == "register" || widget.reason == "create_pin") {
    } else if (widget.reason == "recreate_update_pin") {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => AccountInfoPage(
              from: "pin",
            ),
          ),
          (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pop();
    }
    return true;
  }

  Widget onlySelectedBorderPinPut() {
    int dotCounter = 3;
    double selectedIndicator = 2.0;
    if (SharedPreferencesService().locationSelected == "PH" &&
        GlobalVar.showUploadIdStep) {
      dotCounter = 4;
      selectedIndicator = 2.0;
    }
    final BoxDecoration pinPutDecoration = BoxDecoration(
      color: PopboxColor.mdWhite1000,
      borderRadius: BorderRadius.circular(4.0),
    );
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                if (widget.reason == "expired") {
                                  SharedPreferencesService().isRemove(widget
                                          .loginPayload.phoneNumber ??
                                      SharedPreferencesService().user.phone);
                                  // activePhoneNo
                                }

                                handleWillPop();
                              },
                              child: widget.reason == "register" ||
                                      widget.reason == "create_pin" ||
                                      widget.reason == "forgot_pin"
                                  ? Container()
                                  : widget.reason == "expired"
                                      ? CustomWidget().textBold(
                                          AppLocalizations.of(context)
                                              .translate(
                                                  LanguageKeys.exitAccount),
                                          PopboxColor.mdGrey500,
                                          11.0.sp,
                                          TextAlign.left,
                                        )
                                      : Image.asset(
                                          "assets/images/ic_back_black.png",
                                          fit: BoxFit.fitHeight,
                                        ),
                            ),
                            widget.reason == "register" ||
                                    widget.reason == "recreate_pin" ||
                                    widget.reason == "forgot_pin"
                                ? Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0.0, 0.0, 16.0, 0.0),
                                    child: Row(children: [
                                      _buildPageIndicator(true),
                                      _buildPageIndicator(true),
                                      _buildPageIndicator(true),
                                    ]),
                                  )
                                : widget.reason == "expired" ||
                                        widget.reason == "login"
                                    ? CustomWidget().textRegular(
                                        widget.loginPayload.phoneNumber ??
                                            SharedPreferencesService()
                                                .user
                                                .phone,
                                        PopboxColor.mdGrey900,
                                        14,
                                        TextAlign.left,
                                      )
                                    : Container(),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 32.0),
                          alignment: Alignment.center,
                          child: pageTitle(context),
                        ),
                        SizedBox(
                          height: widget.reason == "expired" ? 4.0 : 20.0,
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: pageSubTitle(context),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 50),
                GestureDetector(
                  onLongPress: () {
                    print(_formKey.currentState.validate());
                  },
                  child: PinPut(
                    validator: (s) {
                      if (s.contains('1')) return null;
                      return 'NOT VALID';
                    },
                    obscureText: "●",
                    useNativeKeyboard: false,
                    // autovalidateMode: AutovalidateMode.onUserInteraction,
                    withCursor: true,
                    fieldsCount: 6,
                    keyboardType: TextInputType.number,
                    fieldsAlignment: MainAxisAlignment.spaceBetween,
                    textStyle: const TextStyle(
                      fontSize: 30.0,
                      color: Colors.redAccent,
                    ),
                    eachFieldMargin: EdgeInsets.all(0),
                    eachFieldWidth: 50.0,
                    eachFieldHeight: 50.0,
                    onSubmit: (String pin) async => submit(pin, false),
                    focusNode: _pinPutFocusNode,
                    controller: _pinPutController,
                    submittedFieldDecoration: pinPutDecoration,
                    selectedFieldDecoration: pinPutDecoration.copyWith(
                      color: Colors.black,
                      border: Border.all(
                        width: 2,
                        color: PopboxColor.mdBlack1000,
                      ),
                    ),
                    followingFieldDecoration: pinPutDecoration,
                    pinAnimationType: PinAnimationType.scale,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 4.0),
                  child: widget.reason == "register" ||
                          widget.reason == "recreate_pin" ||
                          widget.reason == "forgot_pin" ||
                          widget.reason == "update_pin" ||
                          widget.reason == "create_update_pin" ||
                          widget.reason == "recreate_update_pin"
                      ? CustomWidget().textRegular(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.inputSixDigitsPin),
                          PopboxColor.mdGrey700,
                          11.0.sp,
                          TextAlign.left,
                        )
                      : InkWell(
                          onTap: () {
                            _pinPutController.text = '';
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => OtpMethodPage(
                                  reason: "forgot_pin",
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              CustomWidget().textLight(
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.forgotPin),
                                PopboxColor.mdGrey700,
                                12,
                                TextAlign.left,
                              ),
                              SizedBox(width: 7.0),
                              CustomWidget().textLight(
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.clickHere),
                                PopboxColor.blue477FFF,
                                12,
                                TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            Flexible(
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                crossAxisSpacing: 20,
                mainAxisSpacing: 0,
                padding: const EdgeInsets.only(
                  left: 25.0,
                  right: 25.0,
                ),
                physics: NeverScrollableScrollPhysics(),
                children: [
                  ...[1, 2, 3, 4, 5, 6, 7, 8, 9].map((e) {
                    return RoundedButton(
                      title: '$e',
                      onTap: () {
                        _pinPutController.text = '${_pinPutController.text}$e';
                      },
                    );
                  }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // InkWell(
                      //   onTap: () {
                      //     if (_pinPutController.text.isNotEmpty) {
                      //       _pinPutController.text = "";
                      //     }
                      //   },
                      //   child: CustomWidget().textBold(
                      //     "Cancel",
                      //     PopboxColor.mdGrey700,
                      //     9.0.sp,
                      //     TextAlign.left,
                      //   ),
                      // ),
                    ],
                  ),
                  RoundedButton(
                    title: '0',
                    onTap: () {
                      _pinPutController.text =
                          '${_pinPutController.text}' + "0";
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          if (_pinPutController.text.isNotEmpty) {
                            _pinPutController.text = _pinPutController.text
                                .substring(
                                    0, _pinPutController.text.length - 1);
                          }
                        },
                        child: SvgPicture.asset(
                          "assets/images/ic_pin_back.svg",
                          fit: BoxFit.fitHeight,
                          height: 26,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void submit(String pin, bool isGuest) async {
    if (widget.reason == "register") {
      registerPayload.pin = pin;
      SharedPreferencesService().setRegisterPayload(registerPayload);

      //dialog = CustomWidget().showCustomDialog(context: context, msg: "aaaaaa");

      // if (dialog != null) {
      //   Navigator.of(context).pop(true);
      // } else {}
      _pinPutController.text = '';
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PinPage(
            loginPayload: widget.loginPayload,
            reason: "recreate_pin",
          ),
        ),
      );
    } else if (widget.reason == "recreate_pin") {
      //print(json.encode(registerPayload));
      if (registerPayload.pin == pin) {
        register();
      } else {
        CustomWidget().showCustomDialog(
            context: context,
            msg: AppLocalizations.of(context)
                .translate(LanguageKeys.pinsAreNotTheSameAsPrevious));
      }
    } else if (widget.reason == "create_pin" ||
        widget.reason == "verification" ||
        widget.reason == "forgot_pin") {
      CreatePinPayload createPinPayload = new CreatePinPayload()
        ..pin = pin
        ..token = GlobalVar.API_TOKEN
        ..phoneNumber = widget.loginPayload.phoneNumber;

      //print("payload " + json.encode(createPinPayload));
      //print("reason " + widget.reason);

      SharedPreferencesService().setCreatePinPayload(createPinPayload);
      _pinPutController.text = '';
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PinPage(
            loginPayload: widget.loginPayload,
            reason: "create_pin_again",
          ),
        ),
      );
    } else if (widget.reason == "create_pin_again" ||
        widget.reason == "verification_again" ||
        widget.reason == "recreate_forgot_pin") {
      //print(json.encode(registerPayload));

      if (SharedPreferencesService().createPinPayload.pin == pin) {
        createPin(pin: pin, isGuest: isGuest);
      } else {
        CustomWidget().showCustomDialog(
            context: context,
            msg: AppLocalizations.of(context)
                .translate(LanguageKeys.pinsAreNotTheSameAsPrevious));
      }
    }

    // else if (widget.reason == "forgot_pin") {
    //   Navigator.of(context).push(
    //     MaterialPageRoute(
    //       builder: (context) => PinPage(
    //         loginPayload: widget.loginPayload,
    //         reason: "recreate_forgot_pin",
    //       ),
    //     ),
    //   );
    // }

    // else if (widget.reason == "recreate_forgot_pin") {
    //   // Navigator.of(context).push(
    //   //   MaterialPageRoute(
    //   //     builder: (context) => LoginPage(),
    //   //   ),
    //   // );

    //   if (SharedPreferencesService().createPinPayload.pin == pin) {
    //     createPin(pin: pin, isGuest: isGuest);
    //   } else {
    //     CustomWidget().showCustomDialog(
    //         context: context,
    //         msg: AppLocalizations.of(context)
    //             .translate(LanguageKeys.pinsAreNotTheSameAsPrevious));
    //   }
    // }

    else if (widget.reason == "update_pin") {
      SharedPreferencesService().setOldPin(pin);
      _pinPutController.text = '';

      if (SharedPreferencesService().user.pin == pin) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PinPage(
              loginPayload: widget.loginPayload,
              reason: "create_update_pin",
            ),
          ),
        );
      } else {
        CustomWidget().showCustomDialog(
            context: context,
            msg: AppLocalizations.of(context)
                .translate(LanguageKeys.checkUpdatePin));
      }
    } else if (widget.reason == "create_update_pin") {
      SharedPreferencesService().setNewPin(pin);
      _pinPutController.text = '';

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PinPage(
            loginPayload: widget.loginPayload,
            reason: "recreate_update_pin",
          ),
        ),
      );
    } else if (widget.reason == "recreate_update_pin") {
      if (SharedPreferencesService().newPin == pin) {
        //devrafiprogress
        SharedPreferencesService().setNowPin(pin);
        updatePin(pin: pin);
      } else {
        CustomWidget().showCustomDialog(
            context: context,
            msg: AppLocalizations.of(context)
                .translate(LanguageKeys.pinsAreNotTheSameAsPrevious));
      }
    }
    //3.1.3 Remove Account
    else if (widget.reason == "remove_account") {
      if (SharedPreferencesService().user.pin == pin) {
        removeAccount(removeAccReason: widget.removeAccReason);
      } else {
        _pinPutController.text = '';
        CustomWidget().showCustomDialog(
            context: context,
            msg: AppLocalizations.of(context)
                .translate(LanguageKeys.invalidCredential));
      }
    } else if (widget.reason == "login" || widget.reason == "expired") {
      login(pin: pin, isGuest: isGuest);
    }
  }

  void removeAccount({String removeAccReason}) {
    final userModel = Provider.of<UserViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      DeleteAccountPayload payload = DeleteAccountPayload()
        ..token = GlobalVar.API_TOKEN
        ..sessionId = SharedPreferencesService().user.sessionId
        ..userId = SharedPreferencesService().user.userId.toString();
      await userModel.deleteAccount(payload, context, onSuccess: (response) {
        logout(context);
      }, onError: (response) {
        CustomWidget()
            .showCustomDialog(context: context, msg: response.response.message);
      });
    });
  }

  void login({String pin, bool isGuest = false}) {
    SharedPreferencesService().setFirstDisplay(true);
    if (widget.loginPayload.gcmToken == null ||
        widget.loginPayload.gcmToken == "") {
      try {
        var playerId = SharedPreferencesService().fcmToken;
        widget.loginPayload.gcmToken = playerId;
        widget.loginPayload.onesignalPlayerId = null;
      } catch (e) {}
    }

    widget.loginPayload.pin = pin.toString();
    widget.loginPayload.phoneNumber = widget.loginPayload.phoneNumber;
    widget.loginPayload.isGuest = isGuest;
    widget.loginPayload.onesignalExternalUserId = oneSignalExternalUserId ?? "";
    widget.loginPayload.phone = widget.loginPayload.phoneNumber;

    final userModel = Provider.of<UserViewModel>(context, listen: false);

    //print(json.encode(widget.loginPayload));
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await userModel.login(widget.loginPayload, context,
            onSuccess: (response, password, isGuest) async {
          //print("payload3 " + json.encode(response));
          //print("reason3 " + widget.reason);
          if (response.response.code == 200) {
            SharedPreferencesService()
                .setActivePhoneNo(widget.loginPayload.phoneNumber);
            if (response.data.first.onesignalExternalUserIdStatus == false) {
              setLoading(true);
              SharedPreferencesService()
                  .setExistingLoginCountry(locationSelected);
              //OneSignal SDK
              OneSignal.shared
                  .setExternalUserId(response
                      .data.first.suggestGenerateOnesignalExternalUserId
                      .toString())
                  .then((results) {
                //HIT API External OneSignal
                final oneSignalExternalViewModel =
                    Provider.of<UserViewModel>(context, listen: false);
                //One Signal Payload
                OneSignalExternalPayload oneSignalExternalPayload =
                    new OneSignalExternalPayload(
                  token: GlobalVar.API_TOKEN,
                  deviceId: identifier.removemoji
                      .replaceAll(RegExp('[^A-Za-z0-9]'), ''),
                  phone: widget.loginPayload.phoneNumber,
                  onesignalExternalUserId: response
                      .data.first.suggestGenerateOnesignalExternalUserId
                      .toString(),
                );
                oneSignalExternalViewModel.oneSignalExternal(
                    oneSignalExternalPayload, context, onSuccess: (response) {
                  setLoading(false);
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => SplashScreenWelcomeWidget(
                            nameIntro: response.data.first.name),
                      ),
                      (Route<dynamic> route) => false);
                }, onError: (response) {
                  setLoading(false);
                });
                //Hit End
              }).catchError((error) {
                setLoading(false);
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => SplashScreenWelcomeWidget(
                        nameIntro: response.data.first.name,
                      ),
                    ),
                    (Route<dynamic> route) => false);
                //hooks
                hookSlack(
                  context: context,
                  payload: widget.loginPayload,
                  endPoint: "PIN Page - SDK ONESIGNAL",
                  funcName: "PIN Page - SDK ONESIGNAL",
                  msgCatch: error.toString(),
                  isAPI: false,
                );
              });
            } else if (response.data.first.onesignalExternalUserIdStatus ==
                true) {
              setLoading(false);
              SharedPreferencesService()
                  .setExistingLoginCountry(locationSelected);

              SharedPreferencesService().setOneSignalExternalUserId(
                  response.data.first.onesignalExternalUserId);

              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => SplashScreenWelcomeWidget(
                      nameIntro: response.data.first.name,
                    ),
                  ),
                  (Route<dynamic> route) => false);
            } else {
              SharedPreferencesService()
                  .setExistingLoginCountry(locationSelected);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => SplashScreenWelcomeWidget(
                      nameIntro: response.data.first.name,
                    ),
                  ),
                  (Route<dynamic> route) => false);
            }
          } else {
            setLoading(false);
            _pinPutController.text = "";
            CustomWidget().showCustomDialog(
                context: context, msg: response.response.message);
            print("ON PIN PAGE");
          }
        }, onError: (response) {
          setLoading(false);
          _pinPutController.text = "";

          try {
            if (isOnline) {
              //Hooks Slack
              if (response.response.message == "Invalid Credential") {
                //nothing print("DO ===>>> NOTHING");
                CustomWidget().showCustomDialog(
                    context: context,
                    msg: AppLocalizations.of(context)
                        .translate(LanguageKeys.invalidCredential));
              } else if (SharedPrefKeys.msgDio.isNotEmpty) {
                hookSlack(
                  context: context,
                  payload: widget.loginPayload,
                  endPoint: GlobalVar.URL_LOGIN,
                  funcName: "PIN Page - UserLogin1 -  Server",
                  msgCatch: SharedPreferencesService().msgDio.toString(),
                  isAPI: false,
                );
                CustomWidget().showCustomDialog(
                    context: context, msg: SharedPreferencesService().msgDio);
              } else {
                CustomWidget().showCustomDialog(
                    context: context, msg: response.response.message);
                hookSlack(
                  context: context,
                  response: response,
                  payload: widget.loginPayload,
                  endPoint: GlobalVar.URL_LOGIN,
                  funcName: "PIN Page - UserLogin1",
                  isAPI: true,
                );
              }
            } else {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ErrorNetworkPage()));
            }

            setState(() {});
          } catch (e) {
            if (SharedPrefKeys.msgDio.isNotEmpty) {
              hookSlack(
                context: context,
                payload: widget.loginPayload,
                endPoint: GlobalVar.URL_LOGIN,
                funcName: "PIN Page - UserLogin2",
                msgCatch: SharedPreferencesService().msgDio,
                isAPI: false,
              );
              CustomWidget().showCustomDialog(
                  context: context, msg: SharedPreferencesService().msgDio);
            } else {
              hookSlack(
                context: context,
                payload: widget.loginPayload,
                endPoint: GlobalVar.URL_LOGIN,
                funcName: "PIN Page - UserLogin3",
                msgCatch: e.toString(),
                isAPI: false,
              );
              CustomWidget()
                  .showCustomDialog(context: context, msg: e.toString());
            }
          }
        });
      },
    );
  }

  void logout(BuildContext context) async {
    final userModel = Provider.of<UserViewModel>(context, listen: false);

    List<String> deviceInfo = await getDeviceDetails();
    String model = deviceInfo[0];
    String deviceVersion = deviceInfo[1];
    String identifier = deviceInfo[2];
    String brand = deviceInfo[3];
    String osVersion = deviceInfo[4];
    String osType = deviceInfo[5];

    LogoutPayload logoutPayload = new LogoutPayload()
      ..deviceId = identifier.removemoji.replaceAll(RegExp('[^A-Za-z0-9]'), '')
      ..deviceType = osType
      ..sessionId = SharedPreferencesService().user.sessionId
      ..token = GlobalVar.API_TOKEN
      ..phoneNumber = SharedPreferencesService().user.phone;

    userModel.logout(logoutPayload, context, onSuccess: (response) async {
      if (response.response.code == 200) {
        SharedPreferencesService()
            .removeValues(keyword: "existingLoginCountry");
        bool isRemove =
            SharedPreferencesService().isRemove(logoutPayload.phoneNumber);
        try {
          if (SharedPreferencesService().userList != null &&
              SharedPreferencesService().userList.length > 0) {
            int setPhoneNoCounter = 0;
            for (var i = 0;
                i < SharedPreferencesService().userList.length;
                i++) {
              if (SharedPreferencesService().userList[i].data.first.phone !=
                      logoutPayload.phoneNumber &&
                  setPhoneNoCounter < 1) {
                setPhoneNoCounter++;
                SharedPreferencesService().setActivePhoneNo(
                    SharedPreferencesService().userList[i].data.first.phone);
              }
            }
          }
        } catch (e) {}
        resetData();
      } else {}
    }, onError: (response) {
      try {
        if (response.response.message == "Token/User Not Found") {
          bool isRemove =
              SharedPreferencesService().isRemove(logoutPayload.phoneNumber);
          try {
            if (SharedPreferencesService().userList != null &&
                SharedPreferencesService().userList.length > 0) {
              int setPhoneNoCounter = 0;
              for (var i = 0;
                  i < SharedPreferencesService().userList.length;
                  i++) {
                if (SharedPreferencesService().userList[i].data.first.phone !=
                        logoutPayload.phoneNumber &&
                    setPhoneNoCounter < 1) {
                  setPhoneNoCounter++;
                  SharedPreferencesService().setActivePhoneNo(
                      SharedPreferencesService().userList[i].data.first.phone);
                }
              }
            }
          } catch (e) {}
          resetData();
        }
      } catch (e) {}
    });
  }

  void resetData() {
    SharedPreferencesService().removeValues(keyword: "otpCounter");
    SharedPreferencesService().removeValues(keyword: "otpRequestPayload");
    SharedPreferencesService().removeValues(keyword: "registerPayload");
    SharedPreferencesService().removeValues(keyword: "otpValidationPayload");
    SharedPreferencesService().removeValues(keyword: "isLoadTransaction");
    SharedPreferencesService().removeValues(keyword: "existingLoginCountry");

    context.read<BottomNavigationBloc>().add(
          PageTapped(index: 0),
        );
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => SplashScreenPage(),
        ),
        (Route<dynamic> route) => false);
  }

  void hookSlack({
    BuildContext context,
    dynamic response,
    String msgCatch,
    String endPoint,
    String funcName,
    dynamic payload,
    bool isAPI = false,
  }) {
    final userModel = Provider.of<UserViewModel>(context, listen: false);
    //Hooks Slack
    HooksSlackPayload payloadSlack = new HooksSlackPayload(
      token: GlobalVar.API_TOKEN,
      platform: "Android",
      apiInfo: ApiInfo(
        endpoint: endPoint,
        errorMessage: (isAPI) ? response.response.message.toString() : ".nul",
        payload: payload,
      ),
      appError: AppError(
        funcName: funcName,
        line: "",
        message: msgCatch.toString(),
      ),
      deviceInfo: DeviceInfo(
        deviceId: payload.deviceId,
        deviceName: payload.deviceName,
        deviceType: payload.deviceType,
        osName: "",
        osVersion: osVersion,
      ),
      userPhone: payload.phone,
    );

    userModel.logSlack(payloadSlack, context,
        onSuccess: (response) {}, onError: (response) {});
  }

  //Check Connection
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

  void setLoading(bool value) {
    loading = value;
    setState(() {});
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

  void register() {
    final userModel = Provider.of<UserViewModel>(context, listen: false);
    registerPayload.country =
        SharedPreferencesService().locationSelected.toLowerCase();
    //print("response : " + json.encode(registerPayload));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      userModel.register(
        registerPayload,
        context,
        onSuccess: (response) {
          if (response.response.code == 200) {
            SharedPreferencesService()
                .removeValues(keyword: "otpRequestPayload");
            SharedPreferencesService()
                .removeValues(keyword: "otpValidationPayload");
            SharedPreferencesService()
                .removeValues(keyword: "isVerifiedRegister");

            if (SharedPreferencesService().locationSelected == "PH") {
              UserCheckPayload userCheckPayload = new UserCheckPayload(
                  token: GlobalVar.API_TOKEN,
                  phone: registerPayload.phone,
                  deviceId: registerPayload.device.deviceId,
                  notificationSetting: "off",
                  onesignalPlayerId: fcmToken);

              userModel.userCheck(
                userCheckPayload,
                context,
                onSuccess: (response) {
                  SharedPreferencesService()
                      .removeValues(keyword: "registerPayload");
                  _pinPutController.text = '';
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => RegisterIdPage(
                              from: "register",
                            )),
                  );
                },
                onError: (response) {
                  navigateToSuccess();
                },
              );
            } else {
              navigateToSuccess();
            }
          } else {
            CustomWidget().showCustomDialog(
                context: context, msg: response.response.message);
          }
        },
        onError: (response) {
          try {
            hookSlack(
              context: context,
              response: response,
              payload: registerPayload,
              endPoint: GlobalVar.URL_REGISTER,
              funcName: "PIN Page - UserRegister1",
              isAPI: true,
            );
            if (isOnline) {
              if (response.response.message == "validation.unique_email") {
                showAlertInfo(context: context, email: registerPayload.email);
              } else {
                CustomWidget().showCustomDialog(
                    context: context, msg: response.response.message);
              }
            } else {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ErrorNetworkPage()));
            }
            setState(() {});
          } catch (e) {
            hookSlack(
              context: context,
              payload: registerPayload,
              endPoint: GlobalVar.URL_REGISTER,
              funcName: "PIN Page - UserRegister2",
              msgCatch: e.toString(),
              isAPI: false,
            );
            CustomWidget()
                .showCustomDialog(context: context, msg: e.toString());
          }
        },
      );
    });
  }

  void navigateToSuccess() {
    SharedPreferencesService().removeValues(keyword: "registerPayload");
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SuccessPage(
          'pin',
          AppLocalizations.of(context)
              .translate(LanguageKeys.registeredIsSuccessfully),
        ),
      ),
    );
  }

  void createPin({String pin, bool isGuest}) {
    final userModel = Provider.of<UserViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      userModel.createPin(
        SharedPreferencesService().createPinPayload,
        context,
        onSuccess: (response) {
          //print("response : " + json.encode(response));
          if (response.response.code == 200) {
            SharedPreferencesService()
                .removeValues(keyword: "createPinPayload");
            SharedPreferencesService().removeValues(keyword: "registerPayload");
            SharedPreferencesService()
                .removeValues(keyword: "otpRequestPayload");
            SharedPreferencesService()
                .removeValues(keyword: "otpValidationPayload");
            SharedPreferencesService()
                .removeValues(keyword: "isVerifiedRegister");

            login(pin: pin, isGuest: isGuest);
          } else {
            _pinPutController.text = "";
            CustomWidget().showCustomDialog(
                context: context, msg: response.response.message);
          }
        },
        onError: (response) {
          _pinPutController.text = "";
          try {
            if (isOnline) {
              if (response.response.message == "validation.unique_email") {
                CustomWidget().showCustomDialog(
                    context: context,
                    msg: AppLocalizations.of(context)
                        .translate(LanguageKeys.caseAlreadyRegisterd)
                        .replaceAll("%1s", "Email"));
              } else {
                CustomWidget().showCustomDialog(
                    context: context, msg: response.response.message);
              }
            } else {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ErrorNetworkPage()));
            }
            setState(() {});
          } catch (e) {
            CustomWidget()
                .showCustomDialog(context: context, msg: e.toString());
          }
        },
      );
    });
  }

  void updatePin({String pin}) {
    final userModel = Provider.of<UserViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      EditPinPayload editPinPayload = new EditPinPayload()
        ..token = GlobalVar.API_TOKEN
        ..sessionId = SharedPreferencesService().user.sessionId
        ..phoneNumber = SharedPreferencesService().user.phone
        ..oldPin = SharedPreferencesService().oldPin
        ..newPin = SharedPreferencesService().newPin;

      //print("editPinPayload : " + json.encode(editPinPayload));

      userModel.editPin(
        editPinPayload,
        context,
        onSuccess: (response) {
          if (response.response.code == 200) {
            //setPIN NEW
            //*1* devrafi
            ChangeProfilePayload profilePayload = new ChangeProfilePayload()
              ..token = GlobalVar.API_TOKEN
              ..memberId = SharedPreferencesService().user.memberId
              ..sessionId = SharedPreferencesService().user.sessionId;
            profilePayload.email = SharedPreferencesService().user.email;
            profilePayload.dob = SharedPreferencesService().user.dob;
            profilePayload.name = SharedPreferencesService().user.name;
            profilePayload.gender = SharedPreferencesService().user.gender;
            final userModel =
                Provider.of<UserViewModel>(context, listen: false);
            userModel.changeProfile(
              profilePayload,
              context,
              onSuccess: (response) {},
              onError: (response) {},
            );
            // response.data[0].pin = pin;
            // CustomWidget().showCustomDialog(
            //     context: context,
            //     msg: AppLocalizations.of(context)
            //         .translate(LanguageKeys.changePinIsSuccess));

            CustomWidget().showToastShortV1(
                context: context,
                msg: AppLocalizations.of(context)
                    .translate(LanguageKeys.changePinIsSuccess));
            handleWillPop();
          } else {
            CustomWidget().showCustomDialog(
                context: context, msg: response.response.message);
          }
        },
        onError: (response) {
          _pinPutController.text = "";
          try {
            (isOnline)
                ? CustomWidget().showCustomDialog(
                    context: context, msg: response.response.message)
                : Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ErrorNetworkPage()));
            setState(() {});
          } catch (e) {
            CustomWidget()
                .showCustomDialog(context: context, msg: e.toString());
          }
        },
      );
    });
  }

  Widget pageSubTitle(BuildContext context) {
    String title = "";

    if (widget.reason == "register" ||
        widget.reason == "recreate_pin" ||
        widget.reason == "forgot_pin") {
      title = AppLocalizations.of(context)
          .translate(LanguageKeys.popboxPinUsedForLogin);
    } else if (widget.reason == "recreate_update_pin") {
      title = AppLocalizations.of(context)
          .translate(LanguageKeys.reInputNewPopboxPin);
    } else if (widget.reason == "login" || widget.reason == "update_pin") {
      title =
          AppLocalizations.of(context).translate(LanguageKeys.inputPopboxPin);
    } else if (widget.reason == "create_update_pin") {
      title = AppLocalizations.of(context)
          .translate(LanguageKeys.inputNewPopboxPin);
    } else if (widget.reason == "expired") {
      title = AppLocalizations.of(context)
          .translate(LanguageKeys.inputSixDigitsYourPopboxPin);
    } else if (widget.reason == "create_pin") {
      title =
          AppLocalizations.of(context).translate(LanguageKeys.pinpageCreatePin);
    } else if (widget.reason == "create_pin_again") {
      title = AppLocalizations.of(context)
          .translate(LanguageKeys.pinpageReCreatePin);
    } else {
      title = AppLocalizations.of(context)
          .translate(LanguageKeys.popboxPinUsedForLogin);
    }

    return CustomWidget()
        .textRegular(title, PopboxColor.mdGrey700, 14, TextAlign.left);
  }

  Widget pageTitle(BuildContext context) {
    String title = "";

    if (widget.reason == "register") {
      title =
          AppLocalizations.of(context).translate(LanguageKeys.createPopboxPin);
    } else if (widget.reason == "forgot_pin") {
      title = AppLocalizations.of(context).translate(LanguageKeys.popboxPin);
    } else if (widget.reason == "create_update_pin") {
      title =
          AppLocalizations.of(context).translate(LanguageKeys.changePopboxPin);
    } else if (widget.reason == "recreate_update_pin") {
      title = AppLocalizations.of(context)
          .translate(LanguageKeys.confirmationNewPopboxPin);
    } else if (widget.reason == "recreate_pin" ||
        widget.reason == 'recreate_forgot_pin' ||
        widget.reason == "create_pin_again" ||
        widget.reason == "verification_again") {
      title = AppLocalizations.of(context)
          .translate(LanguageKeys.recreatePopboxPin);
    } else if (widget.reason == "create_pin") {
      title =
          AppLocalizations.of(context).translate(LanguageKeys.createPopboxPin);
    } else {
      title = AppLocalizations.of(context).translate(LanguageKeys.popboxPin);
    }

    return CustomWidget().textRegular(
      title,
      PopboxColor.mdGrey900,
      14.0.sp,
      TextAlign.left,
    );
  }
}

void showAlertInfo({context, String email}) {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //TITLE
                Image.asset("assets/images/ic_hand_popsafe.png"),
                CustomWidget().textBoldPlus(
                    AppLocalizations.of(context)
                        .translate(LanguageKeys.emailAlreadyRegister),
                    PopboxColor.mdBlack1000,
                    16,
                    TextAlign.center),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.only(left: 15, right: 15),
                  child: CustomWidget().textRegular(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.emailAlreadyRegisterNote)
                          .replaceAll("%1s", email),
                      PopboxColor.mdBlack1000,
                      14,
                      TextAlign.center),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => RegisterPage(
                          from: "onboarding",
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 23, right: 23, top: 35),
                    child: CustomButtonRectangle(
                      bgColor: PopboxColor.red,
                      fontSize: 14,
                      textColor: Colors.white,
                      title: AppLocalizations.of(context)
                          .translate(LanguageKeys.understand),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).whenComplete(() => null);
}

class RoundedButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  RoundedButton({this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.only(left: 4.0, right: 4.0, bottom: 16.0),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: PopboxColor.mdWhite1000,
            ),
            alignment: Alignment.center,
            child: CustomWidget().textBoldPlus(
                '$title', PopboxColor.mdGrey700, 20.0.sp, TextAlign.center),
          ),
        ),
      ),
    );
  }
}
