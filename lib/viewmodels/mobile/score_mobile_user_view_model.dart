import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../models/app/Score.dart';
import '../../resources/constains/constants.dart';
import '../../resources/utils/data_sources/dio_client.dart';

part 'score_mobile_user_view_model.g.dart';

@riverpod
class ScoreMobileUserViewModel extends _$ScoreMobileUserViewModel {
  @override
  FutureOr<List<Score>> build() {
    return [];
  }

  /// Gọi API lấy điểm theo studentId
  Future<void> fetchByClassId(String studentId) async {
    state = const AsyncLoading();
    try {
      final scores = await fetchScoresByStudentId(studentId);
      state = AsyncData(scores);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Gọi GET /api/v1/score/getByStudentId/{id}
  Future<List<Score>> fetchScoresByStudentId(String studentId) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/score/getByStudentId/$studentId";
    try {
      final response = await DioClient().get(url);
      if (response.statusCode == 200 && response.data != null) {
        final List list = response.data;
        return list.map((e) => Score.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetchScoresByStudentId: $e');
      rethrow;
    }
  }

}
