import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/viewmodel/promo_viewmodel.dart';
import 'package:new_popbox/ui/item/banner_slider_item.dart';
import 'package:new_popbox/ui/item/shop_product_item.dart';
import 'package:new_popbox/ui/pages/popshop_cart_page.dart';
import 'package:new_popbox/ui/widget/app_widget.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class PopShopPage extends StatefulWidget {
  // const PopShopPage({Key key}) : super(key: key);

  @override
  _PopShopPageState createState() => _PopShopPageState();
}

class _PopShopPageState extends State<PopShopPage> {
  String _chosenValue;
  String searchHint = "";
  int _currentBannerSlider = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: AppBarViewWithIcon(
            title: AppLocalizations.of(context).translate(LanguageKeys.shop),
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: PopboxColor.mdBlack1000,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PopShopCart(),
                ),
              );
            },
          ),
        ),
        body: Column(
          children: [
            // headerCart(),
            filterProduct(),
            Expanded(
              child: ListView(
                children: [
                  carouselItemBanner(),
                  gridViewProduct(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget gridViewProduct() {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight + 10) / 2;
    final double itemWidth = size.width / 2;
    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 7.0),
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        childAspectRatio: (itemWidth / itemHeight),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        children: [
          ShopProductItem(),
          ShopProductItem(),
          ShopProductItem(),
          ShopProductItem(),
          ShopProductItem()
        ],
      ),
    );
    // return Align(alignment: Alignment.centerLeft, child: ShopProductItem());
  }

  Widget carouselItemBanner() {
    return Consumer<PromoViewModel>(builder: (context, model, _) {
      if (model.loading) return cartShimmerView(context);
      List<Widget> bannerWidget = [];
      if (model.promoList != null && model.promoList.length > 0) {
        for (var i = 0; i < model.promoList.length; i++) {
          bannerWidget.add(BannerSliderItem(
            promoData: model.promoList[i],
          ));
        }
      }

      return Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, left: 0.0, right: 0.0, bottom: 12.0),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 130.0,
                  enlargeCenterPage: true,
                  viewportFraction: 0.90,
                  aspectRatio: 2.0,
                  autoPlay: true,
                  autoPlayInterval: Duration(milliseconds: 3000),
                  disableCenter: true,
                  enableInfiniteScroll: false,
                  pageSnapping: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.scale,
                  initialPage: 0,
                  onPageChanged: (index, reason) {
                    if (mounted) {
                      setState(() {
                        _currentBannerSlider = index;
                      });
                    }
                  },
                ),
                items: bannerWidget,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: bannerWidget.map(
                (image) {
                  int index = bannerWidget.indexOf(image);
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 3.0),
                    child: Container(
                      width: _currentBannerSlider == index ? 20.0 : 8.0,
                      height: 8.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 2.0),
                      decoration: _currentBannerSlider == index
                          ? BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              shape: BoxShape.rectangle,
                              color: PopboxColor.popboxRed,
                            )
                          : BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              shape: BoxShape.rectangle,
                              color: PopboxColor.mdGrey500,
                            ),
                    ),
                  );
                },
              ).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget filterProduct() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Container Choose Mercant
          Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 25),
            child: CustomWidget().textBold(
              AppLocalizations.of(context)
                  .translate(LanguageKeys.chooseMerchant),
              PopboxColor.mdGrey900,
              9.0.sp,
              TextAlign.left,
            ),
          ),
          //Row Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 8.0),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    showListOfMerchant(context);
                  },
                  child: Container(
                    width: 77.0.w,
                    decoration: BoxDecoration(
                      color: PopboxColor.mdGrey200,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: Container(),
                      icon: Icon(Icons.keyboard_arrow_down),
                      value: _chosenValue,
                      items: <String>[]
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: CustomWidget().textBold(value,
                              PopboxColor.mdGrey900, 12.0.sp, TextAlign.left),
                        );
                      }).toList(),
                      hint: CustomWidget().textBold(
                          searchHint == ""
                              ? AppLocalizations.of(context)
                                  .translate(LanguageKeys.allMerchant)
                              : searchHint,
                          PopboxColor.mdGrey900,
                          12.0.sp,
                          TextAlign.left),
                      onChanged: (String value) {
                        if (mounted) {
                          setState(() {
                            _chosenValue = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                GestureDetector(
                  onTap: () {
                    showListOfFilter(context);
                  },
                  child: Container(
                      width: 12.0.w,
                      height: 47.0,
                      decoration: BoxDecoration(
                          color: PopboxColor.mdGrey200,
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                      child: Icon(Icons.filter_alt_outlined)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget headerCart() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: PopboxColor.mdWhite1000,
      flexibleSpace: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 12.0, right: 22.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        "assets/images/ic_back_black.png",
                        fit: BoxFit.none,
                      ),
                    ),
                    SizedBox(width: 30.0),
                    CustomWidget().textBold(
                      AppLocalizations.of(context).translate(LanguageKeys.shop),
                      PopboxColor.mdBlack1000,
                      13.0.sp,
                      TextAlign.center,
                    ),
                  ],
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PopShopCart(),
                        ),
                      );
                    },
                    child: Icon(Icons.shopping_cart_outlined)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showListOfMerchant(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.55,
            margin: EdgeInsets.only(bottom: 45),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Image.asset(
                            "assets/images/ic_close_icon.png",
                            height: 16.0,
                            width: 16.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 28.0),
                          child: CustomWidget().textBold(
                            'Mercant',
                            PopboxColor.mdBlack1000,
                            12.0.sp,
                            TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Divider(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 25.0),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: PopboxColor.mdGrey300),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.white,
                        ),
                        width: 100.0.w,
                        height: 70.0,
                        margin: EdgeInsets.only(
                            left: 20.0, right: 20.0, bottom: 10.0),
                        child: Container(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: CustomWidget().textBold(
                              'Semua Mercant',
                              PopboxColor.mdGrey900,
                              10.0.sp,
                              TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: ListView.builder(
                          // controller: scrollController,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 4,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: PopboxColor.mdGrey300),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.white,
                              ),
                              width: 100.0.w,
                              height: 70.0,
                              margin: EdgeInsets.only(
                                  left: 20.0, right: 20.0, bottom: 10.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    width: 33.0.w,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Image.asset(
                                        "assets/images/ic_shop_inerie.png",
                                        height: 25.0,
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                  ),
                                  CustomWidget().textBold(
                                    'Inerie',
                                    PopboxColor.mdGrey900,
                                    10.0.sp,
                                    TextAlign.left,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  //
  void showListOfFilter(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.40,
            margin: EdgeInsets.only(bottom: 45),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Image.asset(
                            "assets/images/ic_close_icon.png",
                            height: 16.0,
                            width: 16.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 28.0),
                          child: CustomWidget().textBold(
                            'Urutkan',
                            PopboxColor.mdBlack1000,
                            12.0.sp,
                            TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Divider(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        child: ListView.builder(
                          // controller: scrollController,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 4,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                Container(
                                  width: 100.0.w,
                                  height: 50.0,
                                  margin: EdgeInsets.only(
                                      left: 20.0, right: 20.0, bottom: 10.0),
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: CustomWidget().textRegular(
                                      'Harga Tertinggi',
                                      PopboxColor.mdGrey900,
                                      11.0.sp,
                                      TextAlign.left,
                                    ),
                                  ),
                                ),
                                Container(
                                    margin: EdgeInsets.only(
                                        left: 20.0, right: 20.0),
                                    child: Divider(
                                        color: Colors.grey, height: 1.0))
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }
}
