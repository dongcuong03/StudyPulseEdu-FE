import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';
import 'package:study_pulse_edu/resources/utils/data_sources/local.dart';
import 'package:study_pulse_edu/views/web/home_admin_screen.dart';
import 'package:study_pulse_edu/views/web/login_web_screen.dart';
import 'package:study_pulse_edu/routes/route_const.dart';

class MyRouterWeb {
  static Future<GoRouter> createRouter() async {
    final sharedPre = await SharedPre.instance;
    final token = await sharedPre.getString(SharedPrefsConstants.ACCESS_TOKEN_KEY);

    String initialLocation;

    if (token == null) {
      initialLocation = '/login_web';
    } else {
      initialLocation = '/';
    }

    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          name: RouteConstants.loginWebRouteName,
          path: '/login_web',
          builder: (context, state) => const LoginWebScreen(),
        ),
        GoRoute(
          name: RouteConstants.homeAdminRouteName,
          path: '/',
          builder: (context, state) => const HomeAdminScreen(),
        ),
      ],

      redirect: (context, state) async {
        final token = await sharedPre.getString(SharedPrefsConstants.ACCESS_TOKEN_KEY);
        final currentPath = state.uri.path;
        final isLoggingIn = currentPath == '/login_web';

        if (token == null && !isLoggingIn) {
          return '/login_web';
        }

        if (token != null && isLoggingIn) {
          return '/';
        }

        return null;
      },
    );
  }
}
