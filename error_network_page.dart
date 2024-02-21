import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:sizer/sizer.dart';

class ErrorNetworkPage extends StatefulWidget {
  @override
  _ErrorNetworkPageState createState() => _ErrorNetworkPageState();
}

class _ErrorNetworkPageState extends State<ErrorNetworkPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 60.0, left: 55.0, right: 55.0),
            width: 276.0,
            height: 395.0,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/ic_error_inet.png'))),
          ),
          SizedBox(height: 20.0),
          CustomWidget().textBold(
              AppLocalizations.of(context)
                  .translate(LanguageKeys.errorInetShortMessage),
              PopboxColor.mdBlack1000,
              13.0.sp,
              TextAlign.center),
          SizedBox(height: 20.0),
          Container(
            margin: EdgeInsets.only(left: 30.0, right: 30.0),
            child: CustomWidget().textRegular(
                AppLocalizations.of(context)
                    .translate(LanguageKeys.errorInetMessage),
                PopboxColor.mdBlack1000,
                11.0.sp,
                TextAlign.center),
          ),
          SizedBox(height: 20.0),
          CustomButtonRed(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            title:
                AppLocalizations.of(context).translate(LanguageKeys.tryAgain),
            width: MediaQuery.of(context).size.width * 0.85,
          )
        ],
      ),
    )));
  }
}
