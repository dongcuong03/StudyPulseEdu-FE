import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:study_pulse_edu/models/app/AcademicResult.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';
import 'package:study_pulse_edu/resources/utils/data_sources/dio_client.dart';

part 'academic_result_mobile_teacher_view_model.g.dart';

@riverpod
class AcademicResultMobileTeacherViewModel extends _$AcademicResultMobileTeacherViewModel {
  @override
  FutureOr<List<AcademicResult>> build(String classId) async {
    return await _fetchResults(classId);
  }

  /// Gọi để lấy danh sách kết quả học tập theo lớp
  Future<void> fetch(String classId) async {
    state = const AsyncLoading();
    try {
      final result = await _fetchResults(classId);
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Hàm xử lý gọi API
  Future<List<AcademicResult>> _fetchResults(String classId) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/academicResult/$classId";

    try {
      final response = await DioClient().get(url);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => AcademicResult.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching academic results: $e");
    }

    return [];
  }

  /// Gửi danh sách kết quả học tập lên server
  Future<String?> saveAcademicResults(List<AcademicResult> results) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/academicResult/save";

    try {
      final data = results.map((e) => e.toJson()).toList();
      final response = await DioClient().post(url, data: data);

      if (response.statusCode == 200) {
        return null;
      } else {
        return "Lưu kết quả thất bại (mã lỗi: ${response.statusCode})";
      }
    } catch (e) {
      print("Lỗi khi lưu kết quả học tập: $e");
      return "Lỗi khi lưu kết quả: ${e.toString()}";
    }
  }

}
