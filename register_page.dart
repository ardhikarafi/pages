import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/payload/otp_request_payload.dart';
import 'package:new_popbox/core/models/payload/register_check_unique_payload.dart';
import 'package:new_popbox/core/models/payload/register_device_payload.dart';
import 'package:new_popbox/core/models/payload/register_payload.dart';
import 'package:new_popbox/core/models/payload/user_check_payload.dart';
import 'package:new_popbox/core/utils/global_function.dart';
import 'package:new_popbox/core/utils/library.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/pages/error_network_page.dart';
import 'package:new_popbox/ui/pages/login_page.dart';
import 'package:new_popbox/ui/pages/onboarding_page.dart';
import 'package:new_popbox/ui/pages/otp_method_page.dart';
import 'package:new_popbox/ui/pages/webview_page.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:new_popbox/ui/widget/help_view.dart';
import 'package:new_popbox/ui/widget/phone_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:remove_emoji/remove_emoji.dart';

class RegisterPage extends StatefulWidget {
  final String from;
  const RegisterPage({Key key, this.from}) : super(key: key);
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String fcmToken = "";
  String model = "";
  String deviceVersion = "";
  String identifier = "";
  String brand = "";
  String osVersion = "";
  String osType = "";
  SharedPreferencesService sharedPrefService;

  bool isOnline = false;

  RegisterPayload registerPayload = new RegisterPayload();

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

      RegisterDevicePayload registerDevicePayload = new RegisterDevicePayload();

      registerDevicePayload.deviceId =
          identifier.removemoji.replaceAll(RegExp('[^A-Za-z0-9]'), '');
      //devicename
      if (Platform.isAndroid) {
        registerDevicePayload.deviceName = (brand +
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
        registerDevicePayload.deviceName = ("os version " +
                osVersion +
                " app version " +
                version +
                " build " +
                code)
            .removemoji
            .replaceAll(RegExp('[^A-Za-z0-9]'), '');
      }

      registerDevicePayload.gcmToken = fcmToken;

      if (Platform.isAndroid) {
        registerDevicePayload.type = "android";
      } else if (Platform.isIOS) {
        registerDevicePayload.type = "ios";
      }

      registerPayload.device = registerDevicePayload;
      registerPayload.token = GlobalVar.API_TOKEN;
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
    UserViewModel authViewModel =
        Provider.of<UserViewModel>(context, listen: false);

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
                    //mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            if (widget.from == "onboarding") {
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OnboardingPage(),
                                                ),
                                              );
                                            }
                                            {
                                              Navigator.of(context)
                                                  .pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            LoginPage(),
                                                      ),
                                                      (Route<dynamic> route) =>
                                                          false);
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                16.0, 40.0, 0.0, 16.0),
                                            child: Image.asset(
                                              "assets/images/ic_back_black.png",
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                //Hide
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) => LoginPage(),
                                        ),
                                        (Route<dynamic> route) => false);
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.fromLTRB(
                                        8.0, 24.0, 16.0, 0.0),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                      text: new TextSpan(
                                        style: new TextStyle(
                                          fontSize: 12.0.sp,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          new TextSpan(
                                              text: AppLocalizations.of(context)
                                                  .translate(
                                                      LanguageKeys.haveAccount),
                                              style: TextStyle(
                                                color: PopboxColor.mdGrey700,
                                                fontSize: 10.0.sp,
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.w400,
                                              )),
                                          new TextSpan(
                                            text: " " +
                                                AppLocalizations.of(context)
                                                    .translate(
                                                        LanguageKeys.loginHere),
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
                            Column(children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16.0, 28.0, 0.0, 30.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    CustomWidget().textRegular(
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.register),
                                      PopboxColor.mdGrey900,
                                      14.0.sp,
                                      TextAlign.left,
                                    ),
                                    SizedBox(width: 10.0),
                                    SvgPicture.asset(
                                      "assets/images/ic_popbox_logo.svg",
                                      width: 60.0,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 4.0, 16.0, 0.0),
                              child: PhoneWidget(
                                controller: usernameController,
                                sharedPrefService: sharedPrefService,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 35.0),
                      Container(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                        child: CustomWidget().textFormFieldRegular(
                            controller: emailController, labelText: 'Email'),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 0.0),
                        child: CustomButtonRectangle(
                          onPressed: () {
                            //PH min 10
                            //MY min 9
                            //ID min 11
                            //62859599803 > 11 digits
                            //Email validation
                            String inputEmail =
                                emailController.text.replaceAll(' ', '');
                            bool emailValid = RegExp(
                                    r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$')
                                .hasMatch(inputEmail);

                            int minPhoneLength = 0;
                            int maxPhoneLength = 12;
                            if (sharedPrefService.locationSelected == "ID") {
                              minPhoneLength = 9;
                            } else if (sharedPrefService.locationSelected ==
                                "MY") {
                              minPhoneLength = 7;
                            } else if (sharedPrefService.locationSelected ==
                                "PH") {
                              minPhoneLength = 8;
                            }

                            if (usernameController.text.trim() == "") {
                              CustomWidget().showCustomDialog(
                                context: context,
                                msg: AppLocalizations.of(context).translate(
                                  LanguageKeys.phoneIsRequired,
                                ),
                              );
                            } else if (usernameController.text.trim().length <
                                minPhoneLength) {
                              CustomWidget().showCustomDialog(
                                context: context,
                                msg: AppLocalizations.of(context)
                                    .translate(
                                        LanguageKeys.phoneNoAtLeastNineDigits)
                                    .replaceAll(
                                      "%1s",
                                      (minPhoneLength + 2).toString(),
                                    ),
                              );
                            } else if (usernameController.text.trim().length >
                                maxPhoneLength) {
                              CustomWidget().showCustomDialog(
                                context: context,
                                msg: AppLocalizations.of(context)
                                    .translate(
                                        LanguageKeys.phoneNoMaxFourteenDigits)
                                    .replaceAll(
                                      "%1s",
                                      (maxPhoneLength + 2).toString(),
                                    ),
                              );
                            } else if (emailController.text.trim() == "") {
                              CustomWidget().showCustomDialog(
                                context: context,
                                msg: AppLocalizations.of(context).translate(
                                  LanguageKeys.emailIsRequired,
                                ),
                              );
                            } else if (!emailValid) {
                              CustomWidget().showCustomDialog(
                                context: context,
                                msg: AppLocalizations.of(context).translate(
                                  LanguageKeys.emailFormatIsRequired,
                                ),
                              );
                            } else {
                              String phoneNo = usernameController.text;
                              // .replaceFirst(RegExp("0"), "", 0)
                              // .replaceFirst(RegExp("62"), "", 0)
                              // .replaceFirst(RegExp("60"), "")
                              // .replaceFirst(RegExp("63"), "");

                              if (phoneNo.startsWith("0")) {
                                phoneNo = phoneNo
                                    .replaceFirst(RegExp("0"), "")
                                    .replaceAll(" ", "");
                              }

                              if (phoneNo.startsWith("62")) {
                                phoneNo = phoneNo
                                    .replaceFirst(RegExp("62"), "")
                                    .replaceAll(" ", "");
                              }

                              if (phoneNo.startsWith("60")) {
                                phoneNo = phoneNo
                                    .replaceFirst(RegExp("60"), "")
                                    .replaceAll(" ", "");
                              }

                              if (phoneNo.startsWith("63")) {
                                phoneNo = phoneNo
                                    .replaceFirst(RegExp("63"), "")
                                    .replaceAll(" ", "");
                              }

                              registerPayload.phone =
                                  SharedPreferencesService().phoneCode +
                                      phoneNo;
                              // usernameController.text
                              //     .replaceFirst(RegExp("0"), "")
                              //     .replaceFirst(RegExp("62"), "")
                              //     .replaceFirst(RegExp("60"), "")
                              //     .replaceFirst(RegExp("63"), "");

                              registerPayload.email = emailController.text;
                              registerPayload.country =
                                  SharedPreferencesService().countryCode;

                              SharedPreferencesService()
                                  .setRegisterPayload(registerPayload);

                              OtpRequestPayload otpRequestPayload =
                                  new OtpRequestPayload(
                                      phone:
                                          SharedPreferencesService().phoneCode +
                                              phoneNo);

                              //DEBUG
                              // registerPayload.phone
                              //     .replaceFirst(RegExp("0"), "")
                              //     .replaceFirst(RegExp("62"), "")
                              //     .replaceFirst(RegExp("60"), "")
                              //     .replaceFirst(RegExp("63"), ""));

                              SharedPreferencesService()
                                  .setOtpRequestPayload(otpRequestPayload);

                              // userCheck(context);
                              registerUserUnique(context);
                            }
                          },
                          title: AppLocalizations.of(context)
                              .translate(LanguageKeys.register),
                          bgColor: PopboxColor.popboxRed,
                          textColor: PopboxColor.mdWhite1000,
                          fontSize: 12.0.sp,
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => WebviewPage(
                                reason: "tnc",
                                appbarTitle: AppLocalizations.of(context)
                                    .translate(LanguageKeys.termCondition),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.fade,
                            text: TextSpan(children: [
                              TextSpan(
                                  text: AppLocalizations.of(context).translate(
                                      LanguageKeys.youAgreeWithAgreement),
                                  style: TextStyle(
                                    color: PopboxColor.mdGrey700,
                                    fontSize: 9.0.sp,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w400,
                                  )),
                              WidgetSpan(
                                  child: Container(
                                child: SizedBox(width: 5.0),
                              )),
                              TextSpan(
                                  text: AppLocalizations.of(context)
                                      .translate(LanguageKeys.termOfServices),
                                  style: TextStyle(
                                    color: PopboxColor.blue477FFF,
                                    fontSize: 9.0.sp,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w400,
                                  )),
                            ]),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          callCsBottomSheet(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin:
                              const EdgeInsets.fromLTRB(16.0, 7.0, 16.0, 32.0),
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
                                      fontSize: 9.0.sp,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.w400,
                                    )),
                                new TextSpan(
                                  text: " " +
                                      AppLocalizations.of(context).translate(
                                          LanguageKeys
                                              .callPopboxCustomerService),
                                  style: TextStyle(
                                    color: PopboxColor.blue477FFF,
                                    fontSize: 9.0.sp,
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

  void registerUserUnique(BuildContext context) async {
    final userUnique = Provider.of<UserViewModel>(context, listen: false);
    RegisterCheckUniquePayload payload = new RegisterCheckUniquePayload(
      token: GlobalVar.API_TOKEN,
      phone: usernameController.text,
      email: emailController.text,
    );

    await userUnique.registerUserUnique(payload, context,
        onSuccess: (response) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OtpMethodPage(
            reason: "register",
          ),
        ),
      );
    }, onError: (response) {
      CustomWidget().showCustomDialog(
        context: context,
        msg: AppLocalizations.of(context).translate(
            response.response.message.replaceAll(" ", "").toLowerCase()),
      );
    });
  }

  void userCheck(BuildContext context) async {
    final userModel = Provider.of<UserViewModel>(context, listen: false);

    UserCheckPayload userCheckPayload = new UserCheckPayload(
      token: GlobalVar.API_TOKEN,
      deviceId: registerPayload.device.deviceId,
      phone: registerPayload.phone,
      notificationSetting: await isNotificationOn(),
      onesignalPlayerId: fcmToken,
    );

    userModel.userCheck(userCheckPayload, context,
        isRegister: true, isSaveCallbak: false, onSuccess: (response) async {
      print("Response Regis Page => " + response.response.code.toString());
      if (response.response.code == 400) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtpMethodPage(
              reason: "register",
            ),
          ),
        );
      } else {
        print("11");
        CustomWidget()
            .showCustomDialog(context: context, msg: response.response.message);
      }
    }, onError: (response) {
      //NEW
      try {
        (!isOnline)
            ? Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ErrorNetworkPage()))
            : (response.response.message != "Member Not Found")
                ? CustomWidget().showCustomDialog(
                    context: context, msg: response.response.message)
                : {};
        setState(() {});
      } catch (e) {
        CustomWidget().showCustomDialog(context: context, msg: e.toString());
      }
    });
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

  Future<bool> onWillPop(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => OnboardingPage(),
      ),
    );
    return Future.value(true);
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
}
