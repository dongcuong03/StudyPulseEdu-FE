import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:study_pulse_edu/models/app/TuitionFee.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';
import 'package:study_pulse_edu/viewmodels/web/tuition_fee_view_model.dart';
import 'package:study_pulse_edu/views/web/tuition_management/widget/confirm_tuition_fee_widget.dart';
import 'package:study_pulse_edu/views/web/tuition_management/widget/hoverable_popup_menuI_iem.dart';
import 'package:study_pulse_edu/views/web/tuition_management/widget/tuition_fee_row_widget.dart';
import 'package:study_pulse_edu/views/web/tuition_management/widget/view_tuition_fee_widget.dart';

import '../../../models/app/PagingResponse.dart';
import '../../../resources/utils/app/app_theme.dart';
import '../../../resources/utils/helpers/helper_mixin.dart';
import '../../../resources/widgets/pagination_widget.dart';

class TuitionManagementScreen extends ConsumerStatefulWidget {
  const TuitionManagementScreen({super.key});

  @override
  ConsumerState createState() => _TuitionManagementScreenState();
}

class _TuitionManagementScreenState
    extends ConsumerState<TuitionManagementScreen> with HelperMixin {
  int currentPageIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  String? searchStudentCode;

  TuitionStatus? _selectedTuitionFeeStatus;
  TuitionStatus? tempSelectedTuitionFeeStatus;

  void _fetchPage(
      {int? pageIndex, String? studentCode, TuitionStatus? status}) {
    final viewModel = ref.read(tuitionFeeViewModelProvider.notifier);

    if ((studentCode != null && studentCode.isNotEmpty) || status != null) {
      viewModel.fetchTuitionFees(
        studentCode: studentCode,
        status: status,
      );
    } else {
      // Nếu không tìm kiếm
      viewModel.fetchTuitionFees(pageIndex: pageIndex ?? 1);
    }
    setState(() {
      currentPageIndex = pageIndex ?? 1;
      searchStudentCode = studentCode?.isNotEmpty == true ? studentCode : null;
    });
  }

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (_searchController.text.isEmpty && searchStudentCode != null) {
        _fetchPage(pageIndex: 1);
      }
    });

    Future.microtask(() {
      _fetchPage(pageIndex: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pagingResponse = ref.watch(tuitionFeeViewModelProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 30.h),
            _buildTableHeader(),
            _buildTuitionFeeList(pagingResponse),
            SizedBox(height: 30.h),
            _buildPagination(pagingResponse),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding:
              const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade400,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Text('Chức năng'),
              SizedBox(
                width: 10,
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  popupMenuTheme: PopupMenuThemeData(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                child: PopupMenuButton<String>(
                  tooltip: '',
                  elevation: 8,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  offset: const Offset(0, 50),
                  onSelected: (value) async {
                    switch (value) {
                      case 'notify':
                        // Gửi thông báo
                        await showConfirmDialogWeb(
                            context: context,
                            title: 'Thông báo',
                            content:
                                'Bạn có muốn gửi thông báo đóng học phí đến phụ huynh?',
                            icon: Icons.notifications,
                            onConfirm: () async {
                              final viewModel = ref
                                  .read(tuitionFeeViewModelProvider.notifier);
                              final message =
                                  await viewModel.notifyAllTuitionFees();
                              if (message == null) {
                                showSuccessToastWeb(context,
                                    'Đã gửi thông báo học phí đến tất cả phụ huynh chưa nộp học phí.');
                              } else {
                                showErrorToastWeb(context, message);
                              }
                            });
                        break;
                      case 'export':
                        // Xuất file mẫu

                        try {
                          await ref
                              .read(tuitionFeeViewModelProvider.notifier)
                              .exportTuitionFeeTemplate();
                          showSuccessToastWeb(
                              context, 'Đã xuất file mẫu thành công');
                        } catch (e) {
                          showErrorToastWeb(context, 'Lỗi xuất file: $e');
                        }

                        break;
                      case 'confirm':
                        // Xác nhận trạng thái
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => ConfirmTuitionFeeWidget(
                            onClose: () {
                              showSuccessToastWeb(context,
                                  "Xác nhận trạng thái đóng học phí thành công");
                              _fetchPage(pageIndex: currentPageIndex);
                            },
                          ),
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    HoverablePopupMenuItem(
                      value: 'notify',
                      label: 'Gửi thông báo học phí đến phụ huynh',
                    ),
                    HoverablePopupMenuItem(
                      value: 'export',
                      label: 'Xuất file mẫu',
                    ),
                    HoverablePopupMenuItem(
                      value: 'confirm',
                      label: 'Xác nhận trạng thái đóng học phí',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Search + Filter
        Row(
          children: [
            SizedBox(
              width: 270.w,
              child: Container(
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade500),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Nhập mã học sinh',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 20.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  style: TextStyle(fontSize: 14.sp),
                  onSubmitted: (value) {
                    final studentCode = value.trim();
                    _fetchPage(studentCode: studentCode);
                  },
                ),
              ),
            ),
            SizedBox(width: 20.w),
            GestureDetector(
              onTap: _showFilterDialog,
              behavior: HitTestBehavior.translucent,
              child: Image.asset(
                'assets/images/icon_filter.png',
                width: 30.sp,
                height: 30.sp,
                color: Colors.grey,
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: Colors.grey[300],
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      child: const Row(
        children: [
          Expanded(flex: 0, child: Text('Mã HS')),
          SizedBox(
            width: 30,
          ),
          Expanded(flex: 1, child: Text('Họ tên')),
          Expanded(flex: 1, child: Center(child: Text('Tổng học phí (VND)'))),
          Expanded(
              flex: 1, child: Center(child: Text('Học phí phải nộp (VND)'))),
          Expanded(flex: 1, child: Center(child: Text('Trạng thái nộp'))),
          Expanded(flex: 1, child: Center(child: Text('Hành động'))),
        ],
      ),
    );
  }

  Widget _buildTuitionFeeList(
      AsyncValue<PagingResponse<TuitionFee>?> pagingResponse) {
    return Expanded(
      child: pagingResponse.when(
        data: (pagingResponse) {
          final tuitionFees = pagingResponse?.content ?? [];
          return ListView.separated(
            itemCount: tuitionFees.length,
            separatorBuilder: (_, __) => Divider(height: 0),
            itemBuilder: (context, index) {
              final tuitionFee = tuitionFees[index];
              return TuitionFeeRowWidget(
                studentCode: tuitionFee.student?.studentCode ?? '',
                studentName: tuitionFee.student?.fullName ?? '',
                totalTuitionFee: tuitionFee.totalTuitionFee ?? 0,
                unpaidTuitionFee: tuitionFee.unpaidTuitionFee ?? 0,
                status: tuitionFee.status!,
                onView: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => ViewTuitionDetailWidget(
                      studentId: tuitionFee.student?.id ?? '',
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          print('Error loading data: $error');
          print(stack);
          return Center(child: Text('Lỗi tải dữ liệu'));
        },
      ),
    );
  }

  Widget _buildPagination(
      AsyncValue<PagingResponse<TuitionFee>?> pagingResponse) {
    return pagingResponse.when(
      data: (pagingResponse) {
        final totalElements = pagingResponse?.totalElements ?? 0;
        final pageSizeRaw = pagingResponse?.pageSize ?? 0;
        final pageSize = pageSizeRaw > 0 ? pageSizeRaw : 1;

        final totalPages =
            totalElements == 0 ? 1 : (totalElements / pageSize).ceil();
        return PaginationWidget(
          currentPage: currentPageIndex,
          totalPages: totalPages,
          onPageChanged: (page) {
            _fetchPage(pageIndex: page);
          },
        );
      },
      loading: () => SizedBox.shrink(),
      error: (_, __) => SizedBox.shrink(),
    );
  }

  void _showFilterDialog() {
    tempSelectedTuitionFeeStatus = _selectedTuitionFeeStatus;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filter',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  width: 380,
                  constraints: BoxConstraints(
                    maxHeight: 0.7.sh,
                  ),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Text("Bộ lọc tìm kiếm",
                              style: AppTheme.titleMedium)),
                      const SizedBox(height: 20),
                      Text("Theo trạng thái nộp học phí:",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<TuitionStatus>(
                          isExpanded: true,
                          hint: const Text("Chọn trạng thái nộp",
                              style: TextStyle(fontWeight: FontWeight.normal)),
                          items: TuitionStatus.values.map((status) {
                            return DropdownMenuItem<TuitionStatus>(
                              value: status,
                              child: Text(status.displayName,
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal)),
                            );
                          }).toList(),
                          value: tempSelectedTuitionFeeStatus,
                          onChanged: (value) => setState(
                              () => tempSelectedTuitionFeeStatus = value),
                          buttonStyleData: ButtonStyleData(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade400),
                              color: Colors.white,
                            ),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(Icons.arrow_drop_down,
                                color: Colors.blueAccent),
                            iconSize: 24,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white70,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  tempSelectedTuitionFeeStatus = null;
                                  _selectedTuitionFeeStatus = null;
                                });
                              },
                              child: const Text("Đặt lại"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                _selectedTuitionFeeStatus =
                                    tempSelectedTuitionFeeStatus;
                                Navigator.pop(context);
                                _fetchPage(status: _selectedTuitionFeeStatus);
                              },
                              child: const Text("Áp dụng"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
