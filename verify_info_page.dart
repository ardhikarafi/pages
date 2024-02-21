import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/ui/pages/register_id_page.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:sizer/sizer.dart';

class VerifyInfoPage extends StatefulWidget {
  final String from;
  const VerifyInfoPage({Key key, @required this.from}) : super(key: key);
  @override
  _VerifyInfoPageState createState() => _VerifyInfoPageState();
}

class _VerifyInfoPageState extends State<VerifyInfoPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {},
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //do your stuff
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: DetailAppBarView(
          title: AppLocalizations.of(context)
              .translate(LanguageKeys.verifyAccount),
        ),
      ),
      body: SafeArea(child: content(widget.from)),
    );
  }

  Widget content(String from) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              SizedBox(
                height: 50.0,
              ),
              Image.asset(
                from == "verify"
                    ? "assets/images/ic_verify_info.png"
                    : "assets/images/ic_rejected_info.png",
                width: 100.0,
                height: 160.0,
                fit: BoxFit.fitHeight,
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 40.0,
                  right: 40.0,
                ),
                child: CustomWidget().textBold(
                  from == "verify"
                      ? AppLocalizations.of(context)
                          .translate(LanguageKeys.weNeedVerifyYourAccount)
                      : AppLocalizations.of(context)
                          .translate(LanguageKeys.rejectedReason),
                  PopboxColor.mdGrey900,
                  12.0.sp,
                  TextAlign.center,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
                child: CustomWidget().textRegular(
                  from == "verify"
                      ? AppLocalizations.of(context)
                          .translate(LanguageKeys.verifyAccountReasons)
                      : AppLocalizations.of(context)
                          .translate(LanguageKeys.rejectedReasonInfo),
                  PopboxColor.mdGrey700,
                  11.0.sp,
                  TextAlign.left,
                ),
              ),
              from == "verify"
                  ? Container(
                      margin:
                          EdgeInsets.only(left: 16.0, right: 16.0, top: 80.0),
                      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      child: CustomWidget().textRegular(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.verifyAccountInformation),
                        PopboxColor.mdGrey700,
                        11.0.sp,
                        TextAlign.left,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: PopboxColor.mdYellow100),
                        color: PopboxColor.mdYellow100,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
        Column(
          children: [
            Divider(
              color: PopboxColor.mdGrey400,
            ),
            Container(
              margin: EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
              child: CustomButtonRed(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RegisterIdPage(
                        from: "verify",
                      ),
                    ),
                  );
                },
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.verifyNow),
                width: 90.0.w,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
