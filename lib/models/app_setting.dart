import '../resources/constains/constants.dart';

class AppSetting {
  AppSetting({this.fontSize});

  double? fontSize;

  double get smallTextSize => fontSize != null ? fontSize! - 2 : AppSettingConstants.FONT_SIZE_SMALL;
  double get mediumTextSize => fontSize ?? AppSettingConstants.FONT_SIZE_MEDIUM;
  double get largeTextSize => fontSize != null ? fontSize! + 4 : AppSettingConstants.FONT_SIZE_LARGE;
}
