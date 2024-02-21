import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/user/user_login_data.dart';
import 'package:new_popbox/core/models/payload/login_payload.dart';
import 'package:new_popbox/core/models/payload/user_valid_password_payload.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/pages/otp_method_page.dart';
import 'package:new_popbox/ui/pages/pin_page.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class PasswordPage extends StatefulWidget {
  final String reason;
  final LoginPayload loginPayload;

  const PasswordPage({@required this.reason, this.loginPayload});

  @override
  _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  String getPassword;
  final _passwordController = TextEditingController();
  bool _passwordVisible;

  UserLoginData userData;
  SharedPreferencesService prefs;

  @override
  void initState() {
    _passwordVisible = false;
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        16.0, 40.0, 0.0, 16.0),
                                    child: Image.asset(
                                      "assets/images/ic_back_black.png",
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16.0, 20.0, 0.0, 0.0),
                            child: CustomWidget().textBold(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.accountVerification),
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
                                  AppLocalizations.of(context).translate(
                                      LanguageKeys
                                          .pleaseLoginEnjoyPopboxServices),
                                  PopboxColor.mdGrey700,
                                  11.0.sp,
                                  TextAlign.left,
                                ),
                              ),
                            ),
                          ]),
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
                            padding: const EdgeInsets.fromLTRB(
                                16.0, 24.0, 16.0, 10.0),
                            child: CustomWidget().textBold(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.passwordConfirm),
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
                  obscureText: !_passwordVisible,
                  controller: _passwordController,
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
              //Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 0.0),
                child: CustomButtonRed(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    submit(_passwordController.text);
                  },
                  title:
                      AppLocalizations.of(context).translate(LanguageKeys.next),
                  width: 90.0.w,
                ),
              ),
              SizedBox(height: 15),
              //Forgot Password
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => OtpMethodPage(
                        reason: "pre_login_password",
                      ),
                    ),
                  );
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
      ),
    );
  }

  void submit(String inputPassword) {
    var userViewmodel = Provider.of<UserViewModel>(context, listen: false);
    UserValidPasswordPayload userValidPasswordPayload =
        new UserValidPasswordPayload(
            token: GlobalVar.API_TOKEN,
            phone: SharedPreferencesService().user.phone,
            password: inputPassword);

    userViewmodel.userValidPassword(userValidPasswordPayload, context,
        onSuccess: (response) {
      if (response.data.first.isValid == true) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PinPage(
              loginPayload: widget.loginPayload,
              reason: "create_pin",
            ),
          ),
        );
      } else {
        CustomWidget().showCustomDialog(
            context: context,
            msg: AppLocalizations.of(context)
                .translate(LanguageKeys.passwordNotSame));
      }
    }, onError: (response) {
      CustomWidget().showCustomDialog(
          context: context,
          msg: AppLocalizations.of(context)
              .translate(LanguageKeys.passwordNotSame));
    });
  }
}
