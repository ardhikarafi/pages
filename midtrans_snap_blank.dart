import 'package:flutter/material.dart';
import 'package:new_popbox/core/models/callback/parcel/parcel_history_detail_data.dart';
import 'package:new_popbox/core/models/callback/payment/collect_payment_data.dart';
import 'package:new_popbox/core/models/callback/popsafe/popsafe_history_data.dart';
import 'package:new_popbox/ui/pages/home.dart';
import 'package:new_popbox/ui/pages/payment_success_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timelines/timelines.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/constants/constants.dart';
import '../../core/models/callback/payment/check_status_payment_data.dart';
import '../../core/models/payload/callback_midtrans_payload.dart';
import '../../core/models/payload/check_status_payment_payload.dart';
import '../../core/models/payload/collect_session_payload.dart';
import '../../core/models/payment_status_model.dart';
import '../../core/utils/library.dart';
import '../../core/utils/localization/app_localizations.dart';
import '../../core/viewmodel/collect_payment_viewmodel.dart';
import '../widget/appbar.dart';

void main() {
  runApp(MyMidtransSnapBlank());
}

class MyMidtransSnapBlank extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyMidtransSnapB(),
    );
  }
}

class MyMidtransSnapB extends StatefulWidget {
  final String url;

  const MyMidtransSnapB({Key key, this.url})
      : super(
          key: key,
        );

  @override
  _MyMidtransSnapB createState() => _MyMidtransSnapB();
}

class _MyMidtransSnapB extends State<MyMidtransSnapB> {
  String url = "";
  String currentUrl = "";
  bool shouldLoadNewUrl = false;
  PaymentStatusModel paymentStatusModel;

  @override
  void initState() {
    super.initState();
    print('_launchUrl: ' + widget.url);
    _launchUrl(widget.url);
  }

  @override
  void dispose() {
    // Remove the observer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: GeneralAppBarView(
          title: 'Payment',
          isButtonBack: true,
        ),
      ),
      body: WillPopScope(
        onWillPop: () {
          _gotoHome(this.context);
        },
      ),
    );
  }

  void _launchUrl(String url) async {
    print('logy> _launchUrl: ' + url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('logy> _launchUrl else: ' + url);
      await launch(url);
      // Do something if the app is not installed
    }
  }

  void _gotoHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => Home(),
      ),
    );
  }
}
