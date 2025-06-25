import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../viewmodels/app_setting_view_model.dart';
import '../../constains/constants.dart';
import '../../widgets/base_screen/loading_view.dart';
import '../app/app_theme.dart';
import 'package:pinput/pinput.dart';

mixin HelperMixin {
  static final LoadingView loadingView = LoadingView();

  Future<TimeOfDay?> showTimePickerSpinnerDialog(BuildContext context, {TimeOfDay? initialTime}) async {
    DateTime selectedDateTime = DateTime(
      0,
      0,
      0,
      initialTime?.hour ?? 0,
      initialTime?.minute ?? 0,
    );

    return showDialog<TimeOfDay>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn giờ'),
          backgroundColor: Colors.white,
          content: SizedBox(
            height: 150,
            child: TimePickerSpinner(

              normalTextStyle: const TextStyle(fontSize: 18, color: Colors.grey),
              highlightedTextStyle: const TextStyle(fontSize: 24, color: Colors.black),
              spacing: 50,
              itemHeight: 50,
              time: selectedDateTime,
              isShowSeconds: false,
              onTimeChange: (time) {
                selectedDateTime = time;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Huỷ'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(TimeOfDay(hour: selectedDateTime.hour, minute: selectedDateTime.minute));
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,

              ),
              child: const Text('Chọn'),
            ),
          ],
        );
      },
    );
  }
  double getBodyHeight(BuildContext context) {
    return MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        AppConstants.APP_BAR_HEIGHT.h; // chuyển sang .h
  }

  void showLoading(BuildContext context, {required bool show, Color? color}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (show) {
        loadingView.show(context, color: color);
      } else {
        loadingView.hide();
      }
    });
  }

  void showLoadingWithDuration(BuildContext context, Duration duration) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadingView.show(context);
      Future.delayed(duration, () {
        loadingView.hide();
      });
    });
  }

  void pushedName(BuildContext context, String routeName, {Object? extra}) {
    showLoading(context, show: true);
    context.pushNamed(routeName, extra: extra);
    showLoading(context, show: false);
  }

  void goName(BuildContext context, String routeName, {Object? extra}) {
    context.goNamed(routeName, extra: extra);

  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
  }

  Widget loadingCenter(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  void dismissLoading(BuildContext context, String? isback) {
    if (loadingView != null) {
      loadingView!.hide();
    }
    if (isback != null) {
      backToScreen(context);
    }
  }

  backToScreen(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> modalBottomSheetMenu({
    required BuildContext context,
    required Widget child,
    bool isDrag = true,
  }) {
    return showModalBottomSheet(
        context: context,
        enableDrag: isDrag,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.r),
            topRight: Radius.circular(10.r),
          ),
        ),
        builder: (builder) {
          return child;
        });
  }

  void showSuccessToast(String msg, {Toast length = Toast.LENGTH_LONG}) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: length,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 15.sp);
  }

  void showErrorToast(String msg, {Toast length = Toast.LENGTH_LONG}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: length,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.deepOrangeAccent,
      textColor: Colors.white,
      fontSize: 15.sp,
    );
  }

  void showSuccessToastWeb(BuildContext context, String message) {
    final screenWidth = MediaQuery.of(context).size.width;
    late Flushbar flushbar;
    flushbar = Flushbar(
      titleText: Text('Thành công',
          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.black87, fontSize: 12),
      ),
      icon: const Icon(Icons.check_circle, color: Colors.green, size: 20),
      leftBarIndicatorColor: Colors.green,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      backgroundColor: const Color(0xFFCDF3D6),
      duration: const Duration(seconds: 3),

      margin: EdgeInsets.only(top: 16, right: 16, left: screenWidth * 0.75),

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      isDismissible: true,
      shouldIconPulse: false,
      showProgressIndicator: true,
      progressIndicatorValueColor:
          const AlwaysStoppedAnimation<Color>(Colors.green),
      progressIndicatorBackgroundColor: Colors.green.shade100,

      // 🔧 Hiệu ứng trượt từ phải sang
      animationDuration: const Duration(milliseconds: 500),
      forwardAnimationCurve: Curves.easeOutQuart,

      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(2, 2),
        ),
      ],
      mainButton: IconButton(
        icon: const Icon(Icons.close, color: Colors.black54),
        onPressed: () {
          flushbar.dismiss();
        },
      ),
    )..show(context);
  }

  void showErrorToastWeb(BuildContext context, String message) {
    final screenWidth = MediaQuery.of(context).size.width;
    late Flushbar flushbar;
    flushbar = Flushbar(
      titleText: Text('Lỗi',
          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.black87, fontSize: 12),
      ),
      icon: const Icon(Icons.error, color: Colors.red, size: 20),
      leftBarIndicatorColor: Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      backgroundColor: const Color(0xFFF6EEEE),
      duration: const Duration(seconds: 3),

      margin: EdgeInsets.only(top: 16, right: 16, left: screenWidth * 0.75),

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      isDismissible: true,
      shouldIconPulse: false,
      showProgressIndicator: true,
      progressIndicatorValueColor:
          const AlwaysStoppedAnimation<Color>(Colors.red),
      progressIndicatorBackgroundColor: Colors.red.shade100,

      // 🔧 Hiệu ứng trượt từ phải sang
      animationDuration: const Duration(milliseconds: 500),
      forwardAnimationCurve: Curves.easeOutQuart,

      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(2, 2),
        ),
      ],
      mainButton: IconButton(
        icon: const Icon(Icons.close, color: Colors.black54),
        onPressed: () {
          flushbar.dismiss();
        },
      ),
    )..show(context);
  }

  void showAlertDialog(BuildContext context, WidgetRef ref, String content) {
    final appSetting = ref.watch(appSettingViewModelProvider);
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Text(
          content,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontSize: appSetting.value?.smallTextSize.sp),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(
              'OK',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontSize: appSetting.value?.smallTextSize.sp),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  Future<void> showCenterPopUpDialog(
      BuildContext context, WidgetRef ref, Widget dialogModal) async {
    await showDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      context: context,
      builder: (context) {
        return Align(
          alignment: Alignment.center,
          child: dialogModal,
        );
      },
    );
  }

  Future<bool?> showConfirmDialogWeb({
    required BuildContext context,
    String title = 'Thông báo',
    String content = 'Bạn có muốn',
    String cancelText = 'Không',
    String confirmText = 'Có',
    Color confirmColor = Colors.blue,
    Color cancelColor = Colors.black,
    IconData? icon,
    Color iconColor = Colors.orange,
    VoidCallback? onConfirm,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Confirm Dialog',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.only(top: 100.h),
              padding: EdgeInsets.all(20.w),
              width: 400.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (icon != null)
                        Icon(icon, size: 32.sp, color: iconColor),
                      if (icon != null) SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          content,
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          cancelText,
                          style:
                              AppTheme.bodyMedium.copyWith(color: cancelColor),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          if (onConfirm != null) {
                            onConfirm();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmColor,
                        ),
                        child: Text(
                          confirmText,
                          style:
                              AppTheme.bodyMedium.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(animation);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }


  Future<bool?> showConfirmDialogMobile({
    required BuildContext context,
    String title = 'Thông báo',
    String content = 'Bạn có muốn thực hiện hành động này?',
    String cancelText = 'Không',
    String confirmText = 'Có',
    Color confirmColor = Colors.blue,
    Color cancelColor = Colors.black,
    IconData? icon,
    Color iconColor = Colors.orange,
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (icon != null) Icon(icon, size: 28, color: iconColor),
                      if (icon != null) const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          content,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(cancelText,
                            style: TextStyle(color: cancelColor)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          if (onConfirm != null) onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(confirmText,
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }




  String japaneseDateConvert(String? date) {
    // return 'yyyy年MM月dd日'
    try {
      return DateFormat("yyyy年MM月dd日").format(DateTime.parse(date!));
    } catch (e) {
      return '';
    }
  }

  String isoDateToShortDate(String? date) {
    try {
      return DateFormat('dd-MM-yyyy')
          .format(DateTime.parse(date ?? '').toLocal());
    } catch (e) {
      return '';
    }
  }
}
