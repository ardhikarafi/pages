import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/payload/change_profile_payload.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/email_verification_viewmodel.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:new_popbox/core/models/payload/email_verification_payload.dart';
import 'package:provider/provider.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';

import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:new_popbox/core/utils/library.dart';

import 'account_info_page.dart';

class AccountEmailverificationPage extends StatefulWidget {
  final bool isVerifiedEmail;
  final String emailAddress;
  const AccountEmailverificationPage(
      {Key key, @required this.isVerifiedEmail, @required this.emailAddress})
      : super(key: key);

  @override
  State<AccountEmailverificationPage> createState() =>
      _AccountEmailverificationPageState();
}

class _AccountEmailverificationPageState
    extends State<AccountEmailverificationPage> {
  TextEditingController _emailController;
  EmailVerificationPayload emailVerificationPayload =
      new EmailVerificationPayload();

  bool isVerification = false;
  int citCallMax = 0;

  Timer _timer;
  int countdownTimer = 120;

  String header = "";

  @override
  void dispose() {
    try {
      _timer.cancel();
    } catch (e) {}

    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    _emailController = new TextEditingController(text: widget.emailAddress);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: GeneralAppBarView(
            title: widget.isVerifiedEmail == true
                ? AppLocalizations.of(context)
                    .translate(LanguageKeys.changeEmail)
                    .replaceAll(
                        "%s",
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.changeEmail))
                : AppLocalizations.of(this.context)
                    .translate(LanguageKeys.caseVerification)
                    .replaceAll(
                        "%s",
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.email)),
            isButtonBack: true,
          ),
        ),
        body:
            Consumer<EmailVerificationViewModel>(builder: (context, model, _) {
          return Stack(
            children: [
              Scaffold(
                body: SafeArea(
                    child: Column(
                  children: [
                    !isVerification
                        ? pageSubmitVerification(context, _emailController)
                        : pageSubmitVerificationSent(context, _emailController),
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
          );
        }));
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (countdownTimer == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            countdownTimer--;
          });
        }
      },
    );
  }

  Widget pageSubmitVerification(
      BuildContext context, TextEditingController _emailController) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 30.0),
          child: CustomWidget().textFormFieldRegular(
            controller: _emailController,
            labelText: 'Email',
            //hint: SharedPreferencesService().user.email,
            readOnly: false,
          ),
        ),
        _button(context, _emailController)
      ],
    );
  }

  Widget pageSubmitVerificationSent(
      BuildContext context, TextEditingController _emailController) {
    //startTimer();
    return Padding(
        padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 30.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                //alignment: Alignment.center,
                //width: 100.0.w,
                padding: const EdgeInsets.only(
                    left: 7, right: 7, top: 24, bottom: 24),
                decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(0.10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 5, right: 10, top: 5, bottom: 5),
                      child: CustomWidget().textMedium(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.verifyEmailDesc),
                        PopboxColor.mdBlack1000,
                        11,
                        TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 5.0,
                height: 25.0,
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget().textLight(
                      "Email",
                      PopboxColor.mdGrey700,
                      12,
                      TextAlign.left,
                    ),
                    SizedBox(
                      width: 10,
                      height: 15,
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                  child: CustomWidget().textBold(
                                _emailController.text,
                                PopboxColor.mdBlack1000,
                                14,
                                TextAlign.left,
                              )),
                              flex: 8,
                            ),
                            Expanded(
                              child: Container(
                                  child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          isVerification = false;
                                        });
                                      },
                                      child: CustomWidget().textMedium(
                                        AppLocalizations.of(context)
                                            .translate(LanguageKeys.change),
                                        PopboxColor.blue79ACF9,
                                        11,
                                        TextAlign.left,
                                      )),
                                  alignment: Alignment.centerRight),
                              flex: 2,
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 7),
                    Divider(color: Colors.black),
                    SizedBox(height: 7),
                    Row(
                      children: [
                        countdownTimer == 0 && (citCallMax <= 2)
                            ? InkWell(
                                onTap: () {
                                  if (countdownTimer == 0 && (citCallMax < 2)) {
                                    doVerificationEmail(
                                        context, _emailController.text);
                                    citCallMax += 1;
                                  } else if (countdownTimer == 0 &&
                                      (citCallMax == 2)) {
                                    CustomWidget().showToastShortV1(
                                      context: context,
                                      msg: AppLocalizations.of(context)
                                          .translate(LanguageKeys
                                              .limitResendEmailVerification),
                                    );
                                  }
                                },
                                child: RichText(
                                  textAlign: TextAlign.left,
                                  softWrap: true,
                                  text: new TextSpan(
                                    text: AppLocalizations.of(context)
                                            .translate(LanguageKeys
                                                .notReceivedEmailVerificationSendIn) +
                                        " ",
                                    style: new TextStyle(
                                      fontSize: 9.0.sp,
                                      fontWeight: FontWeight.w400,
                                      color: PopboxColor.mdGrey700,
                                      fontFamily: "Montserrat",
                                    ),
                                    children: <TextSpan>[
                                      new TextSpan(
                                          text: AppLocalizations.of(context)
                                              .translate(LanguageKeys.resend),
                                          style: TextStyle(
                                            color: PopboxColor.blue477FFF,
                                            fontSize: 9.0.sp,
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight.w500,
                                            decoration:
                                                TextDecoration.underline,
                                          )),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                //width: 100.0.w,
                                child: RichText(
                                  textAlign: TextAlign.left,
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                  text: new TextSpan(
                                    text: AppLocalizations.of(context)
                                            .translate(LanguageKeys
                                                .notReceivedEmailVerificationSendIn) +
                                        " ",
                                    style: new TextStyle(
                                      fontSize: 9.0.sp,
                                      color: PopboxColor.mdGrey700,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Montserrat",
                                    ),
                                    children: <TextSpan>[
                                      new TextSpan(
                                          text: countdownTimer.toString(),
                                          style: TextStyle(
                                            color: PopboxColor.blue477FFF,
                                            fontSize: 10.0.sp,
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight.w500,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              )
            ]));
  }

  Widget _button(BuildContext context, TextEditingController emailController) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: CustomButtonRectangle(
        bgColor: Color(0xffFF0B09),
        fontSize: 14,
        textColor: Colors.white,
        title: widget.isVerifiedEmail == true
            ? AppLocalizations.of(context).translate(LanguageKeys.change)
            : AppLocalizations.of(context).translate(LanguageKeys.verification),
        onPressed: () {
          //_emailController.text = SharedPreferencesService().user.email;
          if (emailController.text.isEmpty) {
            CustomWidget().showToastShortV1(
                context: context,
                msg: AppLocalizations.of(context)
                    .translate(LanguageKeys.emailIsRequired));
          } else {
            widget.isVerifiedEmail == true
                ? doChangeEmail(context, emailController.text)
                : doVerificationEmail(context, emailController.text);
          }
        },
      ),
    );
  }

  void doVerificationEmail(BuildContext context, String text) async {
    final emailVerificationModel =
        Provider.of<EmailVerificationViewModel>(context, listen: false);

    EmailVerificationPayload emailVerificationPayload =
        new EmailVerificationPayload(
            token: GlobalVar.API_TOKEN,
            sessionId: SharedPreferencesService().user.sessionId,
            userId: SharedPreferencesService().user.userId.toString(),
            email: text);
    emailVerificationModel.emailVerificationViewModel(
        emailVerificationPayload, context, onSuccess: (response) {
      SharedPreferencesService().user.email = text;
      //print("doVerificationEmail | success");
      setState(() {
        isVerification = true;
        countdownTimer = 120;

        //_emailController = _emailController.text as TextEditingController;
      });
      startTimer();
    }, onError: (response) {
      CustomWidget().showToastShortV1(
        context: context,
        msg: AppLocalizations.of(context)
            .translate(LanguageKeys.errorEmailVerification),
      );
      // print("doVerificationEmail | err " + response.response.message);
    });
  }

  doChangeEmail(BuildContext context, String text) {
    bool emailValid =
        RegExp(r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$')
            .hasMatch(text);
    if (!emailValid) {
      CustomWidget().showCustomDialog(
        context: context,
        msg: AppLocalizations.of(context).translate(
          LanguageKeys.emailFormatIsRequired,
        ),
      );
    } else {
      FocusScope.of(context).unfocus();
      ChangeProfilePayload profilePayload = new ChangeProfilePayload()
        ..token = GlobalVar.API_TOKEN
        ..memberId = SharedPreferencesService().user.memberId
        ..sessionId = SharedPreferencesService().user.sessionId;
      profilePayload.email = text.trim();

      final userModel = Provider.of<UserViewModel>(context, listen: false);
      userModel.changeProfile(
        profilePayload,
        context,
        onSuccess: (response) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AccountInfoPage(),
            ),
          );
        },
        onError: (response) {
          try {
            if (response.response.message == "validation.unique_email") {
              CustomWidget().showCustomDialog(
                  context: context,
                  msg: AppLocalizations.of(context)
                      .translate(LanguageKeys.caseAlreadyRegisterd)
                      .replaceAll("%1s", "Email"));
            } else {
              CustomWidget().showCustomDialog(
                  context: context, msg: response.response.message);
            }
          } catch (e) {
            CustomWidget().showCustomDialog(
                context: context, msg: "catch : : " + e.toString());
          }
        },
      );
    }
  }
}
