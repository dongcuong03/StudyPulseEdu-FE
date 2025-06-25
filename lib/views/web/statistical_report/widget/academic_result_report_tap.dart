import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_pulse_edu/models/app/AcademicReport.dart';
import 'package:study_pulse_edu/viewmodels/web/academic_report_view_model.dart';

import '../../../../resources/utils/app/app_theme.dart';
import 'date_picker_field_widget.dart';

class AcademicResultReportTab extends ConsumerStatefulWidget {
  const AcademicResultReportTab({super.key});

  @override
  ConsumerState<AcademicResultReportTab> createState() => _AcademicResultReportTabState();
}

class _AcademicResultReportTabState extends ConsumerState<AcademicResultReportTab> {
  DateTime? fromDate;
  DateTime? toDate;
  String? fromDateError;
  String? toDateError;
  late ScrollController _tableScrollController;

  List<AcademicReport> classData = [];
  bool isLoading = false;
  bool hasFetched = false;

  Future<void> fetchReport() async {
    setState(() {
      fromDateError = null;
      toDateError = null;
    });

    bool hasError = false;

    if (fromDate == null) {
      fromDateError = "Ngày bắt đầu không được để trống";
      hasError = true;
    }

    if (toDate == null) {
      toDateError = "Ngày kết thúc không được để trống";
      hasError = true;
    }
    if (fromDate != null && toDate != null && fromDate!.isAfter(toDate!)) {
      fromDateError = "Ngày bắt đầu không được sau ngày kết thúc";
      hasError = true;
    }
    if (hasError) {
      setState(() {});
      return;
    }
    setState(() {
      isLoading = true;
    });

    try {
      final result = await ref.read(academicReportViewModelProvider.notifier).fetchReport(fromDate: fromDate!, toDate: toDate!);
      setState(() {
        classData = result ?? [];
        hasFetched = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tableScrollController = ScrollController();
  }

  @override
  void dispose() {
    _tableScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double chartMaxHeight = 240.h;
    final int maxStudentCount = classData.map((e) => (e.totalStudents ?? 0)).fold(0, max);
    final double scaleFactor = chartMaxHeight / (maxStudentCount + 5);
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DatePickerFieldWidget(
                            label: 'Từ ngày',
                            initialDate: fromDate,
                            onDateSelected: (date) => setState(() => fromDate = date),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 4.h, left: 8.w),
                            child: SizedBox(
                              height: 20.h,
                              child: fromDateError != null
                                  ? Text(
                                fromDateError!,
                                style: TextStyle(color: Colors.red, fontSize: 12.sp),
                              )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 25.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DatePickerFieldWidget(
                            label: 'Đến ngày',
                            initialDate: toDate,
                            onDateSelected: (date) => setState(() => toDate = date),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 4.h, left: 8.w),
                            child: SizedBox(
                              height: 20.h,
                              child: toDateError != null
                                  ? Text(
                                toDateError!,
                                style: TextStyle(color: Colors.red, fontSize: 12.sp),
                              )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: SizedBox(
                    height: 56.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3E61FC), Color(0xFF75D1F3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: ElevatedButton(
                        onPressed: fetchReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        child: Text(
                          'Thống kê',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 40.h),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
          if (!isLoading && hasFetched && classData.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 80.h),
              child: Center(
                child: Text(
                  'Không có dữ liệu thống kê trong thời gian này',
                  style: TextStyle(fontSize: 16.sp, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          if (!isLoading && classData.isNotEmpty) ...[

            Card(
              elevation: 8,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    SizedBox(
                      height: chartMaxHeight + 90.h,
                      child: BarChart(
                        BarChartData(
                          maxY: (maxStudentCount + 5) * scaleFactor,
                          barGroups: classData.asMap().entries.map((entry) {
                            final index = entry.key;
                            final data = entry.value;
                            final passed = data.passedStudents ?? 0;
                            final total = data.totalStudents ?? 0;
                            final failed = total - passed;

                            return BarChartGroupData(
                              x: index,
                              barsSpace: 8.w,
                              barRods: [
                                BarChartRodData(
                                  toY: passed * scaleFactor,
                                  color: Colors.teal,
                                  width: 20.w,
                                  borderRadius: BorderRadius.circular(0.r),
                                ),
                                BarChartRodData(
                                  toY: failed * scaleFactor,
                                  color: Colors.orange,
                                  width: 20.w,
                                  borderRadius: BorderRadius.circular(0.r),
                                ),
                              ],
                            );
                          }).toList(),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final report = classData[group.x.toInt()];
                                final value = (rod.toY / scaleFactor).round();
                                final label = rodIndex == 0 ? 'Đạt' : 'Không đạt';
                                return BarTooltipItem(
                                  '${report.className}\n$label: $value HS',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30.w,
                                interval: 10 * scaleFactor,
                                getTitlesWidget: (value, _) {
                                  final realValue = (value / scaleFactor).round();
                                  return Text(
                                    realValue.toString(),
                                    style: TextStyle(fontSize: 10.sp),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40.h,
                                getTitlesWidget: (value, _) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= classData.length) return const SizedBox();
                                  return Padding(
                                    padding: EdgeInsets.only(top: 8.h),
                                    child: Text(
                                      classData[index].className ?? '',
                                      style: TextStyle(fontSize: 12.sp),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(),
                            rightTitles: AxisTitles(),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: Colors.grey.shade300,
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              left: BorderSide(color: Colors.grey.shade400),
                              bottom: BorderSide(color: Colors.grey.shade400),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50.h),
                    Center(
                      child: Text(
                        'Biểu đồ kết quả học tập của các lớp',
                        style: TextStyle(fontSize: 16.sp, fontStyle: FontStyle.italic),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLegend(Colors.teal, 'Đạt'),
                          SizedBox(width: 16.w),
                          _buildLegend(Colors.orange, 'Không đạt'),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            SizedBox(height: 60.h),
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bảng kết quả học tập theo lớp', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                          SizedBox(height: 20.h),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                            color: Colors.grey.shade200,
                            child: Row(
                              children: [
                                _buildHeaderCell('Lớp', flex: 2),
                                _buildHeaderCell('Giáo viên'),
                                _buildHeaderCell('Tổng học sinh', center: true),
                                _buildHeaderCell('Đạt', center: true),
                                _buildHeaderCell('Không đạt', center: true),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 330.h,
                            child: Scrollbar(
                              controller: _tableScrollController,
                              child: ListView.separated(
                                controller: _tableScrollController,
                                itemCount: classData.length,
                                separatorBuilder: (_, __) => Divider(height: 1.h),
                                itemBuilder: (context, index) {
                                  final report = classData[index];
                                  final total = report.totalStudents ?? 0;
                                  final passed = report.passedStudents ?? 0;
                                  final failed = total - passed;

                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                                    child: Row(
                                      children: [
                                        _buildBodyCell(report.className ?? '', flex: 2),
                                        _buildBodyCell(report.teacherName ?? ''),
                                        _buildBodyCell('$total', center: true),
                                        _buildBodyCell('$passed', center: true),
                                        _buildBodyCell('$failed', center: true),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 60.h),
          ],
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(color: color),
        ),
        SizedBox(width: 6.w),
        Text(label, style: TextStyle(fontSize: 12.sp)),
      ],
    );
  }

  Widget _buildHeaderCell(String label, {int flex = 1, bool center = false}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: center ? Alignment.center : Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildBodyCell(String value, {int flex = 1, bool center = false}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: center ? Alignment.center : Alignment.centerLeft,
        child: Text(
          value,
          style: TextStyle(fontSize: 16.sp),
        ),
      ),
    );
  }
}