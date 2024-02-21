import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/utils/hex_color.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/ui/widget/appbar.dart';

class LockerSize extends StatefulWidget {
  final List lockerSizeList;

  const LockerSize({Key key, @required this.lockerSizeList}) : super(key: key);
  @override
  _LockerSizeState createState() => _LockerSizeState();
}

class _LockerSizeState extends State<LockerSize> {
  // List<String> result = widget.lockerSizeList.toList();
  List<String> lockerSize = [
    'Ukuran XS',
    'Ukuran S',
    'Ukuran M',
    'Ukuran L',
    'Ukuran XL'
  ];
  List<String> detailLockerSize = [
    '',
    'untuk laptop',
    'untuk sepatu, tas jinjing',
    'untuk tas backpack',
    'untuk XL'
  ];
  List<String> imageLockerSize = [
    'assets/images/ic_lockersize_small.png',
    'assets/images/ic_lockersize_small.png',
    'assets/images/ic_lockersize_medium.png',
    'assets/images/ic_lockersize_large.png',
    'assets/images/ic_lockersize_large.png',
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: DetailAppBarView(
          title:
              AppLocalizations.of(context).translate(LanguageKeys.lockerSize),
        ),
      ),
      body: SafeArea(
          child: ListView.builder(
        itemCount: widget.lockerSizeList.length,
        itemBuilder: (context, index) => (widget.lockerSizeList[index] == 'XS')
            ? Container()
            : Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 15),
                width: 372,
                height: 107,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: HexColor('#D8D8D8'),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context, widget.lockerSizeList[index]);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Text(widget.lockerSizeList.toString()),
                      Container(
                        margin: EdgeInsets.only(top: 33, left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ukuran " + widget.lockerSizeList[index],
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            (widget.lockerSizeList[index] == 'S')
                                ? Text(
                                    detailLockerSize[1],
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                  )
                                : (widget.lockerSizeList[index] == 'M')
                                    ? Text(
                                        detailLockerSize[2],
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                        ),
                                      )
                                    : (widget.lockerSizeList[index] == 'L')
                                        ? Text(
                                            detailLockerSize[3],
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                            ),
                                          )
                                        : (widget.lockerSizeList[index] == 'XL')
                                            ? Text(
                                                detailLockerSize[4],
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12,
                                                ),
                                              )
                                            : SnackBar(
                                                content: Text('Tidak Tersedia'),
                                              )
                          ],
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        margin: EdgeInsets.only(right: 26),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: (widget.lockerSizeList[index] == 'S')
                                  ? AssetImage(imageLockerSize[1])
                                  : (widget.lockerSizeList[index] == 'M')
                                      ? AssetImage(imageLockerSize[2])
                                      : (widget.lockerSizeList[index] == 'L')
                                          ? AssetImage(imageLockerSize[3])
                                          : (widget.lockerSizeList[index] ==
                                                  'XL')
                                              ? AssetImage(imageLockerSize[4])
                                              :
                                              //Image IF Null
                                              AssetImage(imageLockerSize[3])),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      )),
    );
  }
}
