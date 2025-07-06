import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';
import 'package:study_pulse_edu/resources/utils/app/app_theme.dart';
import 'package:study_pulse_edu/resources/utils/data_sources/local.dart';
import 'package:study_pulse_edu/routes/route_web.dart'; // route dành cho web
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'l10n/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final shared = await SharedPre.instance;

  final router = await MyRouterWeb.createRouter();

  runApp(
    ProviderScope(
      child: MyAppWeb(router: router),
    ),
  );
}

class MyAppWeb extends StatefulWidget {
  final GoRouter router;
  const MyAppWeb({super.key, required this.router});

  @override
  State<MyAppWeb> createState() => _MyAppWebState();

  static _MyAppWebState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppWebState>();
}

class _MyAppWebState extends State<MyAppWeb> {
  Locale _locale = const Locale(AppConstants.APP_LANGUAGE);

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1440, 1024),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.appTheme,
          supportedLocales: L10n.all,
          locale: _locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: widget.router,
        );
      },
    );
  }

  void fetchData() async {
    final language = (await SharedPre.instance)
        .getString(SharedPrefsConstants.LANGUAGE_KEY) ??
        AppConstants.APP_LANGUAGE;
    setState(() {
      _locale = Locale(language);
    });
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }
}
