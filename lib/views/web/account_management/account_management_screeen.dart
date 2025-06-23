import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:study_pulse_edu/views/web/account_management/widget/account_row_widget.dart';
import 'package:study_pulse_edu/views/web/account_management/widget/add_account_form_widget.dart';
import 'package:study_pulse_edu/views/web/account_management/widget/edit_account_parent_form_widget.dart';
import 'package:study_pulse_edu/views/web/account_management/widget/edit_account_teacher_form_widget.dart';
import 'package:study_pulse_edu/views/web/account_management/widget/view_account_parent_widget.dart';
import 'package:study_pulse_edu/views/web/account_management/widget/view_account_teacher_widget.dart';

import '../../../models/app/Account.dart';
import '../../../models/app/PagingResponse.dart';
import '../../../resources/constains/constants.dart';
import '../../../resources/utils/app/app_theme.dart';
import '../../../resources/utils/helpers/helper_mixin.dart';
import '../../../resources/widgets/pagination_widget.dart';
import '../../../viewmodels/web/account_view_model.dart';

class AccountManagementScreeen extends ConsumerStatefulWidget {
  const AccountManagementScreeen({super.key});

  @override
  ConsumerState createState() => _AccountManagementScreeenState();
}

class _AccountManagementScreeenState
    extends ConsumerState<AccountManagementScreeen> with HelperMixin {
  bool isActive = true;
  int currentPageIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  String? searchPhone;
  Role? _selectedRole;
  Role? tempSelectedRole;

  void _fetchPage({int? pageIndex, String? phone, Role? role}) {
    final viewModel = ref.read(accountViewModelProvider.notifier);

    if (phone != null && phone.isNotEmpty || role != null ){

      viewModel.fetchAccounts(phone: phone, role: role);
    } else {

      viewModel.fetchAccounts(pageIndex: pageIndex ?? 1);
    }
    setState(() {
      currentPageIndex = pageIndex ?? 1;
      searchPhone = phone?.isNotEmpty == true ? phone : null;
    });
  }

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (_searchController.text.isEmpty && searchPhone != null) {
        _fetchPage(pageIndex: 1);
      }
    });

    Future.microtask(() {
      _fetchPage(pageIndex: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pagingResponse = ref.watch(accountViewModelProvider);

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
            _buildAccountList(pagingResponse),
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
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AddAccountFormWidget(
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
                'Tạo tài khoản',
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
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: 'Nhập số điện thoại',
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
                    final phone = value.trim();
                    _fetchPage(phone: phone);
                  },
                ),
              ),
            ),
            SizedBox(width: 20.w,),
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
          Expanded(flex: 1, child: Text('Số điện thoại')),
          Expanded(flex: 1, child: Center(child: Text('Vai trò'))),
          Expanded(
              flex: 1, child: Center(child: Text('Trạng thái toàn khoản'))),
          Expanded(flex: 2, child: Center(child: Text('Hành động'))),
        ],
      ),
    );
  }

  Widget _buildAccountList(
      AsyncValue<PagingResponse<Account>?> pagingResponse) {
    return Expanded(
      child: pagingResponse.when(
        data: (pagingResponse) {
          final accounts = pagingResponse?.content ?? [];
          return ListView.separated(
            itemCount: accounts.length,
            separatorBuilder: (_, __) => Divider(height: 0),
            itemBuilder: (context, index) {
              final account = accounts[index];
              return AccountRow(
                phone: account.phone.toString(),
                role: account.role,
                isActive: account.isActive ?? false,
                onToggle: () async {
                  bool success;
                  if (account.isActive == true) {
                    success = await ref
                        .read(accountViewModelProvider.notifier)
                        .disableAccount(account.id.toString());
                  } else {
                    success = await ref
                        .read(accountViewModelProvider.notifier)
                        .enableAccount(account.id.toString());
                  }
                  return success;
                },
                onView: () {
                  // Xem tài khoản

                  if (account.role?.displayName == 'Giáo viên') {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => ViewAccountTeacherWidget(
                        accountId: account.id.toString(),
                        onClose: () => Navigator.of(context).pop(),
                      ),
                    );
                  } else if (account.role?.displayName == 'Phụ huynh') {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => ViewAccountParentWidget(
                        accountId: account.id.toString(),
                        onClose: () => Navigator.of(context).pop(),
                      ),
                    );
                  }
                },
                onEdit: () {
                  // Sửa tài khoản
                  if (account.role?.displayName == 'Giáo viên') {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => EditAccountTeacherFormWidget(
                        accountId: account.id.toString(),
                        onClose: () {
                          Navigator.of(context).pop();
                          _fetchPage(pageIndex: currentPageIndex);
                        },
                      ),
                    );
                  } else if (account.role?.displayName == 'Phụ huynh') {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => EditAccountParentFormWidget(
                        accountId: account.id.toString(),
                        onClose: () {
                          Navigator.of(context).pop();
                          _fetchPage(pageIndex: currentPageIndex);
                        },
                      ),
                    );
                  }
                },
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi tải dữ liệu')),
      ),
    );
  }

  Widget _buildPagination(AsyncValue<PagingResponse<Account>?> pagingResponse) {
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
    tempSelectedRole = _selectedRole;

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
                      Center(child: Text("Bộ lọc tìm kiếm", style: AppTheme.titleMedium)),
                      const SizedBox(height: 20),

                      Text("Theo vai trò:", style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<Role>(
                          isExpanded: true,
                          hint: const Text("Chọn vai trò", style: TextStyle(fontWeight: FontWeight.normal)),
                          items: Role.values
                              .where((role) => role != Role.ADMIN)
                              .map((role) => DropdownMenuItem<Role>(
                            value: role,
                            child: Text(role.displayName,style: TextStyle(fontWeight: FontWeight.normal),),
                          ))
                              .toList(),
                          value: tempSelectedRole,
                          onChanged: (value) => setState(() => tempSelectedRole = value),
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
                            icon: Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
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
                                  tempSelectedRole = null;
                                  _selectedRole = null;
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
                                _selectedRole = tempSelectedRole;
                                Navigator.pop(context);
                                _fetchPage(role: _selectedRole);
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

