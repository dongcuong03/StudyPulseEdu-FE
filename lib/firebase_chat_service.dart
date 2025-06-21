import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseChatService {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://studypulseedu-52567-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://studypulseedu-52567-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  /// Tạo conversationId cố định giữa 2 tài khoản
  String generateConversationId(String id1, String id2) {
    final sorted = [id1, id2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Gửi tin nhắn
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String? attachmentUrl,
  }) async {
    final conversationId = generateConversationId(senderId, receiverId);
    final newMessageRef = _db.child('messages/$conversationId').push();
    final timestamp = DateTime.now().toIso8601String();

    // Gửi tin nhắn vào messages
    await newMessageRef.set({
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'attachmentUrl': attachmentUrl,
      'timestamp': timestamp,
      'isRead': false,
    });

    // Cập nhật vào chats của cả 2 người
    await _db.update({
      'chats/$senderId/$receiverId': {
        'lastMessage': content,
        'lastMessageSenderId': senderId,
        'timestamp': timestamp,
        'unreadCount': 0, // Người gửi không có tin chưa đọc
      },
      'chats/$receiverId/$senderId/lastMessage': content,
      'chats/$receiverId/$senderId/lastMessageSenderId': senderId,
      'chats/$receiverId/$senderId/timestamp': timestamp,
      'chats/$receiverId/$senderId/unreadCount': ServerValue.increment(1),
    });
  }

  /// Lắng nghe tin nhắn theo conversationId
  Stream<List<Map<String, dynamic>>> listenToMessages({
    required String userId1,
    required String userId2,
  }) {
    final conversationId = generateConversationId(userId1, userId2);
    return _db.child('messages/$conversationId').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];

      final messages = data.entries.map((entry) {
        final msg = Map<String, dynamic>.from(entry.value);
        msg['id'] = entry.key;
        return msg;
      }).toList();

      messages.sort((a, b) =>
          DateTime.parse(a['timestamp']).compareTo(DateTime.parse(b['timestamp'])));
      return messages;
    });
  }

  /// Đánh dấu tin nhắn là đã đọc
  Future<void> markMessageAsRead({
    required String senderId,
    required String receiverId,
    required String messageId,
  }) async {
    final conversationId = generateConversationId(senderId, receiverId);
    await _db.child('messages/$conversationId/$messageId/isRead').set(true);

    // Reset số tin chưa đọc
    await _db.child('chats/$receiverId/$senderId/unreadCount').set(0);
  }

  /// Lắng nghe danh sách các cuộc trò chuyện gần đây của user
  Stream<List<Map<String, dynamic>>> listenToRecentChats(String currentUserId) {
    return _db.child('chats/$currentUserId').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];

      final chats = data.entries.map((entry) {
        final chatData = Map<String, dynamic>.from(entry.value);
        final partnerId = entry.key;
        final lastSenderId = chatData['lastMessageSenderId'] ?? '';
        final isFromMe = lastSenderId == currentUserId;

        return {
          'partnerId': partnerId,
          'lastMessage': isFromMe
              ? "Bạn: ${chatData['lastMessage'] ?? ''}"
              : chatData['lastMessage'] ?? '',
          'timestamp': chatData['timestamp'],
          'unreadCount': chatData['unreadCount'] ?? 0,
        };
      }).toList();

      chats.sort((a, b) => DateTime.parse(b['timestamp'])
          .compareTo(DateTime.parse(a['timestamp'])));

      return chats;
    });
  }

  /// Đánh dấu tất cả tin nhắn là đã đọc
  Future<void> markAllMessagesAsRead({
    required String senderId,
    required String receiverId,
  }) async {
    final conversationId = _getConversationId(senderId, receiverId);
    final messagesRef = _db.child('messages').child(conversationId);

    final snapshot = await messagesRef.get();

    for (final child in snapshot.children) {
      final msg = Map<String, dynamic>.from(child.value as Map);
      if (msg['receiverId'] == receiverId && msg['isRead'] == false) {
        await child.ref.update({'isRead': true});
      }
    }

    /// Reset unreadCount về 0 trong 'chats'
    final chatRef = _db.child('chats').child(receiverId).child(senderId);
    await chatRef.update({'unreadCount': 0});
  }

// Helper tạo conversation ID thống nhất
  String _getConversationId(String id1, String id2) {
    final sorted = [id1, id2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }
  /// Đếm số tin nhắn chưa đọc gửi đến user từ tất cả người gửi
  Stream<int> listenTotalUnreadCount(String receiverId) {
    final messagesRef = _db.child('messages');

    return messagesRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return 0;

      int unreadCount = 0;

      for (var conversation in data.values) {
        if (conversation is Map) {
          final messages = Map<String, dynamic>.from(conversation);
          for (var msg in messages.values) {
            final m = Map<String, dynamic>.from(msg);
            final isRead = m['isRead'] ?? false;
            final toId = m['receiverId'];

            if (toId == receiverId && isRead == false) {
              unreadCount++;
            }
          }
        }
      }

      return unreadCount;
    });
  }

  /// Cập nhật trạng thái đang chat với ai (ví dụ: khi mở màn chat)
  Future<void> setCurrentChatUserOnFirebase(String userId, String? chattingWithId) async {
    await _db.child('currentChats/$userId').set(chattingWithId);
  }

  /// Lấy trạng thái người nhận đang chat với ai
  Future<String?> getCurrentChatUserFromFirebase(String userId) async {
    final snapshot = await _db.child('currentChats/$userId').get();
    return snapshot.value as String?;
  }

}
