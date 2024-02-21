import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:new_popbox/core/app_config.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/country.dart';
import 'package:new_popbox/core/service/app_language.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/utils/static_data.dart';
import 'package:new_popbox/ui/pages/onboarding_page.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class LanguagePage extends StatefulWidget {
  final String reason;

  const LanguagePage({Key key, @required this.reason}) : super(key: key);
  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  SharedPreferencesService sharedPrefService;
  static RemoteConfig _remoteConfig;
  bool pbV3ShowPh = false;
  bool myV3ShowPopsafeVersion = false;
  List<Country> languageForCountry = [];
  String selectedCountry = "";
  int checkedIndexOfCountry = -1;
  int checkedIndexOfLanguage = -1;
  bool countryCheck = false;
  bool languageCheck = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      sharedPrefService = await SharedPreferencesService.instance;
    });

    super.initState();
    _initializeRemoteConfig();
  }

  _initializeRemoteConfig() async {
    if (_remoteConfig == null) {
      _remoteConfig = await RemoteConfig.instance;

      final Map<String, dynamic> defaults = <String, dynamic>{
        'pb_v3_show_ph': false,
        'pb_v3_show_ph_version': "1",
        'my_v3_show_popsafe_version': "1",
      };
      await _remoteConfig.setDefaults(defaults);

      _remoteConfig.setConfigSettings(RemoteConfigSettings(
        minimumFetchIntervalMillis: 1,
        fetchTimeoutMillis: 1,
      ));

      await _fetchRemoteConfig();
    }

    setState(() {
      //_isLoading = false;
    });
  }

  Future<void> _fetchRemoteConfig() async {
    try {
      await _remoteConfig.fetch(expiration: const Duration(minutes: 1));
      await _remoteConfig.activateFetched();

      //print('Last fetch status: ' + _remoteConfig.lastFetchStatus.toString());
      //print('Last fetch time: ' + _remoteConfig.lastFetchTime.toString());
      //print('pb_v3_show_ph: ' +
      //_remoteConfig.getBool('pb_v3_show_ph').toString());

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      String code = packageInfo.buildNumber;

      if (mounted) {
        setState(() {
          if (flavor == "development") {
            pbV3ShowPh = _remoteConfig.getBool('pb_v3_show_ph');
          } else {
            if (code == _remoteConfig.getString('pb_v3_show_ph_version')) {
              pbV3ShowPh = true;
            }
          }

          if (flavor == "development" &&
              code == _remoteConfig.getString('pb_v3_show_ph_version_dev')) {
            myV3ShowPopsafeVersion = true;
          } else if (flavor == "production" &&
              code == _remoteConfig.getString('pb_v3_show_ph_version')) {
            myV3ShowPopsafeVersion = true;
          }

          SharedPreferencesService()
              .setIsmyV3ShowPopsafeVersion(myV3ShowPopsafeVersion);
        });
      }

      //print("version : " + version);
      //print("code : " + code);
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: PopboxColor.mdWhite1000,
        statusBarIconBrightness: Brightness.dark));
    var appLanguage = Provider.of<AppLanguage>(context);

    if (SharedPreferencesService().locationSelected == null) {
      //String locale = Intl.systemLocale;
      final locale = Platform.localeName;
      // print("language page object locale :" + locale);

      if (locale == "en_US") {
        appLanguage.changeLanguage(Locale("en"));
        sharedPrefService.setLanguageCode("en");
      } else if (locale == "id_ID") {
        appLanguage.changeLanguage(Locale("id"));
        sharedPrefService.setLanguageCode("id");
      } else if (locale == "ms_MY") {
        appLanguage.changeLanguage(Locale("my"));
        sharedPrefService.setLanguageCode("my");
      } else {
        appLanguage.changeLanguage(Locale("en"));
        sharedPrefService.setLanguageCode("en");
      }
    }

    if (widget.reason == "language") {
      String prevLanguage = appLanguage.appLocal.languageCode;

      if (prevLanguage == "id") {
        prevLanguage = "indonesian";
      } else if (prevLanguage == "en") {
        prevLanguage = "english";
      } else if (prevLanguage == "my") {
        prevLanguage = "malaysia";
      }

      for (var i = 0; i < StaticData().getLanguage(context).length; i++) {
        Country country = StaticData().getLanguage(context)[i];
        if (country.code == prevLanguage) {
          checkedIndexOfLanguage = i;
        }
      }
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: widget.reason == "language"
            ? DetailAppBarView(
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.chooselanguage),
              )
            : Container(
                color: PopboxColor.mdWhite1000,
              ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.reason == "location"
                      ? Container(
                          margin: const EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 15.0),
                          child: CustomWidget().textRegular(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.selectLocation),
                            PopboxColor.mdBlack1000,
                            14,
                            TextAlign.left,
                          ),
                        )
                      : SizedBox(height: 15.0),
                  widget.reason == "location"
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: widget.reason == "language"
                              ? StaticData().getLanguage(context).length
                              : StaticData().getCountry(pbV3ShowPh).length,
                          itemBuilder: (BuildContext context, int index) {
                            Country language = widget.reason == "language"
                                ? StaticData().getLanguage(context)[index]
                                : StaticData().getCountry(pbV3ShowPh)[index];

                            return countryItem(index, language, appLanguage);
                          },
                        )
                      : Container(),
                  widget.reason == "location" && languageForCountry.isNotEmpty
                      ? Container(
                          margin: const EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 15.0, top: 20.0),
                          child: CustomWidget().textBold(
                            AppLocalizations.of(context)
                                .translate(LanguageKeys.selectLanguage),
                            PopboxColor.mdBlack1000,
                            14,
                            TextAlign.left,
                          ),
                        )
                      : Container(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: widget.reason == "language"
                        ? StaticData().getLanguage(context).length
                        : languageForCountry.length,
                    itemBuilder: (BuildContext context, int index) {
                      Country language = widget.reason == "language"
                          ? StaticData().getLanguage(context)[index]
                          : languageForCountry[index];

                      return languageItem(index, language, appLanguage);
                    },
                  ),
                ],
              ),
            ),
          ),
          (widget.reason == "location" && languageCheck && countryCheck)
              ? Container(
                  margin: const EdgeInsets.only(
                      left: 20.0, right: 20.0, bottom: 20.0),
                  child: CustomButtonRectangle(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => OnboardingPage(),
                        ),
                      );
                    },
                    title: AppLocalizations.of(context)
                        .translate(LanguageKeys.next),
                    bgColor: PopboxColor.popboxRed,
                    textColor: PopboxColor.mdWhite1000,
                    fontSize: 12.0.sp,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget languageItem(int index, Country language, var appLanguage) {
    bool checked = index == checkedIndexOfLanguage;
    return GestureDetector(
      onTap: () {
        setState(() {
          checkedIndexOfLanguage = index;
          languageCheck = true;
          if (widget.reason == "language") {
            if (checkedIndexOfLanguage == 0) {
              if (language.code == "indonesian") {
                appLanguage.changeLanguage(Locale("id"));
                sharedPrefService.setLanguageCode("id");
              } else if (language.code == "malaysia") {
                appLanguage.changeLanguage(Locale("en"));
                sharedPrefService.setLanguageCode("en");
              } else {
                appLanguage.changeLanguage(Locale("en"));
                sharedPrefService.setLanguageCode("en");
              }
            } else if (checkedIndexOfLanguage == 1) {
              if (language.code == "indonesian") {
                appLanguage.changeLanguage(Locale("id"));
                sharedPrefService.setLanguageCode("id");
              } else if (language.code == "malaysia") {
                appLanguage.changeLanguage(Locale("en"));
                sharedPrefService.setLanguageCode("en");
              } else {
                appLanguage.changeLanguage(Locale("en"));
                sharedPrefService.setLanguageCode("en");
              }
            } else {
              appLanguage.changeLanguage(Locale("en"));
              sharedPrefService.setLanguageCode("en");
            }
          }
          if (widget.reason == "location") {
            if (checkedIndexOfLanguage == 0) {
              appLanguage.changeLanguage(Locale("en"));
              sharedPrefService.setLanguageCode("en");
            } else if (checkedIndexOfLanguage == 1) {
              if (language.code == "indonesian") {
                appLanguage.changeLanguage(Locale("id"));
                sharedPrefService.setLanguageCode("id");
              } else if (language.code == "malaysia") {
                appLanguage.changeLanguage(Locale("my"));
                sharedPrefService.setLanguageCode("my");
              } else {
                appLanguage.changeLanguage(Locale("en"));
                sharedPrefService.setLanguageCode("en");
              }
            } else {
              appLanguage.changeLanguage(Locale("en"));
              sharedPrefService.setLanguageCode("en");
            }
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 4.0, bottom: 8.0),
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        language.icon != ""
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    32.0, 18.0, 0.0, 18.0),
                                child: Image.asset(
                                  language.icon,
                                  fit: BoxFit.fitHeight,
                                ),
                              )
                            : Container(),
                        language.icon != ""
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    32.0, 0.0, 0.0, 0.0),
                                child: CustomWidget().textRegular(
                                  language.language,
                                  PopboxColor.mdBlack1000,
                                  14,
                                  TextAlign.left,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16.0, 24.0, 0.0, 24.0),
                                child: CustomWidget().textRegular(
                                  language.language,
                                  PopboxColor.mdBlack1000,
                                  14,
                                  TextAlign.left,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
                checked
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check,
                                    color: Colors.white, size: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
          ],
        ),
        decoration: BoxDecoration(
            border: Border.all(color: PopboxColor.mdGrey50),
            color: PopboxColor.mdWhite1000,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  // color: Colors.black12,
                  // offset: Offset(5, 5),
                  // blurRadius: 10,
                  )
            ]),
      ),
    );
  }

  Widget countryItem(int index, Country language, var appLanguage) {
    bool checked = index == checkedIndexOfCountry;
    return GestureDetector(
      onTap: () {
        setState(() {
          checkedIndexOfCountry = index;
          countryCheck = true;
          if (widget.reason == "language") {
            if (checkedIndexOfCountry == 0) {
              appLanguage.changeLanguage(Locale("id"));
              sharedPrefService.setLanguageCode("id");
            } else if (checkedIndexOfCountry == 1) {
              appLanguage.changeLanguage(Locale("my"));
              sharedPrefService.setLanguageCode("my");
            } else {
              appLanguage.changeLanguage(Locale("en"));
              sharedPrefService.setLanguageCode("en");
            }
          }

          if (widget.reason == "location") {
            if (checkedIndexOfCountry == 0) {
              sharedPrefService.setLocationSelected("ID");
              sharedPrefService.setPhoneCode("62");
              setEnvironment(Environment.id);
              // sharedPrefService.setExistingLoginCountry("ID");

              languageForCountry.clear();
              languageForCountry.add(
                new Country.initData(
                  1,
                  AppLocalizations.of(context).translate(LanguageKeys.english),
                  "english",
                  "",
                ),
              );
              languageForCountry.add(
                new Country.initData(
                  2,
                  AppLocalizations.of(context)
                      .translate(LanguageKeys.indonesian),
                  "indonesian",
                  "",
                ),
              );
            } else if (checkedIndexOfCountry == 1) {
              sharedPrefService.setLocationSelected("MY");
              sharedPrefService.setPhoneCode("60");
              // sharedPrefService.setExistingLoginCountry("MY");
              setEnvironment(Environment.my);

              languageForCountry.clear();
              languageForCountry.add(
                new Country.initData(
                  1,
                  AppLocalizations.of(context).translate(LanguageKeys.english),
                  "english",
                  "",
                ),
              );
            } else if (checkedIndexOfCountry == 2) {
              sharedPrefService.setLocationSelected("PH");
              sharedPrefService.setPhoneCode("63");
              setEnvironment(Environment.ph);
            }
            print("languageForCountry LENGTH" +
                languageForCountry.length.toString());
          }
        });
      },
      child: Container(
        height: 80,
        margin: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 4.0, bottom: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        language.icon != ""
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    32.0, 18.0, 0.0, 18.0),
                                child: SvgPicture.asset(
                                  language.icon,
                                  width: 20.0,
                                  fit: BoxFit.fitWidth,
                                ),
                              )
                            : Container(),
                        language.icon != ""
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    32.0, 0.0, 0.0, 0.0),
                                child: CustomWidget().textRegular(
                                  language.language,
                                  PopboxColor.mdBlack1000,
                                  14,
                                  TextAlign.left,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16.0, 24.0, 0.0, 24.0),
                                child: CustomWidget().textRegular(
                                  language.language,
                                  PopboxColor.mdBlack1000,
                                  14,
                                  TextAlign.left,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
                checked
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check,
                                    color: Colors.white, size: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
          ],
        ),
        decoration: BoxDecoration(
          border: Border.all(color: PopboxColor.mdGrey50),
          color: PopboxColor.mdWhite1000,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                // color: Colors.black12,
                // offset: Offset(5, 5),
                // blurRadius: 10,
                )
          ],
        ),
      ),
    );
  }
}
