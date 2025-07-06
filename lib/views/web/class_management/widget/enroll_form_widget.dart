import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_pulse_edu/resources/utils/app/app_theme.dart';
import 'package:study_pulse_edu/viewmodels/web/class_student_view_model.dart';
import '../../../../models/app/PagingResponse.dart';
import '../../../../models/app/Student.dart';
import '../../../../resources/constains/constants.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../resources/widgets/pagination_widget.dart';

class EnrollFormWidget extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final String classID;

  const EnrollFormWidget(
      {super.key, required this.onClose, required this.classID});

  @override
  ConsumerState createState() => _EnrollFormWidgetState();
}

class _EnrollFormWidgetState extends ConsumerState<EnrollFormWidget>
    with HelperMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int currentPageIndex = 1;
  String? searchStudentCode;
  Set<String> selectedStudents = {};

  String? _errorEnroll;

  void _fetchPage({int? pageIndex, String? studentCode}) {
    final viewModel = ref.read(classStudentViewModelProvider.notifier);

    if (studentCode != null && studentCode.isNotEmpty) {
      // Nếu có tìm kiếm
      viewModel.fetchStudent(studentCode: studentCode, classID: widget.classID);
    } else {
      // Nếu không tìm kiếm
      viewModel.fetchStudent(
          pageIndex: pageIndex ?? 1, classID: widget.classID);
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
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _enroll() async {
    setState(() {
      _errorEnroll = null;
    });

    bool isValidForm = _formKey.currentState!.validate();
    if (selectedStudents.isEmpty) {
      setState(() {
        _errorEnroll = 'Vui lòng chọn ít nhất một học sinh để ghi danh.';
      });
      isValidForm = false;
    }

    if (isValidForm) {
      showLoading(context, show: true);
      final viewModel = ref.read(classStudentViewModelProvider.notifier);
      final message = await viewModel.enrollStudents(
        classId: widget.classID,
        studentIds: selectedStudents.toList(),
      );
      showLoading(context, show: false);
      if (message != null) {
        showErrorToastWeb(context, message);
      } else {
        widget.onClose();
        showSuccessToastWeb(context, "Ghi danh lớp học thành công");
      }
    }
  }

  void _unenroll(String studentId) async {
    await showConfirmDialogWeb(
      context: context,
      title: 'Thông báo',
      content: 'Bạn có muốn xóa học sinh khỏi lớp?',
      icon: Icons.notifications,
      onConfirm: () async {
        showLoading(context, show: true);
        final viewModel = ref.read(classStudentViewModelProvider.notifier);
        final message = await viewModel.unenrollStudent(
          classId: widget.classID,
          studentId: studentId,
        );
        showLoading(context, show: false);
        if (message != null) {
          showErrorToastWeb(context, message);
        } else {
          _fetchPage(pageIndex: currentPageIndex);
          showSuccessToastWeb(context, "Xóa học sinh khỏi lớp thành công");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pagingResponse = ref.watch(classStudentViewModelProvider);
    return Dialog(
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: 800.w,
        height: 1.sh,
        child: Column(
          children: [
            // --- Title ---
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
                            Icon(Icons.person_add),
                            SizedBox(width: 8),
                            Text(
                              'Ghi danh lớp học',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onClose,
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
                      child: Form(
                          key: _formKey,
                          child: Column(children: [
                            _buildHeader(),
                            SizedBox(
                              height: 40.h,
                            ),
                            _buildEnrollForm(pagingResponse),
                            SizedBox(height: 40.h),
                            _note(),
                            SizedBox(height: 40.h),
                            _buildPagination(pagingResponse),
                          ])),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120.w,
              height: 60.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3E61FC), Color(0xFF75D1F3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _enroll();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Text(
                    'Ghi danh',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            if (_errorEnroll != null)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  _errorEnroll!,
                  style:
                      AppTheme.bodySmall.copyWith(color: Colors.red.shade800),
                ),
              ),
          ],
        ),
        SizedBox(
          width: 240.w,
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
                hintText: 'Nhập mã học sinh',
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
                final studentCode = value.trim();
                _fetchPage(studentCode: studentCode);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnrollForm(AsyncValue<PagingResponse<Student>?> pagingResponse) {
    return pagingResponse.when(
      data: (response) {
        final students = response?.content ?? [];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            columnWidths: const {
              0: FixedColumnWidth(50),
              1: FixedColumnWidth(120),
              2: FixedColumnWidth(160),
              3: FixedColumnWidth(80),
              4: FixedColumnWidth(110),
              5: FixedColumnWidth(180),
            },
            border: TableBorder.all(color: Colors.grey.shade400),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              // Header
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFF25303C)),
                children: [
                  _buildHeaderCell(''),
                  _buildHeaderCell('Mã học sinh'),
                  _buildHeaderCell('Họ tên'),
                  _buildHeaderCell('Giới tính'),
                  _buildHeaderCell('Ngày sinh'),
                  _buildHeaderCell('Địa chỉ'),
                ],
              ),

              // Body rows
              for (var student in students)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: switch (student.enrollmentStatus) {
                          EnrollmentStatus.CAN_ENROLL => Checkbox(
                              value: selectedStudents.contains(student.id),
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    selectedStudents.add(student.id.toString());
                                  } else {
                                    selectedStudents.remove(student.id);
                                  }
                                });
                              },
                            ),
                          EnrollmentStatus.CONFLICT =>
                            const Icon(Icons.lock, color: Colors.grey),
                          EnrollmentStatus.ENROLLED => IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                _unenroll(student.id.toString());
                              },
                            ),
                          _ => const SizedBox.shrink(),
                        },
                      ),
                    ),
                    _buildCell(student.studentCode ?? ''),
                    _buildCell(student.fullName ?? ''),
                    _buildCell(student.gender?.displayGender ?? ''),
                    _buildCell(formatDate(student.dateOfBirth)),
                    _buildCell(student.address ?? ''),
                  ],
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Lỗi tải dữ liệu: $err")),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Text(
          text,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
        ),
      ),
    );
  }

  Widget _buildCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Widget _note() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.lock, color: Colors.grey, size: 20.sp),
              SizedBox(width: 6.w),
              Text('Học sinh trùng lịch', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 20.w,
                height: 20.h,
                child: Checkbox(
                  value: false,
                  onChanged: null,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              SizedBox(width: 6.w),
              Text('Có thể ghi danh', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
          Row(
            children: [
              Icon(Icons.close, color: Colors.red, size: 20.sp),
              SizedBox(width: 6.w),
              Text('Xóa khỏi lớp', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(AsyncValue<PagingResponse<Student>?> pagingResponse) {
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
}
