import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/search_type.dart';
import 'package:new_popbox/core/utils/extensions/silver_grid_delegate_fixed.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/static_data.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:sizer/sizer.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
        child: SearchAppBarView(
          title: "",
        ),
      ),
      body: SafeArea(
        child: ListView(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: 2,
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                  crossAxisSpacing: 10.0,
                  height: 35.0,
                  crossAxisCount: 3,
                ),
                itemBuilder: (BuildContext context, int index) {
                  SearchType searchType =
                      StaticData().getSearchType(context)[index];

                  return SearchTypeItem(
                    index,
                    searchType.searchType,
                  );
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
              child: CustomWidget().textMedium(
                  AppLocalizations.of(context)
                      .translate(LanguageKeys.lastSearch),
                  PopboxColor.mdGrey700,
                  12.0.sp,
                  TextAlign.left),
            ),
            Expanded(
              child: ListView.builder(
                //physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: StaticData().getApartmentList(context).length,
                itemBuilder: (context, position) {
                  String apartmentName =
                      StaticData().getApartmentList(context)[position];
                  return apartmentNameItem(position, apartmentName);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int checkedIndex = 0;

  Widget SearchTypeItem(int index, String title) {
    bool checked = index == checkedIndex;
    return GestureDetector(
      onTap: () {
        if (mounted) {
          setState(() {
            checkedIndex = index;
          });
        }
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: 10.0,
            minWidth: 10.0,
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

  Widget apartmentNameItem(int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 8.0, bottom: 0.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 4.0),
                  child: CustomWidget().textMedium(
                    title,
                    PopboxColor.mdBlack1000,
                    12.0.sp,
                    TextAlign.left,
                  ),
                ),
              ],
            ),
            Divider(
              height: 1.0,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }
}
