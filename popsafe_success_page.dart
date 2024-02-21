import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/popsafe/popsafe_history_detail_data.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/ui/pages/home.dart';
import 'package:new_popbox/ui/pages/transaction_detail.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:sizer/sizer.dart';

class PopsafePageSuccess extends StatefulWidget {
  final PopsafeHistoryDetailData popsafeHistoryDetailData;

  const PopsafePageSuccess({Key key, @required this.popsafeHistoryDetailData})
      : super(key: key);
  @override
  _PopsafePageSuccessState createState() => _PopsafePageSuccessState();
}

class _PopsafePageSuccessState extends State<PopsafePageSuccess> {
  Future<bool> _willPopCallback() async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
        (Route<dynamic> route) => false);
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SingleChildScrollView(
                child: Container(
                  height: 80.0.h,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Image.asset(
                          'assets/images/ic_popsafesuccess.png',
                          fit: BoxFit.fitWidth,
                          width: 75.0.w,
                          //height: 80.0.h,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 24.0),
                        child: CustomWidget().textBold(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.successfulPayment),
                            PopboxColor.mdBlack1000,
                            15.0.sp,
                            TextAlign.center),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8.0, left: 30, right: 30),
                        child: CustomWidget().textRegular(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.successfulPaymentDetail),
                          PopboxColor.mdBlack1000,
                          11.0.sp,
                          TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          margin: EdgeInsets.only(top: 40),
                          child: CustomWidget().textBoldUnderline(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.backHome),
                            PopboxColor.buttonRedDark,
                            11.0.sp,
                            TextAlign.center,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => Home(),
                              ),
                              (Route<dynamic> route) => false);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                color: PopboxColor.mdGrey350,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => TransactionDetailPage(
                        transactionType: 'popsafe_success',
                        popsafeHistoryDetailData:
                            widget.popsafeHistoryDetailData,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 55,
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  decoration: BoxDecoration(
                    color: PopboxColor.popboxRed,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: CustomWidget().textBold(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.seeTransactionDetail),
                        PopboxColor.mdWhite1000,
                        11.0.sp,
                        null),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
