import 'dart:async';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:new_popbox/core/bloc/bottom_navigation/bottom_navigation_bloc.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/locker/locker_data.dart';
import 'package:new_popbox/core/models/callback/parcel/parcel_for_you_history_data.dart';
import 'package:new_popbox/core/models/callback/parcel/parcel_history_detail_data.dart';
import 'package:new_popbox/core/models/callback/parcel/unfinish_parcel_data.dart';
import 'package:new_popbox/core/models/callback/popcenter/popcenter_detail_response.dart';
import 'package:new_popbox/core/models/callback/popcenter/popcenter_list_response.dart';
import 'package:new_popbox/core/models/callback/popsafe/popsafe_history_data.dart';
import 'package:new_popbox/core/models/callback/popsafe/popsafe_history_detail_data.dart';
import 'package:new_popbox/core/models/callback/popsafe/popsafe_history_detail_popsafe_data.dart';
import 'package:new_popbox/core/models/callback/popsafe/popsafe_order_data.dart';
import 'package:new_popbox/core/models/callback/popsend/popsend_history_data.dart';
import 'package:new_popbox/core/models/payload/lastmile_extend_payload.dart';
import 'package:new_popbox/core/models/payload/parcel_history_detail_payload.dart';
import 'package:new_popbox/core/models/payload/popcenter_detail_payload.dart';
import 'package:new_popbox/core/models/payload/popsafe_extend_payload.dart';
import 'package:new_popbox/core/models/payload/popsafe_history_detail_payload.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/locker_viewmodel.dart';
import 'package:new_popbox/core/viewmodel/parcel_viewmodel.dart';
import 'package:new_popbox/core/viewmodel/popcenter_viewmodel.dart';
import 'package:new_popbox/core/viewmodel/popsafe_viewmodel.dart';
import 'package:new_popbox/ui/item/transaction_tracking_item.dart';
import 'package:new_popbox/ui/pages/form_reporting_page.dart';
import 'package:new_popbox/ui/pages/home.dart';
import 'package:new_popbox/ui/pages/webview_page.dart';
import 'package:new_popbox/ui/widget/alert_info_rectangle_widget.dart';
import 'package:new_popbox/ui/widget/app_widget.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_dialog_box.dart';

import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:new_popbox/ui/widget/help_view.dart';
import 'package:new_popbox/ui/widget/popsafe_cancel_widget.dart';
import 'package:new_popbox/ui/widget/report_order_problem.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:timelines/timelines.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../core/models/callback/payment/check__compare_status_payment_response.dart';
import '../../core/models/payload/check_status_payment_payload.dart';
import '../../core/viewmodel/collect_payment_viewmodel.dart';
import 'method_payment_page.dart';

class TransactionDetailPage extends StatefulWidget {
  final String transactionType;
  final ParcelForYouHistoryData parcelData;
  final UnfinishParcelData unfinishParcelData;
  final PopsafeHistoryData popsafeData;
  final PopsendHistoryData popsendData;
  final PopsafeOrderData popsafeOrderData;
  final PopsafeHistoryDetailData popsafeHistoryDetailData;
  final PopcenterHistoryData popcenterData;
  final String orderIdNotif;
  final bool isPopNotif;
  final String status;
  final ParcelHistoryDetailData parcelHistoryDetailData;

  const TransactionDetailPage(
      {Key key,
      @required this.transactionType,
      this.parcelData,
      this.popsafeData,
      this.popsendData,
      this.unfinishParcelData,
      this.popsafeOrderData,
      this.popsafeHistoryDetailData,
      this.orderIdNotif,
      this.isPopNotif = false,
      this.popcenterData,
      this.status,
      this.parcelHistoryDetailData})
      : super(key: key);
  @override
  _TransactionDetailPageState createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  String hours = "00";
  String minutes = "00";
  String seconds = "00";
  SharedPreferencesService sharedPreferences;
  String languageCode = "";
  String countryCode = "";
  String parcelId = "";
  String locationId = "";
  double totalPricePPC = 0.0;
  String totalAmount = "";
  int convertedValue = 0;
  bool isPaid = false;

  static const duration = const Duration(seconds: 1);

  bool isActive = true;

  Timer timer;

  String finalDays = "00";
  String finalHours = "00";
  String finalMinutes = "00";
  String finalSeconds = "00";
  int timeDiff = 0;
  //
  PopsafeHistoryDetailData popsafeDataDetail;
  ParcelHistoryDetailData parcelHistoryDetailData;
  PopcenterDetailData popcenterDetailData;
  NumberFormat formatCurrency;
  DataComparePayment dataComparePayment;

  int timeDifference = 0;
  bool isExpandedTransaction = false;
  bool isExpandedTrack = false;
  //Extend
  String _valueExtendReason = "";
  final _noteExtendController = TextEditingController();
  //PARCEL
  int countdownTimeParcel = 0;
  String currencyText = "";
  static RemoteConfig _remoteConfig;
  bool showPopsafe;

  void handleTick(DateTime eventTime, DateTime now) {
    //print("eventTime : " + eventTime.toString());
    //print("now : " + now.toString());
    //print("timeDiff : " + timeDiff.toString());
    //print("isActive : " + isActive.toString());

    if (timeDiff > 0) {
      if (isActive) {
        if (mounted) {
          setState(() {
            if (eventTime != now) {
              timeDiff = timeDiff - 1;
            } else {
              //print('Times up!');
              //Do something
            }

            _printDuration(context, Duration(seconds: timeDiff));
          });
        }
      }
    }
  }

  @override
  void initState() {
    _initializeRemoteConfig();
    print('logy> transactionType: ' + widget.transactionType.toString());

    var popsafeModel = Provider.of<PopsafeViewModel>(context, listen: false);
    var parcelModel = Provider.of<ParcelViewModel>(context, listen: false);
    var popcenterModel =
        Provider.of<PopcenterViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        //Pref
        sharedPreferences = await SharedPreferencesService.instance;
        languageCode = sharedPreferences.languageCode;
        countryCode = sharedPreferences.user.country;
        setCurrency();

        //API
        //new implement check payment first
        if (widget.transactionType == "popsafe") {
          PopsafeHistoryDetailPayload historyDetailPayload =
              new PopsafeHistoryDetailPayload()
                ..sessionId = SharedPreferencesService().user.sessionId
                ..token = GlobalVar.API_TOKEN
                ..invoiceId = widget.isPopNotif
                    ? widget.orderIdNotif
                    : widget.popsafeData.invoiceCode;

          await popsafeModel.popsafeHistoryDetail(
            historyDetailPayload,
            context,
            onSuccess: (response) {
              setState(() {
                try {
                  popsafeDataDetail = response.data.first;
                  final dateCreated =
                      DateTime.parse(popsafeDataDetail.createdAt);
                  final dateNow = DateTime.now();
                  timeDifference = dateNow.difference(dateCreated).inSeconds;
                } catch (e) {}
              });
            },
            onError: (response) {},
          );
        } else if (widget.transactionType == "parcel") {
          print('logy> here load data parcel');
          _loadDataParcel();
        } else if (widget.transactionType == "lastmile" ||
            widget.transactionType == "fnb") {
          print('logy> here1');
          ParcelHistoryDetailPayload historyDetailPayload =
              new ParcelHistoryDetailPayload()
                ..sessionId = SharedPreferencesService().user.sessionId
                ..token = GlobalVar.API_TOKEN
                ..orderId = widget.orderIdNotif;
          await parcelModel.parcelHistoryDetail(historyDetailPayload, context,
              onSuccess: (response) {
            setState(() {
              parcelHistoryDetailData = response.data.first;
            });
          }, onError: (response) {});
        } else if (widget.transactionType == "popcenter") {
          PopcenterDetailPayload popcenterDetailPayload =
              new PopcenterDetailPayload()
                ..authorization = GlobalVar.API_TOKEN_POPCENTER
                ..uuidInbound = widget.isPopNotif
                    ? widget.orderIdNotif
                    : widget.popcenterData.inboundUuid;
          await popcenterModel.popcenterDetail(popcenterDetailPayload, context,
              onSuccess: (response) {
            setState(() {
              popcenterDetailData = response.data;
            });
          }, onError: (response) {});
        } else if (widget.transactionType == "unfinish_parcel") {
          ParcelHistoryDetailPayload historyDetailPayload =
              new ParcelHistoryDetailPayload()
                ..sessionId = SharedPreferencesService().user.sessionId
                ..token = GlobalVar.API_TOKEN
                ..orderId = widget.unfinishParcelData.parcelId;
          await parcelModel.parcelHistoryDetail(historyDetailPayload, context,
              onSuccess: (response) {
            setState(() {
              parcelHistoryDetailData = response.data.first;
            });
          }, onError: (response) {});
        }

        String expiryTime = "";
        if (widget.transactionType == "parcel") {
          if (widget.parcelData.overdueTime != null) {
            expiryTime = widget.parcelData.overdueTime;
          }
        } else if (widget.transactionType == "unfinish_parcel") {
          expiryTime = widget.unfinishParcelData.overdueTime;
        } else if (widget.transactionType == "popsafe") {
          expiryTime = widget.popsafeData.expiredTime;
        } else if (widget.transactionType == "popsafe_success") {
        } else {}
        if (expiryTime != null && expiryTime != "") {
          // String dateNow =
          //     DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now());
          // //String dateNow = "2019-08-04 17:52:50";
          // //print("dateNow : " + DateTime.parse(dateNow).toString());
          // //print("dateExp : " + DateTime.parse(expiryTime).toString());

          // String difference =
          //     "${DateTime.parse(expiryTime).difference(DateTime.parse(dateNow)).inSeconds}";
          // //print("difference : " + difference);

          // if (int.tryParse(difference) > 0) {
          //   _printDuration(
          //       context, Duration(seconds: int.tryParse(difference)));
          // }

          // timeDiff = int.tryParse(difference);

          // if (timer == null) {
          //   timer = Timer.periodic(duration, (Timer t) {
          //     handleTick(DateTime.parse(expiryTime), DateTime.parse(dateNow));
          //   });
          // }
        }
      },
    );

    super.initState();
  }

  String _printDuration(BuildContext context, Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (mounted) {
      setState(() {
        finalHours = twoDigits(duration.inHours);
        finalMinutes = twoDigitMinutes;
        finalSeconds = twoDigitSeconds;
      });
    }
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    // return AppLocalizations.of(context)
    //     .translate(LanguageKeys.daysHours)
    //     .replaceAll('%1s', finalHours)
    //     .replaceAll('%2s', finalMinutes);
  }

  String getDaysHours(BuildContext context, Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitHours = twoDigits(duration.inHours.remainder(24));
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (mounted) {
      setState(() {
        finalDays = twoDigits(duration.inDays);
        finalHours = twoDigitHours;
        finalMinutes = twoDigitMinutes;
        finalSeconds = twoDigitSeconds;
      });
    }

    return AppLocalizations.of(context)
        .translate(LanguageKeys.daysHoursMinutes)
        .replaceAll('%1s', finalDays)
        .replaceAll('%2s', finalHours)
        .replaceAll('%3s', finalMinutes);
  }

  _initializeRemoteConfig() async {
    if (_remoteConfig == null || showPopsafe == null) {
      _remoteConfig = await RemoteConfig.instance;
      await _fetchRemoteConfig();
    }

    setState(() {});
  }

  Future<void> _fetchRemoteConfig() async {
    try {
      await _remoteConfig.fetch(expiration: const Duration(minutes: 1));
      await _remoteConfig.activateFetched();
      setState(() {
        showPopsafe = _remoteConfig.getBool('pb_v3_popsafe');
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  void showPopsafeInfo({context}) {
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
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //TITLE
                  Image.asset("assets/images/ic_hand_popsafe.png"),
                  CustomWidget().textBoldPlus(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.onDevelopment),
                      PopboxColor.mdBlack1000,
                      16,
                      TextAlign.center),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: CustomWidget().textRegular(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.onDevelopmentNotes),
                        PopboxColor.mdBlack1000,
                        14,
                        TextAlign.center),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin:
                          const EdgeInsets.only(left: 23, right: 23, top: 35),
                      child: CustomButtonRectangle(
                        bgColor: PopboxColor.red,
                        fontSize: 14,
                        textColor: Colors.white,
                        title: AppLocalizations.of(context)
                            .translate(LanguageKeys.understand),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      callCsBottomSheet(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 32.0),
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
                                      LanguageKeys.callPopboxCustomerService),
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
            ),
          );
        }).whenComplete(() => null);
  }

  //box hours minutes days
  Widget getDaysHoursMinutes(BuildContext context, Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitHours = twoDigits(duration.inHours.remainder(24));
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (mounted) {
      setState(() {
        finalDays = twoDigits(duration.inDays);
        finalHours = twoDigitHours;
        finalMinutes = twoDigitMinutes;
        finalSeconds = twoDigitSeconds;
      });
    }

    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              child: Center(
                child: CustomWidget().textBoldPlus(
                    finalDays, PopboxColor.mdWhite1000, 12, TextAlign.center),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Color(0xff477FFF),
              ),
            ),
            CustomWidget().textBold(
                AppLocalizations.of(context).translate(LanguageKeys.day),
                Color(0xff949494),
                9,
                TextAlign.center),
          ],
        ),
        SizedBox(width: 6),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              child: Center(
                child: CustomWidget().textBoldPlus(
                    finalHours, PopboxColor.mdWhite1000, 12, TextAlign.center),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Color(0xff477FFF),
              ),
            ),
            CustomWidget().textBold(
                AppLocalizations.of(context).translate(LanguageKeys.hours),
                Color(0xff949494),
                9,
                TextAlign.center),
          ],
        ),
        SizedBox(width: 6),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              child: Center(
                child: CustomWidget().textBoldPlus(finalMinutes,
                    PopboxColor.mdWhite1000, 12, TextAlign.center),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Color(0xff477FFF),
              ),
            ),
            CustomWidget().textBold(
                AppLocalizations.of(context).translate(LanguageKeys.minutes),
                Color(0xff949494),
                9,
                TextAlign.center),
          ],
        ),
      ],
    );
  }

  Future<void> _refreshPopsafe() async {
    var popsafeModel = Provider.of<PopsafeViewModel>(context, listen: false);

    PopsafeHistoryDetailPayload historyDetailPayload =
        new PopsafeHistoryDetailPayload()
          ..sessionId = SharedPreferencesService().user.sessionId
          ..token = GlobalVar.API_TOKEN
          ..invoiceId = widget.popsafeData.invoiceCode;

    await popsafeModel.popsafeHistoryDetail(
      historyDetailPayload,
      context,
      onSuccess: (response) {
        setState(() {
          try {
            popsafeDataDetail = response.data.first;
          } catch (e) {}
        });
      },
      onError: (response) {},
    );

    Navigator.of(this.context).pushReplacement(MaterialPageRoute(
      builder: (context) => TransactionDetailPage(
          transactionType: 'popsafe', popsafeData: widget.popsafeData),
    ));
  }

  Future<void> _refreshParcel() async {
    var parcelModel = Provider.of<ParcelViewModel>(context, listen: false);
    ParcelHistoryDetailPayload historyDetailPayload =
        new ParcelHistoryDetailPayload()
          ..sessionId = SharedPreferencesService().user.sessionId
          ..token = GlobalVar.API_TOKEN
          ..orderId = widget.parcelData.id;
    await parcelModel.parcelHistoryDetail(historyDetailPayload, context,
        onSuccess: (response) {
      setState(() {
        parcelHistoryDetailData = response.data.first;
      });
    }, onError: (response) {});

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TransactionDetailPage(
            transactionType: 'parcel', parcelData: widget.parcelData),
      ),
    );
  }

  Future<void> _refreshPopcenter() async {
    var popcenterModel =
        Provider.of<PopcenterViewModel>(context, listen: false);
    PopcenterDetailPayload popcenterDetailPayload = new PopcenterDetailPayload()
      ..authorization = GlobalVar.API_TOKEN_POPCENTER
      ..uuidInbound = widget.isPopNotif
          ? widget.orderIdNotif
          : widget.popcenterData.inboundUuid;
    await popcenterModel.popcenterDetail(popcenterDetailPayload, context,
        onSuccess: (response) {
      setState(() {
        popcenterDetailData = response.data;
      });
    }, onError: (response) {});
  }

  @override
  void dispose() {
    try {
      timer.cancel();
    } catch (e) {}

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.transactionType == "popsafe_success" ||
              widget.transactionType == "popsafe_cancel_success" ||
              widget.transactionType == "popsafe_extend_success")
          ? PreferredSize(
              preferredSize: Size.fromHeight(60.0),
              child: AppBarViewWithNavigator(
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.transactionDetail),
                from: "popsafe_success",
              ),
            )
          : PreferredSize(
              preferredSize: Size.fromHeight(60.0),
              child: DetailAppBarView(
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.transactionDetail),
              ),
            ),
      body: SafeArea(
        child: detailView(
            context,
            widget.transactionType,
            parcelHistoryDetailData,
            widget.unfinishParcelData,
            popsafeDataDetail,
            widget.popsafeHistoryDetailData,
            popcenterDetailData,
            dataComparePayment),
      ),
    );
  }

  Widget detailView(
    BuildContext context,
    String transactionType,
    ParcelHistoryDetailData parcelHistoryDetailData,
    UnfinishParcelData unfinishParcelData,
    PopsafeHistoryDetailData popsafeDataDetail,
    PopsafeHistoryDetailData popsafeDataDetailSuccess,
    PopcenterDetailData popcenterDetailData,
    DataComparePayment dataComparePayment,
  ) {
    if (transactionType == "parcel" ||
        transactionType == "lastmile" ||
        transactionType == "fnb") {
      return parcelViewNew(
          context, parcelHistoryDetailData, dataComparePayment);
    } else if (transactionType == "unfinish_parcel") {
      return unfinishParcelViewNew(
          context, unfinishParcelData, parcelHistoryDetailData);
    } else if (transactionType == "popsafe") {
      return popsafeViewNew(context, popsafeDataDetail);
    } else if (transactionType == "popsafe_success" ||
        transactionType == "popsafe_cancel_success" ||
        transactionType == "popsafe_extend_success") {
      return popsafeSuccessViewNew(context, popsafeDataDetailSuccess);
    } else if (transactionType == "popcenter") {
      return popcenterView(context, popcenterDetailData);
    } else {
      // return popsendView(context);
    }
  }

  Widget originDestinationView(
      {Key key,
      @required BuildContext context,
      @required String title,
      @required String lockerName,
      @required bool showConnector,
      @required Color dotColor}) {
    return Row(
      children: [
        SizedBox(
          height: 110.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TimelineNode(
                indicatorPosition: 0,
                indicator: DotIndicator(
                  color: dotColor,
                ),
                endConnector: showConnector
                    ? DashedLineConnector(
                        dash: 16.0,
                        color: PopboxColor.mdGrey400,
                        gap: 4.0,
                        endIndent: 4.0,
                        indent: 4.0,
                        thickness: 4.0,
                      )
                    : null,
                //endConnector: SolidLineConnector(),
              ),
              Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget().textBold(
                      title,
                      PopboxColor.mdGrey800,
                      13.0.sp,
                      TextAlign.left,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: CustomWidget().textBold(
                        lockerName,
                        PopboxColor.mdBlack1000,
                        14.0.sp,
                        TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: CustomWidget().textRegular(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.seeLocation),
                        PopboxColor.popboxRed,
                        12.0.sp,
                        TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget trackingView(
      {Key key,
      @required BuildContext context,
      @required String title,
      @required String lockerName,
      @required bool showConnector,
      @required Color dotColor,
      @required Color buttonBackground}) {
    return Row(
      children: [
        SizedBox(
          height: 100.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TimelineNode(
                indicatorPosition: 0,
                indicator: DotIndicator(
                  color: dotColor,
                ),
                endConnector: showConnector
                    ? SolidLineConnector(
                        color: PopboxColor.mdGrey400,
                        endIndent: 4.0,
                        indent: 4.0,
                        thickness: 2.0,
                      )
                    : null,
                //endConnector: SolidLineConnector(),
              ),
              Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomButtonGeneral(
                          onPressed: () {},
                          title: title,
                          bgColor: buttonBackground,
                          textColor: PopboxColor.mdWhite1000,
                          fontSize: 7.0.sp,
                          height: 30.0,
                          borderColor: buttonBackground,
                          width: 100.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: CustomWidget().textMedium(
                            "2020-05-21 17:00:00",
                            PopboxColor.mdGrey500,
                            12.0.sp,
                            TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: CustomWidget().textMediumProduct(
                        lockerName,
                        PopboxColor.mdGrey900,
                        13.0.sp,
                        5,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget trackingViewPopSafe(
      {Key key,
      @required BuildContext context,
      @required String status,
      @required String datetime,
      @required bool showConnector,
      @required Color dotColor,
      @required Color buttonBackground}) {
    return Container(
      padding: EdgeInsets.only(bottom: 10.0),
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(left: 16.0, right: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 4.0),
                child: TimelineNode(
                  indicatorPosition: 0,
                  indicator: DotIndicator(
                    color: dotColor,
                    size: 10,
                  ),
                  endConnector: showConnector
                      ? SolidLineConnector(
                          color: PopboxColor.mdGrey300,
                          endIndent: 0.0,
                          indent: 4.0,
                          thickness: 1.0,
                        )
                      : null,
                  //endConnector: SolidLineConnector(),
                ),
              ),
              SizedBox(width: 7.0),
              Container(
                padding: EdgeInsets.only(
                    top: 3.0, bottom: 3.0, left: 10.0, right: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.amber,
                ),
                child: Text(
                  status,
                  style: TextStyle(
                      fontSize: 8.0.sp, color: PopboxColor.mdWhite1000),
                ),
              ),
              SizedBox(width: 2.0),
              CustomWidget().textMedium(
                  datetime, PopboxColor.mdGrey180, 10.0.sp, TextAlign.left),
            ],
          ),
          SizedBox(height: 4.0),
          Row(
            children: [
              SizedBox(width: 7.0),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30.0.w,
                          child: CustomWidget().textMedium(
                              status.toString() + " ",
                              PopboxColor.mdBlack1000,
                              10.0.sp,
                              TextAlign.left),
                        ),
                        SizedBox(width: 5.0),
                        Container(
                          width: 40.0.w,
                          child: CustomWidget().textMedium(datetime,
                              PopboxColor.mdBlack1000, 10.0.sp, TextAlign.left),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget trackingParcelWidget({List<History> parcelHistory}) {
    List<Widget> trackingWidget = [];

    if (parcelHistory != null && parcelHistory.length > 0) {
      for (var i = 0; i < parcelHistory.length; i++) {
        History historyDetailParcelData = parcelHistory[i];

        bool showConnector = false;
        if (i < parcelHistory.length - 1) {
          showConnector = true;
        }

        trackingWidget.add(trackingViewPopSafe(
            context: context,
            status: AppLocalizations.of(context)
                .translate(historyDetailParcelData.status
                    .replaceAll(" ", "")
                    .toLowerCase())
                .toUpperCase(),
            datetime: getFormattedDateShort(historyDetailParcelData.updated),
            showConnector: showConnector,
            dotColor: PopboxColor.popboxRed,
            buttonBackground: PopboxColor.popboxRed));
      }
    }

    return Column(
      children: trackingWidget,
    );
  }

  Widget trackingPopsafeWidget(
      {List<PopsafeHistoryDetailPopSafeData> popsafeHistory}) {
    List<Widget> trackingWidget = [];

    if (popsafeHistory != null && popsafeHistory.length > 0) {
      for (var i = 0; i < popsafeHistory.length; i++) {
        PopsafeHistoryDetailPopSafeData historyDetailPopSafeData =
            popsafeHistory[i];

        bool showConnector = false;
        if (i < popsafeHistory.length - 1) {
          showConnector = true;
        }

        trackingWidget.add(trackingViewPopSafe(
            context: context,
            status: AppLocalizations.of(context)
                .translate(historyDetailPopSafeData.status
                    .replaceAll(" ", "")
                    .toLowerCase())
                .toUpperCase(),
            datetime: getFormattedDateShort(historyDetailPopSafeData.createdAt),
            showConnector: showConnector,
            dotColor: PopboxColor.popboxRed,
            buttonBackground: PopboxColor.popboxRed));
      }
    }

    return Column(
      children: trackingWidget,
    );
  }

  Widget parcelView(BuildContext context, ParcelForYouHistoryData data) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: 16.0, top: 16.0, right: 16.0, bottom: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              new Container(
                margin: EdgeInsets.only(left: 0.0, right: 0.0, bottom: 30.0),
                decoration: new BoxDecoration(
                    color: PopboxColor.popboxPrimaryRed,
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0),
                      bottomLeft: const Radius.circular(10.0),
                      bottomRight: const Radius.circular(10.0),
                    )),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 90.0.w,
                    //maxWidth: 300.0,
                    minHeight: 30.0,
                    maxHeight: 110.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialogBox(
                                    title: data.pin,
                                  );
                                });
                          },
                          child: QrImage(
                            data: "AMBIL#" + data.pin,
                            version: QrVersions.auto,
                            size: 70,
                            gapless: false,
                            padding: EdgeInsets.all(4.0),
                            backgroundColor: PopboxColor.mdWhite1000,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomWidget().textRegular(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.collectionCode),
                                  PopboxColor.mdWhite1000,
                                  8.0.sp,
                                  TextAlign.left),
                              CustomWidget().textBold(
                                data.pin,
                                PopboxColor.mdWhite1000,
                                16.0.sp,
                                TextAlign.left,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              onlyTextContent(
                  context: context,
                  title: AppLocalizations.of(context)
                      .translate(LanguageKeys.receiptNo),
                  content: data.orderNumber,
                  canCopy: true),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Divider(
                  height: 1.0,
                  color: Colors.grey,
                ),
              ),
              onlyTextContent(
                  context: context,
                  title: AppLocalizations.of(context)
                      .translate(LanguageKeys.status),
                  content: AppLocalizations.of(context)
                      .translate(data.status.replaceAll(" ", "").toLowerCase())
                      .toUpperCase(),
                  contentColor: PopboxColor.popboxRed),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Divider(
                  height: 1.0,
                  color: Colors.grey,
                ),
              ),
              textContentLocation(
                context: context,
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.location),
                content: data.locker,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Divider(
                  height: 1.0,
                  color: Colors.grey,
                ),
              ),
              onlyTextContent(
                context: context,
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.codeValidityLimit),
                content: (data.overdueTime != null && data.overdueTime != '')
                    ? getFormattedDate(data.overdueTime)
                    : '-',
              ),
            ],
          ),
        ),

        //REPORT FORM
        InkWell(
          onTap: () {
            print("Trans Detail => go => Form User report");
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => (Platform.isAndroid)
                      ? FormReportingPage(
                          parcelData: data,
                          reason: "Parcel",
                          type: "Collection")
                      : {
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => setState(() {
                                    context.read<BottomNavigationBloc>().add(
                                          PageTapped(index: 2),
                                        );
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (c) => Home()),
                                        (route) => false);
                                  }))
                        }),
            );
          },
          child: ReportOrderProblem(
            imageUrl: "assets/images/ic_question_green.png",
            title: AppLocalizations.of(context)
                .translate(LanguageKeys.askProblemOrder),
            subTitle: AppLocalizations.of(context)
                .translate(LanguageKeys.callPopboxCustomerService),
            bgColor: PopboxColor.mdYellowA500,
          ),
        ),
      ],
    );
  }

  Widget unfinishParcelView(BuildContext context, UnfinishParcelData data) {
    //DATETIME PARSE OVERDUETIME
    final dateNowDateTime = DateTime.now();
    DateTime overdueTime =
        DateFormat("dd MMM yyy hh:mm:ss").parse(data.overdueTime);
    //DATE TIME DIFFERENCE
    DateTime now = DateTime.now();
    String dateTimeNowFormated = DateFormat('dd MMM yyyy HH:mm:ss').format(now);
    final formatedTime = DateFormat('dd MMM yyyy HH:mm:ss');
    final starttime = formatedTime.parse(data.storeTime);
    final nowtime = formatedTime.parse(dateTimeNowFormated);
    final diffDetik = nowtime.difference(starttime).inSeconds;
    String depositTime = getDaysHours(context, Duration(seconds: diffDetik));

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: 16.0, top: 16.0, right: 16.0, bottom: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              new Container(
                margin: EdgeInsets.only(left: 0.0, right: 0.0, bottom: 30.0),
                decoration: new BoxDecoration(
                    color: PopboxColor.popboxPrimaryRed,
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0),
                      //perubahan rounded
                      bottomLeft: const Radius.circular(10.0),
                      bottomRight: const Radius.circular(10.0),
                    )),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 90.0.w,
                    //maxWidth: 300.0,
                    minHeight: 30.0,
                    maxHeight: 110.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialogBox(
                                    title: data.pinCode,
                                  );
                                });
                          },
                          child: QrImage(
                            data: "AMBIL#" + data.pinCode,
                            version: QrVersions.auto,
                            size: 70,
                            gapless: false,
                            padding: EdgeInsets.all(4.0),
                            backgroundColor: PopboxColor.mdWhite1000,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomWidget().textRegular(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.collectionCode),
                                  PopboxColor.mdWhite1000,
                                  8.0.sp,
                                  TextAlign.left),
                              CustomWidget().textBold(
                                data.pinCode,
                                PopboxColor.mdWhite1000,
                                15.0.sp,
                                TextAlign.left,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              onlyTextContent(
                  context: context,
                  title: AppLocalizations.of(context)
                      .translate(LanguageKeys.receiptNo),
                  content: data.awb,
                  canCopy: true),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Divider(
                  height: 1.0,
                  color: Colors.grey,
                ),
              ),
              //devrafi
              onlyTextContent(
                  context: context,
                  title: AppLocalizations.of(context)
                      .translate(LanguageKeys.status),
                  content: (overdueTime.isBefore(dateNowDateTime))
                      ? AppLocalizations.of(context)
                          .translate(LanguageKeys.overdue)
                          .toUpperCase()
                      : AppLocalizations.of(context)
                          .translate(
                              data.status.replaceAll(" ", "").toLowerCase())
                          .toUpperCase(),
                  contentColor: Colors.amber),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Divider(
                  height: 1.0,
                  color: Colors.grey,
                ),
              ),
              textContentLocation(
                context: context,
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.location),
                content: data.location,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Divider(
                  height: 1.0,
                  color: Colors.grey,
                ),
              ),
              onlyTextContent(
                context: context,
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.deliveryTime),
                content: getFormattedDate(data.storeTime),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Divider(
                  height: 1.0,
                  color: Colors.grey,
                ),
              ),
              onlyTextContent(
                context: context,
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.takeTime),
                content: (data.takeTime != null && data.takeTime != '')
                    ? getFormattedDate(data.takeTime)
                    : '-',
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Divider(
                  height: 1.0,
                  color: Colors.grey,
                ),
              ),
              onlyTextContent(
                context: context,
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.codeValidityLimit),
                content: getFormattedDate(data.overdueTime),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Divider(
                  height: 1.0,
                  color: Colors.grey,
                ),
              ),

              onlyTextContent(
                context: context,
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.depositDuration),
                content: getFormattedDate(depositTime),
              ),
            ],
          ),
        ),
        //REPORT FORM
        InkWell(
          onTap: () {
            print("Trans Detail => go => Form User report");
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => (Platform.isAndroid)
                      ? FormReportingPage(
                          unfinishParcelData: data,
                          reason: "Unfinish",
                          type: "Collection",
                        )
                      : {
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => setState(() {
                                    context.read<BottomNavigationBloc>().add(
                                          PageTapped(index: 2),
                                        );
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (c) => Home()),
                                        (route) => false);
                                  }))
                        }),
            );
          },
          child: ReportOrderProblem(
            imageUrl: "assets/images/ic_question_green.png",
            title: AppLocalizations.of(context)
                .translate(LanguageKeys.askProblemOrder),
            subTitle: AppLocalizations.of(context)
                .translate(LanguageKeys.callPopboxCustomerService),
            bgColor: PopboxColor.mdYellowA500,
          ),
        ),
      ],
    );
  }

  Widget unfinishParcelViewNew(BuildContext context, UnfinishParcelData data,
      ParcelHistoryDetailData parcelHistoryDetailData) {
    print('log: view unfinishParcelViewNew');
    setCurrency();
    //DATE TIME DIFFERENCE
    int countStoreDay = 0;
    int countRemainingFreeDay = 0;
    double xFreeDays = 0;
    double pricePPC = 0;
    bool isFree = false;

    if (data != null) {
      DateTime now = DateTime.now();
      String dateTimeNowFormated =
          DateFormat('dd MMM yyyy HH:mm:ss').format(now);
      final formatedTime = DateFormat('dd MMM yyyy HH:mm:ss');
      final nowtime = formatedTime.parse(dateTimeNowFormated);

      countStoreDay =
          nowtime.difference(formatedTime.parse(data.storeTime)).inDays;

      if (data.ppcInfo.status == "ppc") {
        if (countryCode == "MY") {
          if (double.parse(data.ppcInfo.priceOverdue) == 0) {
          } else if (double.parse(data.ppcInfo.priceOverdue) > 0 &&
              data.status != "OVERDUE") {
          } else if (double.parse(data.ppcInfo.priceOverdue) > 0 &&
              data.status == "OVERDUE") {
          } else {
            //nothing
          }
        } else {
          countRemainingFreeDay = formatedTime
              .parse(data.ppcInfo.freeUntil)
              .difference(nowtime)
              .inSeconds;
          print("debug rafi ==> " + countRemainingFreeDay.toString());
          countdownTimeParcel = formatedTime
              .parse(data.ppcInfo.freeUntil)
              .difference(nowtime)
              .inSeconds;
        }

        if (data.ppcInfo.ppcType == "dinamic") {
          if (data.status == "COMPLETED" ||
              data.status == "OPERATOR_TAKEN" ||
              data.status == "COURIER_TAKEN") {
            xFreeDays = (formatedTime
                    .parse(data.takeTime)
                    .difference(formatedTime.parse(data.storeTime))
                    .inDays) -
                data.ppcInfo.freeDays.toDouble() +
                1;
          } else {
            xFreeDays = (nowtime
                    .difference(formatedTime.parse(data.storeTime))
                    .inDays) -
                data.ppcInfo.freeDays.toDouble() +
                1;
          }

          if (xFreeDays <= 0) {
            isFree = true;
          } else if (xFreeDays > data.ppcInfo.maxDay) {
            isFree = false;
            // pricePPC = (data.ppcInfo.maxDay - data.ppcInfo.freeDays) *
            //     double.parse(data.ppcInfo.pricePerDay); //dibulatkanUP
            var priceA = ((nowtime
                            .difference(formatedTime.parse(data.storeTime))
                            .inHours -
                        data.ppcInfo.freeDays) /
                    24)
                .ceilToDouble();
            if (priceA > data.ppcInfo.maxDay) {
              pricePPC =
                  data.ppcInfo.maxDay * double.parse(data.ppcInfo.pricePerDay);
            } else if (priceA < data.ppcInfo.maxDay) {
              pricePPC = priceA * double.parse(data.ppcInfo.pricePerDay);
            }

            print("CEK DEV ${pricePPC.toString()}");
            print("CEK DEV2 ${priceA.toString()}");
          } else {
            isFree = false;
            pricePPC = xFreeDays * double.parse(data.ppcInfo.pricePerDay);
          }
        } else if (data.ppcInfo.ppcType == "fixed" ||
            data.ppcInfo.ppcType == "flat") {
          if (data.ppcInfo.freeDays < 1) {
            if (data.status != "OVERDUE") {
              pricePPC = double.parse(data.ppcInfo.priceInstore);
            } else if (data.status == "OVERDUE") {
              pricePPC = double.parse(data.ppcInfo.priceInstore) +
                  double.parse(data.ppcInfo.priceOverdue);
            }
          } else {
            if (countStoreDay <= data.ppcInfo.freeDays) {
              pricePPC = 0;
            } else {
              if (data.status != "OVERDUE") {
                pricePPC = double.parse(data.ppcInfo.priceInstore);
              } else if (data.status == "OVERDUE") {
                pricePPC = double.parse(data.ppcInfo.priceInstore) +
                    double.parse(data.ppcInfo.priceOverdue);
              }
            }
          }
        } else {
          //else
        }

        if (countdownTimeParcel < 0) {
          countdownTimeParcel = 0;
        }
      }
      //NO PPC
      if (data.ppcInfo.status == "no_ppc") {
        isFree = true;
        countdownTimeParcel =
            formatedTime.parse(data.overdueTime).difference(nowtime).inSeconds;
        if (countdownTimeParcel < 0) {
          countdownTimeParcel = 0;
        }
      } else if ((double.parse(data.ppcInfo.priceOverdue) > 0 &&
          data.status != "OVERDUE")) {
        countdownTimeParcel =
            formatedTime.parse(data.overdueTime).difference(nowtime).inSeconds;
        if (countdownTimeParcel < 0) {
          countdownTimeParcel = 0;
        }
      } else {}
      //
      if (data.status == "TAKEN" || data.status == "COMPLETED") {
        countdownTimeParcel = 0;
      }
    }

    if (data != null && parcelHistoryDetailData != null) {
      if (data.type == "lastmile") {
        return RefreshIndicator(
          onRefresh: _refreshParcel,
          child: Stack(
            children: [
              ListView(scrollDirection: Axis.vertical, children: [
                Column(
                  children: [
                    SizedBox(height: 20.0),
                    //ALERT
                    RegExp(r'WAREHOUSE|warehouse').hasMatch(data.status)
                        ? Container()
                        : (data.ppcInfo.status == "no_ppc" &&
                                data.status == "OVERDUE")
                            ? Column(
                                children: [
                                  AlertInfoRectangleWidget(
                                    text: AppLocalizations.of(context)
                                        .translate(
                                            LanguageKeys.popsafeAlertOverdue),
                                    bgColor: Color(0xffFFCECE),
                                    textColor: Color(0xffFF0B09),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 15,
                                        bottom: 15),
                                    margin: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 10,
                                        bottom: 10),
                                    decoration: BoxDecoration(
                                      color: Color(0xffFFF3E0),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: CustomWidget().googleFontRobboto(
                                      AppLocalizations.of(context).translate(
                                          LanguageKeys
                                              .notesPopsafeTransDetailisOverdue),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                      color: Color(0xffE38800),
                                      textAlign: TextAlign.left,
                                    ),
                                  )
                                ],
                              )
                            : (data.status == "COMPLETED")
                                ? AlertInfoRectangleWidget(
                                    text: AppLocalizations.of(context)
                                        .translate(LanguageKeys
                                            .popcenterAlertOutbound),
                                    bgColor: Color(0xffCBF1E4),
                                    textColor: Color(0xff1CAC77),
                                  )
                                : (data.status == "COURIER_TAKEN" ||
                                        data.status == "OPERATOR_TAKEN")
                                    ? Column(
                                        children: [
                                          AlertInfoRectangleWidget(
                                            text: AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .popsafeAlertOverdue),
                                            bgColor: Color(0xffFFCECE),
                                            textColor: Color(0xffFF0B09),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                                top: 15,
                                                bottom: 15),
                                            margin: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                                top: 10,
                                                bottom: 10),
                                            decoration: BoxDecoration(
                                              color: Color(0xffFFF3E0),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: CustomWidget()
                                                .googleFontRobboto(
                                              AppLocalizations.of(context)
                                                  .translate(LanguageKeys
                                                      .notesPopsafeTransDetailisOverdue),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10,
                                              color: Color(0xffE38800),
                                              textAlign: TextAlign.left,
                                            ),
                                          )
                                        ],
                                      )
                                    : (data.ppcInfo.status == "no_ppc" &&
                                                data.status ==
                                                    "READY FOR PICKUP" ||
                                            data.ppcInfo.status == "no_ppc" &&
                                                data.status == "IN_STORE")
                                        ? Container()
                                        : (data.ppcInfo.status == "no_ppc" &&
                                                data.status != "OVERDUE")
                                            ? AlertInfoRectangleWidget(
                                                text: AppLocalizations.of(
                                                        context)
                                                    .translate(LanguageKeys
                                                        .ppcAlertCollectOnFree),
                                                bgColor: Color(0xff477FFF),
                                                textColor: Colors.white,
                                              )
                                            : (data.ppcInfo.status == "ppc" &&
                                                    countRemainingFreeDay < 0 &&
                                                    countryCode == "ID") //PAID
                                                ? Column(
                                                    children: [
                                                      (data.status == "OVERDUE")
                                                          ? AlertInfoRectangleWidget(
                                                              text: AppLocalizations
                                                                      .of(
                                                                          context)
                                                                  .translate(
                                                                      LanguageKeys
                                                                          .popsafeAlertOverdue),
                                                              bgColor: Color(
                                                                  0xffFFCECE),
                                                              textColor: Color(
                                                                  0xffFF0B09),
                                                            )
                                                          : Container(),
                                                      SizedBox(height: 7),
                                                      AlertInfoRectangleWidget(
                                                        text: AppLocalizations
                                                                .of(context)
                                                            .translate(LanguageKeys
                                                                .ppcAlertCollectNotFree),
                                                        bgColor:
                                                            Color(0xffFFCECE),
                                                        textColor:
                                                            Color(0xffFF0B09),
                                                      ),
                                                    ],
                                                  )
                                                : (data.ppcInfo.status == "ppc" &&
                                                        countRemainingFreeDay >
                                                            0 &&
                                                        countryCode == "ID")
                                                    //FREE
                                                    ? AlertInfoRectangleWidget(
                                                        text: AppLocalizations
                                                                .of(context)
                                                            .translate(LanguageKeys
                                                                .ppcAlertCollectOnFree),
                                                        bgColor:
                                                            Color(0xff477FFF),
                                                        textColor: Colors.white,
                                                      )
                                                    //#04
                                                    : (double.parse(data.ppcInfo
                                                                    .priceOverdue) ==
                                                                0 &&
                                                            countryCode == "MY")
                                                        ? AlertInfoRectangleWidget(
                                                            text: AppLocalizations
                                                                    .of(context)
                                                                .translate(
                                                                    LanguageKeys
                                                                        .ppcAlertCollectNotFree),
                                                            bgColor: Color(
                                                                0xffFF0B09),
                                                            textColor:
                                                                Colors.white,
                                                          )
                                                        //#5 - satu
                                                        : (double.parse(data
                                                                        .ppcInfo
                                                                        .priceOverdue) >
                                                                    0 &&
                                                                data.status !=
                                                                    "OVERDUE" &&
                                                                countryCode ==
                                                                    "MY")
                                                            ? AlertInfoRectangleWidget(
                                                                text: AppLocalizations.of(
                                                                        context)
                                                                    .translate(
                                                                        LanguageKeys
                                                                            .ppcFlatMYRuleNonFreeNote),
                                                                bgColor: Color(
                                                                    0xff477FFF),
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                              )
                                                            : (double.parse(data.ppcInfo.priceOverdue) > 0 &&
                                                                    data.status ==
                                                                        "OVERDUE" &&
                                                                    countryCode ==
                                                                        "MY")
                                                                ? AlertInfoRectangleWidget(
                                                                    text: AppLocalizations.of(
                                                                            context)
                                                                        .translate(
                                                                            LanguageKeys.ppcFlatMYRuleNonFreeNoteOverdue),
                                                                    bgColor: Color(
                                                                        0xffFF0B09),
                                                                    textColor:
                                                                        Colors
                                                                            .white,
                                                                  )

                                                                //TO DO
                                                                : Container(),

                    SizedBox(height: 15),
                    //QR CODE
                    (data.status == "COMPLETED" || data.status == "DESTROY")
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Stack(
                              children: [
                                Image.asset(
                                  "assets/images/ic_box_blue.png",
                                  fit: BoxFit.fitHeight,
                                  width: MediaQuery.of(context).size.width,
                                ),
                                Container(
                                  height: 70,
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomWidget().googleFontRobboto(
                                            AppLocalizations.of(context)
                                                .translate(
                                                    LanguageKeys.collectionCode)
                                                .toUpperCase(),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Colors.white,
                                            textAlign: TextAlign.left,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return CustomDialogBox(
                                                      title: data.pinCode,
                                                    );
                                                  });
                                            },
                                            child: CustomWidget()
                                                .googleFontRobboto(
                                              AppLocalizations.of(context)
                                                  .translate(LanguageKeys
                                                      .clickForSeeQR),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10,
                                              color: Color(0xff00137D),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ],
                                      ),
                                      CustomWidget().googleFontRobboto(
                                        data.pinCode,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 22,
                                        color: Colors.white,
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                    (data.ppcInfo.status == "ppc" &&
                            data.ppcInfo.freeDays == 0 &&
                            countryCode == "ID")
                        ? Container()
                        : (double.parse(data.ppcInfo.priceOverdue) == 0 &&
                                countryCode == "MY" &&
                                data.ppcInfo.status == "ppc")
                            ? Container()
                            : (data.status == "COMPLETED" ||
                                    data.status == "DESTROY" ||
                                    data.status == "OPERATOR_TAKEN" ||
                                    data.status == "COURIER_TAKEN")
                                ? Container()
                                : (data.status == "OVERDUE" &&
                                        data.ppcInfo.status == "no_ppc")
                                    ? Container()
                                    :
                                    //CountDown & Remaining Take Time Limit
                                    Container(
                                        width: 100.0.w,
                                        height: 75,
                                        margin: EdgeInsets.only(
                                            left: 16.0, right: 16.0),
                                        decoration: BoxDecoration(
                                          color: Color(0xffF7F7F7),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomWidget()
                                                    .googleFontRobboto(
                                                  (data.ppcInfo.status ==
                                                          "no_ppc")
                                                      ? AppLocalizations.of(context)
                                                          .translate(LanguageKeys
                                                              .remainingCollectionTime)
                                                      : (countRemainingFreeDay >
                                                              0)
                                                          ? AppLocalizations.of(context)
                                                              .translate(LanguageKeys
                                                                  .remainingFreeTimeLimit)
                                                          : (double.parse(data.ppcInfo.priceOverdue) > 0 &&
                                                                  data.status !=
                                                                      "OVERDUE" &&
                                                                  countryCode ==
                                                                      "MY")
                                                              ? AppLocalizations.of(
                                                                      context)
                                                                  .translate(
                                                                      LanguageKeys
                                                                          .remainingCollectionTime)
                                                              : AppLocalizations.of(
                                                                      context)
                                                                  .translate(
                                                                      LanguageKeys.remainingCollectionTime),
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  textAlign: TextAlign.left,
                                                ),
                                                CustomWidget()
                                                    .googleFontRobboto(
                                                  (data.ppcInfo.status ==
                                                          "no_ppc")
                                                      ? AppLocalizations.of(context)
                                                              .translate(
                                                                  LanguageKeys
                                                                      .collectionTimeLimit) +
                                                          " " +
                                                          data.overdueTime
                                                      : (data.ppcInfo.status ==
                                                              "no_ppc")
                                                          ? AppLocalizations.of(context).translate(LanguageKeys.takeTimeLimit) +
                                                              " " +
                                                              data.overdueTime
                                                          : (data.ppcInfo.status ==
                                                                      "ppc" &&
                                                                  data.ppcInfo.freeDays ==
                                                                      0 &&
                                                                  countryCode ==
                                                                      "ID")
                                                              ? ""
                                                              : (double.parse(data.ppcInfo.priceOverdue) >
                                                                          0 &&
                                                                      data.status !=
                                                                          "OVERDUE")
                                                                  ? AppLocalizations.of(context).translate(LanguageKeys.collectionTimeLimit) +
                                                                      " " +
                                                                      data
                                                                          .overdueTime
                                                                  : (double.parse(data.ppcInfo.priceOverdue) > 0 &&
                                                                          data.status == "OVERDUE" &&
                                                                          countryCode == "MY")
                                                                      ? AppLocalizations.of(context).translate(LanguageKeys.collectionTimeLimit) + " " + data.overdueTime
                                                                      : AppLocalizations.of(context).translate(LanguageKeys.freeCollectBefore) + " " + data.ppcInfo.freeUntil,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 10,
                                                  color: Color(0xffFF0B09),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ],
                                            ),
                                            //Widget getDayHourMinutes
                                            getDaysHoursMinutes(
                                                context,
                                                Duration(
                                                    seconds:
                                                        countdownTimeParcel))
                                          ],
                                        ),
                                      ),
                    SizedBox(height: 12),

                    (data.ppcInfo.status == "no_ppc" &&
                                data.status == "IN_STORE" ||
                            data.ppcInfo.status == "no_ppc" &&
                                data.status == "READY FOR PICKUP")
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 15, bottom: 15),
                            margin: EdgeInsets.only(
                                left: 20, right: 20, top: 0, bottom: 10),
                            decoration: BoxDecoration(
                              color: Color(0xffFFF3E0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CustomWidget().googleFontRobboto(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.noppcAlertInstore),
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: Color(0xffE38800),
                              textAlign: TextAlign.left,
                            ),
                          )
                        : Container(),
                    //Collection Fee
                    //ondevrafi

                    (data.status == "COMPLETED" ||
                            (data.status == "READY FOR PICKUP" &&
                                data.ppcInfo.status == "no_ppc") ||
                            (data.status == "IN_STORE" &&
                                data.ppcInfo.status == "no_ppc"))
                        ? Container()
                        : InkWell(
                            onTap: () {
                              if (data.ppcInfo.status == "ppc" &&
                                  isFree &&
                                  countryCode == "ID") {
                                showRulesWareHouseFreeDay(
                                    context: context, data: data);
                              } else if (countryCode == "MY" &&
                                  data.ppcInfo.priceOverdue != "0") {
                                print("11111");
                                showPPCFlatMYNonFree(
                                    context: context,
                                    pricePPC: pricePPC,
                                    data: data);
                              } else if (countryCode == "MY" &&
                                  data.ppcInfo.priceOverdue == "0") {
                                print("222222");
                                showPPCFlatMY(
                                    context: context, pricePPC: pricePPC);
                              } else {
                                print("33333");
                                showPPCnofreeday(context: context, data: data);
                              }
                            },
                            child: Container(
                              height: 102,
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(left: 16.0, right: 16.0),
                              padding: EdgeInsets.only(left: 22),
                              decoration: BoxDecoration(
                                  color: Color(0xffEAF3FF),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Image.asset(
                                      "assets/images/ic_popcenter_pay.png",
                                      fit: BoxFit.fitHeight,
                                      width: 120,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomWidget().googleFontRobboto(
                                        AppLocalizations.of(context).translate(
                                            LanguageKeys.collectionFee),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: Colors.black,
                                        textAlign: TextAlign.center,
                                      ),
                                      CustomWidget().googleFontRobboto(
                                        formatCurrency.format(pricePPC),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 25,
                                        color: Colors.black,
                                        textAlign: TextAlign.center,
                                      ),
                                      isFree
                                          ? CustomWidget().googleFontRobboto(
                                              AppLocalizations.of(context)
                                                      .translate(LanguageKeys
                                                          .collectionFee) +
                                                  " : " +
                                                  AppLocalizations.of(context)
                                                      .translate(
                                                          LanguageKeys.free),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10,
                                              color: Colors.black,
                                              textAlign: TextAlign.center,
                                            )
                                          : Row(
                                              children: [
                                                CustomWidget()
                                                    .googleFontRobboto(
                                                  AppLocalizations.of(context)
                                                          .translate(LanguageKeys
                                                              .collectionFee) +
                                                      " " +
                                                      formatCurrency.format(
                                                          double.parse(data
                                                              .ppcInfo
                                                              .pricePerDay)) +
                                                      " / 24 " +
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              LanguageKeys
                                                                  .hours),
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 10,
                                                  color: Colors.black,
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(width: 3),
                                                CustomWidget()
                                                    .googleFontRobboto(
                                                  AppLocalizations.of(context)
                                                      .translate(LanguageKeys
                                                          .learnMoreHere),
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 10,
                                                  color: Color(0xff477FFF),
                                                  textAlign: TextAlign.center,
                                                )
                                              ],
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                    (data.status == "COMPLETED" || data.status == "DESTROY")
                        ? Container()
                        : (data.ppcInfo.status == "no_ppc")
                            ? InkWell(
                                onTap: () {
                                  showRulesWareHouse(
                                    context: context,
                                    data: data,
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 16, right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomWidget().textLight(
                                        (data.status == "OVERDUE")
                                            ? AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .nonPPCNotesOverdue)
                                            : AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .nonPPCNotesNoOverdue),
                                        Colors.black,
                                        10,
                                        TextAlign.left,
                                      ),
                                      SizedBox(height: 5),
                                      CustomWidget().textLight(
                                        AppLocalizations.of(context).translate(
                                            LanguageKeys.learnMoreHere),
                                        Color(0xff477FFF),
                                        10,
                                        TextAlign.left,
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                    SizedBox(height: 10),
                    //CONTAIN
                    Container(
                      width: 100.0.w,
                      margin: EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 17.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.0,
                          color: PopboxColor.mdGrey300,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(left: 16.0, right: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomWidget().googleFontRobboto(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.receiptNo),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black,
                                  textAlign: TextAlign.left,
                                ),
                                CustomWidget().textBold(
                                    data.logisticCompany.name.toString(),
                                    PopboxColor.mdBlack1000,
                                    14,
                                    TextAlign.left),
                              ],
                            ),

                            SizedBox(height: 7.0),
                            CustomWidget().googleFontRobboto(
                              data.awb,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.black,
                              textAlign: TextAlign.left,
                            ),
                            Divider(color: Colors.grey),
                            SizedBox(height: 20.0),
                            CustomWidget().googleFontRobboto(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.status),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.black,
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 7.0),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: (data.status == "OVERDUE" ||
                                            data.status == "CANCEL")
                                        ? Color(0xffFFA9A9)
                                        : (data.status == "COMPLETED")
                                            ? Color(0xffCBF1E4)
                                            : Color(0xffEAF3FF),
                                  ),
                                  child: CustomWidget().googleFontRobboto(
                                    AppLocalizations.of(context)
                                        .translate(data.status
                                            .toLowerCase()
                                            .replaceAll(" ", ""))
                                        .toUpperCase(),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    color: (data.status == "OVERDUE" ||
                                            data.status == "CANCEL")
                                        ? Color(0xffFF0B09)
                                        : (data.status == "COMPLETED")
                                            ? Color(0xff1CAC77)
                                            : Color(0xff477FFF),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                SizedBox(width: 10),
                                RegExp(r'WAREHOUSE|warehouse')
                                        .hasMatch(data.status)
                                    ? Container()
                                    : isFree
                                        ? CustomWidget().textLight(
                                            (data.ppcInfo.freeDays != 0)
                                                ? AppLocalizations.of(context).translate(LanguageKeys.free) +
                                                    " " +
                                                    data.ppcInfo.freeDays
                                                        .toString() +
                                                    " " +
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                            LanguageKeys.day)
                                                : AppLocalizations.of(context).translate(
                                                    LanguageKeys.free),
                                            Color(0xffFF9D09),
                                            12,
                                            TextAlign.left)
                                        : (data.ppcInfo.freeDays == 0 &&
                                                data.ppcInfo.status == "ppc")
                                            ? (double.parse(data.ppcInfo.priceOverdue) == 0 &&
                                                    countryCode == "MY")
                                                ? Container()
                                                : (countryCode == "MY" &&
                                                        data.ppcInfo.status ==
                                                            "ppc" &&
                                                        data.ppcInfo.priceInstore ==
                                                            "0" &&
                                                        data.status !=
                                                            "OVERDUE")
                                                    ? CustomWidget().textLight(
                                                        AppLocalizations.of(context).translate(LanguageKeys.free),
                                                        Color(0xffFF9D09),
                                                        12,
                                                        TextAlign.left)
                                                    : (double.parse(data.ppcInfo.priceOverdue) > 0 && data.status != "OVERDUE" && countryCode == "MY")
                                                        ? Container()
                                                        : (double.parse(data.ppcInfo.priceOverdue) > 0 && data.status == "OVERDUE" && countryCode == "MY")
                                                            ? Container()
                                                            : CustomWidget().textLight("PPC", Color(0xffFF9D09), 12, TextAlign.left)
                                            : Container(),
                              ],
                            ),

                            Divider(color: Colors.grey),
                            SizedBox(height: 20.0),
                            CustomWidget().googleFontRobboto(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.location),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.black,
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 7.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 60.0.w,
                                  child: CustomWidget().googleFontRobboto(
                                    data.location,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.black,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    var lockerModel =
                                        Provider.of<LockerViewModel>(context,
                                            listen: false);

                                    List<LockerData> lockerList =
                                        lockerModel.newLockerList;

                                    try {
                                      LockerData lockerData =
                                          lockerList.firstWhere((element) =>
                                              element.name
                                                  .trim()
                                                  .toLowerCase() ==
                                              data.location
                                                  .trim()
                                                  .toLowerCase());
                                      if (lockerData.latitude != null &&
                                          lockerData.latitude != "" &&
                                          lockerData.latitude != "-") {
                                        if (Platform.isIOS) {
                                          await MapLauncher.launchMap(
                                            mapType: MapType.apple,
                                            coords: Coords(
                                                double.parse(
                                                    lockerData.latitude),
                                                double.parse(
                                                    lockerData.longitude)),
                                            title: lockerData.name,
                                            description: lockerData.address,
                                          );
                                        } else {
                                          await MapLauncher.launchMap(
                                            mapType: MapType.google,
                                            coords: Coords(
                                                double.parse(
                                                    lockerData.latitude),
                                                double.parse(
                                                    lockerData.longitude)),
                                            title: lockerData.name,
                                            description: lockerData.address,
                                          );
                                        }
                                      } else {
                                        CustomWidget().showToastShortV1(
                                            context: context,
                                            msg: AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .canNotLoadLocation));
                                      }
                                    } catch (e) {
                                      CustomWidget().showToastShortV1(
                                          context: context,
                                          msg: AppLocalizations.of(context)
                                              .translate(LanguageKeys
                                                  .canNotLoadLocation));
                                    }
                                  },
                                  child: CustomWidget().googleFontRobboto(
                                    "Detail",
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Color(0xff477FFF),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: Colors.grey),
                            SizedBox(height: 20.0),
                            (data.status == "CANCEL" ||
                                    data.status == "EXPIRED")
                                ? Container()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomWidget().googleFontRobboto(
                                        AppLocalizations.of(context)
                                            .translate(LanguageKeys.lockerSize),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Colors.black,
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(height: 6.0),
                                      CustomWidget().googleFontRobboto(
                                        data.lockerSize == ""
                                            ? "-"
                                            : data.lockerSize,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Colors.black,
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                            Divider(color: Colors.grey),
                            SizedBox(height: 20.0),
                            //#1 Nomor & Ukuran Loker
                            Container(
                              width: 100.0.w,
                              child: (data.status == "CANCEL" ||
                                      data.status == "EXPIRED")
                                  ? Container()
                                  : Container(
                                      width: 40.0.w,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomWidget().googleFontRobboto(
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      LanguageKeys.lockerNo),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: Colors.black,
                                              textAlign: TextAlign.left,
                                            ),
                                            SizedBox(height: 6.0),
                                            CustomWidget().googleFontRobboto(
                                              data.lockerNumber == ""
                                                  ? "-"
                                                  : data.lockerNumber
                                                      .toString(),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: Colors.black,
                                              textAlign: TextAlign.left,
                                            ),
                                          ]),
                                    ),
                            ),
                            // (widget.transactionType == "popsafe_cancel_success" ||
                            //         data.status == "CANCEL" ||
                            //         data.status == "EXPIRED")
                            //     ? Container()
                            //     : Column(
                            //         crossAxisAlignment: CrossAxisAlignment.start,
                            //         children: [
                            //           Container(
                            //             width: 40.0.w,
                            //             child: CustomWidget().googleFontRobboto(
                            //               AppLocalizations.of(context).translate(
                            //                   LanguageKeys.takeLimitTime),
                            //               fontWeight: FontWeight.w400,
                            //               fontSize: 12,
                            //               color: Colors.black,
                            //               textAlign: TextAlign.left,
                            //             ),
                            //           ),
                            //           SizedBox(height: 6.0),
                            //           CustomWidget().googleFontRobboto(
                            //             getFormattedDateShort(
                            //                 data.expiredTime),
                            //             fontWeight: FontWeight.w700,
                            //             fontSize: 15,
                            //             color: PopboxColor.popboxPrimaryRed,
                            //             textAlign: TextAlign.left,
                            //           ),
                            //         ],
                            //       ),
                            // Divider(color: Colors.grey),
                            // SizedBox(height: 20.0),
                            //#3 Waktu Kirim & Maks Pembatalan
                            // Container(
                            //   width: 100.0.w,
                            //   child: Row(children: [
                            //     (widget.transactionType ==
                            //                 "popsafe_cancel_success" ||
                            //             data.status == "CANCEL" ||
                            //             data.status == "EXPIRED" ||
                            //             data.status == "COMPLETE")
                            //         ? Container()
                            //         : Column(
                            //             crossAxisAlignment:
                            //                 CrossAxisAlignment.start,
                            //             children: [
                            //               CustomWidget().googleFontRobboto(
                            //                 AppLocalizations.of(context).translate(
                            //                     LanguageKeys
                            //                         .popsafeHistoryMaxCancel),
                            //                 fontWeight: FontWeight.w400,
                            //                 fontSize: 12,
                            //                 color: Colors.black,
                            //                 textAlign: TextAlign.left,
                            //               ),
                            //               SizedBox(height: 6.0),
                            //               CustomWidget().textBold(
                            //                 getFormattedDateShort(
                            //                     data.cancellationTime),
                            //                 PopboxColor.mdGrey900,
                            //                 11.0.sp,
                            //                 TextAlign.left,
                            //               ),
                            //             ],
                            //           ),
                            //   ]),
                            // ),
                            SizedBox(height: 17.0),
                          ],
                        ),
                      ),
                    ),
//TRACKING
                    Container(
                      width: 100.0.w,
                      margin: EdgeInsets.only(left: 16.0, right: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.0,
                          color: PopboxColor.mdGrey300,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: Color(0xffEFEFEF),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(cardColor: Color(0xffEFEFEF)),
                          child: ExpansionPanelList(
                            animationDuration: Duration(milliseconds: 1000),
                            dividerColor: PopboxColor.mdBlack1000,
                            elevation: 0,
                            children: [
                              ExpansionPanel(
                                body: trackingParcelWidget(
                                    parcelHistory:
                                        parcelHistoryDetailData.history),
                                //TITLE
                                headerBuilder:
                                    (BuildContext context, bool isExpanded) {
                                  return Container(
                                    padding:
                                        EdgeInsets.only(top: 14.0, left: 16.0),
                                    child: CustomWidget().googleFontRobboto(
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.tracking),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Colors.black,
                                      textAlign: TextAlign.left,
                                    ),
                                  );
                                },
                                isExpanded: isExpandedTrack,
                              )
                            ],
                            expansionCallback: (int item, bool status) {
                              setState(() {
                                isExpandedTrack = !isExpandedTrack;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    (data.status == "COMPLETED" ||
                            (data.status == "READY FOR PICKUP" &&
                                data.ppcInfo.status == "no_ppc") ||
                            (data.status == "IN_STORE" &&
                                data.ppcInfo.status == "no_ppc"))
                        ? Container()
                        : InkWell(
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
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(left: 20, right: 20),
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 10, bottom: 10),
                                decoration: BoxDecoration(
                                    color: Color(0xffFFEBCF),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.info, color: Color(0xFFFF0B09)),
                                    Container(
                                      padding:
                                          EdgeInsets.only(left: 10, right: 0),
                                      width: MediaQuery.of(context).size.width -
                                          100,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomWidget().googleFontRobboto(
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .isPopcenterNoteTwo),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: Color(0xffE38800),
                                            textAlign: TextAlign.left,
                                          ),
                                          SizedBox(height: 3),
                                          CustomWidget().googleFontRobboto(
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .isPopcenterNoteThree),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: Color(0xffE38800),
                                            textAlign: TextAlign.left,
                                          ),
                                          CustomWidget().googleFontRobboto(
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .isPopcenterNoteFour),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: Color(0xffE38800),
                                            textAlign: TextAlign.left,
                                          ),
                                          Text(
                                            AppLocalizations.of(context)
                                                .translate(
                                                    LanguageKeys.termCondition),
                                            softWrap: true,
                                            overflow: TextOverflow.clip,
                                            style: GoogleFonts.roboto(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: Color(0xffE38800),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),

                    SizedBox(height: 17.0),
                    InkWell(
                      onTap: () {
                        callCsBottomSheet(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info, color: Color(0xFFFF9C08)),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)
                                      .translate(LanguageKeys.havingProblem),
                                  style: TextStyle(
                                    color: Color(0xFF202020),
                                    fontSize: 12,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context).translate(
                                      LanguageKeys.callPopboxCustomerService),
                                  style: TextStyle(
                                    color: Color(0xFF477FFF),
                                    fontSize: 12,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 150.0),
                  ],
                )
              ]),
              (data.ppcInfo.status == "no_ppc" &&
                      data.status == "OVERDUE" &&
                      countStoreDay <= 6)
                  ? GestureDetector(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                bottom: 20.0, left: 20.0, right: 20, top: 15),
                            color: Color(0xffF7F7F7),
                            child: CustomWidget().customColorButton(
                                context,
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.popsafeHowToExtend),
                                PopboxColor.popboxRed,
                                PopboxColor.mdWhite1000),
                          ),
                        ],
                      ),
                      onTap: () {
                        showExtendReasonSelect(
                            context: context, data: data, from: "parcel");
                      },
                    )
                  : (data.ppcInfo.status == "no_ppc" &&
                          data.status == "OVERDUE" &&
                          countStoreDay > 6)
                      ? GestureDetector(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                    bottom: 20.0,
                                    left: 20.0,
                                    right: 20,
                                    top: 15),
                                color: Color(0xffF7F7F7),
                                child: CustomWidget().customColorButton(
                                    context,
                                    AppLocalizations.of(context).translate(
                                        LanguageKeys.callPopboxCustomerService),
                                    PopboxColor.popboxRed,
                                    PopboxColor.mdWhite1000),
                              ),
                            ],
                          ),
                          onTap: () {
                            callCsBottomSheet(context);
                          },
                        )
                      : ((data.ppcInfo.status == "ppc" &&
                                  data.status == "OVERDUE") ||
                              (data.ppcInfo.status == "ppc" &&
                                  data.status == "INSTORE") ||
                              (data.ppcInfo.status == "ppc" &&
                                  data.status == "IN_STORE") ||
                              (data.ppcInfo.status == "ppc" &&
                                  data.status == "READY FOR PICKUP"))
                          ? GestureDetector(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  //bukan pay ppc lastmile
                                  Container(
                                    padding: EdgeInsets.only(
                                        bottom: 20.0,
                                        left: 20.0,
                                        right: 20,
                                        top: 15),
                                    color: Color(0xffF7F7F7),
                                    child: CustomWidget().customColorButton(
                                        context,
                                        AppLocalizations.of(context)
                                            .translate(LanguageKeys.pay)
                                            .toUpperCase(),
                                        PopboxColor.popboxRed,
                                        PopboxColor.mdWhite1000),
                                  ),
                                ],
                              ),
                              onTap: () {
                                //
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MethodPaymentPage()),
                                );

                                // if (showPopsafe == false) {
                                //   showPopsafeInfo(context: context);
                                // } else {
                                //   showExtendOrder(context);
                                // }
                              },
                            )
                          : (data.status == "OPERATOR_TAKEN" ||
                                  data.status == "COURIER_TAKEN")
                              ? GestureDetector(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            bottom: 20.0,
                                            left: 20.0,
                                            right: 20,
                                            top: 15),
                                        color: Color(0xffF7F7F7),
                                        child: CustomWidget().customColorButton(
                                            context,
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys.callCs)
                                                .toUpperCase(),
                                            PopboxColor.popboxRed,
                                            PopboxColor.mdWhite1000),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    callCsBottomSheet(context);
                                  },
                                )
                              : Container()
            ],
          ),
        );
      } else {
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, top: 16.0, right: 16.0, bottom: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  new Container(
                    margin:
                        EdgeInsets.only(left: 0.0, right: 0.0, bottom: 30.0),
                    decoration: new BoxDecoration(
                        color: PopboxColor.popboxPrimaryRed,
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0),
                          bottomLeft: const Radius.circular(10.0),
                          bottomRight: const Radius.circular(10.0),
                        )),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 90.0.w,
                        //maxWidth: 300.0,
                        minHeight: 30.0,
                        maxHeight: 110.0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomDialogBox(
                                          title: data.pinCode);
                                    });
                              },
                              child: QrImage(
                                data: "AMBIL#" + data.pinCode,
                                version: QrVersions.auto,
                                size: 70,
                                gapless: false,
                                padding: EdgeInsets.all(4.0),
                                backgroundColor: PopboxColor.mdWhite1000,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomWidget().textRegular(
                                      AppLocalizations.of(context).translate(
                                          LanguageKeys.collectionCode),
                                      PopboxColor.mdWhite1000,
                                      8.0.sp,
                                      TextAlign.left),
                                  CustomWidget().textBold(
                                    data.pinCode,
                                    PopboxColor.mdWhite1000,
                                    16.0.sp,
                                    TextAlign.left,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  onlyTextContent(
                      context: context,
                      title: AppLocalizations.of(context)
                          .translate(LanguageKeys.receiptNo),
                      content: data.awb,
                      canCopy: true),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: Divider(
                      height: 1.0,
                      color: Colors.grey,
                    ),
                  ),
                  onlyTextContent(
                      context: context,
                      title: AppLocalizations.of(context)
                          .translate(LanguageKeys.status),
                      content: AppLocalizations.of(context)
                          .translate(
                              data.status.replaceAll(" ", "").toLowerCase())
                          .toUpperCase(),
                      contentColor: PopboxColor.popboxRed),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: Divider(
                      height: 1.0,
                      color: Colors.grey,
                    ),
                  ),
                  textContentLocation(
                    context: context,
                    title: AppLocalizations.of(context)
                        .translate(LanguageKeys.location),
                    content: data.location,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: Divider(
                      height: 1.0,
                      color: Colors.grey,
                    ),
                  ),
                  onlyTextContent(
                    context: context,
                    title: AppLocalizations.of(context)
                        .translate(LanguageKeys.codeValidityLimit),
                    content:
                        (data.overdueTime != null && data.overdueTime != '')
                            ? getFormattedDate(data.overdueTime)
                            : '-',
                  ),
                ],
              ),
            ),
            //REPORT FORM
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => (Platform.isAndroid)
                          ? FormReportingPage(
                              unfinishParcelData: data,
                              reason: "Unfinish",
                              type: "Collection")
                          : {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((_) => setState(() {
                                        context
                                            .read<BottomNavigationBloc>()
                                            .add(
                                              PageTapped(index: 2),
                                            );
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (c) => Home()),
                                                (route) => false);
                                      }))
                            }),
                );
              },
              child: ReportOrderProblem(
                imageUrl: "assets/images/ic_question_green.png",
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.askProblemOrder),
                subTitle: AppLocalizations.of(context)
                    .translate(LanguageKeys.callPopboxCustomerService),
                bgColor: PopboxColor.mdYellowA500,
              ),
            ),
          ],
        );
      }
    } else {
      return cartShimmerView(context);
    }
  }

  Widget popsafeSuccessViewNew(
      BuildContext context, PopsafeHistoryDetailData popsafeDataDetailSuccess) {
    return popsafeDataDetailSuccess != null
        ? WillPopScope(
            onWillPop: _willPopCallback,
            child: ListView(children: [
              Column(
                children: [
                  SizedBox(height: 20.0),
                  //QR CODE
                  (popsafeDataDetailSuccess.status != "CANCEL")
                      ? Container(
                          height: 112.0,
                          margin: EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 20.0),
                          decoration: BoxDecoration(
                            color: PopboxColor.mdBlue60,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 20.0),
                              Container(
                                width: 20.0.w,
                                child: (popsafeDataDetailSuccess.status ==
                                            "CANCEL" ||
                                        popsafeDataDetailSuccess.status ==
                                            "EXPIRED")
                                    ? Image.asset(
                                        "assets/images/ic_dummy_qrcode.png",
                                        fit: BoxFit.contain,
                                      )
                                    : (popsafeDataDetailSuccess.codePin == "")
                                        ? Image.asset(
                                            "assets/images/ic_dummy_qrcode.png",
                                            fit: BoxFit.contain,
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return CustomDialogBox(
                                                      title:
                                                          popsafeDataDetailSuccess
                                                              .codePin,
                                                    );
                                                  });
                                            },
                                            child: QrImage(
                                              data: popsafeDataDetailSuccess
                                                  .codePin,
                                              version: QrVersions.auto,
                                              gapless: false,
                                              backgroundColor:
                                                  PopboxColor.mdWhite1000,
                                            )),
                              ),
                              SizedBox(width: 20.0),
                              Container(
                                width: 55.0.w,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomWidget().textRegular(
                                        AppLocalizations.of(context).translate(
                                            LanguageKeys.collectionCode),
                                        PopboxColor.mdGrey180,
                                        10.0.sp,
                                        TextAlign.left),
                                    (popsafeDataDetailSuccess.codePin == "")
                                        ? CustomWidget().textRegular(
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .popsafeHistoryCodeSoon),
                                            PopboxColor.mdBlack1000,
                                            10.0.sp,
                                            TextAlign.left)
                                        : CustomWidget().textBold(
                                            popsafeDataDetailSuccess.codePin,
                                            PopboxColor.mdBlack1000,
                                            16.0.sp,
                                            TextAlign.left)
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      : Container(),

                  //OVERDUE NOTES
                  (popsafeDataDetailSuccess.status == "OVERDUE" ||
                          popsafeDataDetailSuccess.status == "EXPIRED")
                      ? Container(
                          width: 100.0.w,
                          height: 85,
                          margin: EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 20.0),
                          decoration: BoxDecoration(
                            color: PopboxColor.mdOrange150,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.only(left: 10.0),
                              child: CustomWidget().textRegular(
                                  (popsafeDataDetailSuccess.status == "OVERDUE")
                                      ? AppLocalizations.of(context).translate(
                                          LanguageKeys
                                              .notesPopsafeTransDetailisOverdue)
                                      : AppLocalizations.of(context).translate(
                                          LanguageKeys
                                              .notesPopsafeTransDetailisExpired),
                                  PopboxColor.mdWhite1000,
                                  9.0.sp,
                                  TextAlign.left),
                            ),
                          ),
                        )
                      : Container(),
                  //HOW TO SAFE
                  (popsafeDataDetailSuccess.status == "CREATED" ||
                          popsafeDataDetailSuccess.status.replaceAll(" ", "") ==
                              "INSTORE")
                      ? GestureDetector(
                          onTap: () {
                            showQRcodeOnLocker(context);
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20.0),
                            child: ReportOrderProblem(
                              imageUrl: "assets/images/ic_question_green.png",
                              title: (popsafeDataDetailSuccess.codePin == "")
                                  ? AppLocalizations.of(context)
                                      .translate(LanguageKeys.popsafeHowToOrder)
                                  : AppLocalizations.of(context)
                                      .translate(LanguageKeys.popsafeHowToTake),
                              subTitle: (popsafeDataDetailSuccess.codePin == "")
                                  ? AppLocalizations.of(context).translate(
                                      LanguageKeys.popsafeHowToOrderMore)
                                  :
                                  //DEVRAFI SOON
                                  AppLocalizations.of(context).translate(
                                      LanguageKeys.popsafeHowToOrderMore),
                              bgColor: PopboxColor.mdYellowA500,
                            ),
                          ),
                        )
                      : Container(),
                  //CONTAIN
                  Container(
                    width: 100.0.w,
                    margin:
                        EdgeInsets.only(left: 16.0, right: 16.0, bottom: 17.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: PopboxColor.mdGrey300,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.0),
                          CustomWidget().textRegular(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.receiptNo),
                              PopboxColor.mdGrey180,
                              10.0.sp,
                              TextAlign.left),
                          SizedBox(height: 7.0),
                          CustomWidget().textBold(
                            popsafeDataDetailSuccess.invoiceCode,
                            PopboxColor.mdGrey900,
                            12.0.sp,
                            TextAlign.left,
                          ),
                          SizedBox(height: 20.0),
                          CustomWidget().textRegular(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.status),
                              PopboxColor.mdGrey180,
                              10.0.sp,
                              TextAlign.left),
                          SizedBox(height: 7.0),
                          CustomWidget().textBold(
                            popsafeDataDetailSuccess.status,
                            (popsafeDataDetailSuccess.status == "OVERDUE" ||
                                    popsafeDataDetailSuccess.status == "CANCEL")
                                ? PopboxColor.mdYellow700
                                : PopboxColor.popboxRed,
                            9.0.sp,
                            TextAlign.left,
                          ),
                          SizedBox(height: 20.0),
                          CustomWidget().textRegular(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.location),
                              PopboxColor.mdGrey180,
                              10.0.sp,
                              TextAlign.left),
                          SizedBox(height: 7.0),
                          Row(
                            children: [
                              Container(
                                width: 60.0.w,
                                child: CustomWidget().textBold(
                                  popsafeDataDetailSuccess.lockerName,
                                  PopboxColor.mdGrey900,
                                  12.0.sp,
                                  TextAlign.left,
                                ),
                              ),
                              InkWell(
                                  onTap: () async {
                                    var lockerModel =
                                        Provider.of<LockerViewModel>(context,
                                            listen: false);

                                    List<LockerData> lockerList =
                                        lockerModel.newLockerList;

                                    try {
                                      LockerData lockerData =
                                          lockerList.firstWhere((element) =>
                                              element.name
                                                  .trim()
                                                  .toLowerCase() ==
                                              popsafeDataDetailSuccess
                                                  .lockerName
                                                  .trim()
                                                  .toLowerCase());

                                      if (lockerData.latitude != null &&
                                          lockerData.latitude != "" &&
                                          lockerData.latitude != "-") {
                                        if (Platform.isIOS) {
                                          await MapLauncher.launchMap(
                                            mapType: MapType.apple,
                                            coords: Coords(
                                                double.parse(
                                                    lockerData.latitude),
                                                double.parse(
                                                    lockerData.longitude)),
                                            title: lockerData.name,
                                            description: lockerData.address,
                                          );
                                        } else {
                                          await MapLauncher.launchMap(
                                            mapType: MapType.google,
                                            coords: Coords(
                                                double.parse(
                                                    lockerData.latitude),
                                                double.parse(
                                                    lockerData.longitude)),
                                            title: lockerData.name,
                                            description: lockerData.address,
                                          );
                                        }
                                      } else {
                                        CustomWidget().showToastShortV1(
                                            context: context,
                                            msg: AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .canNotLoadLocation));
                                      }
                                    } catch (e) {
                                      CustomWidget().showToastShortV1(
                                          context: context,
                                          msg: AppLocalizations.of(context)
                                              .translate(LanguageKeys
                                                  .canNotLoadLocation));
                                    }
                                  },
                                  child: Image.asset(
                                      "assets/images/ic_location_more.png")),
                            ],
                          ),
                          SizedBox(height: 20.0),
                          //#1 Nomor & Ukuran Loker
                          Container(
                            width: 100.0.w,
                            child: Row(children: [
                              (popsafeDataDetailSuccess.status == "CANCEL" ||
                                      popsafeDataDetailSuccess.status ==
                                          "EXPIRED")
                                  ? Container()
                                  : Container(
                                      width: 40.0.w,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomWidget().textRegular(
                                                AppLocalizations.of(context)
                                                    .translate(
                                                        LanguageKeys.lockerNo),
                                                PopboxColor.mdGrey180,
                                                10.0.sp,
                                                TextAlign.left),
                                            SizedBox(height: 6.0),
                                            CustomWidget().textBold(
                                              popsafeDataDetailSuccess
                                                          .lockerNumber ==
                                                      0
                                                  ? "-"
                                                  : popsafeDataDetailSuccess
                                                      .lockerNumber
                                                      .toString(),
                                              PopboxColor.mdGrey900,
                                              12.0.sp,
                                              TextAlign.left,
                                            ),
                                          ]),
                                    ),
                              //devrafitransdetail
                              (popsafeDataDetailSuccess.status == "CANCEL" ||
                                      popsafeDataDetailSuccess.status ==
                                          "EXPIRED")
                                  ? Container()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomWidget().textRegular(
                                            AppLocalizations.of(context)
                                                .translate(
                                                    LanguageKeys.lockerSize),
                                            PopboxColor.mdGrey180,
                                            10.0.sp,
                                            TextAlign.left),
                                        SizedBox(height: 6.0),
                                        CustomWidget().textBold(
                                          popsafeDataDetailSuccess.lockerSize ==
                                                  ""
                                              ? "-"
                                              : popsafeDataDetailSuccess
                                                  .lockerSize,
                                          PopboxColor.mdGrey900,
                                          12.0.sp,
                                          TextAlign.left,
                                        ),
                                      ],
                                    ),
                            ]),
                          ),
                          // SizedBox(height: 20.0),
                          //#3 Waktu Ambil & Sisa Batas Ambil
                          Container(
                            width: 100.0.w,
                            child: Row(children: [
                              Container(
                                width: 40.0.w,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomWidget().textRegular(
                                          AppLocalizations.of(context)
                                              .translate(LanguageKeys.takeTime),
                                          PopboxColor.mdGrey180,
                                          10.0.sp,
                                          TextAlign.left),
                                      SizedBox(height: 6.0),
                                      CustomWidget().textBold(
                                        (popsafeDataDetailSuccess.takeTime ==
                                                "")
                                            ? "-"
                                            : getFormattedDateShort(
                                                popsafeDataDetailSuccess
                                                    .takeTime),
                                        PopboxColor.mdGrey900,
                                        11.0.sp,
                                        TextAlign.left,
                                      ),
                                    ]),
                              ),
                              (widget.transactionType == "popsafe_cancel_success" ||
                                      popsafeDataDetailSuccess.status ==
                                          "CANCEL" ||
                                      popsafeDataDetailSuccess.status ==
                                          "EXPIRED")
                                  ? Container()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomWidget().textRegular(
                                            AppLocalizations.of(context)
                                                .translate(
                                                    LanguageKeys.takeLimitTime),
                                            PopboxColor.mdGrey180,
                                            10.0.sp,
                                            TextAlign.left),
                                        SizedBox(height: 6.0),
                                        CustomWidget().textBold(
                                          getFormattedDateShort(
                                              popsafeDataDetailSuccess
                                                  .expiredTime),
                                          PopboxColor.mdGrey900,
                                          11.0.sp,
                                          TextAlign.left,
                                        ),
                                      ],
                                    ),
                            ]),
                          ),
                          // SizedBox(height: 20.0),
                          //#2 Waktu Kirim & Maks Pembatalan
                          Container(
                            width: 100.0.w,
                            child: Row(children: [
                              (widget.transactionType == "popsafe_cancel_success" ||
                                      popsafeDataDetailSuccess.status ==
                                          "CANCEL" ||
                                      popsafeDataDetailSuccess.status ==
                                          "EXPIRED" ||
                                      popsafeDataDetailSuccess.status ==
                                          "COMPLETE")
                                  ? Container()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomWidget().textRegular(
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .popsafeHistoryMaxCancel),
                                            PopboxColor.mdGrey180,
                                            10.0.sp,
                                            TextAlign.left),
                                        SizedBox(height: 6.0),
                                        CustomWidget().textBold(
                                          getFormattedDateShort(
                                              popsafeDataDetailSuccess
                                                  .cancellationTime),
                                          PopboxColor.mdGrey900,
                                          11.0.sp,
                                          TextAlign.left,
                                        ),
                                      ],
                                    ),
                            ]),
                          ),
                          // SizedBox(height: 20.0),
                          //BUTTON CANCEL OR EXTEND
                          popsafeDataDetailSuccess.status == "CREATED" &&
                                  timeDifference < 3600
                              ? GestureDetector(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 20.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: PopboxColor.popboxRed),
                                    ),
                                    child: CustomWidget().customColorButton(
                                        context,
                                        AppLocalizations.of(context).translate(
                                            LanguageKeys.orderCancel),
                                        PopboxColor.mdWhite1000,
                                        PopboxColor.popboxRed),
                                  ),
                                  onTap: () {
                                    showCancelOrder(context);
                                  },
                                )
                              : (popsafeDataDetailSuccess.status == "OVERDUE")
                                  ? GestureDetector(
                                      child: Container(
                                        margin: EdgeInsets.only(top: 20.0),
                                        child: CustomWidget().customColorButton(
                                            context,
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .popsafeHowToExtend),
                                            PopboxColor.popboxRed,
                                            PopboxColor.mdWhite1000),
                                      ),
                                      onTap: () {
                                        showExtendOrder(context);
                                      },
                                    )
                                  : Container(),
                          SizedBox(height: 17.0),
                        ],
                      ),
                    ),
                  ),
                  //DEV CONTAINER DETAIL PEMBAYARAN
                  Container(
                    width: 100.0.w,
                    margin: EdgeInsets.only(left: 16.0, right: 16.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: PopboxColor.mdGrey300,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                      child: ExpansionPanelList(
                        animationDuration: Duration(milliseconds: 1000),
                        dividerColor: PopboxColor.mdBlack1000,
                        elevation: 0,
                        children: [
                          ExpansionPanel(
                            body: Container(
                              padding: EdgeInsets.only(left: 16.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  //PRICE
                                  CustomWidget().textRegular(
                                      AppLocalizations.of(context).translate(
                                          LanguageKeys.entrustedCosts),
                                      PopboxColor.mdBlack1000,
                                      11.0.sp,
                                      TextAlign.left),
                                  SizedBox(height: 7),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: CustomWidget().textBold(
                                      formatCurrency.format(
                                          popsafeDataDetailSuccess.totalPrice),
                                      PopboxColor.mdGrey900,
                                      11.0.sp,
                                      TextAlign.left,
                                    ),
                                  ),
                                  SizedBox(height: 11),
                                  //PROMO
                                  CustomWidget().textRegular(
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.voucherPromo),
                                      PopboxColor.mdBlack1000,
                                      11.0.sp,
                                      TextAlign.left),
                                  SizedBox(height: 7),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: CustomWidget().textBold(
                                      formatCurrency.format(
                                          popsafeDataDetailSuccess.promoPrice),
                                      PopboxColor.mdGrey900,
                                      11.0.sp,
                                      TextAlign.left,
                                    ),
                                  ),
                                  SizedBox(height: 11),
                                  //TOTAL PRICE
                                  CustomWidget().textRegular(
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.totalPrice),
                                      PopboxColor.mdBlack1000,
                                      11.0.sp,
                                      TextAlign.left),
                                  SizedBox(height: 7),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: CustomWidget().textBold(
                                      formatCurrency.format(
                                          popsafeDataDetailSuccess.paidPrice),
                                      PopboxColor.mdGrey900,
                                      11.0.sp,
                                      TextAlign.left,
                                    ),
                                  ),
                                  SizedBox(height: 11),
                                ],
                              ),
                            ),
                            //TITLE
                            headerBuilder:
                                (BuildContext context, bool isExpanded) {
                              return Container(
                                padding: EdgeInsets.only(top: 14.0, left: 16.0),
                                child: CustomWidget().textBold(
                                  AppLocalizations.of(context).translate(
                                      LanguageKeys.transactionDetail),
                                  PopboxColor.mdGrey900,
                                  11.0.sp,
                                  TextAlign.left,
                                ),
                              );
                            },
                            isExpanded: isExpandedTransaction,
                          )
                        ],
                        expansionCallback: (int item, bool status) {
                          setState(() {
                            isExpandedTransaction = !isExpandedTransaction;
                          });
                        },
                      ),
                    ),
                  ),
                  //DEV CONTAINER
                  SizedBox(height: 10.0),
                  //DEV CONTAINER DETAIL PEMBAYARAN
                  Container(
                    width: 100.0.w,
                    margin: EdgeInsets.only(left: 16.0, right: 16.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: PopboxColor.mdGrey300,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                      child: ExpansionPanelList(
                        animationDuration: Duration(milliseconds: 1000),
                        dividerColor: PopboxColor.mdBlack1000,
                        elevation: 0,
                        children: [
                          ExpansionPanel(
                            body: trackingPopsafeWidget(
                                popsafeHistory:
                                    popsafeDataDetailSuccess.popsafeHistory),
                            //TITLE
                            headerBuilder:
                                (BuildContext context, bool isExpanded) {
                              return Container(
                                padding: EdgeInsets.only(top: 14.0, left: 16.0),
                                child: CustomWidget().textBold(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.tracking),
                                  PopboxColor.mdGrey900,
                                  11.0.sp,
                                  TextAlign.left,
                                ),
                              );
                            },
                            isExpanded: isExpandedTrack,
                          )
                        ],
                        expansionCallback: (int item, bool status) {
                          setState(() {
                            isExpandedTrack = !isExpandedTrack;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => (Platform.isAndroid)
                                ? FormReportingPage(
                                    popsafeHistoryDetailData:
                                        popsafeDataDetailSuccess,
                                    reason: "Popsafe",
                                    type: "Popsafe",
                                  )
                                : {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) =>
                                            setState(() {
                                              context
                                                  .read<BottomNavigationBloc>()
                                                  .add(
                                                    PageTapped(index: 2),
                                                  );
                                              Navigator.of(context)
                                                  .pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                          builder: (c) =>
                                                              Home()),
                                                      (route) => false);
                                            }))
                                  }),
                      );
                    },
                    child: ReportOrderProblem(
                      imageUrl: "assets/images/ic_question_green.png",
                      title: AppLocalizations.of(context)
                          .translate(LanguageKeys.askProblemOrder),
                      subTitle: AppLocalizations.of(context)
                          .translate(LanguageKeys.callPopboxCustomerService),
                      bgColor: PopboxColor.mdBlue60,
                    ),
                  ),
                  SizedBox(height: 20.0),
                ],
              )
            ]),
          )
        : cartShimmerView(context);
  }

  Widget popcenterView(BuildContext context, PopcenterDetailData data) {
    // setCurrency();
    //DATE TIME DIFFERENCE
    int countStoreDay = 0;
    int countRemainingFreeDay = 0;
    double xFreeDays = 0;
    double pricePPC = 0;
    bool isFree = false;

    if (data != null) {
      DateTime now = DateTime.now();
      String dateTimeNowFormated =
          DateFormat('dd MMM yyyy HH:mm:ss').format(now);
      final formatedTime = DateFormat('dd MMM yyyy HH:mm:ss');
      final nowtime = formatedTime.parse(dateTimeNowFormated);

      countStoreDay =
          nowtime.difference(formatedTime.parse(data.instoreTime)).inDays;

      if (data.ppcInfo.status == "ppc") {
        if (countryCode == "MY") {
          if (double.parse(data.ppcInfo.priceOverdue) == 0) {
          } else if (double.parse(data.ppcInfo.priceOverdue) > 0 &&
              data.lastStatusInbound != "OVERDUE") {
          } else if (double.parse(data.ppcInfo.priceOverdue) > 0 &&
              data.lastStatusInbound == "OVERDUE") {
          } else {
            //nothing
          }
        } else {
          countRemainingFreeDay = formatedTime
              .parse(data.ppcInfo.freeUntil)
              .difference(nowtime)
              .inSeconds;
          print("debug rafi ==> " + countRemainingFreeDay.toString());
          countdownTimeParcel = formatedTime
              .parse(data.ppcInfo.freeUntil)
              .difference(nowtime)
              .inSeconds;
        }

        if (data.ppcInfo.ppcType == "dinamic") {
          if (data.lastStatusInbound == "OUTBOUND_COURIER_POPCENTER" ||
              data.lastStatusInbound == "OUTBOUND_OPERATOR_POPCENTER" ||
              data.lastStatusInbound == "DESTROY_POPCENTER" ||
              data.lastStatusInbound == "OUTBOUND_POPCENTER") {
            xFreeDays = (formatedTime
                    .parse(data.takeTime)
                    .difference(formatedTime.parse(data.instoreTime))
                    .inDays) -
                data.ppcInfo.freeDays.toDouble() +
                1;
          } else {
            xFreeDays = (nowtime
                    .difference(formatedTime.parse(data.instoreTime))
                    .inDays) -
                data.ppcInfo.freeDays.toDouble() +
                1;
          }

          if (xFreeDays <= 0) {
            isFree = true;
            pricePPC = 0;
          } else if (xFreeDays > data.ppcInfo.maxDay) {
            isFree = false;
            pricePPC = (data.ppcInfo.maxDay - data.ppcInfo.freeDays) *
                double.parse(data.ppcInfo.pricePerDay);
          } else {
            isFree = false;
            pricePPC = xFreeDays * double.parse(data.ppcInfo.pricePerDay);
          }
        }

        // else if (data.ppcInfo.ppcType == "fixed" ||
        //     data.ppcInfo.ppcType == "flat") {
        //   if (data.ppcInfo.freeDays < 1) {
        //     if (data.lastStatusInbound != "OVERDUE") {
        //       pricePPC = double.parse(data.ppcInfo.priceStore);
        //     } else if (data.lastStatusInbound == "OVERDUE") {
        //       pricePPC = double.parse(data.ppcInfo.priceStore) +
        //           double.parse(data.ppcInfo.priceOverdue);
        //     }
        //   } else {
        //     if (countStoreDay <= data.ppcInfo.freeDays) {
        //       pricePPC = 0;
        //     } else {
        //       if (data.lastStatusInbound != "OVERDUE") {
        //         pricePPC = double.parse(data.ppcInfo.priceStore);
        //       } else if (data.lastStatusInbound == "OVERDUE") {
        //         pricePPC = double.parse(data.ppcInfo.priceStore) +
        //             double.parse(data.ppcInfo.priceOverdue);
        //       }
        //     }
        //   }
        // } else {
        //   //else
        // }

        if (countdownTimeParcel < 0) {
          countdownTimeParcel = 0;
        }
      }
      //NO PPC
      if (data.ppcInfo.status == "no_ppc") {
        isFree = true;
        //freeday
        //instoretime
        //(instore + freeday)
        countdownTimeParcel = formatedTime
            .parse(data.expiredFreeTime)
            .difference(nowtime)
            .inSeconds;
        if (countdownTimeParcel < 0) {
          countdownTimeParcel = 0;
        }
      } else if ((double.parse(data.ppcInfo.priceOverdue) > 0 &&
          data.lastStatusInbound != "OVERDUE")) {
        countdownTimeParcel = formatedTime
            .parse(data.expiredFreeTime)
            .difference(nowtime)
            .inSeconds;
        if (countdownTimeParcel < 0) {
          countdownTimeParcel = 0;
        }
      } else {}
      if (data.inboundGroup == "PACKAGE_FOOD") {
        isFree = true;
        pricePPC = 0;
        countRemainingFreeDay = 0;
        countdownTimeParcel = 0;
      }
      // if (data.status == "TAKEN" || data.status == "COMPLETED") {
      //   countdownTimeParcel = 0;
      // }
      //
      // print("pricePPC => $pricePPC");
      // print("isFree => $isFree");
    }

    if (data != null) {
      return RefreshIndicator(
        onRefresh: _refreshPopcenter,
        child: ListView(scrollDirection: Axis.vertical, children: [
          Column(
            children: [
              SizedBox(height: 20.0),
              (data.lastStatusInbound == "DESTROY_POPCENTER")
                  ? Column(
                      children: [
                        AlertInfoRectangleWidget(
                          text: AppLocalizations.of(context)
                              .translate(LanguageKeys.popcenterAlertDestroy),
                          bgColor: Color(0xffFFCECE),
                          textColor: Color(0xffFF0B09),
                        ),
                        SizedBox(height: 10),
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
                            width: 100.0.w,
                            padding: EdgeInsets.only(
                              top: 11,
                              bottom: 11,
                              left: 20,
                              right: 20,
                            ),
                            margin: EdgeInsets.only(
                              left: 16,
                              right: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xffFFEBCF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                CustomWidget().googleFontRobboto(
                                  AppLocalizations.of(context).translate(
                                      LanguageKeys.isPopcenterNoteTwo),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black,
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 3),
                                CustomWidget().googleFontRobboto(
                                  AppLocalizations.of(context).translate(
                                      LanguageKeys.isPopcenterNoteThree),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: PopboxColor.red,
                                  textAlign: TextAlign.left,
                                ),
                                CustomWidget().googleFontRobboto(
                                  AppLocalizations.of(context).translate(
                                      LanguageKeys.isPopcenterNoteFour),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black,
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.termCondition),
                                  softWrap: true,
                                  overflow: TextOverflow.clip,
                                  style: GoogleFonts.roboto(
                                    decoration: TextDecoration.underline,
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  : Container(),

              //ALERT
              (data.lastStatusInbound == "INBOUND_POPCENTER" ||
                      data.lastStatusInbound == "INBOUND_POPCENTER_LOCKER")
                  ? InkWell(
                      onTap: () {
                        showPopcenterInfo(context: context);
                      },
                      child: AlertInfoRectangleWidget(
                        text: AppLocalizations.of(context)
                            .translate(LanguageKeys.isPopcenterAlert),
                        bgColor: Color(0xffFFE9C9),
                        textColor: Color(0xffED8E00),
                      ),
                    )
                  : (data.lastStatusInbound == "OUTBOUND_POPCENTER")
                      ? AlertInfoRectangleWidget(
                          text: AppLocalizations.of(context)
                              .translate(LanguageKeys.popcenterAlertOutbound),
                          bgColor: Color(0xffCBF1E4),
                          textColor: Color(0xff1CAC77),
                        )
                      : Container(),
              SizedBox(height: 10),

              // INBOUND_POPCENTER
              (!isFree && data.lastStatusInbound == "INBOUND_POPCENTER" ||
                      !isFree &&
                          data.lastStatusInbound == "INBOUND_POPCENTER_LOCKER")
                  ? AlertInfoRectangleWidget(
                      text: AppLocalizations.of(context)
                          .translate(LanguageKeys.ppcAlertCollectNotFree),
                      bgColor: Color(0xffFFCECE),
                      textColor: Color(0xffFF0B09),
                    )
                  : Container(),
              SizedBox(height: 15),
              (data.lastStatusInbound == "INBOUND_POPCENTER" ||
                      data.lastStatusInbound == "INBOUND_POPCENTER_LOCKER")
                  ? InkWell(
                      onTap: () {
                        if (!isFree && data.inboundGroup != "PACKAGE_FOOD") {
                          showRulesPopcenter(context: context, data: data);
                        }
                      },
                      child: Container(
                        height: 102,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(left: 16.0, right: 16.0),
                        padding: EdgeInsets.only(left: 22),
                        decoration: BoxDecoration(
                            color: Color(0xffEAF3FF),
                            borderRadius: BorderRadius.circular(10)),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Image.asset(
                                "assets/images/ic_popcenter_pay.png",
                                fit: BoxFit.fitHeight,
                                width: 120,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomWidget().googleFontRobboto(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.collectionFee),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black,
                                  textAlign: TextAlign.center,
                                ),
                                CustomWidget().textBoldPlus(
                                    formatCurrency.format(pricePPC),
                                    PopboxColor.mdBlack1000,
                                    22,
                                    TextAlign.left),
                                isFree
                                    ? CustomWidget().googleFontRobboto(
                                        AppLocalizations.of(context).translate(
                                                LanguageKeys.collectionFee) +
                                            " : " +
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys.free),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10,
                                        color: Colors.black,
                                        textAlign: TextAlign.center,
                                      )
                                    : Row(
                                        children: [
                                          CustomWidget().googleFontRobboto(
                                            AppLocalizations.of(context)
                                                    .translate(LanguageKeys
                                                        .collectionFee) +
                                                " " +
                                                formatCurrency.format(
                                                    double.parse(data
                                                        .ppcInfo.pricePerDay)) +
                                                " / 24 " +
                                                AppLocalizations.of(context)
                                                    .translate(
                                                        LanguageKeys.hours),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 10,
                                            color: Colors.black,
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(width: 3),
                                          CustomWidget().googleFontRobboto(
                                            AppLocalizations.of(context)
                                                .translate(
                                                    LanguageKeys.learnMoreHere),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 10,
                                            color: Color(0xff477FFF),
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(height: 10),
              //CountDown & Remaining Take Time Limit
              ((data.lastStatusInbound == "INBOUND_POPCENTER" &&
                          isFree &&
                          data.inboundGroup != "PACKAGE_FOOD") ||
                      (data.lastStatusInbound == "INBOUND_POPCENTER_LOCKER" &&
                          isFree &&
                          data.inboundGroup != "PACKAGE_FOOD"))
                  ? Container(
                      width: 100.0.w,
                      height: 75,
                      margin: EdgeInsets.only(left: 16.0, right: 16.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomWidget().googleFontRobboto(
                                (data.ppcInfo.status == "no_ppc")
                                    ? AppLocalizations.of(context).translate(
                                        LanguageKeys.remainingCollectionTime)
                                    : (countRemainingFreeDay > 0)
                                        ? AppLocalizations.of(context)
                                            .translate(LanguageKeys
                                                .remainingFreeTimeLimit)
                                        : (double.parse(data
                                                        .ppcInfo.priceOverdue) >
                                                    0 &&
                                                data.lastStatusInbound !=
                                                    "OVERDUE" &&
                                                countryCode == "MY")
                                            ? AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .remainingCollectionTime)
                                            : AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .remainingCollectionTime),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.black,
                                textAlign: TextAlign.center,
                              ),
                              CustomWidget().googleFontRobboto(
                                (data.ppcInfo.status == "no_ppc")
                                    ? AppLocalizations.of(context).translate(
                                            LanguageKeys.collectionTimeLimit) +
                                        " " +
                                        data.expiredFreeTime
                                    : (data.ppcInfo.status == "no_ppc")
                                        ? AppLocalizations.of(context).translate(
                                                LanguageKeys.takeTimeLimit) +
                                            " " +
                                            data.expiredFreeTime
                                        : (data.ppcInfo.status == "ppc" &&
                                                data.ppcInfo.freeDays == 0 &&
                                                countryCode == "ID")
                                            ? ""
                                            : (double.parse(data.ppcInfo.priceOverdue) > 0 &&
                                                    data.lastStatusInbound !=
                                                        "OVERDUE")
                                                ? AppLocalizations.of(context).translate(LanguageKeys.collectionTimeLimit) +
                                                    " " +
                                                    data.expiredFreeTime
                                                : (double.parse(data.ppcInfo.priceOverdue) > 0 &&
                                                        data.lastStatusInbound ==
                                                            "OVERDUE" &&
                                                        countryCode == "MY")
                                                    ? AppLocalizations.of(context).translate(LanguageKeys.collectionTimeLimit) +
                                                        " " +
                                                        data.expiredFreeTime
                                                    : AppLocalizations.of(context)
                                                            .translate(
                                                                LanguageKeys.freeCollectBefore) +
                                                        " " +
                                                        data.ppcInfo.freeUntil,
                                fontWeight: FontWeight.w400,
                                fontSize: 10,
                                color: Color(0xffFF0B09),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          // Widget getDayHourMinutes
                          getDaysHoursMinutes(
                              context, Duration(seconds: countdownTimeParcel))
                        ],
                      ),
                    )
                  : Container(),
              SizedBox(height: 10),
              //CONTAIN
              Container(
                width: 100.0.w,
                margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 17.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.0,
                    color: PopboxColor.mdGrey300,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomWidget().googleFontRobboto(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.receiptNo),
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xff202020),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10.0),
                          CustomWidget().textBoldPlus(data.courierCompany ?? "",
                              PopboxColor.mdBlack1000, 14, TextAlign.left),
                        ],
                      ),
                      SizedBox(height: 7.0),
                      CustomWidget().textBoldPlus(data.awbNumber ?? "",
                          PopboxColor.mdBlack1000, 14, TextAlign.left),
                      Divider(
                        color: Color(0xffECE9E9),
                        thickness: 1,
                      ),
                      SizedBox(height: 20.0),
                      CustomWidget().googleFontRobboto(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.status),
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xff202020),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10.0),
                      SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            Row(
                              children: [
                                Container(
                                    decoration: ShapeDecoration(
                                      color: (data.lastStatusInbound ==
                                              "OUTBOUND_POPCENTER")
                                          ? Color(0xffCBF1E4)
                                          : (data.lastStatusInbound ==
                                                      "INBOUND_POPCENTER" ||
                                                  data.lastStatusInbound ==
                                                      "INBOUND_POPCENTER_LOCKER")
                                              ? Color(0xFFF8F8F8)
                                              : Color(0xffFFCECE),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, top: 2, bottom: 2),
                                    child: CustomWidget().googleFontRobboto(
                                      AppLocalizations.of(context).translate(
                                          data.lastStatusInbound.toLowerCase()),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: (data.lastStatusInbound ==
                                              "OUTBOUND_POPCENTER")
                                          ? Color(0xFF1CAC77)
                                          : (data.lastStatusInbound ==
                                                      "INBOUND_POPCENTER" ||
                                                  data.lastStatusInbound ==
                                                      "INBOUND_POPCENTER_LOCKER")
                                              ? Color(0xFF477FFF)
                                              : Color(0xffFF0B09),
                                      textAlign: TextAlign.center,
                                    )),
                                SizedBox(width: 10),
                                (isFree &&
                                        data.lastStatusInbound !=
                                            "OUTBOUND_POPCENTER")
                                    ? Container(
                                        decoration: ShapeDecoration(
                                          color: Color(0xffFFE9C9),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        padding: const EdgeInsets.only(
                                            left: 8,
                                            right: 8,
                                            top: 2,
                                            bottom: 2),
                                        child: CustomWidget().textLight(
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys.free),
                                            Color(0xffFF9D09),
                                            12,
                                            TextAlign.left),
                                      )
                                    : Container(),
                                SizedBox(width: 10),
                                (data.inboundGroup == "PACKAGE_FOOD")
                                    ? Container(
                                        decoration: ShapeDecoration(
                                          color: Color(0xffFFE9C9),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        padding: const EdgeInsets.only(
                                            left: 8,
                                            right: 8,
                                            top: 2,
                                            bottom: 2),
                                        child: CustomWidget().textLight(
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .foodAndBeverage),
                                            Color(0xffFF9D09),
                                            12,
                                            TextAlign.left),
                                      )
                                    : Container()
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Color(0xffECE9E9),
                        thickness: 1,
                      ),
                      SizedBox(height: 20.0),
                      CustomWidget().googleFontRobboto(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.location),
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xff202020),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomWidget().textBoldPlus(data.lastPopCenter.name,
                              PopboxColor.mdBlack1000, 14, TextAlign.left),
                          InkWell(
                              onTap: () async {
                                var lockerModel = Provider.of<LockerViewModel>(
                                    context,
                                    listen: false);

                                List<LockerData> lockerList =
                                    lockerModel.newLockerList;

                                try {
                                  LockerData lockerData = lockerList.firstWhere(
                                      (element) =>
                                          element.name.trim().toLowerCase() ==
                                          data.lastPopCenter.name
                                              .trim()
                                              .toLowerCase());

                                  if (lockerData.latitude != null &&
                                      lockerData.latitude != "" &&
                                      lockerData.latitude != "-") {
                                    if (Platform.isIOS) {
                                      await MapLauncher.launchMap(
                                        mapType: MapType.apple,
                                        coords: Coords(
                                            double.parse(lockerData.latitude),
                                            double.parse(lockerData.longitude)),
                                        title: lockerData.name,
                                        description: lockerData.address,
                                      );
                                    } else {
                                      await MapLauncher.launchMap(
                                        mapType: MapType.google,
                                        coords: Coords(
                                            double.parse(lockerData.latitude),
                                            double.parse(lockerData.longitude)),
                                        title: lockerData.name,
                                        description: lockerData.address,
                                      );
                                    }
                                  } else {
                                    CustomWidget().showToastShortV1(
                                        context: context,
                                        msg: AppLocalizations.of(context)
                                            .translate(LanguageKeys
                                                .canNotLoadLocation));
                                  }
                                } catch (e) {
                                  CustomWidget().showToastShortV1(
                                      context: context,
                                      msg: AppLocalizations.of(context)
                                          .translate(
                                              LanguageKeys.canNotLoadLocation));
                                }
                              },
                              child: Image.asset(
                                "assets/images/ic_location_more.png",
                                color: Color(0xff477FFF),
                              )),
                        ],
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
              //Tracking
              InkWell(
                onTap: () {
                  showTrackingPopcenter(
                    context: context,
                    data: data,
                  );
                },
                child: Container(
                  width: 100.0.w,
                  margin: EdgeInsets.only(left: 16.0, right: 16.0),
                  padding:
                      EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
                  decoration: BoxDecoration(
                    color: Color(0xffF9F9F9),
                    border: Border.all(
                      width: 1.0,
                      color: Color(0xffF9F9F9),
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomWidget().textBoldPlus(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.tracking),
                        PopboxColor.mdGrey900,
                        11.0.sp,
                        TextAlign.left,
                      ),
                      Icon(Icons.arrow_forward_ios_sharp, size: 15),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              (data.lastStatusInbound == "INBOUND_POPCENTER" ||
                      data.lastStatusInbound == "INBOUND_POPCENTER_LOCKER")
                  ? InkWell(
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
                      //ondevrafi
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(left: 20, right: 20),
                        padding: EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        decoration: BoxDecoration(
                            color: Color(0xffFFEBCF),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomWidget().googleFontRobboto(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.isPopcenterNoteTwo),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.black,
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 3),
                            CustomWidget().googleFontRobboto(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.isPopcenterNoteThree),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: PopboxColor.red,
                              textAlign: TextAlign.left,
                            ),
                            CustomWidget().googleFontRobboto(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.isPopcenterNoteFour),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.black,
                              textAlign: TextAlign.left,
                            ),
                            Text(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.termCondition),
                              softWrap: true,
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.roboto(
                                decoration: TextDecoration.underline,
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(height: 15),
              InkWell(
                onTap: () {
                  callCsBottomSheet(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info, color: Color(0xFFFF9C08)),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: AppLocalizations.of(context)
                                .translate(LanguageKeys.havingProblem),
                            style: TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 12,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: AppLocalizations.of(context).translate(
                                LanguageKeys.callPopboxCustomerService),
                            style: TextStyle(
                              color: Color(0xFF477FFF),
                              fontSize: 12,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ]),
      );
    } else {
      return cartShimmerView(context);
    }
  }

  Widget parcelViewNew(BuildContext context, ParcelHistoryDetailData data,
      DataComparePayment dataComparePayment) {
    print('logy> parcelViewNew : ' + data.type);
    //print('logy> dataComparePayment : '+dataComparePayment.totalAmount.toString());

    setCurrency();
    //DATE TIME DIFFERENCE
    int countStoreDayParcel = 0;
    int countRemainingFreeDay = 0;
    double xFreeDays = 0;
    double pricePPC = 0;
    bool isFree = false;

    if (data != null) {
      DateTime now = DateTime.now();
      String dateTimeNowFormated =
          DateFormat('dd MMM yyyy HH:mm:ss').format(now);
      final formatedTime = DateFormat('dd MMM yyyy HH:mm:ss');
      final nowtime = formatedTime.parse(dateTimeNowFormated);

      countStoreDayParcel =
          nowtime.difference(formatedTime.parse(data.storeTime)).inDays;

      print('countStoreDay' + countStoreDayParcel.toString());
      if (data.ppcInfo.status == "ppc") {
        if (countryCode == "MY") {
          if (double.parse(data.ppcInfo.priceOverdue) == 0) {
          } else if (double.parse(data.ppcInfo.priceOverdue) > 0 &&
              data.status != "OVERDUE") {
          } else if (double.parse(data.ppcInfo.priceOverdue) > 0 &&
              data.status == "OVERDUE") {
          } else {
            //nothing
          }
        } else {
          countRemainingFreeDay = formatedTime
              .parse(data.ppcInfo.freeUntil)
              .difference(nowtime)
              .inSeconds;
          print("debug rafi ==> " + countRemainingFreeDay.toString());
          countdownTimeParcel = formatedTime
              .parse(data.ppcInfo.freeUntil)
              .difference(nowtime)
              .inSeconds;
        }

        if (data.ppcInfo.ppcType == "dinamic") {
          if (data.status == "COMPLETED" ||
              data.status == "OPERATOR_TAKEN" ||
              data.status == "COURIER_TAKEN") {
            xFreeDays = (formatedTime
                    .parse(data.takeTime)
                    .difference(formatedTime.parse(data.storeTime))
                    .inDays) -
                data.ppcInfo.freeDays.toDouble() +
                1;
          } else {
            xFreeDays = (nowtime
                    .difference(formatedTime.parse(data.storeTime))
                    .inDays) -
                data.ppcInfo.freeDays.toDouble() +
                1;
          }

          if (xFreeDays <= 0) {
            isFree = true;
          } else if (xFreeDays > data.ppcInfo.maxDay) {
            isFree = false;
            // pricePPC = (data.ppcInfo.maxDay - data.ppcInfo.freeDays) *
            //     double.parse(data.ppcInfo.pricePerDay);
            var priceA = ((nowtime
                            .difference(formatedTime.parse(data.storeTime))
                            .inHours -
                        data.ppcInfo.freeDays) /
                    24)
                .ceilToDouble();
            if (priceA > data.ppcInfo.maxDay) {
              pricePPC =
                  data.ppcInfo.maxDay * double.parse(data.ppcInfo.pricePerDay);
              totalPricePPC =
                  data.ppcInfo.maxDay * double.parse(data.ppcInfo.pricePerDay);
              convertedValue = totalPricePPC.toInt();
            } else if (priceA < data.ppcInfo.maxDay) {
              pricePPC = priceA * double.parse(data.ppcInfo.pricePerDay);
              totalPricePPC = priceA * double.parse(data.ppcInfo.pricePerDay);
              convertedValue = totalPricePPC.toInt();
            }

            print("CEK DEV ${pricePPC.toString()}");
            print("CEK DEV2 ${priceA.toString()}");
          } else {
            isFree = false;
            pricePPC = xFreeDays * double.parse(data.ppcInfo.pricePerDay);
            totalPricePPC = xFreeDays * double.parse(data.ppcInfo.pricePerDay);
            convertedValue = totalPricePPC.toInt();
          }
        } else if (data.ppcInfo.ppcType == "fixed" ||
            data.ppcInfo.ppcType == "flat") {
          if (data.ppcInfo.freeDays < 1) {
            if (data.status != "OVERDUE") {
              pricePPC = double.parse(data.ppcInfo.priceInstore);
              totalPricePPC = double.parse(data.ppcInfo.priceInstore);
              convertedValue = totalPricePPC.toInt();
            } else if (data.status == "OVERDUE") {
              pricePPC = double.parse(data.ppcInfo.priceInstore) +
                  double.parse(data.ppcInfo.priceOverdue);
              totalPricePPC = double.parse(data.ppcInfo.priceInstore) +
                  double.parse(data.ppcInfo.priceOverdue);
              convertedValue = totalPricePPC.toInt();
            }
          } else {
            if (countStoreDayParcel <= data.ppcInfo.freeDays) {
              pricePPC = 0;
              totalPricePPC = 0;
            } else {
              if (data.status != "OVERDUE") {
                pricePPC = double.parse(data.ppcInfo.priceInstore);
                totalPricePPC = double.parse(data.ppcInfo.priceInstore);
                convertedValue = totalPricePPC.toInt();
              } else if (data.status == "OVERDUE") {
                pricePPC = double.parse(data.ppcInfo.priceInstore) +
                    double.parse(data.ppcInfo.priceOverdue);
                totalPricePPC = double.parse(data.ppcInfo.priceInstore) +
                    double.parse(data.ppcInfo.priceOverdue);
                convertedValue = totalPricePPC.toInt();
              }
            }
          }
        } else {
          //else
        }

        if (countdownTimeParcel < 0) {
          countdownTimeParcel = 0;
        }
      }
      //NO PPC
      if (data.ppcInfo.status == "no_ppc") {
        isFree = true;
        countdownTimeParcel =
            formatedTime.parse(data.overdueTime).difference(nowtime).inSeconds;
        if (countdownTimeParcel < 0) {
          countdownTimeParcel = 0;
        }
      } else if ((double.parse(data.ppcInfo.priceOverdue) > 0 &&
          data.status != "OVERDUE")) {
        countdownTimeParcel =
            formatedTime.parse(data.overdueTime).difference(nowtime).inSeconds;
        if (countdownTimeParcel < 0) {
          countdownTimeParcel = 0;
        }
      } else {}
      if (data.status == "TAKEN" || data.status == "COMPLETED") {
        countdownTimeParcel = 0;
      }
      //
    }

    if (data != null) {
      if (data.type == "lastmile") {
        //lastmileView
        print('log> totalPricePPC: ' + totalPricePPC.toString());
        print('log> status: ' + data.status.toString());
        print('log> ppcInfo status: ' + data.ppcInfo.status.toString());
        print('log> ppcInfo freeDays: ' + data.ppcInfo.freeDays.toString());
        print('log> ppcInfo priceOverdue: ' +
            data.ppcInfo.priceOverdue.toString());
        print('log> ppcInfo priceOverdue: ' + countryCode.toString());

        convertedValue = totalPricePPC.toInt();

        print('log> totalPricePPC cnvrt: ' + convertedValue.toString());
        print('log> totalAmount: ' + totalAmount.toString());
        if (dataComparePayment != null) {
          print('log> anchor 1');

          if (dataComparePayment.totalAmount <= convertedValue) {
            print('log> anchor 2a');
            //return PaidPaymentParcelView(context);
          }
          if (dataComparePayment.totalAmount >= convertedValue) {
            print('log> anchor 2');
            isPaid = true;
            //return PaidPaymentParcelView(context);
          } else {
            print('log> anchor 3');
          }
        } else {
          print('log> anchor 4');
        }
//         if(dataComparePayment!= null){
//           if(dataComparePayment.totalAmount >= convertedValue){
//             print('log> here  lastmileView ');
//             return Stack(
//               children: [
//                 ListView(scrollDirection: Axis.vertical, children: [
//                   Column(
//                     children: [
//                       SizedBox(height: 20.0),
//                       //ALERT
//                       RegExp(r'WAREHOUSE|warehouse').hasMatch(data.status)
//                           ? Container()
//                           : (data.ppcInfo.status == "no_ppc" &&
//                           data.status == "OVERDUE")
//                           ? Column(
//                         children: [
//
//                           Container(
//                             width: MediaQuery.of(context).size.width,
//                             padding: EdgeInsets.only(
//                                 left: 10,
//                                 right: 10,
//                                 top: 15,
//                                 bottom: 15),
//                             margin: EdgeInsets.only(
//                                 left: 20,
//                                 right: 20,
//                                 top: 10,
//                                 bottom: 10),
//                             decoration: BoxDecoration(
//                               color: Color(0xffFFF3E0),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: CustomWidget().googleFontRobboto(
//                               AppLocalizations.of(context).translate(
//                                   LanguageKeys
//                                       .notesPopsafeTransDetailisOverdue),
//                               fontWeight: FontWeight.w700,
//                               fontSize: 10,
//                               color: Color(0xffE38800),
//                               textAlign: TextAlign.left,
//                             ),
//                           )
//                         ],
//                       )
//                           : (data.status == "COMPLETED")
//                           ? AlertInfoRectangleWidget(
//                         text: AppLocalizations.of(context)
//                             .translate(LanguageKeys
//                             .popcenterAlertOutbound),
//                         bgColor: Color(0xffCBF1E4),
//                         textColor: Color(0xff1CAC77),
//                       )
//                           : (data.status == "COURIER_TAKEN" ||
//                           data.status == "OPERATOR_TAKEN")
//                           ? Column(
//                         children: [
//
//                           Container(
//                             width: MediaQuery.of(context)
//                                 .size
//                                 .width,
//                             padding: EdgeInsets.only(
//                                 left: 10,
//                                 right: 10,
//                                 top: 15,
//                                 bottom: 15),
//                             margin: EdgeInsets.only(
//                                 left: 20,
//                                 right: 20,
//                                 top: 10,
//                                 bottom: 10),
//                             decoration: BoxDecoration(
//                               color: Color(0xffFFF3E0),
//                               borderRadius:
//                               BorderRadius.circular(10),
//                             ),
//                             child: CustomWidget()
//                                 .googleFontRobboto(
//                               AppLocalizations.of(context)
//                                   .translate(LanguageKeys
//                                   .notesPopsafeTransDetailisOverdue),
//                               fontWeight: FontWeight.w700,
//                               fontSize: 10,
//                               color: Color(0xffE38800),
//                               textAlign: TextAlign.left,
//                             ),
//                           )
//                         ],
//                       )
//                           : (data.ppcInfo.status == "no_ppc" &&
//                           data.status ==
//                               "READY FOR PICKUP" ||
//                           data.status == "IN_STORE")
//                           ? Container()
//                           : (data.ppcInfo.status == "no_ppc" &&
//                           data.status != "OVERDUE")
//                           ? AlertInfoRectangleWidget(
//                         text: AppLocalizations.of(
//                             context)
//                             .translate(LanguageKeys
//                             .ppcAlertCollectOnFree),
//                         bgColor: Color(0xff477FFF),
//                         textColor: Colors.white,
//                       )
//                           : (data.ppcInfo.status == "ppc" &&
//                           countRemainingFreeDay < 0 &&
//                           countryCode == "ID") //PAID
//                           ? Column(
//                         children: [
//                           (data.status == "OVERDUE")
//                               ?
//                           Container() :
//                           SizedBox(height: 7),
//                         ],
//                       )
//                           : (data.ppcInfo.status == "ppc" &&
//                           countRemainingFreeDay >
//                               0 &&
//                           countryCode == "ID")
//                       //FREE
//                           ? AlertInfoRectangleWidget(
//                         text: AppLocalizations
//                             .of(context)
//                             .translate(LanguageKeys
//                             .ppcAlertCollectOnFree),
//                         bgColor:
//                         Color(0xff477FFF),
//                         textColor: Colors.white,
//                       )
//                       //#04
//                           : (double.parse(data.ppcInfo
//                           .priceOverdue) ==
//                           0 &&
//                           countryCode == "MY")
//                           ? AlertInfoRectangleWidget(
//                         text: AppLocalizations
//                             .of(context)
//                             .translate(
//                             LanguageKeys
//                                 .ppcAlertCollectNotFree),
//                         bgColor: Color(
//                             0xffFF0B09),
//                         textColor:
//                         Colors.white,
//                       )
//                       //#5 - satu
//                           : (double.parse(data
//                           .ppcInfo
//                           .priceOverdue) >
//                           0 &&
//                           data.status !=
//                               "OVERDUE" &&
//                           countryCode ==
//                               "MY")
//                           ? AlertInfoRectangleWidget(
//                         text: AppLocalizations.of(
//                             context)
//                             .translate(
//                             LanguageKeys
//                                 .ppcFlatMYRuleNonFreeNote),
//                         bgColor: Color(
//                             0xff477FFF),
//                         textColor:
//                         Colors
//                             .white,
//                       )
//                           : (double.parse(data.ppcInfo.priceOverdue) > 0 &&
//                           data.status ==
//                               "OVERDUE" &&
//                           countryCode ==
//                               "MY")
//                           ?
//                       Container(
//                         width: 100.0.w,
//                         height: 75,
//                         margin: EdgeInsets.only(
//                             left: 16.0, right: 16.0),
//                         decoration: BoxDecoration(
//                           color: Color(0xffF7F7F7),
//                           borderRadius:
//                           BorderRadius.circular(10),
//                         ),
//                         child: Row(
//                           mainAxisAlignment:
//                           MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Column(
//                               mainAxisAlignment:
//                               MainAxisAlignment.center,
//                               crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                               children: [
//                                 CustomWidget()
//                                     .googleFontRobboto(
//                                   (data.ppcInfo.status ==
//                                       "no_ppc")
//                                       ? AppLocalizations.of(context)
//                                       .translate(LanguageKeys
//                                       .remainingCollectionTime)
//                                       : (countRemainingFreeDay >
//                                       0)
//                                       ? AppLocalizations.of(context)
//                                       .translate(LanguageKeys
//                                       .remainingFreeTimeLimit)
//                                       : (double.parse(data.ppcInfo.priceOverdue) > 0 &&
//                                       data.status !=
//                                           "OVERDUE" &&
//                                       countryCode ==
//                                           "MY")
//                                       ? AppLocalizations.of(
//                                       context)
//                                       .translate(
//                                       LanguageKeys
//                                           .remainingCollectionTime)
//                                       : AppLocalizations.of(
//                                       context)
//                                       .translate(
//                                       LanguageKeys.remainingCollectionTime),
//                                   fontWeight: FontWeight.w700,
//                                   fontSize: 14,
//                                   color: Colors.black,
//                                   textAlign: TextAlign.left,
//                                 ),
//                                 CustomWidget()
//                                     .googleFontRobboto(
//                                   (data.ppcInfo.status ==
//                                       "no_ppc")
//                                       ? AppLocalizations.of(context)
//                                       .translate(
//                                       LanguageKeys
//                                           .collectionTimeLimit) +
//                                       " " +
//                                       data.overdueTime
//                                       : (data.ppcInfo.status ==
//                                       "no_ppc")
//                                       ? AppLocalizations.of(context).translate(LanguageKeys.takeTimeLimit) +
//                                       " " +
//                                       data.overdueTime
//                                       : (data.ppcInfo.status ==
//                                       "ppc" &&
//                                       data.ppcInfo.freeDays ==
//                                           0 &&
//                                       countryCode ==
//                                           "ID")
//                                       ? ""
//                                       : (double.parse(data.ppcInfo.priceOverdue) >
//                                       0 &&
//                                       data.status !=
//                                           "OVERDUE")
//                                       ? AppLocalizations.of(context).translate(LanguageKeys.collectionTimeLimit) +
//                                       " " +
//                                       data
//                                           .overdueTime
//                                       : (double.parse(data.ppcInfo.priceOverdue) > 0 &&
//                                       data.status == "OVERDUE" &&
//                                       countryCode == "MY")
//                                       ? AppLocalizations.of(context).translate(LanguageKeys.collectionTimeLimit) + " " + data.overdueTime
//                                       : AppLocalizations.of(context).translate(LanguageKeys.freeCollectBefore) + " " + data.ppcInfo.freeUntil,
//                                   fontWeight: FontWeight.w400,
//                                   fontSize: 10,
//                                   color: Color(0xffFF0B09),
//                                   textAlign: TextAlign.left,
//                                 ),
//                               ],
//                             ),
//                             //Widget getDayHourMinutes
//                             getDaysHoursMinutes(
//                                 context,
//                                 Duration(
//                                     seconds:
//                                     countdownTimeParcel))
//                           ],
//                         ),
//                       )
//                       //TO DO
//                           : Container(),
//
//                       SizedBox(height: 15),
//
//                       //QR CODE
//                       (data.status == "COMPLETED" || data.status == "DESTROY")
//                           ? Container()
//                           : Padding(
//                         padding: const EdgeInsets.only(left: 20, right: 20),
//                         child: Stack(
//                           children: [
//                             Image.asset(
//                               "assets/images/ic_box_blue.png",
//                               fit: BoxFit.fitHeight,
//                               width: MediaQuery.of(context).size.width,
//                             ),
//                             Container(
//                               height: 70,
//                               padding: const EdgeInsets.only(
//                                   left: 10, right: 10),
//                               child: Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     mainAxisAlignment:
//                                     MainAxisAlignment.center,
//                                     children: [
//                                       CustomWidget().googleFontRobboto(
//                                         AppLocalizations.of(context)
//                                             .translate(
//                                             LanguageKeys.collectionCode)
//                                             .toUpperCase(),
//                                         fontWeight: FontWeight.w700,
//                                         fontSize: 14,
//                                         color: Colors.white,
//                                         textAlign: TextAlign.left,
//                                       ),
//                                       InkWell(
//                                         onTap: () {
//                                           showDialog(
//                                               context: context,
//                                               builder:
//                                                   (BuildContext context) {
//                                                 return CustomDialogBox(
//                                                   title: data.pin,
//                                                 );
//                                               });
//                                         },
//                                         child: CustomWidget()
//                                             .googleFontRobboto(
//                                           AppLocalizations.of(context)
//                                               .translate(LanguageKeys
//                                               .clickForSeeQR),
//                                           fontWeight: FontWeight.w400,
//                                           fontSize: 10,
//                                           color: Color(0xff00137D),
//                                           textAlign: TextAlign.left,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   CustomWidget().googleFontRobboto(
//                                     data.pin,
//                                     fontWeight: FontWeight.w700,
//                                     fontSize: 22,
//                                     color: Colors.white,
//                                     textAlign: TextAlign.left,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       (dataComparePayment.totalAmount.toString() == convertedValue.toString()) ?
//                       Column(
//                         children: [
//                           SizedBox(height: 12),
//                           Container(
//                             width: 100.0.w,
//                             height: 75,
//                             margin: EdgeInsets.only(
//                                 left: 16.0, right: 16.0),
//                             decoration: BoxDecoration(
//                               color: Color(0xffF7F7F7),
//                               borderRadius:
//                               BorderRadius.circular(10),
//                             ),
//                             child: Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceEvenly,
//                               children: [
//                                 Column(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.center,
//                                   crossAxisAlignment:
//                                   CrossAxisAlignment.start,
//                                   children: [
//                                     CustomWidget()
//                                         .googleFontRobboto(
//                                       (data.ppcInfo.status ==
//                                           "no_ppc")
//                                           ? AppLocalizations.of(context)
//                                           .translate(LanguageKeys
//                                           .remainingCollectionTime)
//                                           : (countRemainingFreeDay >
//                                           0)
//                                           ? AppLocalizations.of(context)
//                                           .translate(LanguageKeys
//                                           .remainingFreeTimeLimit)
//                                           : (double.parse(data.ppcInfo.priceOverdue) > 0 &&
//                                           data.status !=
//                                               "OVERDUE" &&
//                                           countryCode ==
//                                               "MY")
//                                           ? AppLocalizations.of(
//                                           context)
//                                           .translate(
//                                           LanguageKeys
//                                               .remainingCollectionTime)
//                                           : AppLocalizations.of(
//                                           context)
//                                           .translate(
//                                           LanguageKeys.remainingCollectionTime),
//                                       fontWeight: FontWeight.w700,
//                                       fontSize: 14,
//                                       color: Colors.black,
//                                       textAlign: TextAlign.left,
//                                     ),
//                                     CustomWidget()
//                                         .googleFontRobboto(
//                                       (data.ppcInfo.status ==
//                                           "no_ppc")
//                                           ? AppLocalizations.of(context)
//                                           .translate(
//                                           LanguageKeys
//                                               .collectionTimeLimit) +
//                                           " " +
//                                           data.overdueTime
//                                           : (data.ppcInfo.status ==
//                                           "no_ppc")
//                                           ? AppLocalizations.of(context).translate(LanguageKeys.takeTimeLimit) +
//                                           " " +
//                                           data.overdueTime
//                                           : (data.ppcInfo.status ==
//                                           "ppc" &&
//                                           data.ppcInfo.freeDays ==
//                                               0 &&
//                                           countryCode ==
//                                               "ID")
//                                           ? ""
//                                           : (double.parse(data.ppcInfo.priceOverdue) >
//                                           0 &&
//                                           data.status !=
//                                               "OVERDUE")
//                                           ? AppLocalizations.of(context).translate(LanguageKeys.collectionTimeLimit) +
//                                           " " +
//                                           data
//                                               .overdueTime
//                                           : (double.parse(data.ppcInfo.priceOverdue) > 0 &&
//                                           data.status == "OVERDUE" &&
//                                           countryCode == "MY")
//                                           ? AppLocalizations.of(context).translate(LanguageKeys.collectionTimeLimit) + " " + data.overdueTime
//                                           : AppLocalizations.of(context).translate(LanguageKeys.freeCollectBefore) + " " + data.ppcInfo.freeUntil,
//                                       fontWeight: FontWeight.w400,
//                                       fontSize: 10,
//                                       color: Color(0xffFF0B09),
//                                       textAlign: TextAlign.left,
//                                     ),
//                                   ],
//                                 ),
//                                 //Widget getDayHourMinutes
//                                 getDaysHoursMinutes(
//                                     context,
//                                     Duration(
//                                         seconds:
//                                         countdownTimeParcel))
//                               ],
//                             ),
//                           )
//                         ],
//                       )
//                           :
//                       (data.ppcInfo.status == "ppc" &&
//                           data.ppcInfo.freeDays == 0 &&
//                           countryCode == "ID")
//                           ? Container()
//                           : (double.parse(data.ppcInfo.priceOverdue) == 0 &&
//                           countryCode == "MY" &&
//                           data.ppcInfo.status == "ppc")
//                           ? Container()
//                           : (data.status == "COMPLETED" ||
//                           data.status == "DESTROY" ||
//                           data.status == "OPERATOR_TAKEN" ||
//                           data.status == "COURIER_TAKEN")
//                           ? Container()
//                           : (data.status == "OVERDUE" &&
//                           data.ppcInfo.status == "no_ppc")
//                           ? Container()
//                           :
//                       //CountDown & Remaining Take Time Limit
//                       Container(
//                         width: 100.0.w,
//                         height: 75,
//                         margin: EdgeInsets.only(
//                             left: 16.0, right: 16.0),
//                         decoration: BoxDecoration(
//                           color: Color(0xffF7F7F7),
//                           borderRadius:
//                           BorderRadius.circular(10),
//                         ),
//                         child: Row(
//                           mainAxisAlignment:
//                           MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Column(
//                               mainAxisAlignment:
//                               MainAxisAlignment.center,
//                               crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                               children: [
//                                 CustomWidget()
//                                     .googleFontRobboto(
//                                   (data.ppcInfo.status ==
//                                       "no_ppc")
//                                       ? AppLocalizations.of(context)
//                                       .translate(LanguageKeys
//                                       .remainingCollectionTime)
//                                       : (countRemainingFreeDay >
//                                       0)
//                                       ? AppLocalizations.of(context)
//                                       .translate(LanguageKeys
//                                       .remainingFreeTimeLimit)
//                                       : (double.parse(data.ppcInfo.priceOverdue) > 0 &&
//                                       data.status !=
//                                           "OVERDUE" &&
//                                       countryCode ==
//                                           "MY")
//                                       ? AppLocalizations.of(
//                                       context)
//                                       .translate(
//                                       LanguageKeys
//                                           .remainingCollectionTime)
//                                       : AppLocalizations.of(
//                                       context)
//                                       .translate(
//                                       LanguageKeys.remainingCollectionTime),
//                                   fontWeight: FontWeight.w700,
//                                   fontSize: 14,
//                                   color: Colors.black,
//                                   textAlign: TextAlign.left,
//                                 ),
//                                 CustomWidget()
//                                     .googleFontRobboto(
//                                   (data.ppcInfo.status ==
//                                       "no_ppc")
//                                       ? AppLocalizations.of(context)
//                                       .translate(
//                                       LanguageKeys
//                                           .collectionTimeLimit) +
//                                       " " +
//                                       data.overdueTime
//                                       : (data.ppcInfo.status ==
//                                       "no_ppc")
//                                       ? AppLocalizations.of(context).translate(LanguageKeys.takeTimeLimit) +
//                                       " " +
//                                       data.overdueTime
//                                       : (data.ppcInfo.status ==
//                                       "ppc" &&
//                                       data.ppcInfo.freeDays ==
//                                           0 &&
//                                       countryCode ==
//                                           "ID")
//                                       ? ""
//                                       : (double.parse(data.ppcInfo.priceOverdue) >
//                                       0 &&
//                                       data.status !=
//                                           "OVERDUE")
//                                       ? AppLocalizations.of(context).translate(LanguageKeys.collectionTimeLimit) +
//                                       " " +
//                                       data
//                                           .overdueTime
//                                       : (double.parse(data.ppcInfo.priceOverdue) > 0 &&
//                                       data.status == "OVERDUE" &&
//                                       countryCode == "MY")
//                                       ? AppLocalizations.of(context).translate(LanguageKeys.collectionTimeLimit) + " " + data.overdueTime
//                                       : AppLocalizations.of(context).translate(LanguageKeys.freeCollectBefore) + " " + data.ppcInfo.freeUntil,
//                                   fontWeight: FontWeight.w400,
//                                   fontSize: 10,
//                                   color: Color(0xffFF0B09),
//                                   textAlign: TextAlign.left,
//                                 ),
//                               ],
//                             ),
//                             //Widget getDayHourMinutes
//                             getDaysHoursMinutes(
//                                 context,
//                                 Duration(
//                                     seconds:
//                                     countdownTimeParcel))
//                           ],
//                         ),
//                       ),
//
//                       SizedBox(height: 12),
//                       (data.ppcInfo.status == "no_ppc" &&
//                           data.status == "IN_STORE" ||
//                           data.ppcInfo.status == "no_ppc" &&
//                               data.status == "READY FOR PICKUP")
//                           ? Container(
//                         width: MediaQuery.of(context).size.width,
//                         padding: EdgeInsets.only(
//                             left: 10, right: 10, top: 15, bottom: 15),
//                         margin: EdgeInsets.only(
//                             left: 20, right: 20, top: 0, bottom: 10),
//                         decoration: BoxDecoration(
//                           color: Color(0xffFFF3E0),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: CustomWidget().googleFontRobboto(
//                           AppLocalizations.of(context)
//                               .translate(LanguageKeys.noppcAlertInstore),
//                           fontWeight: FontWeight.w700,
//                           fontSize: 10,
//                           color: Color(0xffE38800),
//                           textAlign: TextAlign.left,
//                         ),
//                       )
//                           : Container(),
//                       //Collection Fee
//                       //ondevrafi
//                       (data.status == "COMPLETED" ||
//                           (data.status == "READY FOR PICKUP" &&
//                               data.ppcInfo.status == "no_ppc"))
//                           ? Container()
//                           : InkWell(
//                         onTap: () {
//                           if (data.ppcInfo.status == "ppc" &&
//                               isFree &&
//                               countryCode == "ID") {
//                             showRulesWareHouseFreeDay(
//                                 context: context, data: data);
//                           } else if (countryCode == "MY" &&
//                               data.ppcInfo.priceOverdue != "0") {
//                             print("11111");
//                             showPPCFlatMYNonFree(
//                                 context: context,
//                                 pricePPC: pricePPC,
//                                 data: data);
//                           } else if (countryCode == "MY" &&
//                               data.ppcInfo.priceOverdue == "0") {
//                             print("222222");
//                             showPPCFlatMY(
//                                 context: context, pricePPC: pricePPC);
//                           } else {
//                             print("33333");
//                             showPPCnofreeday(context: context, data: data);
//                           }
//                         },
//                         child: Container(
//                         ),
//                       ),
//
//                       (data.status == "COMPLETED" || data.status == "DESTROY")
//                           ? Container()
//                           : (data.ppcInfo.status == "no_ppc")
//                           ? InkWell(
//                         onTap: () {
//                           showRulesWareHouse(
//                             context: context,
//                             data: data,
//                           );
//                         },
//                         child: Container(
//                           margin: EdgeInsets.only(left: 16, right: 16),
//                           child: Column(
//                             crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                             children: [
//                               CustomWidget().textLight(
//                                 (data.status == "OVERDUE")
//                                     ? AppLocalizations.of(context)
//                                     .translate(LanguageKeys
//                                     .nonPPCNotesOverdue)
//                                     : AppLocalizations.of(context)
//                                     .translate(LanguageKeys
//                                     .nonPPCNotesNoOverdue),
//                                 Colors.black,
//                                 10,
//                                 TextAlign.left,
//                               ),
//                               SizedBox(height: 5),
//                               CustomWidget().textLight(
//                                 AppLocalizations.of(context).translate(
//                                     LanguageKeys.learnMoreHere),
//                                 Color(0xff477FFF),
//                                 10,
//                                 TextAlign.left,
//                               ),
//                               SizedBox(height: 20),
//                             ],
//                           ),
//                         ),
//                       )
//                           : Container(),
//                       SizedBox(height: 10),
//
//                       //CONTAIN
//                       Container(
//                         width: 100.0.w,
//                         margin: EdgeInsets.only(
//                             left: 16.0, right: 16.0, bottom: 17.0),
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             width: 1.0,
//                             color: PopboxColor.mdGrey300,
//                           ),
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10.0),
//                           ),
//                         ),
//                         child: Container(
//                           margin: EdgeInsets.only(left: 16.0, right: 16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               SizedBox(height: 20.0),
//
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   CustomWidget().googleFontRobboto(
//                                     AppLocalizations.of(context)
//                                         .translate(LanguageKeys.receiptNo),
//                                     fontWeight: FontWeight.w400,
//                                     fontSize: 12,
//                                     color: Colors.black,
//                                     textAlign: TextAlign.left,
//                                   ),
//                                   CustomWidget().textBold(
//                                       data.logisticCompany.name.toString(),
//                                       PopboxColor.mdBlack1000,
//                                       14,
//                                       TextAlign.left),
//                                 ],
//                               ),
//                               SizedBox(height: 7.0),
//
//                               CustomWidget().googleFontRobboto(
//                                 data.orderNumber,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 15,
//                                 color: Colors.black,
//                                 textAlign: TextAlign.left,
//                               ),
//                               Divider(color: Colors.grey),
//                               SizedBox(height: 20.0),
//                               CustomWidget().googleFontRobboto(
//                                 AppLocalizations.of(context)
//                                     .translate(LanguageKeys.status),
//                                 fontWeight: FontWeight.w400,
//                                 fontSize: 12,
//                                 color: Colors.black,
//                                 textAlign: TextAlign.left,
//                               ),
//                               SizedBox(height: 7.0),
//                               Row(
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.all(5),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(10),
//                                       color: Color(0xffEAF3FF),
//                                     ),
//                                     child: CustomWidget().googleFontRobboto(
//                                       AppLocalizations.of(context)
//                                           .translate(LanguageKeys.instore
//                                           .toLowerCase()
//                                           .replaceAll(" ", ""))
//                                           .toUpperCase(),
//                                       fontWeight: FontWeight.w700,
//                                       fontSize: 10,
//                                       color: Color(0xff477FFF),
//                                       textAlign: TextAlign.left,
//                                     ),
//                                   ),
//                                   SizedBox(width: 10),
//                                   RegExp(r'WAREHOUSE|warehouse')
//                                       .hasMatch(data.status)
//                                       ? Container()
//                                       : isFree
//                                       ? CustomWidget().textLight(
//                                       (data.ppcInfo.freeDays != 0)
//                                           ? AppLocalizations.of(context).translate(LanguageKeys.free) +
//                                           " " +
//                                           data.ppcInfo.freeDays
//                                               .toString() +
//                                           " " +
//                                           AppLocalizations.of(context)
//                                               .translate(
//                                               LanguageKeys.day)
//                                           : AppLocalizations.of(context).translate(
//                                           LanguageKeys.free),
//                                       Color(0xffFF9D09),
//                                       12,
//                                       TextAlign.left)
//                                       : (data.ppcInfo.freeDays == 0 &&
//                                       data.ppcInfo.status == "ppc")
//                                       ? (double.parse(data.ppcInfo.priceOverdue) == 0 &&
//                                       countryCode == "MY")
//                                       ? Container()
//                                       : (countryCode == "MY" &&
//                                       data.ppcInfo.status ==
//                                           "ppc" &&
//                                       data.ppcInfo.priceInstore ==
//                                           "0" &&
//                                       data.status !=
//                                           "OVERDUE")
//                                       ? CustomWidget().textLight(
//                                       AppLocalizations.of(context).translate(LanguageKeys.free),
//                                       Color(0xffFF9D09),
//                                       12,
//                                       TextAlign.left)
//                                       : (double.parse(data.ppcInfo.priceOverdue) > 0 && data.status != "OVERDUE" && countryCode == "MY")
//                                       ? Container()
//                                       : (double.parse(data.ppcInfo.priceOverdue) > 0 && data.status == "OVERDUE" && countryCode == "MY")
//                                       ? Container()
//                                       : CustomWidget().textLight("PPC", Color(0xffFF9D09), 12, TextAlign.left)
//                                       : Container(),
//                                 ],
//                               ),
//
//                               Divider(color: Colors.grey),
//                               SizedBox(height: 20.0),
//                               CustomWidget().googleFontRobboto(
//                                 AppLocalizations.of(context)
//                                     .translate(LanguageKeys.location),
//                                 fontWeight: FontWeight.w400,
//                                 fontSize: 12,
//                                 color: Colors.black,
//                                 textAlign: TextAlign.left,
//                               ),
//                               SizedBox(height: 7.0),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Container(
//                                     width: 60.0.w,
//                                     child: CustomWidget().googleFontRobboto(
//                                       data.locker,
//                                       fontWeight: FontWeight.w700,
//                                       fontSize: 15,
//                                       color: Colors.black,
//                                       textAlign: TextAlign.left,
//                                     ),
//                                   ),
//                                   InkWell(
//                                     onTap: () async {
//                                       var lockerModel =
//                                       Provider.of<LockerViewModel>(context,
//                                           listen: false);
//
//                                       List<LockerData> lockerList =
//                                           lockerModel.newLockerList;
//
//                                       try {
//                                         LockerData lockerData =
//                                         lockerList.firstWhere((element) =>
//                                         element.name
//                                             .trim()
//                                             .toLowerCase() ==
//                                             data.locker.trim().toLowerCase());
//                                         if (lockerData.latitude != null &&
//                                             lockerData.latitude != "" &&
//                                             lockerData.latitude != "-") {
//                                           if (Platform.isIOS) {
//                                             await MapLauncher.launchMap(
//                                               mapType: MapType.apple,
//                                               coords: Coords(
//                                                   double.parse(
//                                                       lockerData.latitude),
//                                                   double.parse(
//                                                       lockerData.longitude)),
//                                               title: lockerData.name,
//                                               description: lockerData.address,
//                                             );
//                                           } else {
//                                             await MapLauncher.launchMap(
//                                               mapType: MapType.google,
//                                               coords: Coords(
//                                                   double.parse(
//                                                       lockerData.latitude),
//                                                   double.parse(
//                                                       lockerData.longitude)),
//                                               title: lockerData.name,
//                                               description: lockerData.address,
//                                             );
//                                           }
//                                         } else {
//                                           CustomWidget().showToastShortV1(
//                                               context: context,
//                                               msg: AppLocalizations.of(context)
//                                                   .translate(LanguageKeys
//                                                   .canNotLoadLocation));
//                                         }
//                                       } catch (e) {
//                                         CustomWidget().showToastShortV1(
//                                             context: context,
//                                             msg: AppLocalizations.of(context)
//                                                 .translate(LanguageKeys
//                                                 .canNotLoadLocation));
//                                       }
//                                     },
//                                     child: CustomWidget().googleFontRobboto(
//                                       "Detail",
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 12,
//                                       color: Color(0xff477FFF),
//                                       textAlign: TextAlign.left,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Divider(color: Colors.grey),
//                               SizedBox(height: 20.0),
//                               (data.status == "CANCEL" ||
//                                   data.status == "EXPIRED")
//                                   ? Container()
//                                   : Column(
//                                 crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                                 children: [
//                                   CustomWidget().googleFontRobboto(
//                                     AppLocalizations.of(context)
//                                         .translate(LanguageKeys.lockerSize),
//                                     fontWeight: FontWeight.w400,
//                                     fontSize: 12,
//                                     color: Colors.black,
//                                     textAlign: TextAlign.left,
//                                   ),
//                                   SizedBox(height: 6.0),
//                                   CustomWidget().googleFontRobboto(
//                                     data.lockerSize == ""
//                                         ? "-"
//                                         : data.lockerSize,
//                                     fontWeight: FontWeight.w700,
//                                     fontSize: 15,
//                                     color: Colors.black,
//                                     textAlign: TextAlign.left,
//                                   ),
//                                 ],
//                               ),
//                               Divider(color: Colors.grey),
//                               SizedBox(height: 20.0),
//                               //#1 Nomor & Ukuran Loker
//                               Container(
//                                 width: 100.0.w,
//                                 child: (data.status == "CANCEL" ||
//                                     data.status == "EXPIRED")
//                                     ? Container()
//                                     : Container(
//                                   width: 40.0.w,
//                                   child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         CustomWidget().googleFontRobboto(
//                                           AppLocalizations.of(context)
//                                               .translate(
//                                               LanguageKeys.lockerNo),
//                                           fontWeight: FontWeight.w400,
//                                           fontSize: 12,
//                                           color: Colors.black,
//                                           textAlign: TextAlign.left,
//                                         ),
//                                         SizedBox(height: 6.0),
//                                         CustomWidget().googleFontRobboto(
//                                           data.lockerNumber == ""
//                                               ? "-"
//                                               : data.lockerNumber
//                                               .toString(),
//                                           fontWeight: FontWeight.w700,
//                                           fontSize: 15,
//                                           color: Colors.black,
//                                           textAlign: TextAlign.left,
//                                         ),
//                                       ]),
//                                 ),
//                               ),
//                               // (widget.transactionType == "popsafe_cancel_success" ||
//                               //         data.status == "CANCEL" ||
//                               //         data.status == "EXPIRED")
//                               //     ? Container()
//                               //     : Column(
//                               //         crossAxisAlignment: CrossAxisAlignment.start,
//                               //         children: [
//                               //           Container(
//                               //             width: 40.0.w,
//                               //             child: CustomWidget().googleFontRobboto(
//                               //               AppLocalizations.of(context).translate(
//                               //                   LanguageKeys.takeLimitTime),
//                               //               fontWeight: FontWeight.w400,
//                               //               fontSize: 12,
//                               //               color: Colors.black,
//                               //               textAlign: TextAlign.left,
//                               //             ),
//                               //           ),
//                               //           SizedBox(height: 6.0),
//                               //           CustomWidget().googleFontRobboto(
//                               //             getFormattedDateShort(
//                               //                 data.expiredTime),
//                               //             fontWeight: FontWeight.w700,
//                               //             fontSize: 15,
//                               //             color: PopboxColor.popboxPrimaryRed,
//                               //             textAlign: TextAlign.left,
//                               //           ),
//                               //         ],
//                               //       ),
//                               // Divider(color: Colors.grey),
//                               // SizedBox(height: 20.0),
//                               //#3 Waktu Kirim & Maks Pembatalan
//                               // Container(
//                               //   width: 100.0.w,
//                               //   child: Row(children: [
//                               //     (widget.transactionType ==
//                               //                 "popsafe_cancel_success" ||
//                               //             data.status == "CANCEL" ||
//                               //             data.status == "EXPIRED" ||
//                               //             data.status == "COMPLETE")
//                               //         ? Container()
//                               //         : Column(
//                               //             crossAxisAlignment:
//                               //                 CrossAxisAlignment.start,
//                               //             children: [
//                               //               CustomWidget().googleFontRobboto(
//                               //                 AppLocalizations.of(context).translate(
//                               //                     LanguageKeys
//                               //                         .popsafeHistoryMaxCancel),
//                               //                 fontWeight: FontWeight.w400,
//                               //                 fontSize: 12,
//                               //                 color: Colors.black,
//                               //                 textAlign: TextAlign.left,
//                               //               ),
//                               //               SizedBox(height: 6.0),
//                               //               CustomWidget().textBold(
//                               //                 getFormattedDateShort(
//                               //                     data.cancellationTime),
//                               //                 PopboxColor.mdGrey900,
//                               //                 11.0.sp,
//                               //                 TextAlign.left,
//                               //               ),
//                               //             ],
//                               //           ),
//                               //   ]),
//                               // ),
//                               SizedBox(height: 17.0),
//                             ],
//                           ),
//                         ),
//                       ),
// //TRACKING
//                       Container(
//                         width: 100.0.w,
//                         margin: EdgeInsets.only(left: 16.0, right: 16.0),
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             width: 1.0,
//                             color: PopboxColor.mdGrey300,
//                           ),
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10.0),
//                           ),
//                           color: Color(0xffEFEFEF),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.only(left: 5.0, right: 5.0),
//                           child: Theme(
//                             data: Theme.of(context)
//                                 .copyWith(cardColor: Color(0xffEFEFEF)),
//                             child: ExpansionPanelList(
//                               animationDuration: Duration(milliseconds: 1000),
//                               dividerColor: PopboxColor.mdBlack1000,
//                               elevation: 0,
//                               children: [
//                                 ExpansionPanel(
//                                   body: trackingParcelWidget(
//                                       parcelHistory: data.history),
//                                   //TITLE
//                                   headerBuilder:
//                                       (BuildContext context, bool isExpanded) {
//                                     return Container(
//                                       padding:
//                                       EdgeInsets.only(top: 14.0, left: 16.0),
//                                       child: CustomWidget().googleFontRobboto(
//                                         AppLocalizations.of(context)
//                                             .translate(LanguageKeys.tracking),
//                                         fontWeight: FontWeight.w700,
//                                         fontSize: 15,
//                                         color: Colors.black,
//                                         textAlign: TextAlign.left,
//                                       ),
//                                     );
//                                   },
//                                   isExpanded: isExpandedTrack,
//                                 )
//                               ],
//                               expansionCallback: (int item, bool status) {
//                                 setState(() {
//                                   isExpandedTrack = !isExpandedTrack;
//                                 });
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 15),
//                       (data.status == "COMPLETED" ||
//                           (data.status == "READY FOR PICKUP" &&
//                               data.ppcInfo.status == "no_ppc") ||
//                           (data.status == "IN_STORE" &&
//                               data.ppcInfo.status == "no_ppc"))
//                           ? Container()
//                           : InkWell(
//                         onTap: () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) => WebviewPage(
//                                 reason: "tnc",
//                                 appbarTitle: AppLocalizations.of(context)
//                                     .translate(LanguageKeys.termCondition),
//                               ),
//                             ),
//                           );
//                         },
//                         child: Container(
//                             width: MediaQuery.of(context).size.width,
//                             margin: EdgeInsets.only(left: 20, right: 20),
//                             padding: EdgeInsets.only(
//                                 left: 10, right: 10, top: 10, bottom: 10),
//                             decoration: BoxDecoration(
//                                 color: Color(0xffFFEBCF),
//                                 borderRadius: BorderRadius.circular(10)),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Icon(Icons.info, color: Color(0xFFFF0B09)),
//                                 Container(
//                                   padding:
//                                   EdgeInsets.only(left: 10, right: 0),
//                                   width: MediaQuery.of(context).size.width -
//                                       100,
//                                   child: Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       CustomWidget().googleFontRobboto(
//                                         AppLocalizations.of(context)
//                                             .translate(LanguageKeys
//                                             .isPopcenterNoteTwo),
//                                         fontWeight: FontWeight.w700,
//                                         fontSize: 12,
//                                         color: Color(0xffE38800),
//                                         textAlign: TextAlign.left,
//                                       ),
//                                       SizedBox(height: 3),
//                                       CustomWidget().googleFontRobboto(
//                                         AppLocalizations.of(context)
//                                             .translate(LanguageKeys
//                                             .isPopcenterNoteThree),
//                                         fontWeight: FontWeight.w700,
//                                         fontSize: 12,
//                                         color: Color(0xffE38800),
//                                         textAlign: TextAlign.left,
//                                       ),
//                                       CustomWidget().googleFontRobboto(
//                                         AppLocalizations.of(context)
//                                             .translate(LanguageKeys
//                                             .isPopcenterNoteFour),
//                                         fontWeight: FontWeight.w700,
//                                         fontSize: 12,
//                                         color: Color(0xffE38800),
//                                         textAlign: TextAlign.left,
//                                       ),
//                                       Text(
//                                         AppLocalizations.of(context)
//                                             .translate(
//                                             LanguageKeys.termCondition),
//                                         softWrap: true,
//                                         overflow: TextOverflow.clip,
//                                         style: GoogleFonts.roboto(
//                                           decoration:
//                                           TextDecoration.underline,
//                                           color: Color(0xffE38800),
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.w700,
//                                         ),
//                                         textAlign: TextAlign.left,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             )),
//                       ),
//
//                       SizedBox(height: 17.0),
//                       InkWell(
//                         onTap: () {
//                           callCsBottomSheet(context);
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.info, color: Color(0xFFFF9C08)),
//                             Text.rich(
//                               TextSpan(
//                                 children: [
//                                   TextSpan(
//                                     text: AppLocalizations.of(context)
//                                         .translate(LanguageKeys.havingProblem),
//                                     style: TextStyle(
//                                       color: Color(0xFF202020),
//                                       fontSize: 12,
//                                       fontFamily: 'Roboto',
//                                       fontWeight: FontWeight.w400,
//                                     ),
//                                   ),
//                                   TextSpan(
//                                     text: AppLocalizations.of(context).translate(
//                                         LanguageKeys.callPopboxCustomerService),
//                                     style: TextStyle(
//                                       color: Color(0xFF477FFF),
//                                       fontSize: 12,
//                                       fontFamily: 'Roboto',
//                                       fontWeight: FontWeight.w400,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       SizedBox(height: 150.0),
//                     ],
//                   )
//                 ]),
//                 (data.ppcInfo.status == "no_ppc" &&
//                     data.status == "OVERDUE" &&
//                     countStoreDayParcel <= 6)
//                     ? GestureDetector(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Container(
//                         padding: EdgeInsets.only(
//                             bottom: 20.0, left: 20.0, right: 20, top: 15),
//                         color: Color(0xffF7F7F7),
//                         child: CustomWidget().customColorButton(
//                             context,
//                             AppLocalizations.of(context)
//                                 .translate(LanguageKeys.popsafeHowToExtend),
//                             PopboxColor.popboxRed,
//                             PopboxColor.mdWhite1000),
//                       ),
//                     ],
//                   ),
//                   onTap: () {
//                     showExtendReasonSelect(
//                         context: context, data: data, from: "parcel");
//                   },
//                 )
//                     : (data.ppcInfo.status == "no_ppc" &&
//                     data.status == "OVERDUE" &&
//                     countStoreDayParcel > 6)
//                     ? GestureDetector(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Container(
//                         padding: EdgeInsets.only(
//                             bottom: 20.0,
//                             left: 20.0,
//                             right: 20,
//                             top: 15),
//                         color: Color(0xffF7F7F7),
//                         child: CustomWidget().customColorButton(
//                             context,
//                             AppLocalizations.of(context).translate(
//                                 LanguageKeys.callPopboxCustomerService),
//                             PopboxColor.popboxRed,
//                             PopboxColor.mdWhite1000),
//                       ),
//                     ],
//                   ),
//                   onTap: () {
//                     callCsBottomSheet(context);
//                   },
//                 )
//                     : ((data.ppcInfo.status == "ppc" &&
//                     data.status == "OVERDUE") ||
//                     (data.ppcInfo.status == "ppc" &&
//                         data.status == "INSTORE") ||
//                     (data.ppcInfo.status == "ppc" &&
//                         data.status == "IN_STORE") ||
//                     (data.ppcInfo.status == "ppc" &&
//                         data.status == "READY FOR PICKUP"))
//                     ?
//     dataComparePayment.totalAmount.toString() == convertedValue.toString() ?
//                 Column() :
//                 GestureDetector(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Container(
//                         padding: EdgeInsets.only(
//                             bottom: 20.0,
//                             left: 20.0,
//                             right: 20,
//                             top: 15),
//                         color: Color(0xffF7F7F7),
//                         child: CustomWidget().customColorButton(
//                             context,
//                             AppLocalizations.of(context)
//                                 .translate(LanguageKeys.pay)
//                                 .toUpperCase(),
//                             PopboxColor.popboxRed,
//                             PopboxColor.mdWhite1000),
//                       ),
//                     ],
//                   ),
//                   onTap: () {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                           builder: (context) =>
//                               MethodPaymentPage(parcelHistoryDetailData:
//                               parcelHistoryDetailData,
//                                   parcelId: parcelId,
//                                   transactionType: widget.transactionType,
//                                   totalPrice: pricePPC,
//                                   unfinishParcelData: widget.unfinishParcelData,
//                                   locationId: locationId,
//                                   parcelData: widget.parcelData)),
//                     );
//                   },
//                 )
//                     : (data.status == "OPERATOR_TAKEN" ||
//                     data.status == "COURIER_TAKEN")
//                     ? GestureDetector(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Container(
//                         padding: EdgeInsets.only(
//                             bottom: 20.0,
//                             left: 20.0,
//                             right: 20,
//                             top: 15),
//                         color: Color(0xffF7F7F7),
//                         child: CustomWidget().customColorButton(
//                             context,
//                             AppLocalizations.of(context)
//                                 .translate(LanguageKeys.callCs)
//                                 .toUpperCase(),
//                             PopboxColor.popboxRed,
//                             PopboxColor.mdWhite1000),
//                       ),
//                     ],
//                   ),
//                   onTap: () {
//                     callCsBottomSheet(context);
//                   },
//                 )
//                     : Container()
//               ],
//             );
//           }
//         } else

        print('log: init parcelView');
        // print('log: init parcelView totalAmount: ' +
        //     dataComparePayment.totalAmount.toString());
        print('log: init parcelView convertedValue : ' +
            convertedValue.toString());
        print('log: isPaid: ' + isPaid.toString());

        return RefreshIndicator(
          onRefresh: _refreshParcel,
          child: Stack(
            children: [
              ListView(scrollDirection: Axis.vertical, children: [
                Column(
                  children: [
                    SizedBox(height: 20.0),

                    isPaid == true
                        ? Container()
                        :

                        //ALERT
                        RegExp(r'WAREHOUSE|warehouse').hasMatch(data.status)
                            ? Container()
                            : (data.ppcInfo.status == "no_ppc" &&
                                    data.status == "OVERDUE")
                                ? Column(
                                    children: [
                                      AlertInfoRectangleWidget(
                                        text: AppLocalizations.of(context)
                                            .translate(LanguageKeys
                                                .popsafeAlertOverdue),
                                        bgColor: Color(0xffFFCECE),
                                        textColor: Color(0xffFF0B09),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 15,
                                            bottom: 15),
                                        margin: EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 10,
                                            bottom: 10),
                                        decoration: BoxDecoration(
                                          color: Color(0xffFFF3E0),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: CustomWidget().googleFontRobboto(
                                          AppLocalizations.of(context)
                                              .translate(LanguageKeys
                                                  .notesPopsafeTransDetailisOverdue),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                          color: Color(0xffE38800),
                                          textAlign: TextAlign.left,
                                        ),
                                      )
                                    ],
                                  )
                                : (data.status == "COMPLETED")
                                    ? AlertInfoRectangleWidget(
                                        text: AppLocalizations.of(context)
                                            .translate(LanguageKeys
                                                .popcenterAlertOutbound),
                                        bgColor: Color(0xffCBF1E4),
                                        textColor: Color(0xff1CAC77),
                                      )
                                    : (data.status == "COURIER_TAKEN" ||
                                            data.status == "OPERATOR_TAKEN")
                                        ? Column(
                                            children: [
                                              AlertInfoRectangleWidget(
                                                text: AppLocalizations.of(
                                                        context)
                                                    .translate(LanguageKeys
                                                        .popsafeAlertOverdue),
                                                bgColor: Color(0xffFFCECE),
                                                textColor: Color(0xffFF0B09),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                padding: EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 15,
                                                    bottom: 15),
                                                margin: EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: 10,
                                                    bottom: 10),
                                                decoration: BoxDecoration(
                                                  color: Color(0xffFFF3E0),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: CustomWidget()
                                                    .googleFontRobboto(
                                                  AppLocalizations.of(context)
                                                      .translate(LanguageKeys
                                                          .notesPopsafeTransDetailisOverdue),
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 10,
                                                  color: Color(0xffE38800),
                                                  textAlign: TextAlign.left,
                                                ),
                                              )
                                            ],
                                          )
                                        : (data.ppcInfo.status == "no_ppc" &&
                                                    data.status ==
                                                        "READY FOR PICKUP" ||
                                                data.status == "IN_STORE")
                                            ? Container()
                                            : (data.ppcInfo.status == "no_ppc" &&
                                                    data.status != "OVERDUE")
                                                ? AlertInfoRectangleWidget(
                                                    text: AppLocalizations.of(
                                                            context)
                                                        .translate(LanguageKeys
                                                            .ppcAlertCollectOnFree),
                                                    bgColor: Color(0xff477FFF),
                                                    textColor: Colors.white,
                                                  )
                                                : (data.ppcInfo.status == "ppc" &&
                                                        countRemainingFreeDay <
                                                            0 &&
                                                        countryCode ==
                                                            "ID") //PAID
                                                    ? Column(
                                                        children: [
                                                          (data.status ==
                                                                  "OVERDUE")
                                                              ? AlertInfoRectangleWidget(
                                                                  text: AppLocalizations.of(
                                                                          context)
                                                                      .translate(
                                                                          LanguageKeys
                                                                              .popsafeAlertOverdue),
                                                                  bgColor: Color(
                                                                      0xffFFCECE),
                                                                  textColor: Color(
                                                                      0xffFF0B09),
                                                                )
                                                              : Container(),
                                                          SizedBox(height: 7),
                                                          AlertInfoRectangleWidget(
                                                            text: AppLocalizations
                                                                    .of(context)
                                                                .translate(
                                                                    LanguageKeys
                                                                        .ppcAlertCollectNotFree),
                                                            bgColor: Color(
                                                                0xffFFCECE),
                                                            textColor: Color(
                                                                0xffFF0B09),
                                                          ),
                                                        ],
                                                      )
                                                    : (data.ppcInfo.status ==
                                                                "ppc" &&
                                                            countRemainingFreeDay >
                                                                0 &&
                                                            countryCode == "ID")
                                                        //FREE
                                                        ? AlertInfoRectangleWidget(
                                                            text: AppLocalizations
                                                                    .of(context)
                                                                .translate(
                                                                    LanguageKeys
                                                                        .ppcAlertCollectOnFree),
                                                            bgColor: Color(
                                                                0xff477FFF),
                                                            textColor:
                                                                Colors.white,
                                                          )
                                                        //#04
                                                        : (double.parse(data
                                                                        .ppcInfo
                                                                        .priceOverdue) ==
                                                                    0 &&
                                                                countryCode ==
                                                                    "MY")
                                                            ? AlertInfoRectangleWidget(
                                                                text: AppLocalizations.of(
                                                                        context)
                                                                    .translate(
                                                                        LanguageKeys
                                                                            .ppcAlertCollectNotFree),
                                                                bgColor: Color(
                                                                    0xffFF0B09),
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                              )
                                                            //#5 - satu
                                                            : (double.parse(data.ppcInfo.priceOverdue) > 0 &&
                                                                    data.status !=
                                                                        "OVERDUE" &&
                                                                    countryCode ==
                                                                        "MY")
                                                                ? AlertInfoRectangleWidget(
                                                                    text: AppLocalizations.of(
                                                                            context)
                                                                        .translate(
                                                                            LanguageKeys.ppcFlatMYRuleNonFreeNote),
                                                                    bgColor: Color(
                                                                        0xff477FFF),
                                                                    textColor:
                                                                        Colors
                                                                            .white,
                                                                  )
                                                                : (double.parse(data.ppcInfo.priceOverdue) > 0 &&
                                                                        data.status ==
                                                                            "OVERDUE" &&
                                                                        countryCode ==
                                                                            "MY")
                                                                    ? AlertInfoRectangleWidget(
                                                                        text: AppLocalizations.of(context)
                                                                            .translate(LanguageKeys.ppcFlatMYRuleNonFreeNoteOverdue),
                                                                        bgColor:
                                                                            Color(0xffFF0B09),
                                                                        textColor:
                                                                            Colors.white,
                                                                      )

                                                                    //TO DO
                                                                    : Container(),

                    SizedBox(height: 15),

                    //QR CODE
                    (data.status == "COMPLETED" || data.status == "DESTROY")
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Stack(
                              children: [
                                Image.asset(
                                  "assets/images/ic_box_blue.png",
                                  fit: BoxFit.fitHeight,
                                  width: MediaQuery.of(context).size.width,
                                ),
                                Container(
                                  height: 70,
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomWidget().googleFontRobboto(
                                            AppLocalizations.of(context)
                                                .translate(
                                                    LanguageKeys.collectionCode)
                                                .toUpperCase(),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Colors.white,
                                            textAlign: TextAlign.left,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return CustomDialogBox(
                                                      title: data.pin,
                                                    );
                                                  });
                                            },
                                            child: CustomWidget()
                                                .googleFontRobboto(
                                              AppLocalizations.of(context)
                                                  .translate(LanguageKeys
                                                      .clickForSeeQR),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10,
                                              color: Color(0xff00137D),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ],
                                      ),
                                      CustomWidget().googleFontRobboto(
                                        data.pin,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 22,
                                        color: Colors.white,
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                    (data.ppcInfo.status == "ppc" &&
                            data.ppcInfo.freeDays == 0 &&
                            countryCode == "ID" &&
                            isPaid == false)
                        ? Container()
                        : (double.parse(data.ppcInfo.priceOverdue) == 0 &&
                                countryCode == "MY" &&
                                data.ppcInfo.status == "ppc")
                            ? Container()
                            : (data.status == "COMPLETED" ||
                                    data.status == "DESTROY" ||
                                    data.status == "OPERATOR_TAKEN" ||
                                    data.status == "COURIER_TAKEN")
                                ? Container()
                                : (data.status == "OVERDUE" &&
                                        data.ppcInfo.status == "no_ppc")
                                    ? Container()
                                    :
                                    //CountDown & Remaining Take Time Limit
                                    Container(
                                        width: 100.0.w,
                                        height: 75,
                                        margin: EdgeInsets.only(
                                            left: 16.0, right: 16.0),
                                        decoration: BoxDecoration(
                                          color: Color(0xffF7F7F7),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomWidget()
                                                    .googleFontRobboto(
                                                  (data.ppcInfo.status ==
                                                          "no_ppc")
                                                      ? AppLocalizations.of(context)
                                                          .translate(LanguageKeys
                                                              .remainingCollectionTime)
                                                      : (countRemainingFreeDay >
                                                              0)
                                                          ? AppLocalizations.of(context)
                                                              .translate(LanguageKeys
                                                                  .remainingFreeTimeLimit)
                                                          : (double.parse(data.ppcInfo.priceOverdue) > 0 &&
                                                                  data.status !=
                                                                      "OVERDUE" &&
                                                                  countryCode ==
                                                                      "MY")
                                                              ? AppLocalizations.of(
                                                                      context)
                                                                  .translate(
                                                                      LanguageKeys
                                                                          .remainingCollectionTime)
                                                              : AppLocalizations.of(
                                                                      context)
                                                                  .translate(
                                                                      LanguageKeys.remainingCollectionTime),
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  textAlign: TextAlign.left,
                                                ),
                                                CustomWidget()
                                                    .googleFontRobboto(
                                                  (data.ppcInfo.status ==
                                                          "no_ppc")
                                                      ? AppLocalizations.of(context)
                                                              .translate(LanguageKeys
                                                                  .collectionTimeLimit) +
                                                          " " +
                                                          data.overdueTime
                                                      : (data.ppcInfo.status ==
                                                              "no_ppc")
                                                          ? AppLocalizations.of(context)
                                                                  .translate(LanguageKeys
                                                                      .takeTimeLimit) +
                                                              " " +
                                                              data.overdueTime
                                                          : (data.ppcInfo.status ==
                                                                      "ppc" &&
                                                                  data.ppcInfo.freeDays ==
                                                                      0 &&
                                                                  countryCode ==
                                                                      "ID" &&
                                                                  isPaid ==
                                                                      false)
                                                              ? ""
                                                              : (double.parse(data.ppcInfo.priceOverdue) > 0 &&
                                                                      data.status !=
                                                                          "OVERDUE")
                                                                  ? AppLocalizations.of(context).translate(LanguageKeys.collectionTimeLimit) +
                                                                      " " +
                                                                      data.overdueTime
                                                                  : (double.parse(data.ppcInfo.priceOverdue) > 0 && data.status == "OVERDUE" && countryCode == "MY")
                                                                      ? AppLocalizations.of(context).translate(LanguageKeys.collectionTimeLimit) + " " + data.overdueTime
                                                                      : AppLocalizations.of(context).translate(LanguageKeys.freeCollectBefore) + " " + data.ppcInfo.freeUntil,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 10,
                                                  color: Color(0xffFF0B09),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ],
                                            ),
                                            //Widget getDayHourMinutes
                                            getDaysHoursMinutes(
                                                context,
                                                Duration(
                                                    seconds:
                                                        countdownTimeParcel))
                                          ],
                                        ),
                                      ),

                    SizedBox(height: 12),
                    (data.ppcInfo.status == "no_ppc" &&
                                data.status == "IN_STORE" ||
                            data.ppcInfo.status == "no_ppc" &&
                                data.status == "READY FOR PICKUP")
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 15, bottom: 15),
                            margin: EdgeInsets.only(
                                left: 20, right: 20, top: 0, bottom: 10),
                            decoration: BoxDecoration(
                              color: Color(0xffFFF3E0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CustomWidget().googleFontRobboto(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.noppcAlertInstore),
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: Color(0xffE38800),
                              textAlign: TextAlign.left,
                            ),
                          )
                        : Container(),
                    //Collection Fee
                    //ondevrafi
                    (data.status == "COMPLETED" ||
                            (data.status == "READY FOR PICKUP" &&
                                data.ppcInfo.status == "no_ppc"))
                        ? Container()
                        : InkWell(
                            onTap: () {
                              if (data.ppcInfo.status == "ppc" &&
                                  isFree &&
                                  countryCode == "ID") {
                                showRulesWareHouseFreeDay(
                                    context: context, data: data);
                              } else if (countryCode == "MY" &&
                                  data.ppcInfo.priceOverdue != "0") {
                                print("11111");
                                showPPCFlatMYNonFree(
                                    context: context,
                                    pricePPC: pricePPC,
                                    data: data);
                              } else if (countryCode == "MY" &&
                                  data.ppcInfo.priceOverdue == "0") {
                                print("222222");
                                showPPCFlatMY(
                                    context: context, pricePPC: pricePPC);
                              } else {
                                print("33333");
                                showPPCnofreeday(context: context, data: data);
                              }
                            },
                            child: Container(
                              height: 102,
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(left: 16.0, right: 16.0),
                              padding: EdgeInsets.only(left: 22),
                              decoration: BoxDecoration(
                                  color: Color(0xffEAF3FF),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Image.asset(
                                      "assets/images/ic_popcenter_pay.png",
                                      fit: BoxFit.fitHeight,
                                      width: 120,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomWidget().googleFontRobboto(
                                        AppLocalizations.of(context).translate(
                                            LanguageKeys.collectionFee),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: Colors.black,
                                        textAlign: TextAlign.center,
                                      ),
                                      CustomWidget().googleFontRobboto(
                                        formatCurrency.format(pricePPC),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 25,
                                        color: Colors.black,
                                        textAlign: TextAlign.center,
                                      ),
                                      isFree
                                          ? CustomWidget().googleFontRobboto(
                                              AppLocalizations.of(context)
                                                      .translate(LanguageKeys
                                                          .collectionFee) +
                                                  " : " +
                                                  AppLocalizations.of(context)
                                                      .translate(
                                                          LanguageKeys.free),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10,
                                              color: Colors.black,
                                              textAlign: TextAlign.center,
                                            )
                                          : Row(
                                              children: [
                                                CustomWidget()
                                                    .googleFontRobboto(
                                                  AppLocalizations.of(context)
                                                          .translate(LanguageKeys
                                                              .collectionFee) +
                                                      " " +
                                                      formatCurrency.format(
                                                          double.parse(data
                                                              .ppcInfo
                                                              .pricePerDay)) +
                                                      " / 24 " +
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              LanguageKeys
                                                                  .hours),
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 10,
                                                  color: Colors.black,
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(width: 3),
                                                CustomWidget()
                                                    .googleFontRobboto(
                                                  AppLocalizations.of(context)
                                                      .translate(LanguageKeys
                                                          .learnMoreHere),
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 10,
                                                  color: Color(0xff477FFF),
                                                  textAlign: TextAlign.center,
                                                )
                                              ],
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                    (data.status == "COMPLETED" || data.status == "DESTROY")
                        ? Container()
                        : (data.ppcInfo.status == "no_ppc")
                            ? InkWell(
                                onTap: () {
                                  showRulesWareHouse(
                                    context: context,
                                    data: data,
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 16, right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomWidget().textLight(
                                        (data.status == "OVERDUE")
                                            ? AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .nonPPCNotesOverdue)
                                            : AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .nonPPCNotesNoOverdue),
                                        Colors.black,
                                        10,
                                        TextAlign.left,
                                      ),
                                      SizedBox(height: 5),
                                      CustomWidget().textLight(
                                        AppLocalizations.of(context).translate(
                                            LanguageKeys.learnMoreHere),
                                        Color(0xff477FFF),
                                        10,
                                        TextAlign.left,
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                    SizedBox(height: 10),

                    //CONTAIN
                    Container(
                      width: 100.0.w,
                      margin: EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 17.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.0,
                          color: PopboxColor.mdGrey300,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(left: 16.0, right: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.0),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomWidget().googleFontRobboto(
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.receiptNo),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black,
                                  textAlign: TextAlign.left,
                                ),
                                CustomWidget().textBold(
                                    data.logisticCompany.name.toString(),
                                    PopboxColor.mdBlack1000,
                                    14,
                                    TextAlign.left),
                              ],
                            ),
                            SizedBox(height: 7.0),

                            CustomWidget().googleFontRobboto(
                              data.orderNumber,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.black,
                              textAlign: TextAlign.left,
                            ),
                            Divider(color: Colors.grey),
                            SizedBox(height: 20.0),
                            CustomWidget().googleFontRobboto(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.status),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.black,
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 7.0),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: (data.status == "OVERDUE" ||
                                            data.status == "CANCEL")
                                        ? Color(0xffFFA9A9)
                                        : (data.status == "COMPLETED")
                                            ? Color(0xffCBF1E4)
                                            : Color(0xffEAF3FF),
                                  ),
                                  child: CustomWidget().googleFontRobboto(
                                    AppLocalizations.of(context)
                                        .translate(data.status
                                            .toLowerCase()
                                            .replaceAll(" ", ""))
                                        .toUpperCase(),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    color: (data.status == "OVERDUE" ||
                                            data.status == "CANCEL")
                                        ? Color(0xffFF0B09)
                                        : (data.status == "COMPLETED")
                                            ? Color(0xff1CAC77)
                                            : Color(0xff477FFF),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                SizedBox(width: 10),
                                RegExp(r'WAREHOUSE|warehouse')
                                        .hasMatch(data.status)
                                    ? Container()
                                    : isFree
                                        ? CustomWidget().textLight(
                                            (data.ppcInfo.freeDays != 0)
                                                ? AppLocalizations.of(context).translate(LanguageKeys.free) +
                                                    " " +
                                                    data.ppcInfo.freeDays
                                                        .toString() +
                                                    " " +
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                            LanguageKeys.day)
                                                : AppLocalizations.of(context).translate(
                                                    LanguageKeys.free),
                                            Color(0xffFF9D09),
                                            12,
                                            TextAlign.left)
                                        : (data.ppcInfo.freeDays == 0 &&
                                                data.ppcInfo.status == "ppc")
                                            ? (double.parse(data.ppcInfo.priceOverdue) == 0 &&
                                                    countryCode == "MY")
                                                ? Container()
                                                : (countryCode == "MY" &&
                                                        data.ppcInfo.status ==
                                                            "ppc" &&
                                                        data.ppcInfo.priceInstore ==
                                                            "0" &&
                                                        data.status !=
                                                            "OVERDUE")
                                                    ? CustomWidget().textLight(
                                                        AppLocalizations.of(context).translate(LanguageKeys.free),
                                                        Color(0xffFF9D09),
                                                        12,
                                                        TextAlign.left)
                                                    : (double.parse(data.ppcInfo.priceOverdue) > 0 && data.status != "OVERDUE" && countryCode == "MY")
                                                        ? Container()
                                                        : (double.parse(data.ppcInfo.priceOverdue) > 0 && data.status == "OVERDUE" && countryCode == "MY")
                                                            ? Container()
                                                            : CustomWidget().textLight("PPC", Color(0xffFF9D09), 12, TextAlign.left)
                                            : Container(),
                              ],
                            ),

                            Divider(color: Colors.grey),
                            SizedBox(height: 20.0),
                            CustomWidget().googleFontRobboto(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.location),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.black,
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 7.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 60.0.w,
                                  child: CustomWidget().googleFontRobboto(
                                    data.locker,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.black,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    var lockerModel =
                                        Provider.of<LockerViewModel>(context,
                                            listen: false);

                                    List<LockerData> lockerList =
                                        lockerModel.newLockerList;

                                    try {
                                      LockerData lockerData =
                                          lockerList.firstWhere((element) =>
                                              element.name
                                                  .trim()
                                                  .toLowerCase() ==
                                              data.locker.trim().toLowerCase());
                                      if (lockerData.latitude != null &&
                                          lockerData.latitude != "" &&
                                          lockerData.latitude != "-") {
                                        if (Platform.isIOS) {
                                          await MapLauncher.launchMap(
                                            mapType: MapType.apple,
                                            coords: Coords(
                                                double.parse(
                                                    lockerData.latitude),
                                                double.parse(
                                                    lockerData.longitude)),
                                            title: lockerData.name,
                                            description: lockerData.address,
                                          );
                                        } else {
                                          await MapLauncher.launchMap(
                                            mapType: MapType.google,
                                            coords: Coords(
                                                double.parse(
                                                    lockerData.latitude),
                                                double.parse(
                                                    lockerData.longitude)),
                                            title: lockerData.name,
                                            description: lockerData.address,
                                          );
                                        }
                                      } else {
                                        CustomWidget().showToastShortV1(
                                            context: context,
                                            msg: AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .canNotLoadLocation));
                                      }
                                    } catch (e) {
                                      CustomWidget().showToastShortV1(
                                          context: context,
                                          msg: AppLocalizations.of(context)
                                              .translate(LanguageKeys
                                                  .canNotLoadLocation));
                                    }
                                  },
                                  child: CustomWidget().googleFontRobboto(
                                    "Detail",
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Color(0xff477FFF),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: Colors.grey),
                            SizedBox(height: 20.0),
                            (data.status == "CANCEL" ||
                                    data.status == "EXPIRED")
                                ? Container()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomWidget().googleFontRobboto(
                                        AppLocalizations.of(context)
                                            .translate(LanguageKeys.lockerSize),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Colors.black,
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(height: 6.0),
                                      CustomWidget().googleFontRobboto(
                                        data.lockerSize == ""
                                            ? "-"
                                            : data.lockerSize,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Colors.black,
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                            Divider(color: Colors.grey),
                            SizedBox(height: 20.0),
                            //#1 Nomor & Ukuran Loker
                            Container(
                              width: 100.0.w,
                              child: (data.status == "CANCEL" ||
                                      data.status == "EXPIRED")
                                  ? Container()
                                  : Container(
                                      width: 40.0.w,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomWidget().googleFontRobboto(
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      LanguageKeys.lockerNo),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: Colors.black,
                                              textAlign: TextAlign.left,
                                            ),
                                            SizedBox(height: 6.0),
                                            CustomWidget().googleFontRobboto(
                                              data.lockerNumber == ""
                                                  ? "-"
                                                  : data.lockerNumber
                                                      .toString(),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: Colors.black,
                                              textAlign: TextAlign.left,
                                            ),
                                          ]),
                                    ),
                            ),
                            // (widget.transactionType == "popsafe_cancel_success" ||
                            //         data.status == "CANCEL" ||
                            //         data.status == "EXPIRED")
                            //     ? Container()
                            //     : Column(
                            //         crossAxisAlignment: CrossAxisAlignment.start,
                            //         children: [
                            //           Container(
                            //             width: 40.0.w,
                            //             child: CustomWidget().googleFontRobboto(
                            //               AppLocalizations.of(context).translate(
                            //                   LanguageKeys.takeLimitTime),
                            //               fontWeight: FontWeight.w400,
                            //               fontSize: 12,
                            //               color: Colors.black,
                            //               textAlign: TextAlign.left,
                            //             ),
                            //           ),
                            //           SizedBox(height: 6.0),
                            //           CustomWidget().googleFontRobboto(
                            //             getFormattedDateShort(
                            //                 data.expiredTime),
                            //             fontWeight: FontWeight.w700,
                            //             fontSize: 15,
                            //             color: PopboxColor.popboxPrimaryRed,
                            //             textAlign: TextAlign.left,
                            //           ),
                            //         ],
                            //       ),
                            // Divider(color: Colors.grey),
                            // SizedBox(height: 20.0),
                            //#3 Waktu Kirim & Maks Pembatalan
                            // Container(
                            //   width: 100.0.w,
                            //   child: Row(children: [
                            //     (widget.transactionType ==
                            //                 "popsafe_cancel_success" ||
                            //             data.status == "CANCEL" ||
                            //             data.status == "EXPIRED" ||
                            //             data.status == "COMPLETE")
                            //         ? Container()
                            //         : Column(
                            //             crossAxisAlignment:
                            //                 CrossAxisAlignment.start,
                            //             children: [
                            //               CustomWidget().googleFontRobboto(
                            //                 AppLocalizations.of(context).translate(
                            //                     LanguageKeys
                            //                         .popsafeHistoryMaxCancel),
                            //                 fontWeight: FontWeight.w400,
                            //                 fontSize: 12,
                            //                 color: Colors.black,
                            //                 textAlign: TextAlign.left,
                            //               ),
                            //               SizedBox(height: 6.0),
                            //               CustomWidget().textBold(
                            //                 getFormattedDateShort(
                            //                     data.cancellationTime),
                            //                 PopboxColor.mdGrey900,
                            //                 11.0.sp,
                            //                 TextAlign.left,
                            //               ),
                            //             ],
                            //           ),
                            //   ]),
                            // ),
                            SizedBox(height: 17.0),
                          ],
                        ),
                      ),
                    ),
//TRACKING
                    Container(
                      width: 100.0.w,
                      margin: EdgeInsets.only(left: 16.0, right: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.0,
                          color: PopboxColor.mdGrey300,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: Color(0xffEFEFEF),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(cardColor: Color(0xffEFEFEF)),
                          child: ExpansionPanelList(
                            animationDuration: Duration(milliseconds: 1000),
                            dividerColor: PopboxColor.mdBlack1000,
                            elevation: 0,
                            children: [
                              ExpansionPanel(
                                body: trackingParcelWidget(
                                    parcelHistory: data.history),
                                //TITLE
                                headerBuilder:
                                    (BuildContext context, bool isExpanded) {
                                  return Container(
                                    padding:
                                        EdgeInsets.only(top: 14.0, left: 16.0),
                                    child: CustomWidget().googleFontRobboto(
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.tracking),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Colors.black,
                                      textAlign: TextAlign.left,
                                    ),
                                  );
                                },
                                isExpanded: isExpandedTrack,
                              )
                            ],
                            expansionCallback: (int item, bool status) {
                              setState(() {
                                isExpandedTrack = !isExpandedTrack;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    (data.status == "COMPLETED" ||
                            (data.status == "READY FOR PICKUP" &&
                                data.ppcInfo.status == "no_ppc") ||
                            (data.status == "IN_STORE" &&
                                data.ppcInfo.status == "no_ppc"))
                        ? Container()
                        : InkWell(
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
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(left: 20, right: 20),
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 10, bottom: 10),
                                decoration: BoxDecoration(
                                    color: Color(0xffFFEBCF),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.info, color: Color(0xFFFF0B09)),
                                    Container(
                                      padding:
                                          EdgeInsets.only(left: 10, right: 0),
                                      width: MediaQuery.of(context).size.width -
                                          100,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomWidget().googleFontRobboto(
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .isPopcenterNoteTwo),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: Color(0xffE38800),
                                            textAlign: TextAlign.left,
                                          ),
                                          SizedBox(height: 3),
                                          CustomWidget().googleFontRobboto(
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .isPopcenterNoteThree),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: Color(0xffE38800),
                                            textAlign: TextAlign.left,
                                          ),
                                          CustomWidget().googleFontRobboto(
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .isPopcenterNoteFour),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: Color(0xffE38800),
                                            textAlign: TextAlign.left,
                                          ),
                                          Text(
                                            AppLocalizations.of(context)
                                                .translate(
                                                    LanguageKeys.termCondition),
                                            softWrap: true,
                                            overflow: TextOverflow.clip,
                                            style: GoogleFonts.roboto(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: Color(0xffE38800),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),

                    SizedBox(height: 17.0),
                    InkWell(
                      onTap: () {
                        callCsBottomSheet(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info, color: Color(0xFFFF9C08)),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)
                                      .translate(LanguageKeys.havingProblem),
                                  style: TextStyle(
                                    color: Color(0xFF202020),
                                    fontSize: 12,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context).translate(
                                      LanguageKeys.callPopboxCustomerService),
                                  style: TextStyle(
                                    color: Color(0xFF477FFF),
                                    fontSize: 12,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 150.0),
                  ],
                )
              ]),
              (data.ppcInfo.status == "no_ppc" &&
                      data.status == "OVERDUE" &&
                      countStoreDayParcel <= 6)
                  ? GestureDetector(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                bottom: 20.0, left: 20.0, right: 20, top: 15),
                            color: Color(0xffF7F7F7),
                            child: CustomWidget().customColorButton(
                                context,
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.popsafeHowToExtend),
                                PopboxColor.popboxRed,
                                PopboxColor.mdWhite1000),
                          ),
                        ],
                      ),
                      onTap: () {
                        showExtendReasonSelect(
                            context: context, data: data, from: "parcel");
                      },
                    )
                  : (data.ppcInfo.status == "no_ppc" &&
                          data.status == "OVERDUE" &&
                          countStoreDayParcel > 6)
                      ? GestureDetector(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                    bottom: 20.0,
                                    left: 20.0,
                                    right: 20,
                                    top: 15),
                                color: Color(0xffF7F7F7),
                                child: CustomWidget().customColorButton(
                                    context,
                                    AppLocalizations.of(context).translate(
                                        LanguageKeys.callPopboxCustomerService),
                                    PopboxColor.popboxRed,
                                    PopboxColor.mdWhite1000),
                              ),
                            ],
                          ),
                          onTap: () {
                            callCsBottomSheet(context);
                          },
                        )
                      : ((data.ppcInfo.status == "ppc" &&
                                  data.status == "OVERDUE" &&
                                  isPaid == false) ||
                              (data.ppcInfo.status == "ppc" &&
                                  data.status == "INSTORE") ||
                              (data.ppcInfo.status == "ppc" &&
                                  data.status == "IN_STORE") ||
                              (data.ppcInfo.status == "ppc" &&
                                  data.status == "READY FOR PICKUP"
                              // &&
                              // dataComparePayment.totalAmount <=
                              //     convertedValue
                              ))
                          ? GestureDetector(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                        bottom: 20.0,
                                        left: 20.0,
                                        right: 20,
                                        top: 15),
                                    color: Color(0xffF7F7F7),
                                    child: CustomWidget().customColorButton(
                                        context,
                                        AppLocalizations.of(context)
                                            .translate(LanguageKeys.pay)
                                            .toUpperCase(),
                                        PopboxColor.popboxRed,
                                        PopboxColor.mdWhite1000),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => MethodPaymentPage(
                                          parcelHistoryDetailData:
                                              parcelHistoryDetailData,
                                          parcelId: parcelId,
                                          transactionType:
                                              widget.transactionType,
                                          totalPrice: pricePPC,
                                          unfinishParcelData:
                                              widget.unfinishParcelData,
                                          locationId: locationId,
                                          parcelData: widget.parcelData)),
                                );
                              },
                            )
                          : (data.status == "OPERATOR_TAKEN" ||
                                  data.status == "COURIER_TAKEN")
                              ? GestureDetector(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            bottom: 20.0,
                                            left: 20.0,
                                            right: 20,
                                            top: 15),
                                        color: Color(0xffF7F7F7),
                                        child: CustomWidget().customColorButton(
                                            context,
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys.callCs)
                                                .toUpperCase(),
                                            PopboxColor.popboxRed,
                                            PopboxColor.mdWhite1000),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    callCsBottomSheet(context);
                                  },
                                )
                              : Container()
            ],
          ),
        );
      } else {
        return RefreshIndicator(
          onRefresh: _refreshPopsafe,
          child: Stack(
            children: [
              ListView(children: [
                Column(
                  children: [
                    SizedBox(height: 20.0),
                    //OVERDUE NOTES

                    //ALERT INFO
                    (data.status == "OVERDUE" || data.status == "EXPIRED")
                        ? Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(
                                    left: 20, right: 20, bottom: 10),
                                padding: EdgeInsets.only(
                                  left: 20,
                                  bottom: 10,
                                  top: 10,
                                ),
                                decoration: BoxDecoration(
                                    color: Color(0xffFFA9A9),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    Icon(Icons.notifications_none,
                                        color: Colors.white, size: 20),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                              0.8 -
                                          20,
                                      child: CustomWidget().googleFontRobboto(
                                        AppLocalizations.of(context).translate(
                                            LanguageKeys.popsafeAlertOverdue),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: Color(0xffFF0B09),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(
                                    left: 20, right: 20, bottom: 10),
                                padding: EdgeInsets.only(
                                  left: 20,
                                  bottom: 20,
                                  top: 20,
                                ),
                                decoration: BoxDecoration(
                                    color: Color(0xffFFF3E0),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8 -
                                          20,
                                  child: CustomWidget().googleFontRobboto(
                                    AppLocalizations.of(context).translate(
                                        LanguageKeys.popsafeAlertOverdueTwo),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    color: Color(0xffE38800),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : (data.status == "COMPLETED")
                            ? AlertInfoRectangleWidget(
                                text: AppLocalizations.of(context).translate(
                                    LanguageKeys.popcenterAlertOutbound),
                                bgColor: Color(0xffCBF1E4),
                                textColor: Color(0xff1CAC77),
                              )
                            : Container(),

                    //KODE AMBIL
                    (data.status == "CANCEL" || data.status == "COMPLETED")
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Stack(
                              children: [
                                Image.asset(
                                  "assets/images/ic_box_blue.png",
                                  fit: BoxFit.fitHeight,
                                  width: MediaQuery.of(context).size.width,
                                ),
                                Container(
                                  height: 70,
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomWidget().googleFontRobboto(
                                            AppLocalizations.of(context)
                                                .translate(
                                                    LanguageKeys.collectionCode)
                                                .toUpperCase(),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Colors.white,
                                            textAlign: TextAlign.left,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return CustomDialogBox(
                                                      title: data.pin,
                                                    );
                                                  });
                                            },
                                            child: CustomWidget()
                                                .googleFontRobboto(
                                              AppLocalizations.of(context)
                                                  .translate(LanguageKeys
                                                      .clickForSeeQR),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10,
                                              color: Color(0xff00137D),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ],
                                      ),
                                      CustomWidget().googleFontRobboto(
                                        data.pin,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 22,
                                        color: Colors.white,
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                    //QR CODE
                    // (popsafeDataDetail.status != "CANCEL")
                    //     ? Container(
                    //         height: 112.0,
                    //         margin: EdgeInsets.only(
                    //             left: 16.0, right: 16.0, bottom: 20.0),
                    //         decoration: BoxDecoration(
                    //           color: PopboxColor.mdBlue60,
                    //           borderRadius: BorderRadius.circular(10),
                    //         ),
                    //         child: Row(
                    //           children: [
                    //             SizedBox(width: 20.0),
                    //             Container(
                    //               width: 20.0.w,
                    //               child: (popsafeDataDetail.status == "CANCEL" ||
                    //                       popsafeDataDetail.status == "EXPIRED")
                    //                   ? Image.asset(
                    //                       "assets/images/ic_dummy_qrcode.png",
                    //                       fit: BoxFit.contain,
                    //                     )
                    //                   : (popsafeDataDetail.codePin == "")
                    //                       ? Image.asset(
                    //                           "assets/images/ic_dummy_qrcode.png",
                    //                           fit: BoxFit.contain,
                    //                         )
                    //                       : GestureDetector(
                    //                           onTap: () {
                    //                             showDialog(
                    //                                 context: context,
                    //                                 builder:
                    //                                     (BuildContext context) {
                    //                                   return CustomDialogBox(
                    //                                     title: popsafeDataDetail
                    //                                         .codePin,
                    //                                   );
                    //                                 });
                    //                           },
                    //                           child: QrImage(
                    //                             data: popsafeDataDetail.codePin,
                    //                             version: QrVersions.auto,
                    //                             gapless: false,
                    //                             backgroundColor:
                    //                                 PopboxColor.mdWhite1000,
                    //                           )),
                    //             ),
                    //             SizedBox(width: 20.0),
                    //             Container(
                    //               width: 55.0.w,
                    //               child: Column(
                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                 mainAxisAlignment: MainAxisAlignment.center,
                    //                 children: [
                    //                   CustomWidget().textRegular(
                    //                       AppLocalizations.of(context).translate(
                    //                           LanguageKeys.collectionCode),
                    //                       PopboxColor.mdGrey180,
                    //                       10.0.sp,
                    //                       TextAlign.left),
                    //                   (popsafeDataDetail.codePin == "")
                    //                       ? CustomWidget().textRegular(
                    //                           AppLocalizations.of(context)
                    //                               .translate(LanguageKeys
                    //                                   .popsafeHistoryCodeSoon),
                    //                           PopboxColor.mdBlack1000,
                    //                           10.0.sp,
                    //                           TextAlign.left)
                    //                       : CustomWidget().textBold(
                    //                           popsafeDataDetail.codePin,
                    //                           PopboxColor.mdBlack1000,
                    //                           16.0.sp,
                    //                           TextAlign.left)
                    //                 ],
                    //               ),
                    //             )
                    //           ],
                    //         ),
                    //       )
                    //     : Container(),
                    //HOW TO SAFE
                    (data.status == "CREATED" ||
                            data.status.replaceAll(" ", "") == "INSTORE")
                        ? GestureDetector(
                            onTap: () {
                              showQRcodeOnLocker(context);
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 20.0),
                              child: ReportOrderProblem(
                                imageUrl: "assets/images/ic_question_green.png",
                                title: (data.pin == "")
                                    ? AppLocalizations.of(context).translate(
                                        LanguageKeys.popsafeHowToOrder)
                                    : AppLocalizations.of(context).translate(
                                        LanguageKeys.popsafeHowToTake),
                                subTitle: (data.pin == "")
                                    ? AppLocalizations.of(context).translate(
                                        LanguageKeys.popsafeHowToOrderMore)
                                    : AppLocalizations.of(context).translate(
                                        LanguageKeys.popsafeHowToCollectMore),
                                bgColor: PopboxColor.mdYellowA500,
                              ),
                            ),
                          )
                        : Container(),
                    (data.status == "OVERDUE" ||
                            data.status == "INBOUND_POPCENTER_LOCKER")
                        ? InkWell(
                            onTap: () {
                              // if (!isFree && data.inboundGroup != "PACKAGE_FOOD") {
                              //   showRulesPopcenter(context: context, data: data);
                              // }
                            },
                            child: Container(
                              height: 102,
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(left: 16.0, right: 16.0),
                              padding: EdgeInsets.only(left: 22),
                              decoration: BoxDecoration(
                                  color: Color(0xffEAF3FF),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Image.asset(
                                      "assets/images/ic_popcenter_pay.png",
                                      fit: BoxFit.fitHeight,
                                      width: 120,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomWidget().googleFontRobboto(
                                        AppLocalizations.of(context).translate(
                                            LanguageKeys.collectionFee),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: Colors.black,
                                        textAlign: TextAlign.center,
                                      ),
                                      CustomWidget().googleFontRobboto(
                                        formatCurrency.format(12345),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 25,
                                        color: Colors.black,
                                        textAlign: TextAlign.center,
                                      ),
                                      // isFree
                                      //     ? CustomWidget().googleFontRobboto(
                                      //         AppLocalizations.of(context).translate(
                                      //                 LanguageKeys.collectionFee) +
                                      //             " : " +
                                      //             AppLocalizations.of(context)
                                      //                 .translate(LanguageKeys.free),
                                      //         fontWeight: FontWeight.w400,
                                      //         fontSize: 10,
                                      //         color: Colors.black,
                                      //         textAlign: TextAlign.center,
                                      //       )
                                      //     : Row(
                                      //         children: [
                                      //           CustomWidget().googleFontRobboto(
                                      //             AppLocalizations.of(context)
                                      //                     .translate(LanguageKeys
                                      //                         .collectionFee) +
                                      //                 " " +
                                      //                 formatCurrency.format(
                                      //                     double.parse(data
                                      //                         .ppcInfo.pricePerDay)) +
                                      //                 " / 24 " +
                                      //                 AppLocalizations.of(context)
                                      //                     .translate(
                                      //                         LanguageKeys.hours),
                                      //             fontWeight: FontWeight.w400,
                                      //             fontSize: 10,
                                      //             color: Colors.black,
                                      //             textAlign: TextAlign.center,
                                      //           ),
                                      //           SizedBox(width: 3),
                                      //           CustomWidget().googleFontRobboto(
                                      //             AppLocalizations.of(context)
                                      //                 .translate(
                                      //                     LanguageKeys.learnMoreHere),
                                      //             fontWeight: FontWeight.w400,
                                      //             fontSize: 10,
                                      //             color: Color(0xff477FFF),
                                      //             textAlign: TextAlign.center,
                                      //           )
                                      //         ],
                                      //       ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(height: 10),
                    //CONTAIN
                    Container(
                      width: 100.0.w,
                      margin: EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 17.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.0,
                          color: PopboxColor.mdGrey300,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(left: 16.0, right: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.0),
                            CustomWidget().googleFontRobboto(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.receiptNo),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.black,
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 7.0),
                            CustomWidget().googleFontRobboto(
                              data.orderNumber,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.black,
                              textAlign: TextAlign.left,
                            ),
                            Divider(color: Colors.grey),
                            SizedBox(height: 20.0),
                            CustomWidget().googleFontRobboto(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.status),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.black,
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 7.0),
                            CustomWidget().googleFontRobboto(
                              AppLocalizations.of(context)
                                  .translate(data.status
                                      .toLowerCase()
                                      .replaceAll(" ", ""))
                                  .toUpperCase(),
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: (data.status == "OVERDUE" ||
                                      data.status == "CANCEL")
                                  ? Color(0xffFF0B09)
                                  : data.status == "COMPLETED"
                                      ? Color(0xff1CAC77)
                                      : PopboxColor.popboxRed,
                              textAlign: TextAlign.left,
                            ),
                            Divider(color: Colors.grey),
                            SizedBox(height: 20.0),
                            CustomWidget().googleFontRobboto(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.location),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.black,
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 7.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 60.0.w,
                                  child: CustomWidget().googleFontRobboto(
                                    data.locker,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.black,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    var lockerModel =
                                        Provider.of<LockerViewModel>(context,
                                            listen: false);

                                    List<LockerData> lockerList =
                                        lockerModel.newLockerList;

                                    try {
                                      LockerData lockerData =
                                          lockerList.firstWhere((element) =>
                                              element.name
                                                  .trim()
                                                  .toLowerCase() ==
                                              data.locker.trim().toLowerCase());
                                      if (lockerData.latitude != null &&
                                          lockerData.latitude != "" &&
                                          lockerData.latitude != "-") {
                                        if (Platform.isIOS) {
                                          await MapLauncher.launchMap(
                                            mapType: MapType.apple,
                                            coords: Coords(
                                                double.parse(
                                                    lockerData.latitude),
                                                double.parse(
                                                    lockerData.longitude)),
                                            title: lockerData.name,
                                            description: lockerData.address,
                                          );
                                        } else {
                                          await MapLauncher.launchMap(
                                            mapType: MapType.google,
                                            coords: Coords(
                                                double.parse(
                                                    lockerData.latitude),
                                                double.parse(
                                                    lockerData.longitude)),
                                            title: lockerData.name,
                                            description: lockerData.address,
                                          );
                                        }
                                      } else {
                                        CustomWidget().showToastShortV1(
                                            context: context,
                                            msg: AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .canNotLoadLocation));
                                      }
                                    } catch (e) {
                                      CustomWidget().showToastShortV1(
                                          context: context,
                                          msg: AppLocalizations.of(context)
                                              .translate(LanguageKeys
                                                  .canNotLoadLocation));
                                    }
                                  },
                                  child: CustomWidget().googleFontRobboto(
                                    "Detail",
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Color(0xff477FFF),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: Colors.grey),
                            SizedBox(height: 20.0),
                            (data.status == "CANCEL" ||
                                    data.status == "EXPIRED")
                                ? Container()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomWidget().googleFontRobboto(
                                        AppLocalizations.of(context)
                                            .translate(LanguageKeys.lockerSize),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Colors.black,
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(height: 6.0),
                                      CustomWidget().googleFontRobboto(
                                        data.lockerSize == ""
                                            ? "-"
                                            : data.lockerSize,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Colors.black,
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                            Divider(color: Colors.grey),
                            SizedBox(height: 20.0),
                            //#1 Nomor & Ukuran Loker
                            Container(
                              width: 100.0.w,
                              child: (data.status == "CANCEL" ||
                                      data.status == "EXPIRED")
                                  ? Container()
                                  : Container(
                                      width: 40.0.w,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomWidget().googleFontRobboto(
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      LanguageKeys.lockerNo),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: Colors.black,
                                              textAlign: TextAlign.left,
                                            ),
                                            SizedBox(height: 6.0),
                                            CustomWidget().googleFontRobboto(
                                              data.lockerNumber == "0"
                                                  ? "-"
                                                  : data.lockerNumber
                                                      .toString(),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: Colors.black,
                                              textAlign: TextAlign.left,
                                            ),
                                          ]),
                                    ),
                            ),
                            Divider(color: Colors.grey),
                            SizedBox(height: 20.0),
                            //#2 Waktu Ambil & Sisa Batas Ambil
                            (data.status == "COMPLETED")
                                ? Container()
                                : Container(
                                    width: 100.0.w,
                                    child: Container(
                                      width: 40.0.w,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomWidget().googleFontRobboto(
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      LanguageKeys.takeTime),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: Colors.black,
                                              textAlign: TextAlign.left,
                                            ),
                                            SizedBox(height: 6.0),
                                            CustomWidget().googleFontRobboto(
                                              (data.takeTime == "")
                                                  ? "-"
                                                  : getFormattedDateShort(
                                                      data.takeTime),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: Colors.black,
                                              textAlign: TextAlign.left,
                                            ),
                                          ]),
                                    ),
                                  ),
                            (data.status == "COMPLETED")
                                ? Container()
                                : Divider(color: Colors.grey),
                            (data.status == "COMPLETED")
                                ? Container()
                                : SizedBox(height: 20.0),
                            (widget.transactionType ==
                                        "popsafe_cancel_success" ||
                                    data.status == "CANCEL" ||
                                    data.status == "EXPIRED" ||
                                    data.status == "COMPLETED")
                                ? Container()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40.0.w,
                                        child: CustomWidget().googleFontRobboto(
                                          AppLocalizations.of(context)
                                              .translate(
                                                  LanguageKeys.takeLimitTime),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Colors.black,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      SizedBox(height: 6.0),
                                      CustomWidget().googleFontRobboto(
                                        getFormattedDateShort(data.lastUpdate),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: PopboxColor.popboxPrimaryRed,
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                            (data.status == "COMPLETED" ||
                                    data.status == "COMPLETE")
                                ? Container()
                                : Divider(color: Colors.grey),
                            (data.status == "COMPLETED" ||
                                    data.status == "COMPLETE")
                                ? Container()
                                : SizedBox(height: 20.0),
                            //#3 Waktu Kirim & Maks Pembatalan
                            Container(
                              width: 100.0.w,
                              child: Row(children: [
                                (widget.transactionType ==
                                            "popsafe_cancel_success" ||
                                        data.status == "CANCEL" ||
                                        data.status == "EXPIRED" ||
                                        data.status == "COMPLETE" ||
                                        data.status == "COMPLETED")
                                    ? Container()
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomWidget().googleFontRobboto(
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .popsafeHistoryMaxCancel),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            color: Colors.black,
                                            textAlign: TextAlign.left,
                                          ),
                                          SizedBox(height: 6.0),
                                          // CustomWidget().textBold(
                                          //   getFormattedDateShort(
                                          //       data
                                          //           .cancellationTime),
                                          //   PopboxColor.mdGrey900,
                                          //   11.0.sp,
                                          //   TextAlign.left,
                                          // ),
                                        ],
                                      ),
                              ]),
                            ),
                            (data.status == "COMPLETED" ||
                                    data.status == "COMPLETE")
                                ? Container()
                                : Divider(color: Colors.grey),
                            (data.status == "COMPLETED" ||
                                    data.status == "COMPLETE")
                                ? Container()
                                : SizedBox(height: 17.0),
                          ],
                        ),
                      ),
                    ),
                    //DEV CONTAINER DETAIL PEMBAYARAN
                    // Container(
                    //   width: 100.0.w,
                    //   margin: EdgeInsets.only(left: 16.0, right: 16.0),
                    //   decoration: BoxDecoration(
                    //     border: Border.all(
                    //       width: 1.0,
                    //       color: PopboxColor.mdGrey300,
                    //     ),
                    //     borderRadius: BorderRadius.all(
                    //       Radius.circular(10.0),
                    //     ),
                    //     color: Color(0xffEFEFEF),
                    //   ),
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                    //     child: Theme(
                    //       data: Theme.of(context)
                    //           .copyWith(cardColor: Color(0xffEFEFEF)),
                    //       child: ExpansionPanelList(
                    //         animationDuration: Duration(milliseconds: 1000),
                    //         dividerColor: PopboxColor.mdBlack1000,
                    //         elevation: 0,
                    //         children: [
                    //           ExpansionPanel(
                    //             body: Container(
                    //               padding: EdgeInsets.only(left: 16.0),
                    //               child: Column(
                    //                 mainAxisAlignment:
                    //                     MainAxisAlignment.spaceBetween,
                    //                 crossAxisAlignment:
                    //                     CrossAxisAlignment.start,
                    //                 children: <Widget>[
                    //                   //PRICE
                    //                   CustomWidget().textRegular(
                    //                       AppLocalizations.of(context)
                    //                           .translate(
                    //                               LanguageKeys.entrustedCosts),
                    //                       PopboxColor.mdBlack1000,
                    //                       11.0.sp,
                    //                       TextAlign.left),
                    //                   SizedBox(height: 7),
                    //                   Align(
                    //                     alignment: Alignment.centerLeft,
                    //                     child: CustomWidget().textBold(
                    //                       formatCurrency.format(12345),
                    //                       PopboxColor.mdGrey900,
                    //                       11.0.sp,
                    //                       TextAlign.left,
                    //                     ),
                    //                   ),
                    //                   SizedBox(height: 11),
                    //                   //PROMO
                    //                   CustomWidget().textRegular(
                    //                       AppLocalizations.of(context)
                    //                           .translate(
                    //                               LanguageKeys.voucherPromo),
                    //                       PopboxColor.mdBlack1000,
                    //                       11.0.sp,
                    //                       TextAlign.left),
                    //                   SizedBox(height: 7),
                    //                   Align(
                    //                     alignment: Alignment.centerLeft,
                    //                     child: CustomWidget().textBold(
                    //                       formatCurrency.format(54321),
                    //                       PopboxColor.mdGrey900,
                    //                       11.0.sp,
                    //                       TextAlign.left,
                    //                     ),
                    //                   ),
                    //                   SizedBox(height: 11),
                    //                   //TOTAL PRICE
                    //                   CustomWidget().textRegular(
                    //                       AppLocalizations.of(context)
                    //                           .translate(
                    //                               LanguageKeys.totalPrice),
                    //                       PopboxColor.mdBlack1000,
                    //                       11.0.sp,
                    //                       TextAlign.left),
                    //                   SizedBox(height: 7),
                    //                   Align(
                    //                     alignment: Alignment.centerLeft,
                    //                     child: CustomWidget().textBold(
                    //                       formatCurrency.format(543211),
                    //                       PopboxColor.mdGrey900,
                    //                       11.0.sp,
                    //                       TextAlign.left,
                    //                     ),
                    //                   ),
                    //                   SizedBox(height: 11),
                    //                 ],
                    //               ),
                    //             ),
                    //             //TITLE
                    //             headerBuilder:
                    //                 (BuildContext context, bool isExpanded) {
                    //               return Container(
                    //                 padding:
                    //                     EdgeInsets.only(top: 14.0, left: 16.0),
                    //                 child: CustomWidget().googleFontRobboto(
                    //                   AppLocalizations.of(context).translate(
                    //                       LanguageKeys.transactionDetail),
                    //                   fontWeight: FontWeight.w700,
                    //                   fontSize: 15,
                    //                   color: Colors.black,
                    //                   textAlign: TextAlign.left,
                    //                 ),
                    //               );
                    //             },
                    //             isExpanded: isExpandedTransaction,
                    //           )
                    //         ],
                    //         expansionCallback: (int item, bool status) {
                    //           setState(() {
                    //             isExpandedTransaction = !isExpandedTransaction;
                    //           });
                    //         },
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // //DEV CONTAINER
                    // SizedBox(height: 10.0),
                    //TRACKING
                    Container(
                      width: 100.0.w,
                      margin: EdgeInsets.only(left: 16.0, right: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.0,
                          color: PopboxColor.mdGrey300,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: Color(0xffEFEFEF),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(cardColor: Color(0xffEFEFEF)),
                          child: ExpansionPanelList(
                            animationDuration: Duration(milliseconds: 1000),
                            dividerColor: PopboxColor.mdBlack1000,
                            elevation: 0,
                            children: [
                              //ondevparcel
                              ExpansionPanel(
                                body: trackingParcelWidget(
                                    parcelHistory: data.history),
                                //TITLE
                                headerBuilder:
                                    (BuildContext context, bool isExpanded) {
                                  return Container(
                                    padding:
                                        EdgeInsets.only(top: 14.0, left: 16.0),
                                    child: CustomWidget().googleFontRobboto(
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.tracking),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Colors.black,
                                      textAlign: TextAlign.left,
                                    ),
                                  );
                                },
                                isExpanded: isExpandedTrack,
                              )
                            ],
                            expansionCallback: (int item, bool status) {
                              setState(() {
                                isExpandedTrack = !isExpandedTrack;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.0),
                    InkWell(
                      onTap: () {
                        callCsBottomSheet(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info, color: Color(0xFFFF9C08)),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)
                                      .translate(LanguageKeys.havingProblem),
                                  style: TextStyle(
                                    color: Color(0xFF202020),
                                    fontSize: 12,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context).translate(
                                      LanguageKeys.callPopboxCustomerService),
                                  style: TextStyle(
                                    color: Color(0xFF477FFF),
                                    fontSize: 12,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 150.0),
                  ],
                )
              ]),
              //BUTTON CANCEL OR EXTEND
              data.status == "CREATED" && timeDifference < 3600
                  ? GestureDetector(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                bottom: 20.0, left: 20.0, right: 20),
                            decoration: BoxDecoration(
                              color: Color(0xffF7F7F7),
                              border: Border.all(color: PopboxColor.popboxRed),
                            ),
                            child: CustomWidget().customColorButton(
                                context,
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.orderCancel),
                                PopboxColor.mdWhite1000,
                                PopboxColor.popboxRed),
                          ),
                        ],
                      ),
                      onTap: () {
                        showCancelOrder(context);
                      },
                    )
                  : (data.status == "OVERDUE")
                      ? GestureDetector(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                    bottom: 20.0,
                                    left: 20.0,
                                    right: 20,
                                    top: 15),
                                color: Color(0xffF7F7F7),
                                child: CustomWidget().customColorButton(
                                    context,
                                    AppLocalizations.of(context).translate(
                                        LanguageKeys.popsafeHowToExtend),
                                    PopboxColor.popboxRed,
                                    PopboxColor.mdWhite1000),
                              ),
                            ],
                          ),
                          onTap: () {
                            //
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => MethodPaymentPage()),
                            );

                            // if (showPopsafe == false) {
                            //   showPopsafeInfo(context: context);
                            // } else {
                            //   showExtendOrder(context);
                            // }
                          },
                        )
                      : Container(),
            ],
          ),
        );

        // return ListView(
        //   children: [
        //     Text("rafi"),
        //     Padding(
        //       padding: const EdgeInsets.only(
        //           left: 16.0, top: 16.0, right: 16.0, bottom: 30.0),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.center,
        //         mainAxisAlignment: MainAxisAlignment.start,
        //         children: [
        //           new Container(
        //             margin:
        //                 EdgeInsets.only(left: 0.0, right: 0.0, bottom: 30.0),
        //             decoration: new BoxDecoration(
        //                 color: PopboxColor.popboxPrimaryRed,
        //                 borderRadius: new BorderRadius.only(
        //                   topLeft: const Radius.circular(10.0),
        //                   topRight: const Radius.circular(10.0),
        //                   bottomLeft: const Radius.circular(10.0),
        //                   bottomRight: const Radius.circular(10.0),
        //                 )),
        //             child: ConstrainedBox(
        //               constraints: BoxConstraints(
        //                 minWidth: 90.0.w,
        //                 //maxWidth: 300.0,
        //                 minHeight: 30.0,
        //                 maxHeight: 110.0,
        //               ),
        //               child: Padding(
        //                 padding: const EdgeInsets.only(left: 20.0),
        //                 child: Row(
        //                   mainAxisAlignment: MainAxisAlignment.start,
        //                   crossAxisAlignment: CrossAxisAlignment.center,
        //                   children: [
        //                     GestureDetector(
        //                       onTap: () {
        //                         showDialog(
        //                             context: context,
        //                             builder: (BuildContext context) {
        //                               return CustomDialogBox(
        //                                 title: data.pin,
        //                               );
        //                             });
        //                       },
        //                       child: QrImage(
        //                         data: "AMBIL#" + data.pin,
        //                         version: QrVersions.auto,
        //                         size: 70,
        //                         gapless: false,
        //                         padding: EdgeInsets.all(4.0),
        //                         backgroundColor: PopboxColor.mdWhite1000,
        //                       ),
        //                     ),
        //                     Padding(
        //                       padding: const EdgeInsets.only(left: 20.0),
        //                       child: Column(
        //                         mainAxisAlignment: MainAxisAlignment.center,
        //                         crossAxisAlignment: CrossAxisAlignment.start,
        //                         children: [
        //                           CustomWidget().textRegular(
        //                               AppLocalizations.of(context).translate(
        //                                   LanguageKeys.collectionCode),
        //                               PopboxColor.mdWhite1000,
        //                               8.0.sp,
        //                               TextAlign.left),
        //                           CustomWidget().textBold(
        //                             data.pin,
        //                             PopboxColor.mdWhite1000,
        //                             16.0.sp,
        //                             TextAlign.left,
        //                           ),
        //                         ],
        //                       ),
        //                     )
        //                   ],
        //                 ),
        //               ),
        //             ),
        //           ),
        //           onlyTextContent(
        //               context: context,
        //               title: AppLocalizations.of(context)
        //                   .translate(LanguageKeys.receiptNo),
        //               content: data.orderNumber,
        //               canCopy: true),
        //           Padding(
        //             padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        //             child: Divider(
        //               height: 1.0,
        //               color: Colors.grey,
        //             ),
        //           ),
        //           onlyTextContent(
        //               context: context,
        //               title: AppLocalizations.of(context)
        //                   .translate(LanguageKeys.status),
        //               content: AppLocalizations.of(context)
        //                   .translate(
        //                       data.status.replaceAll(" ", "").toLowerCase())
        //                   .toUpperCase(),
        //               contentColor: PopboxColor.popboxRed),
        //           Padding(
        //             padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        //             child: Divider(
        //               height: 1.0,
        //               color: Colors.grey,
        //             ),
        //           ),
        //           textContentLocation(
        //             context: context,
        //             title: AppLocalizations.of(context)
        //                 .translate(LanguageKeys.location),
        //             content: data.locker,
        //           ),
        //           Padding(
        //             padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        //             child: Divider(
        //               height: 1.0,
        //               color: Colors.grey,
        //             ),
        //           ),
        //           onlyTextContent(
        //             context: context,
        //             title: AppLocalizations.of(context)
        //                 .translate(LanguageKeys.codeValidityLimit),
        //             content:
        //                 (data.overdueTime != null && data.overdueTime != '')
        //                     ? getFormattedDate(data.overdueTime)
        //                     : '-',
        //           ),
        //         ],
        //       ),
        //     ),

        //     //REPORT FORM
        //     InkWell(
        //       onTap: () {
        //         Navigator.of(context).push(
        //           MaterialPageRoute(
        //               builder: (context) => (Platform.isAndroid)
        //                   ? FormReportingPage(
        //                       parcelDataDetail: data,
        //                       reason: "Parcel",
        //                       type: "Collection")
        //                   : {
        //                       WidgetsBinding.instance
        //                           .addPostFrameCallback((_) => setState(() {
        //                                 context
        //                                     .read<BottomNavigationBloc>()
        //                                     .add(
        //                                       PageTapped(index: 2),
        //                                     );
        //                                 Navigator.of(context)
        //                                     .pushAndRemoveUntil(
        //                                         MaterialPageRoute(
        //                                             builder: (c) => Home()),
        //                                         (route) => false);
        //                               }))
        //                     }),
        //         );
        //       },
        //       child: ReportOrderProblem(
        //         imageUrl: "assets/images/ic_question_green.png",
        //         title: AppLocalizations.of(context)
        //             .translate(LanguageKeys.askProblemOrder),
        //         subTitle: AppLocalizations.of(context)
        //             .translate(LanguageKeys.callPopboxCustomerService),
        //         bgColor: PopboxColor.mdYellowA500,
        //       ),
        //     ),
        //   ],
        // );

      }
    } else {
      return cartShimmerView(context);
    }
  }

  Widget popsafeViewNew(
      BuildContext context, PopsafeHistoryDetailData popsafeDataDetail) {
    if (popsafeDataDetail != null) {
      DateTime now = DateTime.now();
      String dateTimeNowFormated =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      final formatedTime = DateFormat('yyyy-MM-dd HH:mm:ss');
      final nowtime = formatedTime.parse(dateTimeNowFormated);
      countdownTimeParcel = formatedTime
          .parse(popsafeDataDetail.expiredTime)
          .difference(nowtime)
          .inSeconds;
    }

    return popsafeDataDetail != null
        ? RefreshIndicator(
            onRefresh: _refreshPopsafe,
            child: Stack(
              children: [
                ListView(children: [
                  Column(
                    children: [
                      SizedBox(height: 20.0),
                      //OVERDUE NOTES
                      //ALERT INFO
                      (popsafeDataDetail.status == "OVERDUE" ||
                              popsafeDataDetail.status == "EXPIRED")
                          ? Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.only(
                                      left: 20, right: 20, bottom: 10),
                                  padding: EdgeInsets.only(
                                    left: 20,
                                    bottom: 10,
                                    top: 10,
                                  ),
                                  decoration: BoxDecoration(
                                      color: Color(0xffFFA9A9),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      Icon(Icons.notifications_none,
                                          color: Colors.white, size: 20),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                    0.8 -
                                                20,
                                        child: CustomWidget().googleFontRobboto(
                                          AppLocalizations.of(context)
                                              .translate(LanguageKeys
                                                  .popsafeAlertOverdue),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: Color(0xffFF0B09),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.only(
                                      left: 20, right: 20, bottom: 10),
                                  padding: EdgeInsets.only(
                                    left: 20,
                                    bottom: 20,
                                    top: 20,
                                  ),
                                  decoration: BoxDecoration(
                                      color: Color(0xffFFF3E0),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                            0.8 -
                                        20,
                                    child: CustomWidget().googleFontRobboto(
                                      AppLocalizations.of(context).translate(
                                          LanguageKeys.popsafeAlertOverdueTwo),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                      color: Color(0xffE38800),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      //KODE AMBIL
                      (popsafeDataDetail.status == "CANCEL" ||
                              popsafeDataDetail.status == "COMPLETED" ||
                              popsafeDataDetail.status == "DESTROY")
                          ? Container()
                          : Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    "assets/images/ic_box_blue.png",
                                    fit: BoxFit.fitHeight,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                  Container(
                                    height: 70,
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomWidget().googleFontRobboto(
                                              AppLocalizations.of(context)
                                                  .translate(LanguageKeys
                                                      .collectionCode)
                                                  .toUpperCase(),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: Colors.white,
                                              textAlign: TextAlign.left,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return CustomDialogBox(
                                                        title: popsafeDataDetail
                                                            .codePin,
                                                      );
                                                    });
                                              },
                                              child: CustomWidget()
                                                  .googleFontRobboto(
                                                AppLocalizations.of(context)
                                                    .translate(LanguageKeys
                                                        .clickForSeeQR),
                                                fontWeight: FontWeight.w400,
                                                fontSize: 10,
                                                color: Color(0xff00137D),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ],
                                        ),
                                        CustomWidget().googleFontRobboto(
                                          popsafeDataDetail.codePin,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 22,
                                          color: Colors.white,
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
//CountDown & Remaining Take Time Limit
                      (popsafeDataDetail.status == "IN STORE")
                          ? Container(
                              width: 100.0.w,
                              height: 75,
                              margin: EdgeInsets.only(left: 16.0, right: 16.0),
                              decoration: BoxDecoration(
                                color: Color(0xffF7F7F7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomWidget().googleFontRobboto(
                                        AppLocalizations.of(context).translate(
                                            LanguageKeys
                                                .remainingTakeTimeLimit),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: Colors.black,
                                        textAlign: TextAlign.left,
                                      ),
                                      CustomWidget().googleFontRobboto(
                                        AppLocalizations.of(context).translate(
                                                LanguageKeys
                                                    .collectionTimeLimit) +
                                            " " +
                                            DateFormat('dd MMMM yyyy HH:mm:ss')
                                                .format(DateFormat(
                                                        'yyyy-MM-dd HH:mm:ss')
                                                    .parse(popsafeDataDetail
                                                        .expiredTime)),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10,
                                        color: Color(0xffFF0B09),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                  //Widget getDayHourMinutes
                                  getDaysHoursMinutes(context,
                                      Duration(seconds: countdownTimeParcel))
                                ],
                              ),
                            )
                          : Container(),
                      (popsafeDataDetail.status == "IN STORE")
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(
                                  left: 20, right: 20, bottom: 10, top: 10),
                              padding: EdgeInsets.only(
                                left: 20,
                                bottom: 20,
                                top: 20,
                              ),
                              decoration: BoxDecoration(
                                  color: Color(0xffFFF3E0),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8 -
                                    20,
                                child: CustomWidget().googleFontRobboto(
                                  AppLocalizations.of(context).translate(
                                      LanguageKeys.noppcAlertInstore),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  color: Color(0xffE38800),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            )
                          : Container(),

                      //QR CODE
                      // (popsafeDataDetail.status != "CANCEL")
                      //     ? Container(
                      //         height: 112.0,
                      //         margin: EdgeInsets.only(
                      //             left: 16.0, right: 16.0, bottom: 20.0),
                      //         decoration: BoxDecoration(
                      //           color: PopboxColor.mdBlue60,
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //         child: Row(
                      //           children: [
                      //             SizedBox(width: 20.0),
                      //             Container(
                      //               width: 20.0.w,
                      //               child: (popsafeDataDetail.status == "CANCEL" ||
                      //                       popsafeDataDetail.status == "EXPIRED")
                      //                   ? Image.asset(
                      //                       "assets/images/ic_dummy_qrcode.png",
                      //                       fit: BoxFit.contain,
                      //                     )
                      //                   : (popsafeDataDetail.codePin == "")
                      //                       ? Image.asset(
                      //                           "assets/images/ic_dummy_qrcode.png",
                      //                           fit: BoxFit.contain,
                      //                         )
                      //                       : GestureDetector(
                      //                           onTap: () {
                      //                             showDialog(
                      //                                 context: context,
                      //                                 builder:
                      //                                     (BuildContext context) {
                      //                                   return CustomDialogBox(
                      //                                     title: popsafeDataDetail
                      //                                         .codePin,
                      //                                   );
                      //                                 });
                      //                           },
                      //                           child: QrImage(
                      //                             data: popsafeDataDetail.codePin,
                      //                             version: QrVersions.auto,
                      //                             gapless: false,
                      //                             backgroundColor:
                      //                                 PopboxColor.mdWhite1000,
                      //                           )),
                      //             ),
                      //             SizedBox(width: 20.0),
                      //             Container(
                      //               width: 55.0.w,
                      //               child: Column(
                      //                 crossAxisAlignment: CrossAxisAlignment.start,
                      //                 mainAxisAlignment: MainAxisAlignment.center,
                      //                 children: [
                      //                   CustomWidget().textRegular(
                      //                       AppLocalizations.of(context).translate(
                      //                           LanguageKeys.collectionCode),
                      //                       PopboxColor.mdGrey180,
                      //                       10.0.sp,
                      //                       TextAlign.left),
                      //                   (popsafeDataDetail.codePin == "")
                      //                       ? CustomWidget().textRegular(
                      //                           AppLocalizations.of(context)
                      //                               .translate(LanguageKeys
                      //                                   .popsafeHistoryCodeSoon),
                      //                           PopboxColor.mdBlack1000,
                      //                           10.0.sp,
                      //                           TextAlign.left)
                      //                       : CustomWidget().textBold(
                      //                           popsafeDataDetail.codePin,
                      //                           PopboxColor.mdBlack1000,
                      //                           16.0.sp,
                      //                           TextAlign.left)
                      //                 ],
                      //               ),
                      //             )
                      //           ],
                      //         ),
                      //       )
                      //     : Container(),
                      //HOW TO SAFE
                      // (popsafeDataDetail.status == "CREATED" ||
                      //         popsafeDataDetail.status.replaceAll(" ", "") ==
                      //             "INSTORE")
                      //     ? GestureDetector(
                      //         onTap: () {
                      //           showQRcodeOnLocker(context);
                      //         },
                      //         child: Container(
                      //           margin: EdgeInsets.only(bottom: 20.0),
                      //           child: ReportOrderProblem(
                      //             imageUrl:
                      //                 "assets/images/ic_question_green.png",
                      //             title: (popsafeDataDetail.codePin == "")
                      //                 ? AppLocalizations.of(context).translate(
                      //                     LanguageKeys.popsafeHowToOrder)
                      //                 : AppLocalizations.of(context).translate(
                      //                     LanguageKeys.popsafeHowToTake),
                      //             subTitle: (popsafeDataDetail.codePin == "")
                      //                 ? AppLocalizations.of(context).translate(
                      //                     LanguageKeys.popsafeHowToOrderMore)
                      //                 : AppLocalizations.of(context).translate(
                      //                     LanguageKeys.popsafeHowToCollectMore),
                      //             bgColor: PopboxColor.mdYellowA500,
                      //           ),
                      //         ),
                      //       )
                      //     : Container(),
                      (popsafeDataDetail.status == "OVERDUE" ||
                              popsafeDataDetail.status ==
                                  "INBOUND_POPCENTER_LOCKER")
                          ? InkWell(
                              onTap: () {
                                // if (!isFree && data.inboundGroup != "PACKAGE_FOOD") {
                                //   showRulesPopcenter(context: context, data: data);
                                // }
                              },
                              child: Container(
                                height: 102,
                                width: MediaQuery.of(context).size.width,
                                margin:
                                    EdgeInsets.only(left: 16.0, right: 16.0),
                                padding: EdgeInsets.only(left: 22),
                                decoration: BoxDecoration(
                                    color: Color(0xffEAF3FF),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Image.asset(
                                        "assets/images/ic_popcenter_pay.png",
                                        fit: BoxFit.fitHeight,
                                        width: 120,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomWidget().googleFontRobboto(
                                          AppLocalizations.of(context)
                                              .translate(
                                                  LanguageKeys.collectionFee),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: Colors.black,
                                          textAlign: TextAlign.center,
                                        ),
                                        CustomWidget().googleFontRobboto(
                                          formatCurrency.format(
                                              popsafeDataDetail.totalPrice),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 25,
                                          color: Colors.black,
                                          textAlign: TextAlign.center,
                                        ),
                                        // isFree
                                        //     ? CustomWidget().googleFontRobboto(
                                        //         AppLocalizations.of(context).translate(
                                        //                 LanguageKeys.collectionFee) +
                                        //             " : " +
                                        //             AppLocalizations.of(context)
                                        //                 .translate(LanguageKeys.free),
                                        //         fontWeight: FontWeight.w400,
                                        //         fontSize: 10,
                                        //         color: Colors.black,
                                        //         textAlign: TextAlign.center,
                                        //       )
                                        //     : Row(
                                        //         children: [
                                        //           CustomWidget().googleFontRobboto(
                                        //             AppLocalizations.of(context)
                                        //                     .translate(LanguageKeys
                                        //                         .collectionFee) +
                                        //                 " " +
                                        //                 formatCurrency.format(
                                        //                     double.parse(data
                                        //                         .ppcInfo.pricePerDay)) +
                                        //                 " / 24 " +
                                        //                 AppLocalizations.of(context)
                                        //                     .translate(
                                        //                         LanguageKeys.hours),
                                        //             fontWeight: FontWeight.w400,
                                        //             fontSize: 10,
                                        //             color: Colors.black,
                                        //             textAlign: TextAlign.center,
                                        //           ),
                                        //           SizedBox(width: 3),
                                        //           CustomWidget().googleFontRobboto(
                                        //             AppLocalizations.of(context)
                                        //                 .translate(
                                        //                     LanguageKeys.learnMoreHere),
                                        //             fontWeight: FontWeight.w400,
                                        //             fontSize: 10,
                                        //             color: Color(0xff477FFF),
                                        //             textAlign: TextAlign.center,
                                        //           )
                                        //         ],
                                        //       ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                      SizedBox(height: 10),
                      //CONTAIN
                      Container(
                        width: 100.0.w,
                        margin: EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 17.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0,
                            color: PopboxColor.mdGrey300,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: Container(
                          margin: EdgeInsets.only(left: 16.0, right: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20.0),
                              CustomWidget().googleFontRobboto(
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.receiptNo),
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.black,
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 7.0),
                              CustomWidget().googleFontRobboto(
                                popsafeDataDetail.invoiceCode,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Colors.black,
                                textAlign: TextAlign.left,
                              ),
                              Divider(color: Colors.grey),
                              SizedBox(height: 20.0),
                              CustomWidget().googleFontRobboto(
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.status),
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.black,
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 7.0),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: (popsafeDataDetail.status ==
                                              "OVERDUE" ||
                                          popsafeDataDetail.status == "CANCEL")
                                      ? Color(0xffFFA9A9)
                                      : (popsafeDataDetail.status ==
                                              "COMPLETED")
                                          ? Color(0xffCBF1E4)
                                          : Color(0xffEAF3FF),
                                ),
                                child: CustomWidget().googleFontRobboto(
                                  AppLocalizations.of(context)
                                      .translate(popsafeDataDetail.status
                                          .toLowerCase()
                                          .replaceAll(" ", ""))
                                      .toUpperCase(),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  color: (popsafeDataDetail.status ==
                                              "OVERDUE" ||
                                          popsafeDataDetail.status == "CANCEL")
                                      ? Color(0xffFF0B09)
                                      : (popsafeDataDetail.status ==
                                              "COMPLETED")
                                          ? Color(0xff1CAC77)
                                          : Color(0xff477FFF),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Divider(color: Colors.grey),
                              SizedBox(height: 20.0),
                              CustomWidget().googleFontRobboto(
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.location),
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.black,
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 7.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 60.0.w,
                                    child: CustomWidget().googleFontRobboto(
                                      popsafeDataDetail.lockerName,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Colors.black,
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      var lockerModel =
                                          Provider.of<LockerViewModel>(context,
                                              listen: false);

                                      List<LockerData> lockerList =
                                          lockerModel.newLockerList;

                                      try {
                                        LockerData lockerData =
                                            lockerList.firstWhere((element) =>
                                                element.name
                                                    .trim()
                                                    .toLowerCase() ==
                                                popsafeDataDetail.lockerName
                                                    .trim()
                                                    .toLowerCase());
                                        if (lockerData.latitude != null &&
                                            lockerData.latitude != "" &&
                                            lockerData.latitude != "-") {
                                          if (Platform.isIOS) {
                                            await MapLauncher.launchMap(
                                              mapType: MapType.apple,
                                              coords: Coords(
                                                  double.parse(
                                                      lockerData.latitude),
                                                  double.parse(
                                                      lockerData.longitude)),
                                              title: lockerData.name,
                                              description: lockerData.address,
                                            );
                                          } else {
                                            await MapLauncher.launchMap(
                                              mapType: MapType.google,
                                              coords: Coords(
                                                  double.parse(
                                                      lockerData.latitude),
                                                  double.parse(
                                                      lockerData.longitude)),
                                              title: lockerData.name,
                                              description: lockerData.address,
                                            );
                                          }
                                        } else {
                                          CustomWidget().showToastShortV1(
                                              context: context,
                                              msg: AppLocalizations.of(context)
                                                  .translate(LanguageKeys
                                                      .canNotLoadLocation));
                                        }
                                      } catch (e) {
                                        CustomWidget().showToastShortV1(
                                            context: context,
                                            msg: AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .canNotLoadLocation));
                                      }
                                    },
                                    child: CustomWidget().googleFontRobboto(
                                      "Detail",
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: Color(0xff477FFF),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(color: Colors.grey),
                              SizedBox(height: 20.0),
                              (popsafeDataDetail.status == "CANCEL" ||
                                      popsafeDataDetail.status == "EXPIRED")
                                  ? Container()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomWidget().googleFontRobboto(
                                          AppLocalizations.of(context)
                                              .translate(
                                                  LanguageKeys.lockerSize),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Colors.black,
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(height: 6.0),
                                        CustomWidget().googleFontRobboto(
                                          popsafeDataDetail.lockerSize == ""
                                              ? "-"
                                              : popsafeDataDetail.lockerSize,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: Colors.black,
                                          textAlign: TextAlign.left,
                                        ),
                                        Divider(color: Colors.grey),
                                        SizedBox(height: 20.0),
                                      ],
                                    ),

                              //#1 Nomor & Ukuran Loker
                              Container(
                                width: 100.0.w,
                                child: (popsafeDataDetail.status == "CANCEL" ||
                                        popsafeDataDetail.status == "EXPIRED")
                                    ? Container()
                                    : Container(
                                        width: 40.0.w,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CustomWidget().googleFontRobboto(
                                                AppLocalizations.of(context)
                                                    .translate(
                                                        LanguageKeys.lockerNo),
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Colors.black,
                                                textAlign: TextAlign.left,
                                              ),
                                              SizedBox(height: 6.0),
                                              CustomWidget().googleFontRobboto(
                                                popsafeDataDetail
                                                            .lockerNumber ==
                                                        0
                                                    ? "-"
                                                    : popsafeDataDetail
                                                        .lockerNumber
                                                        .toString(),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: Colors.black,
                                                textAlign: TextAlign.left,
                                              ),
                                              Divider(color: Colors.grey),
                                              SizedBox(height: 20.0),
                                            ]),
                                      ),
                              ),

                              //#2 Waktu Ambil & Sisa Batas Ambil
                              Container(
                                width: 100.0.w,
                                child: Container(
                                  width: 40.0.w,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomWidget().googleFontRobboto(
                                          AppLocalizations.of(context)
                                              .translate(LanguageKeys.takeTime),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Colors.black,
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(height: 6.0),
                                        CustomWidget().googleFontRobboto(
                                          (popsafeDataDetail.takeTime == "")
                                              ? "-"
                                              : getFormattedDateShort(
                                                  popsafeDataDetail.takeTime),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: Colors.black,
                                          textAlign: TextAlign.left,
                                        ),
                                      ]),
                                ),
                              ),

                              (widget.transactionType ==
                                          "popsafe_cancel_success" ||
                                      popsafeDataDetail.status == "CANCEL" ||
                                      popsafeDataDetail.status == "EXPIRED")
                                  ? Container()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Divider(color: Colors.grey),
                                        SizedBox(height: 20.0),
                                        Container(
                                          width: 40.0.w,
                                          child:
                                              CustomWidget().googleFontRobboto(
                                            AppLocalizations.of(context)
                                                .translate(
                                                    LanguageKeys.takeLimitTime),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            color: Colors.black,
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        SizedBox(height: 6.0),
                                        CustomWidget().googleFontRobboto(
                                          getFormattedDateShort(
                                              popsafeDataDetail.expiredTime),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: PopboxColor.popboxPrimaryRed,
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                              Divider(color: Colors.grey),
                              SizedBox(height: 20.0),
                              //#3 Waktu Kirim & Maks Pembatalan
                              Container(
                                width: 100.0.w,
                                child: Row(children: [
                                  (widget.transactionType ==
                                              "popsafe_cancel_success" ||
                                          popsafeDataDetail.status ==
                                              "CANCEL" ||
                                          popsafeDataDetail.status ==
                                              "EXPIRED" ||
                                          popsafeDataDetail.status ==
                                              "COMPLETE")
                                      ? Container()
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomWidget().googleFontRobboto(
                                              AppLocalizations.of(context)
                                                  .translate(LanguageKeys
                                                      .popsafeHistoryMaxCancel),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: Colors.black,
                                              textAlign: TextAlign.left,
                                            ),
                                            SizedBox(height: 6.0),
                                            CustomWidget().textBold(
                                              getFormattedDateShort(
                                                  popsafeDataDetail
                                                      .cancellationTime),
                                              PopboxColor.mdGrey900,
                                              11.0.sp,
                                              TextAlign.left,
                                            ),
                                            Divider(color: Colors.grey),
                                            SizedBox(height: 17.0),
                                          ],
                                        ),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),

                      //DEV CONTAINER DETAIL PEMBAYARAN
                      Container(
                        width: 100.0.w,
                        margin: EdgeInsets.only(left: 16.0, right: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0,
                            color: PopboxColor.mdGrey300,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          color: Color(0xffEFEFEF),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(cardColor: Color(0xffEFEFEF)),
                            child: ExpansionPanelList(
                              animationDuration: Duration(milliseconds: 1000),
                              dividerColor: PopboxColor.mdBlack1000,
                              elevation: 0,
                              children: [
                                ExpansionPanel(
                                  body: Container(
                                    padding: EdgeInsets.only(left: 16.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        //PRICE
                                        CustomWidget().textRegular(
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys
                                                    .entrustedCosts),
                                            PopboxColor.mdBlack1000,
                                            11.0.sp,
                                            TextAlign.left),
                                        SizedBox(height: 7),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: CustomWidget().textBold(
                                            formatCurrency.format(
                                                popsafeDataDetail.totalPrice),
                                            PopboxColor.mdGrey900,
                                            11.0.sp,
                                            TextAlign.left,
                                          ),
                                        ),
                                        SizedBox(height: 11),
                                        //PROMO
                                        CustomWidget().textRegular(
                                            AppLocalizations.of(context)
                                                .translate(
                                                    LanguageKeys.voucherPromo),
                                            PopboxColor.mdBlack1000,
                                            11.0.sp,
                                            TextAlign.left),
                                        SizedBox(height: 7),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: CustomWidget().textBold(
                                            formatCurrency.format(
                                                popsafeDataDetail.promoPrice),
                                            PopboxColor.mdGrey900,
                                            11.0.sp,
                                            TextAlign.left,
                                          ),
                                        ),
                                        SizedBox(height: 11),
                                        //TOTAL PRICE
                                        CustomWidget().textRegular(
                                            AppLocalizations.of(context)
                                                .translate(
                                                    LanguageKeys.totalPrice),
                                            PopboxColor.mdBlack1000,
                                            11.0.sp,
                                            TextAlign.left),
                                        SizedBox(height: 7),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: CustomWidget().textBold(
                                            formatCurrency.format(
                                                popsafeDataDetail.paidPrice),
                                            PopboxColor.mdGrey900,
                                            11.0.sp,
                                            TextAlign.left,
                                          ),
                                        ),
                                        SizedBox(height: 11),
                                      ],
                                    ),
                                  ),
                                  //TITLE
                                  headerBuilder:
                                      (BuildContext context, bool isExpanded) {
                                    return Container(
                                      padding: EdgeInsets.only(
                                          top: 14.0, left: 16.0),
                                      child: CustomWidget().googleFontRobboto(
                                        AppLocalizations.of(context).translate(
                                            LanguageKeys.transactionDetail),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Colors.black,
                                        textAlign: TextAlign.left,
                                      ),
                                    );
                                  },
                                  isExpanded: isExpandedTransaction,
                                )
                              ],
                              expansionCallback: (int item, bool status) {
                                setState(() {
                                  isExpandedTransaction =
                                      !isExpandedTransaction;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      //DEV CONTAINER
                      SizedBox(height: 10.0),
                      //DEV CONTAINER DETAIL PEMBAYARAN
                      Container(
                        width: 100.0.w,
                        margin: EdgeInsets.only(left: 16.0, right: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0,
                            color: PopboxColor.mdGrey300,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          color: Color(0xffEFEFEF),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(cardColor: Color(0xffEFEFEF)),
                            child: ExpansionPanelList(
                              animationDuration: Duration(milliseconds: 1000),
                              dividerColor: PopboxColor.mdBlack1000,
                              elevation: 0,
                              children: [
                                ExpansionPanel(
                                  body: trackingPopsafeWidget(
                                      popsafeHistory:
                                          popsafeDataDetail.popsafeHistory),
                                  //TITLE
                                  headerBuilder:
                                      (BuildContext context, bool isExpanded) {
                                    return Container(
                                      padding: EdgeInsets.only(
                                          top: 14.0, left: 16.0),
                                      child: CustomWidget().googleFontRobboto(
                                        AppLocalizations.of(context)
                                            .translate(LanguageKeys.tracking),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Colors.black,
                                        textAlign: TextAlign.left,
                                      ),
                                    );
                                  },
                                  isExpanded: isExpandedTrack,
                                )
                              ],
                              expansionCallback: (int item, bool status) {
                                setState(() {
                                  isExpandedTrack = !isExpandedTrack;
                                });
                              },
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16.0),
                      InkWell(
                        onTap: () {
                          callCsBottomSheet(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info, color: Color(0xFFFF9C08)),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)
                                        .translate(LanguageKeys.havingProblem),
                                    style: TextStyle(
                                      color: Color(0xFF202020),
                                      fontSize: 12,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(context)
                                        .translate(LanguageKeys
                                            .callPopboxCustomerService),
                                    style: TextStyle(
                                      color: Color(0xFF477FFF),
                                      fontSize: 12,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 150.0),
                    ],
                  )
                ]),
                //BUTTON CANCEL OR EXTEND
                popsafeDataDetail.status == "CREATED" && timeDifference < 3600
                    ? GestureDetector(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  bottom: 20.0, left: 20.0, right: 20),
                              decoration: BoxDecoration(
                                color: Color(0xffF7F7F7),
                                border:
                                    Border.all(color: PopboxColor.popboxRed),
                              ),
                              child: CustomWidget().customColorButton(
                                  context,
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.orderCancel),
                                  PopboxColor.mdWhite1000,
                                  PopboxColor.popboxRed),
                            ),
                          ],
                        ),
                        onTap: () {
                          showCancelOrder(context);
                        },
                      )
                    : (popsafeDataDetail.status == "OVERDUE")
                        ? GestureDetector(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                      bottom: 20.0,
                                      left: 20.0,
                                      right: 20,
                                      top: 15),
                                  color: Color(0xffF7F7F7),
                                  child: CustomWidget().customColorButton(
                                      context,
                                      AppLocalizations.of(context).translate(
                                          LanguageKeys.popsafeHowToExtend),
                                      PopboxColor.popboxRed,
                                      PopboxColor.mdWhite1000),
                                ),
                              ],
                            ),
                            onTap: () {
                              //
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => MethodPaymentPage()),
                              );

                              // if (showPopsafe == false) {
                              //   showPopsafeInfo(context: context);
                              // } else {
                              //   showExtendOrder(context);
                              // }
                            },
                          )
                        : Container(),
              ],
            ),
          )
        : cartShimmerView(context);
  }

  Future<bool> _willPopCallback() async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
        (Route<dynamic> route) => false);
    return Future.value(true);
  }

  Widget textContentColor({
    String title,
    String content,
    Color contentColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 45.0.w,
          child: CustomWidget().textRegular(
            title,
            PopboxColor.mdGrey700,
            10.0.sp,
            TextAlign.left,
          ),
        ),
        Flexible(
          child: CustomWidget().textBoldProduct(
            content.toString() + " ",
            contentColor,
            11.0.sp,
            5,
          ),
        ),
      ],
    );
  }

  Widget textContentWithStatus({
    BuildContext context,
    String title,
    String content,
    double fontSize,
    String status,
    double fontSizeStatus,
  }) {
    if (status == "DIKEMBALIKAN") {
      fontSizeStatus = 8;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 45.0.w,
          child: CustomWidget().textRegular(
            title,
            PopboxColor.mdGrey700,
            fontSize,
            TextAlign.left,
          ),
        ),
        Container(
          child: CustomWidget().textBoldProduct(
            content,
            PopboxColor.mdGrey900,
            fontSize,
            5,
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 10),
          padding: EdgeInsets.only(left: 10, right: 10),
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: PopboxColor.mdRed500,
          ),
          child: Center(
            child: CustomWidget().textBold(status, PopboxColor.mdWhite1000,
                fontSizeStatus, TextAlign.left),
          ),
        )
      ],
    );
  }

  Widget onlyTextContent(
      {BuildContext context,
      String title,
      String content,
      Color contentColor,
      double fontSize,
      bool canCopy = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 45.0.w,
          child: CustomWidget().textRegular(
            title,
            PopboxColor.mdGrey700,
            10.0.sp,
            TextAlign.left,
          ),
        ),
        Flexible(
          child: InkWell(
              onTap: () {
                if (canCopy) {
                  Clipboard.setData(new ClipboardData(text: content));
                  CustomWidget().showToastShortV1(
                      context: context, msg: "Copied to Clipboard");
                }
              },
              child: CustomWidget().textBold(
                  content,
                  contentColor == null ? PopboxColor.mdGrey900 : contentColor,
                  fontSize == null ? 11.0.sp : fontSize,
                  TextAlign.left)),
        ),
      ],
    );
  }

  Widget textContentImage(
      {BuildContext context, String title, String content, bool enableCopy}) {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 45.0.w,
          child: CustomWidget().textRegular(
            title,
            PopboxColor.mdGrey700,
            11.0.sp,
            TextAlign.left,
          ),
        ),
        Flexible(
          child: Container(
            width: 45.0.w,
            child: CustomWidget().textBoldProduct(
              content,
              PopboxColor.mdGrey900,
              12.0.sp,
              5,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (enableCopy) {
              Clipboard.setData(new ClipboardData(text: content));
              CustomWidget().showCustomDialog(
                  context: context, msg: "Copied to Clipboard");
            }
          },
          child: Image.asset(
            "assets/images/ic_direct_to.png",
            fit: BoxFit.fitHeight,
          ),
        ),
      ],
    );
  }

  Widget textContentLocation(
      {BuildContext context, String title, String content}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 45.0.w,
          child: CustomWidget().textRegular(
            title,
            PopboxColor.mdGrey700,
            10.0.sp,
            TextAlign.left,
          ),
        ),
        Flexible(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidget().textBold(
                  content, PopboxColor.mdGrey900, 11.0.sp, TextAlign.left),
              Container(
                height: 40.0,
                width: 120.0,
                margin: EdgeInsets.only(top: 12.0),
                child: CustomButtonWhiteSmallerRounded(
                  onPressed: () async {
                    //print("objectaaaaa");
                    var lockerModel =
                        Provider.of<LockerViewModel>(context, listen: false);

                    List<LockerData> lockerList = lockerModel.newLockerList;

                    try {
                      LockerData lockerData = lockerList.firstWhere((element) =>
                          element.name.trim().toLowerCase() ==
                          content.trim().toLowerCase());

                      if (lockerData.latitude != null &&
                          lockerData.latitude != "" &&
                          lockerData.latitude != "-") {
                        if (Platform.isIOS) {
                          // ignore: deprecated_member_use
                          await MapLauncher.launchMap(
                            mapType: MapType.apple,
                            coords: Coords(double.parse(lockerData.latitude),
                                double.parse(lockerData.longitude)),
                            title: lockerData.name,
                            description: lockerData.address,
                          );
                        } else {
                          // ignore: deprecated_member_use
                          await MapLauncher.launchMap(
                            mapType: MapType.google,
                            coords: Coords(double.parse(lockerData.latitude),
                                double.parse(lockerData.longitude)),
                            title: lockerData.name,
                            description: lockerData.address,
                          );
                        }
                      } else {
                        CustomWidget().showToastShortV1(
                            context: context,
                            msg: AppLocalizations.of(context)
                                .translate(LanguageKeys.canNotLoadLocation));
                      }
                    } catch (e) {
                      CustomWidget().showToastShortV1(
                          context: context,
                          msg: AppLocalizations.of(context)
                              .translate(LanguageKeys.canNotLoadLocation));
                    }
                  },
                  title: AppLocalizations.of(context)
                      .translate(LanguageKeys.seeLocation),
                  width: 100.0,
                  fontSize: 8.0.sp,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget onlyImageContent({String title, String content}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 45.0.w,
          child: CustomWidget().textRegular(
            title,
            PopboxColor.mdGrey700,
            11.0.sp,
            TextAlign.left,
          ),
        ),
        Image.asset(
          "assets/images/ic_dummy_jne.png",
          fit: BoxFit.fitHeight,
        ),
      ],
    );
  }

  Widget numberItem(String number) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Container(
        child: CustomWidget().textBold(
          number,
          PopboxColor.mdWhite1000,
          11.0.sp,
          TextAlign.left,
        ),
        decoration: new BoxDecoration(
            borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
            color: PopboxColor.mdYellow800),
        padding: new EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      ),
    );
  }

  void showCancelOrder(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            color: Color(0xFF737373),
            child: Container(
              decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(12.0),
                      topRight: const Radius.circular(12.0))),
              child: new Wrap(
                children: <Widget>[
                  PopsafeCancelWidget(
                      popsafeHistoryDetailData:
                          (widget.transactionType == "popsafe")
                              ? popsafeDataDetail
                              : widget.popsafeHistoryDetailData),
                ],
              ),
            ),
          );
        });
  }

  void showExtendOrder(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            margin: EdgeInsets.only(bottom: 45),
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
                            "assets/images/ic_close_icon.png",
                            height: 16.0,
                            width: 16.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 32.0),
                          child: CustomWidget().textBold(
                            AppLocalizations.of(context).translate(
                                LanguageKeys.popsafeExtendOrderTitle),
                            PopboxColor.mdBlack1000,
                            12.0.sp,
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
                Container(
                  margin: EdgeInsets.only(left: 20, top: 30),
                  child: CustomWidget().textBold(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.choosePaymentMethod),
                      PopboxColor.mdBlack1000,
                      10.0.sp,
                      TextAlign.left),
                ),
                //PopBox
                InkWell(
                  onTap: () {
                    //FIX
                    SharedPreferencesService().user.balance <=
                            popsafeDataDetail.totalPrice
                        // ignore: unnecessary_statements
                        ? {print("Popsafe Extend => Saldo tida cukup")}
                        : SharedPreferencesService().user.balance >
                                popsafeDataDetail.totalPrice
                            // ignore: unnecessary_statements
                            ? {
                                Navigator.pop(context),
                                showExtendFormOrder(context)
                              }
                            // ignore: unnecessary_statements
                            : {};
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 20, right: 20, top: 25),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: (SharedPreferencesService().user.balance >
                                popsafeDataDetail.totalPrice)
                            ? PopboxColor.popboxGreyPopsafe
                            : PopboxColor.popboxGrey500Popsafe),
                    height: 80,
                    width: 370,
                    child: Row(
                      children: [
                        SizedBox(width: 42),
                        Image.asset(
                          "assets/images/ic_popbox_pay.png",
                          height: 50.0,
                          width: 70.0,
                        ),
                        SizedBox(width: 20),
                        CustomWidget().textRegular("PopBox Deposit",
                            PopboxColor.mdBlack1000, 12.0.sp, TextAlign.left)
                      ],
                    ),
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(left: 20, top: 6),
                  child: CustomWidget().textRegular(
                      AppLocalizations.of(context)
                              .translate(LanguageKeys.saldoPopboxDeposit) +
                          " " +
                          formatCurrency
                              .format(SharedPreferencesService().user.balance),
                      PopboxColor.buttonRedLight,
                      10.0.sp,
                      TextAlign.left),
                ),
                //OVO
                InkWell(
                  onTap: () {
                    print("OVO TAP");
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WebviewPage(
                          urlMicrosite: popsafeDataDetail.micrositeUrl,
                          reason: "microsite",
                          appbarTitle: AppLocalizations.of(context)
                              .translate(LanguageKeys.popsafeHowToExtend),
                          invoiceId: widget.popsafeData.invoiceCode,
                        ),
                      ),
                    );
                  },
                  child: CustomWidget()
                      .paymentMethod("assets/images/ic_ovo_pay.png", "OVO"),
                ),
                //GOPAY
                InkWell(
                  onTap: () {
                    print("GOPAY TAP");
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WebviewPage(
                          urlMicrosite: popsafeDataDetail.micrositeUrl,
                          reason: "microsite",
                          appbarTitle: AppLocalizations.of(context)
                              .translate(LanguageKeys.popsafeHowToExtend),
                          invoiceId: widget.popsafeData.invoiceCode,
                        ),
                      ),
                    );
                  },
                  child: CustomWidget()
                      .paymentMethod("assets/images/ic_gopay_pay.png", "gopay"),
                ),
              ],
            ),
          );
        });
  }

  void showExtendFormOrder(context) {
    print('log: showExtendFormOrder');
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            margin: EdgeInsets.only(bottom: 30),
            child: new Wrap(
              children: <Widget>[
                Container(height: 15),
                Center(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20),
                    color: PopboxColor.mdGrey300,
                    height: 5,
                    width: 40,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Center(
                    child: CustomWidget().textBold(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.popsafeExtendOrderTitle),
                      PopboxColor.mdBlack1000,
                      12.0.sp,
                      TextAlign.center,
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
                //hide
                // CustomWidget().alertInfoPopsafeExtend(context),
                Container(
                  margin: EdgeInsets.only(left: 20, top: 30),
                  child: CustomWidget().textBold(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.orderDetail),
                      PopboxColor.mdBlack1000,
                      12.0.sp,
                      TextAlign.left),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, top: 30),
                  child: onlyTextContent(
                      context: context,
                      title: AppLocalizations.of(context)
                          .translate(LanguageKeys.receiptNo),
                      content: popsafeDataDetail.invoiceCode,
                      canCopy: true),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                  child: Divider(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: onlyTextContent(
                      context: context,
                      title: AppLocalizations.of(context)
                          .translate(LanguageKeys.takeLimitTime),
                      content: popsafeDataDetail.expiredTime,
                      canCopy: true),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                  child: Divider(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: onlyTextContent(
                      context: context,
                      title: AppLocalizations.of(context)
                          .translate(LanguageKeys.popsafeExtendTime),
                      content: "24 " +
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.hours),
                      canCopy: true),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                  child: Divider(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: CustomWidget().textRegular(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.popsafeExtendOrderNotes),
                      PopboxColor.mdBlack1000,
                      9.0.sp,
                      TextAlign.left),
                ),
                //Popbox Deposit
                Container(
                  margin:
                      EdgeInsets.only(left: 20, right: 40, top: 30, bottom: 15),
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
                                      appbarTitle: AppLocalizations.of(context)
                                          .translate(LanguageKeys.deposit),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                                child: Container(
                                  margin: EdgeInsets.only(left: 5, right: 5),
                                  child: Center(
                                    child: CustomWidget().textRegular(
                                        AppLocalizations.of(context)
                                            .translate(LanguageKeys.infoShort),
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
                        formatCurrency
                            .format(SharedPreferencesService().user.balance),
                        PopboxColor.buttonRedLight,
                        FontWeight.w700,
                        11.0.sp,
                      )
                    ],
                  ),
                ),
                Container(
                  height: 60,
                  color: PopboxColor.mdGrey200,
                  child: Container(
                    margin: EdgeInsets.only(left: 20, right: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomWidget().textRegulerInfoCurrencyPopsafe(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.safePrice),
                            FontWeight.w400,
                            10.0.sp),
                        CustomWidget().textRegulerCurrencyPopsafe(
                          formatCurrency.format(popsafeDataDetail.totalPrice),
                          PopboxColor.mdBlack1000,
                          FontWeight.w700,
                          10.0.sp,
                        )
                      ],
                    ),
                  ),
                ),
                Container(height: 20),
                GestureDetector(
                  onTap: () {
                    (popsafeDataDetail.totalPrice <=
                            SharedPreferencesService().user.balance)
                        // ignore: unnecessary_statements
                        ? {
                            //SUBMIT FORM
                            onLoading(),
                            submitExtend()
                          }
                        // ignore: unnecessary_statements
                        : {print("SALDO KURANG")};
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 20.0, right: 20.0),
                    padding: EdgeInsets.only(
                        left: 20, right: 20, bottom: 16.0, top: 16.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: (popsafeDataDetail.totalPrice <=
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
                              formatCurrency
                                  .format(popsafeDataDetail.totalPrice),
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
          );
        });
  }

  //onLoading
  void onLoading() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: SizedBox(
                height: 50, width: 50, child: CircularProgressIndicator()),
          );
        });
  }

  void submitExtend() {
    PopsafeExtendPayload popsafeExtendPayload = new PopsafeExtendPayload()
      ..token = GlobalVar.API_TOKEN
      ..sessionId = SharedPreferencesService().user.sessionId
      ..invoiceId = popsafeDataDetail.invoiceCode;

    final extendModel = Provider.of<PopsafeViewModel>(context, listen: false);
    extendModel.popsafeExtend(popsafeExtendPayload, context,
        onSuccess: (response) {
      CustomWidget().showCustomDialog(
          context: this.context,
          msg: AppLocalizations.of(this.context)
              .translate(LanguageKeys.popsafe_success_extendorder));

      PopsafeHistoryDetailPayload historyDetailPayload =
          new PopsafeHistoryDetailPayload()
            ..sessionId = SharedPreferencesService().user.sessionId
            ..token = GlobalVar.API_TOKEN
            ..invoiceId = popsafeDataDetail.invoiceCode;

      extendModel.popsafeHistoryDetail(
        historyDetailPayload,
        this.context,
        onSuccess: (response) {
          setState(() {
            popsafeDataDetail = response.data.first;

            Future.delayed(const Duration(milliseconds: 400), () {
              Navigator.of(this.context).pushReplacement(MaterialPageRoute(
                builder: (context) => TransactionDetailPage(
                  transactionType: 'popsafe_extend_success',
                  popsafeHistoryDetailData: popsafeDataDetail,
                ),
              ));
            });
          });
        },
        onError: (response) {
          CustomWidget().showCustomDialog(
              context: this.context, msg: response.response.message);
        },
      );
    }, onError: (response) {
      try {
        CustomWidget().showCustomDialog(
            context: this.context, msg: response.response.message);
      } catch (e) {
        CustomWidget().showCustomDialog(
            context: this.context, msg: "catch : " + e.toString());
      }
    });
  }

  void showQRcodeOnLocker(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            child: new Column(
              children: <Widget>[
                SizedBox(height: 15),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      color: PopboxColor.mdGrey300,
                      height: 5,
                      width: 40,
                    ),
                    (widget.transactionType == "popsafe_success")
                        ? CustomWidget().textBold(
                            (widget.popsafeHistoryDetailData.codePin == "")
                                ? AppLocalizations.of(context)
                                    .translate(LanguageKeys.popsafeHowToOrder)
                                : AppLocalizations.of(context)
                                    .translate(LanguageKeys.popsafeHowToTake),
                            PopboxColor.mdBlack1000,
                            13.0.sp,
                            TextAlign.center)
                        : CustomWidget().textBold(
                            (popsafeDataDetail.codePin == "")
                                ? AppLocalizations.of(context)
                                    .translate(LanguageKeys.popsafeHowToOrder)
                                : AppLocalizations.of(context)
                                    .translate(LanguageKeys.popsafeHowToTake),
                            PopboxColor.mdBlack1000,
                            13.0.sp,
                            TextAlign.center),
                    SizedBox(height: 10),
                    Divider(color: PopboxColor.mdGrey300, height: 1.0),
                    SizedBox(height: 45),
                    (widget.transactionType == "popsafe_success")
                        ? QrImage(
                            data: (widget.popsafeHistoryDetailData.codePin ==
                                    "")
                                ? widget.popsafeHistoryDetailData.invoiceCode
                                : widget.popsafeHistoryDetailData.codePin,
                            version: QrVersions.auto,
                            size: 230,
                            gapless: false,
                            padding: EdgeInsets.all(4.0),
                            backgroundColor: PopboxColor.mdWhite1000,
                          )
                        : QrImage(
                            data: (popsafeDataDetail.codePin == "")
                                ? popsafeDataDetail.invoiceCode
                                : popsafeDataDetail.codePin,
                            version: QrVersions.auto,
                            size: 230,
                            gapless: false,
                            padding: EdgeInsets.all(4.0),
                            backgroundColor: PopboxColor.mdWhite1000,
                          ),
                    SizedBox(height: 10),
                    (widget.transactionType == "popsafe_success")
                        ? CustomWidget().textBold(
                            (widget.popsafeHistoryDetailData.codePin == "")
                                ? widget.popsafeHistoryDetailData.invoiceCode
                                : widget.popsafeHistoryDetailData.codePin,
                            PopboxColor.mdBlack1000,
                            10.0.sp,
                            TextAlign.center)
                        : CustomWidget().textBold(
                            (popsafeDataDetail.codePin == "")
                                ? popsafeDataDetail.invoiceCode
                                : popsafeDataDetail.codePin,
                            PopboxColor.mdBlack1000,
                            10.0.sp,
                            TextAlign.center),
                    SizedBox(height: 20),
                    (widget.transactionType == "popsafe_success")
                        ? Container(
                            margin: EdgeInsets.only(left: 45, right: 45),
                            child: CustomWidget().textRegular(
                                (widget.popsafeHistoryDetailData.codePin == "")
                                    ? AppLocalizations.of(context).translate(
                                        LanguageKeys.popsafeHowToOrderStep)
                                    : AppLocalizations.of(context).translate(
                                        LanguageKeys.popsafeHowToTakeStep),
                                PopboxColor.mdBlack1000,
                                10.0.sp,
                                TextAlign.left),
                          )
                        : Container(
                            margin: EdgeInsets.only(left: 45, right: 45),
                            child: CustomWidget().textRegular(
                                (popsafeDataDetail.codePin == "")
                                    ? AppLocalizations.of(context).translate(
                                        LanguageKeys.popsafeHowToOrderStep)
                                    : AppLocalizations.of(context).translate(
                                        LanguageKeys.popsafeHowToTakeStep),
                                PopboxColor.mdBlack1000,
                                10.0.sp,
                                TextAlign.left),
                          ),
                    SizedBox(height: 33),
                    Container(
                      color: PopboxColor.mdYellow150,
                      width: MediaQuery.of(context).size.width,
                      height: 60,
                      child: Center(
                        child: CustomWidget().textRegular(
                            AppLocalizations.of(context).translate(
                                LanguageKeys.popsafeHowToOrderStepInfo),
                            PopboxColor.mdBlack1000,
                            9.0.sp,
                            TextAlign.center),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  setCurrency() {
    String localFormat = "";
    if (countryCode == "ID") {
      localFormat = 'id_ID';
    } else if (countryCode == "MY") {
      localFormat = 'ms_MY';
    } else {
      localFormat = 'fil_PH';
    }
    formatCurrency = new NumberFormat.simpleCurrency(locale: localFormat);
    if (countryCode == "ID") {
      setState(() {
        currencyText = "Rp.";
      });
    } else if (countryCode == "MY") {
      setState(() {
        currencyText = "RM";
      });
    }
  }

  //Widget
  void showExtendReasonSelect({context, dynamic data, String from}) {
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
                                        AppLocalizations.of(context).translate(
                                            LanguageKeys.chooseReason),
                                        Color(0xff222222),
                                        16,
                                        TextAlign.center),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            RadioListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.forgot),
                                    Color(0xff202020),
                                    14,
                                    TextAlign.left),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                value: AppLocalizations.of(context)
                                    .translate(LanguageKeys.forgot),
                                activeColor: Color(0xffFF0000),
                                groupValue: _valueExtendReason,
                                onChanged: (value) {
                                  setstateBuilder(() {
                                    _valueExtendReason = value;
                                    print(_valueExtendReason);
                                  });
                                }),
                            RadioListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context).translate(
                                        LanguageKeys.lateNotification),
                                    Color(0xff202020),
                                    14,
                                    TextAlign.left),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                value: AppLocalizations.of(context)
                                    .translate(LanguageKeys.lateNotification),
                                activeColor: Color(0xffFF0000),
                                groupValue: _valueExtendReason,
                                onChanged: (value) {
                                  setstateBuilder(() {
                                    _valueExtendReason = value;
                                    print(_valueExtendReason);
                                  });
                                }),
                            RadioListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.outOfTown),
                                    Color(0xff202020),
                                    14,
                                    TextAlign.left),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                value: AppLocalizations.of(context)
                                    .translate(LanguageKeys.outOfTown),
                                activeColor: Color(0xffFF0000),
                                groupValue: _valueExtendReason,
                                onChanged: (value) {
                                  setstateBuilder(() {
                                    _valueExtendReason = value;
                                    print(_valueExtendReason);
                                  });
                                }),
                            RadioListTile(
                                title: CustomWidget().textLight(
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.others),
                                    Color(0xff202020),
                                    14,
                                    TextAlign.left),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                value: "Others",
                                activeColor: Color(0xffFF0000),
                                groupValue: _valueExtendReason,
                                onChanged: (value) {
                                  setstateBuilder(() {
                                    _valueExtendReason = value;
                                    print(_valueExtendReason);
                                  });
                                }),
                            (_valueExtendReason == "Others")
                                ? Container(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16),
                                    child: TextField(
                                      controller: _noteExtendController,
                                      autocorrect: true,
                                      cursorColor: PopboxColor.mdGrey700,
                                      style: TextStyle(
                                        color: PopboxColor.mdBlack1000,
                                        fontSize: 12.0.sp,
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            color: PopboxColor.mdGrey900),
                                        filled: true,
                                        fillColor: PopboxColor.mdGrey150,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                              color: PopboxColor.mdGrey300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                              color: PopboxColor.mdGrey300),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      var parcelModel =
                          Provider.of<ParcelViewModel>(context, listen: false);
                      LastmileExtendPayload lastmileExtendPayload;
                      if (_valueExtendReason.isEmpty) {
                        CustomWidget().showCustomDialog(
                          context: context,
                          msg: AppLocalizations.of(context)
                              .translate(
                                LanguageKeys.caseIsRequired,
                              )
                              .replaceAll(
                                  "%1s",
                                  AppLocalizations.of(context)
                                      .translate(LanguageKeys.chooseReason)),
                        );
                      } else {
                        if (_valueExtendReason == "Others") {
                          lastmileExtendPayload = new LastmileExtendPayload()
                            ..sessionId =
                                SharedPreferencesService().user.sessionId
                            ..token = GlobalVar.API_TOKEN
                            ..parcelId =
                                (from == "parcel") ? data.id : data.parcelId
                            ..reason = _noteExtendController.text;
                        } else {
                          lastmileExtendPayload = new LastmileExtendPayload()
                            ..sessionId =
                                SharedPreferencesService().user.sessionId
                            ..token = GlobalVar.API_TOKEN
                            ..parcelId =
                                (from == "parcel") ? data.id : data.parcelId
                            ..reason = _valueExtendReason.toString();
                        }

                        await parcelModel
                            .lastmileExtend(lastmileExtendPayload, context,
                                onSuccess: (response) {
                          _showSuccessInfo(
                              context, true, response.data.first.messages);
                        }, onError: (response) {
                          _showSuccessInfo(
                              context, false, response.data.first.messages);
                        });
                      }
                    },
                    child: Container(
                      width: 100.0.w,
                      color: Color(0xffF7F7F7),
                      padding: EdgeInsets.only(
                          left: 16, right: 16, top: 16, bottom: 16),
                      child: Consumer<ParcelViewModel>(
                          builder: (context, model, _) {
                        return Stack(children: [
                          CustomButtonRectangle(
                            title: AppLocalizations.of(context)
                                .translate(LanguageKeys.next)
                                .toUpperCase(),
                            bgColor: PopboxColor.popboxRed,
                            textColor: PopboxColor.mdWhite1000,
                            fontSize: 14,
                          ),
                          if (model.loading) ...[
                            Center(
                              child: CircularProgressIndicator(
                                backgroundColor: PopboxColor.popboxRed,
                              ),
                            )
                          ]
                        ]);
                      }),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).whenComplete(() => null);
  }

  void showTrackingPopcenter({context, PopcenterDetailData data}) {
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
                                  .translate(LanguageKeys.tracking),
                              PopboxColor.mdBlack1000,
                              16,
                              TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.collectTrackingHistory.length,
                        itemBuilder: (context, index) {
                          CollectTrackingHistory item =
                              data.collectTrackingHistory[index];

                          return Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: TransactionTrackingItem(
                              dataPopcenter: item,
                              language: languageCode,
                              isFirst: (index == 0) ? true : false,
                              reason: "popcenter",
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
          );
        }).whenComplete(() => null);
  }

  void showTracking({context, ParcelHistoryDetailData data}) {
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
                                  .translate(LanguageKeys.tracking),
                              PopboxColor.mdBlack1000,
                              16,
                              TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.history.length,
                        itemBuilder: (context, index) {
                          History item = data.history[index];
                          return Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: TransactionTrackingItem(
                              data: item,
                              lockerName: data.locker,
                              language: languageCode,
                              isFirst: (index == 0) ? true : false,
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
          );
        }).whenComplete(() => null);
  }

  void showPPCFlatMYNonFree({context, double pricePPC, dynamic data}) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.white,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setstateBuilder) => Container(
                height: MediaQuery.of(context).size.height * 0.55,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Stack(
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Icon(Icons.close),
                            )),
                        Align(
                          alignment: Alignment.center,
                          child: CustomWidget().textBoldPlus(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.rules),
                              PopboxColor.mdBlack1000,
                              16,
                              TextAlign.center),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 1,
                      width: 100.0.w,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CustomWidget().textBold(
                          AppLocalizations.of(context).translate(
                              LanguageKeys.ppcFlatMYRuleNonFreeTitle),
                          Colors.black,
                          12,
                          TextAlign.left),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CustomWidget().textLight(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.collectionFee),
                          Colors.grey,
                          12,
                          TextAlign.left),
                    ),
                    SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffFBFBFB),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomWidget().textBold(
                                  AppLocalizations.of(context)
                                          .translate(LanguageKeys.day) +
                                      " 1-" +
                                      data.lockerInfo.freeDays.toString(),
                                  Colors.grey,
                                  12,
                                  TextAlign.left),
                              SizedBox(height: 10),
                              CustomWidget().textBold(
                                  "> " +
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.day) +
                                      (data.lockerInfo.freeDays + 1).toString(),
                                  Colors.grey,
                                  12,
                                  TextAlign.left),
                              SizedBox(height: 10),
                              CustomWidget().textBold(
                                  "Total", Colors.grey, 12, TextAlign.left),
                            ],
                          ),
                          SizedBox(width: 35),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomWidget().textBold(
                                  data.ppcInfo.priceInstore.toString(),
                                  Colors.grey,
                                  12,
                                  TextAlign.left),
                              SizedBox(height: 10),
                              CustomWidget().textBold(
                                  AppLocalizations.of(context)
                                          .translate(LanguageKeys.additional) +
                                      " " +
                                      formatCurrency.format(double.parse(
                                          data.ppcInfo.priceOverdue)),
                                  Colors.grey,
                                  12,
                                  TextAlign.left),
                              SizedBox(height: 10),
                              CustomWidget().textBold(
                                  formatCurrency.format(pricePPC),
                                  Color(0xffFF0B09),
                                  12,
                                  TextAlign.left),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CustomWidget().textLight(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.ppcFlatMYRuleNonFreeNote),
                          Color(0xffFF0B09),
                          12,
                          TextAlign.left),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CustomWidget().textLight(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.paymentCanBeUsed),
                          Colors.black,
                          12,
                          TextAlign.left),
                    ),
                    SizedBox(height: 10),
                    Image.asset(
                      "assets/images/ic_payment_method.png",
                      height: 30.0,
                      fit: BoxFit.fitHeight,
                    ),
                  ],
                )),
          );
        });
  }

  void showPPCFlatMY({context, double pricePPC}) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setstateBuilder) => Container(
                height: MediaQuery.of(context).size.height * 0.48,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Stack(
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Icon(Icons.close),
                            )),
                        Align(
                          alignment: Alignment.center,
                          child: CustomWidget().textBoldPlus(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.rules),
                              PopboxColor.mdBlack1000,
                              16,
                              TextAlign.center),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 1,
                      width: 100.0.w,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CustomWidget().textLight(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.price),
                          PopboxColor.mdBlack1000,
                          12,
                          TextAlign.left),
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CustomWidget().textRegular(
                          formatCurrency.format(pricePPC),
                          PopboxColor.mdBlack1000,
                          14,
                          TextAlign.left),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CustomWidget().textRegular(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.takeTimeRules),
                          PopboxColor.mdBlack1000,
                          14,
                          TextAlign.left),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CustomWidget().textLight(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.ppcFlatMYRuleNote),
                          PopboxColor.mdBlack1000,
                          12,
                          TextAlign.left),
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CustomWidget().textLight(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.isPPCnoteTwo),
                          Color(0xffFF0B09),
                          12,
                          TextAlign.left),
                    ),
                  ],
                )),
          );
        });
  }

  void showPPCnofreeday({context, dynamic data}) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setstateBuilder) => Container(
              height: MediaQuery.of(context).size.height * 0.75,
              color: Colors.white,
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Stack(
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Icon(Icons.close),
                              )),
                          Align(
                            alignment: Alignment.center,
                            child: CustomWidget().textBoldPlus(
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.rules),
                                PopboxColor.mdBlack1000,
                                16,
                                TextAlign.center),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Divider(color: Colors.grey),
                      SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: CustomWidget().textBold(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.isPPCnoteOnePaid),
                            Colors.black,
                            12,
                            TextAlign.left),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: CustomWidget().textLight(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.collectionFee),
                            Color(0xff43434380),
                            12,
                            TextAlign.left),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 100.0.w,
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        padding: const EdgeInsets.only(
                            left: 20, top: 20, bottom: 20),
                        decoration: BoxDecoration(
                            color: Color(0xffFBFBFB),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  bool priceFree = false;
                                  if (index < data.ppcInfo.freeDays) {
                                    priceFree = true;
                                  }
                                  int priceNominalFix =
                                      int.parse(data.ppcInfo.pricePerDay) *
                                          ((index + 1) - data.ppcInfo.freeDays);

                                  return Container(
                                    padding: const EdgeInsets.only(
                                        top: 3, bottom: 3),
                                    child: Row(
                                      children: [
                                        CustomWidget().textBold(
                                            AppLocalizations.of(context)
                                                    .translate(
                                                        LanguageKeys.day) +
                                                " ${index + 1}",
                                            Color(0xffA2A2A2),
                                            12,
                                            TextAlign.left),
                                        SizedBox(width: 40),
                                        CustomWidget().textBold(
                                            (priceFree)
                                                ? AppLocalizations.of(context)
                                                    .translate(
                                                        LanguageKeys.free)
                                                : priceNominalFix.toString(),
                                            Colors.black,
                                            12,
                                            TextAlign.left),
                                      ],
                                    ),
                                  );
                                }),
                            Container(
                              padding: const EdgeInsets.only(top: 3, bottom: 3),
                              child: Row(
                                children: [
                                  CustomWidget().textBold(
                                      "   > ${data.ppcInfo.maxDay}",
                                      Color(0xffA2A2A2),
                                      12,
                                      TextAlign.left),
                                  SizedBox(width: 40),
                                  CustomWidget().textBold(
                                      (int.parse(data.ppcInfo.pricePerDay) *
                                              (data.ppcInfo.maxDay -
                                                  data.ppcInfo.freeDays))
                                          .toString(),
                                      Color(0xffFF0000),
                                      12,
                                      TextAlign.left),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        child: CustomWidget().textLight(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.isPPCnoteTwoPaid),
                            Color(0xffFF0B09),
                            12,
                            TextAlign.left),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: CustomWidget().textLight(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.paymentCanBeUsed),
                            Colors.black,
                            12,
                            TextAlign.left),
                      ),
                      SizedBox(height: 10),
                      Image.asset(
                        "assets/images/ic_payment_method.png",
                        height: 30.0,
                        fit: BoxFit.fitHeight,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).whenComplete(() => null);
  }

  void showRulesWareHouse({context, dynamic data}) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setstateBuilder) => Container(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Stack(
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Icon(Icons.close),
                          )),
                      Align(
                        alignment: Alignment.center,
                        child: CustomWidget().textBold(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.rules),
                            PopboxColor.mdBlack1000,
                            16,
                            TextAlign.center),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(color: Colors.grey),
                  SizedBox(height: 20),
                  //PPC 1 FREE DAY
                  // Row(
                  //   children: [
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Container(
                  //           padding: const EdgeInsets.only(left: 20),
                  //           child: CustomWidget().textBold(
                  //               "Free", Color(0xffA4A4A4), 12, TextAlign.left),
                  //         ),
                  //         Container(
                  //           margin: EdgeInsets.only(left: 20),
                  //           child: DottedBorder(
                  //             color: Color(0xff477FFF),
                  //             strokeWidth: 1,
                  //             child: Container(
                  //               width: 30.0.w - 20,
                  //               child: Row(
                  //                 mainAxisAlignment: MainAxisAlignment.start,
                  //                 children: [
                  //                   Container(
                  //                     margin: const EdgeInsets.only(
                  //                         left: 9,
                  //                         right: 0,
                  //                         top: 15,
                  //                         bottom: 15),
                  //                     padding: const EdgeInsets.only(
                  //                         left: 9, right: 9, bottom: 5, top: 5),
                  //                     decoration: BoxDecoration(
                  //                         color: Color(0xff477FFF),
                  //                         borderRadius:
                  //                             BorderRadius.circular(5)),
                  //                     child: CustomWidget().textLight("Day 1",
                  //                         Colors.white, 12, TextAlign.left),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Container(
                  //           padding: const EdgeInsets.only(left: 0),
                  //           child: CustomWidget().textBold(
                  //               "Paid", Color(0xffA4A4A4), 12, TextAlign.left),
                  //         ),
                  //         DottedBorder(
                  //           color: Color(0xffFF0200),
                  //           strokeWidth: 1,
                  //           child: Container(
                  //             margin: EdgeInsets.only(right: 0),
                  //             width: 70.0.w - 20,
                  //             decoration: BoxDecoration(
                  //                 color: Color(0xffFFDDDD),
                  //                 borderRadius: BorderRadius.only(
                  //                   topRight: Radius.circular(6),
                  //                   bottomRight: Radius.circular(6),
                  //                 )),
                  //             child: Row(
                  //               mainAxisAlignment: MainAxisAlignment.start,
                  //               children: [
                  //                 Container(
                  //                   margin: const EdgeInsets.only(
                  //                       left: 9, right: 9, top: 15, bottom: 15),
                  //                   padding: const EdgeInsets.only(
                  //                       left: 9, right: 9, bottom: 5, top: 5),
                  //                   decoration: BoxDecoration(
                  //                       color: Color(0xffFF0B09),
                  //                       borderRadius: BorderRadius.circular(5)),
                  //                   child: CustomWidget().textLight("Day > 6",
                  //                       Colors.black, 12, TextAlign.left),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),

                  //NON PPC
                  Container(
                    padding: const EdgeInsets.only(left: 20),
                    child: CustomWidget().textBold(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.takeTime),
                        Color(0xffA4A4A4),
                        12,
                        TextAlign.left),
                  ),
                  SizedBox(height: 6),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      height: 60,
                      width: 100.0.w,
                      child: DottedBorder(
                        color: Color(0xff477FFF),
                        strokeWidth: 1,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: data.lockerInfo.freeDays,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(
                                    left: 9, right: 9, top: 12, bottom: 12),
                                padding:
                                    const EdgeInsets.only(left: 9, right: 9),
                                decoration: BoxDecoration(
                                    color: Color(0xff477FFF),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Center(
                                  child: CustomWidget().textLight(
                                      AppLocalizations.of(context)
                                              .translate(LanguageKeys.day) +
                                          " ${index + 1}",
                                      Colors.white,
                                      12,
                                      TextAlign.left),
                                ),
                              );
                            }),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 20),
                            child: CustomWidget().textBold(
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.day),
                                Color(0xffA4A4A4),
                                12,
                                TextAlign.left),
                          ),
                          SizedBox(height: 6),
                          Container(
                            margin: EdgeInsets.only(left: 20),
                            width: 60.0.w - 20,
                            decoration: BoxDecoration(
                                color: Color(0xffFF9900),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  bottomLeft: Radius.circular(6),
                                )),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 0, right: 0, top: 15, bottom: 15),
                                  padding: const EdgeInsets.only(
                                      left: 9, right: 9, bottom: 5, top: 5),
                                  decoration: BoxDecoration(
                                      color: Color(0xffF1F1F1),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: CustomWidget().textLight(
                                      AppLocalizations.of(context)
                                              .translate(LanguageKeys.day) +
                                          " ${data.lockerInfo.freeDays + 1}",
                                      Colors.black,
                                      12,
                                      TextAlign.left),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 0, right: 0, top: 15, bottom: 15),
                                  padding: const EdgeInsets.only(
                                      left: 9, right: 9, bottom: 5, top: 5),
                                  decoration: BoxDecoration(
                                      color: Color(0xffF1F1F1),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: CustomWidget().textLight(
                                      AppLocalizations.of(context)
                                              .translate(LanguageKeys.day) +
                                          " ${data.lockerInfo.freeDays + 2}",
                                      Colors.black,
                                      12,
                                      TextAlign.left),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 0, right: 0, top: 15, bottom: 15),
                                  padding: const EdgeInsets.only(
                                      left: 9, right: 9, bottom: 5, top: 5),
                                  decoration: BoxDecoration(
                                      color: Color(0xffF1F1F1),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: CustomWidget().textLight(
                                      AppLocalizations.of(context)
                                              .translate(LanguageKeys.day) +
                                          " ${data.lockerInfo.freeDays + 3}",
                                      Colors.black,
                                      12,
                                      TextAlign.left),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 0),
                            child: CustomWidget().textBold("Warehouse",
                                Color(0xffA4A4A4), 12, TextAlign.left),
                          ),
                          SizedBox(height: 6),
                          DottedBorder(
                            color: Color(0xffFF0200),
                            strokeWidth: 1,
                            child: Container(
                              margin: EdgeInsets.only(right: 0),
                              width: 40.0.w - 20,
                              decoration: BoxDecoration(
                                  color: Color(0xffFFDDDD),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(6),
                                    bottomRight: Radius.circular(6),
                                  )),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 9, right: 9, top: 15, bottom: 15),
                                    padding: const EdgeInsets.only(
                                        left: 9, right: 9, bottom: 5, top: 5),
                                    decoration: BoxDecoration(
                                        color: Color(0xffFF0B09),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: CustomWidget().textLight(
                                        AppLocalizations.of(context)
                                                .translate(LanguageKeys.day) +
                                            " > ${data.lockerInfo.freeDays + 3}",
                                        Colors.black,
                                        12,
                                        TextAlign.left),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.only(left: 20),
                    child: CustomWidget().textBold(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.takeTimeRules),
                        Colors.black,
                        14,
                        TextAlign.left),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: CustomWidget().textLight(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.nonPPCnoteOne),
                        Colors.black,
                        12,
                        TextAlign.left),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: CustomWidget().textLight(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.nonPPCnoteTwo),
                        Color(0xffFF0B09),
                        12,
                        TextAlign.left),
                  ),
                ],
              ),
            ),
          );
        }).whenComplete(() => null);
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

  void _checkPayment(ParcelHistoryDetailData parcelHistoryDetailData) async {
    var checkStatusPayment =
        Provider.of<CollectPaymentViewModel>(context, listen: false);
    CheckStatusPaymentPayload checkStatusPaymentPayload =
        new CheckStatusPaymentPayload()
          ..token =
              "iyajJrvejTqHaucPZrtqKXrwDPGcdPoCbMVV56m6AwKOVXb3u75VdFOKGQd9U3FG"
          ..sessionId = SharedPreferencesService().user.sessionId
          // ..sessionId     = sessionId
          ..transactionId = ""
          ..paymentId = ""
          ..idOrderNumber = "" + parcelHistoryDetailData.id
          ..lockerOrderNumber = "";

    print('logy _checkStatusPayment');
    print('logy priceInstore: ' +
        parcelHistoryDetailData.ppcInfo.priceInstore.toString());
    print(
        'logy ppcType: ' + parcelHistoryDetailData.ppcInfo.ppcType.toString());
    print('logy pricePerDay: ' +
        parcelHistoryDetailData.ppcInfo.pricePerDay.toString());
    print('logy priceOverdue: ' +
        parcelHistoryDetailData.ppcInfo.priceOverdue.toString());
    print('logy pricePPC: ' + totalPricePPC.toString());

    //compare
    await checkStatusPayment.compareStatusPayment(
        checkStatusPaymentPayload, context, onSuccess: (response) {
      try {
        dataComparePayment = response.data;
        print('logy _checkStatusPayment response: ' +
            response.data.totalAmount.toString());
        totalAmount = response.data.totalAmount.toString();
        print('logy _checkStatusPayment response totalAmount: ' + totalAmount);
        parcelViewNew(context, parcelHistoryDetailData, dataComparePayment);
      } catch (e) {
        print('logy _checkStatusPayment catch: ' + e.toString());
        parcelViewNew(context, parcelHistoryDetailData, dataComparePayment);
      }
    }, onError: (response) {
      print('logy _checkStatusPayment onError: ' + response.toString());
      parcelViewNew(context, parcelHistoryDetailData, dataComparePayment);
    });
  }

  void _loadDataParcel() async {
    var parcelModel = Provider.of<ParcelViewModel>(context, listen: false);

    ParcelHistoryDetailPayload historyDetailPayload =
        new ParcelHistoryDetailPayload()
          ..sessionId = SharedPreferencesService().user.sessionId
          ..token = GlobalVar.API_TOKEN
          ..orderId = widget.parcelData.id;

    await parcelModel.parcelHistoryDetail(historyDetailPayload, context,
        onSuccess: (response) {
      setState(() {
        parcelHistoryDetailData = response.data.first;

        _checkPayment(parcelHistoryDetailData);
        parcelId = parcelHistoryDetailData.id.toString();
        locationId = parcelHistoryDetailData.lockerId.toString();
      });
    }, onError: (response) {});
  }
}

Widget PaidPaymentParcelView(BuildContext context) {}

void showPopcenterInfo({context}) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setstateBuilder) => Container(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Stack(
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Icon(Icons.close),
                        )),
                    Align(
                      alignment: Alignment.center,
                      child: CustomWidget().textBoldPlus("PopCenter",
                          PopboxColor.mdBlack1000, 16, TextAlign.center),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Divider(color: Colors.grey),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Image.asset(
                    "assets/images/popcenter_info.png",
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomWidget().googleFontRobboto(
                          'PopCenter',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Colors.black,
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 15),
                        CustomWidget().googleFontRobboto(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.isPopcenterDefinition),
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.black,
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        CustomWidget().googleFontRobboto(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.isPopcenterDefinition1),
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.black,
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        CustomWidget().googleFontRobboto(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.isPopcenterDefinition2),
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.black,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).whenComplete(() => null);
}

void showRulesPopcenter({context, dynamic data}) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setstateBuilder) => Container(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Stack(
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Icon(Icons.close),
                        )),
                    Align(
                      alignment: Alignment.center,
                      child: CustomWidget().textBoldPlus(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.rules),
                          PopboxColor.mdBlack1000,
                          16,
                          TextAlign.center),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Divider(color: Colors.grey),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                      color: Color(0xffF5F5F5),
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.only(left: 20, right: 20),
                  padding:
                      EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget().googleFontRobboto(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.takeTimeRules),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.black,
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 10),
                      CustomWidget().googleFontRobboto(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.rulesPopcenter),
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.black,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                //PPC 1 FREE DAY
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  padding: EdgeInsets.only(bottom: 10, top: 10),
                  decoration: BoxDecoration(
                    color: Color(0xffEBF2FD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xff477FFF),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                              width: 30.0.w - 20,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 9, right: 0, top: 15, bottom: 15),
                                    padding: const EdgeInsets.only(
                                        left: 9, right: 9, bottom: 5, top: 5),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: CustomWidget().textLight(
                                        "${data.ppcInfo.freeDays} " +
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys.day),
                                        Color(0xff477FFF),
                                        12,
                                        TextAlign.left),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 20),
                            child: CustomWidget().textBold(
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.free),
                                Color(0xff477FFF),
                                12,
                                TextAlign.left),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DottedBorder(
                            color: Color(0xffFF0200),
                            strokeWidth: 1,
                            child: Container(
                              margin: EdgeInsets.only(right: 0),
                              width: 60.0.w - 20,
                              decoration: BoxDecoration(
                                  color: Color(0xffFFDDDD),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(6),
                                    bottomRight: Radius.circular(6),
                                  )),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 9, right: 9, top: 15, bottom: 15),
                                    padding: const EdgeInsets.only(
                                        left: 9, right: 9, bottom: 5, top: 5),
                                    decoration: BoxDecoration(
                                        color: Color(0xffFF0B09),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: CustomWidget().textLight(
                                        AppLocalizations.of(context)
                                                .translate(LanguageKeys.day) +
                                            " > ${data.ppcInfo.freeDays}",
                                        Colors.white,
                                        12,
                                        TextAlign.left),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 0),
                            child: CustomWidget().textBold(
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.paid),
                                Color(0xffFF0000),
                                12,
                                TextAlign.left),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(left: 20, right: 20),
                    padding: EdgeInsets.only(
                        bottom: 10, top: 10, left: 20, right: 20),
                    decoration: BoxDecoration(
                      color: Color(0xffF5F5F5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomWidget().googleFontRobboto(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.freePeriod)
                              .replaceAll(
                                  "%s", data.ppcInfo.freeDays.toString()),
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xff626262),
                          textAlign: TextAlign.left,
                        ),
                        CustomWidget().googleFontRobboto(
                          AppLocalizations.of(context)
                                  .translate(LanguageKeys.cost) +
                              " @" +
                              "24" +
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.hours) +
                              " Rp.${data.ppcInfo.pricePerDay}",
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xff626262),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        (data.ppcInfo.freeDays != 0)
                            ? CustomWidget().googleFontRobboto(
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.popcenterRulesDesc)
                                    .replaceAll(
                                        "%a", data.ppcInfo.freeDays.toString())
                                    .replaceAll("%b",
                                        (data.ppcInfo.freeDays + 1).toString())
                                    .replaceAll("%c",
                                        data.ppcInfo.pricePerDay.toString()),
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Color(0xff626262),
                                textAlign: TextAlign.left,
                              )
                            : Container(),
                      ],
                    )),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                      color: Color(0xffFFEED3),
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.only(left: 20, right: 20),
                  padding:
                      EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget().googleFontRobboto(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.isPopcenterNote),
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xffD68000),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).whenComplete(() => null);
}

void showRulesWareHouseFreeDay({context, dynamic data}) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setstateBuilder) => Container(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Stack(
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Icon(Icons.close),
                        )),
                    Align(
                      alignment: Alignment.center,
                      child: CustomWidget().textBold(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.rules),
                          PopboxColor.mdBlack1000,
                          16,
                          TextAlign.center),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Divider(color: Colors.grey),
                SizedBox(height: 20),
                //PPC 1 FREE DAY
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 20),
                          child: CustomWidget().textBold(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.free),
                              Color(0xffA4A4A4),
                              12,
                              TextAlign.left),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: DottedBorder(
                            color: Color(0xff477FFF),
                            strokeWidth: 1,
                            child: Container(
                              width: 30.0.w - 20,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 9, right: 0, top: 15, bottom: 15),
                                    padding: const EdgeInsets.only(
                                        left: 9, right: 9, bottom: 5, top: 5),
                                    decoration: BoxDecoration(
                                        color: Color(0xff477FFF),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: CustomWidget().textLight(
                                        "${data.ppcInfo.freeDays} " +
                                            AppLocalizations.of(context)
                                                .translate(LanguageKeys.day),
                                        Colors.white,
                                        12,
                                        TextAlign.left),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 0),
                          child: CustomWidget().textBold(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.paid),
                              Color(0xffA4A4A4),
                              12,
                              TextAlign.left),
                        ),
                        DottedBorder(
                          color: Color(0xffFF0200),
                          strokeWidth: 1,
                          child: Container(
                            margin: EdgeInsets.only(right: 0),
                            width: 70.0.w - 20,
                            decoration: BoxDecoration(
                                color: Color(0xffFFDDDD),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(6),
                                  bottomRight: Radius.circular(6),
                                )),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 9, right: 9, top: 15, bottom: 15),
                                  padding: const EdgeInsets.only(
                                      left: 9, right: 9, bottom: 5, top: 5),
                                  decoration: BoxDecoration(
                                      color: Color(0xffFF0B09),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: CustomWidget().textLight(
                                      AppLocalizations.of(context)
                                              .translate(LanguageKeys.day) +
                                          " > ${data.ppcInfo.freeDays}",
                                      Colors.black,
                                      12,
                                      TextAlign.left),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: CustomWidget().textLight(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.isPPCnoteOne),
                      Colors.black,
                      12,
                      TextAlign.left),
                ),
                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: CustomWidget().textLight(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.isPPCnoteTwo),
                      Color(0xffFF0B09),
                      12,
                      TextAlign.left),
                ),
              ],
            ),
          ),
        );
      }).whenComplete(() => null);
}

String getFormattedDate(String date) {
  String outputDate;
  try {
    DateFormat format = DateFormat("yyyy-MM-dd hh:mm:ss");
    DateTime dateTime = format.parse(date);

    String localeDate = "id_ID";
    if (SharedPreferencesService().locationSelected != 'ID') {
      localeDate = "en_EN";
    }
    DateFormat outputFormat = DateFormat('dd MMMM yyyy hh:mm:dd', localeDate);
    outputDate = outputFormat.format(dateTime);
  } catch (e) {
    outputDate = date;
  }

  return outputDate;
}

String getFormattedDateShort(String date) {
  String outputDate;
  try {
    DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");
    DateTime dateTime = format.parse(date);

    String localeDate = "id_ID";
    if (SharedPreferencesService().locationSelected != 'ID') {
      localeDate = "en_EN";
    }

    DateFormat outputFormat = DateFormat('dd MMM yyyy HH:mm ', localeDate);

    outputDate = outputFormat.format(dateTime);
  } catch (e) {
    outputDate = date;
  }

  return outputDate;
}

_showSuccessInfo(BuildContext context, bool isSuccess, String message) async {
  Navigator.pop(context);
  await Future.delayed(Duration(milliseconds: 50));
  AlertDialog alert = AlertDialog(
    content: Container(
        height: 15.0.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            isSuccess
                ? Icon(
                    Icons.check_circle,
                    color: Color(0xff25BE0C),
                    size: 44,
                  )
                : Icon(
                    Icons.highlight_off,
                    color: Color(0xffFF1010),
                    size: 44,
                  ),
            CustomWidget().textBold(
              AppLocalizations.of(context)
                  .translate(LanguageKeys.caseSuccess)
                  .replaceAll(
                      "%s",
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.popsafeHowToExtend)),
              Colors.black,
              14,
              TextAlign.left,
            ),
            CustomWidget().textRegular(
              message,
              Colors.black,
              11,
              TextAlign.center,
            ),
          ],
        )),
  );
  showDialog(
    context: context,
    useRootNavigator: false,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return alert;
    },
  ).then(
    (value) {
      if (value != null) {
      } else {
        return null;
      }
    },
  );
}

class OriginDestination extends StatelessWidget {
  final String origin;

  const OriginDestination({Key key, this.origin}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomWidget()
            .textBoldProduct(origin, PopboxColor.mdBlack1000, 12.0.sp, 1),
        CustomWidget()
            .textBoldProduct(origin, PopboxColor.mdBlack1000, 12.0.sp, 1),
        CustomWidget()
            .textBoldProduct(origin, PopboxColor.mdBlack1000, 12.0.sp, 1),
      ],
    );
  }
}
