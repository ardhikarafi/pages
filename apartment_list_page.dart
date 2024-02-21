import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/apartment/apartment_data.dart';
import 'package:new_popbox/core/models/callback/region/city_list_data.dart';
import 'package:new_popbox/core/models/callback/region/province_list_data.dart';
import 'package:new_popbox/core/models/payload/apartment_payload.dart';
import 'package:new_popbox/core/models/payload/city_payload.dart';
import 'package:new_popbox/core/models/payload/province_payload.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/apartment_viewmodel.dart';
import 'package:new_popbox/core/viewmodel/region_viewmodel.dart';
import 'package:new_popbox/ui/widget/app_widget.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ApartmentListPage extends StatefulWidget {
  final String from;
  final String provinceId;

  const ApartmentListPage({Key key, @required this.from, this.provinceId})
      : super(key: key);
  @override
  _ApartmentListPageState createState() => _ApartmentListPageState();
}

class _ApartmentListPageState extends State<ApartmentListPage> {
  TextEditingController apartmentNameController = TextEditingController();
  TextEditingController regionNameController = TextEditingController();
  String selectedApartmentName = "";
  String selectedApartmentId = "";

  @override
  void initState() {
    super.initState();

    var apartmentModel =
        Provider.of<ApartmentViewModel>(context, listen: false);

    var regionModel = Provider.of<RegionViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (widget.from == "apartment") {
          String country = "";

          if (SharedPreferencesService().locationSelected == "ID") {
            country = "Indonesia";
          } else if (SharedPreferencesService().locationSelected == "MY") {
            country = "Malaysia";
          } else if (SharedPreferencesService().locationSelected == "PH") {
            country = "Philippines";
          }

          ApartmentPayload apartmentPayload = new ApartmentPayload();
          apartmentPayload.countryName = country;

          apartmentPayload.token = GlobalVar.API_TOKEN;
          await apartmentModel.apartmentList(
            apartmentPayload,
            context,
            onSuccess: (response) {},
            onError: (response) {},
          );
        } else if (widget.from == "province") {
          ProvincePayload provincePayload = new ProvincePayload()
            ..token = GlobalVar.API_TOKEN
            ..countryCode = SharedPreferencesService().locationSelected;

          await regionModel.provinceList(
            provincePayload,
            context,
            onSuccess: (response) {},
            onError: (response) {},
          );
        } else if (widget.from == "city") {
          CityPayload cityPayload = new CityPayload()
            ..token = GlobalVar.API_TOKEN
            ..provinceId = widget.provinceId;

          await regionModel.cityList(
            cityPayload,
            context,
            onSuccess: (response) {},
            onError: (response) {},
          );
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: DetailAppBarView(
            title: AppLocalizations.of(context)
                .translate(LanguageKeys.chooseApartmentName),
          ),
        ),
        body: showList(),
      ),
    );
  }

  Widget showList() {
    if (widget.from == "apartment") {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 28.0, 16.0, 8.0),
            child: CustomWidget().textGreyBorderRegularApartement(
              apartmentNameController,
              AppLocalizations.of(context).translate(LanguageKeys.ok),
              AppLocalizations.of(context)
                  .translate(LanguageKeys.anotherApartment),
              PopboxColor.mdBlack1000,
              12.0.sp,
              "text",
              callBackVoid: () {},
            ),
          ),
          Consumer<ApartmentViewModel>(builder: (context, apartmentModel, _) {
            if (apartmentModel.loading) return cartShimmerView(context);

            try {
              List<ApartmentData> apartmentList =
                  apartmentModel.apartmentResponse.data;

              if (apartmentList != null) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32.0, top: 8.0),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: apartmentList.length,
                      itemBuilder: (context, position) {
                        ApartmentData apartmentData = apartmentList[position];
                        return apartmentNameItem(position, apartmentData);
                      },
                    ),
                  ),
                );
              } else {
                return Center(
                  child: CustomWidget().textMedium(
                    "No Data",
                    PopboxColor.mdBlack1000,
                    13.0.sp,
                    TextAlign.left,
                  ),
                );
              }
            } catch (e) {
              return Center(
                child: CustomWidget().textMedium(
                  "No Data",
                  PopboxColor.mdBlack1000,
                  13.0.sp,
                  TextAlign.left,
                ),
              );
            }
          }),
        ],
      );
    } else if (widget.from == "province") {
      return ListView(
        children: [
          Consumer<RegionViewModel>(builder: (context, regionModel, _) {
            if (regionModel.loading) return cartShimmerView(context);

            try {
              List<ProvinceListData> provinceList =
                  regionModel.provinceResponse.data[0].listData;

              if (provinceList != null) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32.0, top: 8.0),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: provinceList.length,
                      itemBuilder: (context, position) {
                        ProvinceListData provinceData = provinceList[position];
                        return provinceItem(position, provinceData);
                      },
                    ),
                  ),
                );
              } else {
                return Center(
                  child: CustomWidget().textMedium(
                    "No Data",
                    PopboxColor.mdBlack1000,
                    13.0.sp,
                    TextAlign.left,
                  ),
                );
              }
            } catch (e) {
              return Center(
                child: CustomWidget().textMedium(
                  "No Data",
                  PopboxColor.mdBlack1000,
                  13.0.sp,
                  TextAlign.left,
                ),
              );
            }
          }),
        ],
      );
    } else {
      return ListView(
        children: [
          Consumer<RegionViewModel>(builder: (context, regionModel, _) {
            if (regionModel.loading) return cartShimmerView(context);

            try {
              List<CityListData> cityList =
                  regionModel.cityResponse.data[0].listData;

              if (cityList != null) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32.0, top: 8.0),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: cityList.length,
                      itemBuilder: (context, position) {
                        CityListData cityListData = cityList[position];
                        return cityItem(position, cityListData);
                      },
                    ),
                  ),
                );
              } else {
                return Center(
                  child: CustomWidget().textMedium(
                    "No Data",
                    PopboxColor.mdBlack1000,
                    13.0.sp,
                    TextAlign.left,
                  ),
                );
              }
            } catch (e) {
              return Center(
                child: CustomWidget().textMedium(
                  "No Data",
                  PopboxColor.mdBlack1000,
                  13.0.sp,
                  TextAlign.left,
                ),
              );
            }
          }),
        ],
      );
    }
  }

  int checkedIndex = -1;
  Widget apartmentNameItem(int index, ApartmentData apartmentData) {
    bool checked = index == checkedIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          checkedIndex = index;
          Navigator.pop(
            context,
            apartmentData,
          );
        });
      },
      child: Container(
        margin:
            const EdgeInsets.only(left: 0.0, right: 0.0, top: 8.0, bottom: 0.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
                  child: CustomWidget().textMedium(
                    apartmentData.name,
                    PopboxColor.mdBlack1000,
                    13.0.sp,
                    TextAlign.left,
                  ),
                ),
                checked
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
                            child: Image.asset(
                              "assets/images/ic_checked_green.png",
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 16.0, right: 16.0),
              child: Divider(
                height: 1.0,
                color: Colors.grey,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget provinceItem(int index, ProvinceListData provinceListData) {
    bool checked = index == checkedIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          checkedIndex = index;
          Navigator.pop(
            context,
            provinceListData,
          );
        });
      },
      child: Container(
        margin:
            const EdgeInsets.only(left: 0.0, right: 0.0, top: 8.0, bottom: 0.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
                  child: CustomWidget().textMedium(
                    provinceListData.provinceName,
                    PopboxColor.mdBlack1000,
                    13.0.sp,
                    TextAlign.left,
                  ),
                ),
                checked
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
                            child: Image.asset(
                              "assets/images/ic_checked_green.png",
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 16.0, right: 16.0),
              child: Divider(
                height: 1.0,
                color: Colors.grey,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget cityItem(int index, CityListData cityListData) {
    bool checked = index == checkedIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          checkedIndex = index;
          Navigator.pop(
            context,
            cityListData,
          );
        });
      },
      child: Container(
        margin:
            const EdgeInsets.only(left: 0.0, right: 0.0, top: 8.0, bottom: 0.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
                  child: CustomWidget().textMedium(
                    cityListData.cityName,
                    PopboxColor.mdBlack1000,
                    13.0.sp,
                    TextAlign.left,
                  ),
                ),
                checked
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
                            child: Image.asset(
                              "assets/images/ic_checked_green.png",
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 16.0, right: 16.0),
              child: Divider(
                height: 1.0,
                color: Colors.grey,
              ),
            )
          ],
        ),
      ),
    );
  }
}
