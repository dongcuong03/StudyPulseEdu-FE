import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/app/Account.dart';
import '../../resources/constains/constants.dart';
import '../../resources/utils/data_sources/dio_client.dart';

part 'account_mobile_view_model.g.dart';

@riverpod
class AccountMobileViewModel extends _$AccountMobileViewModel {
  @override
  FutureOr<Account?> build() async {
    return await fetchCurrentUser();
  }

  /// Call API lấy thông tin người dùng hiện tại
  Future<void> fetch() async {
    state = const AsyncLoading();

    try {
      final user = await fetchCurrentUser();
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
 //Call API getCurrentAccount
  Future<Account?> fetchCurrentUser() async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/account/getCurrentAccount";

    try {
      final response = await DioClient().get(url);

      if (response.statusCode == 200 && response.data != null) {
        return Account.fromJson(response.data);
      }
    } catch (e) {
      print('Error fetchCurrentUser: $e');
    }
    return null;
  }
}