import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:study_pulse_edu/models/app/Student.dart';

import '../../models/app/PagingResponse.dart';
import '../../resources/constains/constants.dart';
import '../../resources/utils/data_sources/dio_client.dart';

part 'class_student_view_model.g.dart';

@riverpod
class ClassStudentViewModel extends _$ClassStudentViewModel {
  static const int defaultPageSize = 10;

  int _currentPageIndex = 1;

  @override
  FutureOr<PagingResponse<Student>?> build() async {
    return await _fetchStudent(
        pageIndex: _currentPageIndex, pageSize: defaultPageSize);
  }

  Future<void> fetchStudent(
      {int? pageIndex,
      int pageSize = defaultPageSize,
      String? studentCode,
      String? classID}) async {
    state = const AsyncLoading();

    if (pageIndex != null) {
      _currentPageIndex = pageIndex;
    }

    try {
      final pagingResponse = await _fetchStudent(
          pageIndex: pageIndex,
          pageSize: pageSize,
          studentCode: studentCode,
          classID: classID);
      state = AsyncData(pagingResponse);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Call API paging
  Future<PagingResponse<Student>?> _fetchStudent(
      {int? pageIndex,
      int pageSize = defaultPageSize,
      String? studentCode,
      String? classID}) async {
    final url =
        "${ApiConstants.getBaseUrl}/api/v1/class/classEnroll/paging/$classID";

    final data = <String, dynamic>{
      'pageSize': pageSize,
    };

    if (pageIndex != null) {
      data['pageIndex'] = pageIndex;
    }

    if (studentCode != null && studentCode.isNotEmpty) {
      data['studentCode'] = studentCode;
    }

    final response = await DioClient().post(url, data: data);
    if (response.data == null) return null;
    return PagingResponse<Student>.fromJson(
      response.data,
      (json) => Student.fromJson(json),
    );
  }

  ///Call API enrollStudents
  Future<String?> enrollStudents({
    required String classId,
    required List<String> studentIds,
  }) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/class/classEnroll/enroll";

    final requestData = {
      'classId': classId,
      'studentIds': studentIds,
    };

    try {
      final response = await DioClient().post(url, data: requestData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }

      final responseData = response.data;
      final message = (responseData is Map<String, dynamic>)
          ? responseData['message'] as String?
          : null;

      if (message != null) {
        if (message.contains('Class not found')) {
          return 'Lớp học không tồn tại';
        }
        if (message.contains('Lớp học đã đầy')) {
          return 'Lớp học đã đầy';
        }
        return message;
      }
    } catch (e) {
      return 'Lỗi không xác định: $e';
    }
  }

  /// Call API unenrollStudent
  Future<String?> unenrollStudent({
    required String classId,
    required String studentId,
  }) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/class/classEnroll/unenroll";

    final requestData = {
      'classId': classId,
      'studentId': studentId,
    };

    try {
      final response = await DioClient().post(url, data: requestData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }

      final responseData = response.data;
      final message = (responseData is Map<String, dynamic>)
          ? responseData['message'] as String?
          : null;

      if (message != null) {
        if (message.contains('Class not found')) {
          return 'Lớp học không tồn tại';
        }
        if (message.contains('Student not found')) {
          return 'Học sinh không tồn tại';
        }
        return message;
      }
    } catch (e) {
      return 'Lỗi không xác định: $e';
    }
  }
}
