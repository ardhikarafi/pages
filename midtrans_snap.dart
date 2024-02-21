import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_popbox/core/models/callback/parcel/parcel_for_you_history_data.dart';
import 'package:new_popbox/core/models/callback/parcel/parcel_history_detail_data.dart';
import 'package:new_popbox/core/models/callback/parcel/unfinish_parcel_data.dart';
import 'package:new_popbox/core/models/callback/payment/collect_payment_data.dart';
import 'package:new_popbox/core/models/callback/popsafe/popsafe_history_data.dart';
import 'package:new_popbox/ui/pages/midtrans_snap_blank.dart';
import 'package:new_popbox/ui/pages/payment_failed_page.dart';
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
import '../../core/utils/shared_preference_service.dart';
import '../../core/viewmodel/collect_payment_viewmodel.dart';
import '../widget/appbar.dart';

void main() {
  runApp(MyMidtransSnap());
}

class MyMidtransSnap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MidtransSnap(),
    );
  }
}

class MidtransSnap extends StatefulWidget {
  final String url;
  final String transactionType;
  final ParcelHistoryDetailData parcelHistoryDetailData;
  //final CollectPaymentData collectPaymentData;
  //final double totalPaid;
  final String transactionId;
  final UnfinishParcelData unfinishParcelData;
  final ParcelForYouHistoryData parcelData;

  const MidtransSnap(
      {Key key,
      this.url,
      this.transactionType,
      this.parcelHistoryDetailData,
      //this.collectPaymentData,
      //this.totalPaid,
      this.transactionId,
      this.unfinishParcelData,
      this.parcelData})
      : super(
          key: key,
        );

  @override
  _MidtransSnap createState() => _MidtransSnap();
}

class _MidtransSnap extends State<MidtransSnap> with WidgetsBindingObserver {
  String url = "";
  WebViewController _webViewController;
  bool shouldLoadNewUrl = false;
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  bool _isWebViewVisible = true;
  //String urlSnap = "https:\/\/app.midtrans.com\/snap\/v3\/redUnfinishParcelData irection\/b2595f63-bc91-4cdb-8c4f-eda9d2b3dc9a";
  PaymentStatusModel paymentStatusModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove the observer when the widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _appLifecycleState = state;
      _isWebViewVisible = state == AppLifecycleState.resumed;
    });

    // Handle app lifecycle state changes
    switch (state) {
      case AppLifecycleState.resumed:
        print("Logy> App resumed");
        onLoading();

        _createSessionPayment(
            this.context,
            widget.transactionType,
            widget.parcelHistoryDetailData,
            widget.transactionId,
            widget.unfinishParcelData,
            widget.parcelData,
            widget.url);

        // _callBackMidtrans(
        //     this.context,
        //     widget.transactionType,
        //     widget.collectPaymentData,
        //     widget.methodPayment,
        //     widget.totalPaid,
        //     widget.transactionNumber,
        //     widget.parcelHistoryDetailData,
        //     widget.transactionId,
        //     widget.unfinishParcelData,
        //     widget.parcelData);

        // Add your logic when the app is resumed
        break;
      case AppLifecycleState.inactive:
        print("Logy> App inactive");
        url = "";
        // Add your logic when the app becomes inactive
        break;
      case AppLifecycleState.paused:
        print("Logy> App paused");
        // Add your logic when the app is paused
        break;
      case AppLifecycleState.detached:
        print("Logy> App detached");
        url = "";

        // Add your logic when the app is detached
        break;
    }
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
          Navigator.of(context).pop(true);
        },
        child: Stack(
          children: [
            Offstage(
              offstage: !_isWebViewVisible,
              child: WebView(
                  initialUrl: widget.url,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (webViewController) {
                    setState(() {
                      _webViewController = webViewController;
                    });
                  },
                  navigationDelegate: (NavigationRequest request) {
                    if (Uri.parse(request.url).isAbsolute) {
                      checkAppInstalled(
                          request.url); // Replace with your package name
                      return NavigationDecision.prevent;
                    } else {
                      return NavigationDecision.navigate;
                    }
                  },
                  onPageFinished: (String url) {
                    print('logy onPageFinished: ' + url);
                    if (url.contains("/407")) {
                      print('logy handle expired transaction');
                    }
                  }),
            ),
            Center(
              child: _appLifecycleState != AppLifecycleState.resumed
                  ? CircularProgressIndicator()
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkAppInstalled(String packageName) async {
    print('Logy> packageName : ' + packageName);
    PackageInfo packageInfo;
    try {
      packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      // Handle error, if any
      print('Error: $e');
      return;
    }

    // if (packageName.contains("//gopay.co.id")){
    //   _webViewController.loadUrl(packageName);
    //   bool isInstalled = await canLaunch(packageInfo.packageName);
    //   if (isInstalled) {
    //     //_launchUrl(packageInfo.packageName);
    //     print('$packageName is installed.');
    //   } else {
    //     print('$packageName is not installed.');
    //   }
    // }

    if (packageName.contains("https://gopayapp.page.link") ||
        packageName.contains("https://gojek.link/gopay")) {
      Navigator.of(this.context).push(
        MaterialPageRoute(
            builder: (context) => MyMidtransSnapB(
                  url: packageName,
                )),
        // PaymentSuccessPage()),
      );
      // _launchUrl(packageName);
    }
  }

  void updateUrl(String newUrl) async {
    // Update the URL in the WebView
    if (_webViewController != null) {
      await _webViewController.loadUrl(newUrl);
    }
  }

  void onLoading() {
    showDialog(
        context: this.context,
        builder: (BuildContext context) {
          return Center(
            child: SizedBox(
                height: 50, width: 50, child: CircularProgressIndicator()),
          );
        });
  }
}

void _callBackMidtrans(
    BuildContext context,
    String transactionType,
    //CollectPaymentData collectPaymentData,
    double totalPaid,
    ParcelHistoryDetailData parcelHistoryDetailData,
    String transactionId,
    UnfinishParcelData unfinishParcelData,
    ParcelForYouHistoryData parcelData) async {
  print('logy> _callBackMidtrans : ' + transactionId);
  DateTime now = DateTime.now();
  String dateNow = now.toString();
  String grossAmount = totalPaid.toString();

  var callbackMidtrans =
      Provider.of<CollectPaymentViewModel>(context, listen: false);
  CallbackMidtransPayload payload = new CallbackMidtransPayload()
    ..transactionTime = dateNow
    ..transactionStatus = "settlement"
    ..transactionId = transactionId
    ..statusMessage = "midtrans payment notification"
    ..statusCode = "200"
    ..signatureKey =
        "417594c1db9d0da09a19197092bf948e6a808948a1c02b06100ef770ea858ed06b92bb06fd7d54f79e27d88fc96163b69bc9521b124233b616ceea82c4e1a8c8"
    ..settlementTime = dateNow
    ..paymentType = "gopay"
    //..orderId = collectPaymentData.paymentId
    ..merchantId = "G067624917"
    ..grossAmount = grossAmount
    ..fraudStatus = "accept"
    ..currency = "IDR";

  await callbackMidtrans.callbackMidtrans(payload, context,
      onSuccess: (response) {
    try {
      // _createSessionPayment(context, transactionType, parcelHistoryDetailData,
      //     transactionId, unfinishParcelData, parcelData);
    } catch (e) {
      //   _createSessionPayment(context, transactionType, parcelHistoryDetailData,
      //       transactionId, unfinishParcelData, parcelData);
    }
  }, onError: (response) {
    // _createSessionPayment(context, transactionType, parcelHistoryDetailData,
    //     transactionId, unfinishParcelData, parcelData);
  });
}

void _createSessionPayment(
    BuildContext context,
    String transactionType,
    ParcelHistoryDetailData parcelHistoryDetailData,
    String transactionId,
    UnfinishParcelData unfinishParcelData,
    ParcelForYouHistoryData parcelData,
    String url) async {
  print('logy> _createSessionPayment : ' + transactionId);

  var createSession =
      Provider.of<CollectPaymentViewModel>(context, listen: false);
  CreateSessionPayload createSessionPayload = new CreateSessionPayload()
    ..clientId = "001"
    ..token = "79XM983RH8TK37KTR84NNUCYK8DTLTRDXE5Z77UP";
  print('logy _createSessionPayment');
  await createSession.createSessionPayment(createSessionPayload, context,
      onSuccess: (response) {
    try {
      _checkStatusPayment(
          response.data.first.sessionId.toString(),
          context,
          parcelHistoryDetailData,
          transactionId,
          unfinishParcelData,
          transactionType,
          parcelData,
          url);
    } catch (e) {}
  }, onError: (response) {});
}

void _checkStatusPayment(
    String sessionId,
    BuildContext context,
    ParcelHistoryDetailData parcelHistoryDetailData,
    String transactionId,
    UnfinishParcelData unfinishParcelData,
    String transactionType,
    ParcelForYouHistoryData parcelData,
    String url) async {
  var checkStatusPayment =
      Provider.of<CollectPaymentViewModel>(context, listen: false);
  CheckStatusPaymentPayload checkStatusPaymentPayload =
      new CheckStatusPaymentPayload()
        ..token = "79XM983RH8TK37KTR84NNUCYK8DTLTRDXE5Z77UP"
        //sessionId     = SharedPreferencesService().user.sessionId
        ..sessionId = sessionId
        ..transactionId = ""
        ..paymentId = "" + transactionId
        ..idOrderNumber = ""
        ..lockerOrderNumber = "";

  print('logy _checkStatusPayment: ' + transactionId);
  await checkStatusPayment.checkStatusPayment(
      checkStatusPaymentPayload, context, onSuccess: (response) {
    try {
      print('logy _checkStatusPayment response: ' + response.data[0].status);
      if (response.data[0].status.contains("PAID")) {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => PaymentSuccessPage(
                  status: response.data.first.status,
                  statusPayment: response.data.first,
                  transactionId: transactionId,
                  unfinishParcelData: unfinishParcelData,
                  transactionType: transactionType,
                  parcelData: parcelData)),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => PaymentFailedPage(
                  status: response.data.first.status,
                  statusPayment: response.data.first,
                  transactionId: transactionId,
                  unfinishParcelData: unfinishParcelData,
                  transactionType: transactionType,
                  parcelData: parcelData,
                  url: url)),
        );
        //   Fluttertoast.showToast(
        //     msg: "Payment failed, please try again!",
        //     toastLength:
        //         Toast.LENGTH_SHORT, // Duration for which the toast is visible
        //     gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        //     timeInSecForIosWeb:
        //         1, // Time duration in seconds for which the message is displayed
        //     backgroundColor: Colors.grey, // Background color of the toast message
        //     textColor: Colors.white, // Text color of the toast message
        //     fontSize: 16.0, // Font size of the toast message
        //   );
      }
    } catch (e) {
      print('logy _checkStatusPayment catch: ' + e.toString());
    }
  }, onError: (response) {});
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
