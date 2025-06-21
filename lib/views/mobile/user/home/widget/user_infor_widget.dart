import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_pulse_edu/viewmodels/mobile/count_notification_mobile_user_view_model.dart';

import '../../../../../resources/utils/app/app_theme.dart';
import '../../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../../resources/widgets/botton_wavy_clipper.dart';
import '../../../../../resources/widgets/show_parent_verification_dialog.dart';
import '../../../../../routes/route_const.dart';
import '../../../../../viewmodels/mobile/chat_view_model.dart';

class UserInforWidget extends ConsumerStatefulWidget {
  final BuildContext scaffoldContext;
  final String accountName;
  final String parentCode;
  final String accountId;

  const UserInforWidget(
      {required this.scaffoldContext,
      required this.accountName,
      required this.parentCode,
      required this.accountId,
      super.key});

  @override
  ConsumerState createState() => _UserInforWidgetState();
}

class _UserInforWidgetState extends ConsumerState<UserInforWidget>
    with HelperMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(countNotificationMobileUserViewModelProvider.notifier)
          .refreshUnreadCount(widget.accountId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadNotifyState =
        ref.watch(countNotificationMobileUserViewModelProvider);
    final unreadNotify = unreadNotifyState.asData?.value ?? 0;

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
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
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
                          _userInfoCard(
                              widget.accountName, unreadNotify),
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

  Widget _userInfoCard(
      String? displayName, int unreadNotify) {
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
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12), // spacing giữa 2 phần
          _function(unreadNotify), // các nút icon bên phải
        ],
      ),
    );
  }

  Widget _function(int unreadNotify) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, right: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          StreamBuilder<int>(
            stream: ref.read(chatViewModelProvider.notifier).listenUnreadMessageCount(widget.accountId),
            builder: (context, snapshot) {
              final unreadMessage = snapshot.data ?? 0;
              return GestureDetector(
                onTap: () async {
                  final code = await showParentVerificationDialog(context);
                  if (code != null) {
                    if (code == widget.parentCode.toString()) {
                      pushedName(context, RouteConstants.userMessageRouteName,
                          extra: widget.accountId);
                    } else {
                      showErrorToast("Mã xác nhận phụ huynh không chính xác");
                    }
                  }
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(
                      'assets/images/message_icon.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                    if (unreadMessage > 0)
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
                              unreadMessage > 9 ? '9+' : '$unreadMessage',
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
              );
            },
          ),


          const SizedBox(width: 16),
          GestureDetector(
            onTap: () async {
              final code = await showParentVerificationDialog(context);
              if (code != null) {
                if (code == widget.parentCode.toString()) {
                  pushedName(
                    context,
                    RouteConstants.userNotificationRouteName,
                    extra: {
                      "accountId": widget.accountId,
                      "onClose": () {
                        ref.read(countNotificationMobileUserViewModelProvider.notifier).refreshUnreadCount(widget.accountId);
                      },
                    },
                  );
                } else {
                  showErrorToast("Mã xác nhận phụ huynh không chính xác");
                }
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  child: Icon(
                    Icons.notifications,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                if (unreadNotify > 0)
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
                          unreadNotify > 9 ? '9+' : '$unreadNotify',
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
