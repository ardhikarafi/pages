import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/notification/notification_list_data.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:sizer/sizer.dart';

class NotificationDetailPage extends StatefulWidget {
  final NotificationListData notificationData;

  const NotificationDetailPage({Key key, this.notificationData})
      : super(key: key);
  @override
  _NotificationDetailPageState createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
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
        child: DetailAppBarViewCloseIcon(
          title: widget.notificationData.title,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: notificationItem(widget.notificationData))
          ],
        ),
      ),
    );
  }

  Widget notificationItem(NotificationListData data) {
    return Card(
      color: PopboxColor.mdGrey100,
      //elevation: 4.0,
      margin: EdgeInsets.only(top: 4.0),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomWidget().textBoldProduct(
              data.title,
              PopboxColor.mdBlack1000,
              12.0.sp,
              5,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  CustomWidget().textBoldProduct(
                    data.notifType,
                    PopboxColor.mdGrey500,
                    11.0.sp,
                    5,
                  ),
                  CustomWidget().textBoldProduct(
                    "  ●  ",
                    PopboxColor.mdGrey500,
                    11.0.sp,
                    1,
                  ),
                  CustomWidget().textBoldProduct(
                    data.deliveryAt,
                    PopboxColor.mdGrey500,
                    11.0.sp,
                    5,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: CustomWidget().textRegularProduct(
                data.content,
                PopboxColor.mdBlack1000,
                11.0.sp,
                1000,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
