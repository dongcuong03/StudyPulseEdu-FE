import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/app/Score.dart';
import '../../resources/constains/constants.dart';
import '../../resources/utils/data_sources/dio_client.dart';

part 'score_mobile_teacher_view_model.g.dart';

@riverpod
class ScoreMobileTeacherViewModel extends _$ScoreMobileTeacherViewModel {
  @override
  FutureOr<List<Score>> build() {
    return [];
  }

  /// Gọi API lấy điểm theo classId
  Future<void> fetchByClassId(String classId) async {
    state = const AsyncLoading();
    try {
      final scores = await fetchScoresByClassId(classId);
      state = AsyncData(scores);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Gọi GET /api/v1/score/getByClassId/{id}
  Future<List<Score>> fetchScoresByClassId(String classId) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/score/getByClassId/$classId";
    try {
      final response = await DioClient().get(url);
      if (response.statusCode == 200 && response.data != null) {
        final List list = response.data;
        return list.map((e) => Score.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetchScoresByClassId: $e');
      rethrow;
    }
  }

  /// Gọi POST /api/v1/score/save để lưu danh sách điểm
  Future<void> saveScores(List<Score> scores) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/score/save";
    final body = scores.map((e) => e.toJson()).toList();
    print(body);
    try {
      await DioClient().post(url, data: body);
    } catch (e) {
      print('Error saveScores: $e');
      rethrow;
    }
  }

  /// Gọi POST /api/v1/score/exportScoreTemplate/{classId} để xuất file điểm mẫu
  Future<void> exportScoreTemplate(String classId) async {
    final url =
        "${ApiConstants.getBaseUrl}/api/v1/score/exportScoreTemplate/$classId";

    try {
      // Lấy thư mục app
      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        return;
      }

      final fileName = 'score_template_$classId.xlsx';
      final savePath = "${dir.path}/$fileName";

      final response = await DioClient().getBytes(url);
      final file = File(savePath);
      await file.writeAsBytes(response.data);
    } catch (e) {
      print("Lỗi exportScoreTemplate: $e");
    }
  }

  /// Gọi API xuất file Excel điểm
  Future<String?> importScoreExcel(File file, String classId) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/score/importScoreExcel";

    try {
      final formData = FormData.fromMap({
        "uploadfile": await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        "classId": classId,
      });

      final response = await DioClient().post(
        url,
        data: formData,
        isMultipart: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchByClassId(classId);
        return null;
      } else {
        return "Lỗi server: ${response.statusCode} - ${response.statusMessage}";
      }
    } catch (e) {
      print("Lỗi importScoreExcel: $e");
      return "Lỗi gửi file: $e";
    }
  }
}
