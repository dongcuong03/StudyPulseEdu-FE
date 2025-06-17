import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../resources/utils/app/app_theme.dart';
import '../../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../../resources/widgets/botton_wavy_clipper.dart';
import '../../../../../routes/route_const.dart';
class TeacherInforWidget extends ConsumerStatefulWidget {
  final BuildContext scaffoldContext;
  final String accountName;
  const TeacherInforWidget({required this.scaffoldContext,required this.accountName, super.key});


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
                  height: 130,
                  width: double.infinity,
                ),
              ),
              ClipPath(
                clipper: BottomWavyClipper(),
                child: Container(
                  color: AppTheme.primaryColor.withOpacity(0.7),
                  height: 120,
                  width: double.infinity,
                ),
              ),
              ClipPath(
                clipper: BottomWavyClipper(),
                child: Container(
                  color: AppTheme.primaryColor,
                  height: 110,
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipOval(
                            child: Image.asset(
                              'assets/images/logo2.png',
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _teacherInfoCard(widget.accountName),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
          // Có thể thêm nội dung khác ở đây
        ],
      ),
    );
  }
  Widget _teacherInfoCard(String? displayName) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // tách 2 bên
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin giáo viên
          Expanded( // chiếm phần trái
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
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12), // spacing giữa 2 phần
          _function(), // các nút icon bên phải
        ],
      ),
    );
  }

  int unreadCount = 3;

  Widget _function() {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, right: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              pushedName(context, RouteConstants.teacherMessageRouteName);
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  child: Image.asset(
                    'assets/images/message_icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: -5,
                    right: -2,
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Center(
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),


          const SizedBox(width: 16),

          // Nút Draw
          GestureDetector(
            onTap: () {

              Scaffold.of(widget.scaffoldContext).openEndDrawer();
            },
            child: Icon(Icons.menu, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

}
