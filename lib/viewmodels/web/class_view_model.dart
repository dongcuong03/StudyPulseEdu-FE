import 'dart:math';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:study_pulse_edu/models/app/ClassA.dart';

import '../../models/app/PagingResponse.dart';
import '../../resources/constains/constants.dart';
import '../../resources/utils/data_sources/dio_client.dart';

part 'class_view_model.g.dart';

@riverpod
class ClassViewModel extends _$ClassViewModel {
  static const int defaultPageSize = 10;

  int _currentPageIndex = 1;

  final dateFormat = DateFormat('yyyy-MM-dd');

  @override
  FutureOr<PagingResponse<ClassA>?> build() async {
    return await _fetchClasses(
        pageIndex: _currentPageIndex, pageSize: defaultPageSize);
  }

  Future<void> fetchClasses(
      {int? pageIndex,
      int pageSize = defaultPageSize,
      String? className,
      String? teacherName,
      DateTime? startDate,
      DateTime? endDate}) async {
    state = const AsyncLoading();

    if (pageIndex != null) {
      _currentPageIndex = pageIndex;
    }

    try {
      final pagingResponse = await _fetchClasses(
          pageIndex: pageIndex,
          pageSize: pageSize,
          className: className,
          teacherName: teacherName,
          startDate: startDate,
          endDate: endDate);
      state = AsyncData(pagingResponse);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Call API paging
  Future<PagingResponse<ClassA>?> _fetchClasses(
      {int? pageIndex,
      int pageSize = defaultPageSize,
      String? className,
      String? teacherName,
      DateTime? startDate,
      DateTime? endDate}) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/class/paging";

    final data = <String, dynamic>{
      'pageSize': pageSize,
    };

    if (pageIndex != null) {
      data['pageIndex'] = pageIndex;
    }

    if (className != null && className.isNotEmpty) {
      data['className'] = className;
    }
    if (teacherName != null && teacherName.isNotEmpty) {
      data['teacherName'] = teacherName;
    }
    if (startDate != null) {
      data['formDate'] = dateFormat.format(startDate);
    }
    if (endDate != null) {
      data['toDate'] = dateFormat.format(endDate);
    }

    final response = await DioClient().post(url, data: data);
    if (response.data == null) return null;
    return PagingResponse<ClassA>.fromJson(
      response.data,
      (json) => ClassA.fromJson(json),
    );
  }

  ///Call API disableClass
  Future<bool> disableClass(String id) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/class/disableClass/$id";

    try {
      final response = await DioClient().put(url);
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print("Error disableAccount: $e");
    }
    return false;
  }

  ///Call API enableClass
  Future<bool> enableClass(String id) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/class/enableClass/$id";

    try {
      final response = await DioClient().put(url);
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print("Error enableAccount: $e");
    }
    return false;
  }

  /// Call Api createClass
  Future<String?> createClass(ClassA classA) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/class/create";

    try {
      final response = await DioClient().post(url, data: classA.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }
      final data = response.data;
      final message =
          (data is Map<String, dynamic>) ? data['message'] as String? : null;

      if (message != null) {
        if (message.contains('Tên lớp học đã tồn tại')) {
          return 'Tên lớp học đã tồn tại';
        }
        if (message.contains('Giáo viên đã có lớp học trong khung giờ này')) {
          return 'Giáo viên đã có lớp học trong khung giờ này';
        }
        return message;
      }
    } catch (e) {
      return 'Lỗi không xác định: $e';
    }
  }

  /// Call API updateClass
  Future<String?> updateClass(ClassA classA, String classID) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/class/update/$classID";

    try {
      final response = await DioClient().put(url, data: classA.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }
      final data = response.data;
      final message =
          (data is Map<String, dynamic>) ? data['message'] as String? : null;

      if (message != null) {
        if (message.contains('Tên lớp học đã tồn tại')) {
          return 'Tên lớp học đã tồn tại';
        }
        if (message.contains('Giáo viên đã có lớp học trong khung giờ này')) {
          return 'Giáo viên đã có lớp học trong khung giờ này';
        }
        return message;
      }
    } catch (e) {
      return 'Lỗi không xác định: $e';
    }
  }

  ///Call Api getClassById
  Future<ClassA?> getClassById(String id) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/class/$id";
    try {
      final response = await DioClient().get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        return ClassA.fromJson(data);
      }
    } catch (e) {
      print('Error getAccountById: $e');
    }
    return null;
  }
}
