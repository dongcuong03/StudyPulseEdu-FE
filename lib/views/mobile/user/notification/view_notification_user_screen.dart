import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:study_pulse_edu/models/app/NotificationApp.dart';

import '../../../../models/app/Account.dart';
import '../../../../resources/constains/constants.dart';
import '../../../../viewmodels/mobile/notification_mobile_use_view_model.dart';

class ViewNotificationUserScreen extends ConsumerStatefulWidget {
  final VoidCallback? onClose;
  final NotificationApp? notificationApp;

  const ViewNotificationUserScreen({
    required this.onClose,
    required this.notificationApp,
    super.key,
  });

  @override
  ConsumerState createState() => _ViewNotificationUserScreenState();
}

class _ViewNotificationUserScreenState extends ConsumerState<ViewNotificationUserScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final notification = widget.notificationApp;
    if (notification == null) {
      return const Scaffold(
        body: Center(child: Text("Không có dữ liệu thông báo")),
      );
    }

    final teacher = notification.sender?.teacher;
    final student = notification.student;
    final avatarUrl = teacher?.avatarUrl != null
        ? "${ApiConstants.getBaseUrl}/uploads/${teacher?.avatarUrl}"
        : null;
    final teacherName = teacher?.fullName ?? '';
    final studentName = student?.fullName ?? '';
    final studentCode = student?.studentCode ?? '';
    final createdAt = notification.createdAt != null
        ? DateFormat('HH:mm, dd/MM/yyyy').format(notification.createdAt!)
        : '';
    final title = notification.title ?? '';
    final message = notification.message ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Xem thông báo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onClose?.call();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Giáo viên avatar + tên + ngày
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundImage: NetworkImage(avatarUrl!)

                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacherName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        createdAt,
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

              ],
            ),

            SizedBox(height: 30.h),

            // Tiêu đề
            Text(
              title,
              style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w500, color: Colors.teal),
            ),

            SizedBox(height: 12.h),

            // Nội dung message
            Text(
              message,
              style: TextStyle(fontSize: 15.sp, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
