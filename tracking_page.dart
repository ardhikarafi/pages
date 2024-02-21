import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/tracking/tracking_data.dart';
import 'package:new_popbox/core/models/payload/tracking_payload.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/viewmodel/tracking_viewmodel.dart';
import 'package:new_popbox/ui/pages/info_page.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:timelines/timelines.dart';

class TrackingPage extends StatefulWidget {
  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  TextEditingController searchController = new TextEditingController();
  bool isSearch = false;
  bool isFound = false;
  String errorMessage = "";
  TrackingData trackingData = new TrackingData();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        // UserLoginData userData = await SharedPreferencesService().getUser();
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: GeneralAppBarView(
          title: AppLocalizations.of(context)
              .translate(LanguageKeys.packageChecking),
          isButtonBack: true,
        ),
      ),
      body: SafeArea(
        child: Container(
          child: trackingDetailInit(),
        ),
      ),
    );
  }

  Widget trackingDetailInit() {
    return ListView(
      children: [
        searchView(),
        trackingDetailFound(),
        trackingDetailNotFound(),
      ],
    );
  }

  void tracking(BuildContext context) async {
    setState(() {
      trackingData = new TrackingData();
      isFound = false;
      errorMessage = "";
    });

    if (searchController.text.toString().trim() == "") {
      return;
    }

    final trackingModel =
        Provider.of<TrackingViewModel>(context, listen: false);

    TrackingPayload trackingPayload = new TrackingPayload(
        token: GlobalVar.API_TOKEN_INTERNAL,
        orderNumber: searchController.text.toString());

    trackingModel.trackingParcelStatus(trackingPayload, context,
        onSuccess: (response) async {
      try {
        if (response.response.code == 200) {
          setState(() {
            isFound = true;
            trackingData = response.data.first;
          });
        } else {
          setState(() {
            isFound = false;
            errorMessage = response.response.message;
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
      }
    }, onError: (response) {
      setState(() {
        errorMessage = response.response.message;
      });
    });
  }

  Widget searchView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 30.0),
          child: CustomWidget().textFormFieldRegular(
            controller: searchController,
            labelText: AppLocalizations.of(context)
                .translate(LanguageKeys.inputReceiptOrderNo),
            suffixIcon: IconButton(
                icon: Icon(Icons.highlight_off, color: Colors.black),
                onPressed: () {
                  searchController.clear();
                  isSearch = false;
                }),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: CustomButtonRectangle(
            bgColor: Color(0xffFF0B09),
            fontSize: 14,
            textColor: Colors.white,
            title: AppLocalizations.of(context).translate(LanguageKeys.submit),
            onPressed: () {
              setState(() {
                isSearch = true;
                isFound = true;
              });
              tracking(context);
            },
          ),
        ),
      ],
    );
  }

  Widget trackingDetailNotFound() {
    if (isFound == false && isSearch && searchController.text.trim() != "") {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 40.0),
          Image.asset("assets/images/ic_tracking_notfound.png"),
          Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
            child: CustomWidget().textBoldPlus(
                errorMessage, PopboxColor.mdBlack1000, 16, TextAlign.center),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              right: 16.0,
              left: 16.0,
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => InfoPage(),
                  ),
                );
              },
              child: RichText(
                textAlign: TextAlign.center,
                softWrap: true,
                text: new TextSpan(
                  style: new TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    new TextSpan(
                        text: AppLocalizations.of(context)
                            .translate(LanguageKeys.makeSureCorrectReceiptNo),
                        style: TextStyle(
                          color: PopboxColor.mdBlack1000,
                          fontSize: 14,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w400,
                        )),
                    new TextSpan(
                      text: " " +
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.callCs),
                      style: TextStyle(
                        color: PopboxColor.mdBlue700,
                        fontSize: 14,
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
      );
    } else {
      return Container();
    }
  }

  Widget trackingDetailExpired() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.asset(
                "assets/images/ic_bg_expired_awb.png",
                width: 100.0.w,
                //height: 120.0,

                fit: BoxFit.fitWidth,
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomWidget().textBold(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.expiredPackage),
                          PopboxColor.mdGrey800,
                          12.0.sp,
                          TextAlign.left),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: CustomWidget().textRegular(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.pleaseMakePayment),
                            PopboxColor.mdGrey700,
                            10.0.sp,
                            TextAlign.left),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: CustomButtonGeneral(
                          onPressed: null,
                          title: AppLocalizations.of(context)
                              .translate(LanguageKeys.pay),
                          bgColor: PopboxColor.popboxRed,
                          textColor: PopboxColor.mdWhite1000,
                          fontSize: 11.0.sp,
                          height: 30.0,
                          borderColor: PopboxColor.popboxRed,
                          width: 100.0,
                          circularRounded: 8.0,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: CustomWidget().textBold(
                AppLocalizations.of(context)
                    .translate(LanguageKeys.packageStatus),
                PopboxColor.mdBlack1000,
                12.0.sp,
                TextAlign.left),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: onlyTextContent(
              context: context,
              title: AppLocalizations.of(context)
                  .translate(LanguageKeys.receiptNo),
              content: "POPSAFE123QRZ",
              isBold: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 16.0,
            ),
            child: Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ),
          onlyTextContent(
            context: context,
            title: AppLocalizations.of(context).translate(LanguageKeys.status),
            content: "Kadaluarsa",
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 16.0,
            ),
            child: Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ),
          onlyTextContent(
            context: context,
            title: AppLocalizations.of(context)
                .translate(LanguageKeys.deliveryTime),
            content: "Sabtu 20/02/2021 19:00:10",
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 16.0,
            ),
            child: Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ),
          onlyTextContent(
            context: context,
            title:
                AppLocalizations.of(context).translate(LanguageKeys.expiryTime),
            content: "Senin 21/02/2021 19:00:11",
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 16.0,
            ),
            child: Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ),
          onlyTextContent(
            context: context,
            title: AppLocalizations.of(context)
                .translate(LanguageKeys.deliveryTipe),
            content: "Regular",
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 16.0,
            ),
            child: Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ),
          onlyTextContent(
            context: context,
            title: AppLocalizations.of(context)
                .translate(LanguageKeys.logisticCourier),
            content: "JNE",
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 16.0,
            ),
            child: Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 30.0),
            child: CustomWidget().textBold(
                AppLocalizations.of(context).translate(LanguageKeys.tracking),
                PopboxColor.mdBlack1000,
                12.0.sp,
                TextAlign.left),
          ),
          trackingTimeline(
              context: context,
              day: "Sabtu",
              date: '20/02/2021',
              time: "12:00",
              content: "Terima Permintaan Pickup",
              showConnector: true,
              dotColor: PopboxColor.popboxRed,
              showDate: true),
          trackingTimeline(
              context: context,
              day: "",
              date: "",
              time: "13:00",
              content: "Paket telah di pickup",
              showConnector: true,
              dotColor: PopboxColor.popboxRed,
              showDate: false),
          trackingTimeline(
              context: context,
              day: "",
              date: "",
              time: "16:00",
              content: "Paket telah di manifest",
              showConnector: true,
              dotColor: PopboxColor.popboxRed,
              showDate: false),
          trackingTimeline(
              context: context,
              day: "Minggu",
              date: '21/02/2021',
              time: "16:00",
              content: "Paket di Drop di loker popbox Apt.Mediterania",
              showConnector: false,
              dotColor: PopboxColor.popboxRed,
              showDate: true),
        ],
      ),
    );
  }

  Widget trackingTimelin() {
    return FixedTimeline.tileBuilder(
      builder: TimelineTileBuilder.connectedFromStyle(
        contentsAlign: ContentsAlign.basic,
        oppositeContentsBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('opposite\ncontents'),
            );
          }
        },
        contentsBuilder: (context, index) => Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Contents'),
          ),
        ),
        connectorStyleBuilder: (context, index) => ConnectorStyle.solidLine,
        indicatorStyleBuilder: (context, index) => IndicatorStyle.dot,
        itemCount: 3,
      ),
    );
  }

  Widget trackingTimeline(
      {Key key,
      @required BuildContext context,
      @required String day,
      @required String date,
      @required String time,
      @required String content,
      @required bool showConnector,
      bool showDate = false,
      @required Color dotColor}) {
    return Row(
      children: [
        SizedBox(
          height: 80.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 25.0.w,
                    //padding: EdgeInsets.only(right: 12.0),
                    child: CustomWidget().textBold(
                      day,
                      showDate == false
                          ? PopboxColor.mdWhite1000
                          : PopboxColor.mdGrey800,
                      10.0.sp,
                      TextAlign.left,
                    ),
                  ),
                  Container(
                    width: 25.0.w,
                    //padding: const EdgeInsets.only(top: 6.0, right: 12.0),
                    child: CustomWidget().textMedium(
                      date,
                      showDate == false
                          ? PopboxColor.mdWhite1000
                          : PopboxColor.mdBlack1000,
                      10.0.sp,
                      TextAlign.left,
                    ),
                  ),
                ],
              ),
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
                padding: EdgeInsets.only(left: 12.0, right: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget().textMedium(
                      time,
                      PopboxColor.mdGrey800,
                      10.0.sp,
                      TextAlign.left,
                    ),
                    Container(
                      width: 50.0.w,
                      padding: const EdgeInsets.only(top: 6.0),
                      child: CustomWidget().textMediumProduct(
                        content,
                        PopboxColor.mdBlack1000,
                        10.0.sp,
                        3,
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

  Widget trackingDetailFound() {
    if (trackingData != null && trackingData.orderNumber != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 30.0),
            child: CustomWidget().textBold(
                AppLocalizations.of(context)
                    .translate(LanguageKeys.packageStatus),
                PopboxColor.mdBlack1000,
                12.0.sp,
                TextAlign.left),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 16, right: 16.0),
            child: onlyTextContent(
                context: context,
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.receiptNo),
                content: trackingData.orderNumber,
                isBold: true),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 16.0, left: 16.0, right: 16.0),
            child: Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16.0,
            ),
            child: onlyStatusContent(
                context: context,
                title:
                    AppLocalizations.of(context).translate(LanguageKeys.status),
                content: AppLocalizations.of(context)
                    .translate(trackingData.status.toLowerCase())),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 16.0, left: 16.0, right: 16.0),
            child: Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16.0),
            child: onlyTextContent(
                context: context,
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.deliveryTime),
                content: trackingData.storetime),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 16.0, left: 16.0, right: 16.0),
            child: Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16.0),
            child: onlyTextContent(
                context: context,
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.takeTime),
                content: trackingData.taketime),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 16.0, left: 16.0, right: 16.0),
            child: Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16.0),
            child: onlyTextContent(
                context: context,
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.expiryTime),
                content: trackingData.overduetime),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 16.0, left: 16.0, right: 16.0),
            child: Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16.0),
            child: onlyTextContent(
                context: context,
                title:
                    AppLocalizations.of(context).translate(LanguageKeys.locker),
                content: trackingData.lockerName),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 16.0, left: 16.0, right: 16.0),
            child: Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget onlyTextContent(
      {BuildContext context,
      String title,
      String content,
      bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.0.w,
          child: CustomWidget().textMedium(
            title,
            PopboxColor.mdGrey700,
            11.0.sp,
            TextAlign.left,
          ),
        ),
        Flexible(
          child: InkWell(
            onTap: () {
              Clipboard.setData(new ClipboardData(text: content));
              CustomWidget().showCustomDialog(
                  context: context, msg: "Copied to Clipboard");
            },
            child: isBold
                ? CustomWidget().textBoldProduct(
                    content,
                    PopboxColor.mdGrey900,
                    11.0.sp,
                    5,
                  )
                : CustomWidget().textRegularProduct(
                    content,
                    PopboxColor.mdGrey900,
                    11.0.sp,
                    5,
                  ),
          ),
        ),
      ],
    );
  }

  Widget onlyStatusContent(
      {BuildContext context, String title, String content}) {
    // READY FOR PICKUP > blue
    // OVERDUE > red
    // CUSTOMER TAKEN > green
    // OPERATOR TAKEN/ COURIER TAKEN > yellow
    // CANCEL/ CANCELLED > grey

    // IN_STORE: Ready for pickup > blue
    // OVERDUE: Overdue > red
    // CUSTOMER_TAKEN: Already taken by customer > green
    // COURIER_TAKEN: Already taken by courier > yellow
    // OPERATOR_TAKEN: Already taken by PopBox Admin > yellow
    // CANCEL/ CANCELLED: Cancel by courier > grey

    Color btnBackgroundColor = PopboxColor.mdBlue700;
    if (content == "IN_STORE") {
      btnBackgroundColor = PopboxColor.mdBlue700;
    } else if (content == "OVERDUE") {
      btnBackgroundColor = PopboxColor.mdRed700;
    } else if (content == "CUSTOMER_TAKEN") {
      btnBackgroundColor = PopboxColor.mdGreenA700;
    } else if (content == "COURIER_TAKEN") {
      btnBackgroundColor = PopboxColor.mdOrange700;
    } else if (content == "OPERATOR_TAKEN") {
      btnBackgroundColor = PopboxColor.mdOrange700;
    } else if (content == "CANCEL" || content == "CANCELLED") {
      btnBackgroundColor = PopboxColor.mdGrey700;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.0.w,
          child: CustomWidget().textMedium(
            title,
            PopboxColor.mdGrey700,
            11.0.sp,
            TextAlign.left,
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 8.0,
            right: 8.0,
            top: 8.0,
            bottom: 8.0,
          ),
          alignment: Alignment.center,
          //height: 30.0,
          width: 180.0,
          decoration: BoxDecoration(
            color: btnBackgroundColor,
            border: Border.all(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(4),
            ),
          ),
          child: CustomWidget().textRegular(
            content,
            PopboxColor.mdWhite1000,
            10.0.sp,
            TextAlign.center,
          ),
        ),
      ],
    );
  }
}
