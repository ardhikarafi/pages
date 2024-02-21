import 'dart:io';

import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/contact_us/contact_us_data.dart';
import 'package:new_popbox/core/models/callback/contact_us/contact_us_response.dart';
import 'package:new_popbox/core/models/callback/parcel/parcel_for_you_history_data.dart';
import 'package:new_popbox/core/models/callback/parcel/parcel_history_detail_data.dart';
import 'package:new_popbox/core/models/callback/parcel/unfinish_parcel_data.dart';
import 'package:new_popbox/core/models/callback/popsafe/popsafe_history_detail_data.dart';
import 'package:new_popbox/core/models/payload/contact_us_payload.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/contactus_viewmodel.dart';
import 'package:new_popbox/ui/widget/app_widget.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class FormReportingPage extends StatefulWidget {
  const FormReportingPage(
      {Key key,
      this.parcelData,
      this.unfinishParcelData,
      this.reason,
      this.type,
      this.popsafeHistoryDetailData,
      this.parcelDataDetail})
      : super(key: key);

  final ParcelForYouHistoryData parcelData;
  final ParcelHistoryDetailData parcelDataDetail;
  final UnfinishParcelData unfinishParcelData;
  final PopsafeHistoryDetailData popsafeHistoryDetailData;
  final String reason;
  final String type;

  @override
  _FormReportingPageState createState() => _FormReportingPageState();
}

class _FormReportingPageState extends State<FormReportingPage> {
  String _dropDownValueofCategory = "";
  String _dropDownValueofChannel = "";

  final _categoryController = TextEditingController();
  final _channelController = TextEditingController();
  final _descController = TextEditingController();

  List<String> categories = [];
  List<String> categoriesEN = [
    "Door did not open",
    "Accidentally closed box before collecting/Item left behind",
    "Empty box",
    "Wrong parcel",
    "Signature error",
    "PIN expired",
    "Locker offline"
  ];
  List<String> categoriesID = [
    "Kendala kode ambil",
    "Perpanjangan batas pengambilan paket",
    "Kendala aplikasi",
    "Kendala loker",
    "Kendala paket",
    "Kendala pembayaran",
    "Kendala lainnya"
  ];

  List<String> channelComplain = [];
  String nomorWa = "";
  ContactUsResponse contactUs;
  String name;
  String phone;
  String numberOfTransaction = "";
  String statusOfTransaction = "";
  String locationOfTransaction = "";
  @override
  void initState() {
    if (SharedPreferencesService().languageCode == "id") {
      categories = categoriesID;
    } else {
      categories = categoriesEN;
    }

    var contactUsModel =
        Provider.of<ContactUsViewModel>(context, listen: false);
    name = SharedPreferencesService().user.name.toUpperCase();
    phone = SharedPreferencesService().user.phone;
    contactUs = contactUsModel.contactUsResponse;
    //METHOD
    if (SharedPreferencesService().locationSelected == "ID") {
      channelComplain.add("Email");
    } else if (SharedPreferencesService().locationSelected == "MY") {
      channelComplain.add("Email");
      channelComplain.add("WhatsApp");
    }
    //NUMBER AWB & STATUS
    if (widget.reason == "Unfinish") {
      numberOfTransaction = widget.unfinishParcelData.awb;
      statusOfTransaction = widget.unfinishParcelData.status;
      locationOfTransaction = widget.unfinishParcelData.location;
    } else if (widget.reason == "Parcel") {
      numberOfTransaction = widget.parcelDataDetail.orderNumber;
      statusOfTransaction = widget.parcelDataDetail.status;
      locationOfTransaction = widget.parcelDataDetail.locker;
    } else if (widget.reason == "Popsafe") {
      numberOfTransaction =
          widget.popsafeHistoryDetailData.invoiceCode.toString();
      statusOfTransaction = widget.popsafeHistoryDetailData.status;
      locationOfTransaction = widget.popsafeHistoryDetailData.lockerName;
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        String languageCode = SharedPreferencesService().languageCode;

        if (languageCode == null || languageCode == "") {
          if (SharedPreferencesService().locationSelected == "ID") {
            languageCode = "id";
          } else {
            languageCode = "en";
          }
        }

        if (languageCode == 'my') {
          languageCode = 'en';
        }

        SharedPreferencesService prefs =
            await SharedPreferencesService.instance;
        ContactUsPayload contactUsPayload = new ContactUsPayload(
            country: prefs.locationSelected,
            language: languageCode,
            token: GlobalVar.API_TOKEN);

        contactUsModel.contactUs(
          contactUsPayload,
          context,
          onSuccess: (response) {},
          onError: (response) {},
        );
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactUsViewModel>(builder: (context, model, _) {
      if (model.loading) return Scaffold(body: cartShimmerView(context));

      if (model.contactUsResponse.data == null) {
        return Container();
      }
      ContactUsData contactUs = model.contactUsResponse.data.first;
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: DetailAppBarView(
            title: AppLocalizations.of(context)
                .translate(LanguageKeys.formReportUser),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(left: 16.0, right: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 18.0),
                      //No AWB
                      CustomWidget().textBold(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.receiptNo),
                          PopboxColor.mdGrey600,
                          10.0.sp,
                          TextAlign.left),
                      SizedBox(height: 10.0),
                      CustomWidget().textBold(numberOfTransaction,
                          PopboxColor.mdBlack1000, 10.0.sp, TextAlign.left),
                      //KATEGORI
                      SizedBox(height: 18.0),
                      CustomWidget().textBold(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.category),
                          PopboxColor.mdGrey600,
                          10.0.sp,
                          TextAlign.left),
                      SizedBox(height: 10.0),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: PopboxColor.mdGrey300,
                            width: 1.0,
                          ),
                        ),
                        child: DropdownButton(
                          hint: _dropDownValueofCategory == null
                              ? Text('Select')
                              : Text(
                                  _dropDownValueofCategory,
                                  style:
                                      TextStyle(color: PopboxColor.mdBlack1000),
                                ),
                          isExpanded: true,
                          iconSize: 30.0,
                          underline: SizedBox(),
                          icon: Icon(Icons.arrow_drop_down),
                          style: TextStyle(color: PopboxColor.mdBlack1000),
                          items: categories.map(
                            (val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(val),
                              );
                            },
                          ).toList(),
                          onChanged: (val) {
                            setState(
                              () {
                                _dropDownValueofCategory = val;
                                _categoryController.text = val;
                              },
                            );
                          },
                        ),
                      ),
                      //CHANNEL KOMPLAIN
                      SharedPreferencesService().locationSelected != "ID"
                          ? channelComplainWidget()
                          : Container(),
                      SizedBox(height: 10.0),
                      CustomWidget().textBold(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.descripeYourProblem),
                          PopboxColor.mdGrey600,
                          10.0.sp,
                          TextAlign.left),
                      SizedBox(height: 10.0),
                      Container(
                        height: 28.0.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: PopboxColor.mdGrey300,
                            width: 1.0,
                          ),
                        ),
                        child: TextField(
                          controller: _descController,
                          autocorrect: true,
                          maxLines: 9,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: " Enter a message",
                            fillColor: PopboxColor.mdWhite1000,
                          ),
                          style: TextStyle(
                            color: PopboxColor.mdBlack1000,
                            fontSize: 12.0.sp,
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 50.0)
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16.0, right: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_categoryController.text.isEmpty) {
                          CustomWidget().showCustomDialog(
                              context: context,
                              msg: AppLocalizations.of(context)
                                  .translate(
                                      LanguageKeys.pleaseSelectVaribelFirst)
                                  .replaceAll(
                                      "%1s",
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.category)
                                          .toLowerCase()));
                        } else if (_channelController.text.isEmpty &&
                            SharedPreferencesService().locationSelected ==
                                "MY") {
                          CustomWidget().showCustomDialog(
                              context: context,
                              msg: AppLocalizations.of(context)
                                  .translate(
                                      LanguageKeys.pleaseSelectVaribelFirst)
                                  .replaceAll("%1s", "channel"));
                        } else if (_descController.text.isEmpty) {
                          CustomWidget().showCustomDialog(
                              context: context,
                              msg: AppLocalizations.of(context)
                                  .translate(
                                      LanguageKeys.pleaseSelectVaribelFirst)
                                  .replaceAll(
                                      "%1s",
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.description)
                                          .toLowerCase()));
                        } else {
                          if (_channelController.text == "WhatsApp") {
                            launchWhatsapp(
                                context,
                                contactUs.whatsapp,
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.csTemplateHelp)
                                    .replaceAll("%1s", name)
                                    .replaceAll("%2s", numberOfTransaction)
                                    .replaceAll("%3s", phone)
                                    .replaceAll("%4s", locationOfTransaction)
                                    .replaceAll("%5s", _categoryController.text)
                                    .replaceAll("%6s", _descController.text));
                            _showDialog(context, "whatsapp");
                          } else if (_channelController.text == "Email") {
                            final Uri _emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: contactUs.email,
                              query: Platform.isAndroid
                                  ? 'subject=' +
                                      _categoryController.text +
                                      ' - ' +
                                      numberOfTransaction +
                                      '&'
                                          'body=' +
                                      AppLocalizations.of(context)
                                          .translate(
                                              LanguageKeys.csTemplateHelp)
                                          .replaceAll("%1s", name)
                                          .replaceAll(
                                              "%2s", numberOfTransaction)
                                          .replaceAll("%3s", phone)
                                          .replaceAll(
                                              "%4s", locationOfTransaction)
                                          .replaceAll(
                                              "%5s", _categoryController.text)
                                          .replaceAll(
                                              "%6s", _descController.text)
                                  : 'body=',
                              //queryParameters: {'subject': ''}
                            );
                            launch(_emailLaunchUri.toString());
                            _showDialog(context, 'email');
                          } else if (_channelController.text.isEmpty &&
                              SharedPreferencesService().locationSelected ==
                                  "ID") {
                            final Uri _emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: contactUs.email,
                              query: Platform.isAndroid
                                  ? 'subject=' +
                                      _categoryController.text +
                                      ' - ' +
                                      numberOfTransaction +
                                      '&'
                                          'body=' +
                                      AppLocalizations.of(context)
                                          .translate(
                                              LanguageKeys.csTemplateHelp)
                                          .replaceAll("%1s", name)
                                          .replaceAll(
                                              "%2s", numberOfTransaction)
                                          .replaceAll("%3s", phone)
                                          .replaceAll(
                                              "%4s", locationOfTransaction)
                                          .replaceAll(
                                              "%5s", _categoryController.text)
                                          .replaceAll(
                                              "%6s", _descController.text)
                                  : 'body=',
                              //queryParameters: {'subject': ''}
                            );
                            //todo devrafi
                            launch(_emailLaunchUri.toString());
                            _showDialog(context, 'email');
                          }
                        }
                      },
                      child: CustomButtonRed(
                          onPressed: null,
                          title: AppLocalizations.of(context)
                              .translate(LanguageKeys.send),
                          width: 100.0.w),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  _showDialog(BuildContext context, String type) {
    showDialog(
        context: context,
        builder: (context) {
          return GestureDetector(
              child: AlertDialog(
                  title: Column(
                    children: <Widget>[
                      Container(
                        child: CustomWidget().textBold('INFO',
                            PopboxColor.mdGrey600, 10.0.sp, TextAlign.left),
                      )
                    ],
                  ),
                  content: CustomWidget().textBold(
                    AppLocalizations.of(context)
                            .translate(LanguageKeys.caseSendToCase)
                            .replaceAll(
                                "%1s",
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.inquiry))
                            .replaceAll("%2s", type)[0]
                            .toUpperCase() +
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.caseSendToCase)
                            .replaceAll(
                                "%1s",
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.inquiry))
                            .replaceAll("%2s", type)
                            .substring(1),
                    PopboxColor.mdBlack1000,
                    10.0.sp,
                    TextAlign.center,
                  ),
                  actions: <Widget>[]),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              });
        });
  }

  launchWhatsapp(BuildContext context, String phoneNo, String message) async {
    String url =
        "https://wa.me/" + phoneNo.replaceAll("+", "") + "?text=" + message;

    if (Platform.isIOS) {
      url = "https://wa.me/" + phoneNo.replaceAll("+", "");
    }
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      CustomWidget().showCustomDialog(
        context: context,
        msg: 'Could not launch $url',
      );
    }
  }

  Widget channelComplainWidget() {
    //CHANNEL KOMPLAIN
    return Column(children: [
      SizedBox(height: 18.0),
      Align(
        alignment: Alignment.centerLeft,
        child: CustomWidget().textBold(
            AppLocalizations.of(context)
                .translate(LanguageKeys.channelComplain),
            PopboxColor.mdGrey600,
            10.0.sp,
            TextAlign.left),
      ),
      SizedBox(height: 10.0),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: PopboxColor.mdGrey300,
            width: 1.0,
          ),
        ),
        child: DropdownButton(
          hint: _dropDownValueofChannel == null
              ? Text('Select')
              : Text(
                  _dropDownValueofChannel,
                  style: TextStyle(color: PopboxColor.mdBlack1000),
                ),
          isExpanded: true,
          iconSize: 30.0,
          underline: SizedBox(),
          icon: Icon(Icons.arrow_drop_down),
          style: TextStyle(color: PopboxColor.mdBlack1000),
          items: channelComplain.map(
            (val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val),
              );
            },
          ).toList(),
          onChanged: (val) {
            setState(
              () {
                _dropDownValueofChannel = val;
                _channelController.text = val;
              },
            );
          },
        ),
      )
    ]);
  }
}
