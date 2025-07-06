import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_pulse_edu/models/app/Account.dart';

import '../../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../../routes/route_const.dart';

class ListFunctionTeacherWidget extends ConsumerWidget with HelperMixin {
  final Account? account;

  const ListFunctionTeacherWidget({required this.account, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      _FunctionItem(
        icon: Icons.calendar_month,
        label: 'Lịch dạy',
        onTap: () {
          pushedName(context, RouteConstants.teacherScheduleRouteName,
              extra: account);
        },
      ),
      _FunctionItem(
        icon: Icons.class_,
        label: 'Lớp học',
        onTap: () {
          pushedName(context, RouteConstants.teacherClassRouteName,
              extra: account);
        },
      ),
      _FunctionItem(
        icon: Icons.assignment,
        label: 'Bài tập',
        onTap: () {
          pushedName(context, RouteConstants.teacherAssignmentRouteName,
              extra: account);
        },
      ),
      _FunctionItem(
        icon: Icons.grade,
        label: 'Điểm',
        onTap: () {
          pushedName(context, RouteConstants.teacherScoreRouteName,
              extra: account);
        },
      ),
      _FunctionItem(
        icon: Icons.how_to_reg,
        label: 'Điểm danh',
        onTap: () {
          pushedName(context, RouteConstants.teacherAttendanceRouteName,
              extra: account);
        },
      ),
      _FunctionItem(
        icon: Icons.bar_chart,
        label: 'Kết quả học tập',
        onTap: () {
          pushedName(context, RouteConstants.teacherAcademicResultRouteName,
              extra: account);
        },
      ),
    ];

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Wrap(
            spacing: 25.w,
            runSpacing: 25.h,
            alignment: WrapAlignment.center,
            children: items
                .map(
                  (item) => SizedBox(
                    width: 80.w,
                    child: _buildFunctionTile(context, item),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFunctionTile(BuildContext context, _FunctionItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Icon(item.icon, color: Colors.white, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _FunctionItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  _FunctionItem({
    required this.icon,
    required this.label,
    this.onTap,
  });
}
