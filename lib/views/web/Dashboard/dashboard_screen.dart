import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../viewmodels/web/dashboard_view_model.dart';
import 'widget/class_per_teacher_chart.dart';
import 'widget/student_distribution_chart.dart';
import 'widget/statistic_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: dashboardAsync.when(data: (dashboard) => ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Thống kê
          Row(
            children: [
              Expanded(
                child: StatisticCard(
                  title: 'TÀI KHOẢN',
                  value: dashboard!.numberOfAccount.toString(),
                  imageUrl: 'assets/images/icon_account.png',
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: StatisticCard(
                  title: 'HỌC SINH',
                  value: dashboard.numberOfStudent.toString(),
                  imageUrl: 'assets/images/icon_student.png',
                  color: Colors.green,
                  size: 36,
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: StatisticCard(
                  title: 'GIÁO VIÊN',
                  value: dashboard.numberOfTeacher.toString(),
                  imageUrl: 'assets/images/icon_teacher.png',
                  color: Colors.orange,
                  size: 36,
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: StatisticCard(
                  title: 'LỚP HỌC',
                  value: dashboard.numberOfClass.toString(),
                  imageUrl: 'assets/images/icon_class.png',
                  color: Colors.purple,
                  size: 30,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Biểu đồ
          LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth;
              final double cardWidth = (maxWidth - 40) / 2; // trừ spacing

              return Wrap(
                spacing: 40, // khoảng cách giữa các card theo chiều ngang
                runSpacing: 24, // khoảng cách khi xuống dòng
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            spreadRadius: 1,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child:  ClassPerTeacherChart(data: dashboard.teacherClassCounts,),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            spreadRadius: 1,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child:  StudentDistributionChart(data: dashboard.classStudentCounts,),
                    ),
                  ),
                ],
              );
            },
          ),


        ],
      ), error: (err, stack) => Center(child: Text('Lỗi: $err')), loading: () => const Center(child: CircularProgressIndicator())),
    );
  }
}
