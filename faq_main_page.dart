import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/help_center/faq/faq_category_data.dart';
import 'package:new_popbox/core/models/payload/faq_category_payload.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/faq_viewmodel.dart';
import 'package:new_popbox/ui/item/faq_category_item.dart';
import 'package:new_popbox/ui/pages/faq_child_of_category_page.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class FaqMainPage extends StatefulWidget {
  const FaqMainPage({Key key}) : super(key: key);

  @override
  _FaqMainPageState createState() => _FaqMainPageState();
}

class _FaqMainPageState extends State<FaqMainPage> {
  int indexOfCategory = 0;
  Color colorOfIndex;
  List<FaqCategoryData> faqlistofCategory;
  int countOfList = 0;

  @override
  void initState() {
    var faqcategoryModel = Provider.of<FaqViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferencesService prefs = await SharedPreferencesService.instance;
      FaqCategoryPayload faqCategoryPayload = new FaqCategoryPayload();
      faqCategoryPayload.token = GlobalVar.API_TOKEN;
      faqCategoryPayload.country = prefs.locationSelected;
      faqCategoryPayload.lang = "";
      faqCategoryPayload.type = "faq";
      faqCategoryPayload.version = "";
      await faqcategoryModel.faqListofCategory(faqCategoryPayload, context,
          onSuccess: (response) {
        faqlistofCategory = response.data;
        countOfList = response.data.length;
      }, onError: (response) {});
    });
    super.initState();
  }

  //
  @override
  Widget build(BuildContext context) {
    return Consumer<FaqViewModel>(builder: (context, model, _) {
      return Stack(
        children: [
          Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(60.0),
              child: DetailAppBarView(
                title:
                    AppLocalizations.of(context).translate(LanguageKeys.help),
              ),
            ),
            body: SafeArea(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  SizedBox(height: 20.0),
                  //FAQ CATEGORY
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: countOfList,
                        itemBuilder: (context, index) {
                          indexOfCategory = index;
                          if (indexOfCategory % 4 == 0) {
                            colorOfIndex = PopboxColor.redFF000080;
                          } else if (indexOfCategory % 3 == 0) {
                            colorOfIndex = PopboxColor.yellowF9C88080;
                          } else if (indexOfCategory % 2 == 0) {
                            colorOfIndex = PopboxColor.blue79ACF9;
                          } else {
                            colorOfIndex = PopboxColor.blue80F9D4;
                          }

                          FaqCategoryData data = faqlistofCategory[index];
                          return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => FaqChildOfCategoryPage(
                                      faqCategoryData: data),
                                ));
                              },
                              child: FaqCategoryItem(
                                faqCategoryData: data,
                                colorofIndex: colorOfIndex,
                              ));
                        }),
                  ),
                  // Container(
                  //   margin: EdgeInsets.only(left: 20.0, right: 20.0),
                  //   decoration: BoxDecoration(
                  //     color: PopboxColor.mdBlue60,
                  //     borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Container(
                  //         height: 50.0,
                  //         width: 10.0,
                  //         decoration: BoxDecoration(
                  //           color: Colors.blue,
                  //           borderRadius: BorderRadius.only(
                  //             topLeft: Radius.circular(10.0),
                  //             bottomLeft: Radius.circular(10.0),
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(width: 5.0),
                  //       CustomWidget().textBold(
                  //         "Sering Ditanyakan",
                  //         PopboxColor.mdBlack1000,
                  //         10.0.sp,
                  //         TextAlign.left,
                  //       ),
                  //       Spacer(),
                  //       Icon(
                  //         Icons.arrow_forward_ios_rounded,
                  //         color: Colors.black,
                  //         size: 15,
                  //       ),
                  //       SizedBox(width: 10.0)
                  //     ],
                  //   ),
                  // )
                ])),
          ),
          if (model.loading || faqlistofCategory == null)
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
  }
}
