import 'dart:io';

import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/otp_counter.dart';
import 'package:new_popbox/core/models/otp_method.dart';
import 'package:new_popbox/core/models/payload/otp_request_payload.dart';
import 'package:new_popbox/core/models/payload/otp_validation_payload.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/utils/static_data.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/pages/error_network_page.dart';
import 'package:new_popbox/ui/pages/otp_precall_verification_page.dart';
import 'package:new_popbox/ui/pages/otp_verification_page.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:new_popbox/ui/widget/help_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class OtpMethodPage extends StatefulWidget {
  final String reason;
  final String mergePhoneNo;
  final bool showDotsIndicator;
  final bool isCitcall;

  const OtpMethodPage(
      {Key key,
      @required this.reason,
      this.mergePhoneNo = "",
      this.showDotsIndicator = true,
      this.isCitcall = true})
      : super(key: key);
  @override
  _OtpMethodPageState createState() => _OtpMethodPageState();
}

class _OtpMethodPageState extends State<OtpMethodPage>
    with WidgetsBindingObserver {
  SharedPreferencesService sharedPrefService;

  OtpRequestPayload otpRequestPayload =
      SharedPreferencesService().otpRequestPayload;
  bool isOnline = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      sharedPrefService = await SharedPreferencesService.instance;
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        checkedIndex = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    hasNetwork().then((result) {
      setState(() {
        isOnline = result;
      });
    });
    return Consumer<UserViewModel>(
      builder: (context, model, _) {
        return Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                child: Column(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16.0, 40.0, 0.0, 0.0),
                            child: Image.asset(
                              "assets/images/ic_back_black.png",
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 40.0, 16.0, 0.0),
                            child: (widget.reason == "forgot_pin" ||
                                    widget.reason == "register")
                                ? Row(
                                    children: [
                                      _buildPageIndicator(true),
                                      _buildPageIndicator(false),
                                      _buildPageIndicator(false),
                                    ],
                                  )
                                : Container(),
                          )
                        ],
                      ),
                    ),
                    StaticData().getOtpMethods(
                                    context: context,
                                    selectedLocation: SharedPreferencesService()
                                        .locationSelected) ==
                                null ||
                            StaticData()
                                    .getOtpMethods(
                                        context: context,
                                        selectedLocation:
                                            SharedPreferencesService()
                                                .locationSelected)
                                    .length ==
                                0
                        ? HelpView()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16.0, 28.0, 16.0, 6.0),
                                  child: CustomWidget().textBold(
                                    AppLocalizations.of(context)
                                        .translate(
                                            LanguageKeys.verificationWillSendTo)
                                        .replaceAll(
                                            "%1s",
                                            SharedPreferencesService()
                                                .otpRequestPayload
                                                .phone),
                                    PopboxColor.mdGrey900,
                                    16,
                                    TextAlign.left,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    StaticData()
                                .getOtpMethods(
                                    context: context,
                                    selectedLocation: SharedPreferencesService()
                                        .locationSelected)
                                .length ==
                            0
                        ? Container()
                        : Expanded(
                            child: ListView.builder(
                              itemCount: StaticData()
                                  .getOtpMethods(
                                      context: context,
                                      selectedLocation:
                                          SharedPreferencesService()
                                              .locationSelected,
                                      isCitcall: widget.isCitcall)
                                  .length,
                              // ignore: missing_return
                              itemBuilder: (BuildContext context, int index) {
                                OtpMethod otpMethod = StaticData()
                                    .getOtpMethods(
                                        context: context,
                                        selectedLocation:
                                            SharedPreferencesService()
                                                .locationSelected,
                                        isCitcall: widget.isCitcall)[index];
                                String phoneNo;
                                try {
                                  phoneNo = SharedPreferencesService()
                                      .otpRequestPayload
                                      .phone;
                                } catch (e) {
                                  phoneNo =
                                      SharedPreferencesService().user.phone;
                                }

                                if (phoneNo.startsWith("0")) {
                                  phoneNo =
                                      phoneNo.replaceFirst(RegExp("0"), "");
                                }

                                if (phoneNo.startsWith("62")) {
                                  phoneNo =
                                      phoneNo.replaceFirst(RegExp("62"), "");
                                }

                                if (phoneNo.startsWith("60")) {
                                  phoneNo =
                                      phoneNo.replaceFirst(RegExp("60"), "");
                                }

                                if (phoneNo.startsWith("63")) {
                                  phoneNo =
                                      phoneNo.replaceFirst(RegExp("63"), "");
                                }

                                return otpMethodItem(
                                    index,
                                    otpMethod,
                                    SharedPreferencesService().phoneCode +
                                        phoneNo,
                                    isCitcall: widget.isCitcall);
                              },
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

  int checkedIndex = -1;
  Widget otpMethodItem(int index, OtpMethod otpMethod, String phone,
      {bool isCitcall = false}) {
    bool checked = index == checkedIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          checkedIndex = index;

          otpRequestPayload.token = GlobalVar.API_TOKEN_INTERNAL;

          if (widget.reason == "register") {
            otpRequestPayload.email = sharedPrefService.registerPayload.email;
          } else if (widget.reason == "forgot_pin") {
          } else if (widget.reason == "verification") {
          } else if (widget.reason == "pre_login_password") {}

          otpRequestPayload.platform = otpMethod.method;
          otpRequestPayload.requestFrom = "mobile";
          sharedPrefService.setOtpRequestPayload(otpRequestPayload);
          if (isCitcall &&
              SharedPreferencesService().locationSelected == "ID") {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OtpPrecallVerificationPage(
                  reason: widget.reason,
                  showDotsIndicator: widget.showDotsIndicator,
                  platform: otpRequestPayload.platform,
                ),
              ),
            );
          } else {
            //MAIN FUNCTION
            otpRequest(otpRequestPayload.platform);
          }
        });
      },
      child: Container(
        height: 80,
        margin: EdgeInsets.only(top: 25.0, left: 16.0, right: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                          child: Image.asset(
                            otpMethod.icon,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomWidget().textBold(
                                otpMethod.title,
                                PopboxColor.mdBlack1000,
                                14,
                                TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                checked
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check,
                                    color: Colors.white, size: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
          ],
        ),
        decoration: BoxDecoration(
          border: Border.all(color: PopboxColor.mdGrey350),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void otpRequest(String platform) {
    final userModel = Provider.of<UserViewModel>(context, listen: false);

    //print(json.encode(SharedPreferencesService().otpRequestPayload));
    //print("BASE_URL_INTERNAL : " + GlobalVar.BASE_URL_INTERNAL);

    userModel.otpRequest(
      SharedPreferencesService().otpRequestPayload,
      context,
      onSuccess: (response) {
        if (response.response.code == "200") {
          OtpCounter otpCounter = SharedPreferencesService().otpCounter;
          checkedIndex = -1;
          //print(json.encode(otpCounter));

          if (SharedPreferencesService().otpRequestPayload.platform ==
              "whatsapp") {
            otpCounter.wa = otpCounter.wa + 1;
          } else if (SharedPreferencesService().otpRequestPayload.platform ==
              "sms") {
            otpCounter.sms = otpCounter.sms + 1;
          } else if (SharedPreferencesService().otpRequestPayload.platform ==
              "call") {
            otpCounter.call = otpCounter.call + 1;
          }
          SharedPreferencesService().setOtCounter(otpCounter);

          OtpValidationPayload otpValidationPayload =
              new OtpValidationPayload();

          otpValidationPayload.phone =
              SharedPreferencesService().otpRequestPayload.phone;

          otpValidationPayload.email =
              SharedPreferencesService().otpRequestPayload.email;

          SharedPreferencesService()
              .setOtpValidationPayload(otpValidationPayload);

          //CustomWidget().showCustomDialog(
          //context: context, msg: response.response.message);

          if (widget.reason == "add_phone" ||
              widget.reason == "case2" ||
              widget.reason == "case3" ||
              widget.reason == "case6") {
            //print("aaaaaaa");
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => OtpVerificationPage(
                  reason: widget.reason,
                  platform: platform,
                  showDotsIndicator: widget.showDotsIndicator,
                  mergePhoneNo: widget.mergePhoneNo,
                ),
              ),
            );
          } else if (SharedPreferencesService().otpRequestPayload.platform ==
              "call") {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OtpPrecallVerificationPage(
                  reason: widget.reason,
                  showDotsIndicator: widget.showDotsIndicator,
                  platform: platform,
                ),
              ),
            );
          } else {
            //print("bbbbbb");
            //SharedPreferencesService().removeValues(keyword: "userData");
            //devrafi

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OtpVerificationPage(
                  reason: widget.reason,
                  showDotsIndicator: widget.showDotsIndicator,
                  platform: platform,
                ),
              ),
            );
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => OtpVerificationPage(
            //       reason: widget.reason,
            //       showDotsIndicator: widget.showDotsIndicator,
            //       platform: platform,
            //     ),
            //   ),
            // );
          }
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
