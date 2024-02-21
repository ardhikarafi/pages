import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/payload/register_payload.dart';
import 'package:new_popbox/core/utils/library.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/core/viewmodel/user_viewmodel.dart';
import 'package:new_popbox/ui/pages/pin_page.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class RegisterDataPage extends StatefulWidget {
  @override
  _RegisterDataPageState createState() => _RegisterDataPageState();
}

class _RegisterDataPageState extends State<RegisterDataPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  //TextEditingController monthController = TextEditingController();
  //TextEditingController yearController = TextEditingController();

  DateTime selectedBirthDay = new DateTime(
      DateTime.now().year - 11, DateTime.now().month, DateTime.now().day);

  RegisterPayload registerPayload = SharedPreferencesService().registerPayload;

  String gender;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int dotCounter = 3;
    if (SharedPreferencesService().locationSelected == "PH" &&
        GlobalVar.showUploadIdStep) {
      dotCounter = 4;
    }
    return Consumer<UserViewModel>(
      builder: (context, model, _) {
        return Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  //Navigator.of(context).pop(true);
                                },
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 40.0, 0.0, 0.0),
                                    child: Container()

                                    // Image.asset(
                                    //   "assets/images/ic_back_black.png",
                                    //   fit: BoxFit.fitHeight,
                                    // ),
                                    ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 40.0, 16.0, 0.0),
                                  child: Row(
                                    children: [
                                      _buildPageIndicator(true),
                                      _buildPageIndicator(true),
                                      _buildPageIndicator(true),
                                    ],
                                  )),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16.0, 28.0, 16.0, 0.0),
                            child: CustomWidget().textBold(
                              AppLocalizations.of(context)
                                  .translate(LanguageKeys.inputAccountData),
                              PopboxColor.mdGrey900,
                              14.0.sp,
                              TextAlign.left,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 30.0),
                            child: CustomWidget().textFormFieldRegular(
                              controller: nameController,
                              labelText: AppLocalizations.of(context)
                                  .translate(LanguageKeys.name),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16.0, 7.0, 16.0, 0.0),
                            child: CustomWidget().textRegular(
                              AppLocalizations.of(context).translate(
                                  LanguageKeys.inputYourCompleteName),
                              PopboxColor.mdGrey700,
                              9.0.sp,
                              TextAlign.left,
                            ),
                          ),
                          SharedPreferencesService().locationSelected == "PH" ||
                                  SharedPreferencesService().locationSelected ==
                                      "MY"
                              ? Container()
                              : Container(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16.0, top: 25.0),
                                  child: CustomWidget().textFormFieldRegular(
                                      controller: dateController,
                                      labelText: AppLocalizations.of(context)
                                          .translate(LanguageKeys.birthDate),
                                      readOnly: true,
                                      callBackVoid: () {
                                        _selectDate(context);
                                      },
                                      suffixIcon: IconButton(
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.black,
                                          ),
                                          onPressed: () {})),
                                  // Icon(
                                  //   Icons.arrow_drop_down,
                                  //   color: Colors.black,
                                  // ),
                                ),

                          (SharedPreferencesService().locationSelected ==
                                      "PH" ||
                                  SharedPreferencesService().locationSelected ==
                                      "MY")
                              ? Container()
                              : Container(
                                  margin: EdgeInsets.only(
                                      left: 16.0, right: 16.0, top: 25.0),
                                  width: 100.0.w,
                                  decoration: BoxDecoration(
                                      color: PopboxColor.mdWhite1000,
                                      border: Border.all(
                                          color: PopboxColor.mdGrey300),
                                      borderRadius: BorderRadius.circular(8.0)),
                                  padding: const EdgeInsets.fromLTRB(
                                      16.0, 7.0, 16.0, 7.0),
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    underline: Container(),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.black,
                                    ),
                                    value: gender,
                                    items: <String>[
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.male),
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.female),
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                            color: PopboxColor.mdBlack1000,
                                            fontSize: 14,
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    hint: Text(
                                      AppLocalizations.of(context)
                                          .translate(LanguageKeys.gender),
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                        color: PopboxColor.mdBlack1000,
                                        fontSize: 14,
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    onChanged: (String value) {
                                      setState(() {
                                        gender = value;
                                      });
                                    },
                                  ),
                                ),
                          //Button
                          Container(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 30.0),
                            child: CustomButtonRectangle(
                              title: AppLocalizations.of(context)
                                  .translate(LanguageKeys.formSubmit),
                              bgColor: PopboxColor.popboxRed,
                              textColor: PopboxColor.mdWhite1000,
                              fontSize: 12.0.sp,
                              onPressed: () {
                                String finalGender = "";
                                if (gender ==
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.male)) {
                                  finalGender = "male";
                                } else if (gender ==
                                    AppLocalizations.of(context)
                                        .translate(LanguageKeys.female)) {
                                  finalGender = "female";
                                } else {
                                  finalGender = "";
                                }

                                if (nameController.text == null ||
                                    nameController.text.trim() == "") {
                                  CustomWidget().showCustomDialog(
                                      context: context,
                                      msg: AppLocalizations.of(context)
                                          .translate(LanguageKeys
                                              .inputYourCompleteName));
                                  return;
                                }

                                if (nameController.text.trim().length < 5) {
                                  CustomWidget().showCustomDialog(
                                      context: context,
                                      msg: AppLocalizations.of(context)
                                          .translate(LanguageKeys
                                              .nameAtLeastFiveLetters));
                                  return;
                                }
                                if (nameController.text.length > 30) {
                                  CustomWidget().showCustomDialog(
                                    context: context,
                                    msg: AppLocalizations.of(context)
                                        .translate(LanguageKeys.maxCharacter)
                                        .replaceAll("%1s", "30"),
                                  );
                                  return;
                                }
                                if (dateController.text.isEmpty &&
                                    SharedPreferencesService()
                                            .locationSelected ==
                                        "ID") {
                                  CustomWidget().showCustomDialog(
                                    context: context,
                                    msg: AppLocalizations.of(context)
                                        .translate(LanguageKeys.caseIsRequired)
                                        .replaceAll(
                                            "%1s",
                                            AppLocalizations.of(context)
                                                .translate(
                                                    LanguageKeys.birthDate)),
                                  );
                                  return;
                                }
                                if (finalGender.isEmpty &&
                                    SharedPreferencesService()
                                            .locationSelected ==
                                        "ID") {
                                  CustomWidget().showCustomDialog(
                                    context: context,
                                    msg: AppLocalizations.of(context)
                                        .translate(LanguageKeys.caseIsRequired)
                                        .replaceAll(
                                            "%1s",
                                            AppLocalizations.of(context)
                                                .translate(
                                                    LanguageKeys.gender)),
                                  );
                                  return;
                                }

                                registerPayload.name =
                                    nameController.text.trim();

                                try {
                                  registerPayload.gender = finalGender;
                                } catch (e) {}

                                try {
                                  if (dateController.text != null &&
                                      dateController.text != "" &&
                                      dateController.text != 'DD MM YYYY') {
                                    String localeDate = "id_ID";
                                    if (SharedPreferencesService()
                                            .locationSelected !=
                                        'ID') {
                                      localeDate = "en_EN";
                                    }
                                    DateFormat format =
                                        DateFormat("dd MMMM yyyy", localeDate);
                                    DateTime dateTime =
                                        format.parse(dateController.text);

                                    DateFormat outputFormat =
                                        DateFormat('yyyy-MM-dd');
                                    String outputDate =
                                        outputFormat.format(dateTime);
                                    registerPayload.dob = outputDate;
                                  }
                                } catch (e) {
                                  print(e.toString());
                                }

                                SharedPreferencesService()
                                    .setRegisterPayload(registerPayload);

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PinPage(
                                      reason: "register",
                                      loginPayload: null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (model.loading)
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
      },
    );
  }

  Widget _buildPageIndicator(bool active) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.0),
      height: active ? 6.5 : 7.0,
      width: active ? 6.5 : 7.0,
      decoration: BoxDecoration(
        border: Border.all(color: PopboxColor.blue477FFF),
        color: active ? PopboxColor.blue477FFF : PopboxColor.mdWhite1000,
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: PopboxColor.mdWhite1000,
    borderRadius: BorderRadius.circular(4.0),
    border: Border.all(color: PopboxColor.mdGrey350),
  );

  void _selectDate(BuildContext context) {
    var eleventMonths = new DateTime(
        DateTime.now().year - 11, DateTime.now().month, DateTime.now().day);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedBirthDay, // Refer step 1
        firstDate: DateTime(1910),
        lastDate: eleventMonths,
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: PopboxColor.popboxRed,
                onPrimary: PopboxColor.mdWhite1000,
                surface: PopboxColor.popboxRed,
                onSurface: PopboxColor.mdBlack1000,

                //onSecondary: PopboxColor.mdBlack1000,
                //background: PopboxColor.mdBlack1000,
              ),
              dialogBackgroundColor: PopboxColor.mdWhite1000,
              //accentColor: PopboxColor.mdBlack1000,
              //accentColor: Colors.teal,

              //buttonColor: PopboxColor.mdBlack1000
            ),
            child: child,
          );
        },
      );

      if (picked != null && picked != selectedBirthDay)
        setState(() {
          selectedBirthDay = picked;

          String day = selectedBirthDay.day.toString();
          String month = selectedBirthDay.month.toString();

          try {
            if (int.parse(day) < 10) {
              day = "0" + day;
            }
          } catch (e) {}

          try {
            if (int.parse(month) < 10) {
              month = "0" + month;
            }
          } catch (e) {}

          DateFormat format = DateFormat("dd MM yyyy");
          DateTime dateTime = format.parse(
              day + " " + month + " " + selectedBirthDay.year.toString());

          String localeDate = "id_ID";
          if (SharedPreferencesService().locationSelected != 'ID') {
            localeDate = "en_EN";
          }
          DateFormat outputFormat = DateFormat('dd MMMM yyyy', localeDate);
          String outputDate = outputFormat.format(dateTime);

          dateController.text = outputDate;
        });
    });
  }
}
