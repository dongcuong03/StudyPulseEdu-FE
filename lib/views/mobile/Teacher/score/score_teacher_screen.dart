import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../models/app/Account.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../routes/route_const.dart';
import '../../../../viewmodels/mobile/classRoom_mobile_teacher_view_model.dart';

class ScoreTeacherScreen extends ConsumerStatefulWidget {
  final Account? account;

  const ScoreTeacherScreen({required this.account, super.key});

  @override
  ConsumerState createState() => _ScoreTeacherScreenState();
}

class _ScoreTeacherScreenState extends ConsumerState<ScoreTeacherScreen>
    with HelperMixin {
  void _fetch(String id) async {
    await ref.read(classRoomMobileTeacherViewModelProvider.notifier).fetch(id: id);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetch(widget.account!.teacher!.id.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final classListAsync = ref.watch(classRoomMobileTeacherViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Điểm',
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 24.sp,
        ),
      ),
      body: classListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
            child: Text('Lỗi: $error', style: TextStyle(fontSize: 14.sp))),
        data: (classes) {
          return ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classItem = classes[index];
              return Card(
                color: const Color(0xFFE3F2F6),
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: ListTile(
                    title: Text(
                      classItem.className.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    subtitle: Text(
                      'Từ ${formatDate(classItem.startDate.toString())} đến ${formatDate(classItem.endDate.toString())}',
                      style: TextStyle(fontSize: 15.sp),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.more_vert, size: 24.sp),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24.r)),
                          ),
                          builder: (context) {
                            return SizedBox(
                              height: 0.25.sh,
                              child: Padding(
                                padding: EdgeInsets.all(24.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    buildMenuItem(
                                      icon: Icons.rate_review,
                                      label: 'Nhập điểm',
                                      onTap: () {
                                        Navigator.pop(context);
                                        pushedName(
                                          context,
                                          RouteConstants
                                              .teacherEnterScoreRouteName,
                                          extra: {
                                            "account": widget.account,
                                            "ClassRoom": classItem,
                                            "onClose": () {
                                              showSuccessToast(
                                                  'Nhập điểm thành công');
                                            }
                                          },
                                        );
                                      },
                                    ),
                                    buildMenuItem(
                                      icon: Icons.visibility,
                                      label: 'Xem điểm',
                                      onTap: () {
                                        Navigator.pop(context);
                                        pushedName(
                                          context,
                                          RouteConstants
                                              .teacherViewScoreRouteName,
                                          extra: {
                                            "account": widget.account,
                                            "ClassRoom": classItem,
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    splashColor: Colors.transparent,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
            child: Icon(icon, color: Colors.white, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
