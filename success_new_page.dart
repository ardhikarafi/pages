import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';

class SuccessNewPage extends StatefulWidget {
  final String from;
  const SuccessNewPage({Key key, this.from}) : super(key: key);

  @override
  State<SuccessNewPage> createState() => _SuccessNewPageState();
}

class _SuccessNewPageState extends State<SuccessNewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: (widget.from == "accountaddress")
            ? pageAccountAddress()
            : Container());
  }

  Widget pageAccountAddress() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Color(0xff25BE0C),
                size: 44,
              ),
              SizedBox(height: 10),
              CustomWidget().textBoldPlus(
                AppLocalizations.of(context)
                    .translate(LanguageKeys.caseSuccess)
                    .replaceAll(
                        "%s",
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.process)),
                Colors.black,
                16,
                TextAlign.left,
              ),
              SizedBox(height: 15),
              CustomWidget().textLight(
                AppLocalizations.of(context)
                    .translate(LanguageKeys.caseSuccessSave)
                    .replaceAll(
                        "%s",
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.address)),
                Colors.black,
                14,
                TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
