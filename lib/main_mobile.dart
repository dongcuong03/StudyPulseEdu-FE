import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';
import 'package:study_pulse_edu/resources/utils/app/app_theme.dart';
import 'package:study_pulse_edu/resources/utils/data_sources/local.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_pulse_edu/resources/widgets/show_parent_verification_dialog.dart';
import 'package:study_pulse_edu/routes/route_const.dart';
import 'package:study_pulse_edu/routes/router_mobile.dart';
import 'l10n/l10n.dart';
import 'notification_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //thông báo
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  await setupFlutterNotifications(navigatorKey);

  HttpOverrides.global = MyHttpOverrides();
  final shared = await SharedPre.instance;
  final router = await MyRouterMobile.createRouter();

  runApp(
    ProviderScope(
      child: MyAppMobile(router: router),
    ),
  );
}

class MyAppMobile extends StatefulWidget {
  final GoRouter router;
  const MyAppMobile({super.key, required this.router});

  @override
  State<MyAppMobile> createState() => _MyAppMobileState();

  static _MyAppMobileState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppMobileState>();
}

class _MyAppMobileState extends State<MyAppMobile> {
  Locale _locale = const Locale(AppConstants.APP_LANGUAGE);

  @override
  void initState() {
    super.initState();
    fetchData();
    handleFCMEvents(navigatorKey);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
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

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
