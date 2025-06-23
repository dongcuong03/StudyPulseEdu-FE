import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';
import 'package:study_pulse_edu/views/web/manage_notification_history/Widget/Table_notification_widget.dart';

import '../../../resources/utils/helpers/helper_mixin.dart';

class NotificationHistoryScreen extends ConsumerStatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  ConsumerState createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends ConsumerState<NotificationHistoryScreen>
    with HelperMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(text: 'Lịch sử thông báo điểm'),
    Tab(text: 'Lịch sử thông báo điểm danh'),
    Tab(text: 'Lịch sử thông báo học phí'),
    Tab(text: 'Lịch sử thông báo kết quả học tập'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            tabs: _tabs,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.black87,
            indicatorColor: Colors.blue,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TableNotificationWidget(type: NotificationType.SCORE, isAdmin: false,),
          TableNotificationWidget(type: NotificationType.ATTENDANCE, isAdmin: false),
          TableNotificationWidget(type: NotificationType.TUITION,isAdmin: true),
          TableNotificationWidget(type: NotificationType.RESULT,isAdmin: false),

        ],
      ),
    );
  }

  Widget _buildListView(String title) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text('$title - #$index'),
            subtitle: Text('Nội dung thông báo mẫu'),
          ),
        );
      },
    );
  }
}
