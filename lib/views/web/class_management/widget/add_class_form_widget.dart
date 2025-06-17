import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_pulse_edu/models/app/ClassA.dart';
import 'package:study_pulse_edu/resources/utils/app/app_theme.dart';
import 'package:study_pulse_edu/viewmodels/web/class_view_model.dart';
import '../../../../models/app/Account.dart';
import '../../../../models/app/Schedule.dart';
import '../../../../models/app/Teacher.dart';
import '../../../../resources/constains/constants.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../resources/widgets/app_input.dart';
import '../../../../viewmodels/web/account_view_model.dart';

class AddClassFormWidget extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const AddClassFormWidget({
    super.key,
    required this.onClose,
  });

  @override
  ConsumerState createState() => _AddClassFormWidgetState();
}

class _AddClassFormWidgetState extends ConsumerState<AddClassFormWidget>
    with HelperMixin {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _nameClassController = TextEditingController();
  final _studentMaxController = TextEditingController();
  final _tuitionController = TextEditingController();
  final _descriptionController = TextEditingController();
  Account? _selectedTeacher;
  DateTime? _startDate;
  DateTime? _endDate;

  String? _errorSelectTeacher;
  String? _errorStartDate;
  String? _errorEndDate;
  String? _errorSchedule;

  List<Account> _listTeacher = [];
  late List<Schedule> schedules;
  late List<bool> isSelectedList;

  @override
  void initState() {
    super.initState();
    schedules =
        DayOfWeek.values.map((day) => Schedule(dayOfWeek: day)).toList();

    isSelectedList = List.generate(schedules.length, (_) => false);
    _fetchTeacherAccounts();
  }

  Future<void> _fetchTeacherAccounts() async {
    final allTeachers = await ref
        .read(accountViewModelProvider.notifier)
        .getAllAccountTeacher();

    setState(() {
      _listTeacher = allTeachers
          .where((account) =>
              account.teacher?.fullName != null && account.phone != null)
          .map((account) => Account(
                id: account.id,
                phone: account.phone,
                teacher: Teacher(
                  id: account.teacher?.id,
                  fullName: account.teacher?.fullName,
                ),
              ))
          .toList();
    });
  }

  void _addClass() async {
    setState(() {
      _errorSelectTeacher = null;
      _errorStartDate = null;
      _errorEndDate = null;
    });

    bool isValidForm = _formKey.currentState!.validate();
    final today = DateTime.now();
    if (_selectedTeacher == null) {
      setState(() {
        _errorSelectTeacher = 'Giáo viên không được để trống.';
      });
      isValidForm = false;
    }
    if (_startDate == null) {
      _errorStartDate = 'Ngày bắt đầu không được để trống.';
      isValidForm = false;
    } else if (_startDate!
        .isBefore(DateTime(today.year, today.month, today.day))) {
      _errorStartDate = 'Ngày bắt đầu không được trước ngày hiện tại.';
      isValidForm = false;
    } else if (_endDate != null && _startDate!.isAfter(_endDate!)) {
      _errorStartDate = 'Ngày bắt đầu phải trước ngày kết thúc.';
      isValidForm = false;
    }

    if (_endDate == null) {
      _errorEndDate = 'Ngày kết thúc không được để trống.';
      isValidForm = false;
    } else if (_endDate!
        .isBefore(DateTime(today.year, today.month, today.day))) {
      _errorEndDate = 'Ngày kết thúc không được trước ngày hiện tại.';
      isValidForm = false;
    } else if (_startDate != null && _endDate!.isBefore(_startDate!)) {
      _errorEndDate = 'Ngày kết thúc phải sau ngày bắt đầu.';
      isValidForm = false;
    }

    if (!isSelectedList.contains(true)) {
      _errorSchedule = 'Phải chọn ít nhất 1 ngày học trong tuần.';
      isValidForm = false;
    } else {
      bool hasError = false;

      for (int i = 0; i < isSelectedList.length; i++) {
        if (isSelectedList[i]) {
          final schedule = schedules[i];

          if (schedule.startTime == null) {
            _errorSchedule = 'Giờ bắt đầu không được để trống.';
            isValidForm = false;
            hasError = true;
            break;
          } else if (schedule.endTime == null) {
            _errorSchedule = 'Giờ kết thúc không được để trống.';
            isValidForm = false;
            hasError = true;
            break;
          } else if (schedule.startTime!.compareTo(schedule.endTime!) >= 0) {
            _errorSchedule = 'Giờ bắt đầu phải trước giờ kết thúc.';
            isValidForm = false;
            hasError = true;
            break;
          }
        }
      }

      if (!hasError) {
        _errorSchedule = null;
      }
    if (isValidForm) {
      final selectedSchedules = <Schedule>[];
      for (int i = 0; i < isSelectedList.length; i++) {
        if (isSelectedList[i]) {
          selectedSchedules.add(schedules[i]);
        }
      }
      final classA = ClassA(
        className: _nameClassController.text,
        maxStudents: int.tryParse(_studentMaxController.text) ?? 0,
        tuitionFee: double.tryParse(_tuitionController.text) ?? 0,
        description: _descriptionController.text,
        teacher: Teacher(
          id: _selectedTeacher?.teacher?.id
        ),
        startDate: _startDate!,
        endDate: _endDate!,
        schedules: selectedSchedules,
      );
      showLoading(context, show: true);
      final message = await ref.read(classViewModelProvider.notifier).createClass(classA);
      showLoading(context, show: false);
      if (message != null) {
        showErrorToastWeb(context, message);
      } else {
        widget.onClose();
        showSuccessToastWeb(context, "Thêm lớp học thành công");
      }
      }
    }
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
                              'Thêm lớp học',
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
                          child: Column(children: [
                            _buildFormAddClass(),
                            SizedBox(
                              width: 100.w,
                              height: 60.h,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF3E61FC),
                                      Color(0xFF75D1F3)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    _addClass();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Thêm',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
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

  Widget _buildFormAddClass() {
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tên lớp học không được để trống.';
                          }
                          return null;
                        },
                      )),
                      SizedBox(
                        width: 60.w,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTeacherDropdown(),
                            if (_errorSelectTeacher != null)
                              Padding(
                                padding: EdgeInsets.only(left: 16.w, top: 4.h),
                                child: Text(
                                  _errorSelectTeacher!,
                                  style: AppTheme.bodySmall
                                      .copyWith(color: Colors.red.shade800),
                                ),
                              ),
                          ],
                        ),
                      )
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
                        inputType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        prefixIcon: Icon(Icons.group_add_outlined),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Số học sinh tối đa không được để trống.';
                          }
                          return null;
                        },
                      )),
                      SizedBox(
                        width: 60.w,
                      ),
                      Expanded(
                          child: _buildInput(
                        controller: _tuitionController,
                        labelText: "Học phí",
                        inputType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        prefixIcon: Icon(Icons.monetization_on_outlined),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Học phí không được để trống.';
                          }
                          return null;
                        },
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDatePicker(
                              labelText: "Ngày bắt đầu",
                              selectedDate: _startDate,
                              onDateChanged: (value) {
                                setState(() {
                                  _startDate = value;
                                });
                              },
                            ),
                            if (_errorStartDate != null)
                              Padding(
                                padding: EdgeInsets.only(left: 16.w, top: 4.h),
                                child: Text(
                                  _errorStartDate!,
                                  style: AppTheme.bodySmall
                                      .copyWith(color: Colors.red.shade800),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 60.w,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDatePicker(
                              labelText: "Ngày kết thúc",
                              selectedDate: _endDate,
                              onDateChanged: (value) {
                                setState(() {
                                  _endDate = value;
                                });
                              },
                            ),
                            if (_errorEndDate != null)
                              Padding(
                                padding: EdgeInsets.only(left: 16.w, top: 4.h),
                                child: Text(
                                  _errorEndDate!,
                                  style: AppTheme.bodySmall
                                      .copyWith(color: Colors.red.shade800),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  _buildScheduleForm(),
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
        Column(
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
            if (_errorSchedule != null)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  _errorSchedule!,
                  style:
                      AppTheme.bodySmall.copyWith(color: Colors.red.shade800),
                ),
              ),
          ],
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
              decoration: const BoxDecoration(
                color: Color(0xFF25303C),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Center(
                      child: Text('Chọn',
                          style: AppTheme.bodyMedium
                              .copyWith(color: AppTheme.white))),
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Center(
                      child: Text(
                    'Ngày học',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
                  )),
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Center(
                      child: Text(
                    'Giờ bắt đầu',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
                  )),
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Center(
                      child: Text(
                    'Giờ kết thúc',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
                  )),
                ),
              ],
            ),
            for (int i = 0; i < schedules.length; i++)
              TableRow(
                children: [
                  // Checkbox
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Center(
                      child: Checkbox(
                        value: isSelectedList[i],
                        onChanged: (value) {
                          setState(() {
                            isSelectedList[i] = value ?? false;
                            if (!isSelectedList[i]) {
                              schedules[i] = Schedule(
                                id: schedules[i].id,
                                classId: schedules[i].classId,
                                dayOfWeek: schedules[i].dayOfWeek,
                                startTime: null,
                                endTime: null,
                              );
                            }
                          });
                        },
                      ),
                    ),
                  ),

                  // Ngày học
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Center(
                      child: Text(
                        schedules[i].dayOfWeek!.displayName,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),

                  // Giờ bắt đầu
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
                    child: GestureDetector(
                      onTap: isSelectedList[i] ? () => pickTime(i, true) : null,
                      child: AbsorbPointer(
                        absorbing: !isSelectedList[i],
                        child: Container(
                          height: 40.h,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                            color: isSelectedList[i]
                                ? Colors.white
                                : Colors.grey.shade200,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.black54,
                              ),
                              Text(
                                schedules[i].startTime ?? 'Chọn giờ',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: schedules[i].startTime != null
                                      ? Colors.black87
                                      : Colors.grey.shade600,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Giờ kết thúc
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
                    child: GestureDetector(
                      onTap:
                          isSelectedList[i] ? () => pickTime(i, false) : null,
                      child: AbsorbPointer(
                        absorbing: !isSelectedList[i],
                        child: Container(
                          height: 40.h,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                            color: isSelectedList[i]
                                ? Colors.white
                                : Colors.grey.shade200,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.black54,
                              ),
                              Text(
                                schedules[i].endTime ?? 'Chọn giờ',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: schedules[i].endTime != null
                                      ? Colors.black87
                                      : Colors.grey.shade600,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildTeacherDropdown() {
    return DropdownButtonFormField2<Account>(
      decoration: InputDecoration(
        labelText: 'Giáo viên',
        floatingLabelStyle: TextStyle(color: Colors.black),
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.blue.shade300),
        ),
      ),
      isExpanded: true,
      hint: Text(
        'Chọn giáo viên',
        style: AppTheme.bodyMedium,
      ),
      value: _selectedTeacher,
      style: AppTheme.bodyMedium,
      items: _listTeacher.map((account) {
        return DropdownMenuItem<Account>(
          value: account,
          child: Text('${account.teacher?.fullName} - ${account.phone}'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedTeacher = value;
        });
      },
    );
  }

  Widget _buildDatePicker({
    required String? labelText,
    required DateTime? selectedDate,
    required ValueChanged<DateTime> onDateChanged,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(14),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (picked != null) onDateChanged(picked);
        },
        child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
              prefixIcon: Icon(Icons.calendar_month_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.blue.shade300),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                      : 'Chọn ${labelText?[0].toLowerCase()}${labelText?.substring(1)}',
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black54,
                ),
              ],
            )),
      ),
    );
  }

  // Show time picker và cập nhật giờ cho Schedule
  Future<void> pickTime(int index, bool isStartTime) async {
    Schedule schedule = schedules[index];
    TimeOfDay initialTime;

    if (isStartTime && schedule.startTime != null) {
      initialTime = parseTimeOfDay(schedule.startTime!);
    } else if (!isStartTime && schedule.endTime != null) {
      initialTime = parseTimeOfDay(schedule.endTime!);
    } else {
      initialTime = TimeOfDay.now();
    }

    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      final timeStr = '$hour:$minute';

      setState(() {
        schedules[index] = Schedule(
          id: schedule.id,
          classId: schedule.classId,
          dayOfWeek: schedule.dayOfWeek,
          startTime: isStartTime ? timeStr : schedule.startTime,
          endTime: isStartTime ? schedule.endTime : timeStr,
        );
      });
    }
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
        maxLines: maxLines);
  }
}
