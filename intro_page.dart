import 'package:flutter_svg/svg.dart';
import 'package:new_popbox/core/utils/global_function.dart';
import 'package:new_popbox/core/utils/library.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/ui/item/onboarding_item.dart';
import 'package:new_popbox/ui/pages/login_page.dart';
import 'package:new_popbox/ui/pages/register_page.dart';
import 'package:new_popbox/ui/widget/custom_button.dart';
import 'package:new_popbox/ui/widget/custom_view.dart';

class IntroScreen extends StatefulWidget {
  final List<OnboardingItem> onbordingDataList;
  final MaterialPageRoute pageRoute;

  IntroScreen(this.onbordingDataList, this.pageRoute);

  void skipPage(BuildContext context) {
    Navigator.pushReplacement(context, pageRoute);
  }

  @override
  IntroScreenState createState() {
    return new IntroScreenState();
  }
}

class IntroScreenState extends State<IntroScreen> {
  final PageController controller = new PageController();
  int currentPage = 0;
  bool lastPage = false;
  SharedPreferencesService sharedPrefService;
  String fcmToken = "";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        sharedPrefService = await SharedPreferencesService.instance;
        fcmToken = sharedPrefService.fcmToken;
        if (fcmToken == null || fcmToken == "") {
          setOnesignal(this.context);
        }

        //login(context, true);
      },
    );

    super.initState();
  }

  void _onPageChanged(int page) {
    setState(() {
      currentPage = page;
      if (currentPage == widget.onbordingDataList.length - 1) {
        lastPage = true;
        sharedPrefService.setIsOnboarding(true);
      } else {
        lastPage = false;
      }
    });
  }

  Widget _buildPageIndicator(int page) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.0),
      height: page == currentPage ? 6.5 : 7.0,
      width: page == currentPage ? 6.5 : 7.0,
      decoration: BoxDecoration(
        border: Border.all(color: PopboxColor.blue477FFF),
        color: page == currentPage
            ? PopboxColor.blue477FFF
            : PopboxColor.mdWhite1000,
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(height: 50.0),
                    SvgPicture.asset(
                      "assets/images/ic_popbox_logo.svg",
                      width: 85.0,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(height: 10.0),
                    SvgPicture.asset(
                      "assets/images/ic_box_n_beyond.svg",
                      width: 132,
                      fit: BoxFit.fitWidth,
                    ),
                  ],
                ),
                Flexible(
                  child: new PageView(
                    children: widget.onbordingDataList,
                    controller: controller,
                    onPageChanged: _onPageChanged,
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPageIndicator(0),
                      _buildPageIndicator(1),
                      _buildPageIndicator(2),
                      _buildPageIndicator(3),
                    ],
                  ),
                ),
              ],
            )),
            Container(
              padding: const EdgeInsets.only(
                  top: 10.0, bottom: 25.0, left: 20.0, right: 20.0),
              child: Column(
                children: [
                  SizedBox(height: 11.0),
                  CustomButtonRectangle(
                    onPressed: () =>
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => RegisterPage(
                                  from: "onboarding",
                                ))),
                    // widget.skipPage(context),
                    title: AppLocalizations.of(context)
                        .translate(LanguageKeys.register),
                    bgColor: PopboxColor.popboxRed,
                    textColor: PopboxColor.mdWhite1000,
                    fontSize: 12.0.sp,
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.only(left: 8, right: 8),
                    decoration: BoxDecoration(
                        border: Border.all(color: PopboxColor.popboxRed),
                        borderRadius: BorderRadius.circular(5)),
                    child: CustomButtonRectangle(
                      onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => LoginPage())),
                      // widget.skipPage(context),
                      title: AppLocalizations.of(context)
                          .translate(LanguageKeys.login),
                      bgColor: PopboxColor.mdWhite1000,
                      textColor: PopboxColor.popboxRed,
                      fontSize: 12.0.sp,
                    ),
                  ),
                  SizedBox(height: 15),
                  CustomWidget().textLight(
                      "v " + SharedPreferencesService().appVersion,
                      PopboxColor.mdBlack1000,
                      10,
                      TextAlign.center),
                ],
              ),
            )
            //Bottom
          ],
        ),
      ),
    );
  }
}
