import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/address_type.dart';
import 'package:new_popbox/core/models/callback/apartment/apartment_data.dart';
import 'package:new_popbox/core/models/callback/region/city_list_data.dart';
import 'package:new_popbox/core/models/callback/region/province_list_data.dart';
import 'package:new_popbox/core/models/payload/login_payload.dart';
import 'package:new_popbox/core/utils/global_function.dart';
import 'package:new_popbox/core/utils/library.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/pages/apartment_list_page.dart';
import 'package:new_popbox/ui/pages/pin_page.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:remove_emoji/remove_emoji.dart';

class RegisterAddressPage extends StatefulWidget {
  final String from;

  const RegisterAddressPage({Key key, @required this.from}) : super(key: key);
  @override
  _RegisterAddressPagePageState createState() =>
      _RegisterAddressPagePageState();
}

class _RegisterAddressPagePageState extends State<RegisterAddressPage> {
  TextEditingController apartmenrNameController = TextEditingController();
  TextEditingController towerController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  TextEditingController floorController = TextEditingController();
  TextEditingController proviceController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();

  DateTime selectedBirthDay = DateTime.now();
  int addressType = 0;

  LoginPayload loginPayload = new LoginPayload();

  String fcmToken = "";
  String model = "";
  String deviceVersion = "";
  String identifier = "";
  String brand = "";
  String osVersion = "";
  String osType = "";

  String selectedApartment = "";
  String selectedPostalCode = "";
  int selectedProvinceId = 0;
  String selectedProvince = "";
  String selectedCity = "";

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
    int dotCounter = 4;
    double selectedIndicator = 2.0;
    if (SharedPreferencesService().locationSelected == "PH" &&
        GlobalVar.showUploadIdStep) {
      dotCounter = 5;
      selectedIndicator = 3.0;
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
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
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
                                  widget.from == "account"
                                      ? Container()
                                      : Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0.0, 40.0, 16.0, 0.0),
                                          child: CustomWidget().dotsIndicator(
                                              dotCounter, selectedIndicator),
                                        ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 28.0, 0.0, 0.0),
                                    child: CustomWidget().textBold(
                                      AppLocalizations.of(context).translate(
                                          LanguageKeys.inputCompleteAddress),
                                      PopboxColor.mdGrey900,
                                      16.0.sp,
                                      TextAlign.left,
                                    ),
                                  ),
                                  widget.from == "account"
                                      ? Container()
                                      : Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0.0, 28.0, 16.0, 0.0),
                                          child: CustomWidget().textRegular(
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys.skip),
                                            PopboxColor.mdGrey700,
                                            12.0.sp,
                                            TextAlign.left,
                                          ),
                                        ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16.0, 20.0, 0.0, 0.0),
                                child: CustomWidget().textRegular(
                                  AppLocalizations.of(context).translate(
                                      LanguageKeys
                                          .helpUsToProcessYourParcelQuickly),
                                  PopboxColor.mdGrey700,
                                  11.0.sp,
                                  TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16.0, 24.0, 16.0, 0.0),
                                child: CustomWidget().textBold(
                                  AppLocalizations.of(context).translate(
                                      LanguageKeys.choosesYourPlaceType),
                                  PopboxColor.mdBlack1000,
                                  9.0.sp,
                                  TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16.0, 12.0, 16.0, 8.0),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  itemCount: 2,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                    crossAxisSpacing: 1.0.h,
                                    height: 35.0,
                                    crossAxisCount: 2,
                                  ),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    AddressType service = StaticData()
                                        .getAddressType(context)[index];

                                    return addressTypeItem(
                                      index,
                                      service.addressType,
                                    );
                                  },
                                ),
                              ),
                              checkedIndex == 0
                                  ? apartmentView(context)
                                  : houseView(context)
                            ],
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
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => PinPage(
                                      reason: "register",
                                      loginPayload: loginPayload,
                                    ),
                                  ),
                                );
                              },
                              title: AppLocalizations.of(context)
                                  .translate(LanguageKeys.save),
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

  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: PopboxColor.mdWhite1000,
    borderRadius: BorderRadius.circular(4.0),
    border: Border.all(color: PopboxColor.mdGrey350),
  );

  int checkedIndex = 0;
  Widget addressTypeItem(int index, String title) {
    bool checked = index == checkedIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          checkedIndex = index;
        });
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: 1.0.h,
            minWidth: 1.0.w,
            maxWidth: 100.0.w,
            maxHeight: 100.0.h),
        child: RawMaterialButton(
          fillColor: checked ? PopboxColor.popboxRed : PopboxColor.mdGrey200,
          splashColor: checked ? PopboxColor.popboxRed : PopboxColor.mdGrey200,
          child: CustomWidget().textBold(
            title,
            checked ? PopboxColor.mdWhite1000 : PopboxColor.mdGrey900,
            11.0.sp,
            TextAlign.center,
          ),
          onPressed: null,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(
                color: checked ? PopboxColor.popboxRed : PopboxColor.mdGrey350,
              )),
        ),
      ),
    );
  }

  Widget apartmentView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
          child: CustomWidget().textBold(
            AppLocalizations.of(context).translate(LanguageKeys.apartmentName),
            PopboxColor.mdBlack1000,
            9.0.sp,
            TextAlign.left,
          ),
        ),
        Container(
          width: 100.0.w,
          padding: const EdgeInsets.fromLTRB(16, 12.0, 16.0, 0.0),
          child: CustomWidget().textGreyBorderRegular(
            apartmenrNameController,
            selectedApartment,
            PopboxColor.mdBlack1000,
            11.0.sp,
            "text_arrow",
            callBackVoid: () {
              navigateToApartmentList(context);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
          child: CustomWidget().textBold(
            AppLocalizations.of(context).translate(LanguageKeys.tower),
            PopboxColor.mdBlack1000,
            9.0.sp,
            TextAlign.left,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
          child: CustomWidget().textGreyBorderRegular(
            towerController,
            "",
            PopboxColor.mdBlack1000,
            12.0.sp,
            "text",
            callBackVoid: () {},
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
          child: CustomWidget().textBold(
            AppLocalizations.of(context).translate(LanguageKeys.unit),
            PopboxColor.mdBlack1000,
            9.0.sp,
            TextAlign.left,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
          child: CustomWidget().textGreyBorderRegular(
            unitController,
            "",
            PopboxColor.mdBlack1000,
            12.0.sp,
            "text",
            callBackVoid: () {},
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
          child: CustomWidget().textBold(
            AppLocalizations.of(context).translate(LanguageKeys.floor),
            PopboxColor.mdBlack1000,
            9.0.sp,
            TextAlign.left,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
          child: CustomWidget().textGreyBorderRegular(
            floorController,
            "",
            PopboxColor.mdBlack1000,
            12.0.sp,
            "text",
            callBackVoid: () {},
          ),
        ),
      ],
    );
  }

  Widget houseView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
          child: CustomWidget().textBold(
            AppLocalizations.of(context)
                .translate(LanguageKeys.completeAddress),
            PopboxColor.mdBlack1000,
            9.0.sp,
            TextAlign.left,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
          child: CustomWidget().textGreyBorderRegular(
            unitController,
            "",
            PopboxColor.mdBlack1000,
            12.0.sp,
            "text_multi",
            callBackVoid: () {},
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
          child: CustomWidget().textBold(
            AppLocalizations.of(context).translate(LanguageKeys.province),
            PopboxColor.mdBlack1000,
            9.0.sp,
            TextAlign.left,
          ),
        ),
        Container(
          width: 100.0.w,
          padding: const EdgeInsets.fromLTRB(16, 12.0, 16.0, 0.0),
          child: CustomWidget().textGreyBorderRegular(
            proviceController,
            selectedProvince,
            PopboxColor.mdBlack1000,
            11.0.sp,
            "text_arrow",
            callBackVoid: () {
              navigateToRegionList(context, "province");
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
          child: CustomWidget().textBold(
            AppLocalizations.of(context).translate(LanguageKeys.postalCode),
            PopboxColor.mdBlack1000,
            9.0.sp,
            TextAlign.left,
          ),
        ),
        Container(
          width: 100.0.w,
          padding: const EdgeInsets.fromLTRB(16, 12.0, 16.0, 0.0),
          child: CustomWidget().textGreyBorderRegular(
            postalCodeController,
            selectedPostalCode,
            PopboxColor.mdBlack1000,
            11.0.sp,
            "text_arrow",
            callBackVoid: () {
              //navigateToRegionList(context, "province");
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
          child: CustomWidget().textBold(
            AppLocalizations.of(context).translate(LanguageKeys.city),
            PopboxColor.mdBlack1000,
            9.0.sp,
            TextAlign.left,
          ),
        ),
        Container(
          width: 100.0.w,
          padding: const EdgeInsets.fromLTRB(16, 12.0, 16.0, 0.0),
          child: CustomWidget().textGreyBorderRegular(
            cityController,
            selectedCity,
            PopboxColor.mdBlack1000,
            11.0.sp,
            "text_arrow",
            callBackVoid: () {
              navigateToRegionList(context, "city");
            },
          ),
        ),
      ],
    );
  }

  void navigateToApartmentList(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(
          builder: (context) => ApartmentListPage(from: "apartment")),
    );

    setState(() {
      ApartmentData apartmentData = result;

      apartmenrNameController.text = apartmentData.name;
    });
  }

  void navigateToRegionList(BuildContext context, String from) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(
          builder: (context) => ApartmentListPage(
                from: from,
                provinceId: selectedProvinceId.toString(),
              )),
    );

    setState(() {
      if (from == "province") {
        ProvinceListData provinceListData = result;

        selectedProvinceId = provinceListData.provinceId;

        proviceController.text = provinceListData.provinceName;
      } else {
        CityListData cityListData = result;

        cityController.text = cityListData.cityName;
      }
    });
  }
}
