import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/ui/pages/login_page.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:sizer/sizer.dart';

class SuccessPage extends StatefulWidget {
  final String from;
  final String msg;
  const SuccessPage(this.from, this.msg);
  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3000), () {
      setState(() {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: PopboxColor.mdWhite1000,
          height: 100.0.h,
          width: 100.0.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                //crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 100.0),
                    child: Image.asset(
                      "assets/images/ic_popbox_logo.png",
                      fit: BoxFit.fitWidth,
                      width: 100.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 100.0, top: 8.0),
                    child: CustomWidget().textMedium("Box and Beyond",
                        PopboxColor.mdGrey500, 12.0.sp, TextAlign.left),
                  ),
                  CustomWidget().textBold(
                    widget.msg,
                    PopboxColor.mdBlack1000,
                    14.0.sp,
                    TextAlign.left,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: CustomWidget().textMedium(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.pleaseWait),
                      PopboxColor.mdGrey600,
                      12.0.sp,
                      TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: AbsorbPointer(
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        color: Colors.transparent,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Image.asset(
                "assets/images/ic_register_success.png",
                fit: BoxFit.fitWidth,
                width: 80.0.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
