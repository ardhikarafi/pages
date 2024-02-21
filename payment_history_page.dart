import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/account_maps_data.dart';
import 'package:new_popbox/core/models/payload/address_user_update_payload.dart';
import 'package:new_popbox/core/utils/library.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/pages/account_maps_page.dart';
import 'package:new_popbox/ui/pages/success_new_page.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:sizer/sizer.dart';

import 'account_apartment_page.dart';

class PaymentHistory extends StatefulWidget {
  final bool isAddressFilled;
  final String type;

  const PaymentHistory({Key key, this.isAddressFilled = false, this.type})
      : super(key: key);
  @override
  State<PaymentHistory> createState() => _PaymentHistory();
}

class _PaymentHistory extends State<PaymentHistory> {
  //TypeHouse
  String typeHouse;

  TextEditingController administrativeAreaCtr = TextEditingController();
  TextEditingController subAdministrativeAreaCtr = TextEditingController();
  TextEditingController localityCtr = TextEditingController();
  TextEditingController subLocalityCtr = TextEditingController();
  TextEditingController postalCodeCtr = TextEditingController();
  //TypeApartement
  String apartmentUuid;
  TextEditingController nameApartCtr = TextEditingController();
  TextEditingController nameApartOthersCtr = TextEditingController();
  TextEditingController towerCtr = TextEditingController();
  TextEditingController floorCtr = TextEditingController();
  TextEditingController unitCtr = TextEditingController();
  TextEditingController buildTypeCtr = TextEditingController();

  AccountMapsData accountMapsData;
  bool isOther = false;
  SharedPreferencesService sharedPrefService;
  UserLoginData userData;
  String typeOfResidence = "";
  String countryCode = "";
  //InfoApart
  String nameOfApartment = "";
  String tower = "";
  String floor = "";
  String unit = "";
  //Inforumahtapak
  String province = "";
  String city = "";
  String district = "";
  String subDistrict = "";
  String zipCode = "";

  @override
  void initState() {
    super.initState();
  }

  List<String> dataList = [];

  @override
  Widget build(BuildContext context) {
    // dataList.add("one");
    // dataList.add("value");
    print("datalist: " + dataList.toString());
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: GeneralAppBarView(
            title: AppLocalizations.of(context)
                .translate(LanguageKeys.paymentHistory),
            isButtonBack: true,
          ),
        ),
        body: SafeArea(
            child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 1.0),
            Container(
                margin: const EdgeInsets.all(10.0),
                width: 110.0,
                decoration: BoxDecoration(
                  border: Border.all(color: PopboxColor.mdGrey350),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Wrap(
                  crossAxisAlignment:
                      WrapCrossAlignment.start, // Align children at the center
                  children: [
                    InkWell(
                      onTap: () async {
                        //await _showDateRangePicker(context);
                        await _selectDateRange(context);
                      },
                      child: Row(children: [
                        SizedBox(width: 10),
                        Container(
                          // width: MediaQuery.of(context).size.width * 0.5,
                          child: CustomWidget().textLightRoboto(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.filterDate),
                              Colors.grey,
                              12,
                              TextAlign.left),
                        ),
                        SizedBox(width: 5),
                        Container(
                            padding: EdgeInsets.all(8.0),
                            width: 30.0,
                            height: 30.0,
                            child: Image.asset("assets/images/calendar.png")),
                      ]),
                    ),
                  ],
                )),
            Container(
              width: double.infinity,
              height: 0.5,
              color: Colors.grey,
            ),
            SizedBox(height: 15.0),
            dataList != null && dataList.isEmpty
                ?
                //Empty data
                Center(
                    child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            padding: EdgeInsets.only(
                                left: 10.0,
                                top: 100.0,
                                right: 10.0,
                                bottom: 10.0),
                            child: Image.asset(
                                "assets/images/payment_history_not_found.png")),
                        SizedBox(height: 15.0),
                        CustomWidget().textBoldRoboto('Tidak ada transaksi',
                            Colors.black, 16, TextAlign.center),
                        SizedBox(height: 15.0),
                        CustomWidget().textLightRoboto(
                            'Transaksi yang anda cari tidak ditemukan',
                            Colors.black,
                            12,
                            TextAlign.center),
                      ],
                    ),
                  ))
                : Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //List of transaction history
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                    padding: EdgeInsets.all(5.0),
                                    width: 32.0,
                                    height: 32.0,
                                    child: Image.asset(
                                        "assets/images/rejected.png")),
                              ),
                              Expanded(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Container(
                                        // width: MediaQuery.of(context).size.width * 0.5,
                                        child: CustomWidget().textBoldRoboto(
                                            'TRX1293839391F',
                                            Colors.black,
                                            16,
                                            TextAlign.left),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Container(
                                        // width: MediaQuery.of(context).size.width * 0.5,
                                        child: CustomWidget().textLightRoboto(
                                            "Pembayaran PopCenter @ Mediterania Garden",
                                            Colors.black,
                                            12,
                                            TextAlign.left),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Container(
                                        // width: MediaQuery.of(context).size.width * 0.5,
                                        child: CustomWidget().textBoldRoboto(
                                            'GAGAL',
                                            Colors.grey,
                                            12,
                                            TextAlign.left),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Container(
                                        // width: MediaQuery.of(context).size.width * 0.5,
                                        child: CustomWidget().textLightRoboto(
                                            '2020-06-21 17:00:00',
                                            Colors.grey,
                                            12,
                                            TextAlign.left),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Container(
                                          // width: MediaQuery.of(context).size.width * 0.5,
                                          child: CustomWidget().textBoldRoboto(
                                              'Rp 20.000',
                                              Colors.black,
                                              12,
                                              TextAlign.left),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Container(
                                          // width: MediaQuery.of(context).size.width * 0.5,
                                          child: CustomWidget().textBoldRoboto(
                                              'DANA',
                                              Colors.grey,
                                              12,
                                              TextAlign.left),
                                        ),
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                          SizedBox(height: 15.0),
                          Container(
                            width: double.infinity,
                            height: 0.5,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 15.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                    padding: EdgeInsets.all(5.0),
                                    width: 32.0,
                                    height: 32.0,
                                    child: Image.asset(
                                        "assets/images/approved.png")),
                              ),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Container(
                                        // width: MediaQuery.of(context).size.width * 0.5,
                                        child: CustomWidget().textBoldRoboto(
                                            'TR423FF839391F',
                                            Colors.black,
                                            16,
                                            TextAlign.left),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Container(
                                        // width: MediaQuery.of(context).size.width * 0.5,
                                        child: CustomWidget().textLightRoboto(
                                            'PopSafe GBK Pintu Kuning',
                                            Colors.black,
                                            12,
                                            TextAlign.left),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Container(
                                        // width: MediaQuery.of(context).size.width * 0.5,
                                        child: CustomWidget().textBoldRoboto(
                                            'BERHASIL',
                                            Colors.grey,
                                            12,
                                            TextAlign.left),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Container(
                                        // width: MediaQuery.of(context).size.width * 0.5,
                                        child: CustomWidget().textLightRoboto(
                                            '2020-06-21 17:00:00',
                                            Colors.grey,
                                            12,
                                            TextAlign.left),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Container(
                                          // width: MediaQuery.of(context).size.width * 0.5,
                                          child: CustomWidget().textBoldRoboto(
                                              'Rp 22.000',
                                              Colors.black,
                                              12,
                                              TextAlign.left),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Container(
                                          // width: MediaQuery.of(context).size.width * 0.5,
                                          child: CustomWidget().textBoldRoboto(
                                              'DANA',
                                              Colors.grey,
                                              12,
                                              TextAlign.left),
                                        ),
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                          SizedBox(height: 15.0),
                          Container(
                            width: double.infinity,
                            height: 0.5,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 15.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                    padding: EdgeInsets.all(5.0),
                                    width: 32.0,
                                    height: 32.0,
                                    child: Image.asset(
                                        "assets/images/pending.png")),
                              ),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Container(
                                        // width: MediaQuery.of(context).size.width * 0.5,
                                        child: CustomWidget().textBoldRoboto(
                                            'TRX1BERAE23F',
                                            Colors.black,
                                            16,
                                            TextAlign.left),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Container(
                                        // width: MediaQuery.of(context).size.width * 0.5,
                                        child: CustomWidget().textLightRoboto(
                                            'PopSafe GBK Pintu Kuning',
                                            Colors.black,
                                            12,
                                            TextAlign.left),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Container(
                                        // width: MediaQuery.of(context).size.width * 0.5,
                                        child: CustomWidget().textBoldRoboto(
                                            'PENDING',
                                            Colors.grey,
                                            12,
                                            TextAlign.left),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Container(
                                        // width: MediaQuery.of(context).size.width * 0.5,
                                        child: CustomWidget().textLightRoboto(
                                            '2020-06-21 17:00:00',
                                            Colors.grey,
                                            12,
                                            TextAlign.left),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Container(
                                          // width: MediaQuery.of(context).size.width * 0.5,
                                          child: CustomWidget().textBoldRoboto(
                                              'Rp 18.000',
                                              Colors.black,
                                              12,
                                              TextAlign.left),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Container(
                                          // width: MediaQuery.of(context).size.width * 0.5,
                                          child: CustomWidget().textBoldRoboto(
                                              'GOPAY',
                                              Colors.grey,
                                              12,
                                              TextAlign.left),
                                        ),
                                      ),
                                    ],
                                  ))
                            ],
                          )
                        ]))
          ],
        )));
  }

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (picked != null && picked.start != null && picked.end != null) {
      print('Selected date range: ${picked.start} - ${picked.end}');
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    DateTimeRange picked = await showDateRangePicker(
      context: context,
      //initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    Navigator.of(context).pop(picked);
    if (picked != null) {
      Navigator.of(context).pop(picked);
      print('Selected date range: ${picked.start} - ${picked.end}');
    }
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    DateTimeRange selectedDateRange = await showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 400.0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Select Date Range',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    DateTimeRange picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(DateTime.now().year - 1),
                      lastDate: DateTime(DateTime.now().year + 1),
                    );

                    if (picked != null) {
                      print(
                          'Selected date range: ${picked.start} - ${picked.end}');
                      Navigator.of(context).pop(
                          picked); // Close the modal sheet after selecting a date range
                    }
                  },
                  child: Text('Pick a date range'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedDateRange != null) {
      // Handle the selected date range
    }
  }
}
