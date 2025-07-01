import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_pulse_edu/models/app/AcademicResult.dart';
import 'package:study_pulse_edu/resources/utils/helpers/helper_mixin.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/academic_result/widget/academic_result.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/academic_result/widget/evaluation_chart.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/academic_result/widget/evaluation_table.dart';
import 'package:study_pulse_edu/views/mobile/Teacher/academic_result/widget/expandable_section.dart';
import '../../../../resources/utils/app/app_theme.dart';
import '../../../../viewmodels/mobile/academic_result_mobile_teacher_view_model.dart';

class ViewAcademicResultTeacherScreen extends ConsumerStatefulWidget {
  final String? classId;
  const ViewAcademicResultTeacherScreen({super.key, required this.classId});

  @override
  ConsumerState createState() => _ViewAcademicResultTeacherScreenState();
}

class _ViewAcademicResultTeacherScreenState extends ConsumerState<ViewAcademicResultTeacherScreen> with HelperMixin {
  bool showResult = true;
  bool showChart = true;

  List<AcademicResult> _results = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      showLoading(context, show: true);
      final result = await ref.read(
        academicResultMobileTeacherViewModelProvider(widget.classId!).future,
      );
      showLoading(context, show: false);
      setState(() {
        _results = result;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }


  void _submit() async {
    await showConfirmDialogMobile(
        context: context,
        title: 'Thông báo',
        content: 'Bạn có muốn lưu lại và gửi thông báo kết quả học tập đến phụ huynh?',
        icon: Icons.notifications,
        onConfirm: () async {
          showLoading(context, show: true);
          final errorMsg = await ref
              .read(academicResultMobileTeacherViewModelProvider(widget.classId!).notifier)
              .saveAcademicResults(_results);
          showLoading(context, show: false);
          if (errorMsg == null) {
            showSuccessToast("Lưu và gửi thông báo thành công");
          } else {
            showErrorToast("Lưu và gửi thông bao thất bại");
          }
        });
  }

  @override
  Widget build(BuildContext context) {

    final tableData = _results.asMap().entries.map((entry) {
      final i = entry.key;
      final r = entry.value;

      return {
        "index": i,
        "id": r.student?.studentCode ?? "",
        "name": r.student?.fullName ?? "",
        "diemKT": r.testScore ?? 0,
        "diemBT": r.assignmentScore ?? 0,
        "chuyenCan": r.attendanceScore ?? 0,
        "tongKet": r.summaryScore ?? 0,
        "danhGia": r.result?.name == 'PASSED' ? "Đạt" : "Không đạt",
        "nhanXet": r.note ?? "",
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả học tập', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading ? SizedBox.shrink():
        SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              ExpandableSection(
                title: "Biểu đồ đánh giá",
                isExpanded: showChart,
                onToggle: () => setState(() => showChart = !showChart),
                child: EvaluationChart(data: tableData),
              ),
              SizedBox(height: 30.h),
              ExpandableSection(
                title: "Bảng kết quả học tập",
                isExpanded: showResult,
                onToggle: () => setState(() => showResult = !showResult),
                child: AcademicResultTable(
                  data: tableData,
                  onNoteChanged: (index, newNote) {
                    setState(() {
                      _results[index].note = newNote;
                      tableData[index]['nhanXet'] = newNote;
                    });
                  },
                ),
              ),
              SizedBox(height: 30.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3E61FC), Color(0xFF5EBAD7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: ElevatedButton(
                    onPressed: _submit,
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
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
