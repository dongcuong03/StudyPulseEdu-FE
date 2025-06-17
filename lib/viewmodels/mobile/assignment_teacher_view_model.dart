import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:study_pulse_edu/models/app/Assignment.dart';

import '../../models/app/PagingResponse.dart';
import '../../models/app/Submission.dart';
import '../../resources/constains/constants.dart';
import '../../resources/utils/data_sources/dio_client.dart';

part 'assignment_teacher_view_model.g.dart';

@riverpod
class AssignmentTeacherViewModel extends _$AssignmentTeacherViewModel {
  @override
  FutureOr<List<Assignment>?> build() async {
    return await _fetchAssignments();
  }

  Future<void> fetchAssignments(
      {String? className,
      String? teacherId,
      DateTime? formDate,
      DateTime? toDate}) async {
    state = const AsyncLoading();

    try {
      final assignments = await _fetchAssignments(
          className: className,
          teacherId: teacherId,
          formDate: formDate,
          toDate: toDate);
      state = AsyncData(assignments);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<List<Assignment>?> _fetchAssignments(
      {String? className,
      String? teacherId,
      DateTime? formDate,
      DateTime? toDate}) async {
    final url =
        "${ApiConstants.getBaseUrl}/api/v1/assignment/getAllAssignmentTeacher";

    final data = <String, dynamic>{};

    if (className != null && className.isNotEmpty) {
      data['className'] = className;
    }

    if (teacherId != null && teacherId.isNotEmpty) {
      data['teacherId'] = teacherId;
    }
    if (formDate != null) {
      data['formDate'] = formDate.toIso8601String();
    }
    if (toDate != null) {
      data['toDate'] = toDate.toIso8601String();
    }

    final response = await DioClient().post(url, data: data);

    if (response.data == null) return null;

    return (response.data as List)
        .map((json) => Assignment.fromJson(json))
        .toList();
  }

  Future<String?> createAssignment({
    required Assignment assignment,
    List<File>? files,
  }) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/assignment/create";

    try {
      // Encode dữ liệu dto thành JSON string
      final jsonData = jsonEncode(assignment.toJson());

      // Tạo map chứa phần data json
      final formMap = <String, dynamic>{
        "data": MultipartFile.fromString(
          jsonData,
          contentType: MediaType('application', 'json'),
        ),
      };

      // Nếu có files, chuyển từng file sang MultipartFile rồi thêm vào map
      if (files != null && files.isNotEmpty) {
        List<MultipartFile> multipartFiles = [];

        for (var file in files) {
          final fileName = file.path.split('/').last;

          final multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          );

          multipartFiles.add(multipartFile);
        }

        formMap['file'] = multipartFiles;
      }

      final formData = FormData.fromMap(formMap);

      final response = await DioClient().post(
        url,
        data: formData,
        isMultipart: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null; // thành công
      }
    } catch (e) {
      if (e is DioException) {
        final message =
            e.response?.data['message'] ?? 'Đã xảy ra lỗi không xác định';
        return message;
      } else {
        return 'Lỗi không xác định: $e';
      }
    }
    return "Lỗi không xác định";
  }

  // Call APi chấm bài tập
  Future<String?> gradeSubission(
      Submission submission, String submissionId) async {
    final url =
        "${ApiConstants.getBaseUrl}/api/v1/submission/gradeSubission/$submissionId";

    try {
      final response = await DioClient().put(url, data: submission.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }
    } catch (e) {
      if (e is DioException) {
        final message =
            e.response?.data['message'] ?? 'Đã xảy ra lỗi không xác định';
        return message;
      } else {
        return 'Lỗi không xác định: $e';
      }
    }
    return "Lỗi không xác định";
  }
}
