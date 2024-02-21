import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_popbox/core/bloc/bottom_navigation/bottom_navigation_bloc.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/user/multi_phone_no.dart';
import 'package:new_popbox/core/models/callback/user/user_login_data.dart';
import 'package:new_popbox/core/models/payload/change_profile_payload.dart';
import 'package:new_popbox/core/models/payload/login_payload.dart';
import 'package:new_popbox/core/models/payload/logout_payload.dart';
import 'package:new_popbox/core/models/payload/otp_request_payload.dart';
import 'package:new_popbox/core/models/payload/phone_no_payload.dart';
import 'package:new_popbox/core/models/payload/user_check_payload.dart';
import 'package:new_popbox/core/utils/global_function.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/pages/account_emailverification_page.dart';
import 'package:new_popbox/ui/pages/home.dart';
import 'package:new_popbox/ui/pages/merge_account_info_page.dart';
import 'package:new_popbox/ui/pages/pin_page.dart';
import 'package:new_popbox/ui/pages/splash_screen_page.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:new_popbox/ui/widget/gender_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:remove_emoji/remove_emoji.dart';

import 'otp_method_page.dart';

class AccountInfoPage extends StatefulWidget {
  final String from;

  const AccountInfoPage({Key key, this.from}) : super(key: key);
  @override
  _AccountInfoPageState createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage>
    with WidgetsBindingObserver {
  TextEditingController pinController =
      TextEditingController(text: "● ● ● ● ● ●");
  SharedPreferencesService sharedPrefService;

  UserLoginData userData = new UserLoginData();
  LoginPayload loginPayload = new LoginPayload();

  List<MultiplePhoneNumber> _multiplePhoneNumber = [];

  String fcmToken = "";
  String model = "";
  String deviceVersion = "";
  String identifier = "";
  String brand = "";
  String osVersion = "";
  String osType = "";
  //String isEmailVerified = "";
  String emailAddress = "";
  String isEmailVerified = "";
  bool isVerifiedEmail = false;

  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController _removeAccReasonController = TextEditingController();

  //TextEditingController monthController = TextEditingController();
  //TextEditingController yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        sharedPrefService = await SharedPreferencesService.instance;
        UserLoginData userData = await SharedPreferencesService().getUser();

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

        if (userData != null) {
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
          loginPayload.notificationSetting = await isNotificationOn();

          if (emailAddress == "") {
            emailAddress = SharedPreferencesService().user.email;
          }

          try {
            if (SharedPreferencesService().isVerifiedEmail == null) {
              _userCheck();
            }
          } catch (e) {}
        }
      },
    );
    getMultiPhoneData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    UserViewModel().dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //do your stuff

    }
  }

  void getMultiPhoneData() {
    final userModel = Provider.of<UserViewModel>(context, listen: false);

    try {
      _multiplePhoneNumber =
          userModel.loginResponse.data.first.multiplePhoneNumber;

      for (var i = 0; i < _multiplePhoneNumber.length; i++) {
        if (_multiplePhoneNumber[i].phone ==
            SharedPreferencesService().user.phone) {
          MultiplePhoneNumber primaryData = _multiplePhoneNumber[i];
          if (_multiplePhoneNumber.remove(_multiplePhoneNumber[i])) {
            _multiplePhoneNumber.insert(0, primaryData);
          }
        }
      }
    } catch (e) {}
  }

  // @override
  // Future<bool> didPopRoute() async {
  //   print("eeeeeeeeee");
  //   return false;
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, model, _) {
        // List<MultiplePhoneNumber> _multiplePhoneNumber = [];
        // try {
        //   _multiplePhoneNumber =
        //       model.loginResponse.data.first.multiplePhoneNumber;

        //   for (var i = 0; i < _multiplePhoneNumber.length; i++) {
        //     if (_multiplePhoneNumber[i].phone ==
        //         SharedPreferencesService().user.phone) {
        //       MultiplePhoneNumber primaryData = _multiplePhoneNumber[i];
        //       if (_multiplePhoneNumber.remove(_multiplePhoneNumber[i])) {
        //         _multiplePhoneNumber.insert(0, primaryData);
        //       }
        //     }
        //   }
        // } catch (e) {}

        // if (_multiplePhoneNumber == null) {
        //   _multiplePhoneNumber =
        //       SharedPreferencesService().user.multiplePhoneNumber;
        // }

        getMultiPhoneData();

        return WillPopScope(
          // ignore: missing_return
          onWillPop: () {
            handleWillPop();
          },
          child: Stack(
            children: [
              Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(60.0),
                  child: DetailAppBarView(
                    isCallback: true,
                    title: AppLocalizations.of(context)
                        .translate(LanguageKeys.accountInfo),
                    callback: () {
                      handleWillPop();
                    },
                  ),
                ),
                body: SafeArea(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 30.0,
                    ),
                    child: RefreshIndicator(
                      onRefresh: _userCheck,
                      child: ListView(
                        children: [
                          SharedPreferencesService().mergePhoneList != null &&
                                  SharedPreferencesService()
                                          .mergePhoneList
                                          .length >
                                      0
                              ? Container(
                                  margin: EdgeInsets.only(
                                      left: 0.0,
                                      right: 0.0,
                                      top: 0.0,
                                      bottom: 20),
                                  padding:
                                      EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                                  child: CustomWidget().textRegular(
                                    AppLocalizations.of(context).translate(
                                        LanguageKeys
                                            .phoneNoAlreadyRegistered_anotherAccountInfo),
                                    PopboxColor.mdGrey700,
                                    11.0.sp,
                                    TextAlign.left,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: PopboxColor.mdYellow100),
                                    color: PopboxColor.mdYellow100,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                )
                              : Container(),
                          contentData(
                            title: AppLocalizations.of(context)
                                .translate(LanguageKeys.name),
                            content: SharedPreferencesService().user.name,
                            keyword: "name",
                          ),
                          contentData(
                            title: AppLocalizations.of(context)
                                .translate(LanguageKeys.birthDate),
                            content: SharedPreferencesService().user.dob,
                            keyword: "dob",
                          ),
                          contentData(
                            title: AppLocalizations.of(context)
                                .translate(LanguageKeys.gender),
                            content: AppLocalizations.of(context).translate(
                                SharedPreferencesService().user.gender),
                            keyword: "gender",
                          ),
                          contentData(
                            title: AppLocalizations.of(context)
                                .translate(LanguageKeys.email),
                            content: emailAddress.toString(),
                            keyword: "email",
                          ),
                          contentData(
                            title: "Phone",
                            content: SharedPreferencesService().user.phone,
                            keyword: "phone",
                          ),
                          contentData(
                            title: "PIN",
                            content: "PIN",
                            keyword: "pin",
                          ),
                          InkWell(
                            onTap: () {
                              showReasonDeleteAccPopUp(context: context);
                            },
                            child: CustomWidget().textLight(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.removeAccount),
                              PopboxColor.red,
                              12,
                              TextAlign.left,
                            ),
                          ),
                          SizedBox(height: 30.0),
                          InkWell(
                            onTap: () {
                              CustomWidget().showAlertDialog(context,
                                  yesCallback: () {
                                Navigator.of(context).pop();
                                logout(context);
                              }, noCallBack: () {
                                Navigator.of(context).pop();
                              },
                                  showDialodTitle: true,
                                  keyword: "",
                                  noTitle: AppLocalizations.of(context)
                                      .translate(LanguageKeys.cancel),
                                  yesTitle:
                                      AppLocalizations.of(context).translate(
                                    LanguageKeys.yes,
                                  ),
                                  message: AppLocalizations.of(context)
                                      .translate(LanguageKeys.sureToExit));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2, color: PopboxColor.red),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: CustomWidget().customColorButton(
                                context,
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.quitApps),
                                PopboxColor.mdWhite1000,
                                PopboxColor.red,
                              ),
                            ),
                          ),
                        ],
                      ),
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
          ),
        );
      },
    );
  }

  Widget contentData(
      {String title,
      String content,
      String keyword,
      TextEditingController controller}) {
    if (content == "" || content == null) {
      if (keyword == "name") {
        content =
            AppLocalizations.of(context).translate(LanguageKeys.enterName);
      } else if (keyword == "dob") {
        content = AppLocalizations.of(context)
            .translate(LanguageKeys.enterDateOfBirth);
      } else if (keyword == "gender") {
        content =
            AppLocalizations.of(context).translate(LanguageKeys.chooseGender);
      } else if (keyword == "email") {
        content = SharedPreferencesService().user.email;
      } else if (keyword == "pin") {
        content = AppLocalizations.of(context).translate(LanguageKeys.pin);
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            child: CustomWidget().textLight(
          title,
          PopboxColor.mdGrey700,
          12,
          TextAlign.left,
        )),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  width: 70.0.w,
                  child: keyword == "email" &&
                          SharedPreferencesService().isVerifiedEmail == true
                      ? Row(
                          children: [
                            CustomWidget().textLight(
                              content == "email" ? pinController.text : content,
                              PopboxColor.mdBlack1000,
                              content == "email" ? 18 : 14,
                              TextAlign.left,
                            ),
                            SizedBox(
                              width: 3.0,
                            ),
                            Image.asset(
                              "assets/images/ic_verified_email.png",
                              width: 20.0,
                              height: 20.0,
                              fit: BoxFit.fitHeight,
                            ),
                          ],
                        )
                      : CustomWidget().textLight(
                          content == "PIN" ? pinController.text : content,
                          PopboxColor.mdBlack1000,
                          content == "PIN" ? 18 : 14,
                          TextAlign.left,
                        ),
                ),
                flex: 8,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (keyword == "name") {
                      callNameDialog();
                    } else if (keyword == "dob") {
                      callDateDialog();
                    } else if (keyword == "gender") {
                      callGenderDialog();
                    } else if (keyword == "email") {
                      //callEmailDialog();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AccountEmailverificationPage(
                            emailAddress: emailAddress,
                            isVerifiedEmail:
                                (SharedPreferencesService().isVerifiedEmail ==
                                            null ||
                                        SharedPreferencesService()
                                                .isVerifiedEmail ==
                                            true)
                                    ? true
                                    : false,
                          ),
                        ),
                      );
                    } else if (keyword == "pin") {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PinPage(
                            loginPayload: loginPayload,
                            reason: "update_pin",
                          ),
                        ),
                      );
                    }
                  },
                  child: (keyword == "email" &&
                          SharedPreferencesService().isVerifiedEmail == false)
                      ? Padding(
                          padding: EdgeInsets.all(1.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomWidget().textMedium(
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.verifyNow),
                                PopboxColor.red,
                                7.0.sp,
                                TextAlign.right,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Image.asset(
                                "assets/images/ic_unverified_email.png",
                                width: 20.0,
                                height: 20.0,
                                fit: BoxFit.fitHeight,
                              ),
                            ],
                          ))
                      : (keyword == "phone")
                          ? Container()
                          : CustomWidget().textMedium(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.change),
                              PopboxColor.blue477FFF,
                              9.0.sp,
                              TextAlign.right,
                            ),
                ),
                flex: 4,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 0.0, bottom: 30.0),
          child: Divider(
            height: 1.0,
            color: PopboxColor.mdWhite1000,
          ),
        ),
      ],
    );
  }

  void callNameDialog() {
    nameController.text = SharedPreferencesService().user.name;
    CustomWidget().showAlertDialogAddGeneral(
      context,
      controller: nameController,
      noCallBack: () {
        Navigator.of(context).pop();
      },
      yesCallback: () {
        if (nameController.text.length > 30) {
          CustomWidget().showCustomDialog(
            context: context,
            msg: AppLocalizations.of(context)
                .translate(LanguageKeys.maxCharacter)
                .replaceAll("%1s", "30"),
          );
        } else {
          changeProfile(from: "name", name: nameController.text);
        }
      },
      title: AppLocalizations.of(context).translate(LanguageKeys.changeName),
      fieldTitle: AppLocalizations.of(context).translate(LanguageKeys.name),
      hintTitle: AppLocalizations.of(context)
          .translate(LanguageKeys.maxCharacter)
          .replaceAll("%1s", "30"),
      noTitle: AppLocalizations.of(context).translate(LanguageKeys.cancel),
      yesTitle: AppLocalizations.of(context).translate(LanguageKeys.save),
      initialValue: SharedPreferencesService().user.name,
    );
  }

  void callEmailDialog() {
    emailController.text = SharedPreferencesService().user.email;
    CustomWidget().showAlertDialogAddGeneral(
      context,
      controller: emailController,
      noCallBack: () {
        Navigator.of(context).pop();
      },
      yesCallback: () {
        bool emailValid = RegExp(
                r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$')
            .hasMatch(emailController.text);
        if (!emailValid) {
          CustomWidget().showCustomDialog(
            context: context,
            msg: AppLocalizations.of(context).translate(
              LanguageKeys.emailFormatIsRequired,
            ),
          );
        } else {
          changeProfile(from: "email", email: emailController.text);
        }
      },
      title: AppLocalizations.of(context).translate(LanguageKeys.changeEmail),
      fieldTitle: AppLocalizations.of(context).translate(LanguageKeys.email),
      hintTitle: "",
      noTitle: AppLocalizations.of(context).translate(LanguageKeys.cancel),
      yesTitle: AppLocalizations.of(context).translate(LanguageKeys.save),
      initialValue: SharedPreferencesService().user.email,
    );
  }

  void callDateDialog() {
    try {
      if (SharedPreferencesService().user.dob != null &&
          SharedPreferencesService().user.dob != "") {
        DateFormat format = DateFormat("yyyy-MM-dd");
        DateTime dateTime = format.parse(SharedPreferencesService().user.dob);

        String localeDate = "id_ID";
        if (SharedPreferencesService().locationSelected != 'ID') {
          localeDate = "en_EN";
        }
        DateFormat outputFormat = DateFormat('dd MMMM yyyy', localeDate);
        String outputDate = outputFormat.format(dateTime);

        dateController.text = outputDate;
      }
    } catch (e) {}
    //print("dob : " + SharedPreferencesService().user.dob.substring(8, 9));

    CustomWidget().showAlertDialogDate(
      context,
      dateController: dateController,
      //monthController: monthController,
      //yearController: yearController,
      noCallBack: () {
        Navigator.of(context).pop();
      },
      yesCallback: () {
        String dob = "";
        if (dateController.text != null && dateController.text != "") {
          String localeDate = "id_ID";
          if (SharedPreferencesService().locationSelected != 'ID') {
            localeDate = "en_EN";
          }

          DateFormat format = DateFormat("dd MMMM yyyy", localeDate);
          DateTime dateTime = format.parse(dateController.text);

          DateFormat outputFormat = DateFormat('yyyy-MM-dd');
          dob = outputFormat.format(dateTime);
        }
        changeProfile(from: "dob", dob: dob);
      },
      title: AppLocalizations.of(context)
          .translate(LanguageKeys.changeDateOfBirth),
      fieldTitle:
          AppLocalizations.of(context).translate(LanguageKeys.birthDate),
      hintTitle: "",
      noTitle: AppLocalizations.of(context).translate(LanguageKeys.cancel),
      yesTitle: AppLocalizations.of(context).translate(LanguageKeys.save),
      initialValue: SharedPreferencesService().user.dob,
    );
  }

  void callGenderDialog() {
    genderController.text = SharedPreferencesService().user.gender;

    showDialog(
      context: context,
      builder: (_) => GenderDialog(
        controller: genderController,
        noCallBack: () {
          Navigator.of(context).pop();
        },
        yesCallback: () {
          // String gender = "";
          // if (genderController != null && genderController.text == "0") {
          //   gender = "male";
          // } else if (genderController != null && genderController.text == "0") {
          //   gender = "female";
          // }
          changeProfile(from: "gender", gender: genderController.text);
        },
        title:
            AppLocalizations.of(context).translate(LanguageKeys.changeGender),
        fieldTitle: AppLocalizations.of(context).translate(LanguageKeys.gender),
        hintTitle: "",
        noTitle: AppLocalizations.of(context).translate(LanguageKeys.cancel),
        yesTitle: AppLocalizations.of(context).translate(LanguageKeys.save),
        initialValue: SharedPreferencesService().user.gender,
      ),
    );
  }

  Widget phoneItem(int index, MultiplePhoneNumber multiplePhoneNumber) {
    bool isDefault = false;

    if (multiplePhoneNumber.phone == SharedPreferencesService().user.phone) {
      isDefault = true;
    }

    return GestureDetector(
      onTap: () {
        setState(() {});
      },
      child: Container(
        margin:
            const EdgeInsets.only(left: 0.0, right: 0.0, top: 8.0, bottom: 0.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 12.0),
                  child: CustomWidget().textBold(
                    multiplePhoneNumber.phone,
                    PopboxColor.mdGrey800,
                    12.0.sp,
                    TextAlign.left,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      children: [
                        isDefault
                            ? Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: CustomButtonGeneral(
                                  onPressed: null,
                                  title: AppLocalizations.of(context)
                                      .translate(LanguageKeys.primary),
                                  bgColor: PopboxColor.mdYellow700,
                                  textColor: PopboxColor.mdWhite1000,
                                  fontSize: 10.0.sp,
                                  height: 30.0,
                                  borderColor: PopboxColor.mdYellow700,
                                  width: 90.0,
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  submitPhone(
                                      "primary", multiplePhoneNumber.phone);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: CustomWidget().textBoldUnderline(
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.asPrimary),
                                      PopboxColor.mdGrey700,
                                      9.0.sp,
                                      TextAlign.center),
                                ),
                              ),
                        isDefault
                            ? Container()
                            : InkWell(
                                onTap: () {
                                  CustomWidget().showAlertDialogWithButton(
                                      context, noCallBack: () {
                                    Navigator.of(context).pop();
                                  }, yesCallback: () {
                                    submitPhone(
                                        "delete", multiplePhoneNumber.phone);
                                  },
                                      message: AppLocalizations.of(context)
                                          .translate(LanguageKeys
                                              .areYouSureDeletePhoneNo)
                                          .replaceAll(
                                              "%1s", multiplePhoneNumber.phone),
                                      noTitle: AppLocalizations.of(context)
                                          .translate(LanguageKeys.cancel),
                                      yesTitle: AppLocalizations.of(context)
                                          .translate(LanguageKeys.delete));
                                },
                                child: Image.asset(
                                  "assets/images/ic_delete_phone.png",
                                  width: 24.0,
                                  height: 24.0,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Divider(
              height: 1.0,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  void resetData() {
    //SharedPreferencesService().removeValues(keyword: "userData");
    // SharedPreferencesService().removeValues(keyword: "fcmToken");
    SharedPreferencesService().removeValues(keyword: "otpCounter");
    SharedPreferencesService().removeValues(keyword: "otpRequestPayload");
    SharedPreferencesService().removeValues(keyword: "registerPayload");
    SharedPreferencesService().removeValues(keyword: "otpValidationPayload");
    SharedPreferencesService().removeValues(keyword: "isLoadTransaction");
    SharedPreferencesService().removeValues(keyword: "existingLoginCountry");
    //Navigator.pop(context);

    context.read<BottomNavigationBloc>().add(
          PageTapped(index: 0),
        );
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => SplashScreenPage(),
        ),
        (Route<dynamic> route) => false);
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

    //print("payload " + json.encode(logoutPayload));

    userModel.logout(logoutPayload, context, onSuccess: (response) async {
      //print("callback " + json.encode(response));
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
        } catch (e) {
          // print("catch1 : " + e.toString());
        }
        resetData();
      } else {
        // print("response1 : " + response.response.message);
        //hide
        // CustomWidget()
        //     .showCustomDialog(context: context, msg: response.response.message);
      }
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
          } catch (e) {
            // print("catch1 : " + e.toString());
          }
          resetData();
        }
        //hide
        // CustomWidget()
        //     .showCustomDialog(context: context, msg: response.response.message);
      } catch (e) {
        // print("catch2 : " + e.toString());
        //hide
        // CustomWidget().showCustomDialog(
        //   context: context,
        //   msg: AppLocalizations.of(context)
        //       .translate(LanguageKeys.unkownErrorOccoured),
        // );
      }
    });
  }

  void submitPhone(String from, String phoneNo) {
    FocusScope.of(context).unfocus();

    if (phoneNo.startsWith("0")) {
      phoneNo = phoneNo.replaceFirst(RegExp("0"), "").replaceAll(" ", "");
    }

    if (phoneNo.startsWith("62")) {
      phoneNo = phoneNo.replaceFirst(RegExp("62"), "").replaceAll(" ", "");
    }

    if (phoneNo.startsWith("60")) {
      phoneNo = phoneNo.replaceFirst(RegExp("60"), "").replaceAll(" ", "");
    }

    if (phoneNo.startsWith("63")) {
      phoneNo = phoneNo.replaceFirst(RegExp("63"), "").replaceAll(" ", "");
    }

    int minPhoneLength = 0;
    int maxPhoneLength = 12;
    if (sharedPrefService.locationSelected == "ID") {
      minPhoneLength = 9;
    } else if (sharedPrefService.locationSelected == "MY") {
      minPhoneLength = 7;
    } else if (sharedPrefService.locationSelected == "PH") {
      minPhoneLength = 8;
    }

    if (phoneNo.trim() == "") {
    } else if (phoneNo.trim().length < minPhoneLength) {
      CustomWidget().showCustomDialog(
        context: context,
        msg: AppLocalizations.of(context)
            .translate(LanguageKeys.phoneNoAtLeastNineDigits)
            .replaceAll(
              "%1s",
              (minPhoneLength + 2).toString(),
            ),
      );
    } else if (phoneNo.trim().length > maxPhoneLength) {
      CustomWidget().showCustomDialog(
        context: context,
        msg: AppLocalizations.of(context)
            .translate(LanguageKeys.phoneNoMaxFourteenDigits)
            .replaceAll(
              "%1s",
              (maxPhoneLength + 2).toString(),
            ),
      );
    } else {
      loginPayload.phoneNumber = SharedPreferencesService().phoneCode + phoneNo;

      loginPayload.phoneCode = sharedPrefService.phoneCode;

      loginPayload.countryCode = sharedPrefService.locationSelected;

      userCheck(context, from);
    }
  }

  void userCheck(BuildContext context, String from) async {
    final userModel = Provider.of<UserViewModel>(context, listen: false);

    UserCheckPayload userCheckPayload = new UserCheckPayload(
      token: GlobalVar.API_TOKEN,
      phone: loginPayload.phoneNumber.replaceAll(" ", ""),
      deviceId: loginPayload.deviceId,
      notificationSetting: loginPayload.notificationSetting,
      onesignalPlayerId: loginPayload.onesignalPlayerId,
    );

    if (from == "add") {
      // - Kondisi 1: no. HP baru belum terdaftar
      //"code": 400 && "data": []

      // - Kondisi 2: no. HP baru sudah terdaftar sebagai primary tapi status akun `ACTIVE`
      //"code": 200 &&  "status" = "ACTIVE" && "type_registered" = "PRIMARY"
      // - Kondisi 3: no. HP baru sudah terdaftar sebagai primary dan status akun `NOT ACTIVE`
      // - Kondisi 4: no. HP baru sudah terdaftar sebagai secondary no. HP dan status no. HP `VERIFIED` & `ACTIVE`
      // - Kondisi 5: no. HP baru sudah terdaftar sebagai secondary no. HP dan status no. HP `VERIFIED`  & `DELETED`
      Navigator.of(context).pop();
      userModel.userCheck(userCheckPayload, context, isSaveCallbak: false,
          onSuccess: (response) async {
        if (response.data != null &&
            response.data.first != null &&
            response.data.first.statusPhoneInput != null) {
          if (response.data.first.status == "ACTIVE" &&
              response.data.first.statusPhoneInput.typeRegistered ==
                  "PRIMARY") {
            //case 2 :
            // print("case2");
            otpRequest(reason: "case2");
          } else if (response.data.first.status == "DISABLE" &&
              response.data.first.statusPhoneInput.typeRegistered ==
                  "PRIMARY") {
            //case 3 :
            // print("case3");
            otpRequest(reason: "case3");
          } else if (response.data.first.status == "ACTIVE" &&
              response.data.first.statusPhoneInput.typeRegistered ==
                  "SECONDARY" &&
              response.data.first.statusPhoneInput.statusPhone == "VERIFIED") {
            //case 4 :
            // print("case4");
            navigateToMergeInfo("case4");
          } else if (response.data.first.status == "DELETED" &&
              response.data.first.statusPhoneInput.typeRegistered ==
                  "SECONDARY" &&
              response.data.first.statusPhoneInput.statusPhone == "VERIFIED") {
            //case 5 :
            // print("case5");
            otpRequest(reason: "add_phone");
          } else if (response.data.first.status == "ACTIVE" &&
              response.data.first.statusPhoneInput.typeRegistered ==
                  "PRIMARY" &&
              response.data.first.statusPhoneInput.statusPhone ==
                  "UNVERIFIED") {
            //case 4 :
            // print("case6");
            otpRequest(reason: "case6");
          }
        }
      }, onError: (response) {
        //case 1 :
        if (response.response.code == 400) {
          // print("case1");
          otpRequest(reason: "add_phone");
        } else {
          try {
            CustomWidget().showCustomDialog(
                context: context, msg: response.response.message);
          } catch (e) {
            CustomWidget()
                .showCustomDialog(context: context, msg: e.toString());
          }
        }
      });
    } else {
      PhoneNoPayload phoneNoPayload = new PhoneNoPayload()
        ..memberId = SharedPreferencesService().user.memberId
        ..phone = loginPayload.phoneNumber
        ..sessionId = SharedPreferencesService().user.sessionId
        ..token = GlobalVar.API_TOKEN;

      final userModel = Provider.of<UserViewModel>(context, listen: false);

      userModel.multiplePhone(
        from,
        phoneNoPayload,
        context,
        onSuccess: (response) {
          getMultiPhoneData();
          if (from == "delete") {
            Navigator.of(context).pop();
            CustomWidget().showCustomDialog(
                context: context,
                msg: AppLocalizations.of(context)
                    .translate(LanguageKeys.phoneNoSuccessfullyDeleted));
          } else {
            CustomWidget().showCustomDialog(
              context: context,
              msg: AppLocalizations.of(context)
                  .translate(LanguageKeys.changePrimaryNoIsSuccess)
                  .replaceAll("%1s", phoneNoPayload.phone),
            );
          }
        },
        onError: (response) {
          //print("response " + json.encode(response));
          CustomWidget().showCustomDialog(
              context: context, msg: response.response.message);
        },
      );
    }
  }

  void navigateToMergeInfo(String from) {
    phoneController.text = "";
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MergeAccountInfoPage(
          from: from,
          mergePhoneNo: "",
        ),
      ),
    );
  }

  void otpRequest({@required String reason}) {
    String email = "";

    try {
      email = userData.email;
    } catch (e) {}

    OtpRequestPayload otpRequestPayload =
        new OtpRequestPayload(phone: loginPayload.phoneNumber, email: email);
    SharedPreferencesService().setOtpRequestPayload(otpRequestPayload);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OtpMethodPage(
          reason: reason,
          showDotsIndicator: false,
          mergePhoneNo: loginPayload.phoneNumber,
        ),
      ),
    );
  }

  void changeProfile(
      {@required String from,
      String email,
      String dob,
      String name,
      String gender}) {
    if (from == "email") {
      if (email == null || email.trim() == "") {
        return;
      }
    }

    if (from == "dob") {
      if (dob == null || dob.trim() == "") {
        return;
      }
    }

    if (from == "name") {
      if (name == null || name.trim() == "") {
        return;
      }
    }

    if (from == "gender") {
      if (gender == null || gender.trim() == "") {
        return;
      }
    }

    FocusScope.of(context).unfocus();
    ChangeProfilePayload profilePayload = new ChangeProfilePayload()
      ..token = GlobalVar.API_TOKEN
      ..memberId = SharedPreferencesService().user.memberId
      ..sessionId = SharedPreferencesService().user.sessionId;

    if (from == "email") {
      profilePayload.email = email.trim();
    } else if (from == "dob") {
      profilePayload.dob = dob.trim();
    } else if (from == "name") {
      profilePayload.name = name.trim();
    } else if (from == "gender") {
      profilePayload.gender = gender.trim();
    }
    final userModel = Provider.of<UserViewModel>(context, listen: false);
    userModel.changeProfile(
      profilePayload,
      context,
      onSuccess: (response) {
        Navigator.of(context).pop();
      },
      onError: (response) {
        try {
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
        } catch (e) {
          CustomWidget().showCustomDialog(
              context: context, msg: "catch : : " + e.toString());
        }
      },
    );
  }

  bool isALreadyMergeRequested(String phoneNo) {
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

    phoneNo = SharedPreferencesService().phoneCode + phoneNo;
    try {
      if (SharedPreferencesService().mergePhoneList != null &&
          SharedPreferencesService().mergePhoneList.length > 0) {
        for (var i = 0;
            i < SharedPreferencesService().mergePhoneList.length;
            i++) {
          // print("phoneNo " + phoneNo);
          // print(
          //     "phoneNo2 " + SharedPreferencesService().mergePhoneList[i].phone);
          if (phoneNo == SharedPreferencesService().mergePhoneList[i].phone) {
            Navigator.pop(context);
            Future.delayed(Duration(microseconds: 20)).whenComplete(() {
              CustomWidget().showCustomDialog(
                  context: context,
                  msg: AppLocalizations.of(context)
                      .translate(LanguageKeys.mergePhoneRequestIsOnProcessing));
            });

            return true;
          }
        }
      }
    } catch (e) {}

    return false;
  }

  Future<bool> handleWillPop() async {
    if (widget.from == "pin" ||
        widget.from == "otp" ||
        widget.from == "merge") {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => Home(),
          ),
          (Route<dynamic> route) => false);
    } else {
      Navigator.pop(context);
    }
    return true;
  }

  String changeWithSamePhoneValue() {
    final shareprefPhone = SharedPreferencesService().user.phone;
    String result;

    if (shareprefPhone.startsWith("60")) {
      result = shareprefPhone.replaceFirst(RegExp("60"), "");
    } else if (shareprefPhone.startsWith("62")) {
      result = shareprefPhone.replaceFirst(RegExp("62"), "");
    } else if (shareprefPhone.startsWith("63")) {
      result = shareprefPhone.replaceFirst(RegExp("63"), "");
    }
    return result;
  }

  Future<void> _userCheck() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 100));
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
        SharedPreferencesService().user.statusEmail =
            response.data.first.statusEmail;
        if (response.data.first.statusEmail == "UNVERIFIED") {
          SharedPreferencesService().setVerifiedEmail(false);
        } else {
          SharedPreferencesService().setVerifiedEmail(true);
        }
      });
    }, onError: (response) {
      //case 1 :
      if (response.response.code == 400) {
        print("case1");
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

  void showReasonDeleteAccPopUp({context, dynamic data, String from}) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 16),
                              child: Stack(
                                children: [
                                  InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(Icons.arrow_back)),
                                  Align(
                                    alignment: Alignment.center,
                                    child: CustomWidget().textBold(
                                        AppLocalizations.of(context)
                                            .translate(LanguageKeys.reason),
                                        Color(0xff222222),
                                        16,
                                        TextAlign.center),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            Container(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: TextField(
                                controller: _removeAccReasonController,
                                autocorrect: true,
                                cursorColor: PopboxColor.mdGrey700,
                                style: TextStyle(
                                  color: PopboxColor.mdBlack1000,
                                  fontSize: 12.0.sp,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintStyle:
                                      TextStyle(color: PopboxColor.mdGrey900),
                                  filled: true,
                                  fillColor: PopboxColor.mdGrey150,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(
                                        color: PopboxColor.mdGrey300,
                                        width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(
                                        color: PopboxColor.mdGrey300),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (_removeAccReasonController.text.isEmpty) {
                        CustomWidget().showCustomDialog(
                          context: context,
                          msg: AppLocalizations.of(context)
                              .translate(
                                LanguageKeys.caseIsRequired,
                              )
                              .replaceAll(
                                  "%1s",
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.reason)),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PinPage(
                              loginPayload: loginPayload,
                              reason: "remove_account",
                              removeAccReason: _removeAccReasonController.text,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 100.0.w,
                      color: Color(0xffF7F7F7),
                      padding: EdgeInsets.only(
                          left: 16, right: 16, top: 16, bottom: 16),
                      child: CustomButtonRectangle(
                        title: AppLocalizations.of(context)
                            .translate(LanguageKeys.next)
                            .toUpperCase(),
                        bgColor: PopboxColor.popboxRed,
                        textColor: PopboxColor.mdWhite1000,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).whenComplete(() => null);
  }
}
