import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/parcel/parcel_for_you_history_data.dart';
import 'package:new_popbox/core/models/callback/parcel/parcel_history_detail_data.dart';
import 'package:new_popbox/core/models/callback/parcel/unfinish_parcel_data.dart';
import 'package:new_popbox/core/models/payload/create_payment_payload.dart';
import 'package:new_popbox/core/utils/library.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/ui/pages/payment_success_page.dart';
import 'package:new_popbox/ui/pages/midtrans_snap.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:new_popbox/ui/widget/method_payment_item.dart';

import '../../core/models/callback/payment/collect_payment_data.dart';
import '../../core/models/callback/payment/collect_payment_response.dart';
import '../../core/models/callback/popsafe/popsafe_history_data.dart';
import '../../core/utils/shared_preference_service.dart';
import '../../core/viewmodel/collect_payment_viewmodel.dart';

class MethodPaymentPage extends StatefulWidget {
  final double amount;
  final int idTransaction;
  final String username;
  final String phone;
  final String transactionType;
  final String parcelId;
  final String location;
  final String trackerNumber;
  final String invoiceId;
  final PopsafeHistoryData popsafeData;
  final String idParcel;
  final ParcelHistoryDetailData parcelHistoryDetailData;
  final double totalPrice;
  final UnfinishParcelData unfinishParcelData;
  final String locationId;
  final ParcelForYouHistoryData parcelData;

  const MethodPaymentPage(
      {Key key,
      this.amount,
      this.idTransaction,
      this.username,
      this.phone,
      this.transactionType,
      this.parcelId,
      this.location,
      this.trackerNumber,
      this.invoiceId,
      this.popsafeData,
      this.idParcel,
      this.parcelHistoryDetailData,
      this.totalPrice,
      this.unfinishParcelData,
      this.locationId,
      this.parcelData})
      : super(key: key);

  @override
  State<MethodPaymentPage> createState() => _MethodPaymentPageState();
}

class _MethodPaymentPageState extends State<MethodPaymentPage> {
  CollectPaymentResponse collectPaymentResponse;
  int checkedIndex = -1;
  List<String> methodPayment;
  //List<MethodPaymentItem> paymentItems = [];
  List<String> eMoneyList;
  String totalCost = "";
  String resultUrl = "";
  String transactionId = "";
  String eWallet = "gopay";
  CollectPaymentData collectPaymentData;

  @override
  void initState() {
    super.initState();

    methodPayment = [
      "assets/images/ic_gopay_pay.png",
      //"assets/images/ic_gopay_pay.png"
    ];

    eMoneyList = [
      "gopay",
      //"ovo"
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transactionType == "parcel" ||
        widget.transactionType == "lastmile") {
      totalCost = widget.totalPrice.toString();
    } else if (widget.transactionType == "popsafe") {
      totalCost = widget.amount.toString();
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: DetailAppBarView(
          title: AppLocalizations.of(context)
              .translate(LanguageKeys.transactionDetail),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(bottom: 20, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: CustomWidget().googleFontRobboto(
                'Pilih metode Pembayaran',
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Colors.black,
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: CustomWidget().googleFontRobboto(
                'Silakan pilih metode pembayaran untuk melanjutkan proses',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Colors.black,
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: methodPayment.length,
                itemBuilder: (context, index) {
                  bool checked = index == checkedIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          eWallet = eMoneyList[index];
                          print('loggy> select wallet: ' + eWallet.toString());
                          checkedIndex = index;
                        });
                      },
                      child: MethodPaymentItem(
                        asset: methodPayment[index],
                        checked: true,
                      ),
                    ),
                  );
                },
              ),
            ),
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
                  decoration: BoxDecoration(color: Color(0xffFBFBFB)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     CustomWidget().googleFontRobboto(
                      //       AppLocalizations.of(context)
                      //           .translate(LanguageKeys.packageCollectionFee),
                      //       fontWeight: FontWeight.w400,
                      //       fontSize: 14,
                      //       color: Colors.black,
                      //       textAlign: TextAlign.left,
                      //     ),
                      //     CustomWidget().googleFontRobboto(
                      //       'Rp. 1',
                      //       fontWeight: FontWeight.w400,
                      //       fontSize: 14,
                      //       color: Colors.black,
                      //       textAlign: TextAlign.left,
                      //     ),
                      //   ],
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     CustomWidget().googleFontRobboto(
                      //       AppLocalizations.of(context)
                      //           .translate(LanguageKeys.sanksiLateOneDay),
                      //       fontWeight: FontWeight.w400,
                      //       fontSize: 14,
                      //       color: Colors.black,
                      //       textAlign: TextAlign.left,
                      //     ),
                      //     CustomWidget().googleFontRobboto(
                      //       'Rp. 1',
                      //       fontWeight: FontWeight.w400,
                      //       fontSize: 14,
                      //       color: Colors.black,
                      //       textAlign: TextAlign.left,
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      EdgeInsets.only(top: 20, bottom: 20, right: 20, left: 20),
                  decoration: BoxDecoration(color: Color(0xffEDEAEA)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomWidget().googleFontRobboto(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.costTotal),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.black,
                        textAlign: TextAlign.left,
                      ),
                      CustomWidget().googleFontRobboto(
                        'Rp ' + totalCost,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.black,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () async {
                    if (eWallet != null || eWallet != "") {
                      onLoading();
                      _createPayment();
                      print('logy> create payment');
                      //
                    } else {
                      print('logy> pilih ewallet dulu');
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: 15, bottom: 15),
                    color: Colors.white,
                    child: Container(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Color(0xffFF0B09),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: CustomWidget().googleFontRobboto(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.payNow)
                              .toUpperCase(),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.white,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

//onLoading
  void onLoading() {
    showDialog(
        context: this.context,
        builder: (BuildContext context) {
          return Center(
            child: SizedBox(
                height: 50, width: 50, child: CircularProgressIndicator()),
          );
        });
  }

  void _createPayment() async {
    var collectPayment =
        Provider.of<CollectPaymentViewModel>(this.context, listen: false);

    CreatePaymentPayload createPaymentPayload = new CreatePaymentPayload()
      ..token = GlobalVar.API_TOKEN
      //..token            = "A2NABAC6DCLODZDBZXEUCSP5EDTOB0HLYHB1BB3VLGD4A4WM3L"
      ..sessionId = SharedPreferencesService().user.sessionId
      ..trackingNumber = widget.parcelHistoryDetailData.orderNumber
      ..transactionType = widget.parcelHistoryDetailData.type
      ..parcelId = widget.parcelId
      ..locationId = widget.locationId
      ..location = widget.parcelHistoryDetailData.locker
      ..amount = widget.totalPrice
      ..paymentMethod = "MID-SNAP";

    await collectPayment.getCollectPayment(
      createPaymentPayload,
      this.context,
      onSuccess: (response) {
        setState(() {
          try {
            collectPaymentData = response.data.first;
            if (collectPaymentData != null) {
              resultUrl = response.data.first.url;
              transactionId = response.data.first.paymentId;
              print('logy> payload createPayment1: ' + transactionId);
              if (widget.transactionType == "parcel") {
                Navigator.of(this.context).push(
                  MaterialPageRoute(
                      builder: (context) => MidtransSnap(
                          url: resultUrl,
                          transactionType: widget.transactionType,
                          parcelHistoryDetailData:
                              widget.parcelHistoryDetailData,
                          //collectPaymentData: collectPaymentData,
                          //totalPaid: widget.totalPrice,
                          transactionId: transactionId,
                          unfinishParcelData: widget.unfinishParcelData,
                          parcelData: widget.parcelData)),
                  // PaymentSuccessPage()),
                );
              }
              // else if (widget.transactionType == "popsafe") {
              //   Navigator.of(this.context).push(
              //     MaterialPageRoute(
              //         builder: (context) => MidtransSnap(
              //             url: resultUrl,
              //             transactionNumber: response.data[0].transactionNumber,
              //             transactionType: widget.transactionType,
              //             invoiceId: widget.invoiceId,
              //             popsafeData: widget.popsafeData,
              //             methodPayment: eWallet)),
              //     // PaymentSuccessPage()),
              //   );
              // }
            }
          } catch (e) {
            print('logy> exception: ' + e.toString());
          }
        });
      },
      onError: (response) {
        print('logy> response: ');
      },
    );
  }
}
