import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/account_maps_data.dart';
import 'package:new_popbox/core/models/payload/address_user_update_payload.dart';
import 'package:new_popbox/core/utils/library.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/pages/account_maps_page.dart';
import 'package:new_popbox/ui/pages/success_new_page.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:sizer/sizer.dart';

import 'account_apartment_page.dart';

class AccountAddressPage extends StatefulWidget {
  final bool isAddressFilled;
  final String type;

  const AccountAddressPage({Key key, this.isAddressFilled = false, this.type})
      : super(key: key);
  @override
  State<AccountAddressPage> createState() => _AccountAddressPageState();
}

class _AccountAddressPageState extends State<AccountAddressPage> {
  //TypeHouse
  String typeHouse;

  TextEditingController administrativeAreaCtr = TextEditingController();
  TextEditingController subAdministrativeAreaCtr = TextEditingController();
  TextEditingController localityCtr = TextEditingController();
  TextEditingController subLocalityCtr = TextEditingController();
  TextEditingController postalCodeCtr = TextEditingController();
  //TypeApartement
  String apartmentUuid;
  TextEditingController nameApartCtr = TextEditingController();
  TextEditingController nameApartOthersCtr = TextEditingController();
  TextEditingController towerCtr = TextEditingController();
  TextEditingController floorCtr = TextEditingController();
  TextEditingController unitCtr = TextEditingController();
  TextEditingController buildTypeCtr = TextEditingController();

  AccountMapsData accountMapsData;
  bool isOther = false;
  SharedPreferencesService sharedPrefService;
  UserLoginData userData;
  String typeOfResidence = "";
  String countryCode = "";
  //InfoApart
  String nameOfApartment = "";
  String tower = "";
  String floor = "";
  String unit = "";
  //Inforumahtapak
  String province = "";
  String city = "";
  String district = "";
  String subDistrict = "";
  String zipCode = "";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      sharedPrefService = await SharedPreferencesService.instance;
      userData = sharedPrefService.user;
      countryCode = userData.country;
      if (userData.accountTypeAddress == "1") {
        setState(() {
          typeOfResidence = AppLocalizations.of(this.context)
              .translate(LanguageKeys.apartment);
          nameOfApartment = userData.accountApartmentName;
          tower = userData.accountTower;
          floor = userData.accountLantai;
          unit = userData.accountUnit;
        });
      } else {
        setState(() {
          typeOfResidence =
              AppLocalizations.of(this.context).translate(LanguageKeys.house);
          province = userData.accountProvince;
          city = userData.accountCity;
          district = userData.accountDistrict;
          subDistrict = userData.accountSubdistrict;
          zipCode = userData.accountZipCode;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAddressFilled == false) {
      return form(context);
    } else {
      if (widget.type == "1") {
        return infoApartment(context);
      } else {
        return infoRumahTapak(context);
      }
    }
  }

  Widget infoApartment(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: GeneralAppBarView(
            title: AppLocalizations.of(context).translate(LanguageKeys.address),
            isButtonBack: true,
          ),
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                SizedBox(height: 20),
                contentData(
                  context: context,
                  title: AppLocalizations.of(context)
                      .translate(LanguageKeys.typeOfResidence),
                  content: AppLocalizations.of(context)
                      .translate(LanguageKeys.apartment),
                  keyword: typeOfResidence,
                ),
                contentData(
                  context: context,
                  title: AppLocalizations.of(context)
                      .translate(LanguageKeys.nameOfCase)
                      .replaceAll(
                          "%s",
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.apartment)),
                  content: nameOfApartment,
                  keyword: "NameOfApartment",
                ),
                contentData(
                  context: context,
                  title: AppLocalizations.of(context)
                      .translate(LanguageKeys.tower),
                  content: tower,
                  keyword: "tower",
                ),
                contentData(
                  context: context,
                  title: AppLocalizations.of(context)
                      .translate(LanguageKeys.floor),
                  content: floor,
                  keyword: "Floor",
                ),
                contentData(
                  context: context,
                  title:
                      AppLocalizations.of(context).translate(LanguageKeys.unit),
                  content: unit,
                  keyword: "Unit",
                ),
              ],
            ),
          ),
        ));
  }

  Widget infoRumahTapak(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: GeneralAppBarView(
            title: AppLocalizations.of(context).translate(LanguageKeys.address),
            isButtonBack: true,
          ),
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                SizedBox(height: 20),
                contentData(
                  context: context,
                  title: AppLocalizations.of(context)
                      .translate(LanguageKeys.typeOfResidence),
                  content: typeOfResidence,
                  keyword: typeOfResidence,
                ),
                contentData(
                  context: context,
                  title: AppLocalizations.of(context)
                      .translate(LanguageKeys.province),
                  content: province,
                  keyword: "Province",
                ),
                contentData(
                  context: context,
                  title:
                      AppLocalizations.of(context).translate(LanguageKeys.city),
                  content: city,
                  keyword: "City",
                ),
                contentData(
                  context: context,
                  title: AppLocalizations.of(context)
                      .translate(LanguageKeys.district),
                  content: district,
                  keyword: "District",
                ),
                contentData(
                  context: context,
                  title: AppLocalizations.of(context)
                      .translate(LanguageKeys.subDistrict),
                  content: subDistrict,
                  keyword: "Sub District",
                ),
                contentData(
                  context: context,
                  title: AppLocalizations.of(context)
                      .translate(LanguageKeys.postalCode),
                  content: zipCode,
                  keyword: "Zip Code",
                ),
              ],
            ),
          ),
        ));
  }

  Widget form(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: GeneralAppBarView(
          title: AppLocalizations.of(context).translate(LanguageKeys.address),
          isButtonBack: true,
        ),
      ),
      body: Consumer<UserViewModel>(
        builder: (context, model, _) {
          return Stack(
            children: [
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 25.0),
                            width: 100.0.w,
                            decoration: BoxDecoration(
                                color: PopboxColor.mdWhite1000,
                                border:
                                    Border.all(color: PopboxColor.mdGrey300),
                                borderRadius: BorderRadius.circular(8.0)),
                            padding:
                                const EdgeInsets.fromLTRB(16.0, 7.0, 16.0, 7.0),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              underline: Container(),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black,
                              ),
                              value: typeHouse,
                              items: <String>[
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.apartment),
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.house),
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                      color: PopboxColor.mdBlack1000,
                                      fontSize: 14,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                              hint: Text(
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.typeOfResidence),
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  color: PopboxColor.mdBlack1000,
                                  fontSize: 14,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onChanged: (String value) {
                                setState(() {
                                  typeHouse = value;
                                });
                              },
                            ),
                          ),
                          (typeHouse ==
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.apartment))
                              ? formApart(context)
                              : (typeHouse ==
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.house))
                                  ? formRumahTapak(context)
                                  : Container()
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: CustomButtonRectangle(
                        bgColor: Color(0xffFF0B09),
                        fontSize: 14,
                        textColor: Colors.white,
                        title: AppLocalizations.of(context)
                            .translate(LanguageKeys.submit),
                        onPressed: () {
                          if (typeHouse ==
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.apartment)) {
                            if (nameApartCtr.text.isEmpty) {
                              CustomWidget().showCustomDialog(
                                context: context,
                                msg: AppLocalizations.of(context)
                                    .translate(
                                      LanguageKeys.caseIsRequired,
                                    )
                                    .replaceAll(
                                        "%1s",
                                        AppLocalizations.of(context)
                                            .translate(LanguageKeys.apartment)),
                              );
                            } else if (towerCtr.text.isEmpty) {
                              CustomWidget().showCustomDialog(
                                context: context,
                                msg: AppLocalizations.of(context)
                                    .translate(
                                      LanguageKeys.caseIsRequired,
                                    )
                                    .replaceAll(
                                        "%1s",
                                        AppLocalizations.of(context)
                                            .translate(LanguageKeys.tower)),
                              );
                            } else if (floorCtr.text.isEmpty) {
                              CustomWidget().showCustomDialog(
                                context: context,
                                msg: AppLocalizations.of(context)
                                    .translate(
                                      LanguageKeys.caseIsRequired,
                                    )
                                    .replaceAll(
                                        "%1s",
                                        AppLocalizations.of(context)
                                            .translate(LanguageKeys.floor)),
                              );
                            } else if (unitCtr.text.isEmpty) {
                              CustomWidget().showCustomDialog(
                                context: context,
                                msg: AppLocalizations.of(context)
                                    .translate(
                                      LanguageKeys.caseIsRequired,
                                    )
                                    .replaceAll(
                                        "%1s",
                                        AppLocalizations.of(context)
                                            .translate(LanguageKeys.unit)),
                              );
                            } else {
                              submit(context);
                            }
                          } else {
                            //Home
                            submit(context);
                          }
                        },
                      ),
                    )
                  ],
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
      ),
    );
  }

  void submit(BuildContext context) {
    var userModel = Provider.of<UserViewModel>(context, listen: false);
    AddressUserUpdatePayload payload;

    //IF Apartment & Value
    if (typeHouse ==
            AppLocalizations.of(context).translate(LanguageKeys.apartment) &&
        !isOther) {
      payload = new AddressUserUpdatePayload()
        ..token = GlobalVar.API_TOKEN
        ..sessionId = userData.sessionId
        ..userId = userData.userId.toString()
        ..typeAddress = "1"
        ..apartmentUuid = apartmentUuid
        ..apartmentName = nameApartCtr.text
        ..tower = towerCtr.text
        ..lantai = floorCtr.text
        ..unit = unitCtr.text;
    } else if (typeHouse ==
            AppLocalizations.of(context).translate(LanguageKeys.apartment) &&
        isOther) {
      payload = new AddressUserUpdatePayload()
        ..token = GlobalVar.API_TOKEN
        ..sessionId = userData.sessionId
        ..userId = userData.userId.toString()
        ..typeAddress = "1"
        ..apartmentName = nameApartOthersCtr.text
        ..tower = towerCtr.text
        ..lantai = floorCtr.text
        ..unit = unitCtr.text
        ..countryCode = countryCode;
    } else {
      payload = new AddressUserUpdatePayload()
        ..token = GlobalVar.API_TOKEN
        ..sessionId = userData.sessionId
        ..userId = userData.userId.toString()
        ..typeAddress = "2"
        ..address = administrativeAreaCtr.text +
            " , " +
            subAdministrativeAreaCtr.text +
            " , " +
            localityCtr.text +
            " , " +
            subLocalityCtr.text +
            " , " +
            postalCodeCtr.text
        ..province = administrativeAreaCtr.text
        ..city = subAdministrativeAreaCtr.text
        ..district = localityCtr.text
        ..subdistrict = subLocalityCtr.text
        ..zipCode = postalCodeCtr.text
        ..countryCode = countryCode;
    }

    userModel.addressUserUpdate(payload, context, onSuccess: (response) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => SuccessNewPage(
                from: "accountaddress",
              )));
    }, onError: (response) {
      CustomWidget()
          .showCustomDialog(context: context, msg: response.response.message);
    });
  }

  Widget contentData(
      {BuildContext context,
      String title,
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
        content =
            AppLocalizations.of(context).translate(LanguageKeys.enterEmail);
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomWidget().textLight(
          title,
          PopboxColor.mdGrey700,
          12,
          TextAlign.left,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 70.0.w,
                child: CustomWidget().textLight(
                  content,
                  PopboxColor.mdBlack1000,
                  14,
                  TextAlign.left,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => AccountAddressPage(
                        isAddressFilled: false,
                      ),
                    ),
                  );
                },
                child: CustomWidget().textMedium(
                  AppLocalizations.of(context).translate(LanguageKeys.change),
                  PopboxColor.blue477FFF,
                  9.0.sp,
                  TextAlign.left,
                ),
              )
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

  Column formApart(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 30.0),
          child: CustomWidget().textFormFieldRegular(
            callBackVoid: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                        builder: (context) => AccountApartmentPage()),
                  )
                  .then((value) => setState(() {
                        isOther = value["isOther"];
                        nameApartCtr.text = value["value"];
                        apartmentUuid = value["apartId"];
                      }));
            },
            readOnly: true,
            controller: nameApartCtr,
            labelText: AppLocalizations.of(context)
                .translate(LanguageKeys.nameOfCase)
                .replaceAll(
                    "%s",
                    AppLocalizations.of(context)
                        .translate(LanguageKeys.apartment)),
          ),
        ),
        (isOther)
            ? Container(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16.0, top: 30.0),
                child: CustomWidget().textFormFieldRegular(
                  readOnly: false,
                  controller: nameApartOthersCtr,
                  labelText: AppLocalizations.of(context)
                      .translate(LanguageKeys.others),
                ),
              )
            : Container(),
        Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 30.0),
          child: CustomWidget().textFormFieldRegular(
              controller: towerCtr,
              labelText:
                  AppLocalizations.of(context).translate(LanguageKeys.tower)),
        ),
        Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 30.0),
          child: CustomWidget().textFormFieldRegular(
              controller: floorCtr,
              labelText:
                  AppLocalizations.of(context).translate(LanguageKeys.floor)),
        ),
        Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 30.0),
          child: CustomWidget().textFormFieldRegular(
              controller: unitCtr,
              labelText:
                  AppLocalizations.of(context).translate(LanguageKeys.unit)),
        ),
      ],
    );
  }

  Column formRumahTapak(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            openMaps(context);
          },
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
            width: 100.0.w,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              gradient: LinearGradient(
                colors: [
                  Color(0xfff7dfbc),
                  Color(0xfffcc0c6),
                ],
                tileMode: TileMode.mirror,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.home_outlined),
                SizedBox(width: 20),
                CustomWidget().textBoldPlus(
                  AppLocalizations.of(context)
                      .translate(LanguageKeys.addressCurrentLocation),
                  PopboxColor.mdBlack1000,
                  14,
                  TextAlign.left,
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 30.0),
          child: CustomWidget().textFormFieldRegular(
            controller: administrativeAreaCtr,
            labelText:
                AppLocalizations.of(context).translate(LanguageKeys.province),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 30.0),
          child: CustomWidget().textFormFieldRegular(
            controller: subAdministrativeAreaCtr,
            labelText:
                AppLocalizations.of(context).translate(LanguageKeys.city),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 30.0),
          child: CustomWidget().textFormFieldRegular(
            controller: localityCtr,
            labelText: AppLocalizations.of(context)
                .translate(LanguageKeys.subDistrict),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 30.0),
          child: CustomWidget().textFormFieldRegular(
            controller: subLocalityCtr,
            labelText: AppLocalizations.of(context)
                .translate(LanguageKeys.subLocality),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 30.0),
          child: CustomWidget().textFormFieldRegular(
              controller: postalCodeCtr,
              labelText: AppLocalizations.of(context)
                  .translate(LanguageKeys.postalCode)),
        ),
      ],
    );
  }

  void openMaps(BuildContext context) async {
    //start devrafi
    final serviceStatus = await Permission.locationWhenInUse.serviceStatus;
    final isGpsOn = serviceStatus == ServiceStatus.enabled;
    if (!isGpsOn) {
      print("Turn on location services berfore request permission");
      //return;
    }
    final status = await Permission.locationWhenInUse.request();
    if (status == PermissionStatus.granted) {
      print("Open Maps Location => Status Permission Granted");
      Navigator.of(context)
          .push(
            MaterialPageRoute(builder: (context) => AccountMapsPage()),
          )
          .then((value) => {
                setState(() {
                  accountMapsData = value;
                  administrativeAreaCtr.text =
                      accountMapsData.administrativeArea;
                  subAdministrativeAreaCtr.text =
                      accountMapsData.subAdministrativeArea;
                  localityCtr.text = accountMapsData.locality;
                  subLocalityCtr.text = accountMapsData.subLocality;
                  postalCodeCtr.text = accountMapsData.postalCode;
                })
              });
    } else if (status == PermissionStatus.denied) {
      print("Open Maps Location => Status Denied");
    } else if (status == PermissionStatus.permanentlyDenied ||
        status == PermissionStatus.undetermined) {
      print("Open Maps Location => Status Permanante");
      await openAppSettings();
    }
  }
}
