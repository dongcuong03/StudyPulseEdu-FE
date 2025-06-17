import 'dart:html' as html;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:study_pulse_edu/resources/utils/app/app_theme.dart';

import '../../../../models/app/Account.dart';
import '../../../../models/app/Teacher.dart';
import '../../../../resources/constains/constants.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../resources/widgets/app_input.dart';
import '../../../../viewmodels/web/account_view_model.dart';

class EditAccountTeacherFormWidget extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final String accountId;

  const EditAccountTeacherFormWidget({
    super.key,
    required this.onClose,
    required this.accountId,
  });

  @override
  ConsumerState createState() => _EditAccountTeacherFormWidgetState();
}

class _EditAccountTeacherFormWidgetState
    extends ConsumerState<EditAccountTeacherFormWidget> with HelperMixin {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  String? _imgError;
  String? _genderError;
  String? _dateOfbirthError;

  Gender? _selectedGender;
  DateTime? _selectedDate;
  String? _webImageData;
  html.File? _avatarFile;

  // Giáo viên
  final _nameController = TextEditingController();
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
      _nameController.text = account.teacher?.fullName ?? '';
      _selectedGender = account.teacher?.gender;
      _selectedDate = account.teacher?.dateOfBirth;
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

  void _update() async {
    final viewModel = ref.read(accountViewModelProvider.notifier);

    Account account = Account(
        role: Role.TEACHER,
        teacher: Teacher(
            fullName: _nameController.text,
            gender: _selectedGender,
            dateOfBirth: _selectedDate,
            address: _addressController.text,
            educationLevel: _educationController.text,
            specialization: _specializationController.text,
            introduction: _bioController.text));

    //call api
    showLoading(context, show: true);
    final message = await viewModel.updateAccount(
        accountId: widget.accountId, account: account, avatarFile: _avatarFile);
    showLoading(context, show: false);
    if (message != null) {
      showErrorToastWeb(context, message);
    } else {
      widget.onClose();
      showSuccessToastWeb(context, "Sửa tài khoản thành công");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();

    _nameController.dispose();
    _addressController.dispose();
    _educationController.dispose();
    _specializationController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    final input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();
    input.onChange.listen((event) {
      final file = input.files!.first;
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) {
        setState(() {
          _webImageData = reader.result as String?;
          _avatarFile = file;
          _imgError = null;
        });
      });
    });
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField2<Gender>(
      decoration: InputDecoration(
        labelText: 'Giới tính',
        floatingLabelStyle: TextStyle(color: Colors.black),
        prefixIcon: const Icon(Icons.wc),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.blue.shade300),
        ),
      ),
      isExpanded: true,
      hint: Text(
        'Chọn giới tính',
        style: AppTheme.bodyMedium,
      ),
      value: _selectedGender,
      style: AppTheme.bodyMedium,
      items: Gender.values.map((gender) {
        return DropdownMenuItem<Gender>(
          value: gender,
          child: Text(gender.displayGender),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
    );
  }

  Widget _buildDatePicker() {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) setState(() => _selectedDate = picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Ngày sinh',
            prefixIcon: Icon(Icons.calendar_month_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.blue.shade300),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'Ngày sinh',
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.black54,
              ),
            ],
          ),

        ),
      ),
    );
  }

  Widget _buildTeacherForm() {
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 4,
            child: Column(
              children: [
                SizedBox(
                  height: 500.h,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(10),
                          color: AppTheme.white,
                          image: _webImageData != null
                              ? DecorationImage(
                                  image: NetworkImage(_webImageData!),
                                  fit: BoxFit.fill,
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: _webImageData == null
                            ? GestureDetector(
                                onTap: _pickImage,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_circle_outline_outlined,
                                        size: 40, color: Colors.black54),
                                    SizedBox(height: 8),
                                    Text('Chọn ảnh',
                                        style: AppTheme.bodyMedium
                                            .copyWith(color: Colors.black87)),
                                  ],
                                ),
                              )
                            : null,
                      ),
                      if (_webImageData != null)
                        Positioned(
                          bottom: -10,
                          right: -15,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.white,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.edit,
                                size: 23,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_imgError != null)
                  Padding(
                    padding: EdgeInsets.only(left: 8.w, top: 4.h),
                    child: Text(
                      _imgError!,
                      style: AppTheme.bodySmall
                          .copyWith(color: Colors.red.shade800),
                    ),
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
                    controller: _nameController,
                    labelText: "Họ tên",
                    prefixIcon: Icon(Icons.person),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Họ tên không được để trống.';
                      }
                      if (value.trim().length < 2) {
                        return 'Họ tên phải có ít nhất 2 ký tự.';
                      }
                      if (RegExp(r'[0-9]').hasMatch(value)) {
                        return 'Họ tên không được chứa ký tự số.';
                      }

                      if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-=+~`\\/\[\]]')
                          .hasMatch(value)) {
                        return 'Họ tên không được chứa ký tự đặc biệt.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 40.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGenderDropdown(),
                      if (_genderError != null)
                        Padding(
                          padding: EdgeInsets.only(left: 16.w, top: 4.h),
                          child: Text(
                            _genderError!,
                            style: AppTheme.bodySmall
                                .copyWith(color: Colors.red.shade800),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 40.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDatePicker(),
                      if (_dateOfbirthError != null)
                        Padding(
                          padding: EdgeInsets.only(left: 16.w, top: 4.h),
                          child: Text(
                            _dateOfbirthError!,
                            style: AppTheme.bodySmall
                                .copyWith(color: Colors.red.shade800),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 40.h),
                  _buildInput(
                    controller: _addressController,
                    labelText: "Địa chỉ",
                    prefixIcon: Icon(Icons.map_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Địa chỉ không được để trống.';
                      }

                      if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-=+~`\\/\[\]]')
                          .hasMatch(value)) {
                        return 'Địa chỉ không được chứa ký tự đặc biệt.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30.h),
                  _buildInput(
                    controller: _educationController,
                    labelText: "Trình độ",
                    prefixIcon: Icon(Icons.school),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Trình độ không được để trống.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30.h),
                  _buildInput(
                    controller: _specializationController,
                    labelText: "Chuyên môn",
                    prefixIcon: Icon(Icons.bookmark_add_sharp),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Chuyên môn không được để trống.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 40.h),
                  _buildInput(
                    controller: _bioController,
                    labelText: "Giới thiệu",
                    prefixIcon: Icon(Icons.description),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Giới thiệu không được để trống.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 70.h),
                ],
              ),
            ),
          ),
        ],
      ),
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
                              'Sửa tài khoản',
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
                        child: _isLoading
                            ? SizedBox.shrink()
                            : Column(
                                children: [
                                  _buildTeacherForm(),
                                  SizedBox(
                                    width: 100.w,
                                    height: 60.h,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF3E61FC),
                                            Color(0xFF75D1F3)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _imgError = null;
                                            _genderError = null;
                                            _dateOfbirthError = null;
                                          });

                                          bool isValidForm =
                                              _formKey.currentState!.validate();

                                          if (_webImageData == null) {
                                            setState(() {
                                              _imgError =
                                                  'Ảnh giáo viên không được để trống.';
                                            });
                                            isValidForm = false;
                                          }
                                          if (_selectedGender == null) {
                                            setState(() {
                                              _genderError =
                                                  'Giới tính không được để trống.';
                                            });
                                            isValidForm = false;
                                          }
                                          if (_selectedDate == null) {
                                            setState(() {
                                              _dateOfbirthError =
                                                  'Ngày sinh không được để trống.';
                                            });
                                            isValidForm = false;
                                          } else {
                                            final now = DateTime.now();
                                            final age = now.year -
                                                _selectedDate!.year -
                                                ((now.month <
                                                            _selectedDate!
                                                                .month ||
                                                        (now.month ==
                                                                _selectedDate!
                                                                    .month &&
                                                            now.day <
                                                                _selectedDate!
                                                                    .day))
                                                    ? 1
                                                    : 0);

                                            if (_selectedDate!.isAfter(now)) {
                                              setState(() {
                                                _dateOfbirthError =
                                                    'Ngày sinh không được lớn hơn ngày hiện tại.';
                                              });
                                              isValidForm = false;
                                            } else if (age < 18) {
                                              setState(() {
                                                _dateOfbirthError =
                                                    'Giáo viên phải đủ 18 tuổi.';
                                              });
                                              isValidForm = false;
                                            }
                                          }

                                          if (isValidForm) {
                                            _update();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.r),
                                          ),
                                        ),
                                        child: Text(
                                          'Sửa',
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
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
        maxLines: maxLines);
  }
}
