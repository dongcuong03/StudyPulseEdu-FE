import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../viewmodels/web/tuition_fee_view_model.dart';

class ViewTuitionDetailWidget extends ConsumerStatefulWidget {
  final String studentId;

  const ViewTuitionDetailWidget({
    super.key,
    required this.studentId,
  });

  @override
  ConsumerState<ViewTuitionDetailWidget> createState() =>
      _ViewTuitionDetailWidgetState();
}

class _ViewTuitionDetailWidgetState
    extends ConsumerState<ViewTuitionDetailWidget> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> tuitionDetails = [];
  bool isLoading = true;
  String studentCode = '';
  String studentName = '';

  double total = 0;
  double totalPaid = 0;
  double totalUnpaid = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final viewModel = ref.read(tuitionFeeViewModelProvider.notifier);
      final result = await viewModel.getTuitionFeeByStudentId(widget.studentId);

      if (result.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      final student = result.first.student;
      studentCode = student?.studentCode ?? '';
      studentName = student?.fullName ?? '';

      tuitionDetails = result.map((fee) {
        return {
          "className": fee.classRoom?.className ?? '',
          "tuitionFee": fee.classRoom?.tuitionFee?.toDouble() ?? 0,
          "status": fee.status?.displayName,
        };
      }).toList();

      for (var item in tuitionDetails) {
        final fee = (item['tuitionFee'] as double?) ?? 0;
        final status = item['status'] ?? '';

        total += fee;

        if (status == 'Đã nộp') {
          totalPaid += fee;
        } else if (status == 'Chưa nộp') {
          totalUnpaid += fee;
        }
      }

      setState(() => isLoading = false);
    } catch (e) {
      print('Lỗi khi load học phí: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: 800.w,
        height: 1.sh,
        child: Column(
          children: [
            //Title
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                        ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                        blendMode: BlendMode.srcIn,
                        child: const Row(
                          children: [
                            Icon(Icons.monetization_on_rounded),
                            SizedBox(width: 8),
                            Text(
                              'Xem chi tiết học phí',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(color: Colors.black87, thickness: 0.5),
                ],
              ),
            ),

            Expanded(
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.all(Colors.grey.shade400),
                  thickness: MaterialStateProperty.all(6),
                  radius: Radius.circular(3),
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  thickness: 6,
                  radius: Radius.circular(3),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 30.h, right: 30.w, left: 30.w, bottom: 50.h),
                      child: isLoading
                          ? SizedBox.shrink()
                          : Column(
                              children: [
                                _buildTuitionFeeForm(),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTuitionFeeForm() {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Text('Mã học sinh: $studentCode', style: TextStyle(fontSize: 16.sp)),
          SizedBox(height: 8.h),
          Text('Họ tên: $studentName', style: TextStyle(fontSize: 16.sp)),
          SizedBox(height: 30.h),
          Text('Danh sách học phí:',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 12.h),
          Table(
            border: TableBorder.all(color: Colors.grey.shade400),
            columnWidths: {
              0: FixedColumnWidth(50.w),
              1: FlexColumnWidth(),
              2: FixedColumnWidth(160.w),
              3: FixedColumnWidth(160.w),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade200),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Text('STT',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Text('Lớp',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Center(
                        child: Text('Học phí',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Center(
                        child: Text('Trạng thái nộp',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ),
                ],
              ),
              ...tuitionDetails.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Center(child: Text('${index + 1}')),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Text(item['className'] ?? ''),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          NumberFormat.decimalPattern('vi_VN')
                              .format(item['tuitionFee'] ?? 0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Center(child: Text(item['status'] ?? '')),
                    ),
                  ],
                );
              }),
            ],
          ),
          SizedBox(height: 50.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Tổng học phí: ${NumberFormat.currency(locale: 'vi_VN').format(total)}',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Đã đóng: ${NumberFormat.currency(locale: 'vi_VN').format(totalPaid)}',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Còn phải đóng: ${NumberFormat.currency(locale: 'vi_VN').format(totalUnpaid)}',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
          ),
        ],
      ),
    );
  }
}
