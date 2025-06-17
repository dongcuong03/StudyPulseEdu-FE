import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../resources/constains/constants.dart';
import '../../resources/utils/data_sources/dio_client.dart';

part 'count_notification_mobile_user_view_model.g.dart';
@riverpod
class CountNotificationMobileUserViewModel extends _$CountNotificationMobileUserViewModel {
  @override
  FutureOr<int> build() async {
    return 0;
  }

  Future<int> fetchUnreadCount(String accountId) async {
    try {
      final response = await DioClient().get(
          "${ApiConstants.getBaseUrl}/api/v1/notification/unread-count",
        queryParameters: {"accountId": accountId},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as int;
      }
    } catch (e) {
      print('Lỗi lấy số thông báo chưa đọc: $e');
    }
    return 0;
  }

  Future<void> refreshUnreadCount(String accountId) async {
    state = const AsyncLoading();
    state = AsyncData(await fetchUnreadCount(accountId));
  }
}
