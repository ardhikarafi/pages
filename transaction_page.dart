import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:new_popbox/ui/widget/transaction_view.dart';
import 'package:sizer/sizer.dart';

class TransactionPage extends StatefulWidget {
  final String from;

  const TransactionPage({Key key, this.from}) : super(key: key);
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {},
    );

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: DetailAppBarView(
          title: AppLocalizations.of(context)
              .translate(LanguageKeys.yourTransaction),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: ListView(
            children: [
              new TransactionView(
                isHeader: false,
                isHome: false,
                isSearchable: true,
                isShowcase: false,
                keyThree: null,
                from: widget.from,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int checkedIndex = 0;

  Widget lockerTypeItem(int index, String title) {
    bool checked = index == checkedIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          checkedIndex = index;
        });
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: 1.0.h,
            minWidth: 1.0.w,
            maxWidth: 100.0.w,
            maxHeight: 100.0.h),
        child: RawMaterialButton(
          fillColor: checked ? PopboxColor.popboxRed : PopboxColor.mdWhite1000,
          splashColor:
              checked ? PopboxColor.popboxRed : PopboxColor.mdWhite1000,
          child: CustomWidget().textMedium(
            title,
            checked ? PopboxColor.mdWhite1000 : PopboxColor.mdGrey700,
            11.0.sp,
            TextAlign.center,
          ),
          onPressed: null,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(
                color: checked ? PopboxColor.popboxRed : PopboxColor.mdGrey350,
              )),
        ),
      ),
    );
  }
}
