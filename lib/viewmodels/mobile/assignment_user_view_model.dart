import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/app/Assignment.dart';
import '../../models/app/Submission.dart';
import '../../resources/constains/constants.dart';
import '../../resources/utils/data_sources/dio_client.dart';
import '../../views/mobile/user/assignment/widget/assignment_user_tab_widget.dart';

part 'assignment_user_view_model.g.dart';

@riverpod
class AssignmentUserViewModel extends _$AssignmentUserViewModel {
  final Map<AssignmentTabType, List<Assignment>> _assignmentsByTab = {
    AssignmentTabType.all: [],
    AssignmentTabType.notSubmitted: [],
    AssignmentTabType.submitted: [],
    AssignmentTabType.overdue: [],
  };

  List<Assignment> getAssignmentsByTab(AssignmentTabType tab) {
    return _assignmentsByTab[tab] ?? [];
  }

  @override
  FutureOr<List<Assignment>?> build() async {
    return await fetchAssignments();
  }

  /// fetch dữ liệu bài tập và phân loại vào các list
  Future<List<Assignment>?> fetchAssignments(
      {String? className,
      String? studentId,
      DateTime? formDate,
      DateTime? toDate}) async {
    state = const AsyncLoading();

    try {
      final assignments = await _fetchAssignments(
          className: className,
          studentId: studentId,
          formDate: formDate,
          toDate: toDate);

      // Reset map
      for (var type in AssignmentTabType.values) {
        _assignmentsByTab[type] = [];
      }

      if (assignments != null) {
        for (final assignment in assignments) {
          _assignmentsByTab[AssignmentTabType.all]!.add(assignment);

          final isSubmitted =
              assignment.submissions?.any((s) => s.studentId == studentId) ??
                  false;
          DateTime? dueDateTime;
          final dueDate = assignment.dueDate;
          final dueTimeStr = assignment.dueTime?.trim();

          if (dueDate != null && dueTimeStr != null) {
            final parts = dueTimeStr.split(':');

            if (parts.length >= 2) {
              final hour = int.tryParse(parts[0]);
              final minute = int.tryParse(parts[1]);

              if (hour != null && minute != null) {
                dueDateTime = DateTime(
                  dueDate.year,
                  dueDate.month,
                  dueDate.day,
                  hour,
                  minute,
                );
              }
            }
          }
          final isOverdue =
              dueDateTime != null && DateTime.now().isAfter(dueDateTime);

          if (isSubmitted) {
            _assignmentsByTab[AssignmentTabType.submitted]!.add(assignment);
          } else if (isOverdue) {
            _assignmentsByTab[AssignmentTabType.overdue]!.add(assignment);
          } else {
            _assignmentsByTab[AssignmentTabType.notSubmitted]!.add(assignment);
          }
        }
      }

      state = AsyncData(assignments);
      return assignments;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  ///Call API trả về danh sách baì tập theo các tiêu chí
  Future<List<Assignment>?> _fetchAssignments(
      {String? className,
      String? studentId,
      DateTime? formDate,
      DateTime? toDate}) async {
    final url =
        "${ApiConstants.getBaseUrl}/api/v1/assignment/getAllAssignmentUser";

    final data = <String, dynamic>{};

    if (className != null && className.isNotEmpty) {
      data['className'] = className;
    }

    if (studentId != null && studentId.isNotEmpty) {
      data['studentId'] = studentId;
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

  /// Call API nộp bài tập
  Future<String?> createSubmission({
    required Submission submission,
    List<File>? files,
  }) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/submission/create";

    try {
      final jsonData = jsonEncode(submission.toJson());

      final formMap = <String, dynamic>{
        "data": MultipartFile.fromString(
          jsonData,
          contentType: MediaType('application', 'json'),
        ),
      };

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

  /// Call API trả về bài nộp theo id
  Future<Submission?> fetchSubmissionByID({
    Submission? subission,
  }) async {
    final url =
        "${ApiConstants.getBaseUrl}/api/v1/submission/getByStudentIdAndAssignmentId";

    final response = await DioClient().post(url, data: subission?.toJson());
    if (response.data == null) return null;
    return Submission.fromJson(response.data);
  }
}
