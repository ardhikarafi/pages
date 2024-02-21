import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:sizer/sizer.dart';

class PasswordConfirmPage extends StatefulWidget {
  final String reason;

  const PasswordConfirmPage({Key key, this.reason}) : super(key: key);

  @override
  _PasswordConfirmPageState createState() => _PasswordConfirmPageState();
}

class _PasswordConfirmPageState extends State<PasswordConfirmPage> {
  bool _passwordVisible;
  bool _passwordVisibleConfirm;

  @override
  void initState() {
    _passwordVisible = false;
    _passwordVisibleConfirm = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: Column(
                children: <Widget>[
                  Column(children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 50.0, 0.0, 0.0),
                          child: CustomWidget().textBold(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.verificationCode),
                            PopboxColor.mdGrey900,
                            16.0.sp,
                            TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16.0, 20.0, 16.0, 0.0),
                            child: CustomWidget().textRegular(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.newPasswordNote),
                              PopboxColor.mdGrey700,
                              11.0.sp,
                              TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 16.0),
                          child: CustomWidget().textRegular(
                            SharedPreferencesService().user.phone,
                            PopboxColor.mdGrey700,
                            11.0.sp,
                            TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ]),
                ],
              ),
            ),
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
                              const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
                          child: CustomWidget().textBold(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.verificationCode),
                            PopboxColor.mdBlack1000,
                            9.0.sp,
                            TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            //TEXTFIELD
            Container(
              color: PopboxColor.mdWhite1000,
              height: 48,
              margin: EdgeInsets.only(left: 20, right: 20, top: 10),
              child: TextField(
                // controller: _notesController,

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
                  fillColor: PopboxColor.popboxGreyPopsafe,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide:
                        BorderSide(color: PopboxColor.mdGrey300, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: PopboxColor.mdGrey300),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                    child: CustomWidget().textRegular(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.inputPasswordConfirm),
                      PopboxColor.mdGrey700,
                      9.0.sp,
                      TextAlign.left,
                    ),
                  ),
                ),
              ],
            ),
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
                              const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
                          child: CustomWidget().textBold(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.newPassword),
                            PopboxColor.mdBlack1000,
                            9.0.sp,
                            TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            //TEXTFIELD
            Container(
              color: PopboxColor.mdWhite1000,
              height: 48,
              margin: EdgeInsets.only(left: 20, right: 20, top: 10),
              child: TextField(
                // controller: _notesController,

                obscureText: !_passwordVisible,
                autocorrect: true,
                cursorColor: PopboxColor.mdGrey700,
                style: TextStyle(
                  color: PopboxColor.mdBlack1000,
                  fontSize: 12.0.sp,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    color: PopboxColor.mdBlack1000,
                  ),
                  hintStyle: TextStyle(color: PopboxColor.mdGrey900),
                  filled: true,
                  fillColor: PopboxColor.popboxGreyPopsafe,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide:
                        BorderSide(color: PopboxColor.mdGrey300, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: PopboxColor.mdGrey300),
                  ),
                ),
              ),
            ),
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
                              const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
                          child: CustomWidget().textBold(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.newPasswordConfirm),
                            PopboxColor.mdBlack1000,
                            9.0.sp,
                            TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            //TEXTFIELD
            Container(
              color: PopboxColor.mdWhite1000,
              height: 48,
              margin: EdgeInsets.only(left: 20, right: 20, top: 10),
              child: TextField(
                // controller: _notesController,
                obscureText: !_passwordVisibleConfirm,
                autocorrect: true,
                cursorColor: PopboxColor.mdGrey700,
                style: TextStyle(
                  color: PopboxColor.mdBlack1000,
                  fontSize: 12.0.sp,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _passwordVisibleConfirm = !_passwordVisibleConfirm;
                      });
                    },
                    icon: Icon(
                      _passwordVisibleConfirm
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    color: PopboxColor.mdBlack1000,
                  ),
                  hintStyle: TextStyle(color: PopboxColor.mdGrey900),
                  filled: true,
                  fillColor: PopboxColor.popboxGreyPopsafe,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide:
                        BorderSide(color: PopboxColor.mdGrey300, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: PopboxColor.mdGrey300),
                  ),
                ),
              ),
            ),

            //Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 0.0),
              child: CustomButtonRed(
                onPressed: () {
                  FocusScope.of(context).unfocus();

                  // String phoneNo = usernameController.text;

                  // loginPayload.phoneNumber =
                  //     SharedPreferencesService().phoneCode + phoneNo;

                  // loginPayload.phoneCode = sharedPrefService.phoneCode;

                  // loginPayload.countryCode = sharedPrefService.countryCode;
                  // reqLocationPermission();

                  // userCheck(context);
                },
                title:
                    AppLocalizations.of(context).translate(LanguageKeys.next),
                width: 90.0.w,
              ),
            ),
            SizedBox(height: 15),
            //Forgot Password
            InkWell(
              onTap: () {
                print("object");
              },
              child: Align(
                alignment: Alignment.center,
                child: CustomWidget().textRegular(
                  AppLocalizations.of(context)
                      .translate(LanguageKeys.forgotPassword),
                  PopboxColor.mdRed300,
                  9.0.sp,
                  TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
