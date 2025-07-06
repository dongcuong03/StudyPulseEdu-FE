import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:study_pulse_edu/resources/widgets/PDF_view_dialog_widget.dart';
import 'package:study_pulse_edu/resources/widgets/image_view_dialog_widget.dart';
import 'package:study_pulse_edu/viewmodels/mobile/classA_mobile_teacher_view_model.dart';

import '../../../../models/app/Account.dart';

import '../../../../resources/constains/constants.dart';
import '../../../../resources/widgets/assignment_filter_widget.dart';
import '../../../../routes/route_const.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../viewmodels/mobile/assignment_teacher_view_model.dart';

class AssignmentTeacherScreen extends ConsumerStatefulWidget {
  final Account? account;

  const AssignmentTeacherScreen({required this.account, super.key});

  @override
  ConsumerState createState() => _AssignmentTeacherScreenState();
}

class _AssignmentTeacherScreenState
    extends ConsumerState<AssignmentTeacherScreen> with HelperMixin {

  String? _selectedClass;
  DateTime? _fromDate;
  DateTime? _toDate;
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(assignmentTeacherViewModelProvider.notifier).fetchAssignments(
            teacherId: widget.account?.teacher?.id,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncAssignments = ref.watch(assignmentTeacherViewModelProvider);

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Bài tập', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.add, size: 35),
                    onPressed: () {
                      pushedName(
                        context,
                        RouteConstants.teacherAssignAssignmentRouteName,
                        extra: {
                          "account": widget.account,
                          "onClose": () {
                            ref.read(assignmentTeacherViewModelProvider.notifier).fetchAssignments(
                              teacherId: widget.account?.teacher?.id,
                            );
                            showSuccessToast("Giao bài tập thành công");
                          },
                        },
                      );
                    }),
                SizedBox(width: 12,),
                IconButton(
                    icon: const Icon(Icons.filter_list_alt, size: 30),
                    onPressed: () async {
                      final classList = await ref
                          .read(classaMobileTeacherViewModelProvider.notifier)
                          .fetchClassATeacher(id: widget.account?.teacher?.id ?? '');
                      final classNames = classList.map((e) => e.className).toList();

                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) {
                          return AssignmentFilterWidget(
                            classNames: classNames,
                            initialSelectedClass: _selectedClass,
                            initialFromDate: _fromDate,
                            initialToDate: _toDate,
                            onApply: ({selectedClass, fromDate, toDate}) {
                              setState(() {
                                _selectedClass = selectedClass;
                                _fromDate = fromDate;
                                _toDate = toDate;
                              });

                              ref.read(assignmentTeacherViewModelProvider.notifier)
                                  .fetchAssignments(
                                teacherId: widget.account?.teacher?.id,
                                className: selectedClass,
                                formDate: fromDate,
                                toDate: toDate,
                              );
                            },
                            onReset: () {
                              setState(() {
                                _selectedClass = null;
                                _fromDate = null;
                                _toDate = null;
                              });

                              ref.read(assignmentTeacherViewModelProvider.notifier)
                                  .fetchAssignments(
                                teacherId: widget.account?.teacher?.id ,
                              );
                            },
                          );
                        },
                      );
                    })
              ],
            ),
          ),
        ],
      ),
      body: asyncAssignments.when(
        data: (assignments) {
          if (assignments == null || assignments.isEmpty) {
            return const Center(child: Text(""));
          }
          return ListView.builder(
            padding:
                const EdgeInsets.only(top: 12, bottom: 12, left: 24, right: 24),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              final images = assignment.attachmentUrl
                  ?.split(',')
                  .map((e) => e.trim())
                  .where((e) => e.endsWith('.jpg') || e.endsWith('.png'))
                  .toList();
              final pdfs = assignment.attachmentUrl
                  ?.split(',')
                  .map((e) => e.trim())
                  .where((e) => e.endsWith('.pdf'))
                  .toList();
              final others = assignment.attachmentUrl
                  ?.split(',')
                  .map((e) => e.trim())
                  .where((e) =>
                      !e.endsWith('.jpg') &&
                      !e.endsWith('.png') &&
                      !e.endsWith('.pdf'))
                  .toList();

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
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: widget
                                        .account?.teacher?.avatarUrl !=
                                    null
                                ? NetworkImage(
                                    "${ApiConstants.getBaseUrl}/uploads/${widget.account!.teacher!.avatarUrl}")
                                : null,
                            onBackgroundImageError: (_, __) {},
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.account?.teacher?.fullName ?? '',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                "${assignment.createdAt != null ? DateFormat('HH:mm, dd/MM/yyyy').format(assignment.createdAt!) : ''}",
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

                      const SizedBox(height: 10),
                      Text(
                        "Lớp: ${assignment.classA?.className ?? ''}",
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (assignment.dueDate != null &&
                                assignment.dueTime != null)
                            ? "Đến hạn: ${DateFormat('HH:mm').format(DateFormat('HH:mm').parse(assignment.dueTime!))}, ${DateFormat('dd/MM/yyyy').format(assignment.dueDate!)}"
                            : "Đến hạn: ",
                        style: TextStyle(
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
                      Text(
                        assignment.description ?? '',
                        style: TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 12),

                      // File ảnh
                      for (final image in images!)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.image,
                            color: Colors.blue,
                          ),
                          title: Text(image.split('/').last,
                              style: TextStyle(fontSize: 15)),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => ImageViewerDialog(
                                  images: images,
                                  initialIndex: images.indexOf(image)),
                            );
                          },
                        ),
                      // PDF files
                      for (final pdf in pdfs!)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.picture_as_pdf,
                              color: Colors.blue),
                          title: Text(
                            pdf.split('/').last,
                            style: TextStyle(fontSize: 15),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => PDFViewerDialog(pdfUrl: pdf),
                            );
                          },
                        ),

                      // Other files
                      for (final file in others!)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.insert_drive_file,
                              color: Colors.blue),
                          title: Text(file.split('/').last,
                              style: TextStyle(fontSize: 15)),
                          onTap: () {
                            // Gọi tải về
                            downloadFile(file);
                          },
                        ),
                      SizedBox(
                        height: 20,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Text(
                            "Học sinh nộp bài (${assignment.submissions?.length}/${assignment.totalStudentOfClass.toString()})",
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                          IconButton(
                              onPressed: () {
                                pushedName(context, RouteConstants.teacherGradeAssignmentRouteName,
                                  extra: {
                                    "account": widget.account,
                                    "assignment": assignment,
                                  },);
                              },
                              icon: Icon(
                                Icons.rate_review_outlined,
                                color: Colors.blueAccent,
                                size: 30,
                              ))
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Lỗi: $e")),
      ),
    );
  }


  void downloadFile(String url) async {
    final uri = Uri.parse(url.startsWith('http')
        ? url
        : "${ApiConstants.getBaseUrl}/uploads/$url");
    try {
      // Lấy thư mục Downloads
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final filePath = "${directory.path}/${uri.pathSegments.last}";

        // Tải tệp
        await Dio().download(uri.toString(), filePath);
        showSuccessToast("Tải File thành công: ");
      } else {
        showErrorToast("Không thể lấy thư mục lưu trữ.");
      }
    } catch (e) {
      showErrorToast("Lỗi: $e");
    }
  }
}
