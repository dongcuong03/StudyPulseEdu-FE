import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_pulse_edu/models/app/Account.dart';
import 'package:study_pulse_edu/models/app/Student.dart';
import 'package:study_pulse_edu/viewmodels/mobile/account_mobile_view_model.dart';
import 'package:study_pulse_edu/views/mobile/user/home/widget/list_function_user_widget.dart';
import 'package:study_pulse_edu/views/mobile/user/home/widget/user_infor_widget.dart';

import '../../../../../resources/constains/constants.dart';
import '../../../../../resources/utils/app/app_theme.dart';
import '../../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../../routes/route_const.dart';
import '../../../../../viewmodels/auth_view_model.dart';

class HomeUserScreen extends ConsumerStatefulWidget {
  const HomeUserScreen({super.key});

  @override
  ConsumerState createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends ConsumerState<HomeUserScreen>
    with HelperMixin, SingleTickerProviderStateMixin {
  final _authViewModel = AuthViewModel();
  bool isLoading = false;
  Account? account;
  String accountName = "";
  String accountId = "";
  String parentCode = "";
  String accountPhone = "";

  List<Student> _students = [];
  List<Widget> _studentWidgets = [];
  late TabController _tabController;

  int _selectedIndex = 0;

  Future<void> _fetchCurrentAccount() async {
    setState(() => isLoading = true);
    showLoading(context, show: true);

    final fetchedAccount = await ref
        .read(accountMobileViewModelProvider.notifier)
        .fetchCurrentUser();

    if (fetchedAccount != null && fetchedAccount.parent != null) {
      final parent = fetchedAccount.parent!;
      _students = parent.students ?? [];
      _studentWidgets = _students.map((student) {
        return ListFunctionUserWidget(
          studentId: student.id,
          studentName: student.fullName,
          studentCode: student.studentCode,
        );
      }).toList();

      setState(() {
        account = fetchedAccount;
        accountName = parent.fullName ?? "";
        accountId = account?.id ?? "";
        accountPhone = account?.phone ?? "";
        parentCode = parent.verificationCode ?? "";
        _tabController = TabController(length: _students.length, vsync: this);
      });
    }

    showLoading(context, show: false);
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrentAccount();
  }

  @override
  void dispose() {
    if (_students.isNotEmpty) {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.orange.shade200,
                child: const Text(
                  'PH',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              accountName: Text(accountName,
                  style: AppTheme.headlineLarge
                      .copyWith(color: Colors.yellow.shade300, fontSize: 18)),
              accountEmail: Text(accountPhone),
              decoration: const BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title:
                  const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await showConfirmDialogMobile(
                  context: context,
                  title: 'Thông báo',
                  content: 'Bạn có muốn đăng xuất?',
                  icon: Icons.notifications,
                  confirmColor: Colors.blue,
                  onConfirm: () async {
                    await _authViewModel.logout();
                    goName(context, RouteConstants.loginMobileRouteName);
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: isLoading || account == null
          ? SizedBox.shrink()
          : SingleChildScrollView(
            child: Builder(
                builder: (scaffoldContext) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserInforWidget(
                      scaffoldContext: scaffoldContext,
                      accountName: accountName,
                      accountId: accountId,
                      parentCode: parentCode,
                    ),
                    SizedBox(height: 20.h),

                    /// Ảnh nền
                    Center(
                      child: Image.asset(
                        'assets/images/trang_chu_phu_huynh.png',
                        fit: BoxFit.cover,
                        height: 200.h,
                        width: 0.8.sw,
                      ),
                    ),
                    SizedBox(height: 30.h),

                    /// TabBar học sinh
                    DefaultTabController(
                      length: _students.length,
                      child: Column(
                        children: [
                          if (_students.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0, right: 16),
                              child: Container(
                                height: 45.h,
                                padding: EdgeInsets.zero,
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(_students.length, (index) {
                                      final student = _students[index];
                                      final isSelected = index == _selectedIndex;

                                      return Builder(
                                        builder: (itemContext) => GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedIndex = index;
                                              _tabController.animateTo(index);
                                            });
                                            _scrollToCenterFromContext(itemContext);
                                          },
                                          child: Container(
                                            width: 0.65.sw, // Chiều rộng gần bằng màn hình
                                            margin: EdgeInsets.symmetric(horizontal: 6.w),
                                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                            decoration: BoxDecoration(
                                              color: isSelected ? Colors.blue.shade500 : Colors.grey.shade200,
                                              borderRadius: BorderRadius.circular(20.r),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.person,
                                                    size: 18,
                                                    color: isSelected ? Colors.white : Colors.black87),
                                                SizedBox(width: 6.w),
                                                Text(
                                                  "${student.fullName} - ${student.studentCode ?? ''}",
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: isSelected ? Colors.white : Colors.black87,
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  )

                                ),
                              ),
                            ),

                          // Nội dung tab tương ứng
                          if (_students.isNotEmpty)
                            SizedBox(
                              height: 200.h,
                              child: TabBarView(
                                controller: _tabController,
                                physics: const NeverScrollableScrollPhysics(),
                                children: _studentWidgets,
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
          ),
    );
  }

  final ScrollController _scrollController = ScrollController();

  void _scrollToCenterFromContext(BuildContext itemContext) {
    final box = itemContext.findRenderObject() as RenderBox?;
    if (box == null) return;

    final offset = box.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = box.size.width;

    final targetOffset = _scrollController.offset + offset.dx + itemWidth / 2 - screenWidth / 2;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

}
