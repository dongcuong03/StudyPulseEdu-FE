import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationUserScreen extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const NotificationUserScreen({required this.onClose, super.key});

  @override
  ConsumerState createState() => _NotificationUserScreenState();
}

class _NotificationUserScreenState extends ConsumerState<NotificationUserScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(text: 'Điểm danh'),
    Tab(text: 'Điểm'),
    Tab(text: 'Học phí'),
    Tab(text: 'Kết quả'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông báo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white, // màu của nút quay lại
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: _tabs,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.blue,
              indicatorWeight: 3,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent('Thông báo điểm danh'),
                _buildTabContent('Thông báo điểm'),
                _buildTabContent('Thông báo học phí'),
                _buildTabContent('Thông báo kết quả học tập'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String title) {
    return Center(
      child: Text(
        title,
        style: TextStyle(fontSize: 16.sp),
      ),
    );
  }
}
