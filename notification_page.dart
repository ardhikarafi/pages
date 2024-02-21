import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/notification/notification_list_data.dart';
import 'package:new_popbox/core/models/payload/hooks_slack_payload.dart';
import 'package:new_popbox/core/models/payload/notification_payload.dart';
import 'package:new_popbox/core/models/payload/notification_read_payload.dart';
import 'package:new_popbox/core/models/payload/notification_unread_badge_payload.dart';
import 'package:new_popbox/core/utils/global_function.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/notification_viewmodel.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/pages/transaction_detail.dart';
import 'package:new_popbox/ui/widget/app_widget.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:remove_emoji/remove_emoji.dart';

import 'home.dart';
import 'notification_detail_page.dart';

class NotificationPage extends StatefulWidget {
  final String onesignalId;

  const NotificationPage({Key key, this.onesignalId}) : super(key: key);
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationListData> lists = [];
  String model = "";
  String deviceVersion = "";
  String identifier = "";
  String brand = "";
  String osVersion = "";
  String osType = "";
  String version = "";
  String code = "";
  @override
  void initState() {
    var notificationModel =
        Provider.of<NotificationViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        List<String> deviceInfo = await getDeviceDetails();
        model = deviceInfo[0];
        deviceVersion = deviceInfo[1];
        identifier = deviceInfo[2];
        brand = deviceInfo[3];
        osVersion = deviceInfo[4];
        osType = deviceInfo[5];

        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        version = packageInfo.version;
        code = packageInfo.buildNumber;
        NotificationPayload notificationPayload = new NotificationPayload()
          ..sessionId = SharedPreferencesService().user.sessionId
          ..status = "all"
          ..dateRange = []
          ..limit = 20
          ..token = GlobalVar.API_TOKEN;

        try {
          await notificationModel.notificationList(
            notificationPayload,
            context,
            onSuccess: (response) {
              lists = response.data.lists;
            },
            onError: (response) {
              hookSlack(
                context: context,
                endPoint: GlobalVar.URL_NOTIFICATION_LIST,
                funcName: "Notification Page - List",
                payload: notificationPayload,
                response: response,
                isAPI: true,
              );
            },
          );
        } catch (e) {
          hookSlack(
            context: context,
            endPoint: GlobalVar.URL_NOTIFICATION_LIST,
            funcName: "Notification Page - List",
            msgCatch: e.toString(),
            payload: notificationPayload,
            isAPI: false,
          );
        }
      },
    );

    super.initState();
  }

  Future<void> _refresh() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 100));
    var notificationModel =
        Provider.of<NotificationViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        NotificationPayload notificationPayload = new NotificationPayload()
          ..sessionId = SharedPreferencesService().user.sessionId
          ..status = "all"
          ..dateRange = []
          ..limit = 20
          ..token = GlobalVar.API_TOKEN;
        await notificationModel.notificationList(
          notificationPayload,
          context,
          onSuccess: (response) {
            lists = [];
            lists = response.data.lists;
          },
          onError: (response) {},
        );
      },
    );
  }

  void hookSlack({
    BuildContext context,
    dynamic response,
    String msgCatch,
    String endPoint,
    String funcName,
    dynamic payload,
    bool isAPI = false,
  }) {
    final userModel = Provider.of<UserViewModel>(context, listen: false);
    //Hooks Slack
    HooksSlackPayload payloadSlack = new HooksSlackPayload(
      token: GlobalVar.API_TOKEN,
      platform: "Android",
      apiInfo: ApiInfo(
        endpoint: endPoint,
        errorMessage: (isAPI) ? response.response.message.toString() : ".nul",
        payload: payload,
      ),
      appError: AppError(
        funcName: funcName,
        line: "",
        message: msgCatch.toString(),
      ),
      deviceInfo: DeviceInfo(
        deviceId: identifier.removemoji.replaceAll(RegExp('[^A-Za-z0-9]'), ''),
        deviceName: (brand +
                " " +
                model +
                " os version " +
                osVersion +
                " app version " +
                version +
                " build " +
                code)
            .removemoji
            .replaceAll(RegExp('[^A-Za-z0-9]'), ''),
        deviceType: osType,
        osName: "",
        osVersion: osVersion,
      ),
      userPhone: SharedPreferencesService().user.phone,
    );

    userModel.logSlack(payloadSlack, context,
        onSuccess: (response) {}, onError: (response) {});
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
          isCallback: true,
          title:
              AppLocalizations.of(context).translate(LanguageKeys.notification),
          callback: () {
            handleWillPop();
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: handleWillPop,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: Container(
              child:
                  Consumer<NotificationViewModel>(builder: (context, model, _) {
                if (model.loading) return cartShimmerView(context);

                if (model.notificationResponse != null) {
                  if (model.notificationResponse.data.lists.isEmpty) {
                    return Column(
                      children: [
                        Container(
                          margin:
                              EdgeInsets.only(left: 57, right: 57, top: 145),
                          height: 290.0,
                          width: 290.0,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/ic_no_notification_fix.png'))),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 55.0),
                          child: CustomWidget().textBold(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.notificationEmpty),
                            PopboxColor.mdBlack1000,
                            13.0.sp,
                            TextAlign.center,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 15.0),
                          child: CustomWidget().textRegular(
                            AppLocalizations.of(context).translate(
                                LanguageKeys.notificationEmptyDetail),
                            PopboxColor.mdBlack1000,
                            11.0.sp,
                            TextAlign.center,
                          ),
                        )
                      ],
                    );
                  }
                }

                return ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 32.0, top: 8.0),
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: lists.length,
                        itemBuilder: (context, position) {
                          NotificationListData notificationData =
                              lists[position];

                          return notificationItem(position, notificationData);
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> handleWillPop() async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
        (Route<dynamic> route) => false);
    return true;
  }

  int readCounter = 0;
  // ignore: missing_return
  Widget notificationItem(int index, NotificationListData data) {
    if (widget.onesignalId != "" &&
        widget.onesignalId == data.idMessage &&
        readCounter == 0) {
      Future.delayed(Duration(milliseconds: 20)).then((value) {
        readNotification(data);
        readCounter++;
      });
    } else {
      return GestureDetector(
        onTap: () {
          readNotification(data);
        },
        child: Container(
            color: data.status == "read" ? Colors.white : Colors.lightBlue[50],
            child: Container(
              margin:
                  const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget().textBold(
                      data.notifType[0].toUpperCase() +
                          data.notifType.substring(1),
                      PopboxColor.popboxRed,
                      10,
                      TextAlign.left),
                  SizedBox(height: 7),
                  CustomWidget().textBold(
                      data.title, PopboxColor.mdBlack1000, 14, TextAlign.left),
                  SizedBox(height: 6),
                  Text(
                    data.content,
                    overflow: TextOverflow.clip,
                    softWrap: true,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: PopboxColor.mdGrey800,
                        fontSize: 12,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w400,
                        height: 1.8),
                  ),
                  SizedBox(height: 17.0),
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                      ),
                      SizedBox(width: 7.0),
                      CustomWidget().textLight(data.dateSent,
                          PopboxColor.mdGrey800, 10, TextAlign.left),
                    ],
                  )
                ],
              ),
            )),
      );
    }
  }

  void readNotification(NotificationListData data) async {
    var notificationModel =
        Provider.of<NotificationViewModel>(context, listen: false);
    NotificationUnreadBadgePayload notificationUnreadBadgePayload =
        new NotificationUnreadBadgePayload()
          ..sessionId = SharedPreferencesService().user.sessionId
          ..token = GlobalVar.API_TOKEN;

    await notificationModel.notificationUnreadBadge(
      notificationUnreadBadgePayload,
      context,
      onSuccess: (response) {},
      onError: (response) {},
    );

    NotificationReadPayload notificationReadPayload =
        new NotificationReadPayload()
          ..idMessage = data.idMessage
          ..timestamps = DateTime.now().millisecondsSinceEpoch.toString()
          ..token = GlobalVar.API_TOKEN;

    await notificationModel.notificationRead(
      notificationReadPayload,
      context,
      onSuccess: (response) {
        try {
          if (response.response.code == 200) {
            for (var i = 0;
                i < notificationModel.notificationResponse.data.lists.length;
                i++) {
              try {
                if (notificationModel
                            .notificationResponse.data.lists[i].idMessage ==
                        data.idMessage &&
                    data.status == "unread") {
                  setState(() {
                    notificationModel
                        .notificationResponse.data.lists[i].status = "read";
                    notificationModel.notificationUnreadBadgeResponse.data
                        .total = notificationModel
                            .notificationUnreadBadgeResponse.data.total -
                        1;
                  });
                }
              } catch (e) {}
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TransactionDetailPage(
                  isPopNotif: true,
                  transactionType: data.parcelInfo.category,
                  orderIdNotif: (data.notifType == "popsafe")
                      ? data.parcelInfo.awbNumber
                      : data.parcelInfo.id,
                ),
              ),
            );
          } else {
            try {
              CustomWidget().showCustomDialog(
                  context: context, msg: response.response.message);
            } catch (e) {
              CustomWidget()
                  .showCustomDialog(context: context, msg: e.toString());
            }
          }
        } catch (e) {
          CustomWidget().showCustomDialog(
            context: context,
            msg: "catch : " + e.toString(),
          );
        }
      },
      onError: (response) {
        try {
          CustomWidget().showCustomDialog(
              context: context, msg: response.response.message);
        } catch (e) {
          CustomWidget().showCustomDialog(context: context, msg: e.toString());
        }
      },
    );
  }
}
