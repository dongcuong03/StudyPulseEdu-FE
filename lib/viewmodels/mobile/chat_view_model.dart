import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:study_pulse_edu/resources/utils/data_sources/dio_client.dart';

import '../../firebase_chat_service.dart';
import '../../resources/constains/constants.dart';


part 'chat_view_model.g.dart';

@riverpod
class ChatViewModel extends _$ChatViewModel {
  final _chatService = FirebaseChatService();

  @override
  void build() {
  }
  String? _currentChatUserId;

  /// Set người đang chat
  Future<void> setCurrentChatUser({
    required String myAccountId,
    required String? chattingWithId,
  }) async {
    _currentChatUserId = chattingWithId;

    if (chattingWithId != null) {
      await _chatService.setCurrentChatUserOnFirebase(myAccountId, chattingWithId);
    }
  }


  /// Get người đang chat
  String? get currentChatUserId => _currentChatUserId;

  /// Gửi tin nhắn
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String? attachmentUrl,
  }) async {
    await _chatService.sendMessage(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      attachmentUrl: attachmentUrl,
    );
    final chattingWith = await _chatService.getCurrentChatUserFromFirebase(receiverId);
    if (chattingWith != senderId) {
      await sendPushNotification(
        receiverId: receiverId,
        title: 'Bạn có tin nhắn mới',
        message: null,
        data: {
          'type': 'CHAT',
          'senderId': senderId,
          'receiverId': receiverId,
        },
      );
    }
  }

  /// Lắng nghe tin nhắn theo conversation
  Stream<List<Map<String, dynamic>>> listenMessages({
    required String userId1,
    required String userId2,
  }) {
    return _chatService.listenToMessages(
      userId1: userId1,
      userId2: userId2,
    );
  }

  /// Đánh dấu đã đọc
  Future<void> markMessageAsRead({
    required String senderId,
    required String receiverId,
    required String messageId,
  }) async {
    await _chatService.markMessageAsRead(
      senderId: senderId,
      receiverId: receiverId,
      messageId: messageId,
    );
  }

  /// Lắng nghe danh sách cuộc trò chuyện gần đây
  Stream<List<Map<String, dynamic>>> listenToRecentChats(String currentUserId) {
    return _chatService.listenToRecentChats(currentUserId);
  }

  Future<void> markAllMessagesAsRead({
    required String senderId,
    required String receiverId,
  }) async {
    await _chatService.markAllMessagesAsRead(senderId: senderId, receiverId: receiverId);
  }

  /// Đếm số tin nhắn chưa đọc gửi đến giáo viên từ tất cả người gửi
  Stream<int> listenUnreadMessageCount(String receiverId) {
    return _chatService.listenTotalUnreadCount(receiverId);
  }

  Future<void> sendPushNotification({
    required String receiverId,
    required String title,
    String? message,
    Map<String, String>? data,
  }) async {
    try {
      final response = await DioClient().post(
        "${ApiConstants.getBaseUrl}/api/v1/fcm/send",
        data: {
          "receiverId": receiverId,
          "title": title,
          "message": message ?? '',
          "data": data ?? {},
        },
      );

      if (response.statusCode != 200) {
        print('Gửi push thất bại');
      } else {
        print('Gửi push thành công!');
      }
    } catch (e) {
      print('Lỗi gửi push: $e');
    }
  }

  Future<void> uploadAndSendFileMessage({
    required String senderId,
    required String receiverId,
    required File file,
  }) async {
    try {
      final fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await DioClient().postFile(
        "${ApiConstants.getBaseUrl}/api/v1/file/save",
        data: formData,
        isMultipart: true,
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        final attachmentUrl = response.data ?? '';

        await sendMessage(
          senderId: senderId,
          receiverId: receiverId,
          content: "Đã gửi 1 file",
          attachmentUrl: attachmentUrl,
        );
      } else {
        print("Upload thất bại: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi không xác định: $e");

    }
  }


}
