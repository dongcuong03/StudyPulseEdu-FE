import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_pulse_edu/models/app/Account.dart';

import '../../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../../routes/route_const.dart';

class ListFunctionUserWidget extends ConsumerWidget with HelperMixin {
  final String? studentId;
  final String? studentName;
  final String? studentCode;

  const ListFunctionUserWidget(
      {required this.studentId,
      required this.studentName,
      required this.studentCode,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      _FunctionItem(
        icon: Icons.calendar_month,
        label: 'Lịch học',
        onTap: () {
          pushedName(context, RouteConstants.userScheduleRouteName,
              extra: studentId);
        },
      ),
      _FunctionItem(
        icon: Icons.assignment,
        label: 'Bài tập',
        onTap: () {
          pushedName(context, RouteConstants.userAssignmentRouteName,
            extra: {
              "studentId": studentId,
              "studentName": studentName,
              "studentCode": studentCode,
            },);
        },
      ),
      _FunctionItem(
        icon: Icons.grade,
        label: 'Điểm',
        onTap: () {
          pushedName(context, RouteConstants.userScoreRouteName,
              extra: studentId);
        },
      ),
    ];

    return Padding(
      padding:  EdgeInsets.all(16.w),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        color: Colors.white,
        child: Padding(
          padding:  EdgeInsets.all(16.w),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            children:
                items.map((item) => _buildFunctionTile(context, item)).toList(),
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
            height: 40.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6.r,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(item.icon, color: Colors.white, size: 30.sp),
          ),
           SizedBox(height: 8.h),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style:  TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
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
