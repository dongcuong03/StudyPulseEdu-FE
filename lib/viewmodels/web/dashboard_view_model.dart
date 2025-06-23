import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';
import 'package:study_pulse_edu/resources/utils/data_sources/dio_client.dart';

import '../../models/app/DashboardResponseDto.dart';

part 'dashboard_view_model.g.dart';

@riverpod
class DashboardViewModel extends _$DashboardViewModel {
  @override
  Future<DashboardResponseDto?> build() async {
    return await fetchDashboardData();
  }

  Future<DashboardResponseDto?> fetchDashboardData() async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/dashboard/";

    try {
      final response = await DioClient().get(url);
      if (response.statusCode == 200 && response.data != null) {
        return DashboardResponseDto.fromJson(response.data);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
    return null;
  }
}
