import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:study_pulse_edu/models/app/ClassA.dart';
import 'package:study_pulse_edu/models/app/Student.dart';
import 'package:study_pulse_edu/resources/utils/app/app_theme.dart';
import 'package:study_pulse_edu/viewmodels/web/class_view_model.dart';
import '../../../../models/app/Account.dart';
import '../../../../models/app/Schedule.dart';
import '../../../../models/app/Teacher.dart';
import '../../../../resources/constains/constants.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../resources/widgets/app_input.dart';
import '../../../../viewmodels/web/account_view_model.dart';

class ViewClassWidget extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final String classID;

  const ViewClassWidget(
      {super.key, required this.onClose, required this.classID});

  @override
  ConsumerState createState() => _ViewClassWidgetState();
}

class _ViewClassWidgetState extends ConsumerState<ViewClassWidget>
    with HelperMixin {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _studentMaxController = TextEditingController();
  final _tuitionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _nameTeacherController = TextEditingController();
  final _nameClassController = TextEditingController();

  late List<Schedule> schedules;
  late List<bool> isSelectedList;
  late List<Student> students;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    schedules =
        DayOfWeek.values.map((day) => Schedule(dayOfWeek: day)).toList();

    isSelectedList = List.generate(schedules.length, (_) => false);
    _loadClassData(widget.classID);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _studentMaxController.dispose();
    _tuitionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadClassData(String classId) async {
    setState(() {
      _isLoading = true;
    });
    showLoading(context, show: true);
    final classA =
        await ref.read(classViewModelProvider.notifier).getClassById(classId);
    if (classA == null) return;

    setState(() {
      _studentMaxController.text = classA.maxStudents?.toString() ?? '';
      _tuitionController.text = classA.tuitionFee?.toString() ?? '';
      _descriptionController.text = classA.description ?? '';

      _startDateController.text = classA.startDate != null
          ? DateFormat('dd/MM/yyyy')
              .format(DateTime.parse(classA.startDate.toString()))
          : '';
      _endDateController.text = classA.endDate != null
          ? DateFormat('dd/MM/yyyy')
              .format(DateTime.parse(classA.endDate.toString()))
          : '';
      _nameTeacherController.text = classA.teacher!.fullName.toString();
      _nameClassController.text = classA.className.toString();
      students = classA.students ?? [];
      schedules = DayOfWeek.values.map((day) {
        final existing = classA.schedules?.firstWhere(
          (sch) => sch.dayOfWeek == day,
          orElse: () => Schedule(dayOfWeek: day),
        );
        return Schedule(
          dayOfWeek: day,
          startTime: formatTime(existing?.startTime),
          endTime: formatTime(existing?.endTime),
        );
      }).toList();

      isSelectedList = schedules
          .map((s) => s.startTime != null && s.endTime != null)
          .toList();
    });
    showLoading(context, show: false);
    setState(() {
      _isLoading = false;
    });
  }

  String? formatTime(String? time) {
    if (time == null) return null;
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: 800.w,
        height: 1.sh,
        child: Column(
          children: [
            // --- Title ---
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                        ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                        blendMode: BlendMode.srcIn,
                        child: const Row(
                          children: [
                            Icon(Icons.person_add),
                            SizedBox(width: 8),
                            Text(
                              'Xem lớp học',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                  Divider(color: Colors.black87, thickness: 0.5),
                ],
              ),
            ),

            Expanded(
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.all(Colors.grey.shade400),
                  thickness: MaterialStateProperty.all(6),
                  radius: Radius.circular(3),
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  thickness: 6,
                  radius: Radius.circular(3),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 30.h, right: 30.w, left: 30.w, bottom: 50.h),
                      child: Form(
                          key: _formKey,
                          child: _isLoading
                              ? SizedBox.shrink()
                              : Column(children: [
                                  _buildFormViewClass(),
                                ])),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormViewClass() {
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _buildInput(
                              controller: _nameClassController,
                              labelText: "Tên lớp học",
                              prefixIcon: Icon(Icons.class_outlined),
                              readOnly: true)),
                      SizedBox(
                        width: 60.w,
                      ),
                      Expanded(
                          child: _buildInput(
                              controller: _nameTeacherController,
                              labelText: "Giáo viên",
                              prefixIcon: Icon(Icons.person_outline),
                              readOnly: true)),
                    ],
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: _buildInput(
                              controller: _studentMaxController,
                              labelText: "Số học sinh tối đa",
                              prefixIcon: Icon(Icons.group_add_outlined),
                              readOnly: true)),
                      SizedBox(
                        width: 60.w,
                      ),
                      Expanded(
                          child: _buildInput(
                              controller: _tuitionController,
                              labelText: "Học phí",
                              prefixIcon: Icon(Icons.monetization_on_outlined),
                              readOnly: true)),
                    ],
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  Row(children: [
                    Expanded(
                        child: _buildInput(
                            controller: _startDateController,
                            labelText: "Ngày bắt đầu",
                            prefixIcon: Icon(Icons.calendar_month_outlined),
                            readOnly: true)),
                    SizedBox(
                      width: 60.w,
                    ),
                    Expanded(
                        child: _buildInput(
                            controller: _endDateController,
                            labelText: "Ngày kết thúc",
                            prefixIcon: Icon(Icons.calendar_month_outlined),
                            readOnly: true)),
                  ]),
                  SizedBox(
                    height: 40.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: _buildInput(
                              controller: _descriptionController,
                              labelText: "Mô tả",
                              prefixIcon: Icon(Icons.description),
                              maxLines: 3,
                              readOnly: true)),
                    ],
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  _buildScheduleForm(),
                  SizedBox(
                    height: 40.h,
                  ),
                  _buildClassStudentForm(),
                  SizedBox(
                    height: 70.h,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lịch học',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),
        Table(
          columnWidths: {
            0: FixedColumnWidth(80.w),
            1: const FlexColumnWidth(2),
            2: const FlexColumnWidth(3),
            3: const FlexColumnWidth(3),
          },
          border: TableBorder.all(color: Colors.grey.shade400),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFF25303C)),
              children: [
                _buildHeaderCell('Chọn'),
                _buildHeaderCell('Ngày học'),
                _buildHeaderCell('Giờ bắt đầu'),
                _buildHeaderCell('Giờ kết thúc'),
              ],
            ),
            for (int i = 0; i < schedules.length; i++)
              TableRow(
                children: [
                  // Hiển thị dấu tick hoặc rỗng
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Center(
                      child: isSelectedList[i]
                          ? const Icon(Icons.check, color: Colors.blue)
                          : const SizedBox.shrink(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Center(
                      child: Text(
                        schedules[i].dayOfWeek!.displayName,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Center(
                      child: Text(
                        schedules[i].startTime ?? '--',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Center(
                      child: Text(
                        schedules[i].endTime ?? '--',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassStudentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh sách học sinh của lớp học',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),
        Table(
          columnWidths: {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
            4: FlexColumnWidth(4),
          },
          border: TableBorder.all(color: Colors.grey.shade400),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFF25303C)),
              children: [
                _buildHeaderCell('Mã học sinh'),
                _buildHeaderCell('Tên học sinh'),
                _buildHeaderCell('Giới tính'),
                _buildHeaderCell('Ngày sinh'),
                _buildHeaderCell('Địa chỉ'),
              ],
            ),
            for (int i = 0; i < students.length; i++)
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Center(
                      child: Text(
                        students[i].studentCode.toString(),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Center(
                      child: Text(
                        students[i].fullName.toString(),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Center(
                      child: Text(
                        students[i].gender!.displayGender,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Center(
                      child: Text(
                        students[i].dateOfBirth != null
                            ? DateFormat('dd/MM/yyyy').format(DateTime.parse(
                                students[i].dateOfBirth.toString()))
                            : '',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Center(
                      child: Text(
                        students[i].address.toString(),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Center(
        child: Text(
          text,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
        ),
      ),
    );
  }

  TimeOfDay parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String labelText,
    required Icon prefixIcon,
    String? Function(String?)? validator,
    bool isPasswordField = false,
    int? maxLines,
    bool? readOnly,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return AppInput(
        controller: controller,
        labelText: labelText,
        prefixIcon: prefixIcon,
        validator: validator,
        isPasswordField: isPasswordField,
        inputType: inputType,
        inputFormatters: inputFormatters,
        readOnly: readOnly ?? false,
        maxLines: maxLines);
  }
}
