import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/app/ClassRoom.dart';
import '../../resources/constains/constants.dart';
import '../../resources/utils/data_sources/dio_client.dart';

part 'classRoom_mobile_user_view_model.g.dart';

@riverpod
class ClassRoomMobileUserViewModel extends _$ClassRoomMobileUserViewModel {
  @override
  FutureOr<List<ClassRoom>> build() async {
    return [];
  }

  Future<void> fetch({required String id}) async {
    state = const AsyncLoading();

    try {
      final classes = await fetchClassRoomUser(id: id);
      state = AsyncData(classes);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Call API trả về danh sách lơp học theo studentID
  Future<List<ClassRoom>> fetchClassRoomUser({required String id}) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/class/getByStudentID/$id";

    try {
      final response = await DioClient().get(url);

      if (response.statusCode == 200 && response.data != null) {
        final List data = response.data as List;
        return data.map((e) => ClassRoom.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetchClassRoomTeacher: $e');
      rethrow;
    }
  }
}
