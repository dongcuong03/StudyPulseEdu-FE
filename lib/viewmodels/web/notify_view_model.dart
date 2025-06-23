import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:study_pulse_edu/models/app/Account.dart';
import 'package:study_pulse_edu/models/app/NotificationApp.dart';
import '../../models/app/PagingResponse.dart';
import '../../resources/constains/constants.dart';
import '../../resources/utils/data_sources/dio_client.dart';


part 'notify_view_model.g.dart';

@riverpod
class NotifyViewModel extends _$NotifyViewModel {
  static const int defaultPageSize = 10;

  int _currentPageIndex = 1;

  @override
  FutureOr<PagingResponse<NotificationApp>?> build() async {
    return await _fetchNotificationApps(pageIndex: _currentPageIndex, pageSize: defaultPageSize);
  }

  Future<void> fetchNotificationApps({
    int? pageIndex,
    int pageSize = defaultPageSize,
    String? receiverId,
    String? senderId,
    NotificationType? type,
    DateTime? startDate,
    DateTime? endDate
  }) async {
    state = const AsyncLoading();

    if (pageIndex != null) {
      _currentPageIndex = pageIndex;
    }


    try {
      final pagingResponse = await _fetchNotificationApps(
          pageIndex: pageIndex,
          pageSize: pageSize,
          receiverId: receiverId,
          senderId: senderId,
        type: type,
        startDate: startDate,
        endDate: endDate
      );
      state = AsyncData(pagingResponse);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // Call API paging
  Future<PagingResponse<NotificationApp>?> _fetchNotificationApps({
    int? pageIndex,
    int pageSize = defaultPageSize,
    String? receiverId,
    String? senderId,
    NotificationType? type,
    DateTime? startDate,
    DateTime? endDate
  }) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/notification/paging";

    final data = <String, dynamic>{
      'pageSize': pageSize,
    };

    if (pageIndex != null) {
      data['pageIndex'] = pageIndex;
    }

    if (receiverId != null && receiverId.isNotEmpty) {
      data['receiverId'] = receiverId;
    }
    if (senderId != null && senderId.isNotEmpty) {
      data['senderId'] = senderId;
    }
    if (type != null ) {
      data['type'] = type;
    }
    if (startDate != null) {
      data['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      data['endDate'] = endDate.toIso8601String();
    }

    final response = await DioClient().post(url, data: data);
    if (response.data == null) return null;
    return PagingResponse<NotificationApp>.fromJson(
      response.data,
          (json) => NotificationApp.fromJson(json),
    );

  }


  Future<List<Account>> fetchSenders({required NotificationType type}) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/notification/getAllSenders";
    final response = await DioClient().post(url, data: {'type': type});

    if (response.data == null || response.data is! List) return [];

    return (response.data as List)
        .map((e) => Account.fromJson(e))
        .toList();
  }

  Future<List<Account>> fetchReceivers({required NotificationType type}) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/notification/getAllReceivers";
    final response = await DioClient().post(url, data: {'type': type});

    if (response.data == null || response.data is! List) return [];

    return (response.data as List)
        .map((e) => Account.fromJson(e))
        .toList();
  }

}
