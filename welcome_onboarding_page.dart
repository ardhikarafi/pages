import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/ui/pages/otp_method_page.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:sizer/sizer.dart';

class WelcomeOnboardingPage extends StatefulWidget {
  const WelcomeOnboardingPage({Key key}) : super(key: key);

  @override
  _WelcomeOnboardingPageState createState() => _WelcomeOnboardingPageState();
}

class _WelcomeOnboardingPageState extends State<WelcomeOnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  CustomWidget().containerImageWelcomeOnboarding(
                      350, 350, 'assets/images/ic_welcome_onboarding.png'),
                  Container(
                      child: CustomWidget().textBold(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.welcomeOnboarding),
                          PopboxColor.mdBlack1000,
                          22,
                          TextAlign.center)),
                  Container(
                    margin: EdgeInsets.only(top: 15, left: 39, right: 38),
                    child: CustomWidget().textOnboarding(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.welcomeOnboardingDetail),
                      PopboxColor.mdBlack1000,
                      11.0.sp,
                      TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.only(left: 20.0, right: 20.0),
              child: CustomButtonRed(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => OtpMethodPage(
                        reason: "verification",
                      ),
                    ),
                  );
                },
                title:
                    AppLocalizations.of(context).translate(LanguageKeys.next),
                width: 360,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
