import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_pulse_edu/resources/utils/app/app_theme.dart';

import '../../resources/constains/constants.dart';
import '../../resources/utils/data_sources/local.dart';
import '../../resources/utils/helpers/helper_mixin.dart';
import '../../resources/widgets/app_input.dart';
import '../../routes/route_const.dart';
import '../../viewmodels/auth_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginWebScreen extends ConsumerStatefulWidget {
  const LoginWebScreen({super.key});

  @override
  ConsumerState createState() => _LoginWebScreenState();
}

class _LoginWebScreenState extends ConsumerState<LoginWebScreen>
    with HelperMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authViewModel = AuthViewModel();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final phone = _phoneController.text;
      final password = _passwordController.text;

      showLoading(context, show: true);
      final  message =
          await _authViewModel.loginWeb(phone: phone, password: password);
      showLoading(context, show: false);
      print(message);
      if (message == null) {
        final shared = await SharedPre.instance;
        final role = await shared.getString(SharedPrefsConstants.USER_ROLE_KEY);
        if (role == "ADMIN") {
          goName(context, RouteConstants.homeAdminRouteName);
        }else{
          showErrorToastWeb(context,'Vai trò người dùng không hợp lệ.');
        }
      } else {
        showErrorToastWeb(context, message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFE8F0F5),
              Color(0xFF70C0E5),
            ],
          ),
        ),
        child: Center(
          child: _formLogin(),
        ),
      ),
    );
  }


  Widget _buildPhoneField() {
    return AppInput(
      controller: _phoneController,
      inputType: TextInputType.phone,
      labelText: 'Số điện thoại',
      prefixIcon: const Icon(Icons.phone),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Số điện thoại không được để trống.';
        }
        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
          return 'Số điện thoại phải gồm 10 số.';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return AppInput(
      controller: _passwordController,
      isPasswordField: true,
      labelText: 'Mật khẩu',
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
    );
  }

  Widget _formLogin() {
    return Container(
      width: 860.w,
      height: 530.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20.r,
            offset: Offset(0, 30.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.r),
                bottomLeft: Radius.circular(15.r),
              ),
              child: Image.asset(
                'assets/images/banner2.png',
                fit: BoxFit.fill,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
          ),
          SizedBox(width: 60.w),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(right: 60.r),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("ĐĂNG NHẬP",
                        style: AppTheme.titleLarge.copyWith(
                            color: AppTheme.headerLineBackground2,
                            fontSize: 24.sp)),
                    SizedBox(height: 80.h),
                    _buildPhoneField(),
                    SizedBox(height: 20.h),
                    _buildPasswordField(),
                    SizedBox(height: 60.h),
                    SizedBox(
                      width: 180.w,
                      height: 60.h,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF3E61FC),
                              Color(0xFF80D7F5)

                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                          child: Text(
                            'Đăng nhập',
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
        ],
      ),
    );
  }
}
