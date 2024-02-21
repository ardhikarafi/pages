import 'package:flutter/material.dart';
import 'package:new_popbox/core/app_config.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/payload/hooks_slack_payload.dart';
import 'package:new_popbox/core/models/payload/login_payload.dart';
import 'package:new_popbox/core/models/payload/one_signal_external_payload.dart';
import 'package:new_popbox/core/models/payload/otp_request_payload.dart';
import 'package:new_popbox/core/models/payload/user_check_payload.dart';
import 'package:new_popbox/core/service/app_language.dart';
import 'package:new_popbox/core/utils/global_function.dart';
import 'package:new_popbox/core/utils/library.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/pages/error_network_page.dart';
import 'package:new_popbox/ui/pages/home.dart';
import 'package:new_popbox/ui/pages/onboarding_page.dart';
import 'package:new_popbox/ui/pages/password_page.dart';
import 'package:new_popbox/ui/pages/pin_page.dart';
import 'package:new_popbox/ui/pages/register_page.dart';
import 'package:new_popbox/ui/pages/welcome_onboarding_page.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:new_popbox/ui/widget/help_view.dart';
import 'package:new_popbox/ui/widget/phone_widget.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:remove_emoji/remove_emoji.dart';

class LoginPage extends StatefulWidget {
  final String from;

  const LoginPage({Key key, this.from}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  //TextEditingController passwordController = TextEditingController();
  LoginPayload loginPayload = new LoginPayload();

  String fcmToken = "";
  String model = "";
  String deviceVersion = "";
  String identifier = "";
  String brand = "";
  String osVersion = "";
  String osType = "";
  bool isOnline = false;
  String appVersionUser = "";
  String oneSignalExternalUserId = "";
  String userId = "";
  bool loading = false;

  SharedPreferencesService sharedPrefService;

  @override
  void initState() {
    // setOnesignal(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      sharedPrefService = await SharedPreferencesService.instance;
      fcmToken = sharedPrefService.fcmToken;
      oneSignalExternalUserId = sharedPrefService.getOneSignalExternalUserId;

      if (fcmToken == null || fcmToken == "") {
        setOnesignal(this.context);
      }

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
      loginPayload.onesignalPlayerId = null;
      loginPayload.notificationSetting = await isNotificationOn();
      loginPayload.token = GlobalVar.API_TOKEN;
      appVersionUser = version;
      SharedPreferencesService().setAppversion(appVersionUser);

      try {
        if (SharedPreferencesService().userList.length < 1) {
          SharedPreferencesService()
              .removeValues(keyword: SharedPrefKeys.userData);
        }

        if (SharedPreferencesService().userList.length == 1) {
          LoginResponse loginResponse =
              SharedPreferencesService().userList.first;

          if (loginResponse.data.length == 0) {
            SharedPreferencesService()
                .removeValues(keyword: SharedPrefKeys.userData);
          }
        }
      } catch (e) {}
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: PopboxColor.mdWhite1000,
        statusBarIconBrightness: Brightness.dark));
    hasNetwork().then((result) {
      setState(() {
        isOnline = result;
      });
    });
    return Consumer2<UserViewModel, AppLanguage>(
      builder: (context, model, model2, _) {
        return Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: true,
              body: WillPopScope(
                onWillPop: () {
                  onWillPop(context);
                },
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              if (widget.from == "guest" ||
                                                  widget.from ==
                                                      "add_account") {
                                                Navigator.pop(context, false);
                                              } else {
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        OnboardingPage(),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              height: 50.0,
                                              width: 50.0,
                                              margin: const EdgeInsets.fromLTRB(
                                                  0.0, 40.0, 0.0, 16.0),
                                              child: Image.asset(
                                                "assets/images/ic_back_black.png",
                                                fit: BoxFit.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RegisterPage(),
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
                                          children: <TextSpan>[
                                            new TextSpan(
                                                text:
                                                    AppLocalizations.of(context)
                                                        .translate(LanguageKeys
                                                            .dontHaveAccount),
                                                style: TextStyle(
                                                  color: PopboxColor.mdGrey700,
                                                  fontSize: 10.0.sp,
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.w400,
                                                )),
                                            new TextSpan(
                                              text: " " +
                                                  AppLocalizations.of(context)
                                                      .translate(LanguageKeys
                                                          .registerHere),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16.0, 20.0, 0.0, 0.0),
                                      child: CustomWidget().textBold(
                                        AppLocalizations.of(context)
                                            .translate(LanguageKeys.login),
                                        PopboxColor.mdGrey900,
                                        14.0.sp,
                                        TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.0),
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
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 0.0),
                          child: CustomButtonRectangle(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              //PHONE VALIDATION
                              bool phoneValid = RegExp(r'^[0-9]*$')
                                  .hasMatch(usernameController.text);

                              if (usernameController.text.isEmpty) {
                                CustomWidget().showCustomDialog(
                                  context: context,
                                  msg: AppLocalizations.of(context)
                                      .translate(
                                        LanguageKeys.caseIsRequired,
                                      )
                                      .replaceAll("%1s", "Phone"),
                                );
                              } else if (!phoneValid) {
                                CustomWidget().showCustomDialog(
                                  context: context,
                                  msg: AppLocalizations.of(context)
                                      .translate(
                                        LanguageKeys.caseFormatRequired,
                                      )
                                      .replaceAll("%1s", "Phone"),
                                );
                              } else {
                                String phoneNo = usernameController.text;

                                if (phoneNo.startsWith("0")) {
                                  phoneNo =
                                      phoneNo.replaceFirst(RegExp("0"), "");
                                }

                                if (phoneNo.startsWith("62")) {
                                  phoneNo =
                                      phoneNo.replaceFirst(RegExp("62"), "");
                                }

                                if (phoneNo.startsWith("60")) {
                                  phoneNo =
                                      phoneNo.replaceFirst(RegExp("60"), "");
                                }

                                if (phoneNo.startsWith("63")) {
                                  phoneNo =
                                      phoneNo.replaceFirst(RegExp("63"), "");
                                }

                                loginPayload.phoneNumber =
                                    SharedPreferencesService().phoneCode +
                                        phoneNo;

                                loginPayload.phoneCode =
                                    sharedPrefService.phoneCode;

                                loginPayload.countryCode =
                                    sharedPrefService.countryCode;
                                reqLocationPermission();

                                userCheck(context);
                              }
                            },
                            title: AppLocalizations.of(context)
                                .translate(LanguageKeys.login),
                            bgColor: PopboxColor.popboxRed,
                            textColor: PopboxColor.mdWhite1000,
                            fontSize: 12.0.sp,
                          ),
                        ),
                        widget.from == "add_account"
                            ? Container()
                            : InkWell(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  login(context, isGuest: true, pin: "");
                                },
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16.0, 12.0, 16.0, 0.0),
                                  child: CustomWidget().textRegular(
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.loginAsGuest),
                                      PopboxColor.blue477FFF,
                                      11.0.sp,
                                      TextAlign.left),
                                ),
                              ),
                        GestureDetector(
                          onTap: () {
                            callCsBottomSheet(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.fromLTRB(
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
                                        fontWeight: FontWeight.w400,
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
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                child: CustomWidget().textRegular(
                                    "v " + appVersionUser,
                                    PopboxColor.mdBlack1000,
                                    9.0.sp,
                                    TextAlign.center),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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

  void userCheck(BuildContext context) async {
    final userModel = Provider.of<UserViewModel>(context, listen: false);

    UserCheckPayload userCheckPayload = new UserCheckPayload(
      token: GlobalVar.API_TOKEN,
      phone: loginPayload.phoneNumber,
      deviceId: loginPayload.deviceId,
      notificationSetting: loginPayload.notificationSetting,
      onesignalPlayerId: null,
      onesignalExternalUserId: oneSignalExternalUserId ?? "",
    );

    bool isSaveCallback = true;
    if (widget.from == "add_account") {
      isSaveCallback = false;
    }

    userModel.userCheck(userCheckPayload, context,
        isSaveCallbak: isSaveCallback, onSuccess: (response) async {
      if (response.response.code == 200) {
        if (response.data.first.statusRegister == "VERIFIED" &&
                response.data.first.pinSetup == true ||
            (SharedPreferencesService().locationSelected == "PH" &&
                response.data.first.statusRegister == "UNVERIFIED" &&
                response.data.first.pinSetup == true)) {
          //verified and setup
          String email = "";
          try {
            email = response.data.first.email;
            SharedPreferencesService()
                .setLocationSelected(response.data.first.country);
          } catch (e) {}
          //ONE SIGNAL HANDLE START
          if (response.data.first.onesignalExternalUserIdStatus == false) {
            //OneSignal SDK
            setLoading(true);
            OneSignal.shared
                .setExternalUserId(response
                    .data.first.suggestGenerateOnesignalExternalUserId
                    .toString())
                .then((results) {
              //HIT API External OneSignal
              final oneSignalExternalModel =
                  Provider.of<UserViewModel>(context, listen: false);

              OneSignalExternalPayload oneSignalExternalPayload =
                  new OneSignalExternalPayload(
                token: GlobalVar.API_TOKEN,
                deviceId: loginPayload.deviceId,
                phone: loginPayload.phoneNumber,
                onesignalExternalUserId: response
                    .data.first.suggestGenerateOnesignalExternalUserId
                    .toString(),
              );

              oneSignalExternalModel.oneSignalExternal(
                  oneSignalExternalPayload, context, onSuccess: (response) {
                setLoading(false);
                SharedPreferencesService().setOneSignalExternalUserId(
                    response.data.first.onesignalExternalUserId);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PinPage(
                      loginPayload: loginPayload,
                      reason: "login",
                    ),
                  ),
                );
              }, onError: (response) {
                setLoading(false);
                if (response.response.code == 403) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PinPage(
                        loginPayload: loginPayload,
                        reason: "login",
                      ),
                    ),
                  );
                }
              });
              //Hit End
            }).catchError((error) {
              // print(error.toString());
              setLoading(false);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PinPage(
                    loginPayload: loginPayload,
                    reason: "login",
                  ),
                ),
              );
              //Hooks Slack
              hookSlack(
                context: context,
                endPoint: "Login Page - SDK ONESIGNAL EndPoint",
                funcName: "Login Page - SDK ONESIGNAL Function",
                msgCatch: error.toString(),
                payload: userCheckPayload,
                isAPI: false,
              );
            });
          } else if (response.data.first.onesignalExternalUserIdStatus ==
              true) {
            setLoading(false);
            SharedPreferencesService().setOneSignalExternalUserId(
                response.data.first.onesignalExternalUserId);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PinPage(
                  loginPayload: loginPayload,
                  reason: "login",
                ),
              ),
            );
          } else {
            setLoading(false);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PinPage(
                  loginPayload: loginPayload,
                  reason: "login",
                ),
              ),
            );
          }
          //ONE SIGNAL HANDLE END
          OtpRequestPayload otpRequestPayload = new OtpRequestPayload(
              phone: loginPayload.phoneNumber, email: email);
          SharedPreferencesService().setOtpRequestPayload(otpRequestPayload);
          //**REAL CODE */
        } else if (response.data.first.statusRegister == "UNVERIFIED") {
          setLoading(false);
          //not verified phone number
          String email = "";

          try {
            email = response.data.first.email;
          } catch (e) {}

          OtpRequestPayload otpRequestPayload = new OtpRequestPayload(
              phone: loginPayload.phoneNumber, email: email);
          SharedPreferencesService().setOtpRequestPayload(otpRequestPayload);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WelcomeOnboardingPage(),
            ),
          );
        } else if (response.data.first.statusRegister == "VERIFIED" &&
            response.data.first.pinSetup == false) {
          setLoading(false);

          String email = "";
          try {
            email = response.data.first.email;
          } catch (e) {}
          OtpRequestPayload otpRequestPayload = new OtpRequestPayload(
              phone: loginPayload.phoneNumber, email: email);
          SharedPreferencesService().setOtpRequestPayload(otpRequestPayload);
          //Password Page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PasswordPage(
                reason: "pre_create_pin",
                loginPayload: loginPayload,
              ),
            ),
          );
        } else {
          setLoading(false);
          try {
            CustomWidget().showCustomDialog(
                context: context, msg: response.response.message);
          } catch (e) {
            CustomWidget()
                .showCustomDialog(context: context, msg: e.toString());
          }
        }
      } else {
        setLoading(false);
        try {
          CustomWidget().showCustomDialog(
              context: context, msg: response.response.message);
        } catch (e) {
          CustomWidget().showCustomDialog(context: context, msg: e.toString());
        }
      }
    }, onError: (response) {
      setLoading(false);
      try {
        if (isOnline) {
          if (response.response.message == "Member Not Found" ||
              response.response.message ==
                  "The phone must be between 8 and 14 digits." ||
              response.response.message ==
                  "Your account need activation please contact our CS" ||
              response.response.message ==
                  "This primary phone or email already used more than 1 user Active. Please contact Customer Service to fixed") {
            CustomWidget().showCustomDialog(
                context: context, msg: response.response.message);

            print("DO ===>>> NOTHING");
          } else if (SharedPrefKeys.msgDio.isNotEmpty) {
            hookSlack(
              context: context,
              payload: userCheckPayload,
              endPoint: GlobalVar.URL_USER_CHECK,
              funcName: "Login Page - UserCheck2 - Server",
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
              payload: userCheckPayload,
              endPoint: GlobalVar.URL_USER_CHECK,
              funcName: "Login Page - UserCheck1",
              isAPI: true,
            );
          }
        } else {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ErrorNetworkPage()));
        }

        // setState(() {});
      } catch (e) {
        if (SharedPrefKeys.msgDio.isNotEmpty) {
          hookSlack(
            context: context,
            payload: userCheckPayload,
            endPoint: GlobalVar.URL_USER_CHECK,
            funcName: "Login Page - UserCheck2",
            msgCatch: SharedPreferencesService().msgDio.toString(),
            isAPI: false,
          );
          CustomWidget().showCustomDialog(
              context: context, msg: SharedPreferencesService().msgDio);
        } else {
          hookSlack(
            context: context,
            payload: userCheckPayload,
            endPoint: GlobalVar.URL_USER_CHECK,
            funcName: "Login Page - UserCheck3",
            msgCatch: e.toString(),
            isAPI: false,
          );
          CustomWidget().showCustomDialog(context: context, msg: e.toString());
        }
      }
    });
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
        deviceId: loginPayload.deviceId,
        deviceName: loginPayload.deviceName,
        deviceType: loginPayload.deviceType,
        osName: "",
        osVersion: osVersion,
      ),
      userPhone: payload.phone,
    );

    userModel.logSlack(payloadSlack, context,
        onSuccess: (response) {}, onError: (response) {});
  }

  void login(BuildContext context, {String pin, bool isGuest}) {
    final userModel = Provider.of<UserViewModel>(context, listen: false);

    if (fcmToken == null || fcmToken == "") {
      setOnesignal(context);
    }
    fcmToken = SharedPreferencesService().fcmToken;

    if (flavor == "development") {
      if (SharedPreferencesService().locationSelected == "ID") {
        loginPayload.phoneNumber = "6280000000001";
        loginPayload.phoneCode = "62";
        loginPayload.password = "W8Jrl6ct";
        loginPayload.pin = "111111";
        loginPayload.isGuest = true;
        loginPayload.onesignalPlayerId = fcmToken;
        loginPayload.gcmToken = fcmToken;
        print('development | guest ID');
      } else if (SharedPreferencesService().locationSelected == "MY") {
        loginPayload.phoneNumber = "60170000001";
        loginPayload.phoneCode = "60";
        loginPayload.password = "y2CEPcPE";
        loginPayload.pin = "111111";
        loginPayload.isGuest = true;
        loginPayload.onesignalPlayerId = fcmToken;
        loginPayload.gcmToken = fcmToken;
        print('development | guest MY');
      } else if (SharedPreferencesService().locationSelected == "PH") {
        loginPayload.phoneNumber = "639220000001";
        loginPayload.phoneCode = "63";
        loginPayload.password = "IKkDHTBQ";
        loginPayload.pin = "111111";
        loginPayload.isGuest = true;
        loginPayload.onesignalPlayerId = fcmToken;
        loginPayload.gcmToken = fcmToken;

        print('development | guest PH');
      }
    } else {
      if (SharedPreferencesService().locationSelected == "ID") {
        loginPayload.phoneNumber = "6280000000001";
        loginPayload.phoneCode = "62";
        loginPayload.password = "ZyCwPuUL";
        loginPayload.pin = "111111";
        loginPayload.isGuest = true;
        loginPayload.onesignalPlayerId = fcmToken;
        loginPayload.gcmToken = fcmToken;
      } else if (SharedPreferencesService().locationSelected == "MY") {
        loginPayload.phoneNumber = "60170000001";
        loginPayload.phoneCode = "60";
        loginPayload.password = "6gMLi7cZ";
        loginPayload.pin = "111111";
        loginPayload.isGuest = true;
        loginPayload.onesignalPlayerId = fcmToken;
        loginPayload.gcmToken = fcmToken;
      } else if (SharedPreferencesService().locationSelected == "PH") {
        loginPayload.phoneNumber = "639220000001";
        loginPayload.phoneCode = "63";
        loginPayload.password = "56LPSYgj";
        loginPayload.pin = "111111";
        loginPayload.isGuest = true;
        loginPayload.onesignalPlayerId = fcmToken;
        loginPayload.gcmToken = fcmToken;
      }
    }

    //print(json.encode(loginPayload));
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await userModel.login(loginPayload, context,
            onSuccess: (response, password, isGuest) async {
          //print("payload3 " + json.encode(response));
          //print("reason3 " + widget.reason);
          if (response.response.code == 200) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => Home(),
                ),
                (Route<dynamic> route) => false);
          } else {
            CustomWidget().showCustomDialog(
                context: context, msg: response.response.message);
          }
        }, onError: (response) {
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
        });
      },
    );
  }

  Future<bool> onWillPop(BuildContext context) {
    if (widget.from == "guest" || widget.from == "add_account") {
      Navigator.pop(context);
    } else if (widget.from == "add_account") {
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OnboardingPage(),
        ),
      );
    }
    return Future.value(true);
  }

  //Req Loc Permission
  void reqLocationPermission() async {
    //start devrafi
    final serviceStatus = await Permission.locationWhenInUse.serviceStatus;
    final isGpsOn = serviceStatus == ServiceStatus.enabled;
    if (!isGpsOn) {
      print("Turn on location services berfore request permission");
      return;
    }
    final status = await Permission.locationWhenInUse.request();
    if (status == PermissionStatus.granted) {
      print("Open Maps Location => Status Permission Granted");
    } else if (status == PermissionStatus.denied) {
      print("Open Maps Location => Status Denied");
    } else if (status == PermissionStatus.permanentlyDenied) {
      print("Open Maps Location => Status Permanante");
      await openAppSettings();
    }
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

  void setLoading(bool value) {
    loading = value;
    setState(() {});
  }
}
