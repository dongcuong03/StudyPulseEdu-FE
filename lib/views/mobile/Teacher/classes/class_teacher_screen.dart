import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/app/Account.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../routes/route_const.dart';
import '../../../../viewmodels/mobile/classRoom_mobile_teacher_view_model.dart';

class ClassTeacherScreen extends ConsumerStatefulWidget {
  final Account? account;

  const ClassTeacherScreen({required this.account, super.key});

  @override
  ConsumerState createState() => _ClassTeacherScreenState();
}

class _ClassTeacherScreenState extends ConsumerState<ClassTeacherScreen>
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
        title: const Text(
          'Lớp học',
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
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.teal)),
                    subtitle: Text(
                        'Từ ${formatDate(classItem.startDate.toString())} đến ${formatDate(classItem.endDate.toString())}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      pushedName(
                          context, RouteConstants.teacherViewClassRouteName,
                          extra: classItem.id);
                    },
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
}
