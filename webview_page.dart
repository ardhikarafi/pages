import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/help_center/faq/faq_getlist_bycategory_data.dart';
import 'package:new_popbox/core/models/callback/popsafe/popsafe_history_detail_data.dart';
import 'package:new_popbox/core/models/callback/promo/promo_data.dart';
import 'package:new_popbox/core/models/payload/popsafe_history_detail_payload.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/faq_viewmodel.dart';
import 'package:new_popbox/core/viewmodel/help_center_raw_viewmodel.dart';
import 'package:new_popbox/core/viewmodel/popsafe_viewmodel.dart';
import 'package:new_popbox/ui/widget/app_widget.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class WebviewPage extends StatefulWidget {
  final String reason;
  final String appbarTitle;
  final String urlMicrosite;
  final bool isRawData;
  final String invoiceId;
  final PromoData promoData;
  final FaqGetlistbyCategoryData faqGetlistbyCategoryData;

  const WebviewPage(
      {this.reason,
      this.appbarTitle,
      this.urlMicrosite,
      this.isRawData = false,
      this.invoiceId = "",
      this.promoData,
      this.faqGetlistbyCategoryData});
  @override
  _WebviewPageState createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  String url = "";
  String rawData = "";
  // String rawData =
  //     """<h2 style=\"font-family: Rubik, sans-serif; color: rgb(0, 0, 0);\"><span style=\"font-family: &quot;Lucida Grande&quot;;\">Apa itu PopSafe?</span></h2><p><span style=\"font-family: &quot;Lucida Grande&quot;;\">PopSafe: layanan yang memberikan kemudahan untuk menyimpan barang bawaan di loker PopBox dengan aman</span></p><p><span style=\"font-size: 0.875rem; font-family: &quot;Lucida Grande&quot;;\"><span style=\"font-weight: bolder;\">Durasi Waktu:</span></span></p><ul><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Batas waktu penyimpanan adalah 24 jam sejak order dibuat di aplikasi</span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Oleh karena itu kami sarankan order dibuat ketika posisi kita sedang dekat dengan area loker, karena waktu berjalan setelah order tersebut dibuat (jika membuat order dari aplikasi)</span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Order dapat dibatalkan jika belum digunakan untuk meletakkan barang maksimal sampai&nbsp;</span><span style=\"font-weight: bolder;\"><span style=\"font-family: &quot;Lucida Grande&quot;;\">1 jam dari order dibuat</span></span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Jika dibatalkan maka dana akan otomatis kembali ke saldo, tapi jika order menggunakan promo maka promo sudah berkurang kuota pemakaiannya</span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Jika order belim diambil lebih dari 24 jam maka dapat dilakukan perpanjangan lewat aplikasi, dengan tarif normal Rp6.000 (pastikan saldo tersedia)</span></li></ul><p><span style=\"font-weight: bolder;\"><span style=\"font-family: &quot;Lucida Grande&quot;;\">Pilihan pembayaran:</span></span></p><ul><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Saat ini pembayaran hanya dapat dilakukan dengan saldo PopBox.</span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Kamu juga bisa menggunakan kode promo untuk membuat order</span></li></ul><p><span style=\"font-weight: bolder;\"><span style=\"font-family: &quot;Lucida Grande&quot;;\">Cara membuat order dari aplikasi:</span></span></p><ol><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Pilih menu TITIP dan pilih lokasi loker tempat kamu akan menitipkan barang.</span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Pilih ukuran pintu loker</span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Tulis deskripsi barang yang kamu simpan</span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Jika kamu memiliki kode promo masukkan kode promo</span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Dan klik tombil \"Bayar Sekarang\"</span></li></ol><p><span style=\"font-weight: bolder;\"><span style=\"font-family: &quot;Lucida Grande&quot;;\">Cara menitipkan barang di loker</span></span></p><ol><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Datang ke loker yang kamu pilih, lokasi loker harus sama dengan di aplikasi</span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Pilih menu \"KIRIM &amp; TITIP\"</span></li><li><span style=\"font-size: 0.875rem; font-family: &quot;Lucida Grande&quot;;\">Pilih menu \"Titip Barang (PopSafe)\"</span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Arahkan kode QR ke barcode scanner atau masukkan nomor order manual</span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Pintu terbuka masukkan paket dan tutup kembali</span></li></ol><p><span style=\"font-weight: bolder;\"><span style=\"font-family: &quot;Lucida Grande&quot;;\">Cara mengambil barang di loker</span></span></p><ol><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Datang ke loker tempat kamu menitipkan barang</span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Pilih menu ambil</span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Arahkan QR pada barcode scanner loker atau input manual kode ambil</span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Ambil dan tutup pintu kembali</span></li></ol><p><span style=\"font-weight: bolder;\"><span style=\"font-family: &quot;Lucida Grande&quot;;\">Cara melakukan perpanjangan order</span></span></p><ol><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Masuk ke menu transaksi TITIP dan pilih order yang kamu ingin perpanjang</span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Klik tombol \"Perpanjangan Order\"</span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Pilih metode pembayaran yang kamu ingin gunakan</span></li><li><span style=\"font-family: &quot;Lucida Grande&quot;;\">Lakukan pembayaran, jika menggunakan saldo PopBox perpanjangan adalah setiap 1x 24 jam, jika lebih dari 24 jam kamu harus melakukan beberapa kali perpanjanga</span></li></ol>""";
  PopsafeHistoryDetailData popsafeDataDetail;

  @override
  void initState() {
    super.initState();
    String selectedCountry = "";
    String selectedLanguage = "";
    //VIEW MODEL
    var popsafeModel = Provider.of<PopsafeViewModel>(context, listen: false);
    var faqViewModel = Provider.of<FaqViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        //popsafe
        PopsafeHistoryDetailPayload historyDetailPayload =
            new PopsafeHistoryDetailPayload()
              ..sessionId = SharedPreferencesService().user.sessionId
              ..token = GlobalVar.API_TOKEN
              ..invoiceId = widget.invoiceId;

        await popsafeModel.popsafeHistoryDetail(
          historyDetailPayload,
          context,
          onSuccess: (response) {
            setState(() {
              try {
                popsafeDataDetail = response.data.first;
              } catch (e) {}
            });
          },
          onError: (response) {},
        );
        //Faq Get List by Category Child RawData
        if (widget.reason == "faq_new") {
          await faqViewModel.faqGetListbyCategoryChildRawdata(
              widget.faqGetlistbyCategoryData.urlRawData, context,
              onSuccess: (response) {
            rawData = response.data.description;
          }, onError: (response) {});
        }
      },
    );

    try {
      selectedCountry = SharedPreferencesService().user.country.toUpperCase();
      selectedLanguage = SharedPreferencesService().languageCode.toUpperCase();
    } catch (e) {}

    if (selectedCountry == null || selectedCountry == "") {
      try {
        selectedCountry =
            SharedPreferencesService().locationSelected.toUpperCase();
      } catch (e) {}
    }
    if (selectedLanguage == null || selectedLanguage == "") {
      try {
        selectedLanguage =
            SharedPreferencesService().languageCode.toUpperCase();
      } catch (e) {}
    }

    if (widget.reason == "faq") {
      if (selectedCountry == "ID" && selectedLanguage == "EN") {
        url = GlobalVar.FAQ_URL_ID_EN;
      } else if (selectedCountry == "ID") {
        url = GlobalVar.FAQ_URL_ID;
      } else if (selectedCountry == "MY") {
        url = GlobalVar.FAQ_URL_MY;
      } else if (selectedCountry == "PH") {
        url = GlobalVar.FAQ_URL_PH;
      }
    } else if (widget.reason == "popsafe") {
      if (selectedCountry == "ID" && selectedLanguage == "EN") {
        url = GlobalVar.HOW_TO_POPSAFE_ID_EN;
      } else if (selectedCountry == "ID") {
        url = GlobalVar.HOW_TO_POPSAFE_ID;
      } else if (selectedCountry == "MY") {
        url = GlobalVar.HOW_TO_POPSAFE_MY;
      } else if (selectedCountry == "PH") {
        url = GlobalVar.HOW_TO_POPSAFE_PH;
      }
    } else if (widget.reason == "parcel") {
      if (selectedCountry == "ID" && selectedLanguage == "EN") {
        url = GlobalVar.HOW_TO_PARCEL_ID_EN;
      } else if (selectedCountry == "ID") {
        url = GlobalVar.HOW_TO_PARCEL_ID;
      } else if (selectedCountry == "MY") {
        url = GlobalVar.HOW_TO_PARCEL_MY;
      } else if (selectedCountry == "PH") {
        url = GlobalVar.HOW_TO_PARCEL_PH;
      }
    } else if (widget.reason == "popsend") {
      if (selectedCountry == "ID") {
        url = GlobalVar.HOW_TO_POPSEND_ID;
      } else {}
    } else if (widget.reason == "tnc") {
      if (selectedCountry == "ID" && selectedLanguage == "EN") {
        url = GlobalVar.TNC_ID_EN;
      } else if (selectedCountry == "ID") {
        url = GlobalVar.TNC_ID;
      } else if (selectedCountry == "MY") {
        url = GlobalVar.TNC_MY;
      } else if (selectedCountry == "PH") {
        url = GlobalVar.TNC_PH;
      }
    } else if (widget.reason == "info_popsafe") {
      if (selectedCountry == "ID" && selectedLanguage == "EN") {
        url = GlobalVar.INFO_POPSAFE_ID_EN;
      } else if (selectedCountry == "ID") {
        url = GlobalVar.INFO_POPSAFE_ID;
      } else if (selectedCountry == "MY") {
        url = GlobalVar.INFO_POPSAFE_MY;
      } else if (selectedCountry == "PH") {
        url = GlobalVar.INFO_POPSAFE_PH;
      }
    } else if (widget.reason == "tnc_popsafe") {
      if (selectedCountry == "ID" && selectedLanguage == "EN") {
        url = GlobalVar.POPSAFE_TNC_ID_EN;
      } else if (selectedCountry == "ID") {
        url = GlobalVar.POPSAFE_TNC_ID;
      } else if (selectedCountry == "MY") {
        url = GlobalVar.POPSAFE_TNC_MY;
      } else if (selectedCountry == "PH") {
        url = GlobalVar.POPSAFE_TNC_PH;
      }
    } else if (widget.reason == "microsite") {
      url = widget.urlMicrosite;
    } else if (widget.reason == "banner") {
      rawData = widget.promoData.content;
    } else {}

    //print('widget.reason : ' + widget.reason);
    // print('url : ' + url);
    //print('selectedCountry : ' + selectedCountry);
    // print("Country => " + selectedCountry);
    // print("Language =>" + selectedLanguage);
    var helpCenter =
        Provider.of<HelpCenterRawViewmodel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await helpCenter.helpCenterRawData(
        url,
        context,
        onSuccess: (response) {
          setState(() {
            rawData = response.data.description;
          });
        },
        onError: (response) {},
      );

      final flutterWebviewPlugin = new FlutterWebviewPlugin();

      flutterWebviewPlugin.onUrlChanged.listen((String url) {
        if (url.contains('gojek://')) {
          flutterWebviewPlugin.close();
          flutterWebviewPlugin.hide();
          Navigator.pop(context);
          launch(url);
          // launch(url).then((value) =>
          //     Navigator.of(this.context).pushReplacement(MaterialPageRoute(
          //       builder: (context) => TransactionDetailPage(
          //         transactionType: 'popsafe_success',
          //         popsafeHistoryDetailData: popsafeDataDetail,
          //       ),
          //     )));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isRawData == true
        ? Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(60.0),
              child: DetailAppBarView(
                title: widget.appbarTitle,
              ),
            ),
            body: Consumer<HelpCenterRawViewmodel>(
              builder: (context, model, _) {
                if (model.loading) return cartShimmerView(context);

                return Container(
                  color: PopboxColor.mdWhite1000,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (widget.reason == "banner")
                            ? Image.network(widget.promoData.image)
                            : Container(),
                        (widget.reason == "banner")
                            ? Container(
                                margin: EdgeInsets.only(left: 8.0, top: 12.0),
                                child: CustomWidget().textBold(
                                    widget.promoData.title,
                                    PopboxColor.mdBlack1000,
                                    18.0,
                                    TextAlign.left),
                              )
                            : (widget.reason == "faq_new")
                                ? Container(
                                    padding: EdgeInsets.only(
                                        left: 10.0, right: 10.0, top: 26.0),
                                    child: CustomWidget().textBold(
                                        widget.faqGetlistbyCategoryData.title,
                                        PopboxColor.mdBlack1000,
                                        15.0,
                                        TextAlign.left),
                                  )
                                : Container(),
                        Html(
                          data: rawData,
                          onLinkTap: (String url) {
                            canLaunch(url)
                                .then((val) => val ? launch(url) : null);
                          },
                        )
                      ],
                    ),
                  ),
                );
              },
            ))
        : url.contains("gojek://")
            ? Container()
            : WebviewScaffold(
                url: url,
                allowFileURLs: true,
                enableAppScheme: true,
                withJavascript: true,
                hidden: true,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(60.0),
                  child: WebviewAppBarView(
                    title: widget.appbarTitle,
                  ),
                ),
              );

    // return rawData != ""
    //     ? SingleChildScrollView(
    //         child: Html(
    //           data: rawData,
    //         ),
    //       )
    //     : WebviewScaffold(
    //         url: url,
    //         hidden: true,
    //         appBar: PreferredSize(
    //           preferredSize: Size.fromHeight(60.0),
    //           child: WebviewAppBarView(
    //             title: widget.appbarTitle,
    //           ),
    //         ),
    //       );
  }
}
