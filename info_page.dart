import 'package:flutter/material.dart';
import 'package:new_popbox/core/constants/constants.dart';
import 'package:new_popbox/core/models/callback/user/user_login_data.dart';
import 'package:new_popbox/core/utils/localization/app_localizations.dart';
import 'package:new_popbox/core/utils/shared_preference_service.dart';
import 'package:new_popbox/ui/widget/appbar.dart';
import 'package:new_popbox/ui/widget/help_view.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        UserLoginData userData = await SharedPreferencesService().getUser();
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: DetailAppBarView(
            title: AppLocalizations.of(context).translate(LanguageKeys.info),
          ),
        ),
        body: Container(
          child: HelpView(),
        ),
      ),
    );
  }
}
