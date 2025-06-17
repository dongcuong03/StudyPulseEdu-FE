import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:study_pulse_edu/models/app/Student.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';

import '../../../../models/app/Account.dart';
import '../../../../models/app/Attendance.dart';
import '../../../../models/app/ClassA.dart';
import '../../../../models/app/Teacher.dart';
import '../../../../resources/utils/app/app_theme.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../viewmodels/mobile/attendance_teacher_view_model.dart';

class AttendanceTeacherThreeScreen extends ConsumerStatefulWidget {
  final Account? account;
  final ClassA? classA;
  final DateTime? date;
  final VoidCallback? onClose;

  const AttendanceTeacherThreeScreen({
    required this.account,
    required this.classA,
    required this.date,
    required this.onClose,
    super.key,
  });

  @override
  ConsumerState createState() => _AttendanceTeacherThreeScreenState();
}

class _AttendanceTeacherThreeScreenState
    extends ConsumerState<AttendanceTeacherThreeScreen> with HelperMixin {
  final Map<String, AttendanceStatus> _attendanceStatus = {};
  final Map<String, TextEditingController> _noteControllers = {};

  @override
  void initState() {
    super.initState();
    _loadDataAttendace();
  }

  @override
  void dispose() {
    for (var controller in _noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  Future<void> _loadDataAttendace() async {
    final classId = widget.classA?.id;
    final date = widget.date;

    if (classId == null || date == null) return;

    final response = await ref
        .read(attendanceTeacherViewModelProvider.notifier)
        .getAttendanceByClassAndDate(classId: classId, date: date);

    final students = widget.classA?.students ?? [];

    if (response != null && response.isNotEmpty) {
      // Có dữ liệu điểm danh từ API
      for (var student in students) {
        // Tìm attendance ứng với học sinh
        Attendance? attendance;
        try {
          attendance =
              response.firstWhere((a) => a.student?.id == student.id);
        } catch (_) {
          attendance = null;
        }

        // Gán trạng thái và ghi chú nếu tìm thấy
        _attendanceStatus[student.id!] =
            attendance?.status ?? AttendanceStatus.PRESENT;
        _noteControllers[student.id!] =
            TextEditingController(text: attendance?.note ?? '');
      }
    } else {
      // Chưa có dữ liệu điểm danh => mặc định Có mặt + note rỗng
      for (var student in students) {
        _attendanceStatus[student.id!] = AttendanceStatus.PRESENT;
        _noteControllers[student.id!] = TextEditingController();
      }
    }

    if (mounted) {
      setState(() {});
    }
  }


  void _attendance() async {
    final classId = widget.classA?.id;
    final List<Attendance> attendanceList =
        widget.classA!.students!.map((student) {
      final status = _attendanceStatus[student.id!] ?? AttendanceStatus.PRESENT;
      final note = _noteControllers[student.id!]?.text;
      print('status: $status');
      print('note: $note');
      return Attendance(
        student: Student(id: student.id, studentCode: student.studentCode),
        classA: ClassA(className: widget.classA?.className, id: classId),
        teacher: Teacher(
          id: widget.classA?.teacher?.id,
          fullName: widget.classA?.teacher?.fullName
        ),
        attendanceDatetime: DateTime.now(),
        status: status,
        note: note?.trim().isEmpty ?? true ? null : note?.trim(),
      );
    }).toList();
    showLoading(context, show: true);
    final result = await ref.read(attendanceTeacherViewModelProvider.notifier)
        .markAttendanceBulk(attendanceList);
    showLoading(context, show: false);
    if (result == null) {
      widget.onClose?.call();
      context.pop();
    } else {
      showErrorToast(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayFormatted =
        DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(today);
    final presentCount = _attendanceStatus.values
        .where((s) => s == AttendanceStatus.PRESENT)
        .length;
    final absentCount = _attendanceStatus.values
        .where((s) => s == AttendanceStatus.ABSENT)
        .length;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Điểm danh',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Card(
                color: Color(0xFFF5F5F5),
                margin: const EdgeInsets.all(12),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Column(
                    children: [
                      // Phần tên lớp + ngày
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                widget.classA?.className ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(widget.date!),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, thickness: 1),
                      const SizedBox(height: 12),

                      // Phần thống kê sĩ số - có mặt - vắng
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn(
                              'Sĩ số',
                              widget.classA!.students!.length.toString(),
                              Colors.blue),
                          _buildVerticalDivider(),
                          _buildStatColumn(
                              'Có mặt', presentCount.toString(), Colors.teal),
                          _buildVerticalDivider(),
                          _buildStatColumn(
                              'Vắng', absentCount.toString(), Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 0.6.sh,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView.builder(
                    itemCount: widget.classA?.students?.length ?? 0,
                    itemBuilder: (context, index) {
                      final student = widget.classA!.students![index];
                      final studentId = student.id!;
                      final status = _attendanceStatus[studentId];
                      final controller = _noteControllers[studentId];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}. ${student.fullName ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ChoiceChip(
                                      label: Text(
                                        'Có mặt',
                                        style: TextStyle(
                                          color:
                                              status == AttendanceStatus.PRESENT
                                                  ? Colors.white
                                                  : Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      selected:
                                          status == AttendanceStatus.PRESENT,
                                      onSelected: (selected) {
                                        setState(() {
                                          _attendanceStatus[studentId] =
                                              AttendanceStatus.PRESENT;
                                        });
                                      },
                                      showCheckmark: false,
                                      backgroundColor: Colors.grey.shade200,
                                      selectedColor: Colors.teal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide.none,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ChoiceChip(
                                      label: Text(
                                        'Vắng',
                                        style: TextStyle(
                                          color: status == AttendanceStatus.ABSENT
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      selected: status == AttendanceStatus.ABSENT,
                                      onSelected: (selected) {
                                        setState(() {
                                          _attendanceStatus[studentId] =
                                              AttendanceStatus.ABSENT;
                                        });
                                      },
                                      showCheckmark: false,
                                      backgroundColor: Colors.grey.shade200,
                                      selectedColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide.none,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: controller,
                                        decoration: InputDecoration(
                                          hintText: 'Ghi chú',
                                          hintStyle:
                                              const TextStyle(fontSize: 14),
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 9),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade400),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade400),
                                          ),
                                        ),
                                        style: const TextStyle(fontSize: 14),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 30, color: Colors.grey.shade300),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3E61FC), Color(0xFF5EBAD7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: ElevatedButton(
                    onPressed: () {_attendance();},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                    child: Text(
                      'Lưu lại và gửi thông báo đến phụ huynh',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String title, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return SizedBox(
      width: 1,
      child: Center(
        child: Container(
          height: 30,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
