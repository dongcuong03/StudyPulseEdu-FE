import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_pulse_edu/models/app/Assignment.dart';
import 'package:study_pulse_edu/models/app/ClassA.dart';
import 'package:study_pulse_edu/models/app/Student.dart';

import '../../../../models/app/Account.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../routes/route_const.dart';
import '../../../../viewmodels/web/class_view_model.dart';

class GradeAssignmentTeacherScreen extends ConsumerStatefulWidget {
  final Account? account;
  final Assignment? assignment;

  const GradeAssignmentTeacherScreen({
    required this.account,
    required this.assignment,
    super.key,
  });

  @override
  ConsumerState createState() => _GradeAssignmentTeacherScreenState();
}

class _GradeAssignmentTeacherScreenState
    extends ConsumerState<GradeAssignmentTeacherScreen> with HelperMixin {
  ClassA? classA;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadClassData();
  }

  Future<void> _loadClassData() async {
    setState(() => _isLoading = true);
    showLoading(context, show: true);
    final result = await ref
        .read(classViewModelProvider.notifier)
        .getClassById(widget.assignment?.classA?.id ?? '');
    showLoading(context, show: false);
    setState(() {
      classA = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final submittedStudentIds = widget.assignment?.submissions
            ?.map((e) => e.studentId ?? '')
            .toList() ??
        [];

    final submittedStudents = classA?.students
            ?.where((s) => submittedStudentIds.contains(s.id))
            .toList() ??
        [];

    final notSubmittedStudents = classA?.students
            ?.where((s) => !submittedStudentIds.contains(s.id))
            .toList() ??
        [];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chấm bài tập',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: _isLoading
            ? SizedBox.shrink()
            : Column(
                children: [
                  // TabBar bên dưới AppBar
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      indicatorColor: Colors.blue,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      tabs: const [
                        Tab(text: 'Đã nộp'),
                        Tab(text: 'Chưa nộp'),
                      ],
                    ),
                  ),
                  // Nội dung TabBarView
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildStudentList(submittedStudents, canTap: true),
                        _buildStudentList(notSubmittedStudents, canTap: false),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStudentList(List<Student> students, {required bool canTap}) {
    if (students.isEmpty) {
      return const Center(child: Text("Không có học sinh nào."));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final student = students[index];
        return GestureDetector(
          onTap: canTap
              ? () {
                  pushedName(
                    context,
                    RouteConstants.teacherGradeTwoAssignmentRouteName,
                    extra: {
                      "assignment": widget.assignment,
                      "student": student,
                      "onClose": () {
                        showSuccessToast("Chấm bài tập thành công");
                      },
                    },
                  );
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            child: Card(
              color: Color(0xFFE3F2F6),
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade300,
                      child: const Text(
                        "HS",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.fullName ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Mã HS: ${student.studentCode ?? ''}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (canTap)
                      const Icon(Icons.chevron_right, color: Colors.black87),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
