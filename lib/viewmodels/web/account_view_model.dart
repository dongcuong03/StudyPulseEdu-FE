import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/app/Account.dart';
import '../../models/app/PagingResponse.dart';
import '../../models/app/Parent.dart';
import '../../models/app/Teacher.dart';
import '../../resources/constains/constants.dart';
import '../../resources/utils/data_sources/dio_client.dart';
import 'dart:html' as html;
import 'package:http_parser/http_parser.dart';
part 'account_view_model.g.dart';

@riverpod
class AccountViewModel extends _$AccountViewModel {
  static const int defaultPageSize = 10;

  int _currentPageIndex = 1;

  @override
  FutureOr<PagingResponse<Account>?> build() async {
    return await _fetchAccounts(pageIndex: _currentPageIndex, pageSize: defaultPageSize);
  }

  Future<void> fetchAccounts({
    int? pageIndex,
    int pageSize = defaultPageSize,
    String? phone,
  }) async {
    state = const AsyncLoading();

    if (pageIndex != null) {
      _currentPageIndex = pageIndex;
    }


    try {
      final pagingResponse = await _fetchAccounts(
        pageIndex: pageIndex,
        pageSize: pageSize,
        phone: phone,
      );
      state = AsyncData(pagingResponse);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // Call API paging
  Future<PagingResponse<Account>?> _fetchAccounts({
    int? pageIndex,
    int pageSize = defaultPageSize,
    String? phone,
  }) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/account/paging";

    final data = <String, dynamic>{
      'pageSize': pageSize,
    };

    if (pageIndex != null) {
      data['pageIndex'] = pageIndex;
    }

    if (phone != null && phone.isNotEmpty) {
      data['phone'] = phone;
    }

    final response = await DioClient().post(url, data: data);
    if (response.data == null) return null;
    return PagingResponse<Account>.fromJson(
      response.data,
          (json) => Account.fromJson(json),
    );

  }

  //Call API disableAccount
  Future<bool> disableAccount(String id) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/account/disableAccount/$id";

    try {
      final response = await DioClient().put(url);
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print("Error disableAccount: $e");
    }
    return false;
  }

  //Call API enableAccount
  Future<bool> enableAccount(String id) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/account/enableAccount/$id";

    try {
      final response = await DioClient().put(url); // trả về bool
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print("Error enableAccount: $e");
    }
    return false;
  }

//Call API createAccount

  Future<String?> createAccount({
    required Account account,
    html.File? avatarFile,
  }) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/account/create";

    try {
      final jsonData = jsonEncode(account.toJson());

      final formMap = <String, dynamic>{
        "data": MultipartFile.fromString(
          jsonData,
          contentType: MediaType('application', 'json'),
        ),
      };


      if (avatarFile != null) {
        final reader = html.FileReader();
        reader.readAsDataUrl(avatarFile);
        await reader.onLoad.first;

        final dataUrl = reader.result as String;
        // dataUrl ví dụ: data:image/png;base64,iVBORw0KGgoAAAANS...

        final base64Str = dataUrl.split(',').last; // tách phần base64

        final fileBytes = base64Decode(base64Str); // decode base64 thành bytes

        final multipartFile = MultipartFile.fromBytes(
          fileBytes,
          filename: avatarFile.name,
        );

        formMap['file'] = multipartFile;

      formMap['file'] = multipartFile;
      }
      print("formMap: $formMap");
      final formData = FormData.fromMap(formMap);
      // Gọi API với isMultipart = true
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
        final message = e.response?.data['message'] ?? 'Đã xảy ra lỗi không xác định';
        return message;
      } else {
        return 'Lỗi không xác định: $e';
      }
    }
  }


  //Call Api updateAcount
  Future<String?> updateAccount({
    required String accountId,
    required Account account,
    html.File? avatarFile,
  }) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/account/update/$accountId";

    try {
      final jsonData = jsonEncode(account.toJson());

      final formMap = <String, dynamic>{
        "data": MultipartFile.fromString(
          jsonData,
          contentType: MediaType('application', 'json'),
        ),
      };

      if (avatarFile != null) {
        final reader = html.FileReader();
        reader.readAsDataUrl(avatarFile);
        await reader.onLoad.first;

        final dataUrl = reader.result as String;
        final base64Str = dataUrl.split(',').last;

        final fileBytes = base64Decode(base64Str);

        final multipartFile = MultipartFile.fromBytes(
          fileBytes,
          filename: avatarFile.name,
        );

        formMap['file'] = multipartFile;
      }

      final formData = FormData.fromMap(formMap);

      final response = await DioClient().put(
        url,
        data: formData,
        isMultipart: true,
      );
     print(response);
      if (response.statusCode == 200) {
        return null;
      }
    } catch (e) {
      if (e is DioException) {
        final message = e.response?.data['message'] ?? 'Đã xảy ra lỗi không xác định';
        return message;
      } else {
        return 'Lỗi không xác định: $e';
      }
    }
    return 'Cập nhật thất bại';
  }


  //Call Api getAccountById
  Future<Account?> getAccountById(String id) async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/account/$id";
    try {
      final response = await DioClient().get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        return Account.fromJson(data);
      }
    } catch (e) {
      print('Error getAccountById: $e');
    }
    return null;
  }

  // Call API getAllAccountTeacher
  Future<List<Account>> getAllAccountTeacher() async {
    final url = "${ApiConstants.getBaseUrl}/api/v1/account/getAllAccountTeacher";

    try {
      final response = await DioClient().get(url);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => Account.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error getAllTeacherAccounts: $e");
    }
    return [];
  }
}
