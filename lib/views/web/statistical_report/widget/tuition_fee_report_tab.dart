import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../models/app/TuitionReport.dart';
import '../../../../resources/utils/app/app_theme.dart';
import '../../../../viewmodels/web/tuition_report_view_model.dart';
import 'date_picker_field_widget.dart';

class TuitionFeeReportTab extends ConsumerStatefulWidget  {
  const TuitionFeeReportTab({super.key});

  @override
  ConsumerState<TuitionFeeReportTab> createState() => _TuitionFeeReportTabState();
}

class _TuitionFeeReportTabState extends ConsumerState<TuitionFeeReportTab> {
  DateTime? fromDate;
  DateTime? toDate;
  List<TuitionReport> classData = [];
  bool isLoading = false;
  bool hasFetched = false;
  String? fromDateError;
  String? toDateError;
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
      final result = await ref.read(tuitionReportViewModelProvider.notifier).fetchReport(fromDate: fromDate!, toDate: toDate!);
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
  Widget build(BuildContext context) {
    final total = classData.fold(0.0, (sum, item) => sum + (item.totalTuition ?? 0));
    final paid = classData.fold(0.0, (sum, item) => sum + (item.paidAmount ?? 0));
    final unpaid = total - paid;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Chọn ngày
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
                            onDateSelected: (date) {
                              setState(() {
                                fromDate = date;
                              });
                            },
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
                            onDateSelected: (date) {
                              setState(() {
                                toDate = date;
                              });
                            },
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
              SizedBox(width: 20),
              Expanded(
                child: Padding(
                  padding:  EdgeInsets.only(top: 5.h),
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
                      onPressed: () {
                        fetchReport();
                      },
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
                ),),
            ],
          ),

          SizedBox(height: 40.h),

          /// Nếu không có dữ liệu
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
          if (!isLoading && classData.isNotEmpty)
          /// Biểu đồ + Bảng
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    color: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: Text('Chi tiết học phí theo lớp', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600))),
                          SizedBox(height: 40.h),
                          /// Bảng header
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                            color: Colors.grey.shade200,
                            child: Row(
                              children: [
                                _buildHeaderCell('Lớp', flex: 2),
                                _buildHeaderCell('Tổng học phí'),
                                _buildHeaderCell('Đã nộp'),
                                _buildHeaderCell('Chưa nộp'),
                              ],
                            ),
                          ),

                          /// Bảng nội dung có thể cuộn
                          SizedBox(
                            height: 330.h,
                            child: ListView.separated(
                              itemCount: classData.length,
                              separatorBuilder: (_, __) => Divider(height: 1),
                              itemBuilder: (context, index) {
                                final data = classData[index];
                                final double total = data.totalTuition ?? 0;
                                final double paid = data.paidAmount ?? 0;
                                final double unpaid = total - paid;

                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                                  child: Row(
                                    children: [
                                      _buildBodyCell(data.className ?? '', flex: 2),
                                      _buildBodyCell(formatNumber(total)),
                                      _buildBodyCell(formatNumber(paid)),
                                      _buildBodyCell(formatNumber(unpaid)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Card(
                    color: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          SizedBox(
                            height: 190.h,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.teal,
                                    value: paid,
                                    title: formatPercent((paid / total) * 100),
                                    titleStyle: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    radius: 50,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.orange,
                                    value: unpaid,
                                    title: formatPercent((unpaid / total) * 100),
                                    titleStyle: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    radius: 50,
                                  ),
                                ],
                                sectionsSpace: 2,
                                centerSpaceRadius: 30,
                              ),
                            ),
                          ),
                          SizedBox(height: 45.h),
                          Center(
                            child: Text(
                              'Biểu đồ tổng quan học phí',
                              style: TextStyle(fontSize: 16.sp, fontStyle: FontStyle.italic),
                            ),
                          ),
                          SizedBox(height: 35.h),
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildLegendWithValue(Colors.teal, 'Đã nộp', paid, ((paid / total) * 100)),
                                SizedBox(height: 10.h),
                                Padding(
                                  padding:  EdgeInsets.only(left: 15.w),
                                  child: _buildLegendWithValue(Colors.orange, 'Chưa nộp', unpaid, ((unpaid / total) * 100)),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  'Tổng học phí: ${formatNumber(total)}',
                                  style: TextStyle(fontSize: 13.sp, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String formatNumber(double value) {
    final formatter = NumberFormat("#,##0.###", "vi_VN");
    return "${formatter.format(value)} ₫";
  }
  String formatPercent(double value) {
    if (value % 1 == 0) {
      return '${value.toStringAsFixed(0)}%'; // Nếu là số nguyên
    } else {
      return '${value.toStringAsFixed(1)}%'; // Nếu là số thập phân
    }
  }


  Widget _buildLegendWithValue(Color color, String label, double value, double percent) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h, bottom: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            '$label: ${formatNumber(value)} (${formatPercent(percent)})',
            style: TextStyle(fontSize: 12.sp, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildBodyCell(String value, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        style: TextStyle(fontSize: 16.sp),
      ),
    );
  }

}

