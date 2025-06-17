import 'package:flutter/material.dart';

import '../../constains/constants.dart';


class AppTheme {
  AppTheme._();

  static const Color notWhite = Color(0xFFEDF0F2);
  static const Color nearlyWhite = Color(0xFFFEFEFE);
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color grey = Color(0xFF3A5160);
  static const Color darkGrey = Color(0xFF313A44);

  static const Color blackText = Color(0xFF000000);
  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color background = Color(0xFFE6EBEB);
  static const Color chipBackground = Color(0xFFEEF1F3);
  static const Color spacer = Color(0xFFF2F2F2);
  static const Color primaryColor = Colors.blue;
  static const Color secondColor = Color.fromARGB(219, 122, 223, 196);
  static const Color backgroundColor = Color.fromARGB(255, 238, 237, 237);
  static const Color whiteColor = Color.fromARGB(255, 255, 255, 255);
  static const Color grayColor = Color.fromARGB(255, 152, 152, 152);
  static const Color blueGreyDark = Color.fromARGB(255, 3, 45, 67);
  static const Color backgroundColorDark = Color.fromARGB(0, 56, 70, 100);
  static const Color redColor = Color.fromARGB(255, 230, 20, 20);

  static const Color homeBackground = Color(0xffb8dbf4);
  static const Color addPreFlightInspectionBackground = Color(0xfffde1c9);
  static const Color addDroneRepairBackground = Color(0xffd3e7c3);
  static const Color addFlightLogBackground = Color(0xffb7dbf5);
  static const Color editProfileBackground = Color(0xffebdeed);
  static const String fontName = 'NotoSansJP';

  static const Color headerBackground = Color(0xff2e3192);
  static const Color headerLineBackground1 = Color(0xff0e76bc);
  static const Color headerLineBackground2 = Color(0xff00aeef);
  static const Color headerLineBackground3 = Color(0xff23aae1);

  static ThemeData appTheme = ThemeData(
    // colorScheme: const ColorScheme(
    //   brightness: Brightness.light,
    //   primary: AppTheme.primaryColor, onPrimary: AppTheme.white,
    //   secondary: AppTheme.grey, onSecondary: AppTheme.secondColor,
    //   error: AppTheme.redColor, onError: AppTheme.white,
    //   background: AppTheme.white, onBackground: Colors.black,
    //   surface: AppTheme.notWhite, onSurface: AppTheme.blackText, // example: appBar & onAppBar
    // ),
    // colorScheme: const ColorScheme.light().copyWith(
    //   primary: AppTheme.primaryColor,
    //   secondary: AppTheme.grey,
    //   surface: AppTheme.notWhite,
    //   surfaceTint: AppTheme.grey
    // ),
    colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primaryColor),
    primarySwatch: Colors.blue,
    primaryColor: AppTheme.primaryColor,
    textTheme: AppTheme.textTheme,
    buttonTheme: AppTheme.buttonTheme,
    progressIndicatorTheme: AppTheme.progressIndicatorThemeData,
  );

  static ProgressIndicatorThemeData progressIndicatorThemeData =
      const ProgressIndicatorThemeData(color: AppTheme.primaryColor);

  static ButtonThemeData buttonTheme = ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));

  static const TextTheme textTheme = TextTheme(
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodySmall: bodySmall,
    bodyMedium: bodyMedium,
    bodyLarge: bodyLarge,
  );

  static const TextStyle headlineLarge = TextStyle(
    // h4
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: AppSettingConstants.FONT_SIZE_LARGE,
    letterSpacing: 0.4,
    height: 0.9,
    color: blackText,
  );

  static const TextStyle headlineMedium = TextStyle(
    // h4
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: AppSettingConstants.FONT_SIZE_MEDIUM,
    letterSpacing: 0.4,
    height: 0.9,
    color: blackText,
  );

  static const TextStyle headlineSmall = TextStyle(
    // h5
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: AppSettingConstants.FONT_SIZE_SMALL,
    letterSpacing: 0.27,
    color: blackText,
  );

  static const TextStyle titleLarge = TextStyle(
    // h6
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: AppSettingConstants.FONT_SIZE_LARGE,
    letterSpacing: 0.18,
    color: blackText,
  );

  static const TextStyle titleMedium = TextStyle(
    // h6
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: AppSettingConstants.FONT_SIZE_MEDIUM,
    letterSpacing: 0.18,
    color: blackText,
  );

  static const TextStyle titleSmall = TextStyle(
    // subtitle2 -> subtitle
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: AppSettingConstants.FONT_SIZE_SMALL,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle bodySmall = TextStyle(
    // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: AppSettingConstants.FONT_SIZE_SMALL,
    letterSpacing: 0.2,
    color: blackText, // was lightText
  );

  static const TextStyle bodyMedium = TextStyle(
    // body1 -> body2
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: AppSettingConstants.FONT_SIZE_MEDIUM,
    letterSpacing: 0.2,
    color: blackText,
  );

  static const TextStyle bodyLarge = TextStyle(
    // body2 -> body1
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: AppSettingConstants.FONT_SIZE_LARGE,
    letterSpacing: -0.05,
    color: blackText,
  );

  static const InputDecorationTheme inputDecorationTheme =
      InputDecorationTheme(filled: true, fillColor: Colors.white);
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}
