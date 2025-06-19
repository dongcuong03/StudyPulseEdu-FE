import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:study_pulse_edu/viewmodels/mobile/classA_mobile_teacher_view_model.dart';

import '../../../../models/app/Account.dart';
import '../../../../resources/utils/app/app_theme.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../routes/route_const.dart';

class ScoreTeacherScreen extends ConsumerStatefulWidget {
  final Account? account;

  const ScoreTeacherScreen({required this.account, super.key});

  @override
  ConsumerState createState() => _ScoreTeacherScreenState();
}

class _ScoreTeacherScreenState extends ConsumerState<ScoreTeacherScreen>
    with HelperMixin {
  void _fetch(String id) async {
    await ref.read(classaMobileTeacherViewModelProvider.notifier).fetch(id: id);
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
    final classListAsync = ref.watch(classaMobileTeacherViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Điểm',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: classListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Lỗi: $error')),
        data: (classes) {
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classItem = classes[index];
              return Card(
                color: Color(0xFFE3F2F6),
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListTile(
                    title: Text(classItem.className.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'Từ ${formatDate(classItem.startDate.toString())} đến ${formatDate(classItem.endDate.toString())}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (context) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.25,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
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
                                            "classA": classItem,
                                            "onClose": (){
                                              showSuccessToast('Nhập điểm thành công');
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
                                            "classId": classItem.id,
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
