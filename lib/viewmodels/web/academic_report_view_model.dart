import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:study_pulse_edu/models/app/AcademicReport.dart';

import 'package:study_pulse_edu/resources/constains/constants.dart';
import 'package:study_pulse_edu/resources/utils/data_sources/dio_client.dart';

import '../../models/app/TuitionReport.dart';

part 'academic_report_view_model.g.dart';

@riverpod
class AcademicReportViewModel extends _$AcademicReportViewModel {
  @override
  FutureOr<List<AcademicReport>> build() async {
    return [];
  }

  Future<List<AcademicReport>> fetchReport({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    state = const AsyncLoading();
    try {
      final url = "${ApiConstants.getBaseUrl}/api/v1/academicResult/getReport";

      final data = {
        "fromDate": fromDate.toIso8601String(),
        "toDate": toDate.toIso8601String(),
      };

      final response = await DioClient().post(url, data: data);
      if (response.statusCode == 200 && response.data is List) {
        final List<AcademicReport> reports = (response.data as List)
            .map((e) => AcademicReport.fromJson(e))
            .toList();
        state = AsyncData(reports);
        return reports;
      } else {
        throw Exception("Lỗi dữ liệu phản hồi không hợp lệ.");
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

}
