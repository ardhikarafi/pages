import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/locker/locker_data.dart';
import 'package:new_popbox/core/models/payload/popsafe_calculate_payload.dart';
import 'package:new_popbox/core/models/payload/popsafe_history_detail_payload.dart';
import 'package:new_popbox/core/models/payload/popsafe_order_payload.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/popsafe_viewmodel.dart';
import 'package:new_popbox/ui/pages/error_network_page.dart';
import 'package:new_popbox/ui/pages/locker_size.dart';
import 'package:new_popbox/ui/pages/popsafe_location_page.dart';
import 'package:new_popbox/ui/pages/popsafe_success_page.dart';
import 'package:new_popbox/ui/pages/webview_page.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class PopsafePage extends StatefulWidget {
  final String from;
  final String selectedLocker;
  LockerData lockerData;

  PopsafePage({Key key, this.lockerData, this.from, this.selectedLocker});

  @override
  _PopsafePageState createState() => _PopsafePageState();
}

class _PopsafePageState extends State<PopsafePage> {
  NumberFormat formatCurrency;
  //FORM
  final _notesController = TextEditingController();
  final _voucherPromoController = TextEditingController();

  String chooseLockerSize;
  List lockerSizeList;
  LockerData lockerData;
  bool isOnline = false;
  //DUMMY
  int resultPrice = 0;
  int resultPromo = 0;
  int finalPrice = 0;
  String promoName = "x";
  String promoDescription = "";
  bool isLoading = false;
  bool isPromoTyping = false;
  Timer _debounce;
  int countAlert;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        chooseLockerSize = widget.selectedLocker;
        lockerData = widget.lockerData;

        Future.delayed(Duration(milliseconds: 20))
            .whenComplete(() => getPrice());
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    hasNetwork().then((result) {
      setState(() {
        isOnline = result;
      });
    });
    setCurrency();
    return Consumer<PopsafeViewModel>(
      builder: (context, model, _) {
        return Stack(
          children: [
            Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(60.0),
                child: DetailAppBarView(
                  title: AppLocalizations.of(context)
                      .translate(LanguageKeys.deposit),
                ),
              ),
              body: SafeArea(
                child: ListView(
                  children: [
                    CustomWidget().alertInfoPopsafePromo(context),
                    //Container Lokasi
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, top: 25),
                      child: CustomWidget().textBold(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.popboxLocation),
                        PopboxColor.mdBlack1000,
                        9.0.sp,
                        TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 11),
                    Container(
                      margin: EdgeInsets.only(left: 20.0, right: 20.0),
                      height: 48,
                      decoration: BoxDecoration(
                          color: PopboxColor.mdGrey150,
                          border: Border.all(color: PopboxColor.mdGrey300),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: TextButton(
                        onPressed: () {
                          // if (widget.from == "location_detail_page") {
                          // } else {
                          //   setState(() {
                          //     lockerSizeList = [];
                          //   });
                          //   Navigator.of(context)
                          //       .push(MaterialPageRoute(
                          //           builder: (context) =>
                          //               LocationPage(from: "popsafe")))
                          //       .then((value) {
                          //     setState(() {
                          //       lockerData = value;
                          //       chooseLockerSize = null;
                          //       lockerSizeList = lockerData.sizeAvailability;
                          //     });
                          //   });
                          // }
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => PopsafeLocation()))
                              .then((value) {
                            setState(() {
                              lockerData = value;
                              chooseLockerSize = null;
                              lockerSizeList = lockerData.sizeAvailability;
                            });
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                child: Text(
                                  (lockerData != null)
                                      ? lockerData.name
                                      : AppLocalizations.of(context).translate(
                                          LanguageKeys.selectPopsafeLocation),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.0.sp,
                                      fontFamily: "Montserrat"),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.black,
                              size: 15,
                            )
                          ],
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                        ),
                      ),
                    ),
                    //Container Ukuran Loker
                    Container(
                      margin: EdgeInsets.only(left: 20, top: 25),
                      child: CustomWidget().textBold(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.lockerSize),
                          PopboxColor.mdBlack1000,
                          9.0.sp,
                          TextAlign.left),
                    ),
                    SizedBox(height: 11),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      height: 48,
                      decoration: BoxDecoration(
                          color: PopboxColor.mdGrey150,
                          border: Border.all(color: PopboxColor.mdGrey300),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: TextButton(
                        onPressed: () {
                          (lockerData == null)
                              ? CustomWidget().showCustomDialog(
                                  context: context,
                                  msg: AppLocalizations.of(context).translate(
                                    LanguageKeys.popsafeLocationChooseFirst,
                                  ),
                                )
                              : Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => LockerSize(
                                            lockerSizeList:
                                                lockerData.sizeAvailability,
                                          )))
                                  .then((value) {
                                  setState(() {
                                    chooseLockerSize = value;
                                    if (value != null) {
                                      getPrice();
                                    }
                                  });
                                });
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                          backgroundColor: PopboxColor.mdGrey150,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              chooseLockerSize != null
                                  ? chooseLockerSize
                                  : AppLocalizations.of(context).translate(
                                      LanguageKeys.chooseLocker_size),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.0.sp,
                                fontFamily: "Montserrat",
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.black,
                              size: 15,
                            )
                          ],
                        ),
                      ),
                    ),
                    //Barang yang disimpan
                    Container(
                      margin: EdgeInsets.only(left: 20, top: 20),
                      child: CustomWidget().textBold(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.savedItems),
                          PopboxColor.mdBlack1000,
                          9.0.sp,
                          TextAlign.left),
                    ),
                    Container(
                      color: PopboxColor.mdWhite1000,
                      height: 48,
                      margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: TextField(
                        // onChanged: (value) {
                        // if (_debounce?.isActive ?? false) _debounce.cancel();
                        // _debounce = Timer(const Duration(milliseconds: 1500), () {
                        //   onLoading();
                        //   resultPromo = getPromo(_voucherPromoController.text);
                        // });
                        // },
                        controller: _notesController,
                        autocorrect: true,
                        cursorColor: PopboxColor.mdGrey700,
                        style: TextStyle(
                          color: PopboxColor.mdBlack1000,
                          fontSize: 12.0.sp,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: PopboxColor.mdGrey900),
                          filled: true,
                          fillColor: PopboxColor.mdGrey150,
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: PopboxColor.mdGrey300, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: PopboxColor.mdGrey300),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, top: 5),
                      child: CustomWidget().textRegular(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.popsafeExampleItems),
                          PopboxColor.mdGrey700,
                          11.0.sp,
                          TextAlign.left),
                    ),
                    //Hemat dengan Promo
                    Container(
                      margin: EdgeInsets.only(left: 20, top: 25),
                      child: CustomWidget().textBold(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.savingWithPromo),
                          PopboxColor.mdBlack1000,
                          9.0.sp,
                          TextAlign.left),
                    ),
                    Container(
                      color: PopboxColor.mdWhite1000,
                      height: 48,
                      margin: EdgeInsets.only(left: 20, right: 20, top: 8),
                      child: TextField(
                        onChanged: _onChangePromo,
                        controller: _voucherPromoController,
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
                                    _voucherPromoController.clear();
                                    clearPromo(_voucherPromoController.text);
                                  },
                                  child: Image.asset(
                                      "assets/images/ic_popsafe_close.png")),
                              SizedBox(width: 7),
                              InkWell(
                                onTap: () {
                                  // onLoading();
                                  if (lockerData == null) {
                                    CustomWidget().showCustomDialog(
                                      context: context,
                                      msg: AppLocalizations.of(context)
                                          .translate(
                                        LanguageKeys.popsafeLocationRequired,
                                      ),
                                    );
                                  } else if (chooseLockerSize == null) {
                                    CustomWidget().showCustomDialog(
                                      context: context,
                                      msg: AppLocalizations.of(context)
                                          .translate(
                                        LanguageKeys.popsafeSizeRequired,
                                      ),
                                    );
                                  } else {
                                    resultPromo =
                                        getPromo(_voucherPromoController.text);
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: 16, top: 6.0, bottom: 6.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isPromoTyping
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: PopboxColor.mdGrey300, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: PopboxColor.mdGrey300),
                          ),
                        ),
                      ),
                    ),

                    promoName != "" && promoName != "x"
                        ? Container(
                            margin: EdgeInsets.fromLTRB(28.0, 8.0, 16.0, 0.0),
                            child: CustomWidget().textBold(
                                promoName,
                                PopboxColor.mdBlack1000,
                                11.0.sp,
                                TextAlign.left),
                          )
                        : Container(),

                    promoDescription != ""
                        ? Container(
                            margin: EdgeInsets.fromLTRB(28.0, 8.0, 16.0, 0.0),
                            child: CustomWidget().textRegular(
                                promoDescription,
                                PopboxColor.mdBlack1000,
                                11.0.sp,
                                TextAlign.left),
                          )
                        : Container(),
                    //Popbox Deposit
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, top: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                CustomWidget().textMedium(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.popboxDeposit),
                                    PopboxColor.mdGrey900,
                                    11.0.sp,
                                    TextAlign.left),
                                SizedBox(width: 5),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => WebviewPage(
                                          reason: "info_popsafe",
                                          appbarTitle: AppLocalizations.of(
                                                  context)
                                              .translate(LanguageKeys.deposit),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.only(top: 4.0, bottom: 4.0),
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(left: 5, right: 5),
                                      child: Center(
                                        child: CustomWidget().textRegular(
                                            AppLocalizations.of(context)
                                                .translate(
                                                    LanguageKeys.infoShort),
                                            PopboxColor.buttonRedLight,
                                            10.0.sp,
                                            TextAlign.center),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: PopboxColor.buttonRedDark,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          CustomWidget().textRegulerCurrencyPopsafe(
                            formatCurrency.format(
                                SharedPreferencesService().user.balance),
                            PopboxColor.buttonRedLight,
                            FontWeight.w700,
                            11.0.sp,
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    //HARGA TITIP & Promo Voucher
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 16.0),
                      color: PopboxColor.mdGrey200,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomWidget().textRegulerInfoCurrencyPopsafe(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.safePrice),
                                  FontWeight.w400,
                                  10.0.sp),
                              CustomWidget().textRegulerCurrencyPopsafe(
                                formatCurrency.format(resultPrice),
                                PopboxColor.mdBlack1000,
                                FontWeight.w700,
                                10.0.sp,
                              )
                            ],
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomWidget().textRegulerInfoCurrencyPopsafe(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.voucherPromo),
                                    FontWeight.w400,
                                    10.0.sp),
                                CustomWidget().textRegulerCurrencyPopsafe(
                                  formatCurrency.format(resultPromo),
                                  PopboxColor.mdBlack1000,
                                  FontWeight.w700,
                                  10.0.sp,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Term & Condition
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => WebviewPage(
                              reason: "tnc_popsafe",
                              appbarTitle: AppLocalizations.of(context)
                                  .translate(LanguageKeys.termCondition),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
                        color: PopboxColor.mdGrey350,
                        child: RichText(
                          textAlign: TextAlign.left,
                          softWrap: true,
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: 12.0.sp,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: AppLocalizations.of(context)
                                      .translate(LanguageKeys.popsafeTncPart1),
                                  style: TextStyle(
                                    color: PopboxColor.mdGrey900,
                                    fontSize: 10.0.sp,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w500,
                                  )),
                              new TextSpan(
                                text: " " +
                                    AppLocalizations.of(context).translate(
                                        LanguageKeys.popsafeTncPart2),
                                style: TextStyle(
                                  color: PopboxColor.mdBlack1000,
                                  fontSize: 10.0.sp,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 15),
                    //PILIH PEMBAYARAN
                    GestureDetector(
                      onTap: () {
                        if (lockerData == null) {
                          CustomWidget().showCustomDialog(
                            context: context,
                            msg: AppLocalizations.of(context).translate(
                              LanguageKeys.popsafeLocationRequired,
                            ),
                          );
                        } else if (chooseLockerSize == null) {
                          CustomWidget().showCustomDialog(
                            context: context,
                            msg: AppLocalizations.of(context).translate(
                              LanguageKeys.popsafeSizeRequired,
                            ),
                          );
                        } else {
                          (finalPrice <=
                                  SharedPreferencesService().user.balance)
                              ? {
                                  //SUBMIT FORM
                                  // print('===SUBMIT==='),
                                  // print('TOKEN => ' + GlobalVar.API_TOKEN),
                                  // print('Session ID =>' +
                                  //     SharedPreferencesService().user.sessionId),
                                  // print("LOCKER ID : " + lockerData.lockerId),
                                  // print("LOCKER NAME : " + lockerData.name),
                                  // print("UKURAN LOKER : " + chooseLockerSize),
                                  // print("ALAMAT LOKER : " + lockerData.address),
                                  // print('NOTE : ' + _notesController.text),
                                  // print('CODE PROMO : ' + _voucherPromoController.text),

                                  // onLoading(),
                                  submitOrder(),
                                }
                              : {};
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            left: 20.0, right: 20.0, bottom: 20.0),
                        padding: EdgeInsets.only(
                            left: 20, right: 20, bottom: 16.0, top: 16.0),
                        //height: 55,
                        //width: 80.0.w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: (finalPrice <=
                                    SharedPreferencesService().user.balance)
                                ? PopboxColor.popboxRed
                                : PopboxColor.mdGrey300),
                        child: Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomWidget().textBold(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.payNow),
                                  PopboxColor.mdWhite1000,
                                  11.0.sp,
                                  null),
                              CustomWidget().textBold(
                                  formatCurrency.format(finalPrice),
                                  PopboxColor.mdWhite1000,
                                  12.0.sp,
                                  null)
                            ],
                          ),
                        ),
                      ),
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
        );
      },
    );
  }

  //func getPrice from Api Calculate
  void getPrice() {
    if (lockerData != null && lockerData.lockerId != null) {
      FocusScope.of(context).unfocus();
      PopsafeCalculatePayload promoPayload = new PopsafeCalculatePayload()
        ..token = GlobalVar.API_TOKEN
        ..sessionId = SharedPreferencesService().user.sessionId
        ..lockerId = lockerData.lockerId
        ..size = chooseLockerSize;

      final priceModel = Provider.of<PopsafeViewModel>(context, listen: false);
      priceModel.popsafeCalculate(promoPayload, context, onSuccess: (response) {
        setState(() {
          resultPrice = response.data[0].price;
          finalPrice = response.data[0].paidPrice;
          promoName = response.data[0].promoName;
          promoDescription = response.data[0].promoDescription;
        });
      }, onError: (response) {
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
          print("catch");
          CustomWidget().showCustomDialog(
              context: context, msg: "catch : " + e.toString());
        }
      });
      print(resultPrice);
    }
  }

  void clearPromo(String voucherPromo) {
    PopsafeCalculatePayload promoPayload = new PopsafeCalculatePayload()
      ..token = GlobalVar.API_TOKEN
      ..sessionId = SharedPreferencesService().user.sessionId
      ..lockerId = lockerData.lockerId
      ..size = chooseLockerSize
      ..itemDescription = _notesController.text
      ..promoCode = voucherPromo;
    final promoModel = Provider.of<PopsafeViewModel>(context, listen: false);
    promoModel.popsafeCalculate(promoPayload, context, onSuccess: (response) {
      setState(() {
        resultPromo = response.data[0].promoAmount;
        finalPrice = response.data[0].paidPrice;
        promoName = response.data[0].promoName;

        if (promoName == "") {
          promoName = AppLocalizations.of(context)
              .translate(LanguageKeys.promoNotAvailable);
        }
        promoDescription = response.data[0].promoDescription;
      });
    }, onError: (response) {
      try {
        (!isOnline)
            ? Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ErrorNetworkPage()))
            : (response.response.message != "Member Not Found")
                ? CustomWidget().showCustomDialog(
                    context: context, msg: response.response.message)
                : {};
        setState(() {
          promoName = "";
          promoDescription = "";
        });
      } catch (e) {
        setState(() {
          promoName = "";
          promoDescription = "";
        });
      }
    });
  }

  //func voucherPromo
  int getPromo(String voucherPromo) {
    FocusScope.of(context).unfocus();
    if (lockerData == null) {
      setState(() {
        Navigator.pop(context);
        Future.delayed(Duration(milliseconds: 50), () {
          CustomWidget().showCustomDialog(
              context: context,
              msg: AppLocalizations.of(context)
                  .translate(LanguageKeys.lockerIsRequired));
        });
      });

      return 0;
    }

    PopsafeCalculatePayload promoPayload = new PopsafeCalculatePayload()
      ..token = GlobalVar.API_TOKEN
      ..sessionId = SharedPreferencesService().user.sessionId
      ..lockerId = lockerData.lockerId
      ..size = chooseLockerSize
      ..itemDescription = _notesController.text
      ..promoCode = voucherPromo;

    final promoModel = Provider.of<PopsafeViewModel>(context, listen: false);
    promoModel.popsafeCalculate(promoPayload, context, onSuccess: (response) {
      setState(() {
        resultPromo = response.data[0].promoAmount;
        finalPrice = response.data[0].paidPrice;
        promoName = response.data[0].promoName;

        if (promoName == "") {
          promoName = AppLocalizations.of(context)
              .translate(LanguageKeys.promoNotAvailable);
        }

        promoDescription = response.data[0].promoDescription;
      });
    }, onError: (response) {
      try {
        (!isOnline)
            ? Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ErrorNetworkPage()))
            : (response.response.message != "Member Not Found")
                ? CustomWidget().showCustomDialog(
                    context: context, msg: response.response.message)
                : {};

        setState(() {
          promoName = "";
          promoDescription = "";
        });
      } catch (e) {
        setState(() {
          promoName = "";
          promoDescription = "";
        });
        // CustomWidget().showCustomDialog(
        //     context: context, msg: "catch : " + e.toString() + voucherPromo);
      }
    });
    //print(resultPromo);
    return resultPromo;
  }

  //func Order Popsafe
  void submitOrder() {
    PopsafeOrderPayload popsafeOrderPayload = new PopsafeOrderPayload()
      ..token = GlobalVar.API_TOKEN
      ..sessionId = SharedPreferencesService().user.sessionId
      ..lockerId = lockerData.lockerId
      ..lockerSize = chooseLockerSize
      ..size = chooseLockerSize
      ..notes = ""
      ..itemPhoto = ""
      ..autoExtend = 0
      ..promoCode = _voucherPromoController.text
      ..itemDescription = _notesController.text;
    final orderModel = Provider.of<PopsafeViewModel>(context, listen: false);

    orderModel.popsafeOrder(popsafeOrderPayload, context,
        onSuccess: (response) {
      PopsafeHistoryDetailPayload historyDetailPayload =
          new PopsafeHistoryDetailPayload()
            ..sessionId = SharedPreferencesService().user.sessionId
            ..token = GlobalVar.API_TOKEN
            ..invoiceId = response.data.first.invoiceId;
      orderModel.popsafeHistoryDetail(
        historyDetailPayload,
        context,
        onSuccess: (response) {
          setState(() {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => PopsafePageSuccess(
                      popsafeHistoryDetailData: response.data.first),
                ),
                (Route<dynamic> route) => false);
          });
        },
        onError: (response) {},
      );
    }, onError: (response) {
      try {
        (!isOnline)
            ? Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ErrorNetworkPage()))
            : (response.response.message != "Member Not Found")
                ? CustomWidget().showCustomDialog(
                    context: context, msg: response.response.message)
                : CustomWidget().showCustomDialog(
                    context: context, msg: response.response.message);
        setState(() {});
      } catch (e) {
        CustomWidget()
            .showCustomDialog(context: context, msg: "catch : " + e.toString());
      }
    });
  }

  //onLoading
  // void onLoading() {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return Center(
  //           child: SizedBox(
  //               height: 50, width: 50, child: CircularProgressIndicator()),
  //         );
  //       });
  // }

  setCurrency() {
    String localFormat = "";
    if (SharedPreferencesService().locationSelected == "ID") {
      localFormat = 'id_ID';
    } else if (SharedPreferencesService().locationSelected == "MY") {
      localFormat = 'ms_MY';
    } else {
      localFormat = 'fil_PH';
    }
    formatCurrency = new NumberFormat.simpleCurrency(locale: localFormat);
  }

  void _onChangePromo(String inputKeyword) {
    if (inputKeyword.isEmpty) {
      isPromoTyping = false;
    } else {
      isPromoTyping = true;
    }
    setState(() {});
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
