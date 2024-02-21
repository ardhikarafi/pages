import 'package:new_popbox/core/utils/library.dart';
import 'package:new_popbox/ui/item/onboarding_item.dart';
import 'package:new_popbox/ui/pages/intro_page.dart';
import 'package:new_popbox/ui/pages/prelogin_page.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    List<OnboardingItem> list = StaticData().getOnboarding(context);

    Scaffold(body: SafeArea(child: Text("")));

    return new IntroScreen(
      list,
      MaterialPageRoute(builder: (context) => PreloginPage()),
    );
  }
}
