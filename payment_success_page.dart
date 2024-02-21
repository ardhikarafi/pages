import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/parcel/parcel_for_you_history_data.dart';
import 'package:new_popbox/core/models/callback/parcel/parcel_history_detail_data.dart';
import 'package:new_popbox/core/models/callback/parcel/unfinish_parcel_data.dart';
import 'package:new_popbox/core/models/callback/payment/check_status_payment_data.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/ui/pages/transaction_detail.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';

import '../../core/models/callback/popsafe/popsafe_history_data.dart';
import '../../core/models/callback/popsafe/popsafe_history_detail_data.dart';
import '../../core/models/payload/popsafe_history_detail_payload.dart';
import '../../core/utils/library.dart';
import '../../core/utils/shared_preference_service.dart';
import '../../core/viewmodel/popsafe_viewmodel.dart';
import 'home.dart';
import 'package:intl/intl.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String transactionType;
  final String invoiceId;
  final PopsafeHistoryData popsafeData;
  final String status;
  final CheckStatusPaymentData statusPayment;
  final ParcelHistoryDetailData parcelHistoryDetailData;
  final String transactionId;
  final UnfinishParcelData unfinishParcelData;
  final ParcelForYouHistoryData parcelData;

  const PaymentSuccessPage(
      {Key key,
      this.transactionType,
      this.invoiceId,
      this.popsafeData,
      this.status,
      this.statusPayment,
      this.parcelHistoryDetailData,
      this.transactionId,
      this.unfinishParcelData,
      this.parcelData})
      : super(key: key);

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  PopsafeHistoryDetailData popsafeDataDetail;
  NumberFormat formatCurrency;
  String parcelId = "";
  String trackNUmber = "";
  String location = "";

  int timeDifference = 0;
  bool isExpandedTransaction = false;
  bool isExpandedTrack = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: DetailAppBarView(
          title: 'Pembayaran Berhasil',
          isCallback: true,
          callback: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => Home(),
                ),
                (Route<dynamic> route) => false);
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () {
          Navigator.of(this.context).push(
            MaterialPageRoute(builder: (context) => Home()),
            // PaymentSuccessPage()),
          );
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Lottie.asset("assets/lottie/lottie_success.json",
                      fit: BoxFit.contain, width: 150, height: 150),
                ),
                SizedBox(height: 70),
                CustomWidget().googleFontRobboto(
                  AppLocalizations.of(context)
                      .translate(LanguageKeys.successPayment)
                      .toUpperCase(),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.black,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: CustomWidget().googleFontRobboto(
                    AppLocalizations.of(context)
                        .translate(LanguageKeys.successPaymentDesc)
                        .toUpperCase(),
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.black,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    print('log> transactionType: ' +
                        widget.transactionType.toString());
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TransactionDetailPage(
                            transactionType: widget.transactionType,
                            popsafeData: widget.popsafeData,
                            status: widget.status,
                            parcelHistoryDetailData:
                                widget.parcelHistoryDetailData,
                            unfinishParcelData: widget.unfinishParcelData,
                            popsafeHistoryDetailData: popsafeDataDetail,
                            parcelData: widget.parcelData),
                      ),
                    );
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
                              .translate(LanguageKeys.seeCodePickup)
                              .toUpperCase(),
                          //'LIHAT KODE AMBIL',
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
}
