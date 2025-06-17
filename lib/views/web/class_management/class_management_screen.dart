import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_pulse_edu/models/app/ClassA.dart';
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

  void _fetchPage({int? pageIndex, String? className}) {
    final viewModel = ref.read(classViewModelProvider.notifier);

    if (className != null && className.isNotEmpty) {
      // Nếu có tìm kiếm
      viewModel.fetchClasses(className: className);
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

  Widget _buildClassList(AsyncValue<PagingResponse<ClassA>?> pagingResponse) {
    return Expanded(
      child: pagingResponse.when(
        data: (pagingResponse) {
          final classes = pagingResponse?.content ?? [];
          return ListView.separated(
            itemCount: classes.length,
            separatorBuilder: (_, __) => Divider(height: 0),
            itemBuilder: (context, index) {
              final classA = classes[index];
              return ClassRowWidget(
                className: classA.className ?? '',
                nameTeacher: classA.teacher?.fullName ?? '',
                startDate: classA.startDate ?? DateTime.now(),
                endDate: classA.endDate ?? DateTime.now(),
                numberStudent: classA.students?.length ?? 0,
                maxStudent: classA.maxStudents ?? 0,
                status: classA.status ?? ClassStatus.ACTIVE,
                onToggle: () async {
                  bool success;
                  if (classA.status == ClassStatus.ACTIVE) {
                    success = await ref
                        .read(classViewModelProvider.notifier)
                        .disableClass(classA.id.toString());
                  } else {
                    success = await ref
                        .read(classViewModelProvider.notifier)
                        .enableClass(classA.id.toString());
                  }
                  return success;
                },
                onView: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => ViewClassWidget(
                      classID: classA.id.toString(),
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
                      classID: classA.id.toString(),
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
                      classID: classA.id.toString(),
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

  Widget _buildPagination(AsyncValue<PagingResponse<ClassA>?> pagingResponse) {
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
