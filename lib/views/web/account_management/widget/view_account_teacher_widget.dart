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

class ViewAccountTeacherWidget extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final String accountId;

  const ViewAccountTeacherWidget({
    super.key,
    required this.onClose,
    required this.accountId,
  });

  @override
  ConsumerState createState() => _ViewAccountTeacherWidgetState();
}

class _ViewAccountTeacherWidgetState
    extends ConsumerState<ViewAccountTeacherWidget> with HelperMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _activeController = TextEditingController();

  String? _webImageData;

  // Giáo viên
  final _nameController = TextEditingController();
  final _genderController = TextEditingController();
  final _dateOfBirth = TextEditingController();
  final _addressController = TextEditingController();
  final _educationController = TextEditingController();
  final _specializationController = TextEditingController();
  final _bioController = TextEditingController();

  final _baseURL = "${ApiConstants.getBaseUrl}/uploads/";
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
      _nameController.text = account.teacher?.fullName ?? '';
      _genderController.text = account.teacher?.gender?.displayGender ?? '';
      _dateOfBirth.text = account.teacher?.dateOfBirth != null
          ? DateFormat('dd/MM/yyyy')
              .format(DateTime.parse(account.teacher!.dateOfBirth.toString()))
          : '';
      _addressController.text = account.teacher?.address ?? '';
      _educationController.text = account.teacher?.educationLevel ?? '';
      _specializationController.text = account.teacher?.specialization ?? '';
      _bioController.text = account.teacher?.introduction ?? '';

      setState(() {
        _webImageData = _baseURL + (account.teacher?.avatarUrl ?? '');
      });
    }
    showLoading(context, show: false);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();

    _phoneController.dispose();
    _genderController.dispose();
    _dateOfBirth.dispose();
    _roleController.dispose();
    _activeController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _educationController.dispose();
    _specializationController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  Widget _buildTeacherForm() {
    final state = ref.watch(accountViewModelProvider);
    return SizedBox(
      child: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 4,
              child: Column(
                children: [
                  Container(
                    height: 450.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.hardEdge,
                    // để bo góc cho Image bên trong
                    alignment: Alignment.center,
                    child: _webImageData != null
                        ? Image.network(
                            _webImageData!,
                            fit: BoxFit.fill,
                            width: double.infinity,
                            height: 450.h,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                  child: Text('Không tải được ảnh'));
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          )
                        : null,
                  ),
                ],
              ),
            ),
            SizedBox(width: 80.w),
            Flexible(
              flex: 6,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildInput(
                        controller: _phoneController,
                        labelText: "Số điện thoại",
                        prefixIcon: Icon(Icons.phone),
                        readOnly: true),
                    SizedBox(height: 40.h),
                    _buildInput(
                        controller: _roleController,
                        labelText: "Vai trò",
                        prefixIcon: Icon(Icons.switch_account),
                        readOnly: true),
                    SizedBox(height: 40.h),
                    _buildInput(
                        controller: _activeController,
                        labelText: "Trạng thái tài khoản",
                        prefixIcon: Icon(Icons.manage_accounts),
                        readOnly: true),
                    SizedBox(height: 40.h),
                    _buildInput(
                        controller: _nameController,
                        labelText: "Họ tên",
                        prefixIcon: Icon(Icons.person),
                        readOnly: true),
                    SizedBox(height: 40.h),
                    _buildInput(
                        controller: _genderController,
                        labelText: "Giới tính",
                        prefixIcon: Icon(Icons.wc),
                        readOnly: true),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 40.h),
        _buildInput(
            controller: _dateOfBirth,
            labelText: "Ngày sinh",
            prefixIcon: Icon(Icons.calendar_month),
            readOnly: true),
        SizedBox(height: 40.h),
        _buildInput(
            controller: _addressController,
            labelText: "Địa chỉ",
            prefixIcon: Icon(Icons.map_outlined),
            readOnly: true),
        SizedBox(height: 40.h),
        _buildInput(
            controller: _educationController,
            labelText: "Trình độ",
            prefixIcon: Icon(Icons.school),
            readOnly: true),
        SizedBox(height: 40.h),
        _buildInput(
            controller: _specializationController,
            labelText: "Chuyên môn",
            prefixIcon: Icon(Icons.bookmark_add_sharp),
            readOnly: true),
        SizedBox(height: 40.h),
        _buildInput(
            controller: _bioController,
            labelText: "Giới thiệu",
            prefixIcon: Icon(Icons.description),
            maxLines: 3,
            readOnly: true),
        SizedBox(height: 70.h),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.white,
      shape: RoundedRectangleBorder(
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
                                _buildTeacherForm(),
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
