import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/help_center/faq/faq_category_data.dart';
import 'package:new_popbox/core/models/callback/help_center/faq/faq_getlist_bycategory_data.dart';
import 'package:new_popbox/core/models/payload/faq_getlist_bycategory_payload.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/viewmodel/faq_viewmodel.dart';
import 'package:new_popbox/ui/item/faq_category_getlist_item.dart';
import 'package:new_popbox/ui/pages/webview_page.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class FaqChildOfCategoryPage extends StatefulWidget {
  final FaqCategoryData faqCategoryData;
  const FaqChildOfCategoryPage({Key key, this.faqCategoryData})
      : super(key: key);

  @override
  _FaqChildOfCategoryPageState createState() => _FaqChildOfCategoryPageState();
}

class _FaqChildOfCategoryPageState extends State<FaqChildOfCategoryPage> {
  List<FaqGetlistbyCategoryData> data;
  List<FaqGetlistbyCategoryData> myListdata;
  int countOfData = 0;
  bool isSearch = false;
  @override
  void initState() {
    var faqcategoryModel = Provider.of<FaqViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FaqGetListbyCategoryPayload payload = new FaqGetListbyCategoryPayload();
      payload.token = GlobalVar.API_TOKEN;
      payload.typeCategory = widget.faqCategoryData.typeCategory;
      payload.idCategory = widget.faqCategoryData.idCategory;
      await faqcategoryModel.faqgetListbyCategory(payload, context,
          onSuccess: (response) {
        data = response.data;
        myListdata = response.data;
        countOfData = response.data.length;
      }, onError: (response) {});
    });

    super.initState();
  }

  void _runSearch(String inputKeyword) {
    isSearch = true;
    List result;
    if (inputKeyword.isEmpty) {
      isSearch = false;
      result = myListdata;
    } else {
      result = myListdata
          .where((element) =>
              element.title.toLowerCase().contains(inputKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      data = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FaqViewModel>(builder: (context, model, _) {
      return Stack(
        children: [
          Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(60.0),
              child: DetailAppBarView(
                title: widget.faqCategoryData.category,
              ),
            ),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: CustomWidget()
                        .textGreyBorderRegularSearchTransaction(
                            (value) => _runSearch(value),
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.search),
                            PopboxColor.mdGrey900,
                            12.0.sp),
                  ),
                  //TITLE
                  Container(
                    margin: EdgeInsets.only(
                        left: 20.0, right: 20.0, top: 10.0, bottom: 5.0),
                    child: CustomWidget().textBold(
                      AppLocalizations.of(context)
                          .translate(LanguageKeys.helpTopic),
                      PopboxColor.mdBlack1000,
                      12.0.sp,
                      TextAlign.left,
                    ),
                  ),

                  //LIST VIEW
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: (!isSearch) ? countOfData : data.length,
                        itemBuilder: (context, index) {
                          FaqGetlistbyCategoryData dataOfItem = data[index];
                          return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => WebviewPage(
                                      isRawData: true,
                                      reason: "faq_new",
                                      appbarTitle: AppLocalizations.of(context)
                                          .translate(LanguageKeys.detailHelp),
                                      faqGetlistbyCategoryData: dataOfItem,
                                    ),
                                  ),
                                );
                              },
                              child: FaqCategoryGetlistItem(data: dataOfItem));
                        }),
                  ),
                ],
              ),
            ),
          ),
          if (model.loading || data == null)
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
    });
    //
  }
}
