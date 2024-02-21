import 'package:new_popbox/core/utils/library.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/ui/pages/faq_main_page.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';
import 'package:new_popbox/ui/widget/help_view.dart';

class HelpPage extends StatefulWidget {
  final String from;

  const HelpPage({Key key, this.from}) : super(key: key);
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String _chosenValue;
  UserLoginData userData;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        userData = await SharedPreferencesService().getUser();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: widget.from == "home"
            ? DetailAppBarViewCloseIcon(
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.helpService),
              )
            : GeneralAppBarView(
                title: AppLocalizations.of(context)
                    .translate(LanguageKeys.helpService),
              ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 28.0, bottom: 15.0),
              width: 60.0.w,
              child: RawMaterialButton(
                fillColor: PopboxColor.mdWhite1000,
                splashColor: PopboxColor.mdWhite1000,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => FaqMainPage(),
                      ));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/ic_faq_logo.png",
                        ),
                        SizedBox(width: 15),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomWidget().textBoldPlus(
                                AppLocalizations.of(context)
                                    .translate(LanguageKeys.seeFaq),
                                PopboxColor.mdGrey900,
                                14,
                                TextAlign.left,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 6.0),
                                child: CustomWidget().textLight(
                                  AppLocalizations.of(context).translate(
                                      LanguageKeys.seeMostAnsweredQuestion),
                                  PopboxColor.mdGrey700,
                                  12,
                                  TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onPressed: null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: PopboxColor.mdGrey300),
                ),
              ),
            ),
            HelpView(),
          ],
        ),
      ),
    );
  }
}
