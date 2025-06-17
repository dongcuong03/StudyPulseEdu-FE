import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_pulse_edu/resources/widgets/PDF_view_dialog_widget.dart';
import 'package:study_pulse_edu/resources/widgets/image_view_dialog_widget.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:study_pulse_edu/routes/route_const.dart';
import 'package:study_pulse_edu/resources/utils/helpers/helper_mixin.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../models/app/Assignment.dart';

class AssignmentCard extends StatelessWidget with HelperMixin {
  final Assignment assignment;
  final String? studentId;
  final String? studentName;
  final String? studentCode;
  final VoidCallback onSubmitted;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final images = assignment.attachmentUrl
        ?.split(',')
        .map((e) => e.trim())
        .where((e) => e.endsWith('.jpg') || e.endsWith('.png'))
        .toList();
    print(images);
    final pdfs = assignment.attachmentUrl
        ?.split(',')
        .map((e) => e.trim())
        .where((e) => e.endsWith('.pdf'))
        .toList();
    final others = assignment.attachmentUrl
        ?.split(',')
        .map((e) => e.trim())
        .where((e) =>
    !e.endsWith('.jpg') && !e.endsWith('.png') && !e.endsWith('.pdf'))
        .toList();

    final now = DateTime.now();
    final dueDateTime =
    (assignment.dueDate != null && assignment.dueTime != null)
        ? DateTime(
      assignment.dueDate!.year,
      assignment.dueDate!.month,
      assignment.dueDate!.day,
      int.parse(assignment.dueTime!.split(":")[0]),
      int.parse(assignment.dueTime!.split(":")[1]),
    )
        : null;
    final isOverdue = dueDateTime != null && now.isAfter(dueDateTime);
    final hasSubmitted = assignment.submissions
        ?.any((s) => s.studentId == studentId) ??
        false;

    return Card(
      color: Colors.white,
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage:
                      assignment.classA?.teacher?.avatarUrl != null
                          ? NetworkImage(
                          "${ApiConstants.getBaseUrl}/uploads/${assignment.classA?.teacher?.avatarUrl}")
                          : null,
                      onBackgroundImageError: (_, __) {},
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.classA?.teacher?.fullName ?? '',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          assignment.createdAt != null
                              ? DateFormat('HH:mm, dd/MM/yyyy')
                              .format(assignment.createdAt!)
                              : '',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                if (!isOverdue || hasSubmitted)
                  IconButton(
                    icon: const Icon(Icons.more_horiz, size: 30),
                    onPressed: () {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: "Menu",
                        transitionDuration:
                        const Duration(milliseconds: 300),
                        pageBuilder: (context, _, __) {
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: Material(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24)),
                              clipBehavior: Clip.antiAlias,
                              child: Container(
                                height: 0.2.sh,
                                padding: const EdgeInsets.all(20),
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ListTile(
                                      leading: Icon(
                                        hasSubmitted
                                            ? Icons.remove_red_eye
                                            : Icons.upload,
                                        color: Colors.blueAccent,
                                      ),
                                      title: Text(hasSubmitted
                                          ? "Xem bài nộp"
                                          : "Nộp bài tập"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        if (!hasSubmitted) {
                                          context.pushNamed(
                                            RouteConstants
                                                .userSubmissionRouteName,
                                            extra: {
                                              "studentId": studentId,
                                              "assignmentId": assignment.id,
                                              "onClose": onSubmitted,
                                            },
                                          );
                                        }else{
                                          context.pushNamed(
                                            RouteConstants
                                                .userViewSubmissionRouteName,
                                            extra: {
                                              "studentId": studentId,
                                              "studentName": studentName,
                                              "studentCode": studentCode,
                                              "className" : assignment.classA?.className,
                                              "title": assignment.title,
                                              "assignmentId": assignment.id,
                                              "onClose": onSubmitted,
                                            },
                                          );
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        transitionBuilder: (context, animation, _, child) {
                          return SlideTransition(
                            position: Tween(
                                begin: const Offset(0, 1), end: Offset.zero)
                                .animate(animation),
                            child: child,
                          );
                        },
                      );
                    },
                  ),
              ],
            ),

            const SizedBox(height: 10),
            Text("Lớp: ${assignment.classA?.className ?? ''}"),
            const SizedBox(height: 8),
            Text(
              (assignment.dueDate != null && assignment.dueTime != null)
                  ? "Đến hạn: ${assignment.dueTime}, ${DateFormat('dd/MM/yyyy').format(assignment.dueDate!)}"
                  : "Đến hạn: ",
              style: const TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Divider(height: 40),
            Text(
              assignment.title ?? '',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            const SizedBox(height: 10),
            Text(assignment.description ?? ''),
            const SizedBox(height: 12),

            // Attachments
            for (final image in images ?? [])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.image, color: Colors.blue),
                title: Text(image.split('/').last, style: TextStyle(fontSize: 15)),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => ImageViewerDialog(
                    images: images!,
                    initialIndex: images.indexOf(image),
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
                leading:
                const Icon(Icons.insert_drive_file, color: Colors.blue),
                title: Text(file.split('/').last, style: TextStyle(fontSize: 15)),
                onTap: () => downloadFile(file),
              ),
            if (isOverdue)
              const Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Center(
                  child: Text("Đã quá hạn nộp bài", style: TextStyle(color: Colors.red)),
                ),
              ),
          ],
        ),
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
