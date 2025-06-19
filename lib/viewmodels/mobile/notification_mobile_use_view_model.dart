import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../models/app/NotificationApp.dart';
import '../../resources/constains/constants.dart';
import '../../resources/utils/data_sources/dio_client.dart';

part 'notification_mobile_use_view_model.g.dart';

@riverpod
class NotificationMobileUseViewModel extends _$NotificationMobileUseViewModel {
  @override
  FutureOr<List<NotificationApp>> build() {
    return [];
  }

  Future<void> fetch({
    required String accountId,
    String? studentId,
    NotificationType? type,
  }) async {
    state = const AsyncLoading();
    try {
      final data = await fetchNotifications(
        accountId: accountId,
        studentId: studentId,
        type: type,
      );
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<List<NotificationApp>> fetchNotifications({
    required String accountId,
    String? studentId,
    NotificationType? type,
  }) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/notification/getAllByIdAndType";

    final body = {
      "receiverId": accountId,
      if (studentId != null) "studentId": studentId,
      if (type != null) "type": type.name,
    };
    try {
      final response = await DioClient().post(url, data: body);
      if (response.statusCode == 200 && response.data != null) {
        final List jsonList = response.data;
        return jsonList.map((e) => NotificationApp.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetchNotifications: $e');
      rethrow;
    }
  }


  //Clall Api đánh ấu đã đọc
  Future<void> markAsRead(String notificationId) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/notification/read/$notificationId";
    try {
      await DioClient().put(url);
    } catch (e) {
      print('Error markAsRead: $e');
      rethrow;
    }
  }

}
