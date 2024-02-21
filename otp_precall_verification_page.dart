import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/payload/otp_validation_payload.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/pages/error_network_page.dart';
import 'package:new_popbox/ui/pages/otp_verification_page.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class OtpPrecallVerificationPage extends StatefulWidget {
  final String reason;
  final String platform;

  final String mergePhoneNo;
  final bool showDotsIndicator;
  const OtpPrecallVerificationPage(
      {Key key,
      this.reason,
      this.mergePhoneNo,
      this.showDotsIndicator,
      this.platform})
      : super(key: key);

  @override
  _OtpPrecallVerificationPageState createState() =>
      _OtpPrecallVerificationPageState();
}

class _OtpPrecallVerificationPageState
    extends State<OtpPrecallVerificationPage> {
  bool isOnline = false;
  @override
  Widget build(BuildContext context) {
    hasNetwork().then((result) {
      setState(() {
        isOnline = result;
      });
    });
    return Consumer<UserViewModel>(
      builder: (context, model, _) => Stack(
        children: [
          Scaffold(
            body: SafeArea(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
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
                          widget.showDotsIndicator
                              ? Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 40.0, 16.0, 0.0),
                                  child: Row(
                                    children: [
                                      _buildPageIndicator(true),
                                      _buildPageIndicator(true),
                                      _buildPageIndicator(false),
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 35, left: 20),
                            child: CustomWidget().textRegular(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.preCallVerifTitle)
                                  .replaceAll(
                                      "%phone",
                                      SharedPreferencesService()
                                          .otpRequestPayload
                                          .phone),
                              PopboxColor.mdGrey900,
                              16,
                              TextAlign.left,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20, top: 19),
                            child: CustomWidget().textRegular(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.preCallVerifContent),
                              PopboxColor.mdGrey900,
                              16,
                              TextAlign.left,
                            ),
                          ),
                          SizedBox(height: 57),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16.0, 50.0, 16.0, 4.0),
                            child: Lottie.asset(
                                "assets/lottie/lottie_otp_precall.json",
                                fit: BoxFit.contain),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                //Bottom
                Container(
                  margin:
                      EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
                  child: CustomButtonRectangle(
                    onPressed: () {
                      otpRequest();
                    },
                    title: AppLocalizations.of(context)
                        .translate(LanguageKeys.verification),
                    bgColor: PopboxColor.popboxRed,
                    textColor: PopboxColor.mdWhite1000,
                    fontSize: 14,
                  ),
                ),
              ],
            )),
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
  }

  void otpRequest() {
    final userModel = Provider.of<UserViewModel>(context, listen: false);

    userModel.otpRequest(
      SharedPreferencesService().otpRequestPayload,
      context,
      onSuccess: (response) {
        if (response.response.code == "200") {
          OtpValidationPayload otpValidationPayload =
              new OtpValidationPayload();

          otpValidationPayload.phone =
              SharedPreferencesService().otpRequestPayload.phone;

          otpValidationPayload.email =
              SharedPreferencesService().otpRequestPayload.email;

          SharedPreferencesService()
              .setOtpValidationPayload(otpValidationPayload);

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OtpVerificationPage(
                reason: widget.reason,
                showDotsIndicator: widget.showDotsIndicator,
                platform: widget.platform,
              ),
            ),
          );
        } else {
          try {
            CustomWidget().showCustomDialog(
                context: context, msg: response.response.message);
          } catch (e) {
            CustomWidget()
                .showCustomDialog(context: context, msg: e.toString());
          }
        }
      },
      onError: (response) {
        try {
          (isOnline)
              ? CustomWidget().showCustomDialog(
                  context: context, msg: response.response.message)
              : Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ErrorNetworkPage()));
          setState(() {});
        } catch (e) {
          CustomWidget().showCustomDialog(
            context: context,
            msg: e.toString(),
          );
        }
      },
    );
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

  Widget _buildPageIndicator(bool active) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.0),
      height: active ? 6.5 : 7.0,
      width: active ? 6.5 : 7.0,
      decoration: BoxDecoration(
        border: Border.all(color: PopboxColor.blue477FFF),
        color: active ? PopboxColor.blue477FFF : PopboxColor.mdWhite1000,
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }
}
