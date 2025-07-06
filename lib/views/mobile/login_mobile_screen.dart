import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../resources/constains/constants.dart';
import '../../resources/utils/app/app_theme.dart';
import '../../resources/utils/data_sources/local.dart';
import '../../resources/utils/helpers/helper_mixin.dart';
import '../../resources/widgets/app_input.dart';
import '../../routes/route_const.dart';
import '../../viewmodels/auth_view_model.dart';

class LoginMobileScreen extends ConsumerStatefulWidget {
  const LoginMobileScreen({super.key});

  @override
  ConsumerState createState() => _LoginMobileScreenState();
}

class _LoginMobileScreenState extends ConsumerState<LoginMobileScreen>
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
      final message =
          await _authViewModel.loginMobile(phone: phone, password: password);
      showLoading(context, show: false);
      if (message == null) {
        final shared = await SharedPre.instance;
        final role = await shared.getString(SharedPrefsConstants.USER_ROLE_KEY);

        switch (role) {
          case 'TEACHER':
            goName(context, RouteConstants.homeTeacherRouteName);
            break;
          case 'PARENT':
            goName(context, RouteConstants.homeUserRouteName);
            break;
          default:
            showErrorToast('Vai trò người dùng không hợp lệ.');
        }
      } else {
        showErrorToast(message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            _buildBanner(),
            _buildLoginForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return SizedBox(
      height: 0.35.sh,
      width: 1.sw,
      child: Image.asset(
        'assets/images/banner2.png',
        fit: BoxFit.fill,
        height: double.infinity,
        width: double.infinity,
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      margin: EdgeInsets.only(top: 0.33.sh),
      padding: EdgeInsets.all(24.w),
      height: 0.67.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10.r,
            offset: Offset(0, -4.h),
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Center(
                child: Text("ĐĂNG NHẬP",
                    style: AppTheme.titleLarge.copyWith(
                        color: AppTheme.headerLineBackground2,
                        fontSize: 24.sp))),
            SizedBox(height: 80.h),
            _buildPhoneField(),
            SizedBox(height: 20.h),
            _buildPasswordField(),
            SizedBox(height: 35.h),
            _buildLoginButton()
          ],
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

  Widget _buildLoginButton() {
    return SizedBox(
      width: 180.w,
      height: 50.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3E61FC), Color(0xFF5EBAD7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.r),
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
    );
  }
}
