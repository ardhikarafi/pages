import 'package:new_popbox/core/utils/library.dart';
import 'package:new_popbox/ui/pages/login_page.dart';
import 'package:new_popbox/ui/pages/register_page.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';

class PreloginPage extends StatelessWidget {
  final String text;

  PreloginPage({this.text}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Container(
          color: PopboxColor.mdWhite1000,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: PopboxColor.mdWhite1000,
            alignment: Alignment.center,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 4.0),
                  child: Image.asset(
                    "assets/images/ic_popbox_logo.png",
                    fit: BoxFit.fitHeight,
                    width: 100.0,
                  ),
                ),
                CustomWidget().textRegular(
                  AppLocalizations.of(context)
                      .translate(LanguageKeys.boxBeyond),
                  PopboxColor.mdGrey600,
                  12.0.sp,
                  TextAlign.center,
                ),
                Image(
                  fit: BoxFit.fitHeight,
                  width: 50.0.w,
                  //height: 200.0,
                  image: AssetImage("assets/images/ic_onboarding5.png"),
                ),
                SizedBox(
                  height: 32.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 32.0,
                    right: 32.0,
                  ),
                  child: CustomWidget().textBold(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.easySafeConvenient),
                      PopboxColor.mdBlack1000,
                      16.0.sp,
                      TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                  child: CustomWidget().textRegular(
                    AppLocalizations.of(context)
                        .translate(LanguageKeys.onboardingContent5),
                    PopboxColor.mdGrey600,
                    11.0.sp,
                    TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 0.0),
                  child: CustomButtonRed(
                    onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => RegisterPage())),
                    title: AppLocalizations.of(context)
                        .translate(LanguageKeys.register),
                    width: 90.0.w,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                  child: CustomButtonWhiteV2(
                    onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginPage())),
                    title: AppLocalizations.of(context)
                        .translate(LanguageKeys.login),
                    width: 90.0.w,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
