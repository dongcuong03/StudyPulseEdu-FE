import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../routes/route_const.dart';
import '../../../../viewmodels/mobile/account_mobile_view_model.dart';
import '../../../../viewmodels/mobile/chat_view_model.dart';

class MessageTeacherScreen extends ConsumerStatefulWidget {
  final String? accountId;

  const MessageTeacherScreen({required this.accountId, super.key});

  @override
  ConsumerState createState() => _MessageTeacherScreenState();
}

class _MessageTeacherScreenState extends ConsumerState<MessageTeacherScreen>
    with HelperMixin {
  bool isLoading = true;
  List<Map<String, String>> parents = [];
  String searchText = "";

  Stream<List<Map<String, dynamic>>>? chatStream;

  @override
  void initState() {
    super.initState();
    _fetchParents();
    chatStream = ref
        .read(chatViewModelProvider.notifier)
        .listenToRecentChats(widget.accountId!);
  }

  @override
  void didUpdateWidget(covariant MessageTeacherScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accountId != widget.accountId) {
      chatStream = ref
          .read(chatViewModelProvider.notifier)
          .listenToRecentChats(widget.accountId!);
      setState(() {}); // Cập nhật lại UI với stream mới
    }
  }

  void _fetchParents() async {
    final result = await ref
        .read(accountMobileViewModelProvider.notifier)
        .getParentsOfMyStudents(widget.accountId ?? '');
    setState(() {
      parents = result
          .map((account) => {
                "id": account.id ?? "",
                "name": account.parent?.fullName ?? "",
              })
          .toList();
      isLoading = false;
    });
  }

  String _shortenName(String fullName) {
    final words = fullName.trim().split(" ");
    if (words.length <= 2) return fullName;
    return "${words.take(2).join(" ")}...";
  }

  String _formatTime(String iso) {
    try {
      final date = DateTime.parse(iso);
      final now = DateTime.now();

      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      return isToday
          ? DateFormat('HH:mm').format(date)
          : DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredParents = parents
        .where(
            (p) => p["name"]!.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liên lạc', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(10),
                    shadowColor: Colors.black.withOpacity(0.2),
                    child: TextField(
                      onChanged: (value) {
                        setState(() => searchText = value);
                      },
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        hintText: 'Tìm kiếm phụ huynh...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 0.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 0.5),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    itemCount: filteredParents.length,
                    itemBuilder: (context, index) {
                      final parent = filteredParents[index];
                      return GestureDetector(
                        onTap: () {
                          pushedName(
                            context,
                            RouteConstants.teacherMessageDetailRouteName,
                            extra: {
                              "accountId": widget.accountId,
                              "accountParentId": parent['id'],
                              "parentName": parent['name'],
                              "onClose": () {
                                // ref.read(chatViewModelProvider.notifier).setCurrentChatUser(
                                //     myAccountId: widget.accountId!, chattingWithId: null);
                              },
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.blue.shade300,
                                child: const Text(
                                  'PH',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _shortenName(parent["name"] ?? ""),
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Divider(height: 20, color: Colors.grey.shade400),
                ),
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: chatStream,
                    builder: (context, snapshot) {
                      final chats = snapshot.data;
                      if (chats == null || chats.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return ListView.separated(
                        itemCount: chats.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: Colors.grey.shade400),
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          final parent = parents.firstWhere(
                            (p) => p['id'] == chat['partnerId'],
                            orElse: () => {
                              "id": chat['partnerId'],
                              "name": chat['partnerId'],
                            },
                          );

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade300,
                              child: const Text(
                                'PH',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              parent["name"] ?? "",
                              style: TextStyle(
                                fontWeight: (chat['unreadCount'] ?? 0) > 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              chat["lastMessage"] ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: (chat['unreadCount'] ?? 0) > 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: Text(
                              _formatTime(chat["timestamp"] ?? ""),
                              style: const TextStyle(fontSize: 12),
                            ),
                            onTap: () {
                              pushedName(
                                context,
                                RouteConstants.teacherMessageDetailRouteName,
                                extra: {
                                  "accountId": widget.accountId,
                                  "accountParentId": chat["partnerId"],
                                  "parentName": parent["name"],
                                  "onClose": () {
                                    // ref.read(chatViewModelProvider.notifier).setCurrentChatUser(
                                    //     myAccountId: widget.accountId!, chattingWithId: null);
                                  },
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
