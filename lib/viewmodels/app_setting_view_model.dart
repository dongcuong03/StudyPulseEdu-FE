/// RUN "dart run build_runner watch -d" IN CMD TO GENERATE RIVERPOD CODE
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/app_setting.dart';
import '../resources/constains/constants.dart';
import '../resources/utils/data_sources/local.dart';

part 'app_setting_view_model.g.dart';

@riverpod
class AppSettingViewModel extends _$AppSettingViewModel {
  @override
  FutureOr<AppSetting> build() async {
    return _fetchData();
  }

  Future<AppSetting> _fetchData() async {
    final fontSize = (await SharedPre.instance)
        .getDouble(SharedPrefsConstants.FONT_SIZE_KEY);
    return AppSetting(fontSize: fontSize);
  }

  Future<bool> changeFontSize(double fontSize) async {
    try {
      (await SharedPre.instance)
          .setDouble(SharedPrefsConstants.FONT_SIZE_KEY, fontSize);
      state = AsyncValue.data(AppSetting(fontSize: fontSize));
      return true;
    } catch (e) {
      return false;
    }
  }
}
