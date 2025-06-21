import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_pulse_edu/models/app/Account.dart';
import 'package:study_pulse_edu/viewmodels/mobile/account_mobile_view_model.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/home/widget/list_function_teacher_widget.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/home/widget/teacher_infor_widget.dart';

import '../../../../resources/constains/constants.dart';
import '../../../../resources/utils/app/app_theme.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../routes/route_const.dart';
import '../../../../viewmodels/auth_view_model.dart';

class HomeTeacherScreen extends ConsumerStatefulWidget {
  const HomeTeacherScreen({super.key});

  @override
  ConsumerState createState() => _HomeTeacherScreenState();
}

class _HomeTeacherScreenState extends ConsumerState<HomeTeacherScreen>
    with HelperMixin {
  final _authViewModel = AuthViewModel();
  bool isLoading = false;
  late Account account;
  String accountName = "";
  String accountId = "";
  String accountPhone = "";
  String accountAvatarURL = "";

  void _fetchCurrentAccount() async {
    setState(() {
      isLoading = true;
    });

    showLoading(context, show: true);

    account = (await ref
        .read(accountMobileViewModelProvider.notifier)
        .fetchCurrentUser())!;

    if (account != null && account.teacher != null) {
      setState(() {
        accountName = account.teacher!.fullName ?? "";
        accountId = account.id ?? "";
        accountPhone = account.phone ?? "";
        accountAvatarURL = account.teacher!.avatarUrl != null
            ? "${ApiConstants.getBaseUrl}/uploads/${account.teacher!.avatarUrl}"
            : "";
      });
    }

    showLoading(context, show: false);
    setState(() {
      isLoading = false;
    });
  }


  @override
  void initState() {
    super.initState();
    _fetchCurrentAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: Column(
          children: [
            // Header chứa avatar + tên + số điện thoại
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(accountAvatarURL),
                backgroundColor: Colors.white,
              ),
              accountName: Text(accountName,
                  style: AppTheme.headlineLarge
                      .copyWith(color: Colors.yellow.shade300, fontSize: 18)),
              accountEmail: Text(accountPhone),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                final confirm = await showConfirmDialogMobile(
                  context: context,
                  title: 'Thông báo',
                  content: 'Bạn có muốn đăng xuất?',
                  icon: Icons.warning,
                  confirmColor: Colors.blue,
                  onConfirm: () async{
                    await _authViewModel.logout();
                    goName(context, RouteConstants.loginMobileRouteName);
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Builder(
        builder: (context) => SingleChildScrollView(
          child: isLoading
              ? SizedBox.shrink()
              : Column(
                  children: [
                    TeacherInforWidget(scaffoldContext: context, accountName: accountName.toString(), accountId: accountId),
                    SizedBox(height: 40.h),
                    Image.asset(
                      'assets/images/trang_chu_giao_vien.png',
                      fit: BoxFit.cover,
                      height: 200.h,
                      width: 0.8.sw,
                    ),
                    SizedBox(height: 40.h),
                    ListFunctionTeacherWidget(account: account,)
                  ],
                ),
        ),
      ),
    );
  }
}
