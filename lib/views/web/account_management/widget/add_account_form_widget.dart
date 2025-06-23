import 'dart:html' as html;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_pulse_edu/models/app/Account.dart';
import 'package:study_pulse_edu/resources/utils/app/app_theme.dart';

import '../../../../models/app/Parent.dart';
import '../../../../models/app/Student.dart';
import '../../../../models/app/Teacher.dart';
import '../../../../resources/constains/constants.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';
import '../../../../resources/widgets/app_input.dart';
import '../../../../viewmodels/web/account_view_model.dart';

class AddAccountFormWidget extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const AddAccountFormWidget({
    super.key,
    required this.onClose,
  });

  @override
  ConsumerState createState() => _AddAccountFormWidgetState();
}

class _AddAccountFormWidgetState extends ConsumerState<AddAccountFormWidget>
    with HelperMixin {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Role? _selectedRole;
  String? _roleError;
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

  // Phụ huynh
  final _parentNameController = TextEditingController();
  final _confirmCodeController = TextEditingController();
  final _relationshipController = TextEditingController();
  List<Map<String, TextEditingController>> _studentControllers = [];
  List<Gender?> _studentGenders = [];
  List<DateTime?> _studentBirthDates = [];
  List<String?> _studentGenderErrors = [];
  List<String?> _studentBirthDateErrors = [];

  @override
  void initState() {
    super.initState();
    _addStudent(); // Thêm sẵn 1 học sinh
  }

  @override
  void dispose() {
    _scrollController.dispose();

    _phoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _educationController.dispose();
    _specializationController.dispose();
    _bioController.dispose();

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

  void _addStudent() {
    _studentControllers.add({
      'name': TextEditingController(),
      'address': TextEditingController(),
    });
    _studentGenders.add(null);
    _studentBirthDates.add(null);
    _studentGenderErrors.add(null);
    _studentBirthDateErrors.add(null);

    setState(() {});
  }

  void _addAccount() async {
    setState(() {
      _roleError = null;
      _imgError = null;
      _genderError = null;
      _dateOfbirthError = null;
      for (int i = 0; i < _studentGenderErrors.length; i++) {
        _studentGenderErrors[i] = null;
        _studentBirthDateErrors[i] = null;
      }
    });

    bool isValidForm = _formKey.currentState!.validate();

    if (_selectedRole == null) {
      setState(() {
        _roleError = 'Vai trò không được để trống.';
      });
      isValidForm = false;
    }

    if (_selectedRole == Role.TEACHER) {
      if (_webImageData == null) {
        setState(() {
          _imgError = 'Ảnh giáo viên không được để trống.';
        });
        isValidForm = false;
      }
      if (_selectedGender == null) {
        setState(() {
          _genderError = 'Giới tính không được để trống.';
        });
        isValidForm = false;
      }
      if (_selectedDate == null) {
        setState(() {
          _dateOfbirthError = 'Ngày sinh không được để trống.';
        });
        isValidForm = false;
      } else {
        final now = DateTime.now();
        final age = now.year -
            _selectedDate!.year -
            ((now.month < _selectedDate!.month ||
                    (now.month == _selectedDate!.month &&
                        now.day < _selectedDate!.day))
                ? 1
                : 0);

        if (_selectedDate!.isAfter(now)) {
          setState(() {
            _dateOfbirthError = 'Ngày sinh không được lớn hơn ngày hiện tại.';
          });
          isValidForm = false;
        } else if (age < 18) {
          setState(() {
            _dateOfbirthError = 'Giáo viên phải đủ 18 tuổi.';
          });
          isValidForm = false;
        }
      }
    } else if (_selectedRole == Role.PARENT) {
      bool areStudentsValid = _validateStudents();
      if (!areStudentsValid) {
        isValidForm = false;
      }
    }

    if (isValidForm) {
      print(_selectedRole);
      final viewModel = ref.read(accountViewModelProvider.notifier);
      List<Student> students = [];

      for (int i = 0; i < _studentControllers.length; i++) {
        final nameController = _studentControllers[i]['name'];
        final addressController = _studentControllers[i]['address'];
        final gender = _studentGenders.length > i ? _studentGenders[i] : null;
        final birthDate =
            _studentBirthDates.length > i ? _studentBirthDates[i] : null;

        if (nameController != null &&
            nameController.text.isNotEmpty &&
            addressController != null &&
            addressController.text.isNotEmpty) {
          students.add(Student(
            fullName: nameController.text,
            gender: gender,
            dateOfBirth: birthDate,
            address: addressController.text,
          ));
        }
      }

      Account account = Account(
        phone: _phoneController.text,
        password: _passwordController.text,
        role: _selectedRole,
        teacher: _selectedRole?.displayName == "Giáo viên"
            ? Teacher(
                fullName: _nameController.text,
                gender: _selectedGender,
                dateOfBirth: _selectedDate,
                address: _addressController.text,
                educationLevel: _educationController.text,
                specialization: _specializationController.text,
                introduction: _bioController.text)
            : null,
        parent: _selectedRole?.displayName == "Phụ huynh"
            ? Parent(
                fullName: _parentNameController.text,
                verificationCode: _confirmCodeController.text,
                relationship: _relationshipController.text,
                students: students)
            : null,
      );

      //call api
      showLoading(context, show: true);
      final message = await viewModel.createAccount(
          account: account, avatarFile: _avatarFile);
      showLoading(context, show: false);
      if (message != null) {
        showErrorToastWeb(context, message);
      } else {
        widget.onClose();
        showSuccessToastWeb(context, "Tạo tài khoản thành công");
      }
    }
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
      borderRadius: BorderRadius.circular(14),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
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
                    : 'Chọn ngày sinh',
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.black54,
              ),
            ],
          ),


        ),
      ),
    );
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
            prefixIcon: Icon(Icons.calendar_month),
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
            ]

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

  Widget _buildTeacherForm() {
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
          Expanded(
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
                  SizedBox(height: 30.h),
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
                  SizedBox(height: 30.h),
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
                  SizedBox(height: 30.h),
                  _buildInput(
                    controller: _addressController,
                    labelText: "Địa chỉ",
                    prefixIcon: Icon(Icons.map_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Địa chỉ không được để trống.';
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
                  SizedBox(height: 30.h),
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
                  height: 30.h,
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
                  height: 30.h,
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
                  height: 30.h,
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
                            SizedBox(height: 30.h),
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
                            SizedBox(height: 30.h),
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
                            SizedBox(height: 30.h),
                            _buildInput(
                                controller: _studentControllers[index]
                                    ['address']!,
                                labelText: 'Địa chỉ',
                                prefixIcon: Icon(Icons.map_outlined),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Địa chỉ không được để trống.';
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
                              'Tạo tài khoản',
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInput(
                                    controller: _phoneController,
                                    labelText: 'Số điện thoại',
                                    prefixIcon: const Icon(Icons.phone),
                                    inputType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Số điện thoại không được để trống.';
                                      }
                                      if (!RegExp(r'^\d{10}$')
                                          .hasMatch(value)) {
                                        return 'Số điện thoại phải gồm 10 số.';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 80.w),
                                Expanded(
                                  child: _buildInput(
                                    controller: _passwordController,
                                    labelText: 'Mật khẩu',
                                    isPasswordField: true,
                                    prefixIcon: const Icon(Icons.lock),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Mật khẩu không được để trống';
                                      }
                                      if (value.length < 6) {
                                        return 'Mật khẩu phải gồm ít nhất 6 ký tự';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Vai trò:',
                                        style: AppTheme.bodyMedium),
                                    SizedBox(width: 30.w),
                                    Row(
                                      children: [
                                        Radio<Role>(
                                          value: Role.TEACHER,
                                          groupValue: _selectedRole,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedRole = value;
                                              _roleError = null;
                                              for (int i = 0;
                                                  i <
                                                      _studentGenderErrors
                                                          .length;
                                                  i++) {
                                                _studentGenderErrors[i] = null;
                                                _studentBirthDateErrors[i] =
                                                    null;
                                              }
                                            });
                                          },
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        Text('Giáo viên',
                                            style: AppTheme.bodyMedium),
                                        SizedBox(width: 40.w),
                                        Radio<Role>(
                                          value: Role.PARENT,
                                          groupValue: _selectedRole,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedRole = value;
                                              _roleError = null;
                                              _imgError = null;
                                              _genderError = null;
                                              _dateOfbirthError = null;
                                            });
                                          },
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        Text('Phụ huynh',
                                            style: AppTheme.bodyMedium),
                                      ],
                                    ),
                                  ],
                                ),
                                if (_roleError != null)
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 8.w, top: 4.h),
                                    child: Text(
                                      _roleError!,
                                      style: AppTheme.bodySmall
                                          .copyWith(color: Colors.red.shade800),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 30.h),
                            if (_selectedRole == Role.TEACHER)
                              _buildTeacherForm(),
                            if (_selectedRole == Role.PARENT)
                              _buildParentForm(),
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
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    _addAccount();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Tạo',
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
