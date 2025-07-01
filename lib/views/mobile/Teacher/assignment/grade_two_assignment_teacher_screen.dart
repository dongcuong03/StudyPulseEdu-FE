import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:study_pulse_edu/models/app/Assignment.dart';
import 'package:study_pulse_edu/models/app/ClassA.dart';
import 'package:study_pulse_edu/models/app/Student.dart';
import 'package:study_pulse_edu/viewmodels/mobile/assignment_teacher_view_model.dart';
import '../../../../models/app/Account.dart';
import '../../../../models/app/Submission.dart';
import '../../../../models/app/Teacher.dart';
import '../../../../resources/constains/constants.dart';
import '../../../../resources/utils/app/app_theme.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../resources/widgets/PDF_view_dialog_widget.dart';
import '../../../../resources/widgets/app_input_second.dart';
import '../../../../resources/widgets/image_view_dialog_widget.dart';
import '../../../../routes/route_const.dart';
import '../../../../viewmodels/mobile/assignment_user_view_model.dart';
import '../../../../viewmodels/mobile/classA_mobile_teacher_view_model.dart';
import '../../../../viewmodels/web/class_view_model.dart';

class GradeTwoAssignmentTeacherScreen extends ConsumerStatefulWidget {
  final Assignment? assignment;
  final Student? student;
  final VoidCallback? onClose;

  const GradeTwoAssignmentTeacherScreen({
    required this.assignment,
    required this.student,
    required this.onClose,
    super.key,
  });

  @override
  ConsumerState createState() => _GradeTwoAssignmentTeacherScreenState();
}

class _GradeTwoAssignmentTeacherScreenState
    extends ConsumerState<GradeTwoAssignmentTeacherScreen> with HelperMixin {
  bool _isLoading = true;
  String? submissId;
  String? createdAt;
  String? description;
  final _scoreController = TextEditingController();
  final _feedbackController = TextEditingController();
  String? fileUrl;
  List<String>? images;
  List<String>? pdfs;
  List<String>? others;

  String? _errorScore;
  final _formKey = GlobalKey<FormState>();

  Future<void> _loadData(Submission submission) async {
    setState(() {
      _isLoading = true;
    });
    showLoading(context, show: true);
    final response = await ref
        .read(assignmentUserViewModelProvider.notifier)
        .fetchSubmissionByID(subission: submission);
    if (response == null) return;

    setState(() {
      submissId = response.id ?? '';
      createdAt = response.createdAt != null
          ? DateFormat('HH:mm, dd/MM/yyyy').format(response.createdAt!)
          : '';
      description = response.description ?? '';
      if (response.score != null) {
        _scoreController.text = double.parse(response.score!.toString())
            .toString()
            .replaceFirst(RegExp(r'\.0$'), '')
            .replaceFirst(RegExp(r'(\.\d)0$'), r'\1');

      }

      if (response.feedback != null) {
        _feedbackController.text = response.feedback!;
      }
      fileUrl = response.fileUrl ?? '';
      images = fileUrl
          ?.split(',')
          .map((e) => e.trim())
          .where((e) => e.endsWith('.jpg') || e.endsWith('.png'))
          .toList();
      pdfs = fileUrl
          ?.split(',')
          .map((e) => e.trim())
          .where((e) => e.endsWith('.pdf'))
          .toList();
      others = fileUrl
          ?.split(',')
          .map((e) => e.trim())
          .where((e) =>
              !e.endsWith('.jpg') && !e.endsWith('.png') && !e.endsWith('.pdf'))
          .toList();
    });
    showLoading(context, show: false);
    setState(() {
      _isLoading = false;
    });
  }

  void _gradeSubmission() async {
    setState(() {
      _errorScore = null;
    });

    bool isValidForm = _formKey.currentState!.validate();
    if (_scoreController.text.isEmpty) {
      setState(() {
        _errorScore = 'Điểm không được để trống.';
      });
      isValidForm = false;
    }
    if (isValidForm) {
      final submission = Submission(
          score: double.tryParse(_scoreController.text),
          feedback: _feedbackController.text);
      showLoading(context, show: true);
      final message = await ref
          .read(assignmentTeacherViewModelProvider.notifier)
          .gradeSubission(submission, submissId!);
      showLoading(context, show: false);
      if (message != null) {
        showErrorToastWeb(context, message);
      } else {
        widget.onClose?.call();
        context.pop();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData(Submission(
        studentId: widget.student?.id, assignmentId: widget.assignment?.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chấm bài tập - ${widget.student?.fullName}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: _isLoading ? SizedBox.shrink() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar hình tròn với chữ HS
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade200,
                  child: const Text(
                    'HS',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Tên học sinh - Mã học sinh
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.student?.fullName ?? ''} - ${widget.student?.studentCode ?? ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        createdAt ?? '',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Lớp
            Text(
              'Lớp: ${widget.assignment?.classA?.className ?? ''}',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),
            // Tiêu đề bài tập
            Text(
              '${widget.assignment?.title ?? ''}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              description ?? '',
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            for (final image in images ?? [])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.image, color: Colors.blue),
                title:
                    Text(image.split('/').last, style: TextStyle(fontSize: 15)),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => ImageViewerDialog(
                    images: images!,
                    initialIndex: images!.indexOf(image),
                  ),
                ),
              ),
            for (final pdf in pdfs ?? [])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.picture_as_pdf, color: Colors.blue),
                title:
                    Text(pdf.split('/').last, style: TextStyle(fontSize: 15)),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => PDFViewerDialog(pdfUrl: pdf),
                ),
              ),
            for (final file in others ?? [])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    const Icon(Icons.insert_drive_file, color: Colors.blue),
                title:
                    Text(file.split('/').last, style: TextStyle(fontSize: 15)),
                onTap: () => downloadFile(file),
              ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 20),
            // Khung điểm và nhận xét
            _buildScoreAndCommentBoxEditable(),
            if (_errorScore != null)
              Padding(
                padding: EdgeInsets.only(left: 16.w, top: 4.h),
                child: Text(
                  _errorScore!,
                  style: AppTheme.bodySmall
                      .copyWith(color: Colors.red.shade800),
                ),
              ),

            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                    child: SizedBox(
                  height: 45.h,
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
                        _gradeSubmission();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                      ),
                      child: Text(
                        'Chấm điểm',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ))
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreAndCommentBoxEditable() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cột Điểm
          Container(
            width: 130,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Điểm',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey,
                ),
                Expanded(
                  child: Center(
                    child: TextField(
                      controller: _scoreController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 30, color: Colors.red),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Cột Nhận xét
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Nhận xét của giáo viên',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, right: 12, bottom: 8, left: 12),
                      child: TextField(
                        controller: _feedbackController,
                        maxLines: 3,
                        style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                      ),

                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Nhập nhận xét ...',
                          hintStyle: TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),

                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void downloadFile(String url) async {
    final uri = Uri.parse(url.startsWith('http')
        ? url
        : "${ApiConstants.getBaseUrl}/uploads/$url");
    try {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final filePath = "${directory.path}/${uri.pathSegments.last}";
        await Dio().download(uri.toString(), filePath);
        showSuccessToast("Tải tệp thành công");
      } else {
        showErrorToast("Không thể lấy thư mục lưu trữ.");
      }
    } catch (e) {
      showErrorToast("Lỗi: $e");
    }
  }
}
