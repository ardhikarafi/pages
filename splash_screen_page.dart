import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_popbox/core/bloc/splash_screen/splash_screen_bloc.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/dao/lockers_dao.dart';
import 'package:new_popbox/core/models/callback/user/user_login_data.dart';
import 'package:new_popbox/core/models/payload/login_payload.dart';
import 'package:new_popbox/core/models/payload/one_signal_external_payload.dart';
import 'package:new_popbox/core/models/payload/user_check_payload.dart';
import 'package:new_popbox/core/utils/global_function.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/pages/home.dart';
import 'package:new_popbox/ui/pages/language_page.dart';
import 'package:new_popbox/ui/pages/login_page.dart';
import 'package:new_popbox/ui/pages/onboarding_page.dart';
import 'package:new_popbox/ui/pages/payment_history_page.dart';
import 'package:new_popbox/ui/pages/pin_page.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:new_popbox/ui/widget/splash_screen_page_widget.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:remove_emoji/remove_emoji.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  UserLoginData userData = new UserLoginData();
  LoginPayload loginPayload = new LoginPayload();

  String fcmToken = "";
  String model = "";
  String deviceVersion = "";
  String identifier = "";
  String brand = "";
  String osVersion = "";
  String osType = "";
  String isNotification = "";
  SharedPreferencesService sharedPrefService;
  String oneSignalExternalUserId = "";
  String msgDioErr;

  @override
  void initState() {
    // setOnesignal(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      sharedPrefService = await SharedPreferencesService.instance;
      oneSignalExternalUserId = sharedPrefService.getOneSignalExternalUserId;
      fcmToken = sharedPrefService.fcmToken;
      msgDioErr = sharedPrefService.msgDio;
      if (fcmToken == null || fcmToken == "") {
        setOnesignal(context);
      }

      //final sharedPrefService = await SharedPreferencesService.instance;
      // await Provider.of<PushNotificationService>(context, listen: false)
      //     .setup();
      // fcmToken = Provider.of<PushNotificationService>(context, listen: false)
      //     .fcmToken;

      userData = SharedPreferencesService().user;

      isNotification = await isNotificationOn();

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
        LockersDao().deleteLockerAll();
      } catch (e) {}

      if (userData != null && fcmToken != null) {
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

        loginPayload.phoneNumber = userData.phone;
        loginPayload.password = userData.pin;
        loginPayload.notificationSetting = isNotification;

        if (userData.isGuest == false) {
          userCheck(context);
        }
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: PopboxColor.popboxRed,
            statusBarIconBrightness: Brightness.light));
      }
    });

    SharedPreferencesService().removeValues(keyword: "loadLocalContactUs");
    SharedPreferencesService().removeValues(keyword: "msgDio");
    SharedPreferencesService().setHomeNearestLocation(false);
    SharedPreferencesService().setIsFcmUpdate(false);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: PopboxColor.popboxRed,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      body: _buildBody(context),
    );
  }

  BlocProvider<SplashScreenBloc> _buildBody(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SplashScreenBloc(new Initial()),
      child: Container(
        height: MediaQuery.maybeOf(context).size.height,
        width: MediaQuery.maybeOf(context).size.width,
        //color: PopboxColor.popboxPrimaryRed,
        child: Center(
          child: BlocBuilder<SplashScreenBloc, SplashScreenState>(
            // ignore: missing_return
            builder: (context, state) {
              if ((state is Initial) || (state is Loading)) {
                return SplashScreenWidget();
              } else if (state is Loaded) {
                bool isOnboarding = SharedPreferencesService().isOnboarding;
                if (isOnboarding == null) {
                  isOnboarding = false;
                }

                if (userData == null) {
                  if (isOnboarding) {
                    return LoginPage();
                  } else {
                    return LanguagePage(
                      reason: "location",
                    );
                  }
                } else if (userData.isGuest == true ||
                    userData.isGuest == null) {
                  return LoginPage();
                } else {
                  return SplashScreenWidget();
                }
              }
            },
          ),
        ),
      ),
    );
  }

  void storagePermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    if (statuses[Permission.storage].isGranted) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => LoginPage()));
    } else if (statuses[Permission.storage].isPermanentlyDenied) {
      openAppSettings();
    } else {
      if (Platform.isAndroid) {
        Permission.storage.request();
      } else if (Platform.isIOS) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => LoginPage()));
      }
    }
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

    userModel.userCheck(userCheckPayload, context, onSuccess: (response) async {
      try {
        if (response.response.code == 200) {
          if (response.data.first.sessionStatus == "VALID" &&
              (response.data.first.statusRegister == "VERIFIED" ||
                  (SharedPreferencesService().locationSelected == "PH" &&
                      response.data.first.statusRegister == "UNVERIFIED" &&
                      response.data.first.pinSetup == true))) {
            //ONE SIGNAL HANDLE START
            if (response.data.first.onesignalExternalUserIdStatus == false) {
              //OneSignal SDK
              OneSignal.shared
                  .setExternalUserId(response
                      .data.first.suggestGenerateOnesignalExternalUserId
                      .toString())
                  .then((results) {
                // print(results.toString());
                //HIT API External OneSignal
                final oneSignalExternalModel =
                    Provider.of<UserViewModel>(context, listen: false);
                //--One Signal Payload
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
                  SharedPreferencesService().setOneSignalExternalUserId(
                      response.data.first.onesignalExternalUserId);
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => Home(),
                      ),
                      (Route<dynamic> route) => false);
                }, onError: (response) {
                  print("Login Page => oneSignalExternal | err");
                });
                //Hit End
              }).catchError((error) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => Home(),
                    ),
                    (Route<dynamic> route) => false);
              });
            } else if (response.data.first.onesignalExternalUserIdStatus ==
                true) {
              SharedPreferencesService().setOneSignalExternalUserId(
                  response.data.first.onesignalExternalUserId);
              Future.delayed(Duration(seconds: 1), () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => Home(),
                    ),
                    (Route<dynamic> route) => false);
              });
            } else {
              Future.delayed(Duration(seconds: 1), () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => Home(),
                    ),
                    (Route<dynamic> route) => false);
              });
            }
          } else if (response.data.first.sessionStatus == "EXPIRED") {
            // Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => PinPage(
                    loginPayload: loginPayload,
                    reason: "expired",
                  ),
                ),
                (Route<dynamic> route) => false);
            // });
          } else {
            directToLogin();
          }
        } else {
          directToLogin();
        }
      } catch (e) {
        directToLogin();
      }
    }, onError: (response) {
      if (SharedPrefKeys.msgDio.isNotEmpty) {
        CustomWidget()
            .showCustomDialog(
                context: context,
                msg: SharedPreferencesService().msgDio.toString())
            .then((value) => Future.delayed(Duration(seconds: 2), () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => OnboardingPage(),
                    ),
                  );
                }));
      } else {
        directToLogin();
      }
    });
  }

  void directToLogin() {
    if (userData != null && userData.statusRegister == "VERIFIED") {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => PinPage(
              loginPayload: loginPayload,
              reason: "login",
            ),
          ),
          (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (Route<dynamic> route) => false);
    }
  }
}
