import 'dart:html' as html;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:study_pulse_edu/models/app/Account.dart';
import 'package:study_pulse_edu/models/app/Parent.dart';
import 'package:study_pulse_edu/models/app/Student.dart';
import 'package:study_pulse_edu/resources/utils/app/app_theme.dart';

import '../../../../resources/constains/constants.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../resources/widgets/app_input.dart';
import '../../../../viewmodels/web/account_view_model.dart';

class EditAccountParentFormWidget extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final String accountId;

  const EditAccountParentFormWidget({
    super.key,
    required this.onClose,
    required this.accountId,
  });

  @override
  ConsumerState createState() => _EditAccountParentFormWidgetState();
}

class _EditAccountParentFormWidgetState
    extends ConsumerState<EditAccountParentFormWidget> with HelperMixin {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Phụ huynh
  final _parentNameController = TextEditingController();
  final _confirmCodeController = TextEditingController();
  final _relationshipController = TextEditingController();
  List<Map<String, TextEditingController>> _studentControllers = [];
  List<Gender?> _studentGenders = [];
  List<DateTime?> _studentBirthDates = [];
  List<String?> _studentCode = [];
  List<String?> _studentGenderErrors = [];
  List<String?> _studentBirthDateErrors = [];
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
        _studentGenderErrors.add(null);
        _studentBirthDateErrors.add(null);
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

    _parentNameController.dispose();
    _confirmCodeController.dispose();
    _relationshipController.dispose();

    for (var studentMap in _studentControllers) {
      for (var controller in studentMap.values) {
        controller.dispose();
      }
    }

    super.dispose();
  }

  void _addStudent() {
    _studentControllers.add({
      'name': TextEditingController(),
      'address': TextEditingController(),
    });
    _studentGenders.add(null);
    _studentBirthDates.add(null);
    _studentGenderErrors.add(null);
    _studentBirthDateErrors.add(null);
    _studentCode.add(null);
    setState(() {});
  }

  Widget _buildStudentGenderDropdown(int index) {
    return DropdownButtonFormField2<Gender>(
      value: _studentGenders.length > index ? _studentGenders[index] : null,
      decoration: InputDecoration(
        labelText: 'Giới tính',
        prefixIcon: Icon(Icons.wc),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      hint: Text(
        'Chọn giới tính',
        style: AppTheme.bodyMedium,
      ),
      style: AppTheme.bodyMedium,
      items: Gender.values.map((gender) {
        return DropdownMenuItem<Gender>(
          value: gender,
          child: Text(gender.displayGender),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          if (_studentGenders.length > index) {
            _studentGenders[index] = value;
          } else {
            _studentGenders.add(value);
          }
        });
      },
    );
  }

  Widget _buildStudentDatePicker(int index) {
    return Material(
      borderRadius: BorderRadius.circular(14),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2010),
            firstDate: DateTime(1990),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() {
              if (_studentBirthDates.length > index) {
                _studentBirthDates[index] = picked;
              } else {
                _studentBirthDates.add(picked);
              }
            });
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Ngày sinh',
            prefixIcon: Icon(Icons.calendar_month_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _studentBirthDates.length > index &&
                        _studentBirthDates[index] != null
                    ? '${_studentBirthDates[index]!.day}/${_studentBirthDates[index]!.month}/${_studentBirthDates[index]!.year}'
                    : 'Chọn ngày sinh',
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

  bool _validateStudents() {
    bool isValid = true;
    DateTime now = DateTime.now();
    for (int i = 0; i < _studentControllers.length; i++) {
      if (_studentGenders[i] == null) {
        _studentGenderErrors[i] = 'Giới tính không được bỏ trống';
        isValid = false;
      } else {
        _studentGenderErrors[i] = null;
      }

      if (_studentBirthDates[i] == null) {
        _studentBirthDateErrors[i] = 'Ngày sinh không được bỏ trống';
        isValid = false;
      } else {
        final birthDate = _studentBirthDates[i]!;
        final sixYearsAgo = DateTime(now.year - 6, now.month, now.day);

        if (birthDate.isAfter(now)) {
          _studentBirthDateErrors[i] =
              'Ngày sinh không được lớn hơn ngày hiện tại.';
          isValid = false;
        } else if (birthDate.isAfter(sixYearsAgo)) {
          _studentBirthDateErrors[i] = 'Học sinh phải đủ 6 tuổi trở lên';
          isValid = false;
        } else {
          _studentBirthDateErrors[i] = null;
        }
      }
    }

    setState(() {});
    return isValid;
  }

  Widget _buildParentForm() {
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildInput(
                  controller: _parentNameController,
                  labelText: "Họ tên phụ huynh",
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
                SizedBox(
                  height: 40.h,
                ),
                _buildInput(
                  controller: _confirmCodeController,
                  labelText: 'Mã xác nhận phụ huynh',
                  prefixIcon: const Icon(Icons.verified_user),
                  inputType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mã xác nhận phụ huynh không được để trống.';
                    }
                    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                      return 'Mã xác nhận phải là các số và gồm 6 chữ số.';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 40.h,
                ),
                _buildInput(
                  controller: _relationshipController,
                  labelText: 'Mối quan hệ với học sinh',
                  prefixIcon: const Icon(Icons.family_restroom),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mối quan hệ với học sinh không được để trống.';
                    }
                    return null;
                  },
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
                              controller: _studentControllers[index]['name']!,
                              labelText: 'Họ tên học sinh',
                              prefixIcon: Icon(Icons.person_outline),
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

                                if (RegExp(
                                        r'[!@#\$%^&*(),.?":{}|<>_\-=+~`\\/\[\]]')
                                    .hasMatch(value)) {
                                  return 'Họ tên không được chứa ký tự đặc biệt.';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 40.h),
                            _buildStudentDatePicker(index),
                            if (_studentBirthDateErrors[index] != null)
                              Padding(
                                padding: EdgeInsets.only(top: 8.h, left: 16.w),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _studentBirthDateErrors[index]!,
                                    style: AppTheme.bodySmall
                                        .copyWith(color: Colors.red.shade800),
                                  ),
                                ),
                              ),
                            SizedBox(height: 40.h),
                            _buildStudentGenderDropdown(index),
                            if (_studentGenderErrors[index] != null)
                              Padding(
                                padding: EdgeInsets.only(top: 8.h, left: 16.w),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _studentGenderErrors[index]!,
                                    style: AppTheme.bodySmall
                                        .copyWith(color: Colors.red.shade800),
                                  ),
                                ),
                              ),
                            SizedBox(height: 40.h),
                            _buildInput(
                                controller: _studentControllers[index]
                                    ['address']!,
                                labelText: 'Địa chỉ',
                                prefixIcon: Icon(Icons.map_outlined),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Địa chỉ không được để trống.';
                                  }

                                  if (RegExp(
                                          r'[!@#\$%^&*()?":{}|<>_\-=+~`\\/\[\]]')
                                      .hasMatch(value)) {
                                    return 'Địa chỉ không được chứa ký tự đặc biệt.';
                                  }
                                  return null;
                                }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addStudent,
                    icon: Icon(Icons.add),
                    label: Text('Thêm học sinh'),
                  ),
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
                      child: _isLoading
                          ? SizedBox.shrink()
                          : Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildParentForm(),
                                  SizedBox(
                                    width: 100.w,
                                    height: 60.h,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF3E61FC),
                                            Color(0xFF75D1F3)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(15.r),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          final viewModel = ref.read(
                                              accountViewModelProvider
                                                  .notifier);
                                          setState(() {
                                            for (int i = 0;
                                                i < _studentGenderErrors.length;
                                                i++) {
                                              _studentGenderErrors[i] = null;
                                              _studentBirthDateErrors[i] = null;
                                            }
                                          });

                                          bool isValidForm =
                                              _formKey.currentState!.validate();

                                          bool areStudentsValid =
                                              _validateStudents();
                                          if (!areStudentsValid) {
                                            isValidForm = false;
                                          }

                                          if (isValidForm) {
                                            //Call API
                                            final account = Account(
                                                role: Role.PARENT,
                                                parent: Parent(
                                                  fullName:
                                                      _parentNameController
                                                          .text,
                                                  verificationCode:
                                                      _confirmCodeController
                                                          .text,
                                                  relationship:
                                                      _relationshipController
                                                          .text,
                                                  students: List.generate(
                                                      _studentControllers
                                                          .length, (i) {
                                                    return Student(
                                                      studentCode:
                                                          _studentCode[i],
                                                      fullName:
                                                          _studentControllers[i]
                                                                  ['name']!
                                                              .text,
                                                      address:
                                                          _studentControllers[i]
                                                                  ['address']!
                                                              .text,
                                                      gender:
                                                          _studentGenders[i]!,
                                                      dateOfBirth:
                                                          _studentBirthDates[
                                                              i]!,
                                                    );
                                                  }),
                                                ));
                                            showLoading(context, show: true);
                                            final message =
                                                await viewModel.updateAccount(
                                                    accountId: widget.accountId,
                                                    account: account);
                                            showLoading(context, show: false);
                                            if (message != null) {
                                              showErrorToastWeb(
                                                  context, message);
                                            } else {
                                              widget.onClose();
                                              showSuccessToastWeb(context,
                                                  "Sửa tài khoản thành công");
                                            }
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
