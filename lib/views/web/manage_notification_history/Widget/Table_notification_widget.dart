import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:study_pulse_edu/models/app/NotificationApp.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';
import 'package:study_pulse_edu/viewmodels/web/notify_view_model.dart';
import 'package:study_pulse_edu/views/web/manage_notification_history/Widget/Notify_row_widget.dart';

import '../../../../models/app/PagingResponse.dart';
import '../../../../resources/utils/app/app_theme.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../resources/widgets/pagination_widget.dart';

class TableNotificationWidget extends ConsumerStatefulWidget {
  final NotificationType type;
  final bool? isAdmin;

  const TableNotificationWidget(
      {super.key, required this.type, required this.isAdmin});

  @override
  ConsumerState createState() => _TableNotificationWidgetState();
}

class _TableNotificationWidgetState
    extends ConsumerState<TableNotificationWidget> with HelperMixin {
  int currentPageIndex = 1;

  String? _selectedSenderId;
  String? _selectedReceiverId;
  DateTime? _startDate;
  DateTime? _endDate;

  void _fetchPage(
      {int? pageIndex,
      String? receiverId,
      String? senderId,
      NotificationType? type,
      DateTime? startDate,
      DateTime? endDate}) {
    final viewModel = ref.read(notifyViewModelProvider.notifier);

    if ((receiverId != null && receiverId.isNotEmpty) ||
        (senderId != null && senderId.isNotEmpty) ||
        (startDate != null) ||
        (endDate != null)) {
      viewModel.fetchNotificationApps(
          receiverId: receiverId,
          senderId: senderId,
          startDate: startDate,
          endDate: endDate,
          type: type);
    } else {
      // Nếu không tìm kiếm
      viewModel.fetchNotificationApps(
          pageIndex: pageIndex ?? 1, type: widget.type);
    }
    setState(() {
      currentPageIndex = pageIndex ?? 1;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _fetchPage(pageIndex: 1, type: widget.type);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pagingResponse = ref.watch(notifyViewModelProvider);
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
            _buildNotifyList(pagingResponse),
            SizedBox(height: 30.h),
            _buildPagination(pagingResponse),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: _showFilterDialog,
            behavior: HitTestBehavior.translucent,
            child: Image.asset(
              'assets/images/icon_filter.png',
              width: 30.sp,
              height: 30.sp,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: Colors.grey[300],
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: (widget.isAdmin != null && widget.isAdmin == true)
                  ? const Text('Người gửi (Admin)')
                  : const Text('Người gửi (GV)')),
          Expanded(flex: 1, child: Center(child: Text('Người nhận (PH)'))),
          Expanded(flex: 1, child: Center(child: Text('Thời gian gửi'))),
          Expanded(flex: 1, child: Center(child: Text('Tiêu đề'))),
          Expanded(flex: 2, child: Center(child: Text('Nội dung'))),
        ],
      ),
    );
  }

  Widget _buildNotifyList(
      AsyncValue<PagingResponse<NotificationApp>?> pagingResponse) {
    return Expanded(
      child: pagingResponse.when(
        data: (pagingResponse) {
          final notifications = pagingResponse?.content ?? [];
          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) => Divider(height: 0),
            itemBuilder: (context, index) {
              final notify = notifications[index];
              return NotifyRowWidget(
                receiverName: notify.receiver?.parent?.fullName ?? '',
                senderName: notify.sender?.teacher?.fullName ?? '',
                sendDate: notify.createdAt ?? DateTime.now(),
                title: notify.title ?? '',
                message: notify.message ?? '',
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
      AsyncValue<PagingResponse<NotificationApp>?> pagingResponse) {
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
            _fetchPage(pageIndex: page, type: widget.type);
          },
        );
      },
      loading: () => SizedBox.shrink(),
      error: (_, __) => SizedBox.shrink(),
    );
  }

  void _showFilterDialog() async {
    final senders = await ref
        .read(notifyViewModelProvider.notifier)
        .fetchSenders(type: widget.type);
    final receivers = await ref
        .read(notifyViewModelProvider.notifier)
        .fetchReceivers(type: widget.type);

    // Biến tạm lưu giá trị chọn
    String? tempSenderId = _selectedSenderId;
    String? tempReceiverId = _selectedReceiverId;
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;

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
                      Text("Theo nguời gửi:",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: const Text("Chọn người gửi",
                              style: TextStyle(fontWeight: FontWeight.normal)),
                          items: senders.map((account) {
                            return DropdownMenuItem<String>(
                              value: account.id,
                              child: Text(account.teacher?.fullName ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal)),
                            );
                          }).toList(),
                          value: tempSenderId,
                          onChanged: (value) =>
                              setState(() => tempSenderId = value),
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
                      const SizedBox(height: 20),
                      Text("Theo nguời nhận:",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: const Text("Chọn người nhận",
                              style: TextStyle(fontWeight: FontWeight.normal)),
                          items: receivers.map((account) {
                            return DropdownMenuItem<String>(
                              value: account.id,
                              child: Text(account.parent?.fullName ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal)),
                            );
                          }).toList(),
                          value: tempReceiverId,
                          onChanged: (value) =>
                              setState(() => tempReceiverId = value),
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
                      const SizedBox(height: 30),
                      Text("Khoảng thời gian gửi :",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: tempStartDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() => tempStartDate = picked);
                                }
                              },
                              child: _buildDateInput(tempStartDate,
                                  label: "Từ ngày"),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.arrow_right),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: tempEndDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() => tempEndDate = picked);
                                }
                              },
                              child: _buildDateInput(tempEndDate,
                                  label: "Đến ngày"),
                            ),
                          ),
                        ],
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
                                  tempReceiverId = null;
                                  tempSenderId = null;
                                  tempStartDate = null;
                                  tempEndDate = null;

                                  _selectedReceiverId = null;
                                  _selectedSenderId = null;
                                  _startDate = null;
                                  _endDate = null;
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
                                _selectedReceiverId = tempReceiverId;
                                _selectedSenderId = tempSenderId;

                                _startDate = tempStartDate;
                                _endDate = tempEndDate;
                                Navigator.pop(context);
                                _fetchPage(
                                    receiverId: _selectedReceiverId,
                                    senderId: _selectedSenderId,
                                    startDate: _startDate,
                                    endDate: _endDate,
                                    type: widget.type);
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

  Widget _buildDateInput(DateTime? date, {required String label}) {
    return InputDecorator(
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        suffixIcon: const Icon(Icons.calendar_today,
            size: 20, color: Colors.blueAccent),
      ),
      child: Text(
        date != null ? "${date.day}/${date.month}/${date.year}" : label,
      ),
    );
  }
}
