import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../models/app/Notification.dart';
import '../../resources/constains/constants.dart';
import '../../resources/utils/data_sources/dio_client.dart';

part 'notification_mobile_use_view_model.g.dart';

@riverpod
class NotificationMobileUseViewModel extends _$NotificationMobileUseViewModel {
  @override
  FutureOr<List<Notification>> build() {
    return [];
  }

  Future<void> fetch({required String accountId}) async {
    state = const AsyncLoading();
    try {
      final data = await fetchNotifications(accountId: accountId);
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<List<Notification>> fetchNotifications({required String accountId}) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/notification/$accountId";

    try {
      final response = await DioClient().get(url);
      if (response.statusCode == 200 && response.data != null) {
        final List jsonList = response.data;
        return jsonList.map((e) => Notification.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetchNotifications: $e');
      rethrow;
    }
  }

  //Clall Api số thông báo
}
