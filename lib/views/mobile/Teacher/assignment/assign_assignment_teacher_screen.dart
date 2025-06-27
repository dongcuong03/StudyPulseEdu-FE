import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:study_pulse_edu/models/app/Assignment.dart';
import 'package:study_pulse_edu/viewmodels/mobile/assignment_teacher_view_model.dart';

import '../../../../models/app/Account.dart';
import '../../../../models/app/ClassA.dart';
import '../../../../models/app/Teacher.dart';
import '../../../../resources/constains/constants.dart';
import '../../../../resources/utils/app/app_theme.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../resources/widgets/app_input_second.dart';
import '../../../../viewmodels/mobile/classA_mobile_teacher_view_model.dart';

class AssignAssignmentTeacherScreen extends ConsumerStatefulWidget {
  final Account? account;
  final VoidCallback? onClose;
  const AssignAssignmentTeacherScreen({required this.account, required this.onClose, super.key});

  @override
  ConsumerState createState() => _AssignAssignmentTeacherScreenState();
}

class _AssignAssignmentTeacherScreenState
    extends ConsumerState<AssignAssignmentTeacherScreen> with HelperMixin {
  final _formKey = GlobalKey<FormState>();

  String? selectedClass;
  DateTime? selectedDateTime;
  TimeOfDay? selectedTime;
  String? _classError;
  String? _dateTimeError;
  String? _fileError;
  String? _titleError;
  String? _contentError;
  List<String?> classList = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();

  List<PlatformFile> attachedFiles = [];
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        // thêm file mới vào danh sách cũ, tránh trùng lặp nếu cần
        attachedFiles.addAll(result.files);

        attachedFiles = attachedFiles.toSet().toList();
      });
    }
  }

  Future<void> _pickDateTime() async {
    final picked = await showOmniDateTimePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      is24HourMode: true, // Dùng AM/PM
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Colors.blue,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        dialogBackgroundColor: Colors.white, // Nền trắng
      ),

    );

    if (picked != null) {
      setState(() {
        selectedDateTime = picked;
        dateTimeController.text = DateFormat('dd/MM/yyyy – HH:mm').format(picked);
      });
    }

  }
  @override
  void initState() {
    super.initState();
    fetchClassList(widget.account!.teacher!.id.toString());
  }

  void fetchClassList (String id) async{
    final fetchedList = await ref.read(classaMobileTeacherViewModelProvider.notifier).fetchClassATeacher(id: id);
    setState(() {
      classList = fetchedList.map((classA) => classA.className).toList();
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Giao bài tập',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: widget.account?.teacher?.avatarUrl != null
                    ? NetworkImage("${ApiConstants.getBaseUrl}/uploads/${widget.account!.teacher!.avatarUrl}")
                    : null,
                child: widget.account?.teacher?.avatarUrl == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.account?.teacher?.fullName ?? 'Tên giáo viên',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.account?.role?.displayName ?? '',
                    style: AppTheme.bodySmall.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Dropdown chọn lớp
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(20),
            child: Theme(
              data: Theme.of(context).copyWith(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                // tắt hiệu ứng hover (desktop)
              ),
              child: DropdownButtonFormField<String>(
                value: selectedClass,
                decoration: InputDecoration(
                  labelText: 'Chọn lớp',
                  labelStyle:  TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.normal,
                  ),
                  prefixIcon: const Icon(
                    Icons.class_,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
                items: classList.map((cls) {
                  return DropdownMenuItem(value: cls, child: Text(cls!));
                }).toList(),
                onChanged: (value) => setState(() => selectedClass = value),
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.grey,
              ),
            ),
          ),
          if (_classError != null)
            Padding(
              padding: EdgeInsets.only(left: 16.w, top: 4.h),
              child: Text(
                _classError!,
                style: AppTheme.bodySmall
                    .copyWith(color: Colors.red.shade800),
              ),
            ),

          const SizedBox(height: 30),

          _buildDateOrTimeBox(
            label: 'Ngày & giờ đến hạn',
            controller: dateTimeController,
            onTap: _pickDateTime,
          ),
          if (_dateTimeError != null)
            Padding(
              padding: EdgeInsets.only(left: 16.w, top: 4.h),
              child: Text(
                _dateTimeError!,
                style: AppTheme.bodySmall
                    .copyWith(color: Colors.red.shade800),
              ),
            ),

          const SizedBox(height: 30),

          // Tiêu đề bài tập
          _buildInput(
            controller: titleController,
            labelText: 'Tiêu đề bài tập',
            prefixIcon: const Icon(Icons.title),
          ),
          if (_titleError != null)
            Padding(
              padding: EdgeInsets.only(left: 16.w, top: 4.h),
              child: Text(
                _titleError!,
                style: AppTheme.bodySmall
                    .copyWith(color: Colors.red.shade800),
              ),
            ),
          const SizedBox(height: 30),

          // Nội dung bài tập
          _buildInput(
            controller: contentController,
            labelText: 'Nội dung bài tập',
            prefixIcon: const Icon(Icons.description),
            maxLines: 5,
          ),
          if (_contentError != null)
            Padding(
              padding: EdgeInsets.only(left: 16.w, top: 4.h),
              child: Text(
                _contentError!,
                style: AppTheme.bodySmall
                    .copyWith(color: Colors.red.shade800),
              ),
            ),
          const SizedBox(height: 30),

          // Nút đính kèm file
          ElevatedButton.icon(
            onPressed: _pickFiles,

            icon:  Icon(Icons.attach_file, color: Colors.grey[900],),
            label:  Text('Đính kèm file',style: TextStyle(color: Colors.grey[700],)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 4
            ),
          ),
          if (_fileError != null)
            Padding(
              padding: EdgeInsets.only(left: 16.w, top: 4.h),
              child: Text(
                _fileError!,
                style: AppTheme.bodySmall
                    .copyWith(color: Colors.red.shade800),
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: attachedFiles.length,
            itemBuilder: (context, index) {
              final file = attachedFiles[index];
              final extension = file.extension?.toLowerCase();
              IconData icon = Icons.insert_drive_file;
              if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
                icon = Icons.image;
              } else if (['pdf'].contains(extension)) {
                icon = Icons.picture_as_pdf;
              } else if (['doc', 'docx'].contains(extension)) {
                icon = Icons.description;
              } else if (['xls', 'xlsx'].contains(extension)) {
                icon = Icons.table_chart;
              }

              return ListTile(
                leading: Icon(icon, color: Colors.blue),
                title: Text(file.name),
                trailing: IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      attachedFiles.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 60),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF3E61FC),
                    Color(0xFF5EBAD7)

                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: ElevatedButton(
                onPressed:(){
                  _addAssignment();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
                child: Text(
                  'Giao bài',
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
    );
  }

  Widget _buildDateOrTimeBox({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:  TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: const Icon(
            Icons.access_time,
            size: 20,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          suffixIcon: const Icon(
            Icons.arrow_drop_down, // icon mũi tên xổ xuống
            color: Colors.grey,
          ),
        ),
        style: TextStyle(
          fontSize: 16,
          color: controller.text.isEmpty ? Colors.grey : Colors.black,
        ),
      ),
    );
  }


  void _addAssignment() async {
    setState(() {
      _classError = null;
      _dateTimeError= null;
      _fileError = null;
      _titleError = null;
      _contentError = null;
    });

    bool isValidForm = _formKey.currentState!.validate();

    if (selectedClass == null) {
      setState(() {
        _classError = 'Lớp học không được để trống.';
      });
      isValidForm = false;
    }

    if (selectedDateTime == null) {
      setState(() {
        _dateTimeError = 'Ngày và giờ đến hạn không được để trống.';
      });
      isValidForm = false;
    }
    if (selectedDateTime!.isBefore(DateTime.now())) {
      setState(() {
        _dateTimeError = 'Ngày giờ đến hạn không được trước ngày giờ hiện tại.';
      });
      isValidForm = false;
    }
    // Validate tiêu đề
    if (titleController.text.trim().isEmpty) {
      _titleError = 'Tiêu đề không được để trống.';
      isValidForm = false;
    }

    // Validate nội dung
    if (contentController.text.trim().isEmpty) {
      _contentError = 'Nội dung không được để trống.';
      isValidForm = false;
    }
    if (attachedFiles.isEmpty ) {
      setState(() {
        _fileError = 'File đính kèm không được để trống.';
      });
      isValidForm = false;
    }

    if (isValidForm) {
      final viewModel = ref.read(assignmentTeacherViewModelProvider.notifier);
       Assignment assignment = Assignment(
         classA: ClassA(
           className: selectedClass,
           teacher: widget.account?.teacher,
         ),
         dueDate: selectedDateTime,
           dueTime: "${selectedDateTime?.hour.toString().padLeft(2, '0')}:${selectedDateTime?.minute.toString().padLeft(2, '0')}",
           title: titleController.text,
         description: contentController.text
       );

      List<File> files = attachedFiles.map((pf) => File(pf.path!)).toList();

      //call api
      showLoading(context, show: true);
      final message = await viewModel.createAssignment(
          assignment: assignment, files: files);
      showLoading(context, show: false);
      if (message != null) {
        showErrorToast(message);
      } else {
        widget.onClose?.call();
        context.pop();
      }
    }
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
      maxLines: maxLines,
    );
  }
}
