import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_pulse_edu/views/web/statistical_report/widget/academic_result_report_tap.dart';
import 'package:study_pulse_edu/views/web/statistical_report/widget/tuition_fee_report_tab.dart';

import '../../../resources/utils/helpers/helper_mixin.dart';

class StatisticalReportScreen extends ConsumerStatefulWidget {
  const StatisticalReportScreen({super.key});

  @override
  ConsumerState createState() => _StatisticalReportScreenState();
}

class _StatisticalReportScreenState extends ConsumerState<StatisticalReportScreen>
    with HelperMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(text: 'Báo cáo học phí'),
    Tab(text: 'Báo cáo kết quả học tập'),
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
          child: Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
            ),
            child: TabBar(
              controller: _tabController,
              tabs: _tabs,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black87,
              indicatorColor: Colors.blue,
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          TuitionFeeReportTab(),
          AcademicResultReportTab(),
        ],
      ),
    );
  }
}
