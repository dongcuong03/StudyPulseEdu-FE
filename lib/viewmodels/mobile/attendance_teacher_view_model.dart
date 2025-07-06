import 'dart:async';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/app/Attendance.dart';
import '../../resources/constains/constants.dart';
import '../../resources/utils/data_sources/dio_client.dart';

part 'attendance_teacher_view_model.g.dart';

@riverpod
class AttendanceTeacherViewModel extends _$AttendanceTeacherViewModel {
  @override
  FutureOr<List<DateTime>?> build() async => null;

  /// Call API lấy danh sách ngày điểm danh
  Future<List<DateTime>?> getAttendanceByClass(String classId) async {
    state = const AsyncLoading();
    try {
      final response = await DioClient().get(
        "${ApiConstants.getBaseUrl}/api/v1/attendance/byClass/$classId",
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> rawList = response.data;

        final List<DateTime> dates = rawList
            .map((e) => DateTime.parse(e['attendanceDatetime']).toLocal())
            .map((d) => DateTime(d.year, d.month, d.day))
            .toSet()
            .toList();

        state = AsyncData(dates);
        return dates;
      } else {
        state = AsyncError('Lỗi lấy danh sách điểm danh', StackTrace.current);
        return null;
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// Call API điểm danh
  Future<String?> markAttendanceBulk(List<Attendance> attendances) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/attendance/bulk";

    try {
      final data = attendances.map((e) => e.toJson()).toList();
      print('data: $data');
      final response = await DioClient().post(url, data: data);

      if (response.statusCode == 200 && response.data != null) {
        return null; // thành công
      } else {
        return 'Điểm danh thất bại. Vui lòng thử lại.';
      }
    } catch (e) {
      if (e is DioException) {
        final message =
            e.response?.data['message'] ?? 'Đã xảy ra lỗi không xác định';
        return message;
      } else {
        print(e);
        return 'Lỗi không xác định: $e';
      }
    }
  }

  /// call API getAttendanceByClassAndDate
  Future<List<Attendance>?> getAttendanceByClassAndDate({
    required String classId,
    required DateTime date,
  }) async {
    final url =
        "${ApiConstants.getBaseUrl}/api/v1/attendance/byClassAndDate?classId=$classId&date=${date.toIso8601String().split('T').first}";

    try {
      final response = await DioClient().get(url);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> rawList = response.data;
        print(rawList);
        final attendances = rawList.map((e) => Attendance.fromJson(e)).toList();
        print('attendances:$attendances');
        return attendances;
      } else {
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API getAttendanceByClassAndDate: $e");
      return null;
    }
  }
}
