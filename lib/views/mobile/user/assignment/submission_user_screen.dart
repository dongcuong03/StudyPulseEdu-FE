import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:study_pulse_edu/models/app/Submission.dart';
import 'package:study_pulse_edu/viewmodels/mobile/assignment_teacher_view_model.dart';
import 'package:study_pulse_edu/viewmodels/mobile/assignment_user_view_model.dart';

import '../../../../resources/utils/app/app_theme.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../resources/widgets/app_input_second.dart';

class SubmissionUserScreen extends ConsumerStatefulWidget {
  final String? studentId;
  final String? assignmentId;
  final VoidCallback? onClose;

  const SubmissionUserScreen(
      {required this.studentId,
      required this.assignmentId,
      required this.onClose,
      super.key});

  @override
  ConsumerState createState() => _SubmissionUserScreenState();
}

class _SubmissionUserScreenState extends ConsumerState<SubmissionUserScreen>
    with HelperMixin {
  final _formKey = GlobalKey<FormState>();

  String? _fileError;
  final TextEditingController contentController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncAssignments = ref.watch(assignmentTeacherViewModelProvider);
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Nộp bài tập', style: TextStyle(color: Colors.white)),
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
          const SizedBox(height: 20),
          _buildInput(
            controller: contentController,
            labelText: 'Nội dung bài nộp',
            prefixIcon: const Icon(Icons.description),
            maxLines: 5,
          ),
          const SizedBox(height: 30),
          // Nút đính kèm file
          ElevatedButton.icon(
            onPressed: _pickFiles,
            icon: Icon(
              Icons.attach_file,
              color: Colors.grey[900],
            ),
            label: Text('Đính kèm file',
                style: TextStyle(
                  color: Colors.grey[700],
                )),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, elevation: 4),
          ),
          if (_fileError != null)
            Padding(
              padding: EdgeInsets.only(left: 16.w, top: 4.h),
              child: Text(
                _fileError!,
                style: AppTheme.bodySmall.copyWith(color: Colors.red.shade800),
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
                  colors: [Color(0xFF3E61FC), Color(0xFF5EBAD7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: ElevatedButton(
                onPressed: () {
                  _addSubmission();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
                child: Text(
                  'Nộp bài',
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

  void _addSubmission() async {
    setState(() {
      _fileError = null;
    });

    bool isValidForm = _formKey.currentState!.validate();

    if (attachedFiles.isEmpty) {
      setState(() {
        _fileError = 'File đính kèm không được để trống.';
      });
      isValidForm = false;
    }

    if (isValidForm) {
      final viewModel = ref.read(assignmentUserViewModelProvider.notifier);
      Submission submission = Submission(
          assignmentId: widget.assignmentId,
          studentId: widget.studentId,
          description: contentController.text);

      List<File> files = attachedFiles.map((pf) => File(pf.path!)).toList();

      //call api
      showLoading(context, show: true);
      final message = await viewModel.createSubmission(
          submission: submission, files: files);
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
