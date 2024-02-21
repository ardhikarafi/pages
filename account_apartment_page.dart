import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/apartment/apartmentlist_data.dart';
import 'package:new_popbox/core/models/callback/user/user_login_data.dart';
import 'package:new_popbox/core/models/payload/apartmentlist_payload.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/apartment_viewmodel.dart';
import 'package:new_popbox/ui/widget/app_widget.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AccountApartmentPage extends StatefulWidget {
  @override
  State<AccountApartmentPage> createState() => _AccountApartmentPageState();
}

class _AccountApartmentPageState extends State<AccountApartmentPage> {
  SharedPreferencesService sharedPrefService;
  UserLoginData userData;
  List<ApartmentlistData> data = [];
  List<ApartmentlistData> tempData = [];
  bool isSearch = false;
  String country = "";
  @override
  void initState() {
    var apartmentModel =
        Provider.of<ApartmentViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      sharedPrefService = await SharedPreferencesService.instance;
      userData = sharedPrefService.user;
      country = userData.country;

      ApartmentListPayload payload = new ApartmentListPayload()
        ..token = GlobalVar.API_TOKEN
        ..sessionId = userData.sessionId
        ..likeNameApartment = ""
        ..countryCode = country;

      await apartmentModel.getApartmentList(payload, context,
          onSuccess: (response) {
        data = response.data;
        tempData = response.data;
      }, onError: (response) {});
    });

    super.initState();
  }

  void _runSearch(String inputKeyword) {
    isSearch = true;
    List result;
    if (inputKeyword.isEmpty) {
      isSearch = false;
      result = tempData;
    } else {
      result = data
          .where((element) =>
              element.name.toLowerCase().contains(inputKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      data = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: GeneralAppBarView(
          title: AppLocalizations.of(context)
              .translate(LanguageKeys.findApartment),
          isButtonBack: true,
        ),
      ),
      body: Consumer<ApartmentViewModel>(builder: (context, model, _) {
        if (model.loading) return cartShimmerView(context);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CustomWidget().textGreyBorderRegularSearchTransaction(
                  (value) => _runSearch(value),
                  AppLocalizations.of(context).translate(LanguageKeys.search),
                  PopboxColor.mdGrey900,
                  14),
            ),
            (data.length == 0)
                ? Flexible(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomWidget().textBoldPlus(
                        AppLocalizations.of(context)
                            .translate(LanguageKeys.apartmentNotFound),
                        PopboxColor.mdBlack1000,
                        16,
                        TextAlign.left,
                      ),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          final data = {
                            "isOther": true,
                            "value": AppLocalizations.of(context)
                                .translate(LanguageKeys.others)
                          };
                          Navigator.pop(
                            context,
                            data,
                          );
                        },
                        child: CustomWidget().textLight(
                          AppLocalizations.of(context)
                              .translate(LanguageKeys.addYourApartmentHere),
                          PopboxColor.mdBlack1000,
                          12,
                          TextAlign.left,
                        ),
                      ),
                    ],
                  ))
                : Flexible(
                    child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          ApartmentlistData item = data[index];
                          return itemListOfApart(context, item);
                        })),
            GestureDetector(
              onTap: () {
                final data = {
                  "isOther": true,
                  "value": AppLocalizations.of(context)
                      .translate(LanguageKeys.others)
                };
                Navigator.pop(
                  context,
                  data,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Container(
                    width: 100.0.w,
                    margin: const EdgeInsets.only(left: 35, right: 35),
                    child: CustomWidget().textLight(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.others),
                      PopboxColor.mdBlack1000,
                      14,
                      TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 1,
                    width: 100.0.w,
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    color: Color(0xffD8D8D8),
                  )
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

Widget itemListOfApart(BuildContext context, ApartmentlistData item) {
  return GestureDetector(
    onTap: () {
      final data = {
        "isOther": false,
        "value": item.name,
        "apartId": item.uuidApartment
      };
      Navigator.pop(context, data);
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Container(
          width: 100.0.w,
          margin: const EdgeInsets.only(left: 35, right: 35),
          child: CustomWidget().textLight(
            item.name,
            PopboxColor.mdBlack1000,
            14,
            TextAlign.left,
          ),
        ),
        SizedBox(height: 20),
        Container(
          height: 1,
          width: 100.0.w,
          margin: const EdgeInsets.only(left: 20, right: 20),
          color: Color(0xffD8D8D8),
        )
      ],
    ),
  );
}
