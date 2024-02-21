import 'package:flutter/material.dart';

class CustomError extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomError({
    Key key,
    @required this.errorDetails,
  })  : assert(errorDetails != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();

    // Card(
    //   child: Padding(
    //     child: CustomWidget().textBold(
    //         AppLocalizations.of(context).translate(LanguageKeys.pleaseWait),
    //         PopboxColor.mdBlack1000,
    //         12.0.sp,
    //         TextAlign.center),
    //     padding: const EdgeInsets.all(8.0),
    //   ),
    //   color: PopboxColor.mdWhite1000,
    //   margin: EdgeInsets.zero,
    // );
  }
}
