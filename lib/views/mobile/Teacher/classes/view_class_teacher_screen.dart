import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:study_pulse_edu/resources/widgets/app_input_second.dart';

import '../../../../models/app/Schedule.dart';
import '../../../../models/app/Student.dart';

import '../../../../resources/utils/app/app_theme.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../viewmodels/web/class_view_model.dart';

class ViewClassTeacherScreen extends ConsumerStatefulWidget {
  final String? classID;

  const ViewClassTeacherScreen({required this.classID, super.key});

  @override
  ConsumerState createState() => _ViewClassTeacherScreenState();
}

class _ViewClassTeacherScreenState extends ConsumerState<ViewClassTeacherScreen>
    with HelperMixin {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollStudentController = ScrollController();
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
  bool _showSchedule = false;
  bool _showStudent = false;

  @override
  void initState() {
    super.initState();
    _loadClassData(widget.classID.toString());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _studentMaxController.dispose();
    _tuitionController.dispose();
    _descriptionController.dispose();
    _scrollStudentController.dispose();

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
      _tuitionController.text =
          NumberFormat("#,##0", "en_US").format(classA.tuitionFee);
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
      schedules = (classA.schedules ?? [])
          .where((sch) => sch.startTime != null && sch.endTime != null)
          .map((sch) => Schedule(
                dayOfWeek: sch.dayOfWeek,
                startTime: formatTime(sch.startTime),
                endTime: formatTime(sch.endTime),
              ))
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
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Xem lớp học',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        body: ScrollbarTheme(
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
                    top: 30.h, right: 20.w, left: 20.w, bottom: 50.h),
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
        ));
  }

  Widget _buildFormViewClass() {
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tên lớp học: ",
                    style: AppTheme.bodyLarge,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: _buildInput(
                              controller: _nameClassController,
                              prefixIcon: Icon(
                                Icons.class_outlined,
                                size: 21.sp,
                              ),
                              readOnly: true)),
                    ],
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Text(
                    "Giáo viên: ",
                    style: AppTheme.bodyLarge,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: _buildInput(
                              controller: _nameTeacherController,
                              prefixIcon: Icon(
                                Icons.person_outline,
                                size: 21.sp,
                              ),
                              readOnly: true)),
                    ],
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Text(
                    "Số học sinh tối đa: ",
                    style: AppTheme.bodyLarge,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: _buildInput(
                              controller: _studentMaxController,
                              prefixIcon: Icon(
                                Icons.group_add_outlined,
                                size: 21.sp,
                              ),
                              readOnly: true)),
                    ],
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Text(
                    "Học phí: ",
                    style: AppTheme.bodyLarge,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: _buildInput(
                              controller: _tuitionController,
                              prefixIcon: Icon(
                                Icons.monetization_on_outlined,
                                size: 21.sp,
                              ),
                              readOnly: true)),
                    ],
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Text(
                    "Ngày bắt đầu: ",
                    style: AppTheme.bodyLarge,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Row(children: [
                    Expanded(
                        child: _buildInput(
                            controller: _startDateController,
                            prefixIcon: Icon(
                              Icons.calendar_month_outlined,
                              size: 21.sp,
                            ),
                            readOnly: true)),
                  ]),
                  SizedBox(
                    height: 30.h,
                  ),
                  Text(
                    "Ngày kết thúc: ",
                    style: AppTheme.bodyLarge,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Row(children: [
                    Expanded(
                        child: _buildInput(
                            controller: _endDateController,
                            prefixIcon: Icon(
                              Icons.calendar_month_outlined,
                              size: 21.sp,
                            ),
                            readOnly: true)),
                  ]),
                  SizedBox(
                    height: 30.h,
                  ),
                  Text(
                    "Mô tả: ",
                    style: AppTheme.bodyLarge,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: _buildInput(
                              controller: _descriptionController,
                              prefixIcon: Icon(
                                Icons.description_outlined,
                                size: 21.sp,
                              ),
                              maxLines: 3,
                              readOnly: true)),
                    ],
                  ),
                  SizedBox(
                    height: 50.h,
                  ),
                  _buildScheduleDropdown(),
                  SizedBox(
                    height: 20.h,
                  ),
                  _buildStudentDropdown(),
                  SizedBox(
                    height: 30.h,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _showSchedule = !_showSchedule;
            });
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Lịch học:", style: AppTheme.bodyLarge),
              Icon(
                _showSchedule
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.black87,
                size: 20.sp,
              )
            ],
          ),
        ),
        SizedBox(height: 16.h),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final isShowing = child.key == const ValueKey('schedule');

            final offsetAnimation = Tween<Offset>(
              begin: isShowing ? const Offset(0, 0) : Offset.zero,
              end: isShowing ? Offset.zero : const Offset(0, 0),
            ).animate(animation);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: _showSchedule
              ? Container(
                  key: const ValueKey('schedule'),
                  child: Column(
                    children: [
                      _buildScheduleForm(),
                      SizedBox(
                        height: 40.h,
                      )
                    ],
                  ),
                )
              : const SizedBox(
                  key: ValueKey('empty'),
                ),
        ),
      ],
    );
  }

  Widget _buildScheduleForm() {
    return Card(
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 90.w,
                      child: Center(
                          child: Text("Ngày học",
                              style: AppTheme.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600)))),
                  SizedBox(
                      width: 115.w,
                      child: Center(
                          child: Text("Giờ bắt đầu",
                              style: AppTheme.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600)))),
                  SizedBox(
                      width: 100.w,
                      child: Center(
                          child: Text("Giờ kết thúc",
                              style: AppTheme.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600)))),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            // Danh sách lịch học dạng văn bản + Divider
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedules.length,
              separatorBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(
                    top: 10.h, right: 20.w, bottom: 10.h, left: 20.w),
                child: const Divider(
                  color: Colors.grey,
                ),
              ),
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            schedule.dayOfWeek?.displayName ?? '',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 100.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            schedule.startTime ?? '',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 100.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            schedule.endTime ?? '',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _showStudent = !_showStudent;
            });
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Danh sách học sinh: ", style: AppTheme.bodyLarge),
              Icon(
                _showStudent
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.black87,
                size: 20.sp,
              )
            ],
          ),
        ),
        SizedBox(height: 16.h),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final isShowing = child.key == const ValueKey('student');

            final offsetAnimation = Tween<Offset>(
              begin: isShowing ? const Offset(0, 0) : Offset.zero,
              end: isShowing ? Offset.zero : const Offset(0, 0),
            ).animate(animation);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: _showStudent
              ? Container(
                  key: const ValueKey('student'),
                  child: _buildClassStudentForm(),
                )
              : const SizedBox(
                  key: ValueKey('empty'),
                ),
        ),
      ],
    );
  }

  Widget _buildClassStudentForm() {
    return Card(
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 400.h,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Scrollbar(
            controller: _scrollStudentController,
            thumbVisibility: true,
            child: ListView.separated(
              controller: _scrollStudentController,
              itemCount: students.length,
              separatorBuilder: (_, __) => Divider(
                color: Colors.grey.shade500,
                thickness: 1,
                height: 12.h,
              ),
              itemBuilder: (context, index) {
                final student = students[index];
                final dateOfBirth = student.dateOfBirth != null
                    ? DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(student.dateOfBirth.toString()))
                    : '';

                return Padding(
                  padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14.sp),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${student.studentCode} - ${student.fullName}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16.sp),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Ngày sinh: $dateOfBirth',
                              style: TextStyle(
                                  fontSize: 13.sp, color: Colors.grey[700]),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Giới tính: ${student.gender?.displayGender ?? ''}',
                              style: TextStyle(
                                  fontSize: 13.sp, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    String? labelText,
    required Icon prefixIcon,
    String? Function(String?)? validator,
    bool isPasswordField = false,
    int? maxLines,
    bool? readOnly,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return AppInputSecond(
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
