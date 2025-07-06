import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_pulse_edu/views/web/Dashboard/dashboard_screen.dart';
import 'package:study_pulse_edu/views/web/account_management/account_management_screeen.dart';
import 'package:study_pulse_edu/views/web/class_management/class_management_screen.dart';
import 'package:study_pulse_edu/views/web/manage_notification_history/notification_history_screen.dart';
import 'package:study_pulse_edu/views/web/statistical_report/statistical_report_screen.dart';
import 'package:study_pulse_edu/views/web/tuition_management/tuition_management_screen.dart';

import '../../resources/utils/helpers/helper_mixin.dart';
import '../../routes/route_const.dart';
import '../../viewmodels/auth_view_model.dart';

class HomeAdminScreen extends ConsumerStatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  ConsumerState createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends ConsumerState<HomeAdminScreen>
    with HelperMixin {
  final _authViewModel = AuthViewModel();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;
  bool isHoveringLogout = false;
  int? hoveringMenuIndex;

  final List<String> menuItems = [
    'Trang chủ',
    'Quản lý tài khoản',
    'Quản lý lớp học',
    'Quản lý học phí',
    'Quản lý lịch sử thông báo',
    'Báo cáo thống kê',
  ];

  final List<IconData> menuIcons = [
    Icons.home,
    Icons.supervisor_account,
    Icons.class_,
    Icons.monetization_on_rounded,
    Icons.notifications_active,
    Icons.add_chart
  ];

  Widget getPage(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const AccountManagementScreeen();
      case 2:
        return const ClassManagementScreen();
      case 3:
        return const TuitionManagementScreen();
      case 4:
        return const NotificationHistoryScreen();
      case 5:
        return const StatisticalReportScreen();
      default:
        return const DashboardScreen();
    }
  }

  Widget buildLeftDrawer() {
    return Container(
      width: 250.w,
      color: const Color(0xFF25303C),
      child: Column(
        children: [
          Container(
            height: 180.h,
            width: double.infinity,
            color: const Color(0xFF25303C),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;
                final isHovering = hoveringMenuIndex == index;

                final iconColor = (isSelected || isHovering)
                    ? Colors.white
                    : Colors.grey[300];
                final textColor = (isSelected || isHovering)
                    ? Colors.white
                    : Colors.grey[300];

                return MouseRegion(
                  onEnter: (_) => setState(() => hoveringMenuIndex = index),
                  onExit: (_) => setState(() => hoveringMenuIndex = null),
                  child: AnimatedScale(
                    scale: isHovering ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      color: isSelected ? Colors.blue : const Color(0xFF25303C),
                      child: ListTile(
                        leading: Icon(menuIcons[index], color: iconColor),
                        title: Text(
                          menuItems[index],
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16.sp,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEndDrawer() {
    return Drawer(
      width: 300.w,
      backgroundColor: Colors.blueGrey[900],
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(32.w),
            color: Colors.blueGrey[900],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/anh_admin.png'),
                ),
                const SizedBox(height: 10),
                Text(
                  'Quản lý trung tâm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'dvc@gmail.com',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
          Divider(color: Colors.grey[400], thickness: 0.5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: MouseRegion(
              onEnter: (_) => setState(() => isHoveringLogout = true),
              onExit: (_) => setState(() => isHoveringLogout = false),
              child: AnimatedScale(
                scale: isHoveringLogout ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: () async {
                      Navigator.of(context).pop();

                      await showConfirmDialogWeb(
                        context: context,
                        title: 'Thông báo',
                        content: 'Bạn có muốn đăng xuất?',
                        icon: Icons.notifications,
                        onConfirm: () async {
                          await _authViewModel.logout();
                          goName(context, RouteConstants.loginWebRouteName);
                        },
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 12.h),
                      child: Row(
                        children: [
                          Icon(Icons.logout,
                              color: isHoveringLogout
                                  ? Colors.white
                                  : Colors.redAccent),
                          SizedBox(width: 10.w),
                          Text(
                            'Đăng xuất',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isHoveringLogout
                                  ? Colors.white
                                  : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Icon(
                Icons.menu,
                size: 30.w,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: buildEndDrawer(),
      body: Row(
        children: [
          buildLeftDrawer(),
          Expanded(
            child: Column(
              children: [
                buildAppBar(),
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: getPage(selectedIndex),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
