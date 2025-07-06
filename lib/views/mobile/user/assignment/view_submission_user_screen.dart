import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:study_pulse_edu/models/app/Submission.dart';
import 'package:study_pulse_edu/viewmodels/mobile/assignment_user_view_model.dart';
import '../../../../resources/constains/constants.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../resources/widgets/PDF_view_dialog_widget.dart';
import '../../../../resources/widgets/image_view_dialog_widget.dart';

class ViewSubmissionUserScreen extends ConsumerStatefulWidget {
  final String? studentId;
  final String? studentName;
  final String? studentCode;
  final String? className;
  final String? title;
  final String? assignmentId;
  final VoidCallback? onClose;

  const ViewSubmissionUserScreen(
      {required this.studentId,
      required this.studentName,
      required this.studentCode,
      required this.className,
      required this.title,
      required this.assignmentId,
      required this.onClose,
      super.key});

  @override
  ConsumerState createState() => _ViewSubmissionUserScreenState();
}

class _ViewSubmissionUserScreenState
    extends ConsumerState<ViewSubmissionUserScreen> with HelperMixin {
  bool _isLoading = true;
  String? createdAt;
  String? description;
  String? score;
  String? feedback;
  String? fileUrl;
  List<String>? images;
  List<String>? pdfs;
  List<String>? others;

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
      createdAt = response.createdAt != null
          ? DateFormat('HH:mm, dd/MM/yyyy').format(response.createdAt!)
          : '';
      description = response.description ?? '';
      fileUrl = response.fileUrl ?? '';
      score = response.score != null
          ? double.parse(response.score!.toString())
              .toString()
              .replaceFirst(RegExp(r'\.0$'), '')
              .replaceFirst(RegExp(r'(\.\d)0$'), r'\1')
          : '';

      feedback = response.feedback ?? '';
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

  @override
  void initState() {
    super.initState();
    _loadData(Submission(
        studentId: widget.studentId, assignmentId: widget.assignmentId));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Xem bài nộp', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
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
                      '${widget.studentName ?? ''} - ${widget.studentCode ?? ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      createdAt ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Lớp
          Text(
            'Lớp: ${widget.className ?? ''}',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 8),
          // Tiêu đề bài tập
          Text(
            '${widget.title ?? ''}',
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
              title: Text(pdf.split('/').last, style: TextStyle(fontSize: 15)),
              onTap: () => showDialog(
                context: context,
                builder: (_) => PDFViewerDialog(pdfUrl: pdf),
              ),
            ),
          for (final file in others ?? [])
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
              title: Text(file.split('/').last, style: TextStyle(fontSize: 15)),
              onTap: () => downloadFile(file),
            ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 20),
          // Khung điểm và nhận xét
          _buildScoreAndCommentBoxReadonly(
            score: score ?? '',
            comment: feedback ?? '',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildScoreAndCommentBoxReadonly({
    required String score,
    required String comment,
  }) {
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
                Center(
                  child: const Text(
                    'Điểm',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 6),

                // Đường phân cách ngang
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      score,
                      style: const TextStyle(fontSize: 30, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Cột Lời phê
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: const Text(
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
                  const SizedBox(height: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, right: 12, bottom: 8, left: 12),
                      child: Text(
                        comment.isNotEmpty ? comment : '',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
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
