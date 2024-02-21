import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/payload/add_user_id_payload.dart';
import 'package:new_popbox/core/models/payload/login_payload.dart';
import 'package:new_popbox/core/models/payload/register_payload.dart';
import 'package:new_popbox/core/utils/global_function.dart';
import 'package:new_popbox/core/utils/library.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/pages/camera_page.dart';
import 'package:new_popbox/ui/pages/success_page.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:remove_emoji/remove_emoji.dart';

class RegisterIdPage extends StatefulWidget {
  final String from;

  const RegisterIdPage({Key key, @required this.from}) : super(key: key);
  @override
  _RegisterIdPagePageState createState() => _RegisterIdPagePageState();
}

class _RegisterIdPagePageState extends State<RegisterIdPage> {
  DateTime selectedBirthDay = DateTime.now();
  int addressType = 0;

  String _chosenValue;

  LoginPayload loginPayload = new LoginPayload();

  String fcmToken = "";
  String model = "";
  String deviceVersion = "";
  String identifier = "";
  String brand = "";
  String osVersion = "";
  String osType = "";

  RegisterPayload registerPayload = SharedPreferencesService().registerPayload;

  String idPath = "";
  String selfiePath = "";

  int submitCounter = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
      //replace
      // loginPayload.deviceName = (brand +
      //         " " +
      //         model +
      //         " os version " +
      //         osVersion +
      //         " app version " +
      //         version +
      //         " build " +
      //         code)
      //     .removemoji
      //     .replaceAll(RegExp('[^A-Za-z0-9]'), '');
      loginPayload.appVersions = code;
      loginPayload.deviceType = osType;
      loginPayload.gcmToken = fcmToken;
      loginPayload.onesignalPlayerId = fcmToken;
      loginPayload.notificationSetting = await isNotificationOn();
      loginPayload.token = GlobalVar.API_TOKEN;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int dotCounter = 3;
    if (SharedPreferencesService().locationSelected == "PH" &&
        GlobalVar.showUploadIdStep) {
      dotCounter = 4;
    }
    return Consumer<UserViewModel>(
      builder: (context, model, _) {
        return Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(
                                        context,
                                        false,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16.0, 40.0, 0.0, 0.0),
                                      child: Image.asset(
                                        "assets/images/ic_back_black.png",
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                  ),
                                  widget.from == "verify"
                                      ? Container()
                                      : Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0.0, 40.0, 16.0, 0.0),
                                          child: CustomWidget()
                                              .dotsIndicator(dotCounter, 3),
                                        ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 60.0.w,
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 30.0, 0.0, 0.0),
                                    child: CustomWidget().textBoldProduct(
                                      AppLocalizations.of(context).translate(
                                          LanguageKeys.fillITheIdCard),
                                      PopboxColor.mdGrey900,
                                      16.0.sp,
                                      2,
                                    ),
                                  ),
                                  widget.from == "verify"
                                      ? Container()
                                      : GestureDetector(
                                          onTap: () {
                                            // Navigator.of(context).push(
                                            //   MaterialPageRoute(
                                            //     builder: (context) => PinPage(
                                            //       reason: "register",
                                            //       loginPayload: null,
                                            //     ),
                                            //   ),
                                            // );

                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SuccessPage(
                                                  'pin',
                                                  AppLocalizations.of(context)
                                                      .translate(LanguageKeys
                                                          .registeredIsSuccessfully),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0.0, 30.0, 16.0, 0.0),
                                            child: CustomWidget().textRegular(
                                              AppLocalizations.of(context)
                                                  .translate(LanguageKeys.skip),
                                              PopboxColor.mdGrey700,
                                              12.0.sp,
                                              TextAlign.left,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 20),
                            child: CustomWidget().textBold(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.idCard),
                              PopboxColor.mdGrey900,
                              10.0.sp,
                              TextAlign.left,
                            ),
                          ),
                          idTypeItem(
                            context,
                            0,
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.uploadYourdCard),
                            "assets/images/ic_placeholder_idcard.png",
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 20),
                            child: CustomWidget().textBold(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.selfie),
                              PopboxColor.mdGrey900,
                              10.0.sp,
                              TextAlign.left,
                            ),
                          ),
                          idTypeItem(
                            context,
                            1,
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.selfieWithTheProof),
                            "assets/images/ic_placeholder_selfie.png",
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 10),
                            child: CustomWidget().textMedium(
                              AppLocalizations.of(context).translate(
                                  LanguageKeys.pleaseTakeSelfieWithDocument),
                              PopboxColor.mdGrey600,
                              9.0.sp,
                              TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 32.0, 0.0, 0.0),
                      child: Column(
                        children: [
                          CustomWidget().dividerGrey(),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                            child: CustomButtonRed(
                              onPressed: () {
                                // if (widget.from == "verify" || widget.from=="register") {
                                //   submitId(context: context);
                                // } else {
                                //   Navigator.of(context).push(
                                //     MaterialPageRoute(
                                //       builder: (context) => PinPage(
                                //         reason: "register",
                                //         loginPayload: null,
                                //       ),
                                //     ),
                                //   );
                                // }

                                submitId(context: context);
                              },
                              title: AppLocalizations.of(context)
                                  .translate(LanguageKeys.submit),
                              width: 90.0.w,
                            ),
                          ),
                        ],
                      ),
                    ),
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
        );
      },
    );
  }

  int checkedIndex = -1;
  Widget idTypeItem(
      BuildContext context, int index, String title, String image) {
    bool checked = index == checkedIndex;
    return GestureDetector(
      onTap: () {
        setState(
          () {
            checkedIndex = index;

            if (checkedIndex == 0) {
              CustomWidget().showAlertDialogId(
                context,
                yesCallback: () {
                  Navigator.pop(
                    context,
                    false,
                  );
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => CameraPage(
                        isFrontCamera: false,
                        from: "id_card",
                        isShowSwitch: false,
                      ),
                    ),
                  )
                      .then((value) {
                    setState(() {
                      idPath = value.toString();
                    });
                  });
                },
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.uploadIdCard),
                message: AppLocalizations.of(context)
                    .translate(LanguageKeys.uploadIdCardRemarks),
                yesTitle:
                    AppLocalizations.of(context).translate(LanguageKeys.submit),
                imageAllowed: "assets/images/ic_placeholder_idcard_allowed.png",
                imageNotAllowed:
                    "assets/images/ic_placeholder_idcard_notallowed.png",
              );
            } else {
              CustomWidget().showAlertDialogId(
                context,
                yesCallback: () {
                  Navigator.pop(
                    context,
                    false,
                  );
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => CameraPage(
                        isFrontCamera: true,
                        from: "selfie",
                        isShowSwitch: false,
                      ),
                    ),
                  )
                      .then((value) {
                    setState(() {
                      selfiePath = value.toString();
                    });
                  });
                },
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.selfieWithTheProof),
                message: AppLocalizations.of(context)
                    .translate(LanguageKeys.uploadSelfieRemarks),
                yesTitle:
                    AppLocalizations.of(context).translate(LanguageKeys.submit),
                imageAllowed: "assets/images/ic_placeholder_selfie_allowed.png",
                imageNotAllowed:
                    "assets/images/ic_placeholder_selfie_notallowed.png",
              );
            }
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 16.0),
                      child: imageContent(index, image),
                    ),
                    Container(
                      //width: 50.0.w,
                      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 0.0, 24.0),
                      child: CustomWidget().textMediumProduct(
                        title,
                        PopboxColor.mdBlack1000,
                        11.0.sp,
                        4,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    checkedContent(index),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 16.0, 0.0),
                      child: Image.asset(
                        "assets/images/ic_chevron_right.png",
                        fit: BoxFit.fitHeight,
                        color: PopboxColor.mdBlack1000,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Divider(
            //   height: Sizes.s1,
            //   color: Colors.grey,
            // )
          ],
        ),
        decoration: BoxDecoration(
          border: Border.all(color: PopboxColor.mdGrey350),
          gradient: LinearGradient(
            colors: [
              PopboxColor.mdGrey200,
              PopboxColor.mdGrey100,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(5, 5),
              blurRadius: 10,
            )
          ],
        ),
      ),
    );
  }

  Widget imageContent(int index, String image) {
    var finalPath;

    if (index == 0 && idPath != null && idPath != "") {
      finalPath = idPath;
    } else if (index == 1 && selfiePath != null && selfiePath != "") {
      finalPath = selfiePath;
    }

    if (finalPath == null || finalPath.toString() == "null") {
      return Image.asset(
        image,
        fit: BoxFit.fitHeight,
      );
    } else {
      return Image.file(
        File(finalPath),
        fit: BoxFit.fitWidth,
        height: 50.0,
        width: 40.0,
      );
    }
  }

  Widget checkedContent(int index) {
    bool isChecked = false;
    if (index == 0 && idPath != null && idPath != "" && idPath != "null") {
      isChecked = true;
    } else if (index == 1 &&
        selfiePath != null &&
        selfiePath != "" &&
        selfiePath != "null") {
      isChecked = true;
    }
    return isChecked
        ? Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
            child: Image.asset(
              "assets/images/ic_checked_green.png",
              height: 28.0,
              width: 28.0,
            ),
          )
        : Container();
  }

  void submitId({BuildContext context}) async {
    if (submitCounter == 0) {
      submitCounter = 1;
      final userModel = Provider.of<UserViewModel>(context, listen: false);

      final newIdPath = join(
        // In this example, store the picture in the temp directory. Find
        // the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        "card_" + '${DateTime.now()}.jpeg',
      );

      var idResult = await FlutterImageCompress.compressAndGetFile(
        new File(idPath).path,
        newIdPath,
        //minWidth: 2300,
        //minHeight: 1500,
        quality: 50,
        //rotate: 90,
      );

      final newSelfiePath = join(
        // In this example, store the picture in the temp directory. Find
        // the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        "selfie_" + '${DateTime.now()}.jpeg',
      );

      var selfieResult = await FlutterImageCompress.compressAndGetFile(
        new File(selfiePath).path,
        newSelfiePath,
        //minWidth: 2300,
        //minHeight: 1500,
        quality: 50,
        //rotate: 90,
      );

      AddUserIdPayload userIdPayload = new AddUserIdPayload();
      //..imageKtp = new File(idPath)
      userIdPayload.token = GlobalVar.API_TOKEN;
      userIdPayload.imageKtp = await MultipartFile.fromFile(idResult.path);
      userIdPayload.imageSelfie =
          await MultipartFile.fromFile(selfieResult.path);
      userIdPayload.memberId = SharedPreferencesService().user.memberId;

      print(userIdPayload.imageSelfie.length.toString());

      WidgetsBinding.instance.addPostFrameCallback(
        (_) async {
          await userModel.addUserID(userIdPayload, context,
              onSuccess: (response) async {
            if (response.response.code == 200) {
              if (widget.from == "register") {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => SuccessPage(
                      'pin',
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.registeredIsSuccessfully),
                    ),
                  ),
                );
              } else {
                Navigator.pop(
                  context,
                  false,
                );
              }
            } else {
              CustomWidget().showCustomDialog(
                  context: context, msg: response.response.message);
            }
            submitCounter = 0;
          }, onError: (response) {
            submitCounter = 0;
            try {
              CustomWidget().showCustomDialog(
                  context: context, msg: response.response.message);
            } catch (e) {
              CustomWidget().showCustomDialog(
                context: context,
                msg: e.toString(),
              );
            }
          });
        },
      );
    } else {
      CustomWidget().showToastShortV1(
          context: context,
          msg: AppLocalizations.of(context).translate(LanguageKeys.pleaseWait));
    }
  }
}
