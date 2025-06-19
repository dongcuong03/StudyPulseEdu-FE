// Đầu file
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:study_pulse_edu/resources/utils/helpers/helper_mixin.dart';

import '../../../../models/app/Account.dart';
import '../../../../models/app/NotificationApp.dart';
import '../../../../resources/constains/constants.dart';
import '../../../../routes/route_const.dart';
import '../../../../viewmodels/mobile/notification_mobile_use_view_model.dart';

class NotificationUserScreen extends ConsumerStatefulWidget {
  final VoidCallback? onClose;
  final String? accountId;

  const NotificationUserScreen({required this.onClose, required this.accountId, super.key});

  @override
  ConsumerState createState() => _NotificationUserScreenState();
}

class _NotificationUserScreenState extends ConsumerState<NotificationUserScreen>
    with HelperMixin, TickerProviderStateMixin {
  late final TabController _tabController;
  final List<String> _tabTitles = ['Điểm danh', 'Điểm', 'Học phí', 'Kết quả'];
  final List<NotificationType> _types = [
    NotificationType.ATTENDANCE,
    NotificationType.SCORE,
    NotificationType.TUITION,
    NotificationType.RESULT,
  ];

  late List<int> _notificationCounts;
  late List<List<NotificationApp>> _notificationsByTab;
  late List<bool> _loadingTabs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _notificationCounts = List.filled(4, 0);
    _notificationsByTab = List.generate(4, (_) => []);
    _loadingTabs = List.filled(4, true);

    _loadAllNotifications();
  }

  Future<void> _loadAllNotifications() async {
    final viewModel = ref.read(notificationMobileUseViewModelProvider.notifier);
    final accountId = widget.accountId ?? '';

    for (int i = 0; i < _types.length; i++) {
      try {
        final result = await viewModel.fetchNotifications(
          accountId: accountId,
          type: _types[i],
        );
        setState(() {
          _notificationsByTab[i] = result;
          _notificationCounts[i] = result.where((e) => !e.isRead!).length;
          _loadingTabs[i] = false;
        });
      } catch (e) {
        print('Lỗi khi tải thông báo tab $i: $e');
        setState(() {
          _loadingTabs[i] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onClose?.call();
            context.pop();
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: List.generate(4, (index) {
                final count = _notificationCounts[index];
                return Tab(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Text(_tabTitles[index], style: TextStyle(fontSize: 14.sp)),
                      if (count > 0)
                        Positioned(
                          top: -9,
                          right: -18,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(minWidth: 18.w),
                            child: Text(
                              count > 9 ? '9+' : '$count',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.blue,
              indicatorWeight: 3,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(4, (index) {
                if (_loadingTabs[index]) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notifications = _notificationsByTab[index];
                if (notifications.isEmpty) {
                  return const Center(child: Text('Không có thông báo'));
                }

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, i) {
                    return _buildNotificationItem(notifications[i], index);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationApp notification, int tabIndex) {
    final teacherName = notification.sender?.teacher?.fullName;
    final teacherAvatarUrl =
        "${ApiConstants.getBaseUrl}/uploads/${notification.sender?.teacher?.avatarUrl}";
    final studentName = notification.student?.fullName;
    final studentCode = notification.student?.studentCode;
    final title = notification.title;
    final createdAt = notification.createdAt != null
        ? DateFormat('HH:mm, dd/MM/yyyy').format(notification.createdAt!)
        : '';

    return InkWell(
      onTap: () async {
        if (!notification.isRead!) {
          await ref.read(notificationMobileUseViewModelProvider.notifier)
              .markAsRead(notification.id ?? '');
          setState(() {
            notification.isRead = true;
            _notificationCounts[tabIndex]--;
          });
        }
        pushedName(
          context,
          RouteConstants.userViewNotificationRouteName,
          extra: {"notificationApp": notification},
        );
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: notification.isRead! ? Colors.white : Colors.blue[50],
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 24, backgroundImage: NetworkImage(teacherAvatarUrl)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(teacherName ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(createdAt,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Học sinh: $studentName - $studentCode',
                      style: const TextStyle(fontSize: 14, color: Colors.teal)),
                  const SizedBox(height: 6),
                  Text(title ?? '', style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

