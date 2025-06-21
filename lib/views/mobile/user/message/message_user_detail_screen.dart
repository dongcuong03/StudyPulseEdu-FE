import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:study_pulse_edu/resources/utils/helpers/helper_mixin.dart';

import '../../../../resources/constains/constants.dart';
import '../../../../viewmodels/mobile/chat_view_model.dart';

class MessageUserDetailScreen extends ConsumerStatefulWidget {
  final String? accountTeacherId;
  final String? teacherName;
  final String? accountId;
  final VoidCallback? onClose;

  const MessageUserDetailScreen({
    super.key,
    required this.accountTeacherId,
    required this.teacherName,
    required this.accountId,
    required this.onClose,
  });

  @override
  ConsumerState createState() => _MessageUserDetailScreenState();
}

class _MessageUserDetailScreenState extends ConsumerState<MessageUserDetailScreen> with HelperMixin{

  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    final text = messageController.text.trim();
    if (text.isNotEmpty) {
      await ref.read(chatViewModelProvider.notifier).sendMessage(
        senderId: widget.accountId!,
        receiverId: widget.accountTeacherId!,
        content: text,
      );
      messageController.clear();
    }
  }


  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        final file = File(path);
        print("📄 Đã chọn file: ${file.path}");

        await ref.read(chatViewModelProvider.notifier).uploadAndSendFileMessage(
          senderId: widget.accountId!,
          receiverId: widget.accountTeacherId!,
          file: file,
        );
      } else {
        print("Không lấy được path từ file đã chọn");
      }
    } else {
      print("Không chọn file nào");
    }
  }



  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Đánh dấu đang chat với user nào
      ref.read(chatViewModelProvider.notifier).setCurrentChatUser(myAccountId: widget.accountId!, chattingWithId: widget.accountTeacherId);
    });
    ref.read(chatViewModelProvider.notifier).markAllMessagesAsRead(
      senderId: widget.accountTeacherId!,
      receiverId: widget.accountId!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = ref
        .watch(chatViewModelProvider.notifier)
        .listenMessages(userId1: widget.accountId!, userId2: widget.accountTeacherId!);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teacherName ?? '', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            widget.onClose?.call();
            context.pop();
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info_outline),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                final unreadFromParent = messages.any((msg) =>
                msg['senderId'] == widget.accountTeacherId && (msg['isRead'] != true));

                if (unreadFromParent) {
                  ref.read(chatViewModelProvider.notifier).markAllMessagesAsRead(
                    senderId: widget.accountTeacherId!,
                    receiverId: widget.accountId!,
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });
                final Map<String, List<Map<String, dynamic>>> grouped = {};
                for (var msg in messages) {
                  final date = DateTime.parse(msg['timestamp']);
                  final dateKey = _formatDate(date);
                  grouped.putIfAbsent(dateKey, () => []).add(msg);
                }

                final groupedEntries = grouped.entries.toList()
                  ..sort((a, b) =>
                      DateFormat('dd/MM/yyyy').parse(a.key).compareTo(DateFormat('dd/MM/yyyy').parse(b.key)));


                return ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  children: groupedEntries.expand((entry) {
                    final dateLabel = entry.key;
                    final dayMessages = entry.value;

                    return [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            dateLabel,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      ...dayMessages.map((msg) {
                        final fromMe = msg['senderId'] == widget.accountId;
                        final time = DateTime.parse(msg['timestamp']);
                        final attachmentUrl = msg['attachmentUrl'];
                        final hasFile = attachmentUrl != null && attachmentUrl.toString().isNotEmpty;
                        return Align(
                          alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            decoration: BoxDecoration(
                              color: fromMe ? Colors.blue.shade100 : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (hasFile)
                                  InkWell(
                                    onTap: () {
                                      downloadFile(attachmentUrl);
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.insert_drive_file, size: 18),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            Uri.parse(attachmentUrl).pathSegments.last,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Text(msg['content'] ?? ''),

                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(time),
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList()
                    ];
                  }).toList(),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickFile,
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void downloadFile(String url) async {
    final uri = Uri.parse(url.startsWith('http')
        ? url
        : "${ApiConstants.getBaseUrl}/uploads/$url");
    try {
      // Lấy thư mục Downloads
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final filePath = "${directory.path}/${uri.pathSegments.last}";

        // Tải tệp
        await Dio().download(uri.toString(), filePath);
        showSuccessToast("Tải File thành công: ");
      } else {
        showErrorToast("Không thể lấy thư mục lưu trữ.");
      }
    } catch (e) {
      showErrorToast("Lỗi: $e");
    }
  }
}