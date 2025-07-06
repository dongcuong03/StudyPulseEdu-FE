import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../resources/constains/constants.dart';
import '../resources/utils/data_sources/dio_client.dart';
import '../resources/utils/data_sources/local.dart';
import '../resources/utils/helpers/helper_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthViewModel with HelperMixin {
  Future<String?> loginMobile({String? phone, String? password}) async {
    //temp
    final multiLang = await AppLocalizations.delegate
        .load(const Locale(AppConstants.APP_LANGUAGE));
    try {
      final body = {
        'phone': phone ?? '',
        'password': password ?? '',
      };
      final response = await DioClient().postLogin(
          "${ApiConstants.getBaseUrl}/api/auth/access-token",
          data: body);
      if (response.statusCode == 200 &&
          response.data?['accessToken'] != null &&
          response.data?['role'] != null) {
        final shared = await SharedPre.instance;
        await shared.setString(SharedPrefsConstants.ACCESS_TOKEN_KEY,
            response.data?['accessToken']);
        await shared.setString(
            SharedPrefsConstants.USER_ROLE_KEY, response.data?['role']);
        await shared.setString(SharedPrefsConstants.REFRESH_TOKEN_KEY,
            response.data?['refreshToken']);

        //call update fcm token
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await DioClient().patch(
            "${ApiConstants.getBaseUrl}/api/v1/account/update-fcm-token",
            queryParameters: {'fcmToken': fcmToken},
          );
        }
        return null;
      } else {
        final data = response.data;
        final message =
            (data is Map<String, dynamic>) ? data['message'] as String? : null;

        if (message != null) {
          if (message.contains('Số điện thoại không tồn tại')) {
            return 'Số điện thoại không tồn tại';
          }
          if (message.contains('Mật khẩu không chính xác')) {
            return 'Mật khẩu không chính xác';
          }
          return message;
        }
      }
    } catch (e) {
      print('Lỗi không xác định: $e');
      return 'Lỗi không xác định: $e';
    }
    return null;
  }

  Future<String?> loginWeb({String? phone, String? password}) async {
    //temp
    final multiLang = await AppLocalizations.delegate
        .load(const Locale(AppConstants.APP_LANGUAGE));
    try {
      final body = {
        'phone': phone ?? '',
        'password': password ?? '',
      };
      final response = await DioClient().postLogin(
          "${ApiConstants.getBaseUrl}/api/auth/access-token",
          data: body);
      if (response.statusCode == 200 &&
          response.data?['accessToken'] != null &&
          response.data?['role'] != null) {
        final shared = await SharedPre.instance;
        await shared.setString(SharedPrefsConstants.ACCESS_TOKEN_KEY,
            response.data?['accessToken']);
        await shared.setString(
            SharedPrefsConstants.USER_ROLE_KEY, response.data?['role']);
        await shared.setString(SharedPrefsConstants.REFRESH_TOKEN_KEY,
            response.data?['refreshToken']);

        return null;
      } else {
        final data = response.data;
        final message =
            (data is Map<String, dynamic>) ? data['message'] as String? : null;

        if (message != null) {
          if (message.contains('Số điện thoại không tồn tại')) {
            return 'Số điện thoại không tồn tại';
          }
          if (message.contains('Mật khẩu không chính xác')) {
            return 'Mật khẩu không chính xác';
          }
          return message;
        }
      }
    } catch (e) {
      print('Lỗi không xác định: $e');
      return 'Lỗi không xác định: $e';
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await DioClient().patch(
        "${ApiConstants.getBaseUrl}/api/v1/account/update-fcm-token",
        queryParameters: {'fcmToken': null},
      );
      final shared = await SharedPre.instance;
      await shared.remove(SharedPrefsConstants.ACCESS_TOKEN_KEY);
      await shared.remove(SharedPrefsConstants.USER_ROLE_KEY);
      await shared.remove(SharedPrefsConstants.REFRESH_TOKEN_KEY);
    } catch (e) {
      print("Logout error: $e");
    }
  }
}
