import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../resources/utils/app/app_theme.dart';
import '../../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../../resources/widgets/botton_wavy_clipper.dart';
import '../../../../../routes/route_const.dart';
import '../../../../../viewmodels/mobile/chat_view_model.dart';

class TeacherInforWidget extends ConsumerStatefulWidget {
  final BuildContext scaffoldContext;
  final String accountName;
  final String accountId;

  const TeacherInforWidget(
      {required this.scaffoldContext,
      required this.accountName,
      required this.accountId,
      super.key});

  @override
  ConsumerState createState() => _TeacherInforWidgetState();
}

class _TeacherInforWidgetState extends ConsumerState<TeacherInforWidget>
    with HelperMixin {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              ClipPath(
                clipper: BottomWavyClipper(),
                child: Container(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  height: 130.h,
                  width: double.infinity,
                ),
              ),
              ClipPath(
                clipper: BottomWavyClipper(),
                child: Container(
                  color: AppTheme.primaryColor.withOpacity(0.7),
                  height: 120.h,
                  width: double.infinity,
                ),
              ),
              ClipPath(
                clipper: BottomWavyClipper(),
                child: Container(
                  color: AppTheme.primaryColor,
                  height: 110.h,
                  padding:
                      EdgeInsets.symmetric(vertical: 30.h, horizontal: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipOval(
                            child: Image.asset(
                              'assets/images/logo2.png',
                              width: 45.w,
                              height: 45.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          _teacherInfoCard(widget.accountName),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teacherInfoCard(String? displayName) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.h),
                Text(
                  "Xin chào!",
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
                ),
                SizedBox(height: 4.h),
                Text(
                  displayName ?? '',
                  style: AppTheme.headlineLarge.copyWith(
                    color: Colors.yellow.shade300,
                    fontSize: 18.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          _function(),
        ],
      ),
    );
  }

  Widget _function() {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, right: 16.w),
      child: Row(
        children: [
          StreamBuilder<int>(
            stream: ref
                .read(chatViewModelProvider.notifier)
                .listenUnreadMessageCount(widget.accountId),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return GestureDetector(
                onTap: () {
                  pushedName(context, RouteConstants.teacherMessageRouteName,
                      extra: widget.accountId);
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(
                      'assets/images/message_icon.png',
                      width: 30.w,
                      height: 30.h,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: -5.h,
                        right: -2.w,
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          constraints:
                              BoxConstraints(minWidth: 16.w, minHeight: 16.h),
                          child: Center(
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          SizedBox(width: 16.w),
          GestureDetector(
            onTap: () {
              Scaffold.of(widget.scaffoldContext).openEndDrawer();
            },
            child: Icon(Icons.menu, color: Colors.white, size: 26.sp),
          ),
        ],
      ),
    );
  }
}
