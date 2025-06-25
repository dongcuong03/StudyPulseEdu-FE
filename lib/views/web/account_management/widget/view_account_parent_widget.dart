import 'dart:html' as html;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:study_pulse_edu/resources/utils/app/app_theme.dart';

import '../../../../resources/constains/constants.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../resources/widgets/app_input.dart';
import '../../../../viewmodels/web/account_view_model.dart';

class ViewAccountParentWidget extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final String accountId;

  const ViewAccountParentWidget({
    super.key,
    required this.onClose,
    required this.accountId,
  });

  @override
  ConsumerState createState() => _ViewAccountParentWidgetState();
}

class _ViewAccountParentWidgetState
    extends ConsumerState<ViewAccountParentWidget> with HelperMixin {
  final ScrollController _scrollController = ScrollController();

  // Phụ huynh
  final _phoneController = TextEditingController();
  final _roleController = TextEditingController();
  final _activeController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _confirmCodeController = TextEditingController();
  final _relationshipController = TextEditingController();
  List<Map<String, TextEditingController>> _studentControllers = [];
  List<Gender?> _studentGenders = [];
  List<DateTime?> _studentBirthDates = [];
  List<String?> _studentCode = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccountData();
  }

  Future<void> _loadAccountData() async {
    setState(() {
      _isLoading = true;
    });
    showLoading(context, show: true);

    final account = await ref
        .read(accountViewModelProvider.notifier)
        .getAccountById(widget.accountId);

    if (account != null) {
      _phoneController.text = account.phone ?? '';
      _roleController.text = account.role?.displayName ?? '';
      _activeController.text =
          (account.isActive ?? false) ? "Đang hoạt động" : "Đã vô hiệu hóa";
      _parentNameController.text = account.parent?.fullName ?? '';
      _confirmCodeController.text = account.parent?.verificationCode ?? '';
      _relationshipController.text = account.parent?.relationship ?? '';

      // Xử lý danh sách học sinh
      final students = account.parent?.students ?? [];

      for (var student in students) {
        _studentCode.add(student.studentCode);
        _studentControllers.add({
          'name': TextEditingController(text: student.fullName ?? ''),
          'address': TextEditingController(text: student.address ?? ''),
        });
        _studentGenders.add(student.gender);
        _studentBirthDates.add(student.dateOfBirth);
      }
    }
    showLoading(context, show: false);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    _parentNameController.dispose();
    _confirmCodeController.dispose();
    _relationshipController.dispose();
    _activeController.dispose();
    for (var studentMap in _studentControllers) {
      for (var controller in studentMap.values) {
        controller.dispose();
      }
    }

    super.dispose();
  }

  Widget _buildParentForm() {
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                          controller: _phoneController,
                          labelText: "Số điện thoại",
                          prefixIcon: Icon(Icons.phone),
                          readOnly: true),
                    ),
                    SizedBox(
                      width: 60.w,
                    ),
                    Expanded(
                      child: _buildInput(
                          controller: _parentNameController,
                          labelText: "Họ tên phụ huynh",
                          prefixIcon: Icon(Icons.person),
                          readOnly: true),
                    )
                  ],
                ),
                SizedBox(
                  height: 60.h,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                          controller: _roleController,
                          labelText: "Vai trò",
                          prefixIcon: Icon(Icons.switch_account),
                          readOnly: true),
                    ),
                    SizedBox(
                      width: 40.w,
                    ),
                    Expanded(
                      child: _buildInput(
                          controller: _activeController,
                          labelText: "Trạng thái tài khoản",
                          prefixIcon: Icon(Icons.manage_accounts),
                          readOnly: true),
                    )
                  ],
                ),
                SizedBox(
                  height: 60.h,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                          controller: _confirmCodeController,
                          labelText: 'Mã xác nhận phụ huynh',
                          prefixIcon: const Icon(Icons.verified_user),
                          readOnly: true),
                    ),
                    SizedBox(
                      width: 40.w,
                    ),
                    Expanded(
                      child: _buildInput(
                          controller: _relationshipController,
                          labelText: 'Mối quan hệ với học sinh',
                          prefixIcon: const Icon(Icons.family_restroom),
                          readOnly: true),
                    )
                  ],
                ),

                SizedBox(
                  height: 40.h,
                ),
                Text('Thông tin học sinh',
                    style: AppTheme.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _studentControllers.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: AppTheme.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                      margin: EdgeInsets.symmetric(vertical: 31.h),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildInput(
                                controller: TextEditingController(
                                  text: _studentCode[index],
                                ),
                                labelText: 'Mã học sinh',
                                prefixIcon: Icon(Icons.key_outlined),
                                readOnly: true),
                            SizedBox(height: 40.h),
                            _buildInput(
                                controller: _studentControllers[index]['name']!,
                                labelText: 'Họ tên học sinh',
                                prefixIcon: Icon(Icons.person_outline),
                                readOnly: true),
                            SizedBox(height: 40.h),
                            _buildInput(
                              controller: TextEditingController(
                                text: _studentGenders[index]?.displayGender,
                              ),
                              labelText: 'Giới tính',
                              prefixIcon: Icon(Icons.wc),
                              readOnly: true,
                            ),
                            SizedBox(height: 40.h),
                            _buildInput(
                              controller: TextEditingController(
                                text: DateFormat('dd/MM/yyyy')
                                    .format(_studentBirthDates[index]!),
                              ),
                              labelText: 'Ngày sinh',
                              prefixIcon: Icon(Icons.calendar_month_outlined),
                              readOnly: true,
                            ),
                            SizedBox(height: 40.h),
                            _buildInput(
                                controller: _studentControllers[index]
                                    ['address']!,
                                labelText: 'Địa chỉ',
                                prefixIcon: Icon(Icons.map_outlined),
                                readOnly: true)
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountViewModelProvider);
    return Dialog(
      backgroundColor: AppTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: 800.w,
        height: 1.sh, // CỐ ĐỊNH chiều cao dialog
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
                            Icon(Icons.person),
                            SizedBox(width: 8),
                            Text(
                              'Xem tài khoản',
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
                      child: _isLoading
                          ? SizedBox.shrink()
                          : Column(
                              children: [
                                _buildParentForm(),
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

  Widget _buildInput({
    required TextEditingController controller,
    required String labelText,
    required Icon prefixIcon,
    String? Function(String?)? validator,
    bool isPasswordField = false,
    int? maxLines,
    bool readOnly = false,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return AppInput(
      controller: controller,
      labelText: labelText,
      prefixIcon: prefixIcon,
      validator: validator,
      isPasswordField: isPasswordField,
      inputType: inputType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      readOnly: readOnly,
    );
  }
}
