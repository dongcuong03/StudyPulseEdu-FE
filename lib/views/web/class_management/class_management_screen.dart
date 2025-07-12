import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:study_pulse_edu/models/app/ClassRoom.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';
import 'package:study_pulse_edu/viewmodels/web/class_view_model.dart';
import 'package:study_pulse_edu/views/web/class_management/widget/add_class_form_widget.dart';
import 'package:study_pulse_edu/views/web/class_management/widget/class_row_widget.dart';
import 'package:study_pulse_edu/views/web/class_management/widget/edit_class_form_widget.dart';
import 'package:study_pulse_edu/views/web/class_management/widget/enroll_form_widget.dart';
import 'package:study_pulse_edu/views/web/class_management/widget/view_class_widget.dart';

import '../../../models/app/PagingResponse.dart';
import '../../../resources/utils/app/app_theme.dart';
import '../../../resources/utils/helpers/helper_mixin.dart';
import '../../../resources/widgets/pagination_widget.dart';
import '../../../viewmodels/web/account_view_model.dart';

class ClassManagementScreen extends ConsumerStatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  ConsumerState createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends ConsumerState<ClassManagementScreen>
    with HelperMixin {
  int currentPageIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  String? searchNameClass;

  String? _selectedTeacher;
  DateTime? _startDate;
  DateTime? _endDate;

  void _fetchPage(
      {int? pageIndex,
      String? className,
      String? teacherName,
      DateTime? startDate,
      DateTime? endDate}) {
    final viewModel = ref.read(classViewModelProvider.notifier);

    if ((className != null && className.isNotEmpty) ||
        (teacherName != null && teacherName.isNotEmpty) ||
        startDate != null ||
        endDate != null) {
      viewModel.fetchClasses(
        className: className,
        teacherName: teacherName,
        startDate: startDate,
        endDate: endDate,
      );
    } else {
      // Nếu không tìm kiếm
      viewModel.fetchClasses(pageIndex: pageIndex ?? 1);
    }
    setState(() {
      currentPageIndex = pageIndex ?? 1;
      searchNameClass = className?.isNotEmpty == true ? className : null;
    });
  }

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (_searchController.text.isEmpty && searchNameClass != null) {
        _fetchPage(pageIndex: 1);
      }
    });

    Future.microtask(() {
      _fetchPage(pageIndex: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pagingResponse = ref.watch(classViewModelProvider);
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
            _buildClassList(pagingResponse),
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
        SizedBox(
          width: 160.w,
          height: 60.h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3E61FC), Color(0xFF75D1F3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AddClassFormWidget(
                    onClose: () {
                      _fetchPage(pageIndex: 1);
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(
                'Thêm lớp học',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
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
                      offset: Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade500),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tên lớp học',
                    hintStyle: TextStyle(color: Colors.grey),
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
                    final className = value.trim();
                    _fetchPage(className: className);
                  },
                ),
              ),
            ),
            SizedBox(
              width: 20.w,
            ),
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
          Expanded(flex: 1, child: Text('Tên lớp học')),
          Expanded(flex: 1, child: Center(child: Text('Giáo viên'))),
          Expanded(flex: 1, child: Center(child: Text('Ngày bắt đầu'))),
          Expanded(flex: 1, child: Center(child: Text('Ngày kết thúc'))),
          Expanded(flex: 1, child: Center(child: Text('Số lượng học sinh'))),
          Expanded(flex: 2, child: Center(child: Text('Hành động'))),
        ],
      ),
    );
  }

  Widget _buildClassList(AsyncValue<PagingResponse<ClassRoom>?> pagingResponse) {
    return Expanded(
      child: pagingResponse.when(
        data: (pagingResponse) {
          final classes = pagingResponse?.content ?? [];
          return ListView.separated(
            itemCount: classes.length,
            separatorBuilder: (_, __) => Divider(height: 0),
            itemBuilder: (context, index) {
              final ClassRoom = classes[index];
              return ClassRowWidget(
                className: ClassRoom.className ?? '',
                nameTeacher: ClassRoom.teacher?.fullName ?? '',
                startDate: ClassRoom.startDate ?? DateTime.now(),
                endDate: ClassRoom.endDate ?? DateTime.now(),
                numberStudent: ClassRoom.students?.length ?? 0,
                maxStudent: ClassRoom.maxStudents ?? 0,
                status: ClassRoom.status ?? ClassStatus.ACTIVE,
                onToggle: () async {
                  bool success;
                  if (ClassRoom.status == ClassStatus.ACTIVE) {
                    success = await ref
                        .read(classViewModelProvider.notifier)
                        .disableClass(ClassRoom.id.toString());
                  } else {
                    success = await ref
                        .read(classViewModelProvider.notifier)
                        .enableClass(ClassRoom.id.toString());
                  }
                  if (success) {
                    _fetchPage(pageIndex: currentPageIndex);
                  }
                  return success;
                },
                onView: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => ViewClassWidget(
                      classID: ClassRoom.id.toString(),
                      onClose: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
                onEdit: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => EditClassFormWidget(
                      classID: ClassRoom.id.toString(),
                      onClose: () {
                        Navigator.of(context).pop();
                        _fetchPage(pageIndex: currentPageIndex);
                      },
                    ),
                  );
                },
                onEnroll: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => EnrollFormWidget(
                      classID: ClassRoom.id.toString(),
                      onClose: () {
                        Navigator.of(context).pop();
                        _fetchPage(pageIndex: currentPageIndex);
                      },
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

  Widget _buildPagination(AsyncValue<PagingResponse<ClassRoom>?> pagingResponse) {
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

  void _showFilterDialog() async {
    final teacherAccounts = await ref
        .read(accountViewModelProvider.notifier)
        .getAllAccountTeacher();

    final teacherNames = teacherAccounts
        .where((account) => account.role == Role.TEACHER)
        .map((account) => account.teacher?.fullName)
        .whereType<String>()
        .toSet()
        .toList();

    String? tempSelectedTeacher = _selectedTeacher;
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
                      Text("Theo giáo viên:",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: const Text("Chọn giáo viên",
                              style: TextStyle(fontWeight: FontWeight.normal)),
                          items: teacherNames.map((name) {
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Text(name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal)),
                            );
                          }).toList(),
                          value: tempSelectedTeacher,
                          onChanged: (value) =>
                              setState(() => tempSelectedTeacher = value),
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
                      Text("Thời gian bắt đầu - kết thúc:",
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
                                  tempSelectedTeacher = null;
                                  tempStartDate = null;
                                  tempEndDate = null;

                                  _selectedTeacher = null;
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
                                _selectedTeacher = tempSelectedTeacher;
                                _startDate = tempStartDate;
                                _endDate = tempEndDate;
                                Navigator.pop(context);
                                _fetchPage(
                                  teacherName: _selectedTeacher,
                                  startDate: _startDate,
                                  endDate: _endDate,
                                );
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
