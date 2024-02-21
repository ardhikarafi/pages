import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/popshop_product.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/ui/item/popshop_product_item.dart';
import 'package:new_popbox/ui/widget/appbar.dart';

class PopShopCart extends StatefulWidget {
  @override
  _PopShopCartState createState() => _PopShopCartState();
}

class _PopShopCartState extends State<PopShopCart> {
  List<Product> listOfPopFresh;
  List<Product> listOfIneere;
  List<PopshopProduct> products;
  @override
  void initState() {
    listOfPopFresh = [
      Product('SayurTest', 2000, 1, 'Gambar'),
      Product('Tomat', 3000, 2, 'Gambar'),
    ];
    listOfIneere = [
      Product('IneSayur', 2000, 1, 'Gambar'),
      Product('IneTomat', 3000, 2, 'Gambar'),
      Product('IneCabe', 3500, 2, 'Gambar'),
    ];
    products = [
      PopshopProduct(
        categoryName: 'PopFresh',
        products: listOfPopFresh,
      ),
      PopshopProduct(
        categoryName: 'Ineere',
        products: listOfIneere,
      ),
      PopshopProduct(
        categoryName: 'PopFresh',
        products: listOfPopFresh,
      ),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: DetailAppBarView(
            title: AppLocalizations.of(context).translate(LanguageKeys.deposit),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 15.0),
              Expanded(child: buildListViewShop),
            ],
          ),
        ));
  }

  ListView get buildListViewShop {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return PopShopProductItem(
          model: products[index],
          index: index,
        );
      },
    );
  }
}
