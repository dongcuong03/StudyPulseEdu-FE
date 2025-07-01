import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:study_pulse_edu/models/app/Account.dart';
import 'package:study_pulse_edu/models/app/ClassA.dart';
import 'package:study_pulse_edu/models/app/Student.dart';
import 'package:study_pulse_edu/resources/utils/helpers/helper_mixin.dart';

import '../../../../models/app/Score.dart';
import '../../../../resources/utils/app/app_theme.dart';

import 'package:path/path.dart' as p;

import '../../../../viewmodels/mobile/score_mobile_teacher_view_model.dart';

class EnterScoreTeacherScreen extends ConsumerStatefulWidget {
  final Account? account;
  final ClassA? classA;
  final VoidCallback? onClose;

  const EnterScoreTeacherScreen({
    required this.account,
    required this.classA,
    required this.onClose,
    super.key,
  });

  @override
  ConsumerState createState() => _EnterScoreTeacherScreenState();
}

class _EnterScoreTeacherScreenState
    extends ConsumerState<EnterScoreTeacherScreen> with HelperMixin {
  String mode = 'manual'; // 'manual' hoặc 'file'
  String selectedScoreType = 'Kiểm tra 1';
  final Map<String, Map<String, TextEditingController>> _controllersByType = {};
  bool isLoading = true;

  final List<String> scoreTypes = [
    'Kiểm tra 1',
    'Kiểm tra 2',
    'Giữa khóa',
    'Cuối khóa',
  ];

  // Lưu điểm theo loại điểm: { "Kiểm tra 1": { studentId: score } }
  final Map<String, Map<String, double>> scoreData = {};

  File? selectedFile;
  String? fileError;

  List<Score> buildScoreList() {
    final List<Score> scores = [];
    final classId = widget.classA?.id;
    final classA = widget.classA;

    if (classId == null) return scores;

    final Set<String> allStudentIds = {};

    // Gom tất cả studentId xuất hiện ở bất kỳ loại điểm nào
    for (final typeMap in scoreData.values) {
      allStudentIds.addAll(typeMap.keys);
    }

    for (final studentId in allStudentIds) {
      final score = Score(
        classA: classA,
        student: Student(id: studentId),
        scoreTest1: scoreData['Kiểm tra 1']?[studentId],
        scoreTest2: scoreData['Kiểm tra 2']?[studentId],
        scoreMidterm: scoreData['Giữa khóa']?[studentId],
        scoreFinal: scoreData['Cuối khóa']?[studentId],
      );
      scores.add(score);
    }
    return scores;
  }

  void _saveScore() async {
    if (mode == 'manual') {
      final confirm = await showConfirmDialogMobile(
          context: context,
          title: 'Thông báo',
          content: 'Bạn có muốn lưu điểm và gửi thông báo đến phụ huynh?',
          icon: Icons.notifications,
          confirmColor: Colors.blue,
          onConfirm: () async {
            try {
              // Lấy danh sách điểm từ form
              final scoreList = buildScoreList();
              // Gọi API lưu điểm
              showLoading(context, show: true);
              await ref
                  .read(scoreMobileTeacherViewModelProvider.notifier)
                  .saveScores(scoreList);
              showLoading(context, show: false);
              widget.onClose?.call();
              context.pop();
            } catch (e) {
              showErrorToast('Lưu điểm thất bại: $e');
            }
          });
    }
    if (mode == 'file') {
      if (selectedFile == null) {
        setState(() {
          fileError = 'File không đuợc để trống.';
        });
        return;
      }

      final ext = p.extension(selectedFile!.path).toLowerCase();
      if (ext != '.xlsx') {
        setState(() {
          fileError = 'File điểm không hợp lệ. Vui lòng chọn file Excel';
        });
        return;
      }
      setState(() {
        fileError = null;
      });
      final confirm = await showConfirmDialogMobile(
          context: context,
          title: 'Thông báo',
          content: 'Bạn có muốn lưu điểm và gửi thông báo đến phụ huynh?',
          icon: Icons.notifications,
          confirmColor: Colors.blue,
          onConfirm: () async {
            try {
              showLoading(context, show: true);
              final error = await ref
                  .read(scoreMobileTeacherViewModelProvider.notifier)
                  .importScoreExcel(selectedFile!, widget.classA!.id!);

              showLoading(context, show: false);

              if (error == null) {
                widget.onClose?.call();
                context.pop();
              } else {
                showErrorToast(error);
              }
            } catch (e) {
              showErrorToast("Lỗi không xác định: $e");
              showLoading(context, show: false);
            }
          }
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  void _loadScores() async {
    final classId = widget.classA?.id;
    if (classId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final scoreList = await ref
          .read(scoreMobileTeacherViewModelProvider.notifier)
          .fetchScoresByClassId(classId);

      setState(() {
        for (var score in scoreList) {
          final studentId = score.student?.id;
          if (studentId == null) continue;

          void setScore(String type, double? value) {
            if (value == null) return;
            scoreData[type] ??= {};
            scoreData[type]![studentId] = value;

            // Nếu controller đã tồn tại thì gán lại giá trị
            final controller = _controllersByType[type]?[studentId];
            if (controller != null) {
              controller.text = (value % 1 == 0
                  ? value.toInt().toString()
                  : value.toString());
            }
          }

          setScore('Kiểm tra 1', score.scoreTest1);
          setScore('Kiểm tra 2', score.scoreTest2);
          setScore('Giữa khóa', score.scoreMidterm);
          setScore('Cuối khóa', score.scoreFinal);
        }
        isLoading = false;
      });
    } catch (e) {
      showErrorToast('Lỗi: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Student> students = widget.classA?.students ?? [];
    print(widget.classA);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập điểm', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      resizeToAvoidBottomInset: true,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Dropdown chọn chế độ nhập
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Chế độ nhập:',
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 2,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: mode,
                              icon: const Icon(Icons.arrow_drop_down),
                              style:  TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 16.sp,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'manual',
                                  child: Text('Nhập điểm'),
                                ),
                                DropdownMenuItem(
                                  value: 'file',
                                  child: Text('Nhập file điểm'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) setState(() => mode = value);
                              },
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    if (mode == 'manual') buildManualScoreInput(students),
                    if (mode == 'file') buildFileScoreInput(),
                    SizedBox(
                      height: 30.h,
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
                          onPressed: () {
                            _saveScore();
                          },
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
                              fontSize: 16.sp,
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

  /// ==================== NHẬP THỦ CÔNG ====================
  Widget buildManualScoreInput(List<Student> students) {
    final currentScores = scoreData[selectedScoreType] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown loại điểm
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Loại điểm:',
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            Container(
              width: 155.w,
              padding:  EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2.r,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedScoreType,
                  style:  TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 16.sp,
                  ),
                  icon: const Icon(Icons.arrow_drop_down),
                  isExpanded: true,
                  items: scoreTypes
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      // Lưu điểm hiện tại vào scoreData trước khi đổi loại
                      scoreData[selectedScoreType] ??= {};
                      final controllers = _controllersByType[selectedScoreType];
                      if (controllers != null) {
                        for (var entry in controllers.entries) {
                          final parsed = double.tryParse(entry.value.text);
                          if (parsed != null) {
                            scoreData[selectedScoreType]![entry.key] = parsed;
                          } else {
                            scoreData[selectedScoreType]!.remove(entry.key);
                          }
                        }
                      }

                      setState(() {
                        selectedScoreType = value;
                      });
                    }
                  },
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
         SizedBox(height: 25.h),

        Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding:  EdgeInsets.all(12.w),
            child: Column(
              children: [
                // Header bảng
                Container(
                  padding:  EdgeInsets.symmetric(vertical: 8.h),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final sttW = constraints.maxWidth * 0.13;
                      final codeW = constraints.maxWidth * 0.17;
                      final nameW = constraints.maxWidth * 0.5;
                      final scoreW = constraints.maxWidth * 0.2;

                      return Row(
                        children: [
                          SizedBox(
                            width: sttW,
                            child: const Center(
                              child: Text('STT',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          SizedBox(
                            width: codeW,
                            child: const Center(
                              child: Text('Mã HS',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          SizedBox(
                            width: nameW,
                            child: const Center(
                              child: Text('Họ tên',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          SizedBox(
                            width: scoreW,
                            child: const Center(
                              child: Text('Điểm',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Danh sách học sinh
                SizedBox(
                  height: 0.54.sh,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final sttW = constraints.maxWidth * 0.15;
                      final codeW = constraints.maxWidth * 0.15;
                      final nameW = constraints.maxWidth * 0.5;
                      final scoreW = constraints.maxWidth * 0.2;

                      return ListView.separated(
                        itemCount: students.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.grey.shade400,
                          thickness: 1,
                          height: 4,
                          indent: 8,
                          endIndent: 8,
                        ),
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final studentId = student.id;
                          final score = currentScores[studentId];
                          final controllerMap = _controllersByType.putIfAbsent(
                              selectedScoreType, () => {});
                          final controller =
                              controllerMap.putIfAbsent(studentId!, () {
                            final text = score != null
                                ? (score % 1 == 0
                                    ? score.toInt().toString()
                                    : score.toString())
                                : '';
                            return TextEditingController(text: text);
                          });

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: sttW,
                                    child: Center(child: Text('${index + 1}'))),
                                SizedBox(
                                    width: codeW,
                                    child: Center(
                                        child:
                                            Text(student.studentCode ?? ''))),
                                SizedBox(
                                  width: nameW,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(student.fullName ?? ''),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Center(
                                      child: TextField(
                                        controller: controller,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d{0,2}')),
                                          // Chỉ cho phép số và tối đa 2 chữ số thập phân
                                          TextInputFormatter.withFunction(
                                              (oldValue, newValue) {
                                            final text = newValue.text;
                                            final parsed =
                                                double.tryParse(text);
                                            if (text.isEmpty ||
                                                (parsed != null &&
                                                    parsed >= 0 &&
                                                    parsed <= 10)) {
                                              return newValue;
                                            }
                                            return oldValue;
                                          }),
                                        ],
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 6),
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (val) {
                                          final parsed = double.tryParse(val);
                                          setState(() {
                                            scoreData[selectedScoreType] ??= {};
                                            if (parsed != null) {
                                              scoreData[selectedScoreType]![
                                                  studentId] = parsed;
                                            } else {
                                              scoreData[selectedScoreType]!
                                                  .remove(studentId);
                                            }
                                          });
                                        },
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ==================== NHẬP TỪ FILE ====================
  Widget buildFileScoreInput() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: false,
                  type: FileType.any,
                );

                if (result != null && result.files.isNotEmpty) {
                  final path = result.files.first.path;
                  if (path != null) {
                    setState(() {
                      selectedFile = File(path);
                      fileError = null;
                    });
                  }
                }
              },
              icon: const Icon(
                Icons.upload_file,
                color: Colors.blue,
              ),
              label: const Text(
                'Chọn file điểm',
                style: TextStyle(color: Colors.black87),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, elevation: 3),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  showLoading(context, show: true);

                  await ref
                      .read(scoreMobileTeacherViewModelProvider.notifier)
                      .exportScoreTemplate(widget.classA?.id ?? '');
                  showLoading(context, show: false);
                  showSuccessToast("Xuất file mẫu điểm thành công");
                } catch (e) {
                  showErrorToast("Xuất file thất bại");
                }
              },
              icon: const Icon(
                Icons.file_download,
                color: Colors.blue,
              ),
              label: const Text(
                'Xuất file mẫu',
                style: TextStyle(color: Colors.black87),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, elevation: 3),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (selectedFile != null) buildSelectedFileDisplay(),
        if (fileError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  fileError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildSelectedFileDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          _buildFileIcon(selectedFile!.path),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              p.basename(selectedFile!.path),
              style: const TextStyle(fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedFile = null;
                fileError = null;
              });
            },
            child: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildFileIcon(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.gif'].contains(ext)) {
      return const Icon(Icons.image, color: Colors.blue);
    } else if (ext == '.pdf') {
      return const Icon(Icons.picture_as_pdf, color: Colors.blue);
    } else {
      return const Icon(Icons.insert_drive_file, color: Colors.blue);
    }
  }
}
