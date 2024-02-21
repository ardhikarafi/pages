import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/user/merge_phone_data.dart';
import 'package:new_popbox/core/models/callback/user/multi_phone_no.dart';
import 'package:new_popbox/core/models/payload/merge_phone_payload.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MergeAccountInfoPage extends StatefulWidget {
  //registered_secondary
  //registered_primary
  final String from;
  final String mergePhoneNo;
  const MergeAccountInfoPage(
      {Key key, @required this.from, this.mergePhoneNo = ""})
      : super(key: key);
  @override
  _MergeAccountInfoPageState createState() => _MergeAccountInfoPageState();
}

class _MergeAccountInfoPageState extends State<MergeAccountInfoPage>
    with WidgetsBindingObserver {
  TextEditingController emailController = TextEditingController();

  bool showSubmitButton = true;

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
          title:
              AppLocalizations.of(context).translate(LanguageKeys.addPhoneNo),
        ),
      ),
      body: SafeArea(
        child: Consumer<UserViewModel>(builder: (context, userModel, _) {
          return Stack(
            children: [
              content(widget.from),
              if (userModel.loading)
                AbsorbPointer(
                  child: Container(
                    width: 100.0.w,
                    height: 100.0.h,
                    color: Colors.grey.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget content(String from) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              SizedBox(
                height: 30.0,
              ),
              from == "case4"
                  ? Image.asset(
                      "assets/images/ic_merge_phone.png",
                      width: 100.0,
                      height: 160.0,
                      fit: BoxFit.fitHeight,
                    )
                  : Container(),
              SizedBox(
                height: 20.0,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 40.0,
                  right: 40.0,
                ),
                child: CustomWidget().textBold(
                  from == "case4"
                      ? AppLocalizations.of(context).translate(
                          LanguageKeys.phoneNoAlreadyRegisteredSecondary)
                      : AppLocalizations.of(context).translate(
                          LanguageKeys.phoneNoAlreadyRegisteredAnotherAccount),
                  PopboxColor.mdGrey900,
                  12.0.sp,
                  TextAlign.center,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
                child: CustomWidget().textRegular(
                  from == "case4"
                      ? AppLocalizations.of(context).translate(
                          LanguageKeys.phoneNoAlreadyRegisteredSecondaryReason)
                      : AppLocalizations.of(context).translate(LanguageKeys
                          .phoneNoAlreadyRegisteredAnotherAccountReason),
                  PopboxColor.mdGrey700,
                  11.0.sp,
                  TextAlign.left,
                ),
              ),
              from == "case4"
                  ? Container()
                  : Container(
                      margin:
                          EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
                      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      child: CustomWidget().textRegular(
                        AppLocalizations.of(context).translate(LanguageKeys
                            .phoneNoAlreadyRegistered_anotherAccountInfo),
                        PopboxColor.mdGrey700,
                        11.0.sp,
                        TextAlign.left,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: PopboxColor.mdYellow100),
                        color: PopboxColor.mdYellow100,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
              emailWidget()
            ],
          ),
        ),
        ((from == "case2" || from == "case3" || from == "case6") &&
                showSubmitButton)
            ? Column(
                children: [
                  Divider(
                    color: PopboxColor.mdGrey400,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 8.0,
                      bottom: 8.0,
                    ),
                    child: CustomButtonRed(
                      onPressed: () {
                        String email = SharedPreferencesService().user.email;

                        if (widget.mergePhoneNo == null ||
                            widget.mergePhoneNo == "") {
                          return;
                        }

                        email = emailController.text;
                        mergePhone(widget.mergePhoneNo, email);
                      },
                      title: AppLocalizations.of(context)
                          .translate(LanguageKeys.movePhoneNo),
                      width: 90.0.w,
                    ),
                  ),
                ],
              )
            : Container()
      ],
    );
  }

  Widget emailWidget() {
    if ((widget.from == "case2" ||
            widget.from == "case3" ||
            widget.from == "case6") &&
        (SharedPreferencesService().user.email == null ||
            SharedPreferencesService().user.email == "")) {
      return Column(
        children: [
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 10.0),
                        child: CustomWidget().textBold(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.emailAddress),
                          PopboxColor.mdBlack1000,
                          9.0.sp,
                          TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 0.0),
                  child: CustomWidget().textGreyBorderRegular(
                    emailController,
                    "",
                    PopboxColor.mdBlack1000,
                    12.0.sp,
                    "text",
                    callBackVoid: () {},
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                  child: CustomWidget().textRegular(
                    AppLocalizations.of(context)
                        .translate(LanguageKeys.emailExample),
                    PopboxColor.mdGrey700,
                    9.0.sp,
                    TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Container();
  }

  void mergePhone(String phoneNo, String email) {
    FocusScope.of(context).unfocus();
    MergePhonePayload mergePhonePayload = new MergePhonePayload()
      ..token = GlobalVar.API_TOKEN
      ..secondaryPhone = phoneNo
      ..email = email
      ..memberId = SharedPreferencesService().user.memberId
      ..sessionId = SharedPreferencesService().user.sessionId;

    setState(() {
      showSubmitButton = false;
    });

    final userModel = Provider.of<UserViewModel>(context, listen: false);
    userModel.mergePhone(
      mergePhonePayload,
      context,
      onSuccess: (response) {
        setState(() {
          showSubmitButton = false;
        });

        MergePhoneData finalMergePhoneData = new MergePhoneData();
        List<MultiplePhoneNumber> multiplePhoneNo = [];
        finalMergePhoneData.memberId = SharedPreferencesService().user.memberId;

        if (SharedPreferencesService().mergePhoneList != null &&
            SharedPreferencesService().mergePhoneList.length > 0) {
          multiplePhoneNo = SharedPreferencesService().mergePhoneList;
        }

        MultiplePhoneNumber mergePhoneNo = MultiplePhoneNumber()
          ..phone = phoneNo
          ..status = "PENDING";

        multiplePhoneNo.add(mergePhoneNo);

        finalMergePhoneData.multiplePhoneNumber = multiplePhoneNo;

        SharedPreferencesService()
            .removeValues(keyword: SharedPrefKeys.mergePhoneData);
        SharedPreferencesService().setMergePhone(finalMergePhoneData);
        CustomWidget()
            .showToastShortV1(context: context, msg: response.response.message);
        // Navigator.of(context).pushAndRemoveUntil(
        //   MaterialPageRoute(
        //     builder: (context) => AccountInfoPage(
        //       from: "merge",
        //     ),
        //   ),
        //   (Route<dynamic> route) => false);

        Navigator.pop(context);
      },
      onError: (response) {
        setState(() {
          showSubmitButton = true;
        });

        try {
          CustomWidget().showCustomDialog(
              context: context, msg: "onError : " + response.response.message);
        } catch (e) {
          CustomWidget().showCustomDialog(
              context: context, msg: "catch : : " + e.toString());
        }
      },
    );
  }
}
